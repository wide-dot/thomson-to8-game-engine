package fr.bento8.arcade.image;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FilenameFilter;

import javax.imageio.ImageIO;

public class imageUtil {
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
	
	public static String findIdentical(String srcDir, BufferedImage trg) throws Exception {
		try {
			final File dir = new File(srcDir);
        	int trgSize = trg.getWidth()*trg.getHeight();
			
			// Scan all images in directory
	        if (dir.isDirectory()) {
	            for (final File f : dir.listFiles(IMAGE_FILTER)) {
	            	BufferedImage src = ImageIO.read(f);
	            	boolean found = true;
	            	
	            	int srcSize = src.getWidth()*src.getHeight();
	            	if (trgSize != srcSize)
	            		break;
	            	
	            	for (int i = 0; i < trgSize; i++) {
		            	if ((trg.getRaster().getDataBuffer()).getElem(i) != (src.getRaster().getDataBuffer()).getElem(i)) {
		            		found = false;
		            		break;
		            	}  
	            	}
	            	if (found)
	            		return f.getName().split("\\.")[0];
	            	
	            }
	        } else {
	        	System.out.println(srcDir + " is not a directory !");
	        }

		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(e);
		}
		return null;	
	}
}
