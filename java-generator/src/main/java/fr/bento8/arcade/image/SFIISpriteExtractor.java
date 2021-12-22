package fr.bento8.arcade.image;

import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

public class SFIISpriteExtractor {

	private static byte[] allroms;
	private static byte[] sf2gfx;
	private static String outDirPath;
	
	public static final Byte STATUS_STAND               = 0;
	public static final Byte STATUS_WALKING             = 1;
	public static final Byte STATUS_NORMAL              = 2;
	public static final Byte STATUS_CROUCH              = 3;
	public static final Byte STATUS_STAND_UP            = 4;
	public static final Byte STATUS_JUMP_START          = 5;
	public static final Byte STATUS_LANDING             = 6;
	public static final Byte STATUS_TURN_AROUND         = 7;
	public static final Byte STATUS_CROUCH_TURN         = 8;
	public static final Byte STATUS_FALLING             = 9; 
	public static final Byte STATUS_STAND_BLOCK         = 10;
	public static final Byte STATUS_STAND_BLOCK2        = 11;
	public static final Byte STATUS_CROUCH_BLOCK        = 12;
	public static final Byte STATUS_CROUCH_BLOCK2       = 13;
	public static final Byte STATUS_STUN1               = 14;
	public static final Byte STATUS_STUN2               = 15;
	public static final Byte STATUS_STAND_BLOCK_FREEZE  = 16;
	public static final Byte STATUS_CROUCH_BLOCK_FREEZE = 17;
	public static final Byte STATUS_CROUCH_STUN         = 18;
	public static final Byte STATUS_FOOTSWEPT           = 19;
	public static final Byte STATUS_KNOCKDOWN           = 20;
	public static final Byte STATUS_BACK_UP             = 21;
	public static final Byte STATUS_DIZZY               = 22;
	public static final Byte STATUS_HIT_AIR             = 23;
	public static final Byte STATUS_ELECTROCUTED        = 24;
	public static final Byte STATUS_TUMBLE_30           = 25;
	public static final Byte STATUS_TUMBLE_32           = 26;
	public static final Byte STATUS_TUMBLE_34           = 27;
	public static final Byte STATUS_TUMBLE_36           = 28;
	public static final Byte STATUS_PISSED_OFF          = 29;
	public static final Byte STATUS_GETTING_THROWN      = 30;
	public static final Byte STATUS_PUNCH               = 31;
	public static final Byte STATUS_KICK                = 32;
	public static final Byte STATUS_CROUCH_PUNCH        = 33;
	public static final Byte STATUS_CROUCH_KICK         = 34;
	public static final Byte STATUS_JUMP_PUNCH          = 35;
	public static final Byte STATUS_JUMP_KICK           = 36;	
	public static final Byte STATUS_BOUNCE_WALL         = 37;
	public static final Byte STATUS_HADOUKEN            = 38;
	public static final Byte STATUS_RYUKEN_THROW        = 39;	
	public static final Byte STATUS_size                = 40;
	public static final String[] statusLabel = {"STAND", "WALKING", "NORMAL", "CROUCH", "STAND_UP", "JUMP_START", "LANDING", "TURN_AROUND", "CROUCH_TURN", "FALLING", "STAND_BLOCK", "STAND_BLOCK2", "CROUCH_BLOCK", "CROUCH_BLOCK2", "STUN1", "STUN2", "STAND_BLOCK_FREEZE", "CROUCH_BLOCK_FREEZE", "CROUCH_STUN", "FOOTSWEPT", "KNOCKDOWN", "BACK_UP", "DIZZY", "HIT_AIR", "ELECTROCUTED", "TUMBLE_30", "TUMBLE_32", "TUMBLE_34", "TUMBLE_36", "PISSED_OFF", "GETTING_THROWN", "PUNCH", "KICK", "CROUCH_PUNCH", "CROUCH_KICK", "JUMP_PUNCH", "JUMP_KICK", "BOUNCE_WALL", "HADOUKEN", "RYUKEN_THROW"};
	public static final byte[] statusCodes = {0x0, 0x0, 0x2, 0x4, 0x6, 0x8, 0xa, 0xc, 0xe, 0x10, 0x12, 0x14, 0x16, 0x18, 0x1a, 0x1c, 0x1e, 0x20, 0x22, 0x24, 0x26, 0x28, 0x2a, 0x2c, 0x2e, 0x30, 0x32, 0x34, 0x36, 0x3c, 0x3e, 0x40, 0x42, 0x44, 0x46, 0x48, 0x4a, 0x4c, 0x4c, 0x54};
	
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
	public static final int SFIIWW_size = 12;
	
