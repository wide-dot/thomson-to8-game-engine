package fr.bento8.to8.image;

import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.IndexColorModel;
import java.io.File;

import javax.imageio.ImageIO;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.util.FileUtil;

public class lineScroll{

	private static final Logger logger = LogManager.getLogger("log");	
	private static int _OUT_WIDTH = 320;
	
	public static void main(String[] args) throws Throwable {

		System.out.println("*** parallax line scroll generator ***");

		String file = System.getProperty("image");
		String maskFile = System.getProperty("mask");

		if (file == null || file.equals("") || System.getProperty("frames") == null) {
			System.out.println("Arguments:");
			System.out.println(" -Dimage=(String) : the source image to process, indexed png file (0: transparency, 1-16: color)");
			System.out.println(" -Dframes=(int) : number of computed images");
			System.out.println(" -Dmask=(String) : (optional) the non transparent pixels of this image will be used to mask (erase) pixels in final images, indexed png file (0: transparency, 1-16: color)");
			throw new Exception("invalid number of arguments.");
		}		

		int frames = Integer.parseInt(System.getProperty("frames"));		
		
		if (frames <= 0) {
			throw new Exception("invalid number of frames: "+frames+" (must be >0).");
		}

		try {
			BufferedImage image = ImageIO.read(new File(file));
			int width = image.getWidth();
			int height = image.getHeight();
			ColorModel colorModel = image.getColorModel();
			int pixelSize = colorModel.getPixelSize();

			BufferedImage maskImage = null;
			int maskWidth = 0;
			if (maskFile != null) {
				maskImage = ImageIO.read(new File(maskFile));
				maskWidth = maskImage.getWidth();
				int maskHeight = maskImage.getHeight();
				if (maskWidth != _OUT_WIDTH/2 || maskHeight != height) {
					throw new Exception("mask image is "+maskWidth+"x"+maskHeight+" should be 160x"+height+" (same height as input img).");
				}
			}
			BufferedImage imageout;

			if (height <= 200 && pixelSize == 8) {		
				
				int[] lw = new int[height]; // line width
				int[] ls = new int[height]; // line start
				
				// count each line width
				for (int y = 0; y < height; y++) {
					boolean found = false;
					for (int x = 0; x < width; x++) {
						if ((image.getRaster().getDataBuffer()).getElem(x+(y*width))>0) {
							lw[y]++;
							if (!found) {
								ls[y] = x;
								found = true;
							}
						}
					}
				}

				// generate images
				for (int imgnum = 0; imgnum < frames; imgnum++) {
					imageout = new BufferedImage(_OUT_WIDTH/2, height, BufferedImage.TYPE_BYTE_INDEXED, (IndexColorModel)colorModel);
					
					System.out.println("image: "+imgnum);
					for (int y = 0; y < height; y++) {

						if (lw[y] != 0) {
							int xStart = lw[y] - (_OUT_WIDTH/2 - lw[y]/2) % lw[y];
							int offset =  (imgnum * lw[y]) / frames;
									
							for (int x = 0; x < _OUT_WIDTH; x++) {
								int x2 = ls[y] + (offset + xStart + x) % lw[y];
								if (maskImage == null || (maskImage.getRaster().getDataBuffer()).getElem(x/2+(y*maskWidth))==0) {
									imageout.setRGB(x/2, y, image.getRGB(x2, y));
								}
							}
						}
					}

					File outputfile = new File(FileUtil.removeExtension(file)+"_"+String.format("%03d",imgnum)+".png");
					ImageIO.write(imageout, "png", outputfile);
				}

			} else {
				logger.info(file);
				logger.info("vertical resolution: " + height + "px (max 200)");
				logger.info("pixel size:  " + pixelSize + "Bytes (must be 8)");
				throw new Exception("unsupported file format.");
			}

		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(e);
		}		

	}
}