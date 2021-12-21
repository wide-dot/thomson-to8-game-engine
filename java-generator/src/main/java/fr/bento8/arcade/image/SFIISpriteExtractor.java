package fr.bento8.arcade.image;

import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import javax.imageio.ImageIO;

public class SFIISpriteExtractor {

	private static byte[] allroms;
	private static byte[] sf2gfx;
	private static String outDirPath;
	
	public static final Byte STATUS_STAND               = 0x0;
	public static final Byte STATUS_WALKING             = 0x0;
	public static final Byte STATUS_NORMAL              = 0x2;
	public static final Byte STATUS_CROUCH              = 0x4;
	public static final Byte STATUS_STAND_UP            = 0x6;
	public static final Byte STATUS_JUMP_START          = 0x8;
	public static final Byte STATUS_LANDING             = 0xa;
	public static final Byte STATUS_TURN_AROUND         = 0xc;
	public static final Byte STATUS_CROUCH_TURN         = 0xe;
	public static final Byte STATUS_FALLING             = 0x10; 
	public static final Byte STATUS_STAND_BLOCK         = 0x12;
	public static final Byte STATUS_STAND_BLOCK2        = 0x14;
	public static final Byte STATUS_CROUCH_BLOCK        = 0x16;
	public static final Byte STATUS_CROUCH_BLOCK2       = 0x18;
	public static final Byte STATUS_STUN1               = 0x1a;
	public static final Byte STATUS_STUN2               = 0x1c;
	public static final Byte STATUS_STAND_BLOCK_FREEZE  = 0x1e;
	public static final Byte STATUS_CROUCH_BLOCK_FREEZE = 0x20;
	public static final Byte STATUS_CROUCH_STUN         = 0x22;
	public static final Byte STATUS_FOOTSWEPT           = 0x24;
	public static final Byte STATUS_KNOCKDOWN           = 0x26;
	public static final Byte STATUS_BACK_UP             = 0x28;
	public static final Byte STATUS_DIZZY               = 0x2a;
	public static final Byte STATUS_HIT_AIR             = 0x2c;
	public static final Byte STATUS_ELECTROCUTED        = 0x2e;
	public static final Byte STATUS_TUMBLE_30           = 0x30;
	public static final Byte STATUS_TUMBLE_32           = 0x32;
	public static final Byte STATUS_TUMBLE_34           = 0x34;
	public static final Byte STATUS_TUMBLE_36           = 0x36;
	public static final Byte STATUS_PISSED_OFF          = 0x3c;
	public static final Byte STATUS_GETTING_THROWN      = 0x3e;
	public static final Byte STATUS_PUNCH               = 0x40;
	public static final Byte STATUS_KICK                = 0x42;
	public static final Byte STATUS_CROUCH_PUNCH        = 0x44;
	public static final Byte STATUS_CROUCH_KICK         = 0x46;
	public static final Byte STATUS_JUMP_PUNCH          = 0x48;
	public static final Byte STATUS_JUMP_KICK           = 0x4a;	
	public static final Byte STATUS_BOUNCE_WALL         = 0x4c;
	public static final Byte STATUS_HADOUKEN            = 0x4c;
	public static final Byte STATUS_RYUKEN_THROW        = 0x54;	
	
	public static final Byte POWER_0 = 0x0;
	public static final Byte POWER_1 = 0x1;
	public static final Byte POWER_2 = 0x2;
	public static final Byte POWER_3 = 0x3;
	public static final Byte POWER_4 = 0x4;
	
	public static final int SFIIWW_RYU = 0;
	public static final int SFIIWW_EHONDA = 1;
	public static final int SFIIWW_BLANKA = 2;
	public static final int SFIIWW_GUILE = 3;
	public static final int SFIIWW_KEN = 4;
	public static final int SFIIWW_CHUNLI = 5;
	public static final int SFIIWW_ZANGEIF = 6;
	public static final int SFIIWW_DHALSIM = 7;	
	public static final int SFIIWW_BISON = 8;	
	public static final int SFIIWW_SAGAT = 9;	
	public static final int SFIIWW_BALROG = 10;	
	public static final int SFIIWW_VEGA = 11;		
	
