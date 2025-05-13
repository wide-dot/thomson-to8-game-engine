package fr.bento8.to8.image;

import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.awt.image.IndexColorModel;
import java.awt.image.ColorModel;
import java.awt.geom.AffineTransform;
import java.io.File;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

import javax.imageio.ImageIO;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.build.Game;
import fr.bento8.to8.util.FileUtil;

public class SpriteSheet {
	// Convertion d'une planche de sprites en tableaux de donnÃ©es RAMA et RAMB pour chaque Sprite
	// Thomson TO8/TO9+
	// Mode 160x200 en seize couleurs sans contraintes
	
	private static final Logger logger = LogManager.getLogger("log");	
	
	private BufferedImage image;
	private String name;
	public String variant;
	ColorModel colorModel;
	private int width; // largeur totale de l'image
	private int height; // longueur totale de l'image
	private int nbColumns; // nombre de colonnes de tiles dans l'image
	private int nbRows; // nombre de lignes de tiles dans l'image
	
	private boolean plane0_empty;
	private boolean plane1_empty;	

	private Boolean hFlipped = false; // L'image est-elle inversée horizontalement ?
	private Boolean vFlipped = false; // L'image est-elle inversée verticalement ?
	private int subImageNb; // Nombre de sous-images
	private int subImageWidth; // Largeur des sous-images
	private int subImageHeight; // HAuteur des sous-images

	private byte[][][] pixels;
	private byte[][][] data;
	int[] x1_offset; // position haut gauche de l'image par rapport au centre
	int[] y1_offset; // position haut gauche de l'image par rapport au centre		
	int[] x_size; // largeur de l'image en pixel (sans les pixels transparents)		
	int[] y_size; // hauteur de l'image en pixel (sans les pixels transparents)		
	boolean[] alpha; // vrai si l'image contient au moins un pixel transparent	
	boolean[] evenAlpha; // vrai si l'image contient au moins un pixel transparent sur les lignes paires
	boolean[] oddAlpha; // vrai si l'image contient au moins un pixel transparent sur les lignes impaires	
	public int center; // position du centre de l'image (dans le référentiel pixels)
	public int center_offset; // est ce que le centre est pair (0) ou impair (1)
	
	public static final int CENTER = 0;
	public static final int TOP_LEFT = 1;
	public static final int TILE8x16 = 2;	
	public static final int TILE16x16 = 3;
	public static final HashMap<String, Integer> colorModes= new HashMap<String, Integer>(){
		private static final long serialVersionUID = 1L;
	{
			put("CENTER",CENTER);
			put("TOP_LEFT",TOP_LEFT);
			put("TILE8x16",TILE8x16);
			put("TILE16x16",TILE16x16);
			}};

