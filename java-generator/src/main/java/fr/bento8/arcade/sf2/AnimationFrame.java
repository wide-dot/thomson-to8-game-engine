package fr.bento8.arcade.image;

public class AnimationFrame {
	
	public int SIZE_NORMAL = 24; 
	public int SIZE_ENDBLOCK = 28;
	public int SIZE_ABNORMAL = 16;
	
	public int address = 0;
	public int delay = 0;    /* aka chr ctr */
	public int flags = 0;
	public int image = 0;
	public int hb_Head = 0, hb_Body = 0, hb_Foot = 0, hb_Weak = 0, hb_Active = 0, hb_Push = 0; /* 8-0xd */
	public int shadow = 0;      /* 0xe */
	public int priority = 0;    /* 0xf  */
	public int ply_catch = 0;       /* 0x10 CATCH index for data_93440[] @ply_thrown */
	public int block = 0;       /* 0 for non block, 1 for standing block, 2 for crouching */
	public int crouch = 0;      /* exit status stand/crouch 0x12 AI uses this to determine if should block, mugenguild dude has this as weak box mode, determines behaviour when chars weak box is hit */
	public int flipBits = 0;    /* 0x13 */
	public int yOffset = 0;     /* 0x14 */
	public int damageMod = 0;   /* 0x15 */
	public int extraSprite = 0; /* extra sprite selector*/
	public int yoke = 0;        /* YOKE, 0x17 neutral jumps, 06 forward/backward jumps, 0xff walking */	
	public byte[] data = new byte[18];
	public int dataIndex = -1;
	
	public SpriteTiles spriteTiles;
	
	public boolean end_block = false;
	public int loopAnim = 0;
	
	public int size = 0;
	
	public AnimationFrame (byte[] allroms, int i) {
		
		// skip 0 frame duration (0x3eb3c)
		while (byteUtil.getInt16(allroms, i) == 0) {
			if ((byteUtil.getInt16(allroms, i+2) & 0x8000) != 0) {
				i += SIZE_ENDBLOCK;
				size += SIZE_ENDBLOCK;
			} else {
				i += SIZE_ABNORMAL;
				size += SIZE_ABNORMAL;
			}
		}		
		
		address     = i;
		delay       = byteUtil.getInt16(allroms, i);
		flags       = byteUtil.getInt16(allroms, i+2);
		image       = byteUtil.getInt32(allroms, i+4);
		hb_Head     = byteUtil.getInt8(allroms, i+8);
		hb_Body     = byteUtil.getInt8(allroms, i+9);
		hb_Foot     = byteUtil.getInt8(allroms, i+10);
		hb_Weak     = byteUtil.getInt8(allroms, i+11);
		hb_Active   = byteUtil.getInt8(allroms, i+12);
		hb_Push     = byteUtil.getInt8(allroms, i+13);
		shadow      = byteUtil.getInt8(allroms, i+14);
		priority    = byteUtil.getInt8(allroms, i+15);
		ply_catch   = byteUtil.getInt8(allroms, i+16);   
		block       = byteUtil.getInt8(allroms, i+17);
		crouch      = byteUtil.getInt8(allroms, i+18);
		flipBits    = byteUtil.getInt8(allroms, i+19);
		yOffset     = byteUtil.getInt8(allroms, i+20);
		damageMod   = byteUtil.getInt8(allroms, i+21);
		extraSprite = byteUtil.getInt8(allroms, i+22);
		yoke        = byteUtil.getInt8(allroms, i+23);
		
		if (delay>255)
			delay=1; // Chun_Li special_06 and 07 end animation
		
		int k=0;
		for (int j = i; j < i+SIZE_NORMAL; j++) {
			if (j-i > 1 && (j-i < 4 || j-i > 7)) // skip image ptr + delay
				data[k++] = allroms[j];
		}
		
		SFIISpriteExtractor.astotal++;
		
		// Search if this animation data already exists
		dataIndex = -1;
		for (int j = 0; j < SFIISpriteExtractor.animationScriptData.size(); j++) {
			boolean found = true;
			for (int l = 0; l < 18; l++) {
				if (SFIISpriteExtractor.animationScriptData.get(j)[l] != data[l]) {
					found = false;
					break;
				}
			}
			if (found) {
				dataIndex = j;
				break;
			}
		}
		
		if (dataIndex == -1) {
			// Store this new animation data
			// System.out.println("Data: "+print(data));			
			SFIISpriteExtractor.animationScriptData.add(data);
			dataIndex = SFIISpriteExtractor.animationScriptData.size()-1;
		}
		
		System.out.print("\rNumber of animation script data: " + SFIISpriteExtractor.animationScriptData.size() + " animation script total: " + SFIISpriteExtractor.astotal);		
		
//		if (flags > 256) {
//		System.out.println("Frame: 0x"+Integer.toHexString(i)+" Frame duration: "+frame_duration+" Image: 0x"+Integer.toHexString(tilemap)+" Flags: "+Integer.toHexString(flags));
//		}
		
		if ((flags & 0x8000) != 0) { // bit 15 means end of animation 
			end_block=true;
			size += SIZE_ENDBLOCK;				
			loopAnim = byteUtil.getInt32(allroms, i+24);
		} else {
			end_block=false;
			size += SIZE_NORMAL;
		}
		
		spriteTiles = new SpriteTiles(allroms, image);	
		
	}
	
	public static String print(byte[] bytes) {
	    StringBuilder sb = new StringBuilder();
	    sb.append("[ ");
	    for (byte b : bytes) {
	        sb.append(String.format("0x%02X ", b));
	    }
	    sb.append("]");
	    return sb.toString();
	}	
}
