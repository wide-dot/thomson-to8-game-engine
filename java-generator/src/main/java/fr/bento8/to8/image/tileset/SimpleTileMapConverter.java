package fr.bento8.to8.image.tileset;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

import fr.bento8.to8.util.FileUtil;

public class SimpleTileMapConverter {
  
	private static void convertFile(File paramFile) throws Exception {
		try (BufferedInputStream  bufferedInputStream = new BufferedInputStream(new FileInputStream(paramFile))) {
			FileOutputStream fileOutputStream = new FileOutputStream(new File(FileUtil.removeExtension(paramFile.toString())+".bin"));
			System.out.println("Processing "+paramFile.toString()+ " file ...");
			
			byte[] header = new byte[8];
			bufferedInputStream.read(header, 0, 8);
			
            if (header[0] != 0x53 || header[1] != 0x54  || header[2] != 0x4D || header[3] != 0x50) {
            	throw new Exception ("Simple tile map header not found.");
            }
            System.out.println("> STMP Header found");
            
            int width = ((header[5] & 0xff) << 8) | (header[4] & 0xff);
            int height = ((header[7] & 0xff) << 8) | (header[6] & 0xff);
            System.out.println("> Map Width: "+width+" Height: "+height+" Tiles: "+(width*height));
            
			byte[] arrayOfByte = new byte[width*height];
			
		    int data = bufferedInputStream.read();
		    int b = 0;
		    while(data != -1){
		    	arrayOfByte[b++] = (byte)data; 
		        bufferedInputStream.skip(3);
		        data = bufferedInputStream.read();
		    }
	        fileOutputStream.write(arrayOfByte);
	        fileOutputStream.close();
	        System.out.println("Done\n");
		}
	}

	public static void main(String[] paramArrayOfString) throws Exception {
	  String inputdir = paramArrayOfString[0];
	  if (inputdir == null) {
		  System.err.println("Usage: java -jar SimpleTileMapConverter.jar INPUTDIR");
		  return;
	  }
	  
	  File dir = new File(inputdir);
	  File[] files = dir.listFiles((d, name) -> name.endsWith(".stm"));
	  for (File stmfile : files) {
        convertFile(stmfile);
      }
	}
}