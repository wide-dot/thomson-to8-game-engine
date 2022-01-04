package fr.bento8.to8.image.encoder;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.build.AsmSourceCode;
import fr.bento8.to8.build.BuildDisk;
import fr.bento8.to8.build.Game;
import fr.bento8.to8.image.SpriteSheet;
import fr.bento8.to8.util.LWASMUtil;
import zx0.Compressor;
import zx0.Optimizer;

public class ZX0Encoder extends Encoder{

	private static final Logger logger = LogManager.getLogger("log");

	boolean FORWARD = true;
	boolean REARWARD = false;
	public String spriteName;
	public boolean spriteCenterEven;
	private int imageNum;
	private int runcount = 0;
	
	private int x_offset;
	private int x1_offset;
	private int y1_offset;
	private int x_size;
	private int y_size;
	private boolean isPlane0Empty;
	private boolean isPlane1Empty;
	private int center;
	
	// Code
	private List<String> spriteCode1 = new ArrayList<String>();
	private List<String> spriteCode2 = new ArrayList<String>();
	
	// Binary
	private byte[] content;
	private String asmDrawFileName, lstDrawFileName, binDrawFileName;
	private Path asmDFile, lstDFile, binDFile;
	
	public ZX0Encoder(SpriteSheet spriteSheet, String destDir, int imageNum) throws Exception {
		this.imageNum = imageNum;
		spriteCenterEven = (spriteSheet.center % 2) == 0;
		spriteName = spriteSheet.getName();
		x1_offset = spriteSheet.getSubImageX1Offset(imageNum);
		y1_offset = spriteSheet.getSubImageY1Offset(imageNum);
		x_size = spriteSheet.getSubImageXSize(imageNum);
		y_size = spriteSheet.getSubImageYSize(imageNum);
		isPlane0Empty = spriteSheet.isPlane0Empty();
		isPlane1Empty = spriteSheet.isPlane1Empty();		
		center = spriteSheet.getCenter();

		logger.debug("\t\t\tPlanche:"+spriteName+" image:"+imageNum);
		logger.debug("\t\t\tXOffset: "+getX_offset());;
		logger.debug("\t\t\tX1Offset: "+getX1_offset());
		logger.debug("\t\t\tY1Offset: "+getY1_offset());
		logger.debug("\t\t\tXSize: "+getX_size());
		logger.debug("\t\t\tYSize: "+getY_size());	
		logger.debug("\t\t\tCenter: "+spriteSheet.getCenter());
		
		destDir += "/"+spriteName;
		asmDrawFileName = destDir+"_"+imageNum+"_"+spriteSheet.variant+".asm";
		File file = new File (asmDrawFileName);
		file.getParentFile().mkdirs();		
		asmDFile = Paths.get(asmDrawFileName);
		lstDrawFileName = destDir+"_"+imageNum+"_"+spriteSheet.variant+".lst";
		lstDFile = Paths.get(lstDrawFileName);
		binDrawFileName = destDir+"_"+imageNum+"_"+spriteSheet.variant+".bin";
		binDFile = Paths.get(binDrawFileName);

		// Si l'option d'utilisation du cache est activée et qu'on trouve les fichiers .bin et .asm
		// on passe la génération des données
		if (!(BuildDisk.game.useCache && Files.exists(binDFile) && Files.exists(asmDFile) && Files.exists(lstDFile))) {

			//logger.debug("RAM 0 (val hex 0 à f par pixel, . Transparent):");
			//if (logger.isDebugEnabled())
				//logger.debug(debug80Col(spriteSheet.getSubImagePixels(imageNum, 0)));
			
			if (!isPlane0Empty)
				spriteCode1	= encode(spriteSheet.getSubImagePixels(imageNum, 0), spriteSheet.getCenter(), "0");

			//logger.debug("\t\t\tRAM 1 (val hex 0  à f par pixel, . Transparent):");
			//if (logger.isDebugEnabled())
				//logger.debug(debug80Col(spriteSheet.getSubImagePixels(imageNum, 1)));

			if (!isPlane0Empty)
				spriteCode2	= encode(spriteSheet.getSubImagePixels(imageNum, 1), spriteSheet.getCenter(), "1");
			
		}
	}
	