	// TODO mutualiser les deux constructeurs
	public SpriteSheet(Sprite sprite, String associatedIdx, BufferedImage imgCumulative, int nbTiles, int nbColumns, int nbRows, String variant, boolean interlaced, int centerMode, String... fileRef) {
		try {
			this.variant = variant;
			subImageNb = nbTiles;
			image = ImageIO.read(new File(sprite.spriteFile));
			name = sprite.name;
			width = image.getWidth();
			height = image.getHeight();
			colorModel = image.getColorModel();
			int pixelSize = colorModel.getPixelSize();
			
			this.nbColumns = 1;
			this.nbRows = 1;
			
			plane0_empty = true;
			plane1_empty = true;
			
			// if more than one file is present, build an image by diff btw the two images.
			if ((sprite.associatedIdx != null && sprite.associatedIdx.startsWith("_autopal")) && fileRef.length > 0 && fileRef[0] != null) {

				// _autopal is used to swap palette color and help compression,
				// and all images should be declared in the playing order in properties file
				// currently only 4 colors are allowed, TODO allow more colors
				
				BufferedImage imgref;
				if (fileRef[0].equals("_cumulative") && imgCumulative != null) {
					imgref = imgCumulative;
				} else {
					imgref = ImageIO.read(new File(fileRef[0]));
					if (image.getWidth() != imgref.getWidth() || image.getHeight() != imgref.getHeight() || pixelSize != imgref.getColorModel().getPixelSize()) {
						throw new Exception("Image and Image Ref should be of same dimensions and pixelSize ! ("+sprite.name+")");
					}		
				}
				
				// Palette start and stop indexes
				String[] params = sprite.associatedIdx.split("\\(")[1].split("\\)")[0].split("-");
				int idx_min = Integer.parseInt(params[0]);
				int idx_max = Integer.parseInt(params[1]);
				if (idx_max-idx_min != 3) {
					throw new Exception ("_autopal wrong parameter, please provide two color index values, a start and end pos of 4 values length. Ex: 2:5 means use palette colors 2,3,4,5");
				}
				
	        	logger.debug("Process: "+sprite.spriteFile);
				
				// color index mapping table
				int[] cur_idx = new int[4]; // current palette combination
				int[] try_idx = new int[4]; // palette combination to try
				int[] bst_idx = new int[4]; // best palette combination

				// get last frame color palette
				byte cur_pal;
				if (associatedIdx == null || !fileRef[0].equals("_cumulative")) {
					cur_pal = (byte)0b00011011; // palette index are in original order : 0=0, 1=1, ...
				} else {
					// palette was remapped, get the mapping
					cur_pal = (byte)(((Character.digit(associatedIdx.charAt(1), 16) << 4) + Character.digit(associatedIdx.charAt(2), 16)) & 0xFF);
				}
				
				// each color index is encoded in 2 bits so this value means 4 color indexes : 0 (00), 1 (01) ,2 (10), 3 (11)
				cur_idx[0] = (cur_pal & 0b11000000) >> 6;
				cur_idx[1] = (cur_pal & 0b00110000) >> 4;
				cur_idx[2] = (cur_pal & 0b00001100) >> 2;
				cur_idx[3] = (cur_pal & 0b00000011);
				
				// init best count with actual palette
				// ***********************************
				// if the actual palette is found to be the best solution
				// it will be prefered to other equal solutions to save a palette switch at runtime
				
				int best_count = 0;
				boolean skip = false;
				outerloop:
		        for (int x = 0; x < image.getWidth(); x++) {
		            for (int y = 0; y < image.getHeight(); y++) {
		            	int val = (image.getRaster().getDataBuffer()).getElem(x+(y*image.getWidth()));
		            	int src = (imgref.getRaster().getDataBuffer()).getElem(x+(y*imgref.getWidth()));
		            	
		            	// check if previous pal matches new image palette usage, if not break
//		            	if (val >= idx_min && val <= idx_max && val-idx_min != cur_idx[0] && val-idx_min != cur_idx[1] && val-idx_min != cur_idx[2] && val-idx_min != cur_idx[3]) {
//		            		skip = true;
//		            		break outerloop;
//		            	}			            	
		            	
		            	if ((interlaced&&(y % 2 != 0)) ||
		            	    (src >= idx_min && src <= idx_max && val >= idx_min && val <= idx_max && cur_idx[val-idx_min] == src-idx_min) ||
		            	    ((src < idx_min || src > idx_max || val < idx_min || val > idx_max) && src == val)		            	    
		            	   ) {
		            		best_count++;
		            	}
		            }
		        }
				if (!skip) {
		        	bst_idx[0] = cur_idx[0]; 
		        	bst_idx[1] = cur_idx[1];
		        	bst_idx[2] = cur_idx[2];
		        	bst_idx[3] = cur_idx[3];
		        	logger.debug("\tPal cycle init, cleared pixels: "+best_count+" pal: "+bst_idx[0]+" "+bst_idx[1]+" "+bst_idx[2]+" "+bst_idx[3]);		        	
				} else {
					best_count = 0;
					logger.debug("\tPal cycle init, no initial solution found.");
				}
	        	
				// run all palette combinations
				// ****************************
				
	        	int[][] permut = new int[][]{{0,1,2,3},{1,0,2,3},{2,0,1,3},{0,2,1,3},{1,2,0,3},{2,1,0,3},{2,1,3,0},{1,2,3,0},{3,2,1,0},{2,3,1,0},{1,3,2,0},{3,1,2,0},{3,0,2,1},{0,3,2,1},{2,3,0,1},{3,2,0,1},{0,2,3,1},{2,0,3,1},{1,0,3,2},{0,1,3,2},{3,1,0,2},{1,3,0,2},{0,3,1,2},{3,0,1,2}};
				for (int i = 0; i < permut.length; i++) {
					int px_count = 0;
					skip = false;
					try_idx[0] = permut[i][0];
					try_idx[1] = permut[i][1];
					try_idx[2] = permut[i][2];
					try_idx[3] = permut[i][3];
					
					outerloop:
					// count cleared (identical) pixels
			        for (int x = 0; x < image.getWidth(); x++) {
			            for (int y = 0; y < image.getHeight(); y++) {
			            	int val = (image.getRaster().getDataBuffer()).getElem(x+(y*image.getWidth()));
			            	int src = (imgref.getRaster().getDataBuffer()).getElem(x+(y*imgref.getWidth()));	
			            	
			            	// check if previous pal matches new image palette usage, if not break
//			            	if (val >= idx_min && val <= idx_max && val-idx_min != try_idx[0] && val-idx_min != try_idx[1] && val-idx_min != try_idx[2] && val-idx_min != try_idx[3]) {
//			            		skip = true;
//			            		break outerloop;
//			            	}			            	
			            	
			            	if ((interlaced&&(y % 2 != 0)) ||
			            			(src >= idx_min && src <= idx_max && val >= idx_min && val <= idx_max && try_idx[val-idx_min] == src-idx_min) ||
				            	    ((src < idx_min || src > idx_max || val < idx_min || val > idx_max) && src == val)			            	    
				            	) {
			            		px_count++;
			            	}
			            }
			        }
			        
			        if (!skip && px_count > best_count) {
			        	best_count = px_count;
			        	bst_idx[0] = try_idx[0]; 
			        	bst_idx[1] = try_idx[1];
			        	bst_idx[2] = try_idx[2];
			        	bst_idx[3] = try_idx[3];
			        }
				}
				
				// clear similar pixels
		        for (int x = 0; x < image.getWidth(); x++) {
		            for (int y = 0; y < image.getHeight(); y++) {
		            	int val = (image.getRaster().getDataBuffer()).getElem(x+(y*image.getWidth()));
		            	int src = (imgref.getRaster().getDataBuffer()).getElem(x+(y*imgref.getWidth()));			            	
		            	if ((interlaced&&(y % 2 != 0)) ||
		            			(src >= idx_min && src <= idx_max && val >= idx_min && val <= idx_max && bst_idx[val-idx_min] == src-idx_min) ||
			            	    ((src < idx_min || src > idx_max || val < idx_min || val > idx_max) && src == val)			            	    
			            	) {
		            		((DataBufferByte) image.getRaster().getDataBuffer()).setElem(x+(y*image.getWidth()), colorModel.getRGB(0));
		            		image.setRGB(x, y, colorModel.getRGB(0));
		            	}
		            }
		        }					
						    
		        // rebuild palette index
		        byte[] coloridx = new byte[4];
		        coloridx[bst_idx[0]] = 0;
		        coloridx[bst_idx[1]] = 1;
		        coloridx[bst_idx[2]] = 2;
		        coloridx[bst_idx[3]] = 3;
		        
                // reassign color indexes of delta image with best palette
		    	byte[][] paletteRGBA = new byte[4][256];
		    	int paletteSize = 1; 

		    	for (int i = 1; i <= 16; i++) {
		    		if (i < idx_min || i > idx_max) {
		    			paletteRGBA[0][paletteSize] = (byte) (colorModel.getRed(i));
		    			paletteRGBA[1][paletteSize] = (byte) (colorModel.getGreen(i));
		    			paletteRGBA[2][paletteSize] = (byte) (colorModel.getBlue(i));
		    			paletteRGBA[3][paletteSize] = (byte) (colorModel.getAlpha(i));
		    		} else {
		    			paletteRGBA[0][paletteSize] = (byte) (colorModel.getRed(coloridx[i-idx_min]+idx_min));
	    				paletteRGBA[1][paletteSize] = (byte) (colorModel.getGreen(coloridx[i-idx_min]+idx_min));
	    				paletteRGBA[2][paletteSize] = (byte) (colorModel.getBlue(coloridx[i-idx_min]+idx_min));
	    				paletteRGBA[3][paletteSize] = (byte) (colorModel.getAlpha(i));
		    		}
		    		paletteSize++;
		    	}

		    	IndexColorModel newColorModel = new IndexColorModel(8,paletteSize+1,paletteRGBA[0],paletteRGBA[1],paletteRGBA[2],0);
		    	BufferedImage indexedImage = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_BYTE_INDEXED, newColorModel);

		    	for (int x = 0; x < indexedImage.getWidth(); x++) {
		    		for (int y = 0; y < indexedImage.getHeight(); y++) {
		    			int val = (image.getRaster().getDataBuffer()).getElem(x+(y*image.getWidth()));
		    			if (val < idx_min || val > idx_max) {
		    				(indexedImage.getRaster().getDataBuffer()).setElem(x+(y*image.getWidth()), val);
		    				//indexedImage.setRGB(x, y, colorModel.getRGB(val));
		    			} else {
		    				(indexedImage.getRaster().getDataBuffer()).setElem(x+(y*image.getWidth()), bst_idx[val-idx_min]+idx_min);
		    				//indexedImage.setRGB(x, y, colorModel.getRGB(bst_idx[val-idx_min]+idx_min));
		    			}
		    		}
		    	}
		        
		    	image = indexedImage;				
				
		        File outputfile = new File(Game.generatedCodeDirNameDebug+Paths.get(sprite.spriteFile).getFileName().toString()+"_"+FileUtil.removeExtension(Paths.get(fileRef[0]).getFileName().toString())+"_diff.png");
		        ImageIO.write(image, "png", outputfile);
		        
                // merge images to get the new reference
		    	paletteSize = 1; 

		    	for (int i = 1; i <= 16; i++) {
		    		if (i < idx_min || i > idx_max) {
		    			paletteRGBA[0][paletteSize] = (byte) (colorModel.getRed(i));
		    			paletteRGBA[1][paletteSize] = (byte) (colorModel.getGreen(i));
		    			paletteRGBA[2][paletteSize] = (byte) (colorModel.getBlue(i));
		    			paletteRGBA[3][paletteSize] = (byte) (colorModel.getAlpha(i));
		    		} else {
		    			paletteRGBA[0][paletteSize] = (byte) (colorModel.getRed(coloridx[i-idx_min]+idx_min));
	    				paletteRGBA[1][paletteSize] = (byte) (colorModel.getGreen(coloridx[i-idx_min]+idx_min));
	    				paletteRGBA[2][paletteSize] = (byte) (colorModel.getBlue(coloridx[i-idx_min]+idx_min));
	    				paletteRGBA[3][paletteSize] = (byte) (colorModel.getAlpha(i));
		    		}
		    		paletteSize++;
		    	}

		    	IndexColorModel mergedColors = new IndexColorModel(8,paletteSize+1,paletteRGBA[0],paletteRGBA[1],paletteRGBA[2],0);
		    	BufferedImage mergedImage = new BufferedImage(imgref.getWidth(), imgref.getHeight(), BufferedImage.TYPE_BYTE_INDEXED, mergedColors);

		    	for (int x = 0; x < indexedImage.getWidth(); x++) {
		    		for (int y = 0; y < indexedImage.getHeight(); y++) {
		    			int val = (imgref.getRaster().getDataBuffer()).getElem(x+(y*imgref.getWidth()));
	    				(mergedImage.getRaster().getDataBuffer()).setElem(x+(y*imgref.getWidth()), val); 
	    				//mergedImage.setRGB(x, y, colorModel.getRGB(val));
		    		}
		    	}		    	
		    	
		    	for (int x = 0; x < indexedImage.getWidth(); x++) {
		    		for (int y = 0; y < indexedImage.getHeight(); y++) {
		    			int val = (image.getRaster().getDataBuffer()).getElem(x+(y*image.getWidth()));
		    			if (val != 0) {
		    				(mergedImage.getRaster().getDataBuffer()).setElem(x+(y*image.getWidth()), val);
		    				//mergedImage.setRGB(x, y, colorModel.getRGB(val));
		    			}
		    		}
		    	}
		    	
		        File outputfile2 = new File(Game.generatedCodeDirNameDebug+Paths.get(sprite.spriteFile).getFileName().toString()+"_"+FileUtil.removeExtension(Paths.get(fileRef[0]).getFileName().toString())+".png");
		        ImageIO.write(mergedImage, "png", outputfile2);
		        		        
		        sprite.associatedIdx = new String(String.format("$%02X", coloridx[0] << 6 | coloridx[1] << 4 | coloridx[2] << 2 | coloridx[3]));
		        sprite.imgCumulative = mergedImage;
		        logger.debug("\tafter optim   , cleared pixels: "+best_count+" pal: "+coloridx[0]+" "+coloridx[1]+" "+coloridx[2]+" "+coloridx[3]);
	
			} else {
				if (fileRef.length > 0 && fileRef[0] != null) {
					BufferedImage imageRef = ImageIO.read(new File(fileRef[0]));
					if (image.getWidth() != imageRef.getWidth() || image.getHeight() != imageRef.getHeight() || pixelSize != imageRef.getColorModel().getPixelSize()) {
						throw new Exception("Image and Image Ref should be of same dimensions and pixelSize ! ("+sprite.name+")");
					}
					
					// Efface le pixel de l'image si celui-ci est identique à l'image de référence
			        for (int x = 0; x < image.getWidth(); x++) {
			            for (int y = 0; y < image.getHeight(); y++) {
			            	if ((interlaced&&(y % 2 != 0)) || (((image.getRaster().getDataBuffer()).getElem(x+(y*image.getWidth()))) ==
			            			                           ((imageRef.getRaster().getDataBuffer()).getElem(x+(y*imageRef.getWidth()))))
			            			                             ) {
			            		((DataBufferByte) image.getRaster().getDataBuffer()).setElem(x+(y*image.getWidth()), colorModel.getRGB(0));
			            		image.setRGB(x, y, colorModel.getRGB(0));
			            	}
			            }
			        }
			        
			        File outputfile = new File(Game.generatedCodeDirNameDebug+Paths.get(sprite.spriteFile).getFileName().toString()+"_"+FileUtil.removeExtension(Paths.get(fileRef[0]).getFileName().toString())+"_diff.png");
			        ImageIO.write(image, "png", outputfile);
				}
			}

			if (width % nbColumns == 0 && height % nbRows == 0) { // Est-ce que la division de la largeur par le nombre d'images donne un entier ?

				subImageWidth = width/nbColumns; // Largeur de la sous-image
				subImageHeight = height/nbRows; // Hauteur de la sous-image

				//if (subImageWidth <= 160 && height <= 200 && pixelSize == 8) { // Contrôle du format d'image
				if (pixelSize == 8) { // Contrôle du format d'image

					// On inverse l'image horizontalement et verticalement		
					if (variant.contains("XY")) {
						hFlipped = true;
						vFlipped = true;
						AffineTransform tx = AffineTransform.getScaleInstance(-1, -1);
						tx.translate(-image.getWidth(null), -image.getHeight(null));
						AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_NEAREST_NEIGHBOR);
						image = op.filter(image, null);
					}					
					
					// On inverse l'image horizontalement (x mirror)
					else if (variant.contains("X")) {
						hFlipped = true;
						AffineTransform tx = AffineTransform.getScaleInstance(-1, 1);
						tx.translate(-image.getWidth(null), 0);
						AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_NEAREST_NEIGHBOR);
						image = op.filter(image, null);
					}

					// On inverse l'image verticalement (y mirror)		
					else if (variant.contains("Y")) {
						vFlipped = true;
						AffineTransform tx = AffineTransform.getScaleInstance(1, -1);
						tx.translate(0, -image.getHeight(null));
						AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_NEAREST_NEIGHBOR);
						image = op.filter(image, null);
					}

