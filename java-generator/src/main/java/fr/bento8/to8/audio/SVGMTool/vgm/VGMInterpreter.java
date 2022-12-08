package fr.bento8.to8.audio.SVGMTool.vgm;

import java.io.File;
import java.io.IOException;

import fr.bento8.to8.audio.SVGMTool.SVGMTool;

public class VGMInterpreter {
	public static final int SAMPLES_PER_SECOND = 44100;
	public static final int SAMPLES_PER_FRAME_NTSC = 735;
	public static final int SAMPLES_PER_FRAME_PAL = 882;

	private VGMInputStream input;
	public int[] arrayOfInt = new int[0x80000];
	public int i = 0;
	public int loopMarkerHit = 0;
	public int cumulatedFrames = 0;
	public int[] drum = new int[]{0x30, 0x28, 0x21, 0x22, 0x24};

	public VGMInterpreter(File paramFile) throws IOException {
		this.input = new VGMInputStream(paramFile);
		while(run()) {
		}
	}

	public boolean run() throws IOException {
		boolean skipFrame = false;

		while (!skipFrame) {
			if (this.input.isLoopPoint())
				fireLoopPointHit(); 
			int i = this.input.read();

			switch (i) {
			case 0x4F: // Game Gear PSG stereo, write dd to port 0x06
				this.input.read();
				continue;
			case 0x50: // PSG (SN76489/SN76496) write value dd
				int val = this.input.read();
				if (val <= 127 )
					val = val | 0b01000000;
				fireWrite(val);
				continue;
			case 0x51: // YM2413, write value dd to register aa
				int cmd = this.input.read();
				int data = this.input.read();

				// Overwrite drum volume
				if (cmd==0x36)
					data = SVGMTool.drumVol[0];
				if (cmd==0x37)
					data = SVGMTool.drumVol[1];
				if (cmd==0x38)
					data = SVGMTool.drumVol[2];
				
				fireWrite(cmd);
				fireWrite(data);
				
				continue;          				
			case 0x52: case 0x53: case 0x54: case 0x55: case 0x56: case 0x57: case 0x58: case 0x59: case 0x5A: case 0x5B: case 0x5C: case 0x5D: case 0x5E: case 0x5F:        	
				this.input.skip(2L); // write value dd to register aa
				continue;          								
			case 0x61: // Wait n samples, n can range from 0 to 65535
				int waitTime = this.input.readShort();
				if (waitTime%SAMPLES_PER_FRAME_PAL != 0) {
					close();
					throw new IOException("0x61 VGM command not supported at " + Integer.toHexString(this.input.getPosition() - 3) + ": " + Integer.toHexString(waitTime) + "\n");
				}
            	cumulatedFrames += waitTime/SAMPLES_PER_FRAME_PAL;				
				skipFrame = true;
				continue;
			case 0x62: // wait 735 samples (60th of a second)
				close();
				throw new IOException("0x62 VGM command not supported at " + Integer.toHexString(this.input.getPosition() - 3) + "\nOnly PAL wait frame is supported either 0x61 0x72 0x03 or 0x63 command");
            case 0x63: // wait 882 samples (50th of a second)
            	cumulatedFrames++;
				skipFrame = true;
				continue;
			case 0x66: // end of sound data
				fireWriteEnd();				
				close();
				return false;
			case 0x67: // data block
				continue;				
			case 0x80: case 0x81: case 0x82: case 0x83: case 0x84: case 0x85: case 0x86: case 0x87: case 0x88: case 0x89: case 0x8A: case 0x8B: case 0x8C: case 0x8D: case 0x8E: case 0x8F:
				this.input.skip(1L);
				continue;
			case 0x90: // DAC Stream Control Write - Setup Stream Control
				this.input.skip(4L);
				continue;
			case 0x91: // DAC Stream Control Write - Set Stream Data
				this.input.skip(4L);
				continue;
			case 0x92: // DAC Stream Control Write - Set Stream Frequency
				this.input.skip(5L);
				continue;
			case 0x93: // DAC Stream Control Write - Start Stream
				this.input.skip(10L);
				continue;
			case 0x94: // DAC Stream Control Write - Stop Stream
				this.input.skip(1L);
				continue;
			case 0x95: // DAC Stream Control Write - Start Stream (fast call)
				fireWrite(0x0E);
				fireWrite(0x20);
				fireWrite(0x0E);
				this.input.read();      // Stream id
				int blockId = this.input.readShort(); // Block id
				fireWrite(drum[blockId%drum.length]);
				this.input.skip(1L);    // skip Flags
				continue;								
			case 0xE0:        	
				this.input.skip(4L); // data reg
				continue;               
			} 
			close();
			throw new IOException("Unknown VGM command encountered at " + Integer.toHexString(this.input.getPosition() - 1) + ": " + Integer.toHexString(i));
		} 

		return true;
	}

	public int getTotalSamples() {
		return this.input.getTotalSamples();
	}

	public void close() throws IOException {
		this.input.close();
	}

	public void fireLoopPointHit() {
		loopMarkerHit = i;
	}
	
	public void fireWrite(int paramInt) {
		while (cumulatedFrames > 0) {
			arrayOfInt[i++] = 0x39;
			if (cumulatedFrames > 127) {
				arrayOfInt[i++] = cumulatedFrames;
				cumulatedFrames -= 127;
			} else {
				arrayOfInt[i++] = cumulatedFrames;
				cumulatedFrames = 0;
			}
		}
		arrayOfInt[i++] = paramInt;
	}
	
	public void fireWriteEnd() {
		arrayOfInt[i++] = 0x39;
		arrayOfInt[i++] = 0x00;
	}
	
	public int[] getArrayOfInt() {
		return arrayOfInt;
	}
	
	public int getLastIndex() {
		return i;
	}	
}
