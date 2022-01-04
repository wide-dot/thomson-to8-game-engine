package fr.bento8.arcade.image;

import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.imageio.ImageIO;

public class SFIISpriteExtractor {

	public static int imgWidth = 320;
	public static int imgHeight = 200;
	public static double imgWRatio = 2.0;
	
	private static byte[] allroms;
	private static byte[] sf2gfx;
	private static String outDirPath;
	private static String outDirImgPath;
	
	public static final String[][] statusLabel = {{"STAND", "NORMAL", "CROUCH", "STAND_UP", "JUMP_START", "LANDING", "TURN_AROUND", "CROUCH_TURN", "FALLING", "STAND_BLOCK", "STAND_BLOCK2", "CROUCH_BLOCK", "CROUCH_BLOCK2", "STUN1", "STUN2", "STAND_BLOCK_FREEZE", "CROUCH_BLOCK_FREEZE", "CROUCH_STUN", "FOOTSWEPT", "KNOCKDOWN", "BACK_UP", "DIZZY", "HIT_AIR", "ELECTROCUTED", "TUMBLE_30", "TUMBLE_32", "TUMBLE_34", "TUMBLE_36", "PISSED_OFF", "GETTING_THROWN", "PUNCH", "KICK", "CROUCH_PUNCH", "CROUCH_KICK", "JUMP_PUNCH", "JUMP_KICK", "BOUNCE_WALL", "HADOUKEN", "RYUKEN_THROW"},{"","","","","","","","","","","","","","","","","","","",""}};
	
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
	
	public static final String[] playerName  = {"Ryu", "E_Honda", "Blanka", "Guile", "Ken", "Chun-Li", "Zangeif", "Dhalsim", "M_Bison", "Sagat", "Balrog", "Vega"};
	public static final int[][] plyAnimIdx   = {{0x37f1e,0x3d2fc,0x43b90,0x4abac,0x51730,0x56dbc,0x5de06,0x64fbe,0x6aba0,0x6fe22,0x72ee0,0x76f66},{0,0x3ffbc,0x46df4,0,0,0,0,0,0,0,0,0x7905e}};
	public static final int[][] plyAnimStart = {{0x380a8,0x3d40c,0x43ca4,0x4ad6a,0x518bc,0x56f80,0x5df86,0x6514c,0x6ad1c,0x6ff6c,0x73056,0x7708c},{0,0,0,0,0,0,0,0,0,0,0,0}};
	public static final int[][] plyAnimEnd   = {{0x3a7a0,0x3ffbc,0x46df4,0x4d97a,0x540dc,0x59da4,0x60652,0x6775c,0x6c774,0x712d4,0x74a3a,0x78b44},{0,0,0,0,0,0,0,0,0,0,0,0}};
	public static final HashMap<Integer, Integer> plyImgRef = new HashMap<Integer, Integer>();
	
	public static short IMAGE_ATTR = (short) 0x8000;		/* images are in tile,attr pairs */
	