					checkPixelRange();
					prepareImages(variant.contains("1"), centerMode);

				} else {
					logger.info("Le format de fichier de " + sprite.spriteFile + " n'est pas supporté.");
					logger.info("Resolution: " + subImageWidth + "x" + height + "px (doit être inférieur ou égal à 160x200)");
					logger.info("Taille pixel:  " + pixelSize + "Bytes (doit être 8)");
					throw new Exception ("Erreur de format d'image PNG.");
				}
			}
			else if (width % nbColumns != 0) {
				logger.info("La largeur d'image :" + width + " n'est pas divisible par le nombre de colonnes de tiles :" +  nbColumns);
				throw new Exception ("Erreur de format d'image PNG.");
			}
			else if (height % nbRows != 0) {
				logger.info("La hauteur d'image :" + height + " n'est pas divisible par le nombre de lignes de tiles :" +  nbRows);
				throw new Exception ("Erreur de format d'image PNG.");
			}

		} catch (Exception e) {
			System.out.println("file: " + sprite.spriteFile);
			e.printStackTrace();
			System.out.println(e);
		}
	}
	
	public SpriteSheet(String tag, String file, int nbTiles, int nbColumns, int nbRows, int centerMode) {
		try {
			this.variant = "ND0"; // default variant
			subImageNb = nbTiles;
			image = ImageIO.read(new File(file));
			name = tag;
			width = image.getWidth();
			height = image.getHeight();
			colorModel = image.getColorModel();
			int pixelSize = colorModel.getPixelSize();
			this.nbColumns = nbColumns;
			this.nbRows = nbRows;
			plane0_empty = true;
			plane1_empty = true;

			if (width % nbColumns == 0 && height % nbRows == 0) { // Est-ce que la division de la largeur par le nombre d'images donne un entier ?

				subImageWidth = width/nbColumns; // Largeur de la sous-image
				subImageHeight = height/nbRows; // Hauteur de la sous-image

				if (subImageWidth <= 160 && subImageHeight <= 200 && pixelSize == 8) { // Contrôle du format d'image
					checkPixelRange();
					prepareImages(false, centerMode);

				} else {
					logger.info("Le format de fichier de " + file + " n'est pas supporté.");
					logger.info("Resolution: " + subImageWidth + "x" + height + "px (doit être inférieur ou égal à  160x200)");
					logger.info("Taille pixel:  " + pixelSize + "Bytes (doit être 8)");
					throw new Exception ("Erreur de format d'image PNG.");
				}
			}
			else if (width % nbColumns != 0) {
				logger.info("La largeur d'image :" + width + " n'est pas divisible par le nombre de colonnes de tiles :" +  nbColumns);
				throw new Exception ("Erreur de format d'image PNG.");
			}
			else if (height % nbRows != 0) {
				logger.info("La hauteur d'image :" + height + " n'est pas divisible par le nombre de lignes de tiles :" +  nbRows);
				throw new Exception ("Erreur de format d'image PNG.");
			}

		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(e);
		}
	}

	public void checkPixelRange() throws Exception {
        // Vérifie que les index de couleur respectent la plage : 0 transparent, 1-16 couleurs
		for (int i = 0; i < image.getRaster().getDataBuffer().getSize(); i++) {
			if ((byte) (((DataBufferByte) image.getRaster().getDataBuffer()).getElem(i)) > 16) {
				logger.info("Le fichier png contient des indices de couleur > 16. Rappel: 0 transparent 1-16 couleurs");
				throw new Exception ("Erreur de format d'image PNG.");
			}
		}
	}	

	public void prepareImages(boolean onePixelOffset, int locationRef) {
		// sépare l'image en deux parties pour la RAM A et RAM B
		// ajoute les pixels transparents pour constituer une image linéaire de largeur 2x80px
		int paddedImage = 80*(height/nbRows);
		pixels = new byte[subImageNb][2][paddedImage];
		data = new byte[subImageNb][2][paddedImage];
		x1_offset = new int[subImageNb];
		y1_offset = new int[subImageNb];		
		x_size = new int[subImageNb];		
		y_size = new int[subImageNb];
		alpha = new boolean[subImageNb];
		evenAlpha = new boolean[subImageNb];
		oddAlpha = new boolean[subImageNb];
		boolean even = true;		
		plane0_empty = true;
		plane1_empty = true;

		switch (locationRef) {
			case CENTER   : center = (int)((Math.ceil(subImageHeight/2.0)-1)*40) +  subImageWidth/8; break;
			case TOP_LEFT : center = 0; break;
			case TILE8x16 : center = (int)((Math.ceil(subImageHeight*3.0/4.0)-1)*40) +  subImageWidth/8; break; 
			case TILE16x16 : center = (int)((Math.ceil(subImageHeight*3.0/4.0)-1)*40) +  subImageWidth/8; break;
		}
		
		// Correction positionnement sprite en fonction de la largeur d'image
		center_offset = subImageWidth % 8;
		switch (center_offset) {
			case 0 : center_offset = -1; break;
			case 1 : center_offset = 0; break;
			case 2 : center_offset = 0; break;
			case 3 : center_offset = 1; break;
			case 4 : center_offset = 1; break;
			case 5 : center_offset = 2; break;
			case 6 : center_offset = 2; break;
			case 7 : center_offset = 3; break;
		}		
		
		for (int position = 0; position < subImageNb; position++) { // Parcours de toutes les sous-images
			
			// Position de début et de fin de chaque sous-image
			int startIndex = subImageWidth * (position % nbColumns) + width * (subImageHeight * (position / nbColumns));		
			int endIndex = startIndex + width*(subImageHeight-1) + (subImageWidth-1);
			
			int indexDest = 0;
			int curLine = 0;
			int page = 0;		
			int x_Min = 160;
			int x_Max = -1;
			int y_Min = 200;
			int y_Max = -1;			
			boolean firstPixel = true;
			
			int index = startIndex;
			int endLineIndex = startIndex + subImageWidth;

			even = false; // 
			alpha[position] = false;
			evenAlpha[position] = false;
			oddAlpha[position] = false;
			
			while (index <= endIndex) { // Parcours de tous les pixels de l'image
				
				// Ecriture des pixels 2 à 2
				pixels[position][page][indexDest] = (byte) (((DataBufferByte) image.getRaster().getDataBuffer()).getElem(index));
				if (pixels[position][page][indexDest] == 0) {
					data[position][page][indexDest] = 0;
					alpha[position] = true;
					if (even) {
						evenAlpha[position] = true;
					} else {
						oddAlpha[position] = true;
					}
				} else {
					if (page == 0 && pixels[position][page][indexDest] > 0) {
						plane0_empty = false;
					} else if (page == 1 && pixels[position][page][indexDest] > 0) {
						plane1_empty = false;
					}
					
					data[position][page][indexDest] = (byte) (pixels[position][page][indexDest]-1);
					
					// Calcul des offset et size de l'image
					if (firstPixel) {
						firstPixel = false;
						switch (locationRef) {
							case CENTER   : y1_offset[position] = curLine-(subImageHeight-1)/2; break;
							case TOP_LEFT : y1_offset[position] = 0; break;
							case TILE8x16 : y1_offset[position] = curLine-(subImageHeight-1)*3/4; break;
							case TILE16x16 : y1_offset[position] = curLine-(subImageHeight-1)*3/4; break;
						}						
					}
					if (indexDest*2+page*2-(160*curLine) < x_Min) {
						x_Min = indexDest*2+page*2-(160*curLine);
						switch (locationRef) {
							case CENTER   : x1_offset[position] = x_Min - ((subImageWidth-1)/2); break;
							case TOP_LEFT : x1_offset[position] = 0; break;
							case TILE8x16 : x1_offset[position] = 0; break;
							case TILE16x16 : x1_offset[position] = 0; break;
						}						
					}
					if (indexDest*2+page*2-(160*curLine) > x_Max) {
						x_Max = indexDest*2+page*2-(160*curLine);
					}
					if (curLine < y_Min) {
						y_Min = curLine;
					}
					if (curLine > y_Max) {
						y_Max = curLine;
					}
					x_size[position] = x_Max-x_Min;
					y_size[position] = y_Max-y_Min;
				}
				index++;

				if (index == endLineIndex) {
					curLine++;
					index = subImageWidth * (position % nbColumns) + width * (subImageHeight * (position / nbColumns)) + width * curLine;
					endLineIndex = index + subImageWidth;
					indexDest = 80*curLine;
					page = 0;
					even = !even;
				} else {
					pixels[position][page][indexDest+1] = (byte) (((DataBufferByte) image.getRaster().getDataBuffer()).getElem(index));
					if (pixels[position][page][indexDest+1] == 0) {
						data[position][page][indexDest+1] = 0;
						alpha[position] = true;
						if (even) {
							evenAlpha[position] = true;
						} else {
							oddAlpha[position] = true;
						}					
					} else {
					
						if (page == 0 && pixels[position][page][indexDest+1] > 0) {
							plane0_empty = false;
						} else if (page == 1 && pixels[position][page][indexDest+1] > 0) {
							plane1_empty = false;
						}						
						data[position][page][indexDest+1] = (byte) (pixels[position][page][indexDest+1]-1);
						
						// Calcul des offset et size de l'image
						if (firstPixel) {
							firstPixel = false;
							switch (locationRef) {
								case CENTER   : y1_offset[position] = curLine-(subImageHeight-1)/2; break;
								case TOP_LEFT : y1_offset[position] = 0; break;
								case TILE8x16 : y1_offset[position] = curLine-(subImageHeight-1)*3/4; break;
								case TILE16x16 : y1_offset[position] = curLine-(subImageHeight-1)*3/4; break;
							}							
						}
						if (indexDest*2+page*2+1-(160*curLine) < x_Min) {
							x_Min = indexDest*2+page*2+1-(160*curLine);
							switch (locationRef) {
								case CENTER   : x1_offset[position] = x_Min-((subImageWidth-1)/2); break;
								case TOP_LEFT : x1_offset[position] = 0; break;
								case TILE8x16 : x1_offset[position] = 0; break;
								case TILE16x16 : x1_offset[position] = 0; break;
							}					
						}
						if (indexDest*2+page*2+1-(160*curLine) > x_Max) {
							x_Max = indexDest*2+page*2+1-(160*curLine);
						}
						if (curLine < y_Min) {
							y_Min = curLine;						
						}
						if (curLine > y_Max) {
							y_Max = curLine;
						}		
						x_size[position] = x_Max-x_Min;
						y_size[position] = y_Max-y_Min;	
					}
					index++;

					// Alternance des banques RAM A et RAM B
					if (page == 0) {
						page = 1;
					} else {
						page = 0;
						indexDest = indexDest+2;
					}

					if (index == endLineIndex) {
						curLine++;
						index = subImageWidth * (position % nbColumns) + width * (subImageHeight * (position / nbColumns)) + width * curLine;
						endLineIndex = index + subImageWidth;
						indexDest = 80*curLine;
						page = 0;
						even = !even;
					}
				}
			}
			
			if (onePixelOffset) {
				byte pixelSave = 0;
				byte dataSave = 0;
				// Décalage de l'image de 1px à droite pour chaque ligne
				for (int y = 0; y < height; y++) {
					for (int x = 79; x >= 1; x -= 2) {
						if (x == 79) {
							// Le pixel en fin de ligne revient au début de cette ligne
							pixelSave = pixels[position][1][x + (80 * y)];
							dataSave = data[position][1][x + (80 * y)];
						} else {
							pixels[position][0][(x + 1) + (80 * y)] = pixels[position][1][x + (80 * y)];
							data[position][0][(x + 1) + (80 * y)] = data[position][1][x + (80 * y)];
						}

						pixels[position][1][x + (80 * y)] = pixels[position][1][(x - 1) + (80 * y)];
						data[position][1][x + (80 * y)] = data[position][1][(x - 1) + (80 * y)];

						pixels[position][1][(x - 1) + (80 * y)] = pixels[position][0][x + (80 * y)];
						data[position][1][(x - 1) + (80 * y)] = data[position][0][x + (80 * y)];

						pixels[position][0][x + (80 * y)] = pixels[position][0][(x - 1) + (80 * y)];
						data[position][0][x + (80 * y)] = data[position][0][(x - 1) + (80 * y)];

						if (x == 1) {
							// Le pixel en fin de ligne revient au début de cette ligne
							pixels[position][0][0 + (80 * y)] = pixelSave;
							data[position][0][0 + (80 * y)] = dataSave;
						}
					}
				}
			}
		}
	}

	private int computePosition(int position) {
		
		// si l'image est inversée horizontalement, on inverse également l'index des sous-images
		if (hFlipped) {
			position = nbColumns * (position / nbColumns) + (nbColumns-1) - (position % nbColumns);
		}
		
		// si l'image est inversée verticalement, on inverse également l'index des sous-images
		if (vFlipped) {
			position = (nbRows - (position / nbColumns) - 1) + (position % nbColumns);
		}

		return position;
	}
	
	public byte[] getSubImagePixels(int position, int ramPage) {
		return pixels[computePosition(position)][ramPage];
	}

	public byte[] getSubImageData(int position, int ramPage) {
		return data[computePosition(position)][ramPage];
	}

	public int getSize() {
		return subImageNb;
	}

	public String getName() {
		return name;
	}

	public int getSubImageX1Offset(int position) {
		return x1_offset[computePosition(position)];
	}	
	
	public int getSubImageY1Offset(int position) {
		return y1_offset[computePosition(position)];
	}

	public int getSubImageXSize(int position) {
		return x_size[computePosition(position)];
	}

	public int getSubImageYSize(int position) {
		return y_size[computePosition(position)];
	}
	
	public boolean getAlpha(int position) {
		return alpha[computePosition(position)];
	}	
	
	public boolean getOddAlpha(int position) {
		return oddAlpha[computePosition(position)];
	}	
	
	public boolean getEvenAlpha(int position) {
		return evenAlpha[computePosition(position)];
	}		
	
	public int getCenter() {
		return center;
	}
	
	public boolean isPlane0Empty() {
		return plane0_empty;
	}
	
	public boolean isPlane1Empty() {
		return plane1_empty;
	}	
}