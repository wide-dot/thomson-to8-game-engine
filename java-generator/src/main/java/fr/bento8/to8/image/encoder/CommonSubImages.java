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

// Process a group of images and extract common sub images
// This is used as a way to lower the compilated sprite size
// This tool must be used before building, to prepare images
// Expect long processing time

public class CommonSubImages {

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
    
    public static void main(String[] args) throws Exception {
    	// Params
    	// 1: directory of images to process
    	// 2: minimum of pixels for a match
    	// 3: maximum of sub images for an image
    	new CommonSubImages(args[0], Integer.parseInt(args[1]), Integer.parseInt(args[2]));
    }
	
	public CommonSubImages(String srcDir, int minPx, int maxNbSubImg) throws Exception {
		try {
			File[] imgs;
			int[] imgsNbSub;
			List<String>[] imgsSubsNames;
			final File dir = new File(srcDir);
			String destDir = srcDir+"/out/";
			
			// Get all images in directory
	        if (dir.isDirectory()) {
	        	int i = 0;
	        	System.out.println("Read directory: "+srcDir);
	            for (final File f : dir.listFiles(IMAGE_FILTER)) {
	            	i++;
	            }
	            imgs = new File[i];
	            imgsNbSub = new int[i];
	            imgsSubsNames = new ArrayList[i];
	            i = 0;
	            for (final File f : dir.listFiles(IMAGE_FILTER)) {
	            	imgs[i++] = f;
	            	System.out.println(f.getName());
	            }	            
	        } else {
	        	System.out.println(srcDir + " is not a directory !");
	        	return;
	        }
	        
	        // process all images couples and find best match value in px
	        int nbSubImg = 0;
		    boolean processing = true;
	        while (processing) {

		        processing = false;	        	
			    int bestPxCount = 0;
			    int bi = 0, bj = 1, bxo = 0, byo = 0;
	
			    int progress = 0;
			    int progressTotal = 0;
		        for (int i=0; i<imgs.length; i++) {
		            for (int j=i+1; j<imgs.length; j++) {
		            	progressTotal++;
		            }
		        }		    
			    
		        for (int i=0; i<imgs.length; i++) {
		            for (int j=i+1; j<imgs.length; j++) {
		            	
		            	System.out.print("Pass: "+nbSubImg+" ("+progress+"/"+progressTotal+")\r");
		            	progress++;
				        BufferedImage imageA = ImageIO.read(imgs[i]);
				        BufferedImage imageB = ImageIO.read(imgs[j]);
			
				        // Search for all common images part between two images by moving imageB in all possible positions in imageA
				        int currentPxCount = 0;
				        int xo = 0, yo = 0, xb = 0, yb = 0;
					        
				        // change position of B
				        for (xo = imageB.getWidth()-1; xo >= -(imageA.getWidth()-1); xo--) {
				        	for (yo = imageB.getHeight()-1; yo >= -(imageA.getHeight()-1); yo--) {
				    	        currentPxCount = 0;
				    	        for (int x = 0; x < imageA.getWidth(); x++) {
				    	            for (int y = 0; y < imageA.getHeight(); y++) {
				    	            	xb = x+xo;
				    	            	yb = y+yo;
				    	            	if ((imageA.getRaster().getDataBuffer()).getElem(x+(y*imageA.getWidth())) != 0 && xb < imageB.getWidth() && xb >= 0 && yb < imageB.getHeight() && yb >= 0 && (imageA.getRaster().getDataBuffer()).getElem(x+(y*imageA.getWidth())) == (imageB.getRaster().getDataBuffer()).getElem(xb+(yb*imageB.getWidth())))
				    	            		currentPxCount++;
				    	            }
				    	        }
				    	        if (currentPxCount > minPx && currentPxCount > bestPxCount) {
				    	        	bestPxCount = currentPxCount;
				    	        	bi = i;
				    	        	bj = j;
				    	        	bxo = xo;
				    	        	byo = yo;
				    	        }	    	        
					        }
		            	}
		        	}
		        }

		        if (bestPxCount > 0) {
			        // extract the best sub image
			        System.out.println("Best match "+nbSubImg+": "+bestPxCount+"px x:"+bxo+" y:"+byo);
			        
			        BufferedImage imageA = ImageIO.read(imgs[bi]);
			        BufferedImage imageB = ImageIO.read(imgs[bj]);
			        
			        int xb = 0, yb = 0, subPxCount = 0;
			        
			        BufferedImage image = new BufferedImage(imageA.getWidth(), imageA.getHeight(), BufferedImage.TYPE_BYTE_INDEXED, (IndexColorModel) imageA.getColorModel());
			        for (int x = 0; x < imageA.getWidth(); x++) {
			            for (int y = 0; y < imageA.getHeight(); y++) {
			            	xb = x+bxo;
			            	yb = y+byo;
			            	if ((imageA.getRaster().getDataBuffer()).getElem(x+(y*imageA.getWidth())) != 0 && xb < imageB.getWidth() && xb >= 0 && yb < imageB.getHeight() && yb >= 0 && (imageA.getRaster().getDataBuffer()).getElem(x+(y*imageA.getWidth())) == (imageB.getRaster().getDataBuffer()).getElem(xb+(yb*imageB.getWidth()))) {
			            		((DataBufferByte) image.getRaster().getDataBuffer()).setElem(x+(y*imageA.getWidth()), (imageA.getRaster().getDataBuffer()).getElem(x+(y*imageA.getWidth())));
			            		image.setRGB(x, y, imageA.getColorModel().getRGB((imageA.getRaster().getDataBuffer()).getElem(x+(y*imageA.getWidth()))));
			            		subPxCount++;
			            	}
			            }
			        }		        
		
			        // Test all images against this commun sub image, must be a perfect match 
			        int curSubPxCount;
			        String imgIdLst = "";
		
			        for (int k = 0; k < imgs.length; k++) {
	
			        	imageA = ImageIO.read(imgs[k]);
				        outer :
				        for (int xo = image.getWidth()-1; xo >= -(imageA.getWidth()-1); xo--) {
				        	for (int yo = image.getHeight()-1; yo >= -(imageA.getHeight()-1); yo--) {
						        curSubPxCount = 0;			        		
				    	        for (int x = 0; x < imageA.getWidth(); x++) {
				    	            for (int y = 0; y < imageA.getHeight(); y++) {
				    	            	xb = x+xo;
				    	            	yb = y+yo;
				    	            	if (xb < image.getWidth()
				    	            		&& xb >= 0
				    	            		&& yb < image.getHeight()
				    	            		&& yb >= 0
				    	            		&& (image.getRaster().getDataBuffer()).getElem(xb+(yb*image.getWidth())) != 0
				    	            		&& (imageA.getRaster().getDataBuffer()).getElem(x+(y*imageA.getWidth())) == (image.getRaster().getDataBuffer()).getElem(xb+(yb*image.getWidth()))) {
				    	            		((DataBufferByte) imageA.getRaster().getDataBuffer()).setElem(x+(y*imageA.getWidth()), imageA.getColorModel().getRGB(0));
				    	            		imageA.setRGB(x, y, imageA.getColorModel().getRGB(0));
				    	            		curSubPxCount++;
				    	            	}
				    	            }
				    	        }
		    	        
				    	        // if perfect match, substracted image is saved as a new working reference
				    	        if (curSubPxCount == subPxCount && imgsNbSub[k] < maxNbSubImg) {
				    	        	File file = new File(destDir+imgs[k].getName());
				    	        	file.getParentFile().mkdirs();		        
				    	        	ImageIO.write(imageA, "png", file);
				    	        	imgs[k] = file;
				    	        	imgsNbSub[k]++; 
				    	        	imgIdLst += imgs[k].getName()+", ";
				    	        	if (imgsSubsNames[k] == null) {
				    	        		imgsSubsNames[k] = new ArrayList<String>();
				    	        	}
				    	        	imgsSubsNames[k].add("DIFF"+nbSubImg+".png (x:"+xo+" y:"+yo+")");
				    		        processing = true;
				    		        break outer;
				    	        } else {
				    	        	imageA = ImageIO.read(imgs[k]);
				    	        }
					        }
			        	}
			        }			        	
			        
			        if (processing) {
			        	System.out.println("Subimage DIFF"+nbSubImg+".png : "+imgIdLst.substring(0, imgIdLst.length()-2));
			        	File file = new File(destDir+"DIFF"+nbSubImg+".png");
			        	file.getParentFile().mkdirs();		        
			        	ImageIO.write(image, "png", file);
			        	nbSubImg++;		        
			        }
			        
		        }
	        }
	        
	        // print results
	        for (int k=0; k<imgsSubsNames.length; k++) {
	        	if (imgsSubsNames[k] != null)
	        		System.out.println("Image: "+imgs[k].getName()+" "+Arrays.toString(imgsSubsNames[k].toArray()));
	        }
	        System.out.println("End of process.");

		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(e);
		}	
	}
}