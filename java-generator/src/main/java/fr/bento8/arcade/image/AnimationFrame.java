package fr.bento8.arcade.image;

public class AnimationFrame {
	public int address = 0;
	public int frame_duration = 0;
	public int flags = 0;
	public int tilemap = 0;
	public SpriteTiles spriteTiles;
	
	public boolean end_block = false;
	public int loopAnim = 0;
	
	public int SIZE_NORMAL = 24; 
	public int SIZE_END = 28;
	
	public AnimationFrame (byte[] allroms, int i) {
		address = i;
		frame_duration = byteUtil.getInt16(allroms, i);
		flags = byteUtil.getInt16(allroms, i+2);
		tilemap = byteUtil.getInt32(allroms, i+4);
		
//		System.out.println("\tFrame: 0x"+Integer.toHexString(i)+" Frame duration: "+frame_duration+" Image: 0x"+Integer.toHexString(tilemap)+" Flags: "+Integer.toHexString(flags));
		
		if ((flags & 0x8000) != 0) { // bit 15 means end of animation 
			end_block=true;
			loopAnim = byteUtil.getInt32(allroms, i+24);
		} else {
			end_block=false;
		}
		
//		if (!end_block) {
//			System.out.println("\tFrame: 0x"+Integer.toHexString(i)+" Frame duration: "+frame_duration+" Image: 0x"+Integer.toHexString(tilemap));
//		} else {
//			System.out.println("\tFrame: 0x"+Integer.toHexString(i)+" Frame duration: "+frame_duration+" Image: 0x"+Integer.toHexString(tilemap)+" loop: 0x"+Integer.toHexString(loopAnim));
//		}
		spriteTiles = new SpriteTiles(allroms, tilemap);
	}
	
	public int next () {
		if (!end_block) { 
			return SIZE_NORMAL;
		} else {
			return SIZE_END;
		}
	}
}
