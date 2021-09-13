package fr.bento8.to8.image;

import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.awt.image.ColorModel;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

import javax.imageio.ImageIO;

import fr.bento8.to8.build.Act;
import fr.bento8.to8.build.Object;
import fr.bento8.to8.storage.RAMLoaderIndex;
import fr.bento8.to8.util.knapsack.ItemBin;

public class PngToBottomUpB16Bin extends ItemBin{
	BufferedImage image;
	ColorModel colorModel;
	int width;
	int height;
	byte[] pixels;
	byte[] pixelsAB;

	public String name = "";
	public Act act;	
	public String file;
	public boolean inRAM = false;
	
	/**
	 * Charge un PNG et génère une page mémoire prête à l'affichage pour TO8
	 * Les données sont copiées à l'envers pour utilisation PUL/PSH remontant
	 * @param nom du fichier image
	 */
	public PngToBottomUpB16Bin(String file, Act act) {
		try {
			System.out.println("**************** Conversion png vers binaire pour PUL/PSH remontant "+file+" ****************");
			
			this.name = act.name+" Background Image";
			this.file = file;
			this.act = act;
			
			// Lecture de l'image a traiter
			image = ImageIO.read(new File(file));
			width = image.getWidth();
			height = image.getHeight();
			colorModel = image.getColorModel();
			int pixelSize = colorModel.getPixelSize();

			// Contrôle du format d'image
			if (width == 160 && height == 200 && pixelSize == 8) {
				
				pixels = ((DataBufferByte) image.getRaster().getDataBuffer()).getData();
				
				// Construction de la RAM A et la RAM B
				int i,j;
				pixelsAB = new byte[16000]; //Determine la taille du fichier de sortie

				// Data - Ecriture en sens inverse pour PUL/PSH
				for (i = (width*height)-1, j = 0; i >= 28; i -= 28) {
					pixelsAB[j]   = (byte)((pixels[i-27]-1) << 4 | (pixels[i-26]-1) & 0x0F );
					pixelsAB[j+1] = (byte)((pixels[i-23]-1) << 4 | (pixels[i-22]-1) & 0x0F );
					pixelsAB[j+2] = (byte)((pixels[i-19]-1) << 4 | (pixels[i-18]-1) & 0x0F );
					pixelsAB[j+3] = (byte)((pixels[i-15]-1) << 4 | (pixels[i-14]-1) & 0x0F );
					pixelsAB[j+4] = (byte)((pixels[i-11]-1) << 4 | (pixels[i-10]-1) & 0x0F );
					pixelsAB[j+5] = (byte)((pixels[i-7]-1)  << 4 | (pixels[i-6]-1)  & 0x0F );
					pixelsAB[j+6] = (byte)((pixels[i-3]-1)  << 4 | (pixels[i-2]-1)  & 0x0F );
					j += 8000;
					pixelsAB[j]   = (byte)((pixels[i-25]-1) << 4 | (pixels[i-24]-1) & 0x0F );
					pixelsAB[j+1] = (byte)((pixels[i-21]-1) << 4 | (pixels[i-20]-1) & 0x0F );
					pixelsAB[j+2] = (byte)((pixels[i-17]-1) << 4 | (pixels[i-16]-1) & 0x0F );
					pixelsAB[j+3] = (byte)((pixels[i-13]-1) << 4 | (pixels[i-12]-1) & 0x0F );
					pixelsAB[j+4] = (byte)((pixels[i-9]-1)  << 4 | (pixels[i-8]-1)  & 0x0F );
					pixelsAB[j+5] = (byte)((pixels[i-5]-1)  << 4 | (pixels[i-4]-1)  & 0x0F );
					pixelsAB[j+6] = (byte)((pixels[i-1]-1)  << 4 | (pixels[i]-1)    & 0x0F );
					j -= 8000;
					j += 7;
				}
				pixelsAB[j]   = (byte)((pixels[i-23]-1) << 4 | (pixels[i-22]-1) & 0x0F );
				pixelsAB[j+1] = (byte)((pixels[i-19]-1) << 4 | (pixels[i-18]-1) & 0x0F );
				pixelsAB[j+2] = (byte)((pixels[i-15]-1) << 4 | (pixels[i-14]-1) & 0x0F );
				pixelsAB[j+3] = (byte)((pixels[i-11]-1) << 4 | (pixels[i-10]-1) & 0x0F );
				pixelsAB[j+4] = (byte)((pixels[i-7]-1)  << 4 | (pixels[i-6]-1)  & 0x0F );
				pixelsAB[j+5] = (byte)((pixels[i-3]-1)  << 4 | (pixels[i-2]-1)  & 0x0F );
				j += 8000;
				pixelsAB[j]   = (byte)((pixels[i-21]-1) << 4 | (pixels[i-20]-1) & 0x0F );
				pixelsAB[j+1] = (byte)((pixels[i-17]-1) << 4 | (pixels[i-16]-1) & 0x0F );
				pixelsAB[j+2] = (byte)((pixels[i-13]-1) << 4 | (pixels[i-12]-1) & 0x0F );
				pixelsAB[j+3] = (byte)((pixels[i-9]-1)  << 4 | (pixels[i-8]-1)  & 0x0F );
				pixelsAB[j+4] = (byte)((pixels[i-5]-1)  << 4 | (pixels[i-4]-1)  & 0x0F );
				pixelsAB[j+5] = (byte)((pixels[i-1]-1)  << 4 | (pixels[i]-1)    & 0x0F );
		
			} else {
				System.out.println("Le format de fichier de " + file + " n'est pas supporté.");
				System.out.println("Resolution: " + width + "x" + height + "px (doit être égal à 160x200)");
				System.out.println("Taille pixel:  " + pixelSize + "Bytes (doit être 8)");
			}
			
			bin = pixelsAB;
			uncompressedSize = pixelsAB.length;
			//inRAM = this.inRAM;
			
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(e);
		}
	}

	public byte[] getBIN() {
		return pixelsAB;
	}

	@Override
	public String getFullName() {
		// TODO Auto-generated method stub
		return name;
	}

	@Override
	public Object getObject() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public RAMLoaderIndex getRAMLoaderIndex() {
		// TODO Auto-generated method stub
		return null;
	}
}
