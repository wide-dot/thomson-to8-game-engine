package fr.bento8.to8.build;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

import fr.bento8.to8.image.PngToBottomUpB16Bin;
import fr.bento8.to8.ram.RamImage;
import fr.bento8.to8.storage.FdUtil;
import fr.bento8.to8.storage.T2Util;
import fr.bento8.to8.util.OrderedProperties;

public class Game {
	
	public String name;
	
	// Engine Loader
	public String engineAsmBootFd;
	public String engineAsmRAMLoaderManagerFd;
	public String engineAsmRAMLoaderFd;
	public static int loadManagerSizeFd = 0;	
	
	public String engineAsmBootT2;
	public String engineAsmRAMLoaderManagerT2;
	public String engineAsmRAMLoaderT2;	
	public static int loadManagerSizeT2 = 0;
	public static int bootSizeT2 = 0;
	public static int T2_NB_PAGES = 128;
	public String engineAsmBootT2Loader;
	public String engineAsmT2Loader;
	
	// Game Mode
	public String gameModeBoot;
	public HashMap<String, GameMode> gameModes = new HashMap<String, GameMode>();
	public static HashMap<String, GameModeCommon> allGameModeCommons = new HashMap<String, GameModeCommon>();	
	public static HashMap<String, Object> allObjects = new HashMap<String, Object>();
	public static HashMap<String, PngToBottomUpB16Bin> allBackgroundImages = new HashMap<String, PngToBottomUpB16Bin>();

	// Build
	public String lwasm;
	public String exobin;
	public String hxcfe;
	public boolean debug;
	public boolean logToConsole;	
	public String outputDiskName;
	public static String constAnim;
	public static String generatedCodeDirName;
	public static String generatedCodeDirNameDebug;
	public boolean memoryExtension;
	public static int nbMaxPagesRAM;	
	public boolean useCache;
	public int maxTries;
	public static String pragma;
	public static String[] includeDirs;
	public static String define;
	
	// Storage
	public FdUtil fd = new FdUtil();
	public T2Util t2 = new T2Util();	
	public RamImage romT2 = new RamImage(T2_NB_PAGES);
	
	public AsmSourceCode glb;
	
	public byte[] engineRAMLoaderManagerBytesFd;	
	public byte[] engineRAMLoaderManagerBytesT2;	
	public byte[] engineAsmRAMLoaderBytes;	
	public byte[] mainEXOBytes;
	public byte[] bootLoaderBytes;
	
	public Game() throws Exception {	
	}
	
