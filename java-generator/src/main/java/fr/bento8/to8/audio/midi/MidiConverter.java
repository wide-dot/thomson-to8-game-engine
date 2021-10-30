package fr.bento8.to8.audio.midi;

import java.io.File;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

import javax.sound.midi.MetaMessage;
import javax.sound.midi.MidiEvent;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.Sequence;
import javax.sound.midi.ShortMessage;
import javax.sound.midi.SysexMessage;
import javax.sound.midi.Track;

import fr.bento8.to8.util.FileUtil;

public class MidiConverter{

	public static void main(String[] args) throws Exception {
		Sequence sequence = MidiSystem.getSequence(new File(args[0]));
		
		if (sequence.getDivisionType() != Sequence.PPQ) {
			throw new Exception("Midi file should have Division Type set to PPQ. SMPTE not yet supported.");
		}
		
		// MIDI files use two values to specify the timing :
		// - the resolution (measured in ticks per quarter note) (File Header)
		// - the tempo (measured in microseconds per quarter note) (META message)		
		int tickpQrt = sequence.getResolution();
		
		// Parse first track for tempo messages and create a list of tempos
		List<long[]> tempoLst = initTempo(sequence, tickpQrt);
		
		// Parse last track for midi messages and replace messages tick by 50hz wait frames
		Track track = sequence.getTracks()[sequence.getTracks().length-1];
		byte[] data = getMT32Data(track, tickpQrt, tempoLst);
		Files.write(new File(FileUtil.removeExtension(args[0])+".to8.mid").toPath(), data);	
	}
	
	public static List<long[]> initTempo(Sequence sequence, int tickpQrt) {
		long bpm = 500000; // default tempo (120bpm)
		int lastFrame = 0, curFrame = 0;
		long lastTick = 0;
		List<long[]> tempoLst = new ArrayList<long[]>();
		
		Track track = sequence.getTracks()[0];
		tempoLst.add(new long[]{0, 0, bpm});
		
		for (int i=0; i < track.size(); i++) {
			MidiEvent event = track.get(i);
			MidiMessage message = event.getMessage();
			
			// Read new TEMPO
			// The following is an example of a MIDI set tempo meta message.
			// 0xFF 0x51 0x03 0x07 0xA1 0x20
			//
			// - The status byte 0xFF shows that this is a meta message.
			// - The second byte is the meta type 0x51 and signifies that this is a set tempo meta message.
			// - The third byte is 3, which means that there are three remaining bytes.
			// - These three bytes form the hexadecimal value 0x07A120 (500000 decimal), which means that there are 500,000 microseconds per quarter note.
			//
			// Since there are 60,000,000 microseconds per minute, the message above translates to: set the tempo to 60,000,000 / 500,000 = 120 quarter notes per minute (120 beats per minute).
			// This message would normally appear in the first track chunk. If this message does not appear, the default tempo is 120 beats per minute as in the example above.
			// This message is important if the MIDI time division is specified in "pulses per quarter note", as such MIDI time division defines the number of ticks per quarter note, but does not itself define the length of the quarter note.
			// The length of the quarter note is then defined with the set tempo meta message described here.		
			// BPM = (60/(500,000e-6))*b/4, with b the lower numeral of the time signature
			
			if (message instanceof MetaMessage && ((MetaMessage)message).getMessage().length > 0 && ((MetaMessage)message).getMessage()[1] == (byte) 0x51) {
				curFrame = tick2Frame(bpm, tickpQrt, event.getTick()-lastTick) + lastFrame;
				bpm = ((((MetaMessage)message).getMessage()[3] & 0xff) << 16) + ((((MetaMessage)message).getMessage()[4] & 0xff) << 8) + ((((MetaMessage)message).getMessage()[5] & 0xff));
				
				if (event.getTick() == 0) {
					tempoLst.set(0, new long[]{0, 0, bpm});
				} else {
					tempoLst.add(new long[]{event.getTick(), curFrame, bpm});
				}
				
				lastFrame = curFrame;
				lastTick = event.getTick();
			}
		}
			
		return tempoLst;
	}	
	
	public static byte[] getMT32Data(Track track, int tickpQrt, List<long[]> tempoLst) {
		byte[] data = new byte[2097152]; // 2Mo Buffer
		int dataIdx = 0;
		
		long absolTick = 0;
		long absolFrame = 0;
		long lastAbsolFrame = 0;
		int relativeFrame = 0;
		
		for (int i = 0; i < track.size(); i++) {
			
			MidiEvent event = track.get(i);
			
			// MT-32 keep only supported messages
			MidiMessage message = event.getMessage();
			if (message instanceof ShortMessage && (
				((ShortMessage)message).getCommand() == ShortMessage.NOTE_ON ||
				((ShortMessage)message).getCommand() == ShortMessage.NOTE_OFF ||
				((ShortMessage)message).getCommand() == ShortMessage.CONTROL_CHANGE ||
				((ShortMessage)message).getCommand() == ShortMessage.PROGRAM_CHANGE ||
				((ShortMessage)message).getCommand() == ShortMessage.PITCH_BEND ||
				((ShortMessage)message).getCommand() == ShortMessage.ACTIVE_SENSING ||
				((ShortMessage)message).getCommand() == ShortMessage.END_OF_EXCLUSIVE) || (
				message instanceof SysexMessage)) {
					
				// get absolute tick and convert into relative frames
				absolTick = event.getTick();
				absolFrame = tick2Frame(tickpQrt, absolTick, tempoLst);
				relativeFrame = (int) (absolFrame - lastAbsolFrame);
				lastAbsolFrame = absolFrame;
				
				System.out.print("wait ");
				// write relative frame wait (msb 0)
				while (relativeFrame > 0) {
					data[dataIdx++] = (byte) ((relativeFrame%127) & 0xFF);
					System.out.print(" ("+absolTick+")");
					System.out.print(" "+String.format("%02X", (data[dataIdx-1])));
					relativeFrame -= relativeFrame%127;
				}
				
				System.out.print(" data ");
				// write message data (msb 1)
				for (int j = 0; j < message.getLength(); j++) {
					data[dataIdx++] = message.getMessage()[j];
					System.out.print(" "+String.format("%02X", (data[dataIdx-1])));
				}	
				
				System.out.println("");
			}
		}
		
		// Read from buffer to final byte array
		byte[] newData = new byte[dataIdx];
		for (int i = 0; i < dataIdx; i++) {
			newData[i] = data[i];
		}
		return newData;
	}	
	
	private static int tick2Frame(long bpm, int tickpQrt, long msgTicks) {
		return (int) Math.round((msgTicks * (bpm/1000000.0) * 50) / tickpQrt);
	}	
	
	private static int tick2Frame(int tickpQrt, long msgTicks, List<long[]> tempoLst) {
		// get frame index for last valid tempo
		int i;
		for (i = 0; i < tempoLst.size(); i++) {
			if (tempoLst.get(i)[0] > msgTicks)
				break;
		}
		i--;
		
		// from this index get the absolute frame value
		int absFrame = (int) Math.round(tempoLst.get(i)[1] + ((msgTicks - tempoLst.get(i)[0]) * (tempoLst.get(i)[2]/1000000.0) * 50 ) / tickpQrt);
		
		return absFrame;
	}	
	
    public static String hex(byte[] bytes) {
        StringBuilder result = new StringBuilder();
        for (byte aByte : bytes) {
            result.append(String.format("%02X", aByte));
        }
        return result.toString();
    }	
}