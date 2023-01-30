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

public class LeanScroll{

	private static final Logger logger = LogManager.getLogger("log");
	private static String file;
	private static BufferedImage image;
	private static BufferedImage leanTiles;
	private static BufferedImage leanTilesCommon;
	private static String right, left, up, down, uright, uleft, dright, dleft, free, interlace; 
	public static int width, height;
	public static int r_step, l_step, u_step, d_step, ur_step, ul_step, dr_step, dl_step;
	public static int r_max, l_max, u_max, d_max, ur_max, ul_max, dr_max, dl_max;
	
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
				
				// apply interlace
				if (interlace != null) {
					for (int y = 1-Integer.parseInt(interlace); y < height; y+=2) {
						for (int x = 0; x < width; x++) {					
							image.setRGB(x, y, image.getColorModel().getRGB(0));
						}
					}
				}

				leanTiles = new BufferedImage(width, height, BufferedImage.TYPE_BYTE_INDEXED, (IndexColorModel)colorModel);
				leanTilesCommon = deepCopy(image);
				
				// lean
				for (int y = 0; y < height; y++) {
					for (int x = 0; x < width; x++) {
						test(x, y);
					}
				}
				
				// group pixels by pair in x axis
				for (int y = 0; y < height; y++) {
					for (int x = 0; x < width; x+=2) {
						group2x(x, y);
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
		
		free = System.getProperty("free");
		if (free != null && (right == null || left == null || up == null || down == null)) {
			printUsage();
			throw new Exception("free scroll needs 4 directions declared (right, left, up, down).");
		}
			

		uright = System.getProperty("upright");
		ur_step = 0;
		ur_max = 0;
		if (uright != null) {
			ur_step = Integer.parseInt(uright.split(",")[0]);
			ur_max  = Integer.parseInt(uright.split(",")[1]);
		}

		uleft = System.getProperty("upleft");
		ul_step = 0;
		ul_max = 0;
		if (uleft != null) {
			ul_step = Integer.parseInt(uleft.split(",")[0]);
			ul_max  = Integer.parseInt(uleft.split(",")[1]);
		}
		
		dright = System.getProperty("downright");
		dr_step = 0;
		dr_max = 0;
		if (dright != null) {
			dr_step = Integer.parseInt(dright.split(",")[0]);
			dr_max  = Integer.parseInt(dright.split(",")[1]);
		}

		dleft = System.getProperty("downleft");
		dl_step = 0;
		dl_max = 0;
		if (dleft != null) {
			dl_step = Integer.parseInt(dleft.split(",")[0]);
			dl_max  = Integer.parseInt(dleft.split(",")[1]);
		}	
		
		interlace = System.getProperty("interlace");
		if (interlace != null && !interlace.equals("0") && !interlace.equals("1")) {
			printUsage();
			throw new Exception("invalid argument for interlace.");
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
		
		if (uright != null && ur_max % ur_step != 0) {
			printMultipleError("upright");
		}
		
		if (uleft != null && ul_max % ul_step != 0) {
			printMultipleError("upleft");
		}
		
		if (dright != null && dr_max % dr_step != 0) {
			printMultipleError("downright");
		}
		
		if (dleft != null && dl_max % dl_step != 0) {
			printMultipleError("downleft");
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
		System.out.println(" -Dupright=<int,int>");
		System.out.println(" -Dupleft=<int,int>");
		System.out.println(" -Ddownright=<int,int>");
		System.out.println(" -Ddownleft=<int,int>");
		System.out.println(" -Dfree");
		System.out.println(" -Dinterlace= 0 (odd) or 1 (even)");
		System.out.println("with <int,int> as : scrool step, scroll max value");
		System.out.println("values are in pixel, max value should be a multiple of step value.");
		System.out.println("free is for free scroll in any direction (you must declare right, left, up and down parameters).");
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
		// upright scroll			
		if (uright != null) {
			for (int i = ur_step; i <= ur_max; i += ur_step) {							
				if (!(x+i < width && y-i >= 0 && (image.getRaster().getDataBuffer()).getElem(x+i+(y-i)*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					keepPixel(x,y);
					return;
				}
			}
		}
		
		// upleft scroll
		if (uleft != null) {
			for (int i = ul_step; i <= ul_max; i += ul_step) {							
				if (!(x-i >= 0  && y-i >= 0 && (image.getRaster().getDataBuffer()).getElem(x-i+(y-i)*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					keepPixel(x,y);
					return;
				}
			}
		}
		
		// downright scroll			
		if (dright != null) {
			for (int i = dr_step; i <= dr_max; i += dr_step) {							
				if (!(x+i < width && y+i < height && (image.getRaster().getDataBuffer()).getElem(x+i+(y+i)*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					keepPixel(x,y);
					return;
				}
			}
		}
		
		// downleft scroll
		if (dleft != null) {
			for (int i = dl_step; i <= dl_max; i += dl_step) {							
				if (!(x-i >= 0  && y+i < height && (image.getRaster().getDataBuffer()).getElem(x-i+(y+i)*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					keepPixel(x,y);
					return;
				}
			}
		}			
		
		// Right scroll			
		if (right != null) {
			for (int i = r_step; i <= r_max; i += r_step) {							
				if (!(x+i < width && (image.getRaster().getDataBuffer()).getElem(x+i+y*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					keepPixel(x,y);
					return;
				}
			}
		}
		
		// Left scroll
		if (left != null) {
			for (int i = l_step; i <= l_max; i += l_step) {							
				if (!(x-i >= 0 && (image.getRaster().getDataBuffer()).getElem(x-i+y*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					keepPixel(x,y);
					return;
				}
			}
		}
		
		// Down scroll			
		if (down != null) {
			for (int i = d_step; i <= d_max; i += d_step) {							
				if (!(y+i < height && (image.getRaster().getDataBuffer()).getElem(x+(y+i)*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					keepPixel(x,y);
					return;
				}
			}
		}
		
		// Up scroll
		if (up != null) {
			for (int i = u_step; i <= u_max; i += u_step) {							
				if (!(y-i >= 0 && (image.getRaster().getDataBuffer()).getElem(x+(y-i)*width) == (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
					keepPixel(x,y);
					return;
				}
			}
		}			

		// free scroll			
		if (free != null) {
			for (int i = r_step; i <= r_max; i += r_step) {							
				for (int j = u_step; j <= u_max; j += u_step) {				
					if ((x+i < width && y-j >= 0 && (image.getRaster().getDataBuffer()).getElem(x+i+(y-j)*width) != (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
						keepPixel(x,y);
						return;
					}
				}
			}

			for (int i = l_step; i <= l_max; i += l_step) {	
				for (int j = u_step; j <= u_max; j += u_step) {
					if ((x-i >= 0  && y-j >= 0 && (image.getRaster().getDataBuffer()).getElem(x-i+(y-j)*width) != (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
						keepPixel(x,y);
						return;
					}
				}
			}

			for (int i = r_step; i <= r_max; i += r_step) {
				for (int j = d_step; j <= d_max; j += d_step) {
					if ((x+i < width && y+j < height && (image.getRaster().getDataBuffer()).getElem(x+i+(y+j)*width) != (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
						keepPixel(x,y);
						return;
					}
				}
			}

			for (int i = l_step; i <= l_max; i += l_step) {		
				for (int j = d_step; j <= d_max; j += d_step) {
					if ((x-i >= 0  && y+j < height && (image.getRaster().getDataBuffer()).getElem(x-i+(y+j)*width) != (image.getRaster().getDataBuffer()).getElem(x+y*width))) {
						keepPixel(x,y);
						return;
					}
				}
			}
		}
	}	
	
	public static void keepPixel(int x, int y) {
		leanTiles.setRGB(x, y, image.getRGB(x, y));
		leanTilesCommon.setRGB(x, y, image.getColorModel().getRGB(0));
	}
	
	public static void group2x(int x, int y) {
		if ((leanTiles.getRaster().getDataBuffer()).getElem(x+(y*width)) == 0 && (leanTiles.getRaster().getDataBuffer()).getElem(x+1+(y*width)) != 0){
			keepPixel(x,y);
			return;
		}
		
		if ((leanTiles.getRaster().getDataBuffer()).getElem(x+(y*width)) != 0 && (leanTiles.getRaster().getDataBuffer()).getElem(x+1+(y*width)) == 0){
			keepPixel(x+1,y);
			return;
		}
	}
	
}