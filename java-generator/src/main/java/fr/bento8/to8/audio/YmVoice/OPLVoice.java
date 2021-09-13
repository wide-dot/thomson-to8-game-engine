package fr.bento8.to8.audio.YmVoice;

public class OPLVoice {

	public byte fb, con, vv;
	public OPLSlotParam[] slots;	

	double[] _ml_tbl = new double[] {0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 12, 12, 15, 15};

	static class OPLSlotParam {

		public void setMl(byte ml) {
			this.ml = ml;
		}

		public void setTl(byte tl) {
			this.tl = tl;
		}

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

		public OPLSlotParam(OPLSlotParam init) {
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

		public OPLSlotParam(byte am, byte pm, byte eg, byte ml, byte kr, byte kl, byte tl, byte ar, byte dr, byte sl, byte rr, byte ws) {
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

	public OPLVoice() {}		  

	public OPLVoice(OPLVoice init) {
		this.fb = init.fb;
		this.con = init.con;
		this.slots = new OPLSlotParam[] {new OPLSlotParam(init.slots[0]), new OPLSlotParam(init.slots[1])};		
	}	 

	public OPLVoice(byte fb, byte con, OPLSlotParam[] slots) {
		this.fb = fb;
		this.con = con;
		this.slots = slots;		
	}			
	
	public OPLVoice(byte fb, byte con, byte vv, OPLSlotParam[] slots) {
		this.fb = fb;
		this.con = con;
		this.vv = vv;
		this.slots = slots;		
	}			

	public byte[] toOPLLROMVoice() {
		int diff = Integer.MAX_VALUE;
		byte program = 0;
		OPLLVoice opllv = new OPLLVoice();

		for (int i = 1; i < 16; i++) {
			OPLLVoice opll = opllv.OPLLVoiceMap[i];
			if (i == 13) continue;
			int d = 0;
			double ml_a = this.slots[1].ml / _ml_tbl[this.slots[0].ml];
			double ml_b = opll.slots[1].ml / _ml_tbl[opll.slots[0].ml];
			d += (Math.abs(ml_a - ml_b))*2;
			d += (Math.abs(this.fb - opll.fb))/2;
			d += (Math.abs(this.slots[0].ar - opll.slots[0].ar));
			d += (Math.abs(this.slots[1].ar - opll.slots[1].ar));
			d += (Math.abs(this.slots[0].dr - opll.slots[0].dr));
			d += (Math.abs(this.slots[1].dr - opll.slots[1].dr));
			d +=  Math.min(
					63,
					4 * Math.abs(this.slots[0].sl - opll.slots[0].sl) +
					Math.abs(this.slots[0].tl - ((opll.slots[0].tl + opll.slots[0].ws != 0) ? 8 : 0))
					) >> 3;
		if (this.slots[1].rr == 0) {
			// sustainable tone
			if (opll.slots[1].eg == 0) {
				continue;
			}
			d += Math.abs(this.slots[1].sl - opll.slots[1].sl);
		} else {
			// percusive tone
			if (opll.slots[1].eg == 1) {
				continue;
			}
			d += Math.abs(this.slots[1].rr - opll.slots[1].rr);
		}
		if (d < diff) {
			program = (byte)i;
			diff = d;
		}
		}
		OPLLVoice opll = opllv.OPLLVoiceMap[program];
		int ooff = (int) Math.floor((Math.log(_ml_tbl[this.slots[1].ml] / _ml_tbl[opll.slots[1].ml])/ Math.log(2)) / 2);

		int voff = 1;
		if (opll.slots[1].ws != 0) {
			voff -= 2;
			if (opll.slots[0].ws != 0) {
				voff -= 2;
			}
		}

	    return new byte[] {(byte)((program << 4) + (byte)Math.min(15, Math.max(0, vv+voff))), (byte)(ooff*12 & 0xff)};
	}

}