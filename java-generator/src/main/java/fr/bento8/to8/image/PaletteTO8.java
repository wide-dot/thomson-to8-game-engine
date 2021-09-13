package fr.bento8.to8.image;

import java.awt.Color;
import java.awt.image.ColorModel;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;

import javax.imageio.ImageIO;

public class PaletteTO8 {

	private static LAB[] paletteLab;
	private static int[] paletteRGB;
	private static int to8RGB[] = {0,  97, 122, 143, 158, 171, 184, 194, 204, 212, 219, 227, 235, 242, 250, 255}; // relevé de voltage datasheet EF9369
	private static HashMap<Integer, Integer> to8RGBIndex = new HashMap<Integer, Integer>();	
	//private static int to8[] = {0,  97, 124, 144, 159, 172, 184, 194, 204, 212, 221, 228, 235, 242, 249, 255}; // 255*pow(n/15.0, 1/2.8)

	static {
		LAB labColor;
		paletteLab = new LAB[4096];
		paletteRGB = new int[4096];
		int i = 0;
		for (int r=0; r<16; r++) {
			for (int g=0; g<16; g++) {
				for (int b=0; b<16; b++) {
					labColor = LAB.fromRGBr(to8RGB[r], to8RGB[g], to8RGB[b], 1.0);
					paletteLab[i]=labColor;
					paletteRGB[i] = (0xFF000000 & (255 << 24)) | (0x00FF0000 & (to8RGB[r] << 16)) | (0x0000FF00 & (to8RGB[g] << 8)) | (0x000000FF & to8RGB[b]);
					i++;
				}
			}
			to8RGBIndex.put(to8RGB[r], r);
		}
	}
	
	public static String getPaletteData(String fileName) throws IOException {
		LAB currentColor = new LAB(0, 0, 0);
		int j, nearestColor;
		double distance, minDistance;
		
		ColorModel colorModel = ImageIO.read(new File(fileName)).getColorModel();
		String code = "";
		
		// Construction de la palette de couleur
		for (int colorIndex = 1; colorIndex < 17; colorIndex++) {
			Color couleur = new Color(colorModel.getRGB(colorIndex));
			currentColor = LAB.fromRGBr(couleur.getRed(), couleur.getGreen(), couleur.getBlue(), 1.0);
			minDistance = Double.POSITIVE_INFINITY;
			nearestColor = 0;
			for (j = 0; j < 4096; j++) {
				distance = LAB.ciede2000(currentColor, paletteLab[j]);
				if (distance < minDistance) {
					nearestColor = paletteRGB[j];
					minDistance = distance;
				}
			}

			code += "        fdb   $"
					+ Integer.toHexString(to8RGBIndex.get((nearestColor >> 8) & 0xFF))
					+ Integer.toHexString(to8RGBIndex.get((nearestColor >> 16) & 0xFF))					
					+ "0"
					+ Integer.toHexString(to8RGBIndex.get(nearestColor & 0xFF))
					+ "\n";
		}
		
		return code;
	}
		
}