	public static byte[][][] paletteRGBA = new byte[12][4][16];
	public static final int[][] plyPalette = {
			{0x0111, 0x0fd9, 0x0fb8, 0x0e97, 0x0c86, 0x0965, 0x0643, 0x0b00, 0x0fff, 0x0eec, 0x0dca, 0x0ba8, 0x0a87, 0x0765, 0x0f00, 0x0000}, // 0x8a8cc Common Ply
			{0x0222, 0x0fec, 0x0fd9, 0x0fb7, 0x0e96, 0x0b64, 0x0843, 0x0631, 0x0678, 0x0dff, 0x0ace, 0x08ad, 0x077c, 0x0658, 0x0d43, 0x0000},
			{0x0111, 0x0ffc, 0x0ee7, 0x0dc4, 0x0a90, 0x0870, 0x0650, 0x0530, 0x0fc0, 0x0f80, 0x0d60, 0x0a40, 0x0830, 0x0aac, 0x0778, 0x0000},
			{0x0640, 0x0fff, 0x0fd9, 0x0fb8, 0x0e97, 0x0b75, 0x0dfa, 0x08d9, 0x0697, 0x0474, 0x0f50, 0x007d, 0x0fe0, 0x0964, 0x0050, 0x0000},
			{0x0111, 0x0ffb, 0x0fd9, 0x0ea7, 0x0d86, 0x0a65, 0x0643, 0x0fe6, 0x0f60, 0x0f40, 0x0f00, 0x0c00, 0x0900, 0x0600, 0x0fc0, 0x0000},
			{0x0000, 0x0fea, 0x0fc9, 0x0e97, 0x0c86, 0x0a65, 0x0850, 0x0740, 0x0500, 0x0009, 0x005b, 0x058d, 0x07ae, 0x0acf, 0x0fff, 0x0000},
			{0x0111, 0x0640, 0x0a75, 0x0da7, 0x0feb, 0x0ffd, 0x0ec9, 0x0a00, 0x0d44, 0x0f66, 0x0b90, 0x0fd7, 0x0700, 0x0854, 0x0a98, 0x0000},
			{0x0111, 0x0631, 0x0853, 0x0a75, 0x0c97, 0x0eb9, 0x0fdb, 0x0fff, 0x0aaa, 0x0f30, 0x0630, 0x0960, 0x0ca0, 0x0fd0, 0x0ff8, 0x0000},
			{0x0234, 0x0600, 0x0900, 0x0c32, 0x0e65, 0x0f87, 0x0456, 0x007f, 0x0eef, 0x0aad, 0x0679, 0x0fd9, 0x0e96, 0x0a64, 0x0643, 0x0000}, // 0x8baac M Bison Stage
			{0x0f00, 0x0a00, 0x0fc9, 0x0da8, 0x0b96, 0x0974, 0x0753, 0x0530, 0x0fff, 0x0bbb, 0x0777, 0x075f, 0x053a, 0x0407, 0x0005, 0x0000}, // 0x8bcac Sagat Stage
			{0x0d55, 0x0631, 0x0953, 0x0b75, 0x0c96, 0x0eb7, 0x0fea, 0x0e66, 0x0f99, 0x0679, 0x069d, 0x09be, 0x0bde, 0x0def, 0x0fff, 0x0000}, // 0x8beac Balrog Stage
			{0x0222, 0x0ffe, 0x0fea, 0x0fb8, 0x0e96, 0x0c75, 0x0954, 0x0740, 0x0ff0, 0x0b9f, 0x097e, 0x075b, 0x0429, 0x0f80, 0x0c00, 0x0000}};// 0x8c0ac Vega Stage
	public static final IndexColorModel[] plyColorModel= new IndexColorModel[12];
	
	public static List<String> animationScript = new ArrayList<String>();
	public static List<String> sprites = new ArrayList<String>();
	public static Map<String, String> identicalImages = new HashMap<String, String>();
	
	public static boolean explore_mode = false;
	
