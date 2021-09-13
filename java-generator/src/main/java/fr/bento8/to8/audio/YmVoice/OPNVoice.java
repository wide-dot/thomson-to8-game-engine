package fr.bento8.to8.audio.YmVoice;

import fr.bento8.to8.audio.YmVoice.OPLVoice.OPLSlotParam;

public class OPNVoice {

	public byte fb, con, ams, pms;
	public OPNSlotParam[] slots;

	public static class OPNSlotParam {
		byte dt;
		byte ml;
		byte tl;
		byte ks;
		byte ar;
		byte am;
		byte dr;
		byte sr;
		byte sl;
		byte rr;
		byte ssg;

		public OPNSlotParam(OPNSlotParam init) {
			this.dt = init.dt;
			this.ml = init.ml;
			this.tl = init.tl;
			this.ks = init.ks;
			this.ar = init.ar;
			this.am = init.am;
			this.dr = init.dr;
			this.sr = init.sr;
			this.sl = init.sl;
			this.rr = init.rr;
			this.ssg = init.ssg;
		};

		public OPNSlotParam(byte dt, byte ml, byte tl, byte ks, byte ar, byte am, byte dr, byte sr, byte sl, byte rr, byte ssg) {
			this.dt = dt;
			this.ml = ml;
			this.tl = tl;
			this.ks = ks;
			this.ar = ar;
			this.am = am;
			this.dr = dr;
			this.sr = sr;
			this.sl = sl;
			this.rr = rr;
			this.ssg = ssg;
		};	
		
		private OPLSlotParam toOPLSlotParam() {
			OPLSlotParam sp = new OPLSlotParam(
					am,
					(byte)0,
					(byte)0,
					ml,
					(byte)(ks >> 1),					
					(byte)0,
					(byte)Math.min(63, tl),
					_AR(ar),
					_DR(dr),
					sl,
					_DR(sr),
					(byte)0
					);
			return sp;
		}	

		private byte _AR(byte a) {
			switch (a) {
			case 31:
				return 15;
			case 0:
				return 0;
			default:
				return (byte) Math.max(1, Math.min(15, (a * 28) >> 6));
			}
		}
		private byte _DR(byte a) {
			switch (a) {
			case 31:
				return 15;
			case 0:
				return 0;
			default:
				return (byte) Math.max(1, Math.min(15, (a * 28) >> 6));
			}
		}
	}  	

	public OPNVoice(byte fb, byte con, byte ams, byte pms, OPNSlotParam s0, OPNSlotParam s1, OPNSlotParam s2, OPNSlotParam s3) {
		this.fb = fb;
		this.con = con;
		this.ams = ams;
		this.pms = pms;
		this.slots = new OPNSlotParam[] {s0, s1, s2, s3};		
	}

	public OPNVoice(byte fb, byte con, byte ams, byte pms, OPNSlotParam[] slots) {
		this.fb = fb;
		this.con = con;
		this.ams = ams;
		this.pms = pms;
		this.slots = new OPNSlotParam[] {new OPNSlotParam(slots[0]), new OPNSlotParam(slots[1]), new OPNSlotParam(slots[2]), new OPNSlotParam(slots[3])};		
	}	

	public OPLVoice toOPL() {
		OPLSlotParam[] ss = new OPLSlotParam[] {
				this.slots[0].toOPLSlotParam(),
				this.slots[1].toOPLSlotParam(),
				this.slots[2].toOPLSlotParam(),
				this.slots[3].toOPLSlotParam()
		};
		
		// set volume
	    int vol;
	    switch (this.con) {
	      case 4:
	        vol = (ss[2].tl + ss[3].tl) / 2;
	        break;
	      case 5:
	      case 6:
	        vol = (ss[1].tl + ss[2].tl + ss[3].tl) / 3;
	        break;
	      case 7:
	        vol = (ss[0].tl + ss[1].tl + ss[2].tl + ss[3].tl) / 4;
	        break;
	      default:
	        vol = ss[3].tl;
	        break;
	    }
	    int vv = (vol >> 3);		

	    // select slots
		OPLSlotParam s0, s1;
		switch (this.con) {
		case 0: case 3:
			s0 = ss[0];
			s1 = ss[3];
			s1.setMl(ss[1].ml);
			s1.setTl((byte)(Math.min(63, Math.max(0, ss[1].tl - 2) + ss[3].tl)));
			return new OPLVoice(this.fb, (byte)0, (byte)vv, new OPLSlotParam[] {s0, s1});
		case 1:
			s0 = ss[0];
			s1 = ss[3];
			s1.setMl(ss[2].ml);
			s1.setTl((byte)(Math.min(63, Math.max(0, ss[2].tl - 2) + ss[3].tl)));
			return new OPLVoice(this.fb, (byte)0, (byte)vv, new OPLSlotParam[] {s0, s1});	    	  
		case 2:
			s0 = ss[0];
			s1 = ss[3];
			return new OPLVoice(this.fb, (byte)0, (byte)vv, new OPLSlotParam[] {s0, s1});	    	  
		case 4: case 5: case 6:
			s0 = ss[0];
			s1 = ss[1];
			return new OPLVoice(this.fb, (byte)0, (byte)vv, new OPLSlotParam[] {s0, s1});	    
		default:
			s0 = ss[0];
			s1 = ss[1];
			return new OPLVoice(this.fb, (byte)1, (byte)vv, new OPLSlotParam[] {s0, s1});	  
		}
	}

}