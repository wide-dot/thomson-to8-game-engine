package fr.bento8.arcade.rtype;

import fr.bento8.arcade.util.byteUtil;

public class Palette {

	// $C8000 $C8BFF Palette 1
    // $CC000 $CCBFF Palette 2
	//
	// palettes are arranged in 3 tables, one for each r, g, b component
	// each table is $200 long, repeated 2 times (so 0x400 long)
	// and component value is 5bit long into a little endian 16 bit
	// so on RAM : E0 FF will be darkest value (%00000) for the component
	//
	
	public byte[] r = new byte[0x100];
	public byte[] g = new byte[0x100];
	public byte[] b = new byte[0x100];
	public byte[] pal = new byte[0x300];
	
	public static int palette_loc = 0x3B000; // 108 lines (16 colors) of palette at this position
	
	// read from ROM palette
	public Palette (Rom rom, int nb, int lines) {
		for (int i=0 ; i < 16*lines; i++) {
			int p = palette_loc+nb*16*3+i*3;
			int j = i*3;
			
			r[i] = (byte) ((rom.maincpu[p+0] & 0x1F) << 3);
			g[i] = (byte) ((rom.maincpu[p+1] & 0x1F) << 3);
			b[i] = (byte) ((rom.maincpu[p+2] & 0x1F) << 3);
			
			pal[j+0] = r[i];
			pal[j+1] = g[i];
			pal[j+2] = b[i];
		}
	}
	
	// read from RAM palette
	// TODO make a data input file
	// TODO add a matching function to get line palette index
	public Palette (byte[] inpal) {
		for (int offset=0 ; offset < 0x100; offset++) {
			r[offset] = (byte) ((byteUtil.getInt16LE(inpal, offset*2+0x0000) & 0x1F) << 3);
			g[offset] = (byte) ((byteUtil.getInt16LE(inpal, offset*2+0x0400) & 0x1F) << 3);
			b[offset] = (byte) ((byteUtil.getInt16LE(inpal, offset*2+0x0800) & 0x1F) << 3);
			
			pal[offset*3+0] = r[offset];
			pal[offset*3+1] = g[offset];
			pal[offset*3+2] = b[offset];
		}
	}
	
	public static byte palette1[] = {};
	public static byte palette2[] = {};
}

