package fr.bento8.to8.image;

import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.io.File;

import javax.imageio.ImageIO;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.util.FileUtil;

public class lineScroll{

	private static final Logger logger = LogManager.getLogger("log");	

	public static void main(String[] args) throws Throwable {

		System.out.println("*** line scroll generator ***");

		if (args.length != 5) {
			System.out.println("Arguments:");
			System.out.println(" <inputfile> : the png file");
			System.out.println(" <steps> : px resolution of the scroll (integer)");
			System.out.println(" <factor> : parallax factor");
			System.out.println(" <direction> : direction");
			System.out.println(" <frontoffset> : front offset");
			System.out.println("ex: test.png 1 0.01 down 9");
			throw new Exception("invalid number of arguments.");
		}

		try {
			String file = args[0];
			int scrollSteps = Integer.parseInt(args[1]);
			double factor = Double.parseDouble(args[2]);
			String direction = args[3];
			int offset = Integer.parseInt(args[4]);

			BufferedImage image = ImageIO.read(new File(file));
			BufferedImage imageout;
			int width = image.getWidth();
			int height = image.getHeight();
			ColorModel colorModel = image.getColorModel();
			int pixelSize = colorModel.getPixelSize();

			if (height * factor > 1) {
				System.out.println("parallax factor is too high.");
				throw new Exception("invalid parallax factor.");
			}
			
			if (height <= 200 && pixelSize == 8) {		

				// generate images
				int imagenum = 0;
				int center = (width/2)-(160/2);
				for (int imagepos = 0; imagepos < width-160; imagepos += scrollSteps) {
					imageout = new BufferedImage(160, height, BufferedImage.TYPE_INT_ARGB);
					System.out.println("image pos: "+imagepos);
					for (int y = 0; y < height; y++) {
						double linefactor = 1-(factor*(height-offset-y));
						if (linefactor>1) linefactor=1;
						for (int x = 0; x < 160; x++) {
							int x2 = (int)Math.round(center+x+(imagepos-center)*linefactor);
							if (x2 < width) {
								imageout.setRGB(x, y, image.getRGB(x2, y));
							} else {
								imageout.setRGB(x, y, colorModel.getRGB(0));
							}
						}
					}

					File outputfile = new File(FileUtil.removeExtension(file)+"_"+(imagenum++)+".png");
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