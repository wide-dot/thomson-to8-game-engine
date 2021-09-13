package fr.bento8.to8.audio.YMTool;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import fr.bento8.to8.audio.YMTool.ym.YMTools;
import fr.bento8.to8.audio.YMTool.vgm.VGMInterpreter;

public class YMTool {
  public static final String TITLE = YMTool.class.getSimpleName();
  private static boolean split = false;
  private static boolean compress = true;
  private static int framerate = 0;
  private static String inputFilename;
  public static String outputFilename;
  private static int mask;
  
  private static void convertFile(File paramFile) {
    try {
      VGMInterpreter vGMInterpreter = new VGMInterpreter(paramFile);
      if (framerate > 0)
        framerate = 44100 / framerate; 
      int[] arrayOfInt = YMTools.getYMdata(vGMInterpreter, framerate);
      if (arrayOfInt.length == 53248) {
        if (!split) {
          System.err.println("Input data is too long. You can use the '-split' option to split the output over multiple files.");
          return;
        } 
        int b = 0;
        while (true) {
          arrayOfInt = maskData(arrayOfInt, mask);
          exportSound(compress ? YMTools.compressYM(arrayOfInt) : arrayOfInt, new File(String.valueOf(outputFilename) + b++));
          arrayOfInt = YMTools.getYMdata(vGMInterpreter, framerate);
          if (arrayOfInt.length != 53248) {
            vGMInterpreter.close();
            exportSound(compress ? YMTools.compressYM(arrayOfInt) : arrayOfInt, new File(String.valueOf(outputFilename) + b++));
            return;
          } 
        } 
      } 
      vGMInterpreter.close();
      arrayOfInt = maskData(arrayOfInt, mask);
      exportSound(compress ? YMTools.compressYM(arrayOfInt) : arrayOfInt, new File(outputFilename));
    } catch (IOException iOException) {
      iOException.printStackTrace();
    } 
  }
  
  private static int[] maskData(int[] paramArrayOfint, int paramInt) {
    if (paramInt > 0) {
      int[] arrayOfInt = new int[paramArrayOfint.length];
      int b1 = 0;
      int i = -1;
      for (int b2 = 0; b2 < paramArrayOfint.length; b2++) {
        if (paramArrayOfint[b2] < 56 && paramArrayOfint[b2] >= 8)
          return paramArrayOfint; 
        if (b1==0 && (paramArrayOfint[b2] & 0xF8) == 56 && (arrayOfInt[b1 - 1] & 0xF8) == 56) {
          int j = (paramArrayOfint[b2] & 0x7) + 1 + (arrayOfInt[b1 - 1] & 0x7) + 1;
          arrayOfInt[b1 - 1] = 56 + Math.min(7, j - 1);
          j -= (arrayOfInt[b1 - 1] & 0x7) + 1;
          if (j > 0)
            arrayOfInt[b1++] = 56 + j - 1; 
        } else {
          if ((paramArrayOfint[b2] & 0x80) != 0)
            i = (paramArrayOfint[b2] & 0x70) >> 5; 
          if ((paramArrayOfint[b2] & 0xC0) == 0 || (Math.max(0, i - 1) & paramInt) != 0)
            arrayOfInt[b1++] = paramArrayOfint[b2]; 
        } 
      } 
      if (b1 < paramArrayOfint.length) {
        paramArrayOfint = new int[b1];
        System.arraycopy(arrayOfInt, 0, paramArrayOfint, 0, paramArrayOfint.length);
      } 
    } 
    return paramArrayOfint;
  }
  
  private static void exportSound(int[] paramArrayOfint, File paramFile) {
    try {
      FileOutputStream fileOutputStream = new FileOutputStream(paramFile);
      byte[] arrayOfByte = new byte[paramArrayOfint.length];
      for (int b = 0; b < arrayOfByte.length; b++)
        arrayOfByte[b] = (byte)paramArrayOfint[b]; 
      fileOutputStream.write(arrayOfByte);
      fileOutputStream.close();
    } catch (IOException iOException) {
      iOException.printStackTrace();
    } 
  }
  
  private static void parseArgs(String[] paramArrayOfString) {
    for (int b = 0; b < paramArrayOfString.length; b++) {
      if ("-split".equalsIgnoreCase(paramArrayOfString[b])) {
        split = true;
      } else if ("-uncompressed".equalsIgnoreCase(paramArrayOfString[b])) {
        compress = false;
      } else if ("-framerate".equalsIgnoreCase(paramArrayOfString[b])) {
        framerate = Integer.parseInt(paramArrayOfString[++b]);
      } else if (paramArrayOfString[b].charAt(0) != '-') {
        if (inputFilename == null) {
          inputFilename = paramArrayOfString[b];
        } else if (paramArrayOfString[b].charAt(0) == '2' || paramArrayOfString[b].charAt(0) == '3') {
          for (int b1 = 0; b1 < paramArrayOfString[b].length(); b1++) {
            if (paramArrayOfString[b].charAt(b1) == '2') {
              mask |= 0x1;
            } else if (paramArrayOfString[b].charAt(b1) == '3') {
              mask |= 0x2;
            } 
          } 
        } else if (outputFilename == null) {
          outputFilename = paramArrayOfString[b];
        } 
      } 
    } 
  }
  
  public static void main(String[] paramArrayOfString) {
    parseArgs(paramArrayOfString);
    if (inputFilename == null) {
      System.err.println("Usage: java -jar YMTool.jar INPUTFILE [OUTPUTFILE] [2|3|23] [OPTIONS]");
      System.err.println("Options:");
      System.err.println("-split           Split large files into multiple files.");
      System.err.println("-uncompressed    Don't compress output.");
      System.err.println("-framerate       The target framerate. E.g. 60 for NTSC. If not specified, the input framerate is used.");
      return;
    } 
    if (outputFilename == null)
      if (inputFilename.endsWith(".vgm")) {
        outputFilename = inputFilename.replace(".vgm", ".ym");
      } else {
        outputFilename = String.valueOf(inputFilename) + ".ym";
      }  
    convertFile(new File(inputFilename));
  }
}