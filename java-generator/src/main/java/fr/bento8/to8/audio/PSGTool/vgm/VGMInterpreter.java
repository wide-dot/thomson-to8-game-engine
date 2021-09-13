package fr.bento8.to8.audio.PSGTool.vgm;

import java.io.File;
import java.io.IOException;
import java.util.LinkedList;

public class VGMInterpreter {
	public static final int SAMPLES_PER_SECOND = 44100;

	public static final int SAMPLES_PER_FRAME_NTSC = 735;

	public static final int SAMPLES_PER_FRAME_PAL = 882;

	private final VGMInputStream input;

	private final int samplesPerFrame;

	private int samplesToWait;

	private LinkedList<VGMListener> listenerList = new LinkedList<VGMListener>();

	private VGMListener[] listeners = new VGMListener[0];

	public VGMInterpreter(File paramFile) throws IOException {
		this.input = new VGMInputStream(paramFile);
		int i = this.input.getRate();
		this.samplesPerFrame = (i == 0) ? SAMPLES_PER_FRAME_NTSC : (SAMPLES_PER_SECOND / i);
	}

	public boolean run(int paramInt) throws IOException {
		boolean psgFrame = false;
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
				if (!psgFrame && skipFrame)
					paramInt -= 1;
				psgFrame = false;
				skipFrame = false;
				continue;
			} 
			switch (i) {
			case 79:
				this.input.read();
				skipFrame = true;          
				continue;
			case 80:
				fireWritePSGport(this.input.read());
				psgFrame = true;
				continue;
			case 97:
				paramInt -= this.input.readShort();
				psgFrame = false;
				skipFrame = false;
				continue;
			case 98:
				paramInt -= SAMPLES_PER_FRAME_NTSC;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 99:
				paramInt -= SAMPLES_PER_FRAME_PAL;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 102:
				close();
				return false;
			case 144:
				this.input.skip(4L);
				skipFrame = true;
				continue;
			case 145:
				this.input.skip(4L);
				skipFrame = true;
				continue;
			case 146:
				this.input.skip(5L);
				skipFrame = true;
				continue;
			case 0x93: // DAC Stream Control Write - Start Stream
				this.input.skip(10L);
				skipFrame = true;
				continue;
			case 0x94: // DAC Stream Control Write - Stop Stream
				this.input.skip(1L);
				skipFrame = true;
				continue;
			case 0x95: // DAC Stream Control Write - Start Stream (fast call)
				this.input.skip(4L);
				skipFrame = true;
				continue;	          
			case 0x51: case 0x52: case 0x53: case 0x54: case 0x55: case 0x56: case 0x57: case 0x58: case 0x59: case 0x5A: case 0x5B: case 0x5C: case 0x5D: case 0x5E: case 0x5F:        	
				this.input.skip(2L); // data reg
				skipFrame = true;
				continue;          
			case 0x67:
				this.input.skip(2L);
				this.input.skip(this.input.readInt()); // data block
				skipFrame = true;
				continue;
			case 0x80:
				skipFrame = true;        	
				continue;
			case 0x81:
				paramInt -= 1;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x82:
				paramInt -= 2;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x83:
				paramInt -= 3;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x84:
				paramInt -= 4;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x85:
				paramInt -= 5;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x86:
				paramInt -= 6;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x87:
				paramInt -= 7;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x88:
				paramInt -= 8;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x89:
				paramInt -= 9;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x8A:
				paramInt -= 10;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x8B:
				paramInt -= 11;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x8C:
				paramInt -= 12;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x8D:
				paramInt -= 13;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x8E:
				paramInt -= 14;
				psgFrame = false;
				skipFrame = false;
				continue;
			case 0x8F:
				paramInt -= 15;
				psgFrame = false;
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

	protected final void fireWritePSGport(int paramInt) {
		VGMListener[] arrayOfVGMListener;
		int i = (arrayOfVGMListener = this.listeners).length;
		for (byte b = 0; b < i; b++) {
			VGMListener vGMListener = arrayOfVGMListener[b];
			vGMListener.writePSGport(paramInt);
		} 
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