	public static void main(String[] args) throws Exception {
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
		
		outDirImgPath = outDirPath+"/frames/";
		File dir = new File(outDirImgPath);
		dir.mkdirs();
		
		for (int ply = 0; ply < playerName.length; ply++) {
			dir = new File(outDirImgPath+playerName[ply]+"/");
			dir.mkdirs();
		}
		
		outDirImgPath = outDirPath+"/noIndexFrames/";
		dir = new File(outDirImgPath);
		dir.mkdirs();
		
		for (int ply = 0; ply < playerName.length; ply++) {
			dir = new File(outDirImgPath+playerName[ply]+"/");
			dir.mkdirs();
		}
		
		System.out.println("SFII Sprite extractor");
		setPalettes();
		
		System.out.print("Extract all images ...\r");
		explore_mode = true;
		
		for (int lvl = 0; lvl < plyAnimStart.length; lvl++) {
			for (int ply = 0; ply < plyAnimStart[lvl].length; ply++) {
				int status = 0;
				while (plyAnimStart[lvl][ply] != plyAnimEnd[lvl][ply]) {
					extract(ply, lvl, (byte)status++, (byte)0);
				}
			}
		}
		
		FileWriter animRefFile = new FileWriter(outDirPath+"/noIndexAnimations.properties");
		
		// write sprite index
		for (int i = 0; i < sprites.size(); i++) {
			animRefFile.write(sprites.get(i)+"\n");
		}	
		
		// write animation index
		for (int i = 0; i < animationScript.size(); i++) {
			// replace duplicate images
			String curLine = animationScript.get(i);
			for (var ee : identicalImages.entrySet()) {
				curLine = curLine.replaceAll(ee.getKey(), ee.getValue());
			}
			animRefFile.write(curLine+"\n");
		}
		
		animRefFile.close();	
		animationScript.clear();
		sprites.clear();
		identicalImages.clear();
		outDirImgPath = outDirPath+"/frames/";
		
		System.out.print("Extract all animations by index ...\r");
		explore_mode = false;
		
		// Process by animation index
		for (int lvl = 0; lvl < plyAnimIdx.length; lvl++) {
			for (int ply = 0; ply < SFIIWW_size; ply++) {
				
				// find animations and secondary animations
				int idxStart = plyAnimIdx[lvl][ply];
				int idxEnd = idxStart + byteUtil.getInt16(allroms,idxStart);
				int nbStatus = (idxEnd - idxStart) / 2;
				for (int status = 0; status < nbStatus; status++) {
					for (int pwr = 0; pwr < 10; pwr++) {
						// check valid frame
						int plyAnimIndex = plyAnimIdx[lvl][ply];
						int iStatus = plyAnimIndex+(byteUtil.getInt16(allroms,plyAnimIndex+(status*2)));
						int iAnim = iStatus+byteUtil.getInt16(allroms,iStatus+(pwr*2));
						
					    if (plyImgRef.containsKey(iAnim) && plyImgRef.get(iAnim) == ply) {
					    	extract(ply, lvl, (byte)status, (byte)pwr);
					    }
					}
				}
			}
		}
		
		animRefFile = new FileWriter(outDirPath+"/animations.properties");
		
		// write sprite index
		for (int i = 0; i < sprites.size(); i++) {
			animRefFile.write(sprites.get(i)+"\n");
		}	
		
		// write animation index
		for (int i = 0; i < animationScript.size(); i++) {
			// replace duplicate images
			String curLine = animationScript.get(i);
			for (var ee : identicalImages.entrySet()) {
				curLine = curLine.replaceAll(ee.getKey(), ee.getValue());
			}
			animRefFile.write(curLine+"\n");
		}
		
		animRefFile.close();	
		System.out.print("\rEnd of process.                                                  ");
	}

	private static void extract(int ply, int lvl, Byte status, Byte power) throws Exception {
		
		int plyAnimIndex = 0, iStatus = 0, iAnim = 0, iAnimFrame = 0;
		String animRef;
		
		if (explore_mode) {
			iAnimFrame = plyAnimStart[lvl][ply];
			animRef = "animation."+playerName[ply]+"_"+status+"=";
		} else {
			plyAnimIndex = plyAnimIdx[lvl][ply];
			iStatus = plyAnimIndex+(byteUtil.getInt16(allroms,plyAnimIndex+(status*2)));
			iAnim = iStatus+byteUtil.getInt16(allroms,iStatus+(power*2));
			iAnimFrame = iAnim;
			animRef = "animation."+playerName[ply]+"_"+status+"_"+power+"=";
		}
		//System.out.print(animRef+"...                    \r");
		
		if (iAnimFrame != 0) {
			
			// Decode Animation Frame
			int i = 0;
		    AnimationFrame frame = null;
		    while (iAnimFrame != plyAnimEnd[lvl][ply]) {		
		    	
			    //debug
			    //if (i==0) {
			    //	System.out.print("\n"+animRef+" {"+Integer.toHexString(iStatus+(power*2))+"} ");
			    //}
			    
			    frame = new AnimationFrame(allroms, iAnimFrame);
			    //System.out.print(Integer.toHexString(frame.address)+" ");
			    String existingImgName = drawSprite(ply, frame, i++);
			    
		    	String imgName = Integer.toHexString(frame.address);
			    if(existingImgName == null) {
			    	// no duplicate for this image, point to itself
			    	identicalImages.put(imgName, imgName);
			    	sprites.add("sprite."+imgName+"=./images/"+playerName[ply]+"/"+imgName+".png;NB0,XB0");
			    } else {
			    	// duplicate found, point to existing image
			    	identicalImages.put(imgName, existingImgName);
			    }
			    
			    iAnimFrame += frame.size;
			    animRef += frame.frame_duration+":"+Integer.toHexString(frame.address)+";";
//			    System.out.print(frame.address+"("+frame.frame_duration+") ");
			    
				if (frame.end_block) {
					break;
				}			    
			}
		    plyAnimStart[lvl][ply] = iAnimFrame;
		    int inAnimFramePos = animRef.lastIndexOf(Integer.toHexString(frame.loopAnim));
		    if (inAnimFramePos >= 0) {
			    int goBackNFrames = (int) animRef.substring(inAnimFramePos).chars().filter(ch -> ch == ';').count();
			    int totalNFrames = (int) animRef.chars().filter(ch -> ch == ';').count();
		    	if(totalNFrames == goBackNFrames) {
		    		animRef += "_resetAnim";
		    	} else {
		    		animRef += "_goBackNFrames;"+goBackNFrames;
		    	}
		    } else {
		    	// loop frame is outside current animation
	        	String gotoAnim = "";
		        for (int as = 0; as < animationScript.size(); as++) {
		            if (animationScript.get(as).lastIndexOf(Integer.toHexString(frame.loopAnim)) >= 0) {
		            	gotoAnim = animationScript.get(as).split("=")[0].split("\\.")[1];
		            }
		        }
		        if (gotoAnim.equals("")) {
		        	gotoAnim = "NOT_FOUND("+Integer.toHexString(frame.loopAnim)+")";
		        }
		    	animRef += "_goToAnimation;"+gotoAnim;
		    }

		    animationScript.add(animRef);
		} 
	}
	
