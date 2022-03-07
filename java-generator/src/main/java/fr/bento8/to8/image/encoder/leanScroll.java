package fr.bento8.to8.image.encoder;

import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.IndexColorModel;
import java.awt.image.WritableRaster;
import java.io.File;

import javax.imageio.ImageIO;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.util.FileUtil;

public class leanScroll{

	private static final Logger logger = LogManager.getLogger("log");
	private static String file;
	private static BufferedImage image;
	private static BufferedImage leanTiles;
	private static BufferedImage leanTilesCommon;
	private static String right, left, up, down; 
	public static int width, height, r_step, l_step, u_step, d_step, r_max, l_max, u_max, d_max;
	
	public static void main(String[] args) throws Throwable {

		System.out.println("*** lean scroll optimizer ***");
		checkParams();
		
		try {
			image = ImageIO.read(new File(file));
			width = image.getWidth();
			height = image.getHeight();
			ColorModel colorModel = image.getColorModel();
			int pixelSize = colorModel.getPixelSize();

			if (pixelSize == 8) {		

				leanTiles = new BufferedImage(width, height, BufferedImage.TYPE_BYTE_INDEXED, (IndexColorModel)colorModel);
				leanTilesCommon = deepCopy(image);
				
				for (int y = 0; y < height; y++) {
					for (int x = 0; x < width; x++) {
						test(x, y);
					}
				}
				
				File outputfile = new File(FileUtil.removeExtension(file)+"_lean.png");
				ImageIO.write(leanTiles, "png", outputfile);
				
				outputfile = new File(FileUtil.removeExtension(file)+"_lean-common.png");
				ImageIO.write(leanTilesCommon, "png", outputfile);
				System.out.println("end of process.");

			} else {
				logger.info(file);
				logger.info("pixel size:  " + pixelSize + "Bytes (must be 8)");
				throw new Exception("unsupported file format.");
			}

		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(e);
		}		

	}
	
	static void checkParams() throws Exception {
		file = System.getProperty("image");

		if (file == null || file.equals("")) {
			printUsage();
			throw new Exception("invalid number of arguments.");
		}		
		
		right = System.getProperty("right");
		r_step = 0;
		r_max = 0;
		if (right != null) {
			r_step = Integer.parseInt(right.split(",")[0]);
			r_max  = Integer.parseInt(right.split(",")[1]);
		}

		left = System.getProperty("left");
		l_step = 0;
		l_max = 0;
		if (left != null) {
			l_step = Integer.parseInt(left.split(",")[0]);
			l_max  = Integer.parseInt(left.split(",")[1]);
		}
		
		up = System.getProperty("up");
		u_step = 0;
		u_max = 0;
		if (up != null) {
			u_step = Integer.parseInt(up.split(",")[0]);
			u_max  = Integer.parseInt(up.split(",")[1]);
		}

		down = System.getProperty("down");
		d_step = 0;
		d_max = 0;
		if (down != null) {
			d_step = Integer.parseInt(down.split(",")[0]);
			d_max  = Integer.parseInt(down.split(",")[1]);
		}		

		if (file == null || file.equals("")) {
			printUsage();
			throw new Exception("invalid number of arguments.");
		}
		
		if (right != null && r_max % r_step != 0) {
			printMultipleError("right");
		}
		
		if (left != null && l_max % l_step != 0) {
			printMultipleError("left");
		}
		
		if (up != null && u_max % u_step != 0) {
			printMultipleError("down");
		}
		
		if (down != null && d_max % d_step != 0) {
			printMultipleError("down");
		}		
		return;
	}
	
	static void printUsage() {
		System.out.println("Arguments:");
		System.out.println(" -Dimage=<String>  : the source image to process, indexed png file (0: transparency, 1-16: color)\n");
		System.out.println("Optional:");
		System.out.println(" -Dright=<int,int>");
		System.out.println(" -Dleft=<int,int>");
		System.out.println(" -Dup=<int,int>");
		System.out.println(" -Ddown=<int,int>");
		System.out.println("with <int,int> as : scrool step, scroll max value");
		System.out.println("values are in pixel, max value should be a multiple of step value.");
	}

	static void printMultipleError(String param) throws Exception {
		printUsage();
		throw new Exception("invalid values for " + param + " scroll : max value should be a multiple of step value");		
	}
	
	static BufferedImage deepCopy(BufferedImage bi) {
		 ColorModel cm = bi.getColorModel();
		 boolean isAlphaPremultiplied = cm.isAlphaPremultiplied();
		 WritableRaster raster = bi.copyData(null);
		 return new BufferedImage(cm, raster, isAlphaPremultiplied, null);
		}	

	public static void test(int x, int y) {
		// Right scroll			
		if (right != null) {
			for (int ri = r_step; ri <= r_max; ri += r_step) {							
				if (!(x+ri < width && (image.getRaster().getDataBuffer()).getElem(x+ri+y*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					leanTiles.setRGB(x, y, image.getRGB(x, y));
					leanTilesCommon.setRGB(x, y, image.getColorModel().getRGB(0));
					return;
				}
			}
		}
		
		// Left scroll
		if (left != null) {
			for (int li = l_step; li <= l_max; li += l_step) {							
				if (!(x-li >= 0 && (image.getRaster().getDataBuffer()).getElem(x-li+y*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					leanTiles.setRGB(x, y, image.getRGB(x, y));
					leanTilesCommon.setRGB(x, y, image.getColorModel().getRGB(0));
					return;
				}
			}
		}
		
		// Down scroll			
		if (down != null) {
			for (int di = d_step; di <= d_max; di += d_step) {							
				if (!(y+di < height && (image.getRaster().getDataBuffer()).getElem(x+(y+di)*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					leanTiles.setRGB(x, y, image.getRGB(x, y));
					leanTilesCommon.setRGB(x, y, image.getColorModel().getRGB(0));
					return;
				}
			}
		}
		
		// Up scroll
		if (up != null) {
			for (int ui = u_step; ui <= u_max; ui += u_step) {							
				if (!(y-ui >= 0 && (image.getRaster().getDataBuffer()).getElem(x+(y-ui)*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					leanTiles.setRGB(x, y, image.getRGB(x, y));
					leanTilesCommon.setRGB(x, y, image.getColorModel().getRGB(0));
					return;
				}
			}
		}

	}	
}