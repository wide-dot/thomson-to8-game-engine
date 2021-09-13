package fr.bento8.to8.audio.YMTool.vgm;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedList;

import fr.bento8.to8.audio.YMTool.YMTool;

public class VGMInterpreter {
	public static final int SAMPLES_PER_SECOND = 44100;

	public static final int SAMPLES_PER_FRAME_NTSC = 735;

	public static final int SAMPLES_PER_FRAME_PAL = 882;

	private final VGMInputStream input;

	private final int samplesPerFrame;

	private int samplesToWait;
	
	private int dataBlock = 0;

	private LinkedList<VGMListener> listenerList = new LinkedList<VGMListener>();

	private VGMListener[] listeners = new VGMListener[0];

	public VGMInterpreter(File paramFile) throws IOException {
		this.input = new VGMInputStream(paramFile);
		int i = this.input.getRate();
		this.samplesPerFrame = (i == 0) ? SAMPLES_PER_FRAME_NTSC : (SAMPLES_PER_SECOND / i);
	}

	public boolean run(int paramInt) throws IOException {
		boolean dacFrame = false;
		boolean skipFrame = false;
		if (paramInt == 0)
			paramInt = this.samplesPerFrame; 
		paramInt -= this.samplesToWait;
		while (paramInt > 0) {
			if (this.input.isLoopPoint())
				fireLoopPointHit(); 
			int i = this.input.read();
			if ((i & 0xF0) == 112) {
				paramInt -= (i & 0xF) + 1;
				if (!dacFrame && skipFrame)
					paramInt -= 1;
				dacFrame = false;
				skipFrame = false;
				continue;
			} 
			switch (i) {
			case 0x4F: // Game Gear PSG stereo, write dd to port 0x06
				this.input.read();
				skipFrame = true;          
				continue;
			case 0x50: // PSG (SN76489/SN76496) write value dd
				// fireWriteYMport(this.input.read());
				this.input.read();
				skipFrame = true;
				continue;
			case 0x61: // Wait n samples, n can range from 0 to 65535
				paramInt -= this.input.readShort();
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x62: // wait 735 samples (60th of a second)
				paramInt -= SAMPLES_PER_FRAME_NTSC;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x63: // wait 882 samples (50th of a second)
				paramInt -= SAMPLES_PER_FRAME_PAL;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x66: // end of sound data
				close();
				return false;
			case 0x90: // DAC Stream Control Write - Setup Stream Control
				this.input.skip(4L);
				dacFrame = true;
				continue;
			case 0x91: // DAC Stream Control Write - Set Stream Data
				this.input.skip(4L);
				dacFrame = true;
				continue;
			case 0x92: // DAC Stream Control Write - Set Stream Frequency
				this.input.skip(5L);
				dacFrame = true;
				continue;
			case 0x93: // DAC Stream Control Write - Start Stream
				this.input.skip(10L);
				dacFrame = true;
				continue;
			case 0x94: // DAC Stream Control Write - Stop Stream
				this.input.skip(1L);
				dacFrame = true;
				continue;
			case 0x95: // DAC Stream Control Write - Start Stream (fast call)
				this.input.skip(4L);
				dacFrame = true;
				continue;				
			case 0x51: case 0x52: case 0x53: case 0x54: case 0x55: case 0x56: case 0x57: case 0x58: case 0x59: case 0x5A: case 0x5B: case 0x5C: case 0x5D: case 0x5E: case 0x5F:        	
				this.input.skip(2L); // data reg
				skipFrame = true;
				continue;          
			case 0x67:
				this.input.skip(2L);
				fireWriteDac(this.input.readInt()); // data block
				skipFrame = true;
				continue;
				
				// TODO check DAC enable sinon on ne declenche pas de lecture
				// moyenne par sample des ecarts entre chaque lecture de sample
				// donne une valeur entiere byte et une valeur decimale byte
				// chaque valeur est associée à un evenement de lecture
				
			case 0x80:
				skipFrame = true;        	
				continue;
			case 0x81:
				paramInt -= 1;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x82:
				paramInt -= 2;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x83:
				paramInt -= 3;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x84:
				paramInt -= 4;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x85:
				paramInt -= 5;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x86:
				paramInt -= 6;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x87:
				paramInt -= 7;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x88:
				paramInt -= 8;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x89:
				paramInt -= 9;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x8A:
				paramInt -= 10;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x8B:
				paramInt -= 11;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x8C:
				paramInt -= 12;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x8D:
				paramInt -= 13;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x8E:
				paramInt -= 14;
				dacFrame = false;
				skipFrame = false;
				continue;
			case 0x8F:
				paramInt -= 15;
				dacFrame = false;
				skipFrame = false;
				continue;            
			case 0xE0:        	
				this.input.skip(4L); // data reg
				skipFrame = true;
				continue;               
			} 
			close();
			throw new IOException("Unknown VGM command encountered at " + Integer.toHexString(this.input.getPosition() - 1) + ": " + Integer.toHexString(i));
		} 
		if (paramInt <= 0)
			this.samplesToWait = -paramInt; 
		return true;
	}

	public int getTotalSamples() {
		return this.input.getTotalSamples();
	}

	public void close() throws IOException {
		this.input.close();
	}

	protected final void fireWriteYMport(int paramInt) {
		VGMListener[] arrayOfVGMListener;
		int i = (arrayOfVGMListener = this.listeners).length;
		for (byte b = 0; b < i; b++) {
			VGMListener vGMListener = arrayOfVGMListener[b];
			vGMListener.writeYMport(paramInt);
		} 
	}
	
	protected final void fireWriteDac(int dataLength) throws IOException {
		Path path = Paths.get(YMTool.outputFilename+String.format(".b%02X", dataBlock & 0xFF));
		Files.write(path, this.input.readNBytes(dataLength));		
		dataBlock++;
	}	

	protected final void fireLoopPointHit() {
		VGMListener[] arrayOfVGMListener;
		int i = (arrayOfVGMListener = this.listeners).length;
		for (byte b = 0; b < i; b++) {
			VGMListener vGMListener = arrayOfVGMListener[b];
			vGMListener.loopPointHit();
		} 
	}

	public final void addVGMPortListener(VGMListener paramVGMListener) {
		this.listenerList.addFirst(paramVGMListener);
		this.listeners = this.listenerList.<VGMListener>toArray(new VGMListener[this.listenerList.size()]);
	}

	public final void removeVGMPortListener(VGMListener paramVGMListener) {
		this.listenerList.remove(paramVGMListener);
		this.listeners = this.listenerList.<VGMListener>toArray(new VGMListener[this.listenerList.size()]);
	}
}