	public static final String[] playerName = {"Ryu", "E_Honda", "Blanka", "Guile", "Ken", "Chun-Li", "Zangeif", "Dhalsim", "M_Bison", "Sagat", "Balrog", "Vega"}; 
	public static final int[] plyAnimIdx = {0x37f1e,0x3d2fc,0x43b90,0x4abac,0x51730,0x56dbc,0x5de06,0x64fbe,0x6aba0,0,0,0x76f66};
	public static final int[] plyAnimIdx2 = {0,0x3ffbc,0x46df4,0,0,0,0,0,0,0,0,0x7905e};
	public static final int[] plyAnimStart = {0x380a8,0x3d40c,0x43ca4,0,0,0,0,0,0,0,0,0};
	public static final int[] plyAnimEnd = {0x3a7a0,0x3ffbc,0x46df4,0,0,0,0,0,0,0,0,0};	
	public static final int[] plyAnimStart2 = {0,0,0,0,0,0,0,0,0,0,0,0};	// TODO replace by plyAnimStart[][] 	
	public static final int[] plyAnimEnd2 = {0,0,0,0,0,0,0,0,0,0,0,0};
	
	public static short IMAGE_ATTR = (short) 0x8000;		/* images are in tile,attr pairs */
	
	public static byte[][] paletteRGBA = new byte[4][256];
	public static final int PALETTE = 0x8a8ac; //90000
	public static final int PALETTE_STAGE = 1;
	
	public static IndexColorModel colorModel;
	public static List<String> animationScript = new ArrayList<String>();
	
	public static boolean explore_mode = false;
	
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
		
		if (args.length == 4 && args[3].equals("-explore")) {
			explore_mode = true;
		}
		
		System.out.println("SFII Sprite extractor");
		setPalettes(PALETTE, PALETTE_STAGE);
		
		boolean explore_mode = true;
		if (!explore_mode) {
			for (int ply = 0; ply < SFIIWW_size; ply++) {
				for (int status = 0; status < STATUS_size; status++) {
					for (byte pwr = 0; pwr < 5; pwr++) {
						extract(ply, (byte)status, pwr);
					}
				}
			}
		} else {
			for (int ply = 0; ply < SFIIWW_size; ply++) {
				int status = 0;
				while (plyAnimStart[ply] != plyAnimEnd[ply]) {
					extract(ply, (byte)status++, (byte)0);
				}
			}
			
		}
		
		FileWriter animRefFile = new FileWriter(outDirPath+"/animations.properties");
		for (int i = 0; i < animationScript.size(); i++) {
			animRefFile.write(animationScript.get(i)+"\n");
		}
		animRefFile.close();	
	}

	private static void extract(int ply, Byte status, Byte power) throws IOException {
		System.out.print("\nPlayer: "+playerName[ply]+" Animation: "+status+" Power: "+power+" Frames: ");
//		int plyAnimIndex = avatar[ply];
//		int iStatus = plyAnimIndex+(byteUtil.getInt16(allroms,plyAnimIndex+statusCodes[status])/2);
//		int iAnim = (plyAnimIndex+status)+(byteUtil.getInt16(allroms,iStatus+power)/2);
//		int iAnimFrame = iAnim;
		int iAnimFrame = plyAnimStart[ply];
		
		if (iAnimFrame != 0) {

			String animRef;
			if (explore_mode) {
				animRef = "animation."+playerName[ply]+"_"+status+"_"+power+"=";
			} else {
				animRef = "animation."+playerName[ply]+"_"+statusLabel[status]+"_"+power+"=";
			}
			
			// Decode Animation Frame
			int i = 0;
		    AnimationFrame frame = null;
		    while (iAnimFrame != plyAnimEnd[ply]) {		    
			    frame = new AnimationFrame(allroms, iAnimFrame);
			    drawSprite(frame, i++);
			    iAnimFrame += frame.size;
			    
			    animRef += frame.frame_duration+":"+Integer.toHexString(frame.address)+";";
			    System.out.print(frame.address+"("+frame.frame_duration+") ");
			    
				if (frame.end_block) {
					break;
				}			    
			}
		    plyAnimStart[ply] = iAnimFrame;
		    animRef += "_resetAnim;"+Integer.toHexString(frame.loopAnim);
		    animationScript.add(animRef);
		} 
	}
	
	private static void drawSprite(AnimationFrame image, int frame) throws IOException {
	    if (image.address == 0) { return; }
	    if (image.spriteTiles.tileCount == 0) { return; }
	    
	    if ((((short) image.spriteTiles.tileCount) & IMAGE_ATTR) == 0) {
	    	sub_7f244(image, (short)(384/2), (short)200, frame); // draw unflipped	    	
	        return;
	    }
	    
	    if ((image.spriteTiles.attr & 0xff00) == 0) {
	    	image.spriteTiles.tileCount = 1;
	    }
		
		sub_7ee58(image, (short)(384/2), (short)200, frame); // draw unflipped	    
	}
	
	public static void sub_7f244(AnimationFrame image, short x, short y, int frame) throws IOException {
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
		File outputfile = new File(outDirPath+"/frames/"+Integer.toHexString(image.address)+".png");
		outputfile.mkdirs();
        ImageIO.write(pngImage, "png", outputfile);		
	}	
	
	/* 7ee58 Object with No Flip */
	public static void sub_7ee58(AnimationFrame image, short x, short y, int frame) throws IOException {
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
		File outputfile = new File(outDirPath+"/frames/"+Integer.toHexString(image.address)+".png");
		outputfile.mkdirs();
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
	}
}