	public static final String[] playerName = {"Ryu", "E.Honda", "Blanka", "Guile", "Ken", "Chun-Li", "Zangeif", "Dhalsim", "Bison", "Sagat", "Balrog", "Vega"}; 
	public static final int[] plyAnimIdx = {0x37f1e,0x3d2fc,0x43b90,0x4abac,0x51730,0x56dbc,0x5de06,0x64fbe,0x6aba0,0,0,0x76f66};
	public static final int[] plyAnimIdx2 = {0,0x3ffbc,0x46df4,0,0,0,0,0,0,0,0,0x7905e};
	public static final int[] plyAnimStart = {0x380a8,0x3d40c,0,0,0,0,0,0,0,0,0,0};
	public static final int[] plyAnimEnd = {0x3a7a0,0,0,0,0,0,0,0,0,0,0,0};	
	public static final int[] plyAnimStart2 = {0,0,0,0,0,0,0,0,0,0,0,0};		
	
	public static short IMAGE_ATTR = (short) 0x8000;		/* images are in tile,attr pairs */
	
	public static byte[][] paletteRGBA = new byte[4][256];
	public static final int PALETTE = 0x8a8ac; //90000
	public static final int PALETTE_STAGE = 1;
	
	public static IndexColorModel colorModel;
	
	public static void main(String[] args) throws IOException {
		// need allroms.bin and sf2gfx.bin files
		//
		//./interleave int1 1 sf2u.30a sf2u.37a
		//./interleave int2 1 sf2u.31a sf2u.38a
		//./interleave int3 1 sf2u.28a sf2u.35a
		//./interleave int4 1 sf2_29a.bin sf2_36a.bin
		//cat int1 int2 int3 int4 > allroms.bin
		//# echo "4256ec60bf9eec21f4d6bb34c38990a9401af82e - expected shasum"
		//# shasum allroms.bin 

		//./interleave gint1 2 sf2-5m.4a sf2-7m.6a sf2-1m.3a sf2-3m.5a
		//./interleave gint2 2 sf2-6m.4c sf2-8m.6c sf2-2m.3c sf2-4m.5c
		//./interleave gint3 2 sf2-13m.4d sf2-15m.6d sf2-9m.3d sf2-11m.5d

		//cat gint1 gint2 gint3 > sf2gfx.bin
		//# echo "db52a6314b4c0cd4c48eb324720c83dd142c3bff - expected shasum"
		//# shasum sf2gfx.bin  # should be db52a6314b4c0cd4c48eb324720c83dd142c3bff 	
		
		File allromsFile = new File(args[0]);
		allroms = Files.readAllBytes(allromsFile.toPath());
		
		File sf2gfxFile = new File(args[1]);
		sf2gfx = Files.readAllBytes(sf2gfxFile.toPath());
		
		File outDir = new File(args[2]);
		if (!outDir.isDirectory()) {
			System.out.println("Unknown output directory: "+args[2]);
			return;
		}
		outDirPath = outDir.getPath();
		
		System.out.println("SFII Sprite extractor");
		setPalettes(PALETTE, PALETTE_STAGE);
		extract(SFIIWW_RYU, STATUS_KICK, POWER_0);
	}

	private static void extract(int ply, Byte status, Byte power) throws IOException {
		System.out.println("Player: "+playerName[ply]+" Animation: "+status+" Power: "+power);
//		int plyAnimIndex = avatar[ply];
//		int iStatus = plyAnimIndex+(byteUtil.getInt16(allroms,plyAnimIndex+status)/2);
//		int iAnim = (plyAnimIndex+status)+(byteUtil.getInt16(allroms,iStatus+power)/2);
//		int iAnimFrame = iAnim;
		int iAnimFrame = plyAnimStart[ply];
		
		if (iAnimFrame != 0) {
			// Decode Animation Frame
			String label = ply+"_"+status+"_"+power;
			int i = 0;
		    AnimationFrame frame = new AnimationFrame(allroms, iAnimFrame);	
		    drawSprite(frame, label, i++);
		    iAnimFrame += frame.next();
		    while (iAnimFrame != plyAnimEnd[ply]) {		    
			    frame = new AnimationFrame(allroms, iAnimFrame);
			    drawSprite(frame, label, i++);
			    iAnimFrame += frame.next();
			}
		}
	}
	
	private static void drawSprite(AnimationFrame image, String label, int frame) throws IOException {
	    if (image.address == 0) { return; }
	    if (image.spriteTiles.tileCount == 0) { return; }
	    
	    if ((((short) image.spriteTiles.tileCount) & IMAGE_ATTR) == 0) {
	    	sub_7f244(image, (short)(384/2), (short)200, label, frame); // draw unflipped	    	
	        return;
	    }
	    
	    if ((image.spriteTiles.attr & 0xff00) == 0) {
	    	image.spriteTiles.tileCount = 1;
	    }
		
		sub_7ee58(image, (short)(384/2), (short)200, label, frame); // draw unflipped	    
	}
	
