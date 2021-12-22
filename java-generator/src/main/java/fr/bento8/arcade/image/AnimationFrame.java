package fr.bento8.arcade.image;

public class AnimationFrame {
	public int address = 0;
	public int frame_duration = 0;
	public int flags = 0;
	public int tilemap = 0;
	public SpriteTiles spriteTiles;
	
	public boolean end_block = false;
	public int loopAnim = 0;
	
	public int size = 0;
	public int SIZE_NORMAL = 24; 
	public int SIZE_ENDBLOCK = 28;
	public int SIZE_ABNORMAL = 16;
	
	public AnimationFrame (byte[] allroms, int i) {
		
		// skip 0 frame duration (0x3eb3c)
		while (byteUtil.getInt16(allroms, i) == 0) { 
			i += SIZE_ABNORMAL;
			size += SIZE_ABNORMAL;
		}		
		
		address = i;
		frame_duration = byteUtil.getInt16(allroms, i);
		flags = byteUtil.getInt16(allroms, i+2);
		tilemap = byteUtil.getInt32(allroms, i+4);
		
		System.out.println("\n\tFrame: 0x"+Integer.toHexString(i)+" Frame duration: "+frame_duration+" Image: 0x"+Integer.toHexString(tilemap)+" Flags: "+Integer.toHexString(flags));
		
		if ((flags & 0x8000) != 0) { // bit 15 means end of animation 
			end_block=true;
			size += SIZE_ENDBLOCK;				
			loopAnim = byteUtil.getInt32(allroms, i+24);
		} else {
			end_block=false;
			size += SIZE_NORMAL;
		}
		
		spriteTiles = new SpriteTiles(allroms, tilemap);			
	}
}
