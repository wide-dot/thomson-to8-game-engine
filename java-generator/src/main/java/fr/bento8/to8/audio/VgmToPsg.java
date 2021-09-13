package fr.bento8.to8.audio;

import java.io.EOFException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class VgmToPsg{
	
	// Sverx's VGM to PSG converter
	// Conversion depuis vgm2psg.c (PSGlib)
	// Ajout du support du YM2413

	static int VGM_OLD_HEADERSIZE = 64;            // 'old' VGM header
	static byte VGM_HEADER_SIGNATURE = (byte) 0x00;
	static byte VGM_HEADER_LOOPPOINT = (byte) 0x1C;
	static byte VGM_HEADER_FRAMERATE = (byte) 0x24;
	static byte VGM_DATA_OFFSET = (byte) 0x34;

	static final byte VGM_GGSTEREO = (byte) 0x4F;
	static final byte VGM_PSGFOLLOWS = (byte) 0x50;
	static final byte VGM_FRAMESKIP_NTSC = (byte) 0x62;
	static final byte VGM_FRAMESKIP_PAL = (byte) 0x63;
	static final byte VGM_SAMPLESKIP = (byte) 0x61;
	static final byte VGM_ENDOFDATA = (byte) 0x66;

	static int MAX_WAIT = 7;                       // fits in 3 bits only

	static byte PSG_ENDOFDATA = (byte) 0x00;
	static byte PSG_LOOPMARKER = (byte) 0x01;
	static byte PSG_WAIT = (byte) 0x38;

	static int CHANNELS = 4;	
	
	static byte[] loop_offset_b = new byte[4];;
	static int loop_offset;
	static byte[] data_offset_b = new byte[4];;
	static int data_offset;
	static FileOutputStream fOUT;	
	
	static byte[] volume = {(byte) 0x0F, (byte) 0x0F, (byte) 0x0F, (byte) 0x0F};  // starting volume = silence
	static int[] freq = {0,0,0,0};
	static boolean[] volume_change = {false,false,false,false};
	static boolean[] freq_change = {false,false,false,false};
	static boolean[] hi_freq_change = {false,false,false,false};
	static boolean frame_started = true;
	static boolean pause_started = false;
	static int pause_len = 0;
	static int lastlatch = (byte) 0x9F;                  // latch volume silent on channel 0
	static boolean[] active={false,false,false,false};
	static boolean is_sfx = false;
	
	private static int fromByteArray(byte[] bytes, int offset) {
	// LittleEndian
	     return ((bytes[offset+3] & 0xFF) << 24) | 
	            ((bytes[offset+2] & 0xFF) << 16) | 
	            ((bytes[offset+1] & 0xFF) << 8 ) | 
	            ((bytes[offset+0] & 0xFF) << 0 );
	}	
	
	private static void decLoopOffset(int n) {
	  loop_offset-=n;
	}

	private static void incLoopOffset() {
	  loop_offset++;
	}  

	private static boolean checkLoopOffset() {     // returns 1 when loop_offset becomes 0
	  return (loop_offset==0);
	}	
	
	private static void init_frame(boolean initial_state) {
		int i;
		for (i=0;i<CHANNELS;i++) {
			if ((!initial_state) ||                                // set to false
				((initial_state) && (!is_sfx)) ||                  // or set to true if it's not a SFX
		        ((initial_state) && (is_sfx) && (active[i]))) {    // or set to true if it's a SFX and the chn is active
		      volume_change[i]=initial_state;    
		      freq_change[i]=initial_state;
		      hi_freq_change[i]=initial_state;
		    }
		  }
		  frame_started=initial_state;
	}

	private static void add_command (int c) {
		int chn,typ;
		if ((c&(byte)0x80)!=0) {                 // it's a latch
			chn=(c&(byte)0x60)>>5;
			typ=(c&(byte)0x10)>>4;
			if (typ==1) {
				volume[chn]=(byte)(c&0x0F);
				volume_change[chn]=true;
			} else {
				freq[chn]=(freq[chn]&0xFFF0)|(c&0x0F);
				freq_change[chn]=true;
			}
		} else {                                 // it's a data (not a latch)
			chn=(lastlatch&0x60)>>5;
			typ=(lastlatch&0x10)>>4;	
			if (typ==1) {
				volume[chn]=(byte)(c&0x0F);
				volume_change[chn]=true;
			} else {
				if ((c&0x3F)!=(freq[chn]>>4))    // see if we're really changing the high part of the frequence or not
					hi_freq_change[chn]=true;
				freq[chn]=(freq[chn]&0x000F)|((c&0x3F)<<4);
				freq_change[chn]=true;
			}
		}  	
	}

	private static void dump_frame() throws IOException {
		int i;
		byte c;
		for (i=0;i<CHANNELS-1;i++) {
			if (freq_change[i]) {
				c=(byte)((freq[i]&0x0F)|(i<<5)|(byte)0x80); // latch channel 0-2 freq
				fOUT.write(c);
				if (hi_freq_change[i]) {               // DATA byte needed?
					c=(byte)((freq[i]>>4)|(byte)0x40);                 // make sure DATA bytes have 1 as 6th bit
					fOUT.write(c);
				}
			}

			if (volume_change[i]) {
				c=(byte)((byte)0x90|(i<<5)|(volume[i]&(byte)0x0F));        // latch channel 0-2 volume
				fOUT.write(c);
			}

		}

		if (freq_change[3]) {
			c=(byte)((freq[i]&0x07)|(byte)0xE0);                   // latch channel 3 (noise)
			fOUT.write(c);
		}

		if (volume_change[3]) {
			c=(byte)((byte)0x90|(i<<5)|(volume[3]&(byte)0x0F));          // latch channel 3 volume
			fOUT.write(c);
		}
	}


	private static void dump_pause() throws IOException {
		if (pause_len>0) {
			while (pause_len>MAX_WAIT) {
				fOUT.write(PSG_WAIT+MAX_WAIT);   // write PSG_WAIT+7 to file
				pause_len-=MAX_WAIT+1;           // skip MAX_WAIT+1 
			}
			if (pause_len>0)
				fOUT.write(PSG_WAIT+(pause_len-1));  // write PSG_WAIT+[0 to 7] to file, don't do it if 0
		}
	}

	private static void found_pause() throws IOException {
		if (frame_started) {
			dump_frame();
			init_frame(false);
		}
		pause_started=true;
	}

	private static void found_frame() throws IOException {
		if (pause_started)
			dump_pause();
		frame_started=true;

		pause_started=false;
		pause_len=0;
	}

	private static void empty_data() throws IOException {
		if (pause_started) {
			dump_pause();
			pause_len=0;
			pause_started=false;
		} else if (frame_started) {
			dump_frame();
			init_frame(false);
		}
	}


	private static void writeLoopMarker() throws IOException {
		empty_data();
		fOUT.write(PSG_LOOPMARKER);
	}


	public static void main(String[] args) throws Throwable {
		int i;
		int c;
		int pos = 0;
		boolean leave = false;
		boolean fatal = false;
		int ss,fs;
		int latched_chn=0;
		boolean first_byte=true;
		int file_signature;
		int frame_rate;
		int sample_divider=735;                            // NTSC (default)

		System.out.println("*** Sverx's VGM to PSG converter ***");

		if ((args.length<2) || (args.length>3)) {
			System.out.println("Arguments: inputfile.VGM outputfile.PSG [2|3|23]");
			System.out.println(" the optional third parameter specifies which channel(s) should be active,");
			System.out.println(" for SFX conversion:");
			System.out.println(" - 2 means the SFX is using channel 2 only");
			System.out.println(" - 3 means the SFX is using channel 3 (noise) only");
			System.out.println(" - 23 means the SFX is using both channels");
			return;
		}

		if (args.length==3) {
			for (i=0;i<CHANNELS;i++)
				active[i]=false;

			for (i=0;i<args[2].length();i++) {
				switch (args[2].charAt(i)) {
				case '2':
					active[2]=true;
					break;
				case '3':
					active[3]=true;
					break;
				}
			}
			is_sfx=true;
			System.out.println("Info: SFX conversion on channel(s): "+(active[2]?"2":"")+(active[3]?"3":"")+"");
		}

		init_frame(true);

		byte[] fIN = Files.readAllBytes(Paths.get(args[0]));
		if (fIN == null) {
			System.out.println("Fatal: can't open input VGM file");
			return;
		}

		file_signature = fromByteArray(fIN, VGM_HEADER_SIGNATURE);
		if (file_signature!=544040790) {    // check for 'Vgm ' file signature
			System.out.println("Fatal: input file doesn't seem a valid VGM/VGZ file");
			return;
		}

		frame_rate = fromByteArray(fIN, VGM_HEADER_FRAMERATE); // read frame_rate in the VGM header
		if (frame_rate==60) {
			System.out.println("Info: NTSC (60Hz) VGM detected");	
		} else if (frame_rate==50) {
			System.out.println("Info: PAL (50Hz) VGM detected");
			sample_divider=882;                           // PAL!
		} else {
			System.out.println("Warning: unknown frame rate, assuming NTSC (60Hz)");	
		}

		loop_offset = fromByteArray(fIN, VGM_HEADER_LOOPPOINT); // read loop_offset
		data_offset = fromByteArray(fIN, VGM_DATA_OFFSET); // read data_offset
		if (data_offset>0) {
			data_offset=VGM_DATA_OFFSET+data_offset; // skip VGM header
		} else {
			data_offset=VGM_OLD_HEADERSIZE; // skip 'old' VGM header
		}
		
		pos = data_offset;
		if (loop_offset!=0) {
			System.out.format("Info: loop point at 0x%04x\n",loop_offset);
			loop_offset=loop_offset+VGM_HEADER_LOOPPOINT-data_offset;
		} else {
			System.out.println("Info: no loop point defined");
			loop_offset=-1; // make it negative so that won't happen
		}

		fOUT = new FileOutputStream(args[1]);
		if (fOUT == null) {
			System.out.println("Fatal: can't write to output PSG file");
			return;
		}

		try {
		while ((!leave)) {
			c = fIN[pos];
			pos += 1;
			decLoopOffset(1);
			if (checkLoopOffset()) writeLoopMarker();

			switch (c) {

			case VGM_GGSTEREO:            // stereo data byte follows
				// BETA: this is simply DISCARDED atm
				c = fIN[pos];
				pos += 1;
				System.out.println("Warning: GameGear stereo info discarded");
				decLoopOffset(1);
				if (checkLoopOffset()) writeLoopMarker();
				break;

			case VGM_PSGFOLLOWS:          // PSG byte follows

				c = fIN[pos];
				pos += 1;

				if ((c&(byte)0x80)!=0) {
					lastlatch=c;               // latch value
					latched_chn=(c&0x60)>>5;   // isolate chn number
				} else {
					c|=0x40;                   // make sure DATA bytes have 1 as 6th bit
				}

				if ((!is_sfx) || (active[latched_chn])) {   // output only if on an active channel

					found_frame();

					if ((first_byte) && ((c&0x80)==0)) {
						add_command(lastlatch);
						System.out.println("Warning: added missing latch command in frame start");
					}
					add_command(c);
					first_byte=false;
				}

				decLoopOffset(1);
				if (checkLoopOffset()) writeLoopMarker();
				break;

			case VGM_FRAMESKIP_NTSC:
			case VGM_FRAMESKIP_PAL:

				// frame skip, now count how many
				found_pause();

				fs=1;
				do {
					c = fIN[pos];
					pos += 1;
					if ((c==VGM_FRAMESKIP_NTSC) || (c==VGM_FRAMESKIP_PAL)) fs++;
					decLoopOffset(1);
				} while ((fs<MAX_WAIT) && ((c==VGM_FRAMESKIP_NTSC) || (c==VGM_FRAMESKIP_PAL)) && (!checkLoopOffset()));

				if ((c!=VGM_FRAMESKIP_NTSC) && (c!=VGM_FRAMESKIP_PAL)) {
                    pos -= 1;
					incLoopOffset();
				}

				pause_len+=fs;
				if (checkLoopOffset()) writeLoopMarker();

				first_byte=true;

				break;

			case VGM_SAMPLESKIP:         // sample skip, now count how many

				found_pause();

				c = fIN[pos];
				pos += 1;
				ss=c;
				c = fIN[pos];
				pos += 1;
				ss+=c*256;
				fs=ss/sample_divider;                           // samples to frames
				if ((ss%sample_divider)!=0) {
					System.out.println("Warning: pause length isn't perfectly frame sync'd");
					if ((ss%sample_divider)>(sample_divider/2))   // round to closest int
						fs++;
				}

				pause_len+=fs;

				decLoopOffset(2);
				if (checkLoopOffset()) writeLoopMarker();

				first_byte=true;

				break;


			case VGM_ENDOFDATA:         // end of data
				leave = true;
				decLoopOffset(1);
				if (checkLoopOffset()) writeLoopMarker();
				empty_data();
				fOUT.write(PSG_ENDOFDATA);
				break;

			default:
				System.out.format("Fatal: found unknown char 0x%02x at 0x08x\n",c,pos-1);
				leave = true;
				fatal = true;
				break;
			}

		}

		fOUT.close();
		} catch (EOFException e) {

		}
		
		if (!fatal) {
			System.out.println("Info: conversion complete");
		}
		return;
	}
}