	public static void sub_7f244(AnimationFrame image, short x, short y, String label, int frame) throws IOException {
		short sx, sy;
		int tile, attr;
		short offsets = image.spriteTiles.offsets;
		
		BufferedImage pngImage = new BufferedImage(384, 224, BufferedImage.TYPE_BYTE_INDEXED, colorModel);
		
		for (int i = 0; i < image.spriteTiles.tiles.length; i++) {
			if (image.spriteTiles.tiles[i] <= 0xbfff) {
				tile = image.spriteTiles.tiles[i] << 7;
				attr = image.spriteTiles.attr & 0x1f;
	
	            if(tile == 0) {
	            	offsets += 2;
				} else {
					sx = (short) (x + image.spriteTiles.getOffset(offsets));
					if(sx > 512 || sx < 0) {
						offsets += 2;
					} else {
						sy = (short) ((short)(y + image.spriteTiles.getOffset(offsets+1)) & 0x1ff);
						offsets += 2;
						//System.out.println("DrawImage: "+sx+" "+sy+" "+tile+" "+attr);
						drawImage(pngImage, sx, sy, tile, attr);
					}
				}
			}
		}
		File outputfile = new File(outDirPath+"/"+label+"_"+String.format("%04d", frame)+".png");
        ImageIO.write(pngImage, "png", outputfile);		
	}	
	
	/* 7ee58 Object with No Flip */
	public static void sub_7ee58(AnimationFrame image, short x, short y, String label, int frame) throws IOException {
		short sx, sy;
		int tile, attr;
		short offsets = image.spriteTiles.offsets;
		
		BufferedImage pngImage = new BufferedImage(384, 224, BufferedImage.TYPE_BYTE_INDEXED, colorModel);
		
		for (int i = 0; i < image.spriteTiles.tiles.length; i++) {
			if (image.spriteTiles.tiles[i] <= 0xbfff) {			
				tile = image.spriteTiles.tiles[i] << 7;
				attr = image.spriteTiles.attr & 0x1f;
	
	            if(tile == 0) {
	            	offsets += 2;
				} else {
					sx = (short) (x + image.spriteTiles.getOffset(offsets));
					offsets++;
					if(sx > 512 || sx < 0) {
						offsets++;
					} else {
						sy = (short) ((short)(y + image.spriteTiles.getOffset(offsets)) & 0x1ff);
						offsets++;
						System.out.println("DrawImage: "+sx+" "+sy+" "+tile+" "+attr);
						drawImage(pngImage, sx, sy, tile, attr);
					}
				}
			}
		}
        File outputfile = new File(outDirPath+"/"+label+"_"+String.format("%04d", frame)+".png");
        ImageIO.write(pngImage, "png", outputfile);		
	}

