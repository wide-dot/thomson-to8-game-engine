package fr.bento8.to8.audio.YmVoice;

public class OPLLVoice {

	class OPLLSlotParam {
		byte am;
		byte pm;
		byte eg;
		byte ml;
		byte kr;
		byte kl;
		byte tl;
		byte ar;
		byte dr;
		byte sl;
		byte rr;
		byte ws;

		public OPLLSlotParam(OPLLSlotParam init) {
			this.am = init.am;
			this.pm = init.pm;
			this.eg = init.eg;
			this.ml = init.ml;
			this.kr = init.kr;
			this.kl = init.kl;
			this.tl = init.tl;
			this.ar = init.ar;
			this.dr = init.dr;
			this.sl = init.sl;
			this.rr = init.rr;
			this.ws = init.ws;
		};

		public OPLLSlotParam(byte am, byte pm, byte eg, byte ml, byte kr, byte kl, byte tl, byte ar, byte dr, byte sl, byte rr, byte ws) {
			this.am = am;
			this.pm = pm;
			this.eg = eg;
			this.ml = ml;
			this.kr = kr;
			this.kl = kl;
			this.tl = tl;
			this.ar = ar;
			this.dr = dr;
			this.sl = sl;
			this.rr = rr;
			this.ws = ws;
		};		  
	}  

	private static byte[][] _OPLL_ROM_PATCHES = new byte[][] {
		{(byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00},
		{(byte)0x71, (byte)0x61, (byte)0x1e, (byte)0x17, (byte)0xd0, (byte)0x78, (byte)0x00, (byte)0x17}, // 1: Violin
		{(byte)0x13, (byte)0x41, (byte)0x1a, (byte)0x0d, (byte)0xd8, (byte)0xf7, (byte)0x23, (byte)0x13}, // 2: Guitar
		{(byte)0x13, (byte)0x01, (byte)0x99, (byte)0x00, (byte)0xf2, (byte)0xd4, (byte)0x21, (byte)0x23}, // 3: Piano
		{(byte)0x11, (byte)0x61, (byte)0x0e, (byte)0x07, (byte)0x8d, (byte)0x64, (byte)0x70, (byte)0x27}, // 4: Flute
		{(byte)0x32, (byte)0x21, (byte)0x1e, (byte)0x06, (byte)0xe1, (byte)0x76, (byte)0x01, (byte)0x28}, // 5: Clarinet
		{(byte)0x31, (byte)0x22, (byte)0x16, (byte)0x05, (byte)0xe0, (byte)0x71, (byte)0x00, (byte)0x18}, // 6: Oboe
		{(byte)0x21, (byte)0x61, (byte)0x1d, (byte)0x07, (byte)0x82, (byte)0x81, (byte)0x11, (byte)0x07}, // 7: Trumpet
		{(byte)0x33, (byte)0x21, (byte)0x2d, (byte)0x13, (byte)0xb0, (byte)0x70, (byte)0x00, (byte)0x07}, // 8: Organ
		{(byte)0x61, (byte)0x61, (byte)0x1b, (byte)0x06, (byte)0x64, (byte)0x65, (byte)0x10, (byte)0x17}, // 9: Horn
		{(byte)0x41, (byte)0x61, (byte)0x0b, (byte)0x18, (byte)0x85, (byte)0xf0, (byte)0x81, (byte)0x07}, // A: Synthesizer
		{(byte)0x33, (byte)0x01, (byte)0x83, (byte)0x11, (byte)0xea, (byte)0xef, (byte)0x10, (byte)0x04}, // B: Harpsichord
		{(byte)0x17, (byte)0xc1, (byte)0x24, (byte)0x07, (byte)0xf8, (byte)0xf8, (byte)0x22, (byte)0x12}, // C: Vibraphone
		{(byte)0x61, (byte)0x50, (byte)0x0c, (byte)0x05, (byte)0xd2, (byte)0xf5, (byte)0x40, (byte)0x42}, // D: Synthsizer Bass
		{(byte)0x01, (byte)0x01, (byte)0x55, (byte)0x03, (byte)0xe4, (byte)0x90, (byte)0x03, (byte)0x02}, // E: Acoustic Bass
		{(byte)0x41, (byte)0x41, (byte)0x89, (byte)0x03, (byte)0xf1, (byte)0xe4, (byte)0xc0, (byte)0x13}  // F: Electric Guitar
	};	  

	public byte fb;
	public OPLLSlotParam[] slots;
	public OPLLVoice[] OPLLVoiceMap;

	public OPLLVoice() {
		initOPLLVoiceMap();
	}

	public OPLLVoice(byte[] d) {
		this.fb = (byte)(d[3] & 7);
		this.slots = new OPLLSlotParam[] {
				new OPLLSlotParam(
						(byte)((d[0] >> 7) & 1),
						(byte)((d[0] >> 6) & 1),
						(byte)((d[0] >> 5) & 1),
						(byte)(d[0] & 0xf),
						(byte)((d[0] >> 4) & 1),
						(byte)((d[2] >> 6) & 3),
						(byte)(d[2] & 0x3f),
						(byte)((d[4] >> 4) & 0xf),
						(byte)(d[4] & 0xf),
						(byte)((d[6] >> 4) & 0xf),
						(byte)(d[6] & 0xf),
						(byte)((d[3] >> 3) & 1)),
				new OPLLSlotParam(
						(byte)((d[1] >> 7) & 1),
						(byte)((d[1] >> 6) & 1),
						(byte)((d[1] >> 5) & 1),
						(byte)(d[1] & 0xf),						
						(byte)((d[1] >> 4) & 1),
						(byte)((d[3] >> 6) & 3),
						(byte)(0),
						(byte)((d[5] >> 4) & 0xf),
						(byte)(d[5] & 0xf),
						(byte)((d[7] >> 4) & 0xf),
						(byte)(d[7] & 0xf),
						(byte)((d[3] >> 4) & 1))};
	}

	public void initOPLLVoiceMap() {
		OPLLVoiceMap = new OPLLVoice[_OPLL_ROM_PATCHES.length];
		for(int i = 0; i < _OPLL_ROM_PATCHES.length; i++) {
			OPLLVoiceMap[i] = new OPLLVoice(_OPLL_ROM_PATCHES[i]);		    
		}			  
	}


}