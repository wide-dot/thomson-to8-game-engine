package fr.bento8.to8.image.encoder;

import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.imageio.ImageIO;

public class AnimSubImages {	
    
    public static void main(String[] args) throws Exception {
    	// Params
    	// 1: directory of images to process
    	// 2: minimum of pixels for a match
    	// 3: maximum of sub images for an image
    	new AnimSubImages(args[0], Integer.parseInt(args[1]), Integer.parseInt(args[2]));
    }
	
	public AnimSubImages(String srcDir, int minPx, int maxSubImg) throws Exception {
		try {
			File[][] imgs = new File[maxSubImg][];
			BufferedImage[][] bufs = new BufferedImage[maxSubImg][];
			byte[][][] pixels = new byte[maxSubImg][][];
			final File dir = new File(srcDir);
			String destDir = srcDir+"/out/";
			boolean odd = false;
						
			// pixel qty ratio
			int totalPxIn = 0;
			int totalPxOut = 0;
			
			// Get all images in directory
	        if (dir.isDirectory()) {
	        	int i = 0;
	        	System.out.println("Read directory: "+srcDir);
	            for (final File f : dir.listFiles(IMAGE_FILTER)) {
	            	i++;
	            }
	            
	            // if odd number of files, last file will be duplicated to have only pairs
	            if (i%2==1) {
	            	odd = true;
	            	i++;
	            }
	            
	            // Init first level of images
	            imgs[0] = new File[i];
	            bufs[0] = new BufferedImage[i];
	            pixels[0] = new byte[i][];
	            
	            // count non tranparent pixels for each image
		        System.out.println("Nb of non transparent pixels:");
	            i = 0;
	            for (File f : dir.listFiles(IMAGE_FILTER)) {
	            	BufferedImage image = ImageIO.read(f);
	            	imgs[0][i] = new File(destDir+String.format("%04d", 0)+"-"+String.format("%04d", i)+".png");;
	            	bufs[0][i] = image;
	            	pixels[0][i] = ((DataBufferByte)image.getRaster().getDataBuffer()).getData();
	            	int nbPx = 0;
	            	for (int p=0; p < image.getWidth()*image.getHeight(); p++) {
	            		if (pixels[0][i][p] != 0) {
	            			nbPx++;
	            			totalPxIn++;
	            		}
	            	}
	            	System.out.println(f.getName()+" "+nbPx+" px");
	            	i++;
	            }	    
	            
	            // if odd number of files, last file will be duplicated to have pairs
	            if (odd) {
	            	imgs[0][i] = imgs[0][i-1];
	            	bufs[0][i] = bufs[0][i-1];
	            	pixels[0][i] = pixels[0][i-1];
	            }
	            
	        } else {
	        	System.out.println(srcDir + " is not a directory !");
	        	return;
	        }
	        
	        // process all images couples and find best match value in px
		    int progress = 0;
		    int progressTotal = 0;
	        int lvl = 0;
	        int lvlMax = 0;
		    
	        int width = bufs[0][1].getWidth();
	        int height = bufs[0][1].getHeight();
	        IndexColorModel icm = (IndexColorModel) bufs[0][1].getColorModel();
	        
		    // init images to compute
		    // parse all levels until max nb of sub images
		    int nbCplLevel = imgs[0].length;
		    progressTotal = nbCplLevel;
		    while (lvlMax<maxSubImg) {

		    	lvlMax++;
		    	nbCplLevel = nbCplLevel/2;
		    	
		    	// exit if end of levels
		    	if (nbCplLevel == 1)
		    		break;
		    	
		    	// odd sub images
		    	if (nbCplLevel%2 == 1)
		    		nbCplLevel++;
		    	
		    	imgs[lvlMax] = new File[nbCplLevel];
		    	bufs[lvlMax] = new BufferedImage[nbCplLevel];
		    	pixels[lvlMax] = new byte[nbCplLevel][]; 
		    	
		    	for (int i=0; i<nbCplLevel; i++) {
		    		progressTotal++;
		    		
		    		imgs[lvlMax][i] = new File(destDir+String.format("%04d", lvlMax)+"-"+String.format("%04d", i)+".png");
	            	bufs[lvlMax][i] = new BufferedImage(width, height, BufferedImage.TYPE_BYTE_INDEXED, icm);
		    		pixels[lvlMax][i] = ((DataBufferByte)bufs[lvlMax][i].getRaster().getDataBuffer()).getData();
		    	}	  
		    }
		    
		    // last level
	    	imgs[lvlMax] = new File[1];
	    	bufs[lvlMax] = new BufferedImage[1];
	    	pixels[lvlMax] = new byte[1][]; 
    		imgs[lvlMax][0] = new File(destDir+String.format("%04d", lvlMax)+"-"+String.format("%04d", 0)+".png");
        	bufs[lvlMax][0] = new BufferedImage(width, height, BufferedImage.TYPE_BYTE_INDEXED, icm);
    		pixels[lvlMax][0] = ((DataBufferByte)bufs[lvlMax][0].getRaster().getDataBuffer()).getData();
		    
		    // each level processing write next level images until only one image to process or max sub images is reached
	    	for (lvl=0; lvl<lvlMax; lvl++) {
	    		for (int i=0; i<imgs[lvl].length; i=i+2) {
	    			System.out.print("Level: "+lvl+" ("+progress+"/"+progressTotal+")\r");
		            progress++;
		            	
			        int subPxCount = 0, pos = 0;
			        
			        for (int y = 0; y < height; y++) {
			            for (int x = 0; x < width; x=x+2) {
			            	pos = x+(y*width);
			            	
			            	if (pixels[lvl][i][pos] == pixels[lvl][i+1][pos] && pixels[lvl][i][pos+1] == pixels[lvl][i+1][pos+1]) {
			            		
			            		// if a match is found, set pixel to sub level image and clear parents pixel
			            		pixels[lvl+1][i/2][pos] = pixels[lvl][i][pos];
			            		pixels[lvl][i][pos] = 0;
			            		pixels[lvl][i+1][pos] = 0;
			            		subPxCount++;
			            		
			            		pixels[lvl+1][i/2][pos+1] = pixels[lvl][i][pos+1];
			            		pixels[lvl][i][pos+1] = 0;
			            		pixels[lvl][i+1][pos+1] = 0;
			            		subPxCount++;
			            	}
			            }
			        }
			        
			        // check odd image
			        if (pixels[lvl+1].length>1 && i+2==imgs[lvl].length && ((i+2)/2)%2 == 1) {
				        for (int y = 0; y < height; y++) {
				            for (int x = 0; x < width; x++) {
				            	pos = x+(y*width);
				            	pixels[lvl+1][(i+2)/2][pos] = pixels[lvl+1][((i+2)/2)-1][pos];
				            }
				        }
			        }
		        }
	        }
	    	
	    	for (lvl=0; lvl<imgs.length; lvl++) {
	    		if (imgs[lvl] != null) {
		    		for (int i=0; i<imgs[lvl].length; i++) {
		    			if (imgs[lvl][i] != null)
		    				imgs[lvl][i].getParentFile().mkdirs();
		    				ImageIO.write(bufs[lvl][i], "png", imgs[lvl][i]);
		    		}
	    		}
	    			
		    }
		    
	        System.out.println("End of process.");

		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(e);
		}	
	}
	
    static final String[] EXTENSIONS = new String[]{
            "png"
        };

        static final FilenameFilter IMAGE_FILTER = new FilenameFilter() {

            @Override
            public boolean accept(final File dir, final String name) {
                for (final String ext : EXTENSIONS) {
                    if (name.endsWith("." + ext)) {
                        return (true);
                    }
                }
                return (false);
            }
        };
}