	private static void drawImage(BufferedImage image, short sx, short sy, int tile, int attr) {
		int colorOffset = (attr & 0x1ff);

		//System.out.println("Read: "+tile);
   		for (int y = 0; y < 16; y++) {
   			for (int x = 0; x < 8; x+=4) {
   				
   				int color1 = ((sf2gfx[tile+(y*8)+x] & 0b10000000) >> 7) | ((sf2gfx[tile+(y*8)+x+1] & 0b10000000) >> 6) | ((sf2gfx[tile+(y*8)+x+2] & 0b10000000) >> 5) | ((sf2gfx[tile+(y*8)+x+3] & 0b10000000) >> 4);
   				if (color1 == 15) {
   					color1 = 0;
   				} else {
   					color1 += (colorOffset*16);
   				}
   				
   				int color2 = ((sf2gfx[tile+(y*8)+x] & 0b01000000) >> 6) | ((sf2gfx[tile+(y*8)+x+1] & 0b01000000) >> 5) | ((sf2gfx[tile+(y*8)+x+2] & 0b01000000) >> 4) | ((sf2gfx[tile+(y*8)+x+3] & 0b01000000) >> 3);
   				if (color2 == 15) {
   					color2 = 0;
   				} else {
   					color2 += (colorOffset*16);
   				}   				
   				
   				int color3 = ((sf2gfx[tile+(y*8)+x] & 0b00100000) >> 5) | ((sf2gfx[tile+(y*8)+x+1] & 0b00100000) >> 4) | ((sf2gfx[tile+(y*8)+x+2] & 0b00100000) >> 3) | ((sf2gfx[tile+(y*8)+x+3] & 0b00100000) >> 2);
   				if (color3 == 15) {
   					color3 = 0;
   				} else {
   					color3 += (colorOffset*16);
   				}   	
   				
   				int color4 = ((sf2gfx[tile+(y*8)+x] & 0b00010000) >> 4) | ((sf2gfx[tile+(y*8)+x+1] & 0b00010000) >> 3) | ((sf2gfx[tile+(y*8)+x+2] & 0b00010000) >> 2) | ((sf2gfx[tile+(y*8)+x+3] & 0b00010000) >> 1);
   				if (color4 == 15) {
   					color4 = 0;
   				} else {
   					color4 += (colorOffset*16);
   				}   	   	
   				
   				int color5 = ((sf2gfx[tile+(y*8)+x] & 0b00001000)) >> 3 | ((sf2gfx[tile+(y*8)+x+1] & 0b00001000) >> 2) | ((sf2gfx[tile+(y*8)+x+2] & 0b00001000) >> 1) | ((sf2gfx[tile+(y*8)+x+3] & 0b00001000));
   				if (color5 == 15) {
   					color5 = 0;
   				} else {
   					color5 += (colorOffset*16);
   				}
   				
   				int color6 = ((sf2gfx[tile+(y*8)+x] & 0b00000100) >> 2) | ((sf2gfx[tile+(y*8)+x+1] & 0b00000100) >> 1) | ((sf2gfx[tile+(y*8)+x+2] & 0b00000100)) | ((sf2gfx[tile+(y*8)+x+3] & 0b00000100) << 1);
   				if (color6 == 15) {
   					color6 = 0;
   				} else {
   					color6 += (colorOffset*16);
   				}   				
   				
   				int color7 = ((sf2gfx[tile+(y*8)+x] & 0b00000010) >> 1) | ((sf2gfx[tile+(y*8)+x+1] & 0b00000010)) | ((sf2gfx[tile+(y*8)+x+2] & 0b00000010) << 1) | ((sf2gfx[tile+(y*8)+x+3] & 0b00000010) << 2);
   				if (color7 == 15) {
   					color7 = 0;
   				} else {
   					color7 += (colorOffset*16);
   				}   	
   				
   				int color8 = ((sf2gfx[tile+(y*8)+x] & 0b00000001)) | ((sf2gfx[tile+(y*8)+x+1] & 0b00000001) << 1) | ((sf2gfx[tile+(y*8)+x+2] & 0b00000001) << 2) | ((sf2gfx[tile+(y*8)+x+3] & 0b00000001) << 3);
   				if (color8 == 15) {
   					color8 = 0;
   				} else {
   					color8 += (colorOffset*16);
   				}
   				
   				(image.getRaster().getDataBuffer()).setElem(((y+sy)*image.getWidth())+(x*2)+sx, color1);
   				(image.getRaster().getDataBuffer()).setElem(((y+sy)*image.getWidth())+(x*2)+1+sx, color2);
   				(image.getRaster().getDataBuffer()).setElem(((y+sy)*image.getWidth())+(x*2)+2+sx, color3);
   				(image.getRaster().getDataBuffer()).setElem(((y+sy)*image.getWidth())+(x*2)+3+sx, color4);
   				(image.getRaster().getDataBuffer()).setElem(((y+sy)*image.getWidth())+(x*2)+4+sx, color5);
   				(image.getRaster().getDataBuffer()).setElem(((y+sy)*image.getWidth())+(x*2)+5+sx, color6);
   				(image.getRaster().getDataBuffer()).setElem(((y+sy)*image.getWidth())+(x*2)+6+sx, color7);
   				(image.getRaster().getDataBuffer()).setElem(((y+sy)*image.getWidth())+(x*2)+7+sx, color8);
    		}
    	}
	}	
	
	public static void setPalettes(int address, int palette) throws IOException {
		palette--;
	    for(int u = 0; u < 16; u++) {
	        for(int v = 0; v < 16; v++) {
	        	int i = (u * 16) + v;
	        	int j = address + (palette * 512) + i * 2;
				paletteRGBA[3][i] = (byte)0xff; // (byte)((((byte)allroms[j]   & 0xf0) >> 4)*16);	        	
				paletteRGBA[0][i] = (byte)((((byte)allroms[j]   & 0x0f)     )*16);
				paletteRGBA[1][i] = (byte)((((byte)allroms[j+1] & 0xf0) >> 4)*16);
				paletteRGBA[2][i] = (byte)((((byte)allroms[j+1] & 0x0f)     )*16);
	        }
	        paletteRGBA[3][0] = (byte)0x0;
	    }
	    
		colorModel = new IndexColorModel(8,256,paletteRGBA[0],paletteRGBA[1],paletteRGBA[2],paletteRGBA[3]);
		BufferedImage image = new BufferedImage(384, 224, BufferedImage.TYPE_BYTE_INDEXED, colorModel);		
        File outputfile = new File(outDirPath+"/"+"palette.png");
        ImageIO.write(image, "png", outputfile);		
	}
}