	public int getDSize() throws IOException {
		return Files.readAllBytes(Paths.get(binDrawFileName)).length;
	}
	
	public String getDrawBINFile() {
		return binDrawFileName;
	}
	
	public List<String> encode(byte[] dataIn, int center, String id) throws Exception {
		AsmSourceCode src = new AsmSourceCode();
		byte[] output = null;
        int[] delta = { 0 };
        
        // takes a dataIn table (values 0-16 : 0 transparent color, 1-16 colors)
        // split into two tables :
        // data : 0-15 colors (transparency is lost and now share the same index with color 0)
        // alpha : transparency mask 0-1 (0 : transparent, 1 : opaque)
		byte[] data = new byte[dataIn.length / 2];
		byte[] alpha = new byte[dataIn.length / 2];
		int i_start = 0, i_end = data.length;
		boolean startFlag = true;

		for (int i = 0; i < data.length; i++) {
			
			data[i] = (byte) ((dataIn[i*2]==0?0:(((dataIn[i*2] & 0xff) - 1) << 4)) + (dataIn[1+i*2]==0?0:(dataIn[1+i*2] & 0xff) - 1));
            alpha[i] = (byte) (((dataIn[i*2]==0?0:1) << 4) + (dataIn[1+i*2]==0?0:1));
			
			if (alpha[i] == 0 && startFlag) {
				i_start = i;
			}

			if (alpha[i] != 0) {
				i_end = i;
				startFlag = false;
			}
		}
		i_end++;

		byte[] dataTrim = new byte[i_end-i_start];
		byte[] alphaTrim = new byte[i_end-i_start];
		
		for (int i = 0; i < dataTrim.length; i++) {
			dataTrim[i] = data[i+i_start];
			alphaTrim[i] = alpha[i+i_start];
		}

		data = dataTrim;
		alpha = alphaTrim;

		if (BuildDisk.game.debug) {
			Path path = Paths.get(Game.generatedCodeDirNameDebug+spriteName+"_"+runcount+"_rle.bin");
			Path patha = Paths.get(Game.generatedCodeDirNameDebug+spriteName+"_"+runcount+"_rle-alpha.bin");
	        Files.write(path, data);
	        Files.write(patha, alpha);
	        runcount++;
		}        

		// only process color data, transparency is lost
        output = new Compressor().compress(new Optimizer().optimize(data, 0, 32640, 4, true), data, 0, false, false, delta);
        src.addFcb(output);
        
		List<String> asm = new ArrayList<String>();
		asm.add(src.content);
		return asm;
	}
	
