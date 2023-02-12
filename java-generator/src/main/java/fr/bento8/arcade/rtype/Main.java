package fr.bento8.arcade.rtype;

import java.io.File;
import java.nio.file.Files;

public class Main {
	public static void main(String[] args) throws Exception {
		
		String path = args[0];
		
		Rom rom = new Rom (path);
		File outputFile = new File(path+"/rom.bin");
		Files.write(outputFile.toPath(), rom.data);
		
		Palette pal1 = new Palette (Palette.palette1);
		outputFile = new File(path+"/1-1.pal");
		Files.write(outputFile.toPath(), pal1.pal);
		
		Palette pal2 = new Palette (Palette.palette2);
		outputFile = new File(path+"/1-2.pal");
		Files.write(outputFile.toPath(), pal2.pal);
		
		System.out.println("Done.");
	}
}
