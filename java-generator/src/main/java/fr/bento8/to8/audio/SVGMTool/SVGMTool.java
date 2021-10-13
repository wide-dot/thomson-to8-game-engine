package fr.bento8.to8.audio.SVGMTool;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import fr.bento8.to8.audio.SVGMTool.vgm.VGMInterpreter;

public class SVGMTool {
	private static String inputFilename;
	public static String outputFilename;
	public static VGMInterpreter vGMInterpreter;
	public static int[] drumVol;

	private static void convertFile(File paramFile) {
		try {
			vGMInterpreter = new VGMInterpreter(paramFile);
			vGMInterpreter.close();
			exportSound(vGMInterpreter.getArrayOfInt(), new File(outputFilename));
		} catch (IOException iOException) {
			iOException.printStackTrace();
		} 
	}

	private static void exportSound(int[] paramArrayOfint, File paramFile) {
		try {
			FileOutputStream fileOutputStream = new FileOutputStream(paramFile);
			byte[] arrayOfByte = new byte[vGMInterpreter.getLastIndex()];
			for (int b = 0; b < vGMInterpreter.getLastIndex(); b++)
				arrayOfByte[b] = (byte)paramArrayOfint[b]; 
			fileOutputStream.write(arrayOfByte);
			fileOutputStream.close();
		} catch (IOException iOException) {
			iOException.printStackTrace();
		} 
	}

	private static void parseArgs(String[] paramArrayOfString) throws Exception {
		for (int b = 0; b < paramArrayOfString.length; b++) {
			if (paramArrayOfString[b].startsWith("-drumvol=")) {
				String[] drumVolTxt = paramArrayOfString[b].split("=")[1].split(",");
				if (drumVolTxt.length != 3) {
					throw new Exception("drumvol option need three arguments, ex: -drumvol=0xF2,0x62,0x44");
				}
				drumVol = new int[3];
				drumVol[0] = Integer.decode(drumVolTxt[0]);
				drumVol[1] = Integer.decode(drumVolTxt[1]);
				drumVol[2] = Integer.decode(drumVolTxt[2]);        	
			} else {
				if (inputFilename == null) {
					inputFilename = paramArrayOfString[b];
				} else if (outputFilename == null) {
					outputFilename = paramArrayOfString[b];
				}
			}
		} 
		if (drumVol == null) {
			drumVol = new int[3];
			drumVol[0] = 0xF2;
			drumVol[1] = 0x62;
			drumVol[2] = 0x44;   
		}
	} 

	public static void main(String[] paramArrayOfString) throws Exception {
		parseArgs(paramArrayOfString);
		if (inputFilename == null) {
			System.err.println("Arguments: INPUTFILE [OUTPUTFILE] [-drumvol=0xF2,0x62,0x44]");
			System.err.println("-drumvol : (optional) lists all attenuations values for each drum sound (0: max vol, F: silence)");
			System.err.println("Default values are:");
			System.err.println("0xF2 : F (unused) 2 (attenuation value for Bass drum)");
			System.err.println("0x62 : 6 (attenuation value for Hi-hat) 2 (attenuation value for Snare drum)");
			System.err.println("0x44 : 4 (attenuation value for Tom) 4 (attenuation value for Cymbal)");
			return;
		} 
		if (outputFilename == null)
			if (inputFilename.endsWith(".vgm")) {
				outputFilename = inputFilename.replace(".vgm", ".svgm");
			} else {
				outputFilename = String.valueOf(inputFilename) + ".svgm";
			}  
		convertFile(new File(inputFilename));
	}
}