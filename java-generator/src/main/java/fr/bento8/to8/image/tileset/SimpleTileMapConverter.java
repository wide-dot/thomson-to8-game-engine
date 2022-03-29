package fr.bento8.to8.image.tileset;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

import fr.bento8.to8.util.FileUtil;

public class SimpleTileMapConverter {
	
	private static String bits;
	private static int bytes;
	private static int skip;
  
	private static void convertFile(File paramFile) throws Exception {
		try (BufferedInputStream  bufferedInputStream = new BufferedInputStream(new FileInputStream(paramFile))) {
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
            
            int totalSize = width*height*bytes;
		    int data = 0;
            for (int nbfiles = 0; nbfiles <= totalSize / 16384; nbfiles++) {
            	FileOutputStream fileOutputStream = new FileOutputStream(new File(FileUtil.removeExtension(paramFile.toString())+"_"+nbfiles+"."+bits+".bin"));
				byte[] arrayOfByte = new byte[16384];
			    int b = 0;    				
			    while(b < arrayOfByte.length && bufferedInputStream.available()>0){
			    	for (int i = b+bytes-1; i >= b; i--) {
			    		data = bufferedInputStream.read();
			    		arrayOfByte[i] = (byte)data;
			    	}
		    		bufferedInputStream.skip(skip);
		    		b+=bytes;
			    }

			    byte[] finalArray = new byte[b];
			    for (int j = 0; j < finalArray.length; j++) {
			    	finalArray[j] = arrayOfByte[j];
			    }
		        fileOutputStream.write(finalArray);
		        fileOutputStream.close();
            }
	        System.out.println("Done\n");
		}
	}

	public static void main(String[] paramArrayOfString) throws Exception {
	  String inputdir = paramArrayOfString[0];
	  if (inputdir == null) {
		  System.err.println("Usage: java -jar SimpleTileMapConverter.jar INPUTDIR <bits for tile ids 8, 16, 24, 32>");
		  return;
	  }
	  
	  bits = paramArrayOfString[1];
	  bytes = Integer.parseInt(bits)/8;
	  if (skip < 0 || skip > 4) {
		  System.err.println("Usage: java -jar SimpleTileMapConverter.jar INPUTDIR <bits for tile ids 8, 16, 24, 32>");
		  return;
	  }
	  skip = 4-bytes;
	  
	  File dir = new File(inputdir);
	  File[] files = dir.listFiles((d, name) -> name.endsWith(".stm"));
	  for (File stmfile : files) {
        convertFile(stmfile);
      }
	}
}