	public Game(String file) throws Exception {	
			OrderedProperties prop = new OrderedProperties();
			this.name = "Game";
			
			try {
				InputStream input = new FileInputStream(file);
				prop.load(input);
			} catch (Exception e) {
				throw new Exception("\tUnable to load: "+file, e); 
			}
			
			if (prop.getProperty("builder.to8.memoryExtension") == null) {
				throw new Exception("builder.to8.memoryExtension not found in "+file);
			}
			memoryExtension = (prop.getProperty("builder.to8.memoryExtension").contentEquals("Y")?true:false);
			if (memoryExtension) {
				nbMaxPagesRAM = 32;
			} else {
				nbMaxPagesRAM = 16;
			}

			// Engine ASM source code
			// ********************************************************************

			engineAsmBootFd = prop.getProperty("engine.asm.boot.fd");
			if (engineAsmBootFd == null) {
				throw new Exception("engine.asm.boot.fd not found in "+file);
			}
			
			engineAsmBootT2 = prop.getProperty("engine.asm.boot.t2");
			if (engineAsmBootT2 == null) {
				throw new Exception("engine.asm.boot.t2 not found in "+file);
			}
			
			engineAsmBootT2Loader = prop.getProperty("engine.asm.boot.t2Loader");
			if (engineAsmBootT2Loader == null) {
				throw new Exception("engine.asm.boot.t2Loader not found in "+file);
			}						

			engineAsmT2Loader = prop.getProperty("engine.asm.t2Loader");
			if (engineAsmT2Loader == null) {
				throw new Exception("engine.asm.t2Loader not found in "+file);
			}				
			
			engineAsmRAMLoaderManagerFd = prop.getProperty("engine.asm.RAMLoaderManager.fd");
			if (engineAsmRAMLoaderManagerFd == null) {
				throw new Exception("engine.asm.RAMLoaderManager.fd not found in "+file);
			}
			
			engineAsmRAMLoaderFd = prop.getProperty("engine.asm.RAMLoader.fd");
			if (engineAsmRAMLoaderFd == null) {
				throw new Exception("engine.asm.RAMLoader.fd not found in "+file);
			}
			
			engineAsmRAMLoaderManagerT2 = prop.getProperty("engine.asm.RAMLoaderManager.t2");
			if (engineAsmRAMLoaderManagerT2 == null) {
				throw new Exception("engine.asm.RAMLoaderManager.t2 not found in "+file);
			}
			
			engineAsmRAMLoaderT2 = prop.getProperty("engine.asm.RAMLoader.t2");
			if (engineAsmRAMLoaderT2 == null) {
				throw new Exception("engine.asm.RAMLoader.t2 not found in "+file);
			}	
			
			constAnim = prop.getProperty("builder.constAnim");
			if (constAnim == null) {
				throw new Exception("builder.constAnim not found in "+file);
			}			
			
			generatedCodeDirName = prop.getProperty("builder.generatedCode") + "/";
			if (generatedCodeDirName == null) {
				throw new Exception("builder.generatedCode not found in "+file);
			}
			File tmpFile = new File (generatedCodeDirName);
			tmpFile.mkdir();
			generatedCodeDirNameDebug = generatedCodeDirName + "/debug/";
			tmpFile = new File (generatedCodeDirNameDebug);
			tmpFile.mkdir();

			// Game Definition
			// ********************************************************************		

			gameModeBoot = prop.getProperty("gameModeBoot");
			if (gameModeBoot == null) {
				throw new Exception("gameModeBoot not found in "+file);
			}

			HashMap<String, String[]> gameModeProperties = PropertyList.get(prop, "gameMode");
			if (gameModeProperties == null) {
				throw new Exception("gameMode not found in "+file);
			}
			
			// Chargement des fichiers de configuration des Game Modes
			for (Map.Entry<String,String[]> curGameMode : gameModeProperties.entrySet()) {
				BuildDisk.prelog += ("\tLoad Game Mode "+curGameMode.getKey()+": "+curGameMode.getValue()[0]+"\n");
				gameModes.put(curGameMode.getKey(), new GameMode(curGameMode.getKey(), curGameMode.getValue()[0]));
			}	

			// Build parameters
			// ********************************************************************				

			lwasm = prop.getProperty("builder.lwasm");
			if (lwasm == null) {
				throw new Exception("builder.lwasm not found in "+file);
			}
			
			pragma = prop.getProperty("builder.lwasm.pragma");
			if (pragma != null) {
				pragma = "--pragma=" + pragma;
			} else {
				pragma = "";
			}

			includeDirs = prop.getProperty("builder.lwasm.includeDirs").split(";");
			if (includeDirs != null) {
				for (int i=0; i<includeDirs.length; i++)
					includeDirs[i] = "--includedir=" + includeDirs[i];
			}
			
			define = prop.getProperty("builder.lwasm.define");
			if (define != null) {
				define = "--define=" + define;
			} else {
				define = "";
			}	

			if (prop.getProperty("builder.debug") == null) {
				throw new Exception("builder.debug not found in "+file);
			}
			debug = (prop.getProperty("builder.debug").contentEquals("Y")?true:false);
			
			exobin = prop.getProperty("builder.exobin");
			if (exobin == null) {
				BuildDisk.prelog += ("\nRam Data will be compressed by ZX0\n");
			} else {
				BuildDisk.prelog += ("\nRam Data will be compressed by Exomizer\n");
			}
			
			hxcfe = prop.getProperty("builder.hxcfe");
			if (hxcfe == null) {
				BuildDisk.prelog += ("\nhxcfe not defined.\n");
			}	

			if (prop.getProperty("builder.logToConsole") == null) {
				throw new Exception("builder.logToConsole not found in "+file);
			}
			logToConsole = (prop.getProperty("builder.logToConsole").contentEquals("Y")?true:false);

			outputDiskName = prop.getProperty("builder.diskName");
			if (outputDiskName == null) {
				throw new Exception("builder.diskName not found in "+file);
			}
			String outputDir = Paths.get(outputDiskName).getParent().toString();
			tmpFile = new File (outputDir);
			tmpFile.mkdir();

			if (prop.getProperty("builder.compilatedSprite.useCache") == null) {
				throw new Exception("builder.compilatedSprite.useCache not found in "+file);
			}
			useCache = (prop.getProperty("builder.compilatedSprite.useCache").contentEquals("Y")?true:false);

			if (prop.getProperty("builder.compilatedSprite.maxTries") == null) {
				throw new Exception("builder.compilatedSprite.maxTries not found in "+file);
			}
			maxTries = Integer.parseInt(prop.getProperty("builder.compilatedSprite.maxTries"));
			
			glb = new AsmSourceCode(BuildDisk.createFile(FileNames.GAME_GLOBALS, ""));
		}	
}