	public void compileCode(String org) {		
		try
		{
			Pattern pt = Pattern.compile("[ \t]*ORG[ \t]*\\$[a-fA-F0-9]{4}");
			Process p;
			
			// Process Draw Code
			// ****************************************************************			
			if (!(BuildDisk.game.useCache && Files.exists(binDFile) && Files.exists(asmDFile) && Files.exists(lstDFile))) {
				Files.deleteIfExists(asmDFile);
				Files.createFile(asmDFile);
				
				Files.write(asmDFile, getCodeFrameDrawHeader(org), Charset.forName("UTF-8"), StandardOpenOption.APPEND);
				String src;
				
				if (isPlane0Empty && isPlane1Empty) {	
					src = "        rts\n";				
					Files.write(asmDFile, src.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);					
				} else {					
					src = "        ; this will change return address and skip bra instruction\n";
					src += "        puls  d\n";
					src += "        addd  #7\n";
					src += "        pshs  d\n";   
					src += "        ; set graphic routine parameters\n";
					
					if (!isPlane0Empty) {
					    src += "        ldx   glb_screen_location_1\n";
					    src += "        leax  "+(-center)+",x\n";
					    src += "        stx   glb_screen_location_1\n";								
						src += "        leau  @a,pcr\n";			    
					} else {
						src += "        ldu   #0\n";
					}
					if (!isPlane1Empty) {
					    src += "        ldx   glb_screen_location_2\n";
					    src += "        leax  "+(-center)+",x\n";
					    src += "        stx   glb_screen_location_2\n";								
						src += "        leax  @b,pcr\n";
					} else {
						src += "        ldx   #0\n";
					}
					src += "        ; go to alt graphic routine\n";
					src += "        rts\n";				
					Files.write(asmDFile, src.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
					
					if (!isPlane0Empty) {
						src = "@a";					
						Files.write(asmDFile, src.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
						Files.write(asmDFile, spriteCode1, Charset.forName("UTF-8"), StandardOpenOption.APPEND);						
					}
					if (!isPlane1Empty) {
						src = "@b";					
						Files.write(asmDFile, src.getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
						Files.write(asmDFile, spriteCode2, Charset.forName("UTF-8"), StandardOpenOption.APPEND);						
					}	
				}
				
			} else {
				// change ORG adress in existing ASM file
				String str = new String(Files.readAllBytes(asmDFile), StandardCharsets.UTF_8);
				Matcher m = pt.matcher(str);
				if (m.find()) {
					str = m.replaceFirst("\tORG \\$"+org);
				}
				Files.write(asmDFile, str.getBytes(StandardCharsets.UTF_8));
			}

			// Delete binary file
			Files.deleteIfExists(binDFile);
			
			List<String> command = new ArrayList<>(List.of(BuildDisk.game.lwasm,
					asmDrawFileName,
					   "--output=" + binDrawFileName,
					   "--list=" + lstDrawFileName,
					   "--6809",	
					   "--includedir=./",
					   "--raw",
					   Game.pragma				   
					   ));
			
			for (int i=0; i<Game.includeDirs.length; i++)
				command.add(Game.includeDirs[i]);
			
			if (Game.define != null && Game.define.length()>0) command.add(Game.define);
				
			p = new ProcessBuilder(command).inheritIO().start();
			p.waitFor();

			// Load binary code
			content = Files.readAllBytes(Paths.get(binDrawFileName));	
			int compilerDSize = content.length;	
			int compilerDCycles = LWASMUtil.countCycles(lstDrawFileName);
			
			logger.debug("\t\t\t" +lstDrawFileName + " lwasm.exe DRAW cycles: " + compilerDCycles);
			logger.debug("\t\t\t" +lstDrawFileName + " lwasm.exe DRAW size: " + compilerDSize);

			if (compilerDSize > 16384) {
				throw new Exception("\t\t\t" +lstDrawFileName + " Le code généré ("+compilerDSize+" octets) dépasse la taille d'une page", new Exception("Prérequis."));
			}			
		} 
		catch (Exception e)
		{
			e.printStackTrace(); 
			System.out.println(e); 
		}
	}

	public static String debug80Col(byte[] b1) {
		StringBuilder strBuilder = new StringBuilder();
		int i = 0;
		for(byte val : b1) {
			if (val == 0) {
				strBuilder.append(".");
			} else {
				strBuilder.append(String.format("%01x", (val-1)&0xff));
			}
			if (++i == 80) {
				strBuilder.append(System.lineSeparator());
				i = 0;
			}
		}
		return strBuilder.toString();
	}

	public List<String> getCodeFrameDrawHeader(String org) {
		List<String> asm = new ArrayList<String>();
		asm.add("\tINCLUDE \"./Engine/Constants.asm\"");
		asm.add("");
		asm.add("\torg   $" + org + "");
		asm.add("\tsetdp $FF");
		asm.add("\topt   c,ct");		
		asm.add("");		
		asm.add("DRAW_" + spriteName + "_" + imageNum);
		return asm;
	}

	public int getX_offset() {
		return x_offset;
	}

	public int getX1_offset() {
		return x1_offset;
	}	
	
	public int getY1_offset() {
		return y1_offset;
	}

	public int getX_size() {
		return x_size;
	}

	public int getY_size() {
		return y_size;
	}	
}
