package fr.bento8.arcade.rtype;

public class Tile {
	public byte[] data = new byte[8*8];
	
	public Tile (int id, Rom rom) {
		
		// Tile id is 13 bit long (0x1FFF), bit 12 tell the ROM tu use : gfx2 or gfx3
		byte[] gfx = rom.gfx2;
		
		if ((id & 0x1FFF) >> 12 == 1) {
			gfx = rom.gfx3;
			id = id & 0xFFF;
		}
		
		int loc = id * 8; // each tile is encoded as 8 bytes for each of the 4 bitplane
		int i = 0;        // position in dest data
		
		// parse each line of the tile
		for (int y=loc; y<loc+8; y++) {
			
			// parse each col of the tile
			for (int x=7; x>=0; x--) {
				data[i++] = (byte) (((gfx[0x00000+y] >> x) & 0x1) |
						           (((gfx[0x08000+y] >> x) & 0x1) << 1) |
						           (((gfx[0x10000+y] >> x) & 0x1) << 2) |
						           (((gfx[0x18000+y] >> x) & 0x1) << 3));
			}
		}
		
	}
}
