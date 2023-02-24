package fr.bento8.arcade.rtype;

import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.nio.file.Files;

import javax.imageio.ImageIO;

public class Main {
	public static void main(String[] args) throws Exception {
		
		System.out.print("start processing ...");
		
		String path = args[0];
		String dirRom = path + "/out/rom";
		String dirPalette = path + "/out/palette";
		String dirTile = path + "/out/tiles";
				
		File dir;
		dir = new File(dirRom);
		dir.mkdirs();
		dir = new File(dirPalette);
		dir.mkdirs();
		dir = new File(dirTile);
		dir.mkdirs();
		
		// rebuild all rom images
		Rom rom = new Rom (path);
		File outputFile = new File(dirRom+"/maincpu.bin");
		Files.write(outputFile.toPath(), rom.maincpu);
		outputFile = new File(dirRom+"/gfx1.bin");
		Files.write(outputFile.toPath(), rom.gfx1);
		outputFile = new File(dirRom+"/gfx2.bin");
		Files.write(outputFile.toPath(), rom.gfx2);
		outputFile = new File(dirRom+"/gfx3.bin");
		Files.write(outputFile.toPath(), rom.gfx3);

		// extract all palette lines into dedicated .pal files
		for (int i=0; i<108; i++) {
			Palette pal = new Palette (rom, i, 16);
			outputFile = new File(dirPalette+"/" + String.format("%03d", i) + ".pal");
			Files.write(outputFile.toPath(), pal.pal);
		}
		
		// extract all tiles in png
		for (int i=0; i < 0x6A; i++) {
			Tile tile = new Tile(i, rom);
			Palette pal = new Palette (rom, TilePalette.line[i], 1);
			IndexColorModel cm = new IndexColorModel(8, 16, pal.r, pal.g, pal.b);
		    BufferedImage png = new BufferedImage(8, 8, BufferedImage.TYPE_BYTE_INDEXED, cm);
		    for (int j=0; j < tile.data.length; j++) {
		    	png.getRaster().getDataBuffer().setElem(j, tile.data[j]);
		    }
		    outputFile = new File(dirTile+"/" + String.format("%04d", i) + ".png");			
			ImageIO.write(png, "png", outputFile);		
		}
		
		System.out.println(" done");
	}
}