	private static String drawSprite(int ply, AnimationFrame image, int frame) throws Exception {
	    if (image.address == 0) { return null; }
	    if (image.spriteTiles.tileCount == 0) { return null; }
	    BufferedImage pngImage;
	    
	    pngImage = sub_7f244(image, (short)(imgWidth/2), (short)imgHeight, frame, plyColorModel[ply]);
	    
	    // Build ref image index
	    if (explore_mode)
	    	plyImgRef.put(image.address, ply);
	    
		// find already existing image
		String srcImg = imageUtil.findIdentical(outDirImgPath+playerName[ply], pngImage);
		if(srcImg == null) {
			File outputfile = new File(outDirImgPath+playerName[ply]+"/"+Integer.toHexString(image.address)+".png");
			ImageIO.write(pngImage, "png", outputfile);		
		}	
		return srcImg;
	}
	
	public static BufferedImage sub_7f244(AnimationFrame image, short x, short y, int frame, IndexColorModel cm) {
		short sx, sy;
		int tile, attr;
		short offsets = image.spriteTiles.offsets;
		
		BufferedImage pngImage = new BufferedImage(imgWidth, imgHeight, BufferedImage.TYPE_BYTE_INDEXED, cm);
		
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
//						System.out.println("DrawImage: "+sx+" "+sy+" "+tile+" "+attr);
						drawImage(pngImage, sx, sy, tile, attr);
					}
				}
			}
		}
		
		return pngImage;
	}	

	// todo: have a look here 
	// https://searchcode.com/total-file/1585206/src/vidhrdw/cps1.cpp/
	
	private static void drawImage(BufferedImage image, short sx, short sy, int tile, int attr) {

//		System.out.println("Read: "+tile);
   		for (int y = 0; y < 16; y++) {
   			for (int x = 0; x < 8; x+=4) {
   				
   				int color1 = ((sf2gfx[tile+(y*8)+x] & 0b10000000) >> 7) | ((sf2gfx[tile+(y*8)+x+1] & 0b10000000) >> 6) | ((sf2gfx[tile+(y*8)+x+2] & 0b10000000) >> 5) | ((sf2gfx[tile+(y*8)+x+3] & 0b10000000) >> 4);
   				if (color1 == 15) {
   					color1 = 0;
   				} else {
   					color1 += 1;
   				}
   				
   				int color2 = ((sf2gfx[tile+(y*8)+x] & 0b01000000) >> 6) | ((sf2gfx[tile+(y*8)+x+1] & 0b01000000) >> 5) | ((sf2gfx[tile+(y*8)+x+2] & 0b01000000) >> 4) | ((sf2gfx[tile+(y*8)+x+3] & 0b01000000) >> 3);
   				if (color2 == 15) {
   					color2 = 0;
   				} else {
   					color2 += 1;
   				}   				
   				
   				int color3 = ((sf2gfx[tile+(y*8)+x] & 0b00100000) >> 5) | ((sf2gfx[tile+(y*8)+x+1] & 0b00100000) >> 4) | ((sf2gfx[tile+(y*8)+x+2] & 0b00100000) >> 3) | ((sf2gfx[tile+(y*8)+x+3] & 0b00100000) >> 2);
   				if (color3 == 15) {
   					color3 = 0;
   				} else {
   					color3 += 1;
   				}   	
   				
   				int color4 = ((sf2gfx[tile+(y*8)+x] & 0b00010000) >> 4) | ((sf2gfx[tile+(y*8)+x+1] & 0b00010000) >> 3) | ((sf2gfx[tile+(y*8)+x+2] & 0b00010000) >> 2) | ((sf2gfx[tile+(y*8)+x+3] & 0b00010000) >> 1);
   				if (color4 == 15) {
   					color4 = 0;
   				} else {
   					color4 += 1;
   				}   	   	
   				
   				int color5 = ((sf2gfx[tile+(y*8)+x] & 0b00001000)) >> 3 | ((sf2gfx[tile+(y*8)+x+1] & 0b00001000) >> 2) | ((sf2gfx[tile+(y*8)+x+2] & 0b00001000) >> 1) | ((sf2gfx[tile+(y*8)+x+3] & 0b00001000));
   				if (color5 == 15) {
   					color5 = 0;
   				} else {
   					color5 += 1;
   				}
   				
   				int color6 = ((sf2gfx[tile+(y*8)+x] & 0b00000100) >> 2) | ((sf2gfx[tile+(y*8)+x+1] & 0b00000100) >> 1) | ((sf2gfx[tile+(y*8)+x+2] & 0b00000100)) | ((sf2gfx[tile+(y*8)+x+3] & 0b00000100) << 1);
   				if (color6 == 15) {
   					color6 = 0;
   				} else {
   					color6 += 1;
   				}   				
   				
   				int color7 = ((sf2gfx[tile+(y*8)+x] & 0b00000010) >> 1) | ((sf2gfx[tile+(y*8)+x+1] & 0b00000010)) | ((sf2gfx[tile+(y*8)+x+2] & 0b00000010) << 1) | ((sf2gfx[tile+(y*8)+x+3] & 0b00000010) << 2);
   				if (color7 == 15) {
   					color7 = 0;
   				} else {
   					color7 += 1;
   				}   	
   				
   				int color8 = ((sf2gfx[tile+(y*8)+x] & 0b00000001)) | ((sf2gfx[tile+(y*8)+x+1] & 0b00000001) << 1) | ((sf2gfx[tile+(y*8)+x+2] & 0b00000001) << 2) | ((sf2gfx[tile+(y*8)+x+3] & 0b00000001) << 3);
   				if (color8 == 15) {
   					color8 = 0;
   				} else {
   					color8 += 1;
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
	
	public static void setPalettes() throws IOException {
	    for(int ply = 0; ply < 12; ply++) {
	    	paletteRGBA[ply][3][0] = (byte)0x0; // transparency at idx 0
	    	paletteRGBA[ply][2][0] = (byte)0x0; //
	    	paletteRGBA[ply][1][0] = (byte)0x0; //
	    	paletteRGBA[ply][0][0] = (byte)0x0; //
	    	
		    for(int i = 1; i < 16; i++) {
		    	paletteRGBA[ply][3][i] = (byte)0xff;	        	
		    	paletteRGBA[ply][0][i] = (byte)(((plyPalette[ply][i-1] & 0x0f00) >> 8)*16);
		    	paletteRGBA[ply][1][i] = (byte)(((plyPalette[ply][i-1] & 0x00f0) >> 4)*16);
		    	paletteRGBA[ply][2][i] = (byte)(((plyPalette[ply][i-1] & 0x000f)     )*16);
		    }
	      
	        plyColorModel[ply] = new IndexColorModel(8,16,paletteRGBA[ply][0],paletteRGBA[ply][1],paletteRGBA[ply][2],paletteRGBA[ply][3]);
	    }
	}
}
