package fr.bento8.to8.build;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.core.LoggerContext;
import org.apache.logging.log4j.core.config.Configuration;
import org.apache.logging.log4j.core.config.Configurator;
import org.apache.logging.log4j.core.config.LoggerConfig;

import fr.bento8.to8.audio.Sound;
import fr.bento8.to8.audio.SoundBin;
import fr.bento8.to8.boot.Bootloader;
import fr.bento8.to8.compiledSprite.backupDrawErase.AssemblyGenerator;
import fr.bento8.to8.compiledSprite.draw.SimpleAssemblyGenerator;
import fr.bento8.to8.image.Animation;
import fr.bento8.to8.image.AnimationBin;
import fr.bento8.to8.image.PngToBottomUpB16Bin;
import fr.bento8.to8.image.ImageSetBin;
import fr.bento8.to8.image.PaletteTO8;
import fr.bento8.to8.image.Sprite;
import fr.bento8.to8.image.SpriteSheet;
import fr.bento8.to8.image.SubSprite;
import fr.bento8.to8.image.SubSpriteBin;
import fr.bento8.to8.image.TileBin;
import fr.bento8.to8.image.Tileset;
import fr.bento8.to8.image.encoder.Encoder;
import fr.bento8.to8.image.encoder.MapRleEncoder;
import fr.bento8.to8.image.encoder.ZX0Encoder;
import fr.bento8.to8.ram.RamImage;
import fr.bento8.to8.storage.DataIndex;
import fr.bento8.to8.storage.FdUtil;
import fr.bento8.to8.storage.RAMLoaderIndex;
import fr.bento8.to8.storage.SdUtil;
import fr.bento8.to8.storage.T2Util;
import fr.bento8.to8.util.FileUtil;
import fr.bento8.to8.util.LWASMUtil;
import fr.bento8.to8.util.knapsack.Item;
import fr.bento8.to8.util.knapsack.Knapsack;
import fr.bento8.to8.util.knapsack.Solution;
import zx0.Compressor;
import zx0.Optimizer;

public class BuildDisk
{
	static final Logger logger = LogManager.getLogger("log");
	public static String prelog = ""; // buffer that store log before log init

	public static Game game;
	private static FdUtil fd = new FdUtil();
	private static T2Util t2 = new T2Util();
	private static SdUtil t2L = new SdUtil();	
	
	public static int UNDEFINED = 0;
	public static int FLOPPY_DISK = 0;
	public static int MEGAROM_T2 = 1;
	public static String[] MODE_LABEL = new String[]{"FLOPPY_DISK", "MEGAROM_T2"};
	public static String[] MODE_DIR = new String[]{"FD", "T2"};
	public static boolean GAMEMODE = false;
	public static boolean GAMEMODE_COMMON = true;
	public static String RAM = "RAM";
	
	public static boolean abortFloppyDisk = false;
	public static boolean abortT2 = false;
	
	public static DynamicContent dynamicContentFD = new DynamicContent();
	public static DynamicContent dynamicContentT2 = new DynamicContent();	
	
	/**
	 * Génère une image de disquette dans les formats .fd et .sd pour 
	 * l'ordinateur Thomson TO8.
	 * L'image de disquette contient un secteur d'amorçage et le code
	 * MainGameManager qui sera chargé en mémoire par le code d'amorçage.
	 * Ce programme n'utilise donc pas de système de fichier.
	 * 
	 * Plan d'adressage d'une disquette Thomson TO8 ou format .fd (655360 octets ou 640kiB)
	 * Identifiant des faces: 0-1
	 * Pour chaque face, identifiant des pistes: 0-79
	 * Pour chaque piste, identifiant des secteurs: 1-16
	 * Taille d'un secteur: 256 octets
	 * face=0 piste=0 secteur=1 : octets=0 à 256 (Secteur d'amorçage)
	 * ...
	 * 
	 * Le format .sd (1310720 octets ou 1,25MiB) reprend la même structure que le format .fd mais ajoute
	 * 256 octets à la fin de chaque secteur avec la valeur FF
	 * 
	 * Remarque il est posible dans un fichier .fd ou .sd de concaténer deux disquettes
	 * Cette fonctionnalité n'est pas (encore ;-)) implémentée ici.
	 * 
	 * Mode graphique utilisé: 160x200 (seize couleurs sans contraintes)
	 * 
	 * @param args nom du fichier properties contenant les données de configuration
	 * @throws Throwable 
	 */
	
	public static void main(String[] args) throws Throwable
	{
		try {
			loadGameConfiguration(args[0]);
			clean();
			
			initT2();
			compileRAMLoader();
			generateObjectIDs();
			generateGameModeIDs();
			processSounds();			
			processBackgroundImages();
			generateSprites();
			generateTilesets();
			compileMainEngines(false);
			compileObjects();
			System.gc();
			computeRamAddress();
			computeRomAddress();
			generateDynamicContent();
			generateImgAniIndex();
			compileMainEngines(true);
			applyDynamicContent();			
			compressData();
			writeObjectsFd(); 
			writeObjectsT2();
			compileRAMLoaderManager();
			compileAndWriteBootFd();
			compileAndWriteBootT2();
			buildT2Loader();
			
		} catch (Exception e) {
			logger.fatal("Build error.", e);
		}
	}

	
	private static void clean() throws IOException {
		logger.debug("Delete RAM data files ...");

		File file = new File (Game.generatedCodeDirName+"RAM data/"+MODE_LABEL[FLOPPY_DISK]+"/tmp");
		file.getParentFile().mkdirs();
		file = new File (Game.generatedCodeDirName+"RAM data/"+MODE_LABEL[MEGAROM_T2]+"/tmp");
		file.getParentFile().mkdirs();		
		
		final File downloadDirectory = new File(Game.generatedCodeDirName+"RAM data/"+MODE_LABEL[FLOPPY_DISK]);   
	    final File[] files = downloadDirectory.listFiles( (dir,name) -> name.matches(".*\\.raw" ));
	    Arrays.asList(files).stream().forEach(File::delete);
	    final File[] filesExo = downloadDirectory.listFiles( (dir,name) -> name.matches(".*\\.exo" ));
	    Arrays.asList(filesExo).stream().forEach(File::delete);	
	    
		final File downloadDirectoryT2 = new File(Game.generatedCodeDirName+"RAM data/"+MODE_LABEL[MEGAROM_T2]);   
	    final File[] filesT2 = downloadDirectoryT2.listFiles( (dir,name) -> name.matches(".*\\.raw" ));
	    Arrays.asList(filesT2).stream().forEach(File::delete);
	    final File[] filesT2Exo = downloadDirectoryT2.listFiles( (dir,name) -> name.matches(".*\\.exo" ));
	    Arrays.asList(filesT2Exo).stream().forEach(File::delete);		    
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private static void initT2() throws Exception {
		Game.bootSizeT2 = getBINSize(game.engineAsmBootT2);
		game.glb.addConstant("Build_RAMLoaderManager", String.format("$%1$04X", Game.bootSizeT2));
		game.glb.flush();
		//game.romT2.reserveT2Header();
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	public static void loadGameConfiguration(String configFileName) throws Exception {
		logger.info("Load Game configuration: "+configFileName+" ...");
		game = new Game(configFileName);
		
		// Initialisation du logger
		if (game.debug) {
			Configurator.setAllLevels(LogManager.getRootLogger().getName(), Level.DEBUG);
		}

		LoggerContext context = LoggerContext.getContext(false);
		Configuration configuration = context.getConfiguration();
		LoggerConfig loggerConfig = configuration.getLoggerConfig(LogManager.getRootLogger().getName());

		if (!game.logToConsole) {
			loggerConfig.removeAppender("LogToConsole");
			context.updateLoggers();
		}			
		
		logger.debug(prelog);
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private static void compileRAMLoader() throws Exception {
		compileRAMLoader(FLOPPY_DISK);
		Files.deleteIfExists(Paths.get(Game.generatedCodeDirName + FileNames.FILE_INDEX_FD));
		compileRAMLoader(MEGAROM_T2);
		Files.deleteIfExists(Paths.get(Game.generatedCodeDirName + FileNames.FILE_INDEX_T2));
	}
	
	private static void compileRAMLoader(int mode) throws Exception {
		logger.info("Compile RAM Loader ...");

		String ramLoader;
		if (mode == FLOPPY_DISK) {
			ramLoader = duplicateFile(game.engineAsmRAMLoaderFd);
		} else {
			ramLoader = duplicateFile(game.engineAsmRAMLoaderT2);
		}
		compileRAW(ramLoader, mode);
		Path binFile = Paths.get(getBINFileName(ramLoader));
		byte[] BINBytes = Files.readAllBytes(binFile);
		byte[] InvBINBytes = new byte[BINBytes.length];
        int j = 0;
        
		// Inversion des données par bloc de 7 octets (simplifie la copie par pul/psh au runtime)
		for (int i = BINBytes.length-7; i >= 0; i -= 7) {
			InvBINBytes[j++] = BINBytes[i];			                          
			InvBINBytes[j++] = BINBytes[i+1];
			InvBINBytes[j++] = BINBytes[i+2];
			InvBINBytes[j++] = BINBytes[i+3];
			InvBINBytes[j++] = BINBytes[i+4];
			InvBINBytes[j++] = BINBytes[i+5];
			InvBINBytes[j++] = BINBytes[i+6];
		}
		
		Files.write(binFile, InvBINBytes);
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void generateObjectIDs() throws Exception {
		logger.info("Set Objects Id as Globals ...");
				
		// GLOBALS - Génération des identifiants d'objets pour l'ensemble des game modes
		// - identifiants des objets communs, ils sont identiques pour un même Game Mode Common
		// - identifiants des objets de Game Mode (Un id d'un même objet peut être différent selon le game Mode)
		// L'id objet est utilisé comme index pour accéder à l'adresse du code de l'objet au runtime
		// ----------------------------------------------------------------------------------------------------		
		int objIndex;
		for(Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			
			objIndex = 1;
			logger.debug("\tGame Mode: "+gameMode.getKey());
			
			// Game Mode Common
			for (GameModeCommon common : gameMode.getValue().gameModeCommon) {
				if (common != null) {
					for (Entry<String, Object> object : common.objects.entrySet()) {
						objIndex = generateObjectIDs(gameMode.getValue(), object.getValue(), objIndex);
					}
				}
			}
			
			// Objets du Game Mode
			for (Entry<String, Object> object : gameMode.getValue().objects.entrySet()) {
				objIndex = generateObjectIDs(gameMode.getValue(), object.getValue(), objIndex);

			}
			gameMode.getValue().glb.flush();
		}
	}
	
	private static int generateObjectIDs(GameMode gameMode, Object object, int objIndex) throws Exception {
		// Sauvegarde de l'id objet pour ce Game Mode
		gameMode.objectsId.put(object, objIndex);
		
		// Génération de la constante ASM
		gameMode.glb.addConstant("ObjID_"+object.name, Integer.toString(objIndex));
		
		logger.debug("\t\tObjID_"+object.name+" "+Integer.toString(objIndex));
		return ++objIndex; 
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void generateGameModeIDs() throws Exception {
		logger.info("Set GameMode Id as Globals ...");

		int gmIndex = 0;
		for(Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			gmIndex = generateGameModeIDs(gameMode.getValue(), gmIndex);
			game.glb.flush();
		}
	}
	
	private static int generateGameModeIDs(GameMode gameMode, int gmIndex) throws Exception {
		// Génération de la constante ASM
		game.glb.addConstant("GmID_"+gameMode.name, Integer.toString(gmIndex));
		
		// game mode de démarrage
		if (gameMode.name.contentEquals(game.gameModeBoot)) {
			game.glb.addConstant("gmboot", Integer.toString(gmIndex));
		}
		
		logger.debug("\t\tGmID_"+gameMode.name+" "+Integer.toString(gmIndex));
		return ++gmIndex; 
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	 
	private static void processSounds() throws Exception {
		logger.info("Process Sounds ...");

		// Chargement des données audio
		// ---------------------------------------------

		// Parcours de tous les objets de chaque Game Mode
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			logger.debug("\tGame Mode: "+gameMode.getKey());

			// Game Mode Common
			for (GameModeCommon common : gameMode.getValue().gameModeCommon) {
				if (common != null) {
					for (Entry<String, Object> object : common.objects.entrySet()) {
						processSounds(gameMode.getValue(), object.getValue());
					}
				}
			}			
			
			for (Entry<String, Object> object : gameMode.getValue().objects.entrySet()) {
				processSounds(gameMode.getValue(), object.getValue());
			}
		}
	}
	
	private static void processSounds(GameMode gameMode, Object object) throws Exception {
		// Parcours des données audio de l'objet
		for (Entry<String, String[]> soundsProperties : object.soundsProperties.entrySet()) {

			logger.debug("\t\tSound: "+soundsProperties.getKey());
			
			Sound sound = new Sound(soundsProperties.getKey());
			sound.soundFile = soundsProperties.getValue()[0];
			boolean inRAM = soundsProperties.getValue().length > 1 && soundsProperties.getValue()[1].equalsIgnoreCase(BuildDisk.RAM);
			if (inRAM)
				sound.inRAM = true;			
			
			sound.setAllBinaries(sound.soundFile, inRAM);
			object.sounds.add(sound);
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	 
	private static void processBackgroundImages() throws Exception {
		logger.info("Process Background Images ...");

		// Parcours de tous les objets de chaque Game Mode
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			logger.debug("\tGame Mode: "+gameMode.getKey());
			processBackgroundImages(gameMode.getValue());
		}
	}
	
	private static void processBackgroundImages(GameMode gameMode) throws Exception {
		Act act = gameMode.acts.get(gameMode.actBoot);

		if (act != null && act.bgFileName != null) {
			logger.debug("\t\tBackground Image: "+act.bgFileName);			
			String[] data = act.bgFileName.split(",");		
			if (!Game.allBackgroundImages.containsKey(data[0])) {
				//PngToBottomUpB16Bin img = new PngToBottomUpB16Bin(data[0], act);
				PngToBottomUpB16Bin img = new PngToBottomUpB16Bin(data[0], act);
				
				if ((data.length > 1 && data[1].equalsIgnoreCase(BuildDisk.RAM)?true:false))
					img.inRAM = true;			
			
				gameMode.backgroundImages.put(act, img);
				Game.allBackgroundImages.put(img.file, img);
			} else {
				gameMode.backgroundImages.put(act, Game.allBackgroundImages.get(data[0]));
			}
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private static void generateSprites() throws Exception {
		logger.info("Generate Sprites ...");

		// Génération des sprites compilés pour chaque objet
		// -------------------------------------------------

		// Parcours de tous les objets de manière unitaire
		for (Entry<String, Object> object : Game.allObjects.entrySet()) {
				generateSprites(object.getValue());
		}
	}
	
	private static void generateSprites(Object object) throws Exception {
		AssemblyGenerator asm;
		Encoder easm;

		// génération du sprite compilé
		SubSprite curSubSprite;	
		String associatedIdx = null;
		BufferedImage imgCumulative = null;
		
		// Parcours des images de l'objet et compilation de l'image
		AsmSourceCode asmImgIndex = new AsmSourceCode(createFile(object.imageSet.fileName, object.name));
		for (Entry<String, String[]> spriteProperties : object.spritesProperties.entrySet()) {

			Sprite sprite = new Sprite(spriteProperties.getKey());
			sprite.spriteFile = spriteProperties.getValue()[0].split(",")[0];
			String spriteFileRef = (spriteProperties.getValue()[0].split(",").length>1?spriteProperties.getValue()[0].split(",")[1]:null);
			sprite.associatedIdx = (spriteProperties.getValue()[0].split(",").length>2?(spriteProperties.getValue()[0].split(",")[2].equals("")?null:spriteProperties.getValue()[0].split(",")[2]):null);
			boolean interlaced = (spriteProperties.getValue()[0].split(",").length>3?(spriteProperties.getValue()[0].split(",")[3].equals("_full")?false:true):true);			
			String[] spriteVariants = spriteProperties.getValue()[1].split(",");
			if (spriteProperties.getValue().length > 2 && spriteProperties.getValue()[2].equalsIgnoreCase(BuildDisk.RAM))
				sprite.inRAM = true;					

			// Parcours des différents rendus demandés pour chaque image
			for (String cur_variant : spriteVariants) {
				logger.debug("\t"+object.name+" Compile sprite: " + sprite.name + " image:" + sprite.spriteFile + " variant:" + cur_variant);

				// Sauvegarde du code généré pour la variante
				curSubSprite = new SubSprite(sprite);
				curSubSprite.setName(cur_variant);
				
				if (cur_variant.contains("B")) {
					logger.debug("\t\t- BackupBackground/Draw/Erase");
					SpriteSheet ss = new SpriteSheet(sprite, associatedIdx, imgCumulative, 1, 1, 1, cur_variant, interlaced);
					asm = new AssemblyGenerator(ss, Game.generatedCodeDirName + object.name, 0);
					asm.compileCode("A000");
					// La valeur 64 doit être ajustée dans MainEngine.asm si modifiée TODO : rendre paramétrable
					// 16 octets supplémentaires pour IRQ 12 octets du bckp registres et 4 pour les appels sous programmes
					// A rendre paramétrable aussi
					curSubSprite.nb_cell = (asm.getEraseDataSize() + 16 + 64 - 1) / 64;
					curSubSprite.x1_offset = asm.getX1_offset();
					curSubSprite.y1_offset = asm.getY1_offset();
					curSubSprite.x_size = asm.getX_size();
					curSubSprite.y_size = asm.getY_size();
					curSubSprite.center_offset = ss.center_offset;

					curSubSprite.draw = new SubSpriteBin(curSubSprite);
					curSubSprite.draw.setName(cur_variant);
					curSubSprite.draw.bin = Files.readAllBytes(Paths.get(asm.getBckDrawBINFile()));
					curSubSprite.draw.uncompressedSize = asm.getDSize();
					curSubSprite.draw.inRAM = sprite.inRAM;
					object.subSpritesBin.add(curSubSprite.draw);

					curSubSprite.erase = new SubSpriteBin(curSubSprite);
					curSubSprite.erase.setName(cur_variant+" E");
					curSubSprite.erase.bin = Files.readAllBytes(Paths.get(asm.getEraseBINFile()));
					curSubSprite.erase.uncompressedSize = asm.getESize();
					curSubSprite.erase.inRAM = sprite.inRAM;							
					object.subSpritesBin.add(curSubSprite.erase);
				}
				
				if (cur_variant.contains("D")) {
					SpriteSheet ss;
					if (cur_variant.contains("DMAP")) {
						logger.debug("\t\t- Draw MAP RLE");
						cur_variant = cur_variant.replace("DMAP", "D");						
						ss = new SpriteSheet(sprite, associatedIdx, imgCumulative, 1, 1, 1, cur_variant, interlaced, spriteFileRef);
						easm = new MapRleEncoder(ss, Game.generatedCodeDirName + object.name, 0);

					} else if (cur_variant.contains("DZX0")) {
						logger.debug("\t\t- Draw ZX0");
						cur_variant = cur_variant.replace("DZX0", "D");						
						ss = new SpriteSheet(sprite, associatedIdx, imgCumulative, 1, 1, 1, cur_variant, interlaced, spriteFileRef);
						easm = new ZX0Encoder(ss, Game.generatedCodeDirName + object.name, 0);

					} else {
						logger.debug("\t\t- Draw");
						ss = new SpriteSheet(sprite, associatedIdx, imgCumulative, 1, 1, 1, cur_variant, interlaced, spriteFileRef);
						easm = new SimpleAssemblyGenerator(ss, Game.generatedCodeDirName + object.name, 0, SimpleAssemblyGenerator._NO_ALPHA);
					}
					easm.compileCode("A000");
					curSubSprite.nb_cell = 0;
					curSubSprite.x1_offset = easm.getX1_offset();
					curSubSprite.y1_offset = easm.getY1_offset();
					curSubSprite.x_size = easm.getX_size();
					curSubSprite.y_size = easm.getY_size();
					curSubSprite.center_offset = ss.center_offset;							

					curSubSprite.draw = new SubSpriteBin(curSubSprite);
					curSubSprite.draw.setName(cur_variant);
					curSubSprite.draw.bin = Files.readAllBytes(Paths.get(easm.getDrawBINFile()));
					curSubSprite.draw.uncompressedSize = easm.getDSize();
					curSubSprite.draw.inRAM = sprite.inRAM;							
					object.subSpritesBin.add(curSubSprite.draw);					
				}
				sprite.subSprites.put(cur_variant, curSubSprite);
			}

			// Sauvegarde de tous les rendus demandés pour l'image en cours
			object.sprites.put(sprite.name, sprite);
			object.imageSet.uncompressedSize += writeImgIndex(asmImgIndex, null, sprite, UNDEFINED);
			associatedIdx = sprite.associatedIdx;
			imgCumulative = sprite.imgCumulative;
		}
		
		object.imageSet.bin = new byte[object.imageSet.uncompressedSize];
		AsmSourceCode asmAniIndex = new AsmSourceCode(createFile(object.animation.fileName, object.name));
		object.animation.uncompressedSize += writeAniIndex(asmAniIndex, object);
		object.animation.bin = new byte[object.animation.uncompressedSize];
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private static void generateTilesets() throws Exception {
		logger.info("Generate Tilesets ...");

		// Génération des tilesets pour chaque objet
		// -------------------------------------------------

		// Parcours de tous les objets de manière unitaire
		for (Entry<String, Object> object : Game.allObjects.entrySet()) {
			generateTilesets(object.getValue());
		}
	}
	
	private static void generateTilesets(Object object) throws Exception {
		SimpleAssemblyGenerator sasm;	
		
		// Parcours des tileset de l'objet et compilation des images de tiles
		for (Entry<String, String[]> tilesetProperties : object.tilesetsProperties.entrySet()) {

			Tileset tileset = new Tileset(tilesetProperties.getKey());
			tileset.fileName = tilesetProperties.getValue()[0];
			tileset.nbTiles = Integer.parseInt(tilesetProperties.getValue()[1].split(",")[0]);
			tileset.nbColumns = Integer.parseInt(tilesetProperties.getValue()[1].split(",")[1]);
			tileset.nbRows = Integer.parseInt(tilesetProperties.getValue()[1].split(",")[2]);

			//if (tilesetProperties.getValue().length > 2 && tilesetProperties.getValue()[2].equalsIgnoreCase(BuildDisk.RAM))
			// tileset should always be in RAM for rendering speed
			tileset.inRAM = true;					

			// Parcours des différents tiles du tileset
			logger.debug("\t"+object.name+" tileset: " + tileset.name);
			SpriteSheet ss = new SpriteSheet(tileset.name, tileset.fileName, tileset.nbTiles, tileset.nbColumns, tileset.nbRows);
			int tileId;
			for (tileId = 0; tileId < tileset.nbTiles; tileId++) {
				logger.debug("\t\t"+object.name+" Compile tile: " + tileId);

					// search for an identical tile
					boolean isSame = false;
					int s;
					
					for (s = 0; s < tileId; s++) {
						isSame = true;
						if ((ss.getSubImagePixels(tileId, 0).length != tileset.tiles.get(s).pixels0.length) ||
							(ss.getSubImagePixels(tileId, 1).length != tileset.tiles.get(s).pixels1.length)){
							isSame = false;
						} else {
							for (int b = 0; b < ss.getSubImagePixels(tileId, 0).length; b++) {
								if ((ss.getSubImagePixels(tileId, 0)[b] != tileset.tiles.get(s).pixels0[b]) ||
									(ss.getSubImagePixels(tileId, 1)[b] != tileset.tiles.get(s).pixels1[b])){
									isSame = false;
									break;
								}
							}
						}
						if (isSame) {
							break;
						}
					}
					
					if (isSame) {
						// for this tile index, use an identical tile
						// at index construction, the same page/addr will be referenced
						// tile will not be added to object thus no duplicate compilated sprite							
						tileset.tiles.add(tileset.tiles.get(s));	
						logger.info("Found duplicate tile for index: "+tileId+", will use index: "+s);
//						logger.debug("Tile: "+tileId);
//						logger.debug(SimpleAssemblyGenerator.debug80Col(ss.getSubImagePixels(tileId, 0)));
//						logger.debug("Index: "+s);
//						logger.debug(SimpleAssemblyGenerator.debug80Col(tileset.tiles.get(s).pixels));						
						
					} else {
						sasm = new SimpleAssemblyGenerator(ss, Game.generatedCodeDirName + object.name, tileId, SimpleAssemblyGenerator._ODD_ALPHA);
						sasm.compileCode("A000");						

						TileBin tileBin = new TileBin(tileset);
						tileBin.setName(tileset.name + "-" + tileId);
						tileBin.bin = Files.readAllBytes(Paths.get(sasm.getDrawBINFile()));
						tileBin.uncompressedSize = sasm.getDSize();
						tileBin.inRAM = tileset.inRAM;
						tileBin.pixels0 = ss.getSubImagePixels(tileId, 0);						
						tileBin.pixels1 = ss.getSubImagePixels(tileId, 1);
						tileset.tiles.add(tileBin);
						object.tilesBin.add(tileBin);
					}
			}

			object.tilesets.put(tileset.name, tileset);
			dynamicContentFD.set(tileset.name, "index", tileId*3);
			dynamicContentT2.set(tileset.name, "index", tileId*3);
		}
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private static void compileMainEngines(boolean writeIdx) throws Throwable {
		logger.info("Compile Main Engines ...");
		if (!abortFloppyDisk) {	
			compileMainEngines(FLOPPY_DISK, writeIdx);
		}
		compileMainEngines(MEGAROM_T2, writeIdx);
	}
	
	private static void compileMainEngines(int mode, boolean writeIdx) throws Throwable {
		logger.info("Compile Main Engines for " + MODE_LABEL[mode] + "...");
		
		for(Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			logger.debug("\tGame Mode : " + gameMode.getKey());
			
			String prepend = "\tINCLUDE \"" + Game.generatedCodeDirName + gameMode.getKey() + "/" + FileNames.OBJECTID+"\"\n";
			prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + FileNames.GAME_GLOBALS + "\"\n";			
			String mainEngineTmpFile = duplicateFilePrepend(gameMode.getValue().engineAsmMainEngine, gameMode.getKey()+"/"+MODE_DIR[mode]+"/", prepend);
			AsmSourceCode asmBuilder = new AsmSourceCode(createFile(FileNames.MAIN_GENCODE, gameMode.getValue().name));			
			
			writePalIndex(asmBuilder, gameMode.getValue());
			writeObjIndex(asmBuilder, gameMode.getValue(), mode);
			writeSndIndex(asmBuilder, gameMode.getValue(), mode);
			writeImgPgIndex(asmBuilder, gameMode.getValue(), mode);
			writeAniPgIndex(asmBuilder, gameMode.getValue(), mode);
			writeAniAsdIndex(asmBuilder, gameMode.getValue(), mode);
			writeBackgroundImageIndex(asmBuilder, gameMode.getValue(), mode);			
			writeLoadActIndex(asmBuilder, gameMode.getValue());
			
			Files.write(Paths.get(mainEngineTmpFile), ("\tINCLUDE \"" + Game.generatedCodeDirName + gameMode.getKey() + "/" + FileNames.MAIN_GENCODE + "\"\n").getBytes(), StandardOpenOption.APPEND);
			
			compileRAW(mainEngineTmpFile, mode, gameMode.getValue(), 1);
			byte[] binBytes = Files.readAllBytes(Paths.get(getBINFileName(mainEngineTmpFile)));

			if (binBytes.length > RamImage.PAGE_SIZE) {
				throw new Exception("file " + gameMode.getValue().engineAsmMainEngine + " is too large:" + binBytes.length + " bytes (max:"+RamImage.PAGE_SIZE+")");
			} else {
				logger.info("bin length: " + binBytes.length);
			}
			
			// Le MainEngine est de taille constante, pas besoin de demultiplier pour FD/T2
			gameMode.getValue().code = new ObjectBin();
			gameMode.getValue().code.bin = binBytes;
			RAMLoaderIndex rli = new RAMLoaderIndex();
			rli.ram_page = 1;
			rli.ram_address = 0x0100;
			rli.ram_endAddress = 0x0100 + binBytes.length;
			
			if (rli.ram_endAddress >= 0x4000) {
				throw new Exception ("game-mode binary should be 16128 bytes max ($6100-$9FFF).");
			}			
			
			rli.split = false; // la page 1 n'est pas utilsée en zone cartouche
			rli.gml.add(gameMode.getValue());
			
			// Dans le cas d'une seconde passe on maj les données
			if (gameMode.getValue().code.dataIndex.get(gameMode.getValue()) == null) {
				gameMode.getValue().code.dataIndex.put(gameMode.getValue(), new DataIndex());
			}
			
			if (mode == FLOPPY_DISK) {
				gameMode.getValue().code.dataIndex.get(gameMode.getValue()).fd_ram_page = rli.ram_page;
				gameMode.getValue().code.dataIndex.get(gameMode.getValue()).fd_ram_address = rli.ram_address;
				gameMode.getValue().code.dataIndex.get(gameMode.getValue()).fd_ram_endAddress = rli.ram_endAddress;
				gameMode.getValue().ramFD.setData(rli.ram_page, rli.ram_address, binBytes);
				if (writeIdx) {
					gameMode.getValue().fdIdx.add(rli); // Seconde passe
				}
			} else {
				gameMode.getValue().code.dataIndex.get(gameMode.getValue()).t2_ram_page = rli.ram_page;
				gameMode.getValue().code.dataIndex.get(gameMode.getValue()).t2_ram_address = rli.ram_address;		
				gameMode.getValue().code.dataIndex.get(gameMode.getValue()).t2_ram_endAddress = rli.ram_endAddress;
				gameMode.getValue().ramT2.setData(rli.ram_page, rli.ram_address, binBytes);
				if (writeIdx) {				
					gameMode.getValue().t2Idx.add(rli); // Seconde passe
				}
			}
		}
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void writePalIndex(AsmSourceCode asmBuilder, GameMode gameMode) throws Throwable {
		for (Entry<String, Palette> palette : gameMode.palettes.entrySet()) {
			asmBuilder.addLabel(palette.getValue().name);
			asmBuilder.add(PaletteTO8.getPaletteData(palette.getValue().fileName));
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void writeLoadActIndex(AsmSourceCode asmBuilder, GameMode gameMode) throws Throwable {
		asmBuilder.add("LoadAct");
		
		if (gameMode.actBoot != null) {
			Act act = gameMode.acts.get(gameMode.actBoot);

			if (act != null) {
				
				if (act.bgColorIndex != null || act.bgFileName != null) {
					asmBuilder.add("        ldb   #$02                     * load page 2");						
					asmBuilder.add("        stb   $E7E5                    * in data space ($A000-$DFFF)");
				}
				
				if (act.bgColorIndex != null) {
					asmBuilder.add("        ldx   #"+String.format("$%1$01X%1$01X%1$01X%1$01X", Integer.parseInt(act.bgColorIndex))+"                   * set Background solid color");
					asmBuilder.add("        jsr   ClearDataMem");
				}					
				
				if (act.bgFileName != null) {
					asmBuilder.add("        ldx   #Bgi_"+act.name);
					asmBuilder.add("        jsr   DrawFullscreenImage");
				}				

				if (act.screenBorder != null) {
					asmBuilder.add("        lda   $E7DD                    * set border color");
					asmBuilder.add("        anda  #$F0");
					asmBuilder.add("        adda  #"+String.format("$%1$02X", Integer.parseInt(act.screenBorder))+"                     * color ref");
					asmBuilder.add("        sta   $E7DD");
					asmBuilder.add("        anda  #$0F");
					asmBuilder.add("        adda  #$80");
					asmBuilder.add("        sta   glb_screen_border_color+1    * maj WaitVBL");
				}

				if (act.bgColorIndex != null || act.bgFileName != null) {
					asmBuilder.add("        jsr   WaitVBL");						
					asmBuilder.add("        ldb   #$03                     * load page 3");						
					asmBuilder.add("        stb   $E7E5                    * data space ($A000-$DFFF)");
				}
				
				if (act.bgColorIndex != null) {
					asmBuilder.add("        ldx   #"+String.format("$%1$01X%1$01X%1$01X%1$01X", Integer.parseInt(act.bgColorIndex))+"                   * set Background solid color");					
					asmBuilder.add("        jsr   ClearDataMem");						
				}

				if (act.bgFileName != null) {
					asmBuilder.add("        ldx   #Bgi_"+act.name);
					asmBuilder.add("        jsr   DrawFullscreenImage");
				}
				
				if (act.paletteName != null) {
					asmBuilder.add("        ldd   #" + act.paletteName);
					asmBuilder.add("        std   Cur_palette");
					asmBuilder.add("        clr   Refresh_palette");
				}
			}
		}
		
		asmBuilder.add("        rts");
		asmBuilder.flush();
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void compileObjects() throws Exception {
		logger.info("Compile Objects ...");
		
		// Parcours de tous les objets de chaque Game Mode
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			
			logger.info("\t"+gameMode.getKey()+":");
			
			// Game Mode Common
			for (GameModeCommon common : gameMode.getValue().gameModeCommon) {
				if (common != null) {
					for (Entry<String, Object> object : common.objects.entrySet()) {
						compileObject(gameMode.getValue(), object.getValue(), 0);
					}
				}
			}
						
			for (Entry<String, Object> object : gameMode.getValue().objects.entrySet()) {
				compileObject(gameMode.getValue(), object.getValue(), 0);
			}		
		}		
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void compileObject(GameMode gm, Object obj, int org) throws Exception {
		logger.info("\t\t"+obj.name+" at "+String.format("$%1$04X", org));
		
		String objectCodeTmpFile, prepend;
		String imgSetDir = gm.name + "/"+MODE_DIR[UNDEFINED]+"/" + obj.name;
		String aniDir = gm.name + "/"+MODE_DIR[UNDEFINED]+"/" + obj.name;
		
		// Compilation de l'index image pour etiquettes 
		if (obj.imageSet.uncompressedSize > 0) {
			prepend = "\torg   $A000\n"; // dummy
			prepend += "\tsetdp $FF\n";
			objectCodeTmpFile = duplicateFilePrepend(Game.generatedCodeDirName + obj.name + "/" + obj.imageSet.fileName, imgSetDir + "/", prepend);
			compileRAW(objectCodeTmpFile, UNDEFINED);
			obj.imageSet.bin = Files.readAllBytes(Paths.get(getBINFileName(objectCodeTmpFile)));
			obj.imageSet.uncompressedSize = obj.imageSet.bin.length;
		}		
		
		// Compilation de l'index animation pour etiquettes 
		if (obj.animation.uncompressedSize > 0) {
			prepend = "\tINCLUDE \"" + Game.constAnim+"\"\n";
			prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + aniDir + "/" + FileUtil.removeExtension(obj.imageSet.fileName)+".glb" + "\"\n";
			prepend += "\torg   $A000\n"; // dummy
			prepend += "\tsetdp $FF\n";
			objectCodeTmpFile = duplicateFilePrepend(Game.generatedCodeDirName + obj.name + "/" + obj.animation.fileName, aniDir + "/", prepend);
			compileRAW(objectCodeTmpFile, UNDEFINED);
			obj.animation.bin = Files.readAllBytes(Paths.get(getBINFileName(objectCodeTmpFile)));
			obj.animation.uncompressedSize = obj.animation.bin.length;
		}			
		
		// Compilation de l'objet
		prepend = "\topt   c,ct\n";
		Path p = Paths.get(gm.engineAsmMainEngine);
		String asmFileName = p.getFileName().toString();		
		prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + gm.name+ "/" + MODE_DIR[UNDEFINED] + "/" + FileUtil.removeExtension(asmFileName)+".glb" +"\"\n";		

		if (obj.imageSet.uncompressedSize > 0 && obj.animation.uncompressedSize == 0) {
			prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + imgSetDir + "/" + FileUtil.removeExtension(obj.imageSet.fileName)+".glb" + "\"\n";
		}
		
		if (obj.animation.uncompressedSize > 0) {
			prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + aniDir + "/" + FileUtil.removeExtension(obj.animation.fileName)+".glb" + "\"\n";
		}
		
		prepend += "\torg   " + String.format("$%1$04X", org) + "\n";
		prepend += "\tsetdp $FF\n";
		objectCodeTmpFile = duplicateFilePrepend(obj.codeFileName, imgSetDir, prepend);
		compileRAW(objectCodeTmpFile, UNDEFINED);
		obj.gmCode.get(gm).code.bin = Files.readAllBytes(Paths.get(getBINFileName(objectCodeTmpFile)));
		obj.gmCode.get(gm).code.uncompressedSize = obj.gmCode.get(gm).code.bin.length;
		logger.debug("file " + objectCodeTmpFile + " intermediate size:" + obj.gmCode.get(gm).code.uncompressedSize + " bytes");
		
		if (obj.gmCode.get(gm).code.uncompressedSize > RamImage.PAGE_SIZE) {
			throw new Exception("file " + objectCodeTmpFile + " is too large:" + obj.gmCode.get(gm).code.uncompressedSize + " bytes (max:" + RamImage.PAGE_SIZE + ")");
		}
	}		
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void computeRamAddress() throws Exception {
		
		logger.debug("computeRamAddress ...");
		
		// La taille des index fichier du RAMLoader dépend du nombre de pages utilisées par chaque Game Loader
		// première passe de sac a dos pour determiner le nombre de pages necessaires pour chaque Game Mode
		int initStartPage = 4;
		int INDEX_STRUCT_SIZE_FD = 7;
		int INDEX_STRUCT_SIZE_T2 = 6;
		int totalIndexSizeFD = 0;
		int totalIndexSizeT2 = 0;		
		
		// Au runtime on a le game mode courant (celui chargé en RAM) et le prochain game Mode
		// Au moment du chargement une comparaison est effectuée entre chaque ligne de l'index fichier
		// si ligne identique : pas de chargement de la ligne (a faire jusqu'a la fin de l'index)
		// Necessite de trier les lignes d'index fichier pour pouvoir faire une comparaison sans tout parcourir
		// et de positionner les communs en début d'index
		GameMode gm;
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			gm = gameMode.getValue();
			logger.debug("\tGame Mode : " + gm.name);
		
			gm.ramFD.curPage = initStartPage;
			gm.indexSizeFD = 0;

			// Calcul de la taille d'index fichier pour les Communs du game Mode (Disquette)
			for (GameModeCommon common : gm.gameModeCommon) {
				if (common != null) {
					if (!abortFloppyDisk) {
						logger.debug("\t\tCommon : " + common.name);
						common.items = getRAMItems(gm, common.objects, FLOPPY_DISK, GAMEMODE_COMMON);
						gm.indexSizeFD += computeItemsRamAddress(gm, common, common.items, gm.ramFD, false);
						if (gm.ramFD.isOutOfMemory())
							abortFloppyDisk = true;
					}
				}
			}
			
			// Calcul de la taille d'index fichier pour le Game Mode (Disquette)
			if (!abortFloppyDisk) {
				gm.items = getRAMItems(gm, gm.objects, FLOPPY_DISK, GAMEMODE);
				gm.items = addCommonObjectCodeToRAMItems(gm.items, gm, FLOPPY_DISK);
				gm.indexSizeFD += computeItemsRamAddress(gm, null, gm.items, gm.ramFD, false);
				if (gm.ramFD.isOutOfMemory())
					abortFloppyDisk = true;
			}
			
			gm.indexSizeFD += 4; // index supplémentaire pour ajustement avec RAM Loader Manager et MaineEngine
			gm.indexSizeFD *= INDEX_STRUCT_SIZE_FD;
			gm.indexSizeFD += 2+1; // index + fin
			totalIndexSizeFD += gm.indexSizeFD;			
			logger.debug("\t\tindex size FD: "+gm.indexSizeFD);
			
			gm.ramT2.curPage = initStartPage;
			gm.indexSizeT2 = 0;
			
			// Calcul de la taille d'index fichier pour les Communs du game Mode (T.2)
			for (GameModeCommon common : gm.gameModeCommon) {
				if (common != null) {
					if (!abortT2) {
						logger.debug("\t\tCommon : " + common.name);
						common.items = getRAMItems(gm, common.objects, MEGAROM_T2, GAMEMODE_COMMON);
						gm.indexSizeT2 += computeItemsRamAddress(gm, common, common.items, gm.ramT2, false);
						if (gm.ramT2.isOutOfMemory())
							abortT2 = true;
					}
				}
			}			
			
			// Calcul de la taille d'index fichier pour le Game Mode (T.2)
			if (!abortT2) {
				gm.items = getRAMItems(gm, gm.objects, MEGAROM_T2, GAMEMODE);
				gm.items = addCommonObjectCodeToRAMItems(gm.items, gm, MEGAROM_T2);
				gm.indexSizeT2 += computeItemsRamAddress(gm, null, gm.items, gm.ramT2, false); 
				if (gm.ramT2.isOutOfMemory())
					abortT2 = true;
			}
			
			gm.indexSizeT2 += 4; // index supplémentaire pour ajustement avec RAM Loader Manager et MainEngine		
			gm.indexSizeT2 *= INDEX_STRUCT_SIZE_T2;
			gm.indexSizeT2 += 2+1; // index + fin
			totalIndexSizeT2 += gm.indexSizeT2;
			logger.debug("\t\tindex size T2: "+gm.indexSizeT2);
		}

		if (abortFloppyDisk && abortT2) {
			throw new Exception("Not enough RAM !");
		}
		
		// Positionnement des adresses de départ du code en RAM
		// calcul de la taille des index fichier de RAMLoader/RAMLoaderManager
		Game.loadManagerSizeFd = getRAMLoaderManagerSizeFd();
		Game.loadManagerSizeFd += totalIndexSizeFD;
		
		Game.loadManagerSizeT2 = getRAMLoaderManagerSizeT2();		
		Game.loadManagerSizeT2 += totalIndexSizeT2;
		
		logger.debug("\t\tinitStartAddressFD: "+Game.loadManagerSizeFd);
		logger.debug("\t\tinitStartAddressT2: "+Game.loadManagerSizeT2);
		
		logger.debug("\n\ncompute ram position ... ");
		logger.debug("--------------------------------------------------------------------------------");		
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			gm = gameMode.getValue();
			logger.debug("\n\n\tGame Mode : " + gm.name);
			logger.debug("-----------------------------");

			if (!abortFloppyDisk) {
				gm.ramFD.curPage = initStartPage;
				gm.ramFD.curAddress = Game.loadManagerSizeFd;

				for (GameModeCommon common : gm.gameModeCommon) {
					if (common != null) {
						logger.debug("\t\tCommon : " + common.name);
						common.items = getRAMItems(gm, common.objects, FLOPPY_DISK, GAMEMODE_COMMON);
						computeItemsRamAddress(gm, common, common.items, gm.ramFD, true);
					}
				}
				gm.items = getRAMItems(gm, gm.objects, FLOPPY_DISK, GAMEMODE);
				gm.items = addCommonObjectCodeToRAMItems(gm.items, gm, FLOPPY_DISK);
				computeItemsRamAddress(gm, null, gm.items, gm.ramFD, true);
			}
			
			if (!abortT2) {
				gm.ramT2.curPage = initStartPage;
				gm.ramT2.curAddress = Game.loadManagerSizeT2;

				for (GameModeCommon common : gm.gameModeCommon) {
					if (common != null) {
						logger.debug("\t\tCommon : " + common.name);
						common.items = getRAMItems(gm, common.objects, MEGAROM_T2, GAMEMODE_COMMON);
						computeItemsRamAddress(gm, common, common.items, gm.ramT2, true);
					}
				}
				gm.items = getRAMItems(gm, gm.objects, MEGAROM_T2, GAMEMODE);
				gm.items = addCommonObjectCodeToRAMItems(gm.items, gm, MEGAROM_T2);
				computeItemsRamAddress(gm, null, gm.items, gm.ramT2, true);
			}
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static Item[] getRAMItems(GameMode gm, HashMap<String, Object> objects, int mode, boolean isCommon) {
		logger.debug("\t\tCompute " + (isCommon?"Common":"") + " RAM Items for " + MODE_LABEL[mode] + " ...");

		// Répartition des données en RAM
		// -----------------------------------------------

		// mode FLOPPY : Toutes les données sont chargées en RAM
		// mode T.2 : Seul code/sprite/animation/sound des objets qui ont le flag RAM
		// sont chargés en RAM
		// Deux raison pour charger des données en RAM avec la T.2 :
		// - dans le cas d'un code avec auto modification, ou présence de données
		// - dans le cas ou l'on souhaite gagner de la place sur la T.2
		// les données sont alors compressées sur T.2 et décompressées en RAM au runtime

		// Gestion d'un game mode "commun" (un seul par Game Mode)
		// Au runtime, si le commun nécessaire au nouveau Game Mode est déjà présent, on
		// ne le recharge pas.

		// Compte le nombre d'objets a traiter
		int nbGameModeItems = 0;
		
		for (Entry<Act, PngToBottomUpB16Bin> bi : gm.backgroundImages.entrySet()) { 
			if (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && bi.getValue().inRAM))
				nbGameModeItems++;
		}
		
		for (Entry<String, Object> object : objects.entrySet()) {

			// Sprites
			for (SubSpriteBin subSprite : object.getValue().subSpritesBin)
				if (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && subSprite.inRAM))
					nbGameModeItems ++;

			// ImageSet Index
			if (object.getValue().subSpritesBin.size() > 0
					&& (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && object.getValue().imageSetInRAM)))
				nbGameModeItems++;

			// Animation Index
			if (!object.getValue().animationsProperties.isEmpty()
					&& (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && object.getValue().animationInRAM)))
				nbGameModeItems++;
			
			// TileSets
			for (TileBin tile : object.getValue().tilesBin)
				if (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && tile.inRAM))
					nbGameModeItems ++;			

			// Sounds
			for (Sound sound : object.getValue().sounds)
				for (SoundBin soundBIN : sound.sb)
					if (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && soundBIN.inRAM))
						nbGameModeItems++;

			// Object Code
			if (!isCommon)
				nbGameModeItems++;
		}

		// Initialise un item pour chaque élément a écrire en RAM
		Item[] items = new Item[nbGameModeItems];
		int itemIdx = 0;

		for (Entry<Act, PngToBottomUpB16Bin> bi : gm.backgroundImages.entrySet()) { 
			if (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && bi.getValue().inRAM))
				items[itemIdx++] = new Item(bi.getValue(), 1);
		}		
		
		// Initialisation des items
		for (Entry<String, Object> object : objects.entrySet()) {

			// Sprites
			for (SubSpriteBin subSprite : object.getValue().subSpritesBin)
				if (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && subSprite.inRAM))
					items[itemIdx++] = new Item(subSprite, 1);

			// ImageSet Index
			if (object.getValue().subSpritesBin.size() > 0
					&& (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && object.getValue().imageSetInRAM)))
				items[itemIdx++] = new Item(object.getValue().imageSet, 1);

			// Animation Index
			if (!object.getValue().animationsProperties.isEmpty()
					&& (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && object.getValue().animationInRAM)))
				items[itemIdx++] = new Item(object.getValue().animation, 1);
			
			// TileSets
			for (TileBin tile : object.getValue().tilesBin)
				if (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && tile.inRAM))
					items[itemIdx++] = new Item(tile, 1);			

			// Sounds
			for (Sound sound : object.getValue().sounds)
				for (SoundBin soundBIN : sound.sb)
					if (mode == FLOPPY_DISK || (mode == MEGAROM_T2 && soundBIN.inRAM))
						items[itemIdx++] = new Item(soundBIN, 1);

			// Object Code
			if (!isCommon) {
				Item obj = new Item(object.getValue().gmCode.get(gm).code, 1);
				items[itemIdx++] = obj;	
			}
		}

		return items;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static Item[] addCommonObjectCodeToRAMItems(Item[] items, GameMode gm, int mode) {
		logger.debug("\t\tAdd common ObjectCode to GameMode RAM Items for " + MODE_LABEL[mode] + " ...");
		int nbGameModeItems = 0;
		Item[] newItems;

		// Un code objet ne peut pas être commun, il est spécifique à un GameMode MainEngine
		// On l'extrait donc des ressources communes pour l'ajouter au GameMode

		// Compte le nombre d'objets a traiter
		for (GameModeCommon common : gm.gameModeCommon) {
			if (common != null) {
				for (Entry<String, Object> object : common.objects.entrySet()) {

					// Ajoute les items du commun de type code objet
					nbGameModeItems++;
				}
			}
		}

		// Copie les items du Game Mode dans le nouveau tableau
		int i;
		newItems = new Item[items.length + nbGameModeItems];
		for (i = 0; i < items.length; i++) {
			newItems[i] = items[i];
		}

		for (GameModeCommon common : gm.gameModeCommon) {
			if (common != null) {
				for (Entry<String, Object> object : common.objects.entrySet()) {
					
					// Ajoute les items du commun de type code objet
					Item obj = new Item(object.getValue().gmCode.get(gm).code, 1);
					newItems[i++] = obj;
				}
			}
		}

		return newItems;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static int computeItemsRamAddress(GameMode gm, GameModeCommon gmc, Item[] items, RamImage rImg, boolean writeIndex) throws Exception {
		boolean firstLoop = true;
		int nbHalfPages = 0;

		if (items.length > 0) {
			rImg.startAddress[rImg.curPage] = rImg.curAddress;
			rImg.endAddress[rImg.curPage] = rImg.curAddress;
		}
		
		while (items.length > 0) {

			if (!firstLoop) {
				rImg.curPage++;
				if (rImg.isOutOfMemory()) {
					logger.fatal("C'est un peu trop ambitieux ... plus de place en RAM !");
					return 0;
				}
				rImg.startAddress[rImg.curPage] = 0;
				rImg.endAddress[rImg.curPage] = 0;
			}
			
			// les données sont réparties en pages en fonction de leur taille par un
			// algorithme "sac à dos"
			Knapsack knapsack = new Knapsack(items, RamImage.PAGE_SIZE-rImg.startAddress[rImg.curPage]); // Sac à dos de poids max 16Ko
			Solution solution = knapsack.solve();

			// Parcours de la solution
			for (Iterator<Item> iter = solution.items.listIterator(); iter.hasNext();) {

				Item currentItem = iter.next();
				
				if (writeIndex) {
					if (currentItem.bin.dataIndex.get(gm) == null) {
						currentItem.bin.dataIndex.put(gm, new DataIndex());
					}
					
					if (rImg.mode == BuildDisk.FLOPPY_DISK) {
						currentItem.bin.dataIndex.get(gm).fd_ram_page = rImg.curPage;					
						currentItem.bin.dataIndex.get(gm).fd_ram_address = rImg.endAddress[rImg.curPage];
						rImg.setDataAtCurPos(currentItem.bin.bin);
						currentItem.bin.dataIndex.get(gm).fd_ram_endAddress = rImg.endAddress[rImg.curPage];
						logger.debug("\t\t\tItem: "+currentItem.name+" FD "+currentItem.bin.dataIndex.get(gm).fd_ram_page+" "+String.format("$%1$04X", currentItem.bin.dataIndex.get(gm).fd_ram_address)+" "+String.format("$%1$04X", currentItem.bin.dataIndex.get(gm).fd_ram_endAddress-1));
						
					} else if (rImg.mode == BuildDisk.MEGAROM_T2) {
						currentItem.bin.dataIndex.get(gm).t2_ram_page = rImg.curPage;					
						currentItem.bin.dataIndex.get(gm).t2_ram_address = rImg.endAddress[rImg.curPage];
						rImg.setDataAtCurPos(currentItem.bin.bin);
						currentItem.bin.dataIndex.get(gm).t2_ram_endAddress = rImg.endAddress[rImg.curPage];
						logger.debug("\t\t\tItem: "+currentItem.name+" T2 "+currentItem.bin.dataIndex.get(gm).t2_ram_page+" "+String.format("$%1$04X", currentItem.bin.dataIndex.get(gm).t2_ram_address)+" "+String.format("$%1$04X", currentItem.bin.dataIndex.get(gm).t2_ram_endAddress-1));
					}
					
				} else {
					int startAddress = rImg.curAddress;
					rImg.endAddress[rImg.curPage] += currentItem.weight;
					rImg.curAddress = rImg.endAddress[rImg.curPage] + 1;
					logger.debug("\t\t\tItem: "+currentItem.name+" "+rImg.curPage+" "+String.format("$%1$04X", startAddress)+" "+String.format("$%1$04X", rImg.curAddress-1));					
				}

				// construit la liste des éléments restants à organiser
				for (int i = 0; i < items.length; i++) {
					if (items[i].bin == currentItem.bin) {
						Item[] newItems = new Item[items.length - 1];
						for (int l = 0; l < i; l++) {
							newItems[l] = items[l];
						}
						for (int j = i; j < items.length - 1; j++) {
							newItems[j] = items[j + 1];
						}
						items = newItems;
						break;
					}
				}
			}
			
			if (rImg.startAddress[rImg.curPage] < rImg.endAddress[rImg.curPage]) {
			
				nbHalfPages += 1;
				if (rImg.startAddress[rImg.curPage] < 0x2000 && rImg.endAddress[rImg.curPage] > 0x2000)
					nbHalfPages += 1;	

				// Division de la page RAM en deux parties			
				if (writeIndex) {			
					RAMLoaderIndex rli = new RAMLoaderIndex();
					rli.gml.add(gm);
					if (gmc != null) {
						rli.gmc = gmc;
					}
					rli.ram_page = rImg.curPage;
					rli.ram_address = rImg.startAddress[rImg.curPage];
					if (rImg.startAddress[rImg.curPage] < 0x2000 && rImg.endAddress[rImg.curPage] > 0x2000) {
						rli.ram_endAddress = 0x2000;
					} else {
						rli.ram_endAddress = rImg.endAddress[rImg.curPage];
					}

					if (rImg.mode == BuildDisk.FLOPPY_DISK) {
						gm.fdIdx.add(rli);
					} else if (rImg.mode == BuildDisk.MEGAROM_T2) {
						gm.t2Idx.add(rli);				
					}

					if (rImg.startAddress[rImg.curPage] < 0x2000 && rImg.endAddress[rImg.curPage] > 0x2000) {
						rli = new RAMLoaderIndex();
						rli.gml.add(gm);
						if (gmc != null) {
							rli.gmc = gmc;
						}
						rli.ram_page = rImg.curPage;
						rli.ram_address = 0x2000;
						rli.ram_endAddress = rImg.endAddress[rImg.curPage];

						if (rImg.mode == BuildDisk.FLOPPY_DISK) {
							gm.fdIdx.add(rli);
						} else if (rImg.mode == BuildDisk.MEGAROM_T2) {
							gm.t2Idx.add(rli);	
						}			
					}

					logger.debug("\t\tFound solution for page : " + rImg.curPage + " start: " + String.format("$%1$04X", rImg.startAddress[rImg.curPage]) + " end: " + String.format("$%1$04X", rImg.endAddress[rImg.curPage]-1) + " non allocated space: " + (RamImage.PAGE_SIZE - rImg.endAddress[rImg.curPage]) + " octets");
				} else {
					logger.debug("\t\tFound solution for page : " + rImg.curPage + " start: " + String.format("$%1$04X", rImg.startAddress[rImg.curPage]) + " end: " + String.format("$%1$04X", rImg.endAddress[rImg.curPage]-1));
				}
			} else {
				logger.debug("\t\tNo solution for page : " + rImg.curPage + " start: " + String.format("$%1$04X", rImg.startAddress[rImg.curPage]));
			}
			
			firstLoop = false;
		}
		
		return nbHalfPages;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void computeRomAddress() throws Exception {
		
		logger.debug("computeRomAddress ...");
		
		game.romT2.curPage = 0;
		game.romT2.startAddress[game.romT2.curPage] = 0;
		game.romT2.endAddress[game.romT2.curPage] = Game.bootSizeT2 + Game.loadManagerSizeT2;
		
		Item[] items = getROMItems();
		computeItemsRomAddress(items, game.romT2.startAddress[game.romT2.curPage], game.romT2.endAddress[game.romT2.curPage]);
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static Item[] getROMItems() {
		logger.debug("\t\tCompute ROM Items for " + MODE_LABEL[MEGAROM_T2] + " ...");

		// Compte le nombre d'objets a traiter
		int nbItems = 0;
		
		for (Entry<String, PngToBottomUpB16Bin> bi : Game.allBackgroundImages.entrySet()) {		
			if (!bi.getValue().inRAM)
				nbItems++;
		}
		
		// Parcours unique de tous les objets
		for (Entry<String, Object> object : Game.allObjects.entrySet()) {

			// Sprites
			for (SubSpriteBin subSprite : object.getValue().subSpritesBin)
				if (!subSprite.inRAM)
					nbItems ++;

			// ImageSet Index
			if (object.getValue().subSpritesBin.size() > 0 && !object.getValue().imageSetInRAM)
				nbItems++;

			// Animation Index
			if (!object.getValue().animationsProperties.isEmpty() && !object.getValue().animationInRAM)
				nbItems++;
			
			// TileSets
			for (TileBin tile : object.getValue().tilesBin)
				if (!tile.inRAM)
					nbItems ++;					

			// Sounds
			for (Sound sound : object.getValue().sounds)
				for (SoundBin soundBIN : sound.sb)
					if (!soundBIN.inRAM)
						nbItems += 1;
		}

		// Initialise un item pour chaque élément a écrire en ROM
		Item[] items = new Item[nbItems];
		int itemIdx = 0;

		for (Entry<String, PngToBottomUpB16Bin> bi : Game.allBackgroundImages.entrySet()) {		
			if (!bi.getValue().inRAM)
				items[itemIdx++] = new Item(bi.getValue(), 1);
		}		
		
		for (Entry<String, Object> object : Game.allObjects.entrySet()) {

			// Sprites
			for (SubSpriteBin subSprite : object.getValue().subSpritesBin)
				if (!subSprite.inRAM)
					items[itemIdx++] = new Item(subSprite, 1);

			// ImageSet Index
			if (object.getValue().subSpritesBin.size() > 0 && !object.getValue().imageSetInRAM)
				items[itemIdx++] = new Item(object.getValue().imageSet, 1);

			// Animation Index
			if (!object.getValue().animationsProperties.isEmpty() && !object.getValue().animationInRAM)
				items[itemIdx++] = new Item(object.getValue().animation, 1);
			
			// Sprites
			for (TileBin tile : object.getValue().tilesBin)
				if (!tile.inRAM)
					items[itemIdx++] = new Item(tile, 1);			

			// Sounds
			for (Sound sound : object.getValue().sounds)
				for (SoundBin soundBIN : sound.sb)
					if (!soundBIN.inRAM)
						items[itemIdx++] = new Item(soundBIN, 1);
		}

		return items;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private static void computeItemsRomAddress(Item[] items, int pageStart, int pageAddress) throws Exception {
		boolean firstPass = true;
		game.romT2.curPage = pageStart;
		game.romT2.curAddress = pageAddress;
		
		// les pages rom vont de 0 à 127 mais on y accede par les index 128 à 255 (80-FF)
		// pour ne pas interférer avec les pages de RAM 0 à 31 (60-7F)
		
		while (items.length > 0) {

			if (!firstPass) {
				game.romT2.curPage++;
				game.romT2.updateEndPage();
				
				if (game.romT2.isOutOfMemory()) {
					throw new Exception("C'est un peu trop ambitieux ... 2Mo pour la T.2 et pas un octet de plus !");
				}
			}
			
			// les données sont réparties en pages en fonction de leur taille par un algorithme "sac à dos"
			Knapsack knapsack = new Knapsack(items, RamImage.PAGE_SIZE-game.romT2.endAddress[game.romT2.curPage]); // Sac à dos de poids max 16Ko
			Solution solution = knapsack.solve();

			// Parcours de la solution
			for (Iterator<Item> iter = solution.items.listIterator(); iter.hasNext();) {

				Item currentItem = iter.next();

				currentItem.bin.t2_page = game.romT2.curPage;					
				currentItem.bin.t2_address = game.romT2.endAddress[game.romT2.curPage];
				game.romT2.setDataAtCurPos(currentItem.bin.bin);
				currentItem.bin.t2_endAddress = game.romT2.endAddress[game.romT2.curPage];
				
				logger.debug("Item: "+currentItem.name+" T2 ROM "+currentItem.bin.t2_page+" "+String.format("$%1$04X", currentItem.bin.t2_address)+" "+String.format("$%1$04X", currentItem.bin.t2_endAddress-1));

				// construit la liste des éléments restants à organiser
				for (int i = 0; i < items.length; i++) {
					if (items[i].bin == currentItem.bin) {
						Item[] newItems = new Item[items.length - 1];
						for (int l = 0; l < i; l++) {
							newItems[l] = items[l];
						}
						for (int j = i; j < items.length - 1; j++) {
							newItems[j] = items[j + 1];
						}
						items = newItems;
						break;
					}
				}
			}
			
			if (game.romT2.startAddress[game.romT2.curPage] < game.romT2.endAddress[game.romT2.curPage]) {
				logger.debug("\t\tFound solution for page : " + game.romT2.curPage + " start: " + String.format("$%1$04X", game.romT2.startAddress[game.romT2.curPage]) + " end: " + String.format("$%1$04X", game.romT2.endAddress[game.romT2.curPage]-1) + " non allocated space: " + (RamImage.PAGE_SIZE - game.romT2.endAddress[game.romT2.curPage]) + " octets");
			} else {
				logger.debug("\t\tNo solution for page : " + game.romT2.curPage + " start: " + String.format("$%1$04X", game.romT2.startAddress[game.romT2.curPage]));
			}
			
			firstPass = false;
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void generateDynamicContent() throws Exception {
		logger.info("Generate dynamic content ...");
		
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			logger.debug("\nGame Mode : " + gameMode.getKey());
			GameMode gm = gameMode.getValue();
			
			// Objets Communs au Game Mode
			for (GameModeCommon common : gm.gameModeCommon) {
				if (common != null) {
					for (Entry<String, Object> object : common.objects.entrySet()) {
						generateDynamicContent(gameMode.getValue(), object.getValue());
					}
				}
			}
			
			// Objets du Game Mode
			for (Entry<String, Object> object : gm.objects.entrySet()) {
				generateDynamicContent(gameMode.getValue(), object.getValue());
			}
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void generateDynamicContent(GameMode gm, Object obj) throws Exception {

		// Generate Tileset index
		for (Entry<String, Tileset> tileset : obj.tilesets.entrySet()) {
			byte[] data;
			int i;
			
			// FLOPPY DISK
			if (!abortFloppyDisk) {
				data = new byte[tileset.getValue().tiles.size()*3];
				i = 0;
			
				for (TileBin tile : tileset.getValue().tiles) {
					data[i++] = (byte)(tile.dataIndex.get(gm).fd_ram_page + 0x60);
					data[i++] = (byte)(tile.dataIndex.get(gm).fd_ram_address >> 8);		
					data[i++] = (byte)(tile.dataIndex.get(gm).fd_ram_address & 0xFF);
				}
				dynamicContentFD.set(tileset.getValue().name, "index", data);
			}

			// MEGAROM T2
			data = new byte[tileset.getValue().tiles.size()*3];
			i = 0;
			logger.debug("TILESET: " + tileset.getValue().name);
			if (tileset.getValue().inRAM) {
				for (TileBin tile : tileset.getValue().tiles) {
					data[i++] = (byte)(tile.dataIndex.get(gm).t2_ram_page + 0x60);
					data[i++] = (byte)(tile.dataIndex.get(gm).t2_ram_address >> 8);		
					data[i++] = (byte)(tile.dataIndex.get(gm).t2_ram_address & 0xFF);	
					logger.debug("DATA: " + String.format("$%1$02X $%2$04X", data[i-3], tile.dataIndex.get(gm).t2_ram_address));
				}
			} else {
				for (TileBin tile : tileset.getValue().tiles) {
					data[i++] = (byte)(tile.t2_page + 0x80);
					data[i++] = (byte)(tile.t2_address >> 8);
					data[i++] = (byte)(tile.t2_address & 0xFF);
				}
			}
			dynamicContentT2.set(tileset.getValue().name, "index", data);			
		}

		// Place new dynamic content here
		// ...
	}	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void applyDynamicContent() throws Exception {
		logger.info("Apply dynamic content ...");
		
		for (Entry<String, String[]> tag : dynamicContentFD.tags.entrySet()) {
			if (tag.getValue()[2] != null && tag.getValue()[3] != null) { // page, address
				byte[] data = dynamicContentFD.get(tag.getValue()[0], tag.getValue()[1]); // object, method
				System.out.println("FD key: "+tag.getKey()+" Object: "+tag.getValue()[0]+" method: "+tag.getValue()[1]+" Page: "+Integer.parseInt(tag.getValue()[2])+" StartPos: "+(Integer.parseInt(tag.getValue()[3], 16)>0x4000?Integer.parseInt(tag.getValue()[3], 16)-0x6000:Integer.parseInt(tag.getValue()[3], 16)));
				dynamicContentFD.tagsGm.get(tag.getKey()).ramFD.setData(Integer.parseInt(tag.getValue()[2]), (Integer.parseInt(tag.getValue()[3], 16)>0x4000?Integer.parseInt(tag.getValue()[3], 16)-0x6000:Integer.parseInt(tag.getValue()[3], 16)), data);
			}
		}
		
		for (Entry<String, String[]> tag : dynamicContentT2.tags.entrySet()) {
			if (tag.getValue()[2] != null && tag.getValue()[3] != null) { // page, address
				byte[] data = dynamicContentT2.get(tag.getValue()[0], tag.getValue()[1]); // object, method
				System.out.println("T2 key: "+tag.getKey()+" Object: "+tag.getValue()[0]+" method: "+tag.getValue()[1]+" Page: "+Integer.parseInt(tag.getValue()[2])+" StartPos: "+(Integer.parseInt(tag.getValue()[3], 16)>0x4000?Integer.parseInt(tag.getValue()[3], 16)-0x6000:Integer.parseInt(tag.getValue()[3], 16)));				
				dynamicContentT2.tagsGm.get(tag.getKey()).ramT2.setData(Integer.parseInt(tag.getValue()[2]),  (Integer.parseInt(tag.getValue()[3], 16)>0x4000?Integer.parseInt(tag.getValue()[3], 16)-0x6000:Integer.parseInt(tag.getValue()[3], 16)), data);
			}
		}		
	
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void generateImgAniIndex() throws Exception {
		logger.info("Generate Image index and Animation script index ...");
		
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			logger.debug("\nGame Mode : " + gameMode.getKey());
			GameMode gm = gameMode.getValue();
			
			// Objets Communs au Game Mode
			for (GameModeCommon common : gm.gameModeCommon) {
				if (common != null) {
					for (Entry<String, Object> object : common.objects.entrySet()) {
						generateImgAniIndex(gameMode.getValue(), object.getValue());
					}
				}
			}
			
			// Objets du Game Mode
			for (Entry<String, Object> object : gm.objects.entrySet()) {
				generateImgAniIndex(gameMode.getValue(), object.getValue());
			}
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	
	private static void generateImgAniIndex(GameMode gm, Object obj) throws Exception {
		AsmSourceCode asmImgIndexFd;
		AsmSourceCode asmImgIndexT2;		
		
		String imgSetDirFd = gm.name + "/"+MODE_DIR[FLOPPY_DISK]+"/" + obj.name;
		String imgSetDirT2 = gm.name + "/"+MODE_DIR[MEGAROM_T2]+"/" + obj.name;
		String aniDirFd = gm.name + "/"+MODE_DIR[FLOPPY_DISK]+"/" + obj.name;
		String aniDirT2 = gm.name + "/"+MODE_DIR[MEGAROM_T2]+"/" + obj.name;
		
		
		RamImage imgSetData, aniData, codeData;
		int objCodePage, objCodeAddress;
		int imgSetPage, imgSetAddress;
		int aniPage, aniAddress;
		AsmSourceCode asmAniIndex;
		
		if (!abortFloppyDisk) {
			// Génération de l'index ImageSet pour FD	
			asmImgIndexFd = new AsmSourceCode(createFile(obj.imageSet.fileName, imgSetDirFd));
			for (Entry<String, Sprite> sprite : obj.sprites.entrySet()) {
				writeImgIndex(asmImgIndexFd, gm, sprite.getValue(), FLOPPY_DISK);
			}
			
			// Génération de l'index Animation pour FD				
			asmAniIndex = new AsmSourceCode(createFile(obj.animation.fileName, aniDirFd));
			writeAniIndex(asmAniIndex, obj);
			
			codeData = gm.ramFD;
			imgSetData = gm.ramFD;
			aniData = gm.ramFD;
			objCodePage = obj.gmCode.get(gm).code.dataIndex.get(gm).fd_ram_page;
			objCodeAddress = obj.gmCode.get(gm).code.dataIndex.get(gm).fd_ram_address;
			
			if (obj.imageSet.dataIndex.get(gm) == null) {
				obj.imageSet.dataIndex.put(gm, new DataIndex());
			}
			
			imgSetPage = obj.imageSet.dataIndex.get(gm).fd_ram_page;
			imgSetAddress = obj.imageSet.dataIndex.get(gm).fd_ram_address;
			
			if (obj.animation.dataIndex.get(gm) == null) {
				obj.animation.dataIndex.put(gm, new DataIndex());
			}		
			
			aniPage = obj.animation.dataIndex.get(gm).fd_ram_page;
			aniAddress = obj.animation.dataIndex.get(gm).fd_ram_address;		
			
			// Compilation de ImageSet, Animation, Object pour FD
			compileObjectWithImageRef(gm, obj, imgSetDirFd, aniDirFd, codeData, imgSetData, aniData, objCodePage, objCodeAddress, imgSetPage, imgSetAddress, aniPage, aniAddress, FLOPPY_DISK);
		}
		
		// Génération de l'index ImageSet pour T2
		asmImgIndexT2 = new AsmSourceCode(createFile(obj.imageSet.fileName, imgSetDirT2));
		for (Entry<String, Sprite> sprite : obj.sprites.entrySet()) {
			writeImgIndex(asmImgIndexT2, gm, sprite.getValue(), MEGAROM_T2);
		}
		
		asmAniIndex = new AsmSourceCode(createFile(obj.animation.fileName, aniDirT2));
		writeAniIndex(asmAniIndex, obj);				
		
		codeData = gm.ramT2;
		objCodePage = obj.gmCode.get(gm).code.dataIndex.get(gm).t2_ram_page;
		objCodeAddress = obj.gmCode.get(gm).code.dataIndex.get(gm).t2_ram_address;
		
		if (obj.imageSetInRAM) {
			imgSetData = gm.ramT2;
			imgSetPage = obj.imageSet.dataIndex.get(gm).t2_ram_page;
			imgSetAddress = obj.imageSet.dataIndex.get(gm).t2_ram_address;			
		} else {
			imgSetData = game.romT2;
			imgSetPage = obj.imageSet.t2_page;
			imgSetAddress = obj.imageSet.t2_address;			
		}
		
		if (obj.animationInRAM) {
			aniData = gm.ramT2;
			aniPage = obj.animation.dataIndex.get(gm).t2_ram_page;
			aniAddress = obj.animation.dataIndex.get(gm).t2_ram_address;				
		} else {
			aniData = game.romT2;
			aniPage = obj.animation.t2_page;
			aniAddress = obj.animation.t2_address;				
		}		

		compileObjectWithImageRef(gm, obj, imgSetDirT2, aniDirT2, codeData, imgSetData, aniData, objCodePage, objCodeAddress, imgSetPage, imgSetAddress, aniPage, aniAddress, MEGAROM_T2);
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	
	private static void compileObjectWithImageRef(GameMode gm, Object obj, String imgSetDir, String aniDir, RamImage codeData, RamImage imgSetData, RamImage aniData,
			                                      int objCodePage, int objCodeAddress, int imgSetPage, int imgSetAddress, int aniPage, int aniAddress, int mode) throws Exception {
		logger.info("\t\t"+obj.name+" at "+String.format("$%1$04X|$%2$02X", objCodeAddress, objCodePage)+" imageSet at "+String.format("$%1$04X|$%2$02X", imgSetAddress, imgSetPage)+" animation at "+String.format("$%1$04X|$%2$02X", aniAddress, aniPage));
		
		String objectCodeTmpFile, prepend;
		
		// Compilation de l'index image pour etiquettes 
		if (obj.imageSet.uncompressedSize > 0) {
			prepend = "\torg   $" + String.format("%1$04X", imgSetAddress) + "\n";
			prepend += "\tsetdp $FF\n";
			objectCodeTmpFile = duplicateFilePrepend(Game.generatedCodeDirName + imgSetDir + "/" + obj.imageSet.fileName, imgSetDir + "/", prepend);
			compileRAW(objectCodeTmpFile, mode);
			obj.imageSet.bin = Files.readAllBytes(Paths.get(getBINFileName(objectCodeTmpFile)));
			obj.imageSet.uncompressedSize = obj.imageSet.bin.length;
			imgSetData.setData(imgSetPage, imgSetAddress, obj.imageSet.bin);			
		}		
		
		// Compilation de l'index animation pour etiquettes 
		if (obj.animation.uncompressedSize > 0) {
			prepend = "\tINCLUDE \"" + Game.constAnim+"\"\n";			
			prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + aniDir + "/" + FileUtil.removeExtension(obj.imageSet.fileName)+".glb" + "\"\n";
			prepend += "\torg   $" + String.format("%1$04X", aniAddress) + "\n";
			prepend += "\tsetdp $FF\n";			
			objectCodeTmpFile = duplicateFilePrepend(Game.generatedCodeDirName + aniDir + "/" + obj.animation.fileName, aniDir + "/", prepend);
			compileRAW(objectCodeTmpFile, mode);
			obj.animation.bin = Files.readAllBytes(Paths.get(getBINFileName(objectCodeTmpFile)));
			obj.animation.uncompressedSize = obj.animation.bin.length;
			imgSetData.setData(aniPage, aniAddress, obj.animation.bin);			
		}			
		
		// Compilation de l'objet
		prepend = "\topt   c,ct\n";		
		Path p = Paths.get(gm.engineAsmMainEngine);
		String asmFileName = p.getFileName().toString();			
		prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + gm.name+ "/" + MODE_DIR[mode] + "/" + FileUtil.removeExtension(asmFileName)+".glb" +"\"\n";
		
		if (obj.imageSet.uncompressedSize > 0 && obj.animation.uncompressedSize == 0) {			
			prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + imgSetDir + "/" + FileUtil.removeExtension(obj.imageSet.fileName)+".glb" + "\"\n";
		}
		
		if (obj.animation.uncompressedSize > 0) {
			prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + aniDir + "/" + FileUtil.removeExtension(obj.animation.fileName)+".glb" + "\"\n";
		}
		
		prepend += "\torg   $" + String.format("%1$04X", objCodeAddress) + "\n";
		prepend += "\tsetdp $FF\n";
		objectCodeTmpFile = duplicateFilePrepend(obj.codeFileName, imgSetDir, prepend);
		compileRAW(objectCodeTmpFile, mode, gm, objCodePage);
		obj.gmCode.get(gm).code.bin = Files.readAllBytes(Paths.get(getBINFileName(objectCodeTmpFile)));
		codeData.setData(objCodePage, objCodeAddress, obj.gmCode.get(gm).code.bin);		
		logger.debug("file " + objectCodeTmpFile + " final size:" + obj.gmCode.get(gm).code.bin.length + " bytes");
		
		if (obj.gmCode.get(gm).code.uncompressedSize != obj.gmCode.get(gm).code.bin.length) {
			throw new Exception("Second compilation pass for file " + objectCodeTmpFile + " gives different binary size ! (original: "+obj.gmCode.get(gm).code.uncompressedSize+" bytes)");
		}		
	}		
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	
	private static void writeObjectsFd() {
		logger.info("Write Objects to FLOPPY_DISK image ...");
		int index;
		
		if (!abortFloppyDisk) {	
			fd.setIndex(0, 0, 2);
			fd.setIndex(fd.getIndex() + Game.loadManagerSizeFd);
			
			HashMap<GameModeCommon, List<RAMLoaderIndex>> commons = new HashMap<GameModeCommon, List<RAMLoaderIndex>>();
	
			for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
				Enumeration<RAMLoaderIndex> enumFd = Collections.enumeration(gameMode.getValue().fdIdx);
				while (enumFd.hasMoreElements()) {
					RAMLoaderIndex di = enumFd.nextElement();
	
					// Gestion des communs, on n'écrit qu'une seule fois les communs sur disquette
					RAMLoaderIndex fdic = null;
					if (commons.containsKey(di.gmc)) {
						for (RAMLoaderIndex dic : commons.get(di.gmc)) {
							if (dic.ram_page == di.ram_page && dic.ram_address == di.ram_address && dic.ram_endAddress == di.ram_endAddress && Arrays.equals(di.encBin, dic.encBin)) {
								fdic = dic;
								break;
							}
						}
					}
					
					if (fdic != null) {
						di.fd_drive = fdic.fd_drive;
						di.fd_track = fdic.fd_track;
						di.fd_sector = fdic.fd_sector;
						di.fd_nbSector = fdic.fd_nbSector;
						di.fd_endOffset = fdic.fd_endOffset;					
					} else {
						di.fd_drive = fd.getUnit();
						di.fd_track = fd.getTrack();
						di.fd_sector = fd.getSector();
		
						index = (fd.getIndex() / 256) * 256; // round to start sector
						fd.write(di.encBin);
						di.fd_nbSector = (int) Math.ceil((fd.getIndex() - index) / 256.0); // round to end sector
						di.fd_endOffset = ((int) Math.ceil(fd.getIndex() / 256.0) * 256) - fd.getIndex();
						
						if (di.gmc != null) {
							if (!commons.containsKey(di.gmc)) {
								commons.put(di.gmc, new ArrayList<RAMLoaderIndex>());
							}
							commons.get(di.gmc).add(di);
						}
					}
				}
			}
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	
	private static void writeObjectsT2() throws Exception {
		logger.info("Write Objects to MEGAROM_T2 image ...");

		// Compte le nombre d'objets a traiter
		int nbItems = 0;
				
		HashMap<GameModeCommon, List<RAMLoaderIndex>> commons = new HashMap<GameModeCommon, List<RAMLoaderIndex>>();

		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			Enumeration<RAMLoaderIndex> enumT2 = Collections.enumeration(gameMode.getValue().t2Idx);
			while (enumT2.hasMoreElements()) {
				RAMLoaderIndex di = enumT2.nextElement();

				RAMLoaderIndex fdic = null;
				if (commons.containsKey(di.gmc)) {
					for (RAMLoaderIndex dic : commons.get(di.gmc)) {
						if (dic.ram_page == di.ram_page && dic.ram_address == di.ram_address && dic.ram_endAddress == di.ram_endAddress && Arrays.equals(di.encBin, dic.encBin)) {
							fdic = dic;
							break;
						}
					}
				}
				
				if (fdic == null) {
					nbItems++;
					
					if (di.gmc != null) {
						if (!commons.containsKey(di.gmc)) {
							commons.put(di.gmc, new ArrayList<RAMLoaderIndex>());
						}
						commons.get(di.gmc).add(di);
					}
				}
			}
		}
		
		commons.clear();
		// Initialise un item pour chaque élément a écrire en ROM
		Item[] items = new Item[nbItems];
		int itemIdx = 0;		
		
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			Enumeration<RAMLoaderIndex> enumT2 = Collections.enumeration(gameMode.getValue().t2Idx);
			while (enumT2.hasMoreElements()) {
				RAMLoaderIndex di = enumT2.nextElement();

				RAMLoaderIndex fdic = null;
				if (commons.containsKey(di.gmc)) {
					for (RAMLoaderIndex dic : commons.get(di.gmc)) {
						if (dic.ram_page == di.ram_page && dic.ram_address == di.ram_address && dic.ram_endAddress == di.ram_endAddress && Arrays.equals(di.encBin, dic.encBin)) {
							fdic = dic;
							break;
						}
					}
				}
				
				if (fdic != null) {
					fdic.rli.add(di); // save identical common, will be updated in knapsack
				} else {
					items[itemIdx++] = new Item(di, 1, di.encBin.length);
					
					if (di.gmc != null) {
						if (!commons.containsKey(di.gmc)) {
							commons.put(di.gmc, new ArrayList<RAMLoaderIndex>());
						}
						commons.get(di.gmc).add(di);
					}
				}
			}
		}

		boolean firstPass = true;
		
		while (items.length > 0) {

			if (!firstPass) {
				game.romT2.curPage++;
				game.romT2.updateEndPage();				
				
				if (game.romT2.isOutOfMemory()) {
					throw new Exception("C'est un peu trop ambitieux ... 2Mo pour la T.2 et pas un octet de plus !");
				}
			}
			
			// les données sont réparties en pages en fonction de leur taille par un algorithme "sac à dos"
			Knapsack knapsack = new Knapsack(items, RamImage.PAGE_SIZE-game.romT2.endAddress[game.romT2.curPage]); // Sac à dos de poids max 16Ko
			Solution solution = knapsack.solve();

			// Parcours de la solution
			for (Iterator<Item> iter = solution.items.listIterator(); iter.hasNext();) {

				Item currentItem = iter.next();
				
				currentItem.bin.getRAMLoaderIndex().t2_page = game.romT2.curPage;					
				currentItem.bin.getRAMLoaderIndex().t2_address = game.romT2.endAddress[game.romT2.curPage];
				game.romT2.setDataAtCurPos(((RAMLoaderIndex) currentItem.bin).encBin);
				currentItem.bin.getRAMLoaderIndex().t2_endAddress = game.romT2.endAddress[game.romT2.curPage];
				
				logger.debug("Item: "+currentItem.name+" T2 ROM "+currentItem.bin.getRAMLoaderIndex().t2_page+" "+String.format("$%1$04X", currentItem.bin.getRAMLoaderIndex().t2_address) + " " + String.format("$%1$04X", currentItem.bin.getRAMLoaderIndex().t2_endAddress-1));
				
				// Update all identical index on other GameModes
				for (RAMLoaderIndex di : currentItem.bin.getRAMLoaderIndex().rli) {
					di.t2_page = currentItem.bin.getRAMLoaderIndex().t2_page;
					di.t2_address = currentItem.bin.getRAMLoaderIndex().t2_address;
					di.t2_endAddress = currentItem.bin.getRAMLoaderIndex().t2_endAddress;
				}

				// construit la liste des éléments restants à organiser
				for (int i = 0; i < items.length; i++) {
					if (items[i].bin == currentItem.bin) {
						Item[] newItems = new Item[items.length - 1];
						for (int l = 0; l < i; l++) {
							newItems[l] = items[l];
						}
						for (int j = i; j < items.length - 1; j++) {
							newItems[j] = items[j + 1];
						}
						items = newItems;
						break;
					}
				}
			}
			
			if (game.romT2.startAddress[game.romT2.curPage] < game.romT2.endAddress[game.romT2.curPage]) {
				logger.debug("\t\tFound solution for page : " + game.romT2.curPage + " start: " + String.format("$%1$04X", game.romT2.startAddress[game.romT2.curPage]) + " end: " + String.format("$%1$04X", game.romT2.endAddress[game.romT2.curPage]-1) + " non allocated space: " + (RamImage.PAGE_SIZE - game.romT2.endAddress[game.romT2.curPage]) + " octets");
			} else {
				logger.debug("\t\tNo solution for page : " + game.romT2.curPage + " start: " + String.format("$%1$04X", game.romT2.startAddress[game.romT2.curPage]));
			}
			
			firstPass = false;
		}
		firstPass = false;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static int getRAMLoaderManagerSizeFd() throws Exception {
		logger.info("get RAM Loader Manager size for " + MODE_LABEL[FLOPPY_DISK] + "...");

		createFile(FileNames.FILE_INDEX_FD);

		// Compilation du Game Mode Manager
		// -------------------------------------------------
		String prepend = "Gm_Index\n";
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			prepend += "\tfdb $0000\n";
		}		
		String gameModeManagerTmpFile = duplicateFilePrepend(game.engineAsmRAMLoaderManagerFd, "", prepend);
		
		compileRAW(gameModeManagerTmpFile, FLOPPY_DISK);
		game.engineRAMLoaderManagerBytesFd = Files.readAllBytes(Paths.get(getBINFileName(gameModeManagerTmpFile)));

		if (game.engineRAMLoaderManagerBytesFd.length > RamImage.PAGE_SIZE) {
			throw new Exception("Le fichier "+game.engineAsmRAMLoaderManagerFd+" est trop volumineux:"+game.engineRAMLoaderManagerBytesFd.length+" octets (max:"+RamImage.PAGE_SIZE+")");
		}	
		
		logger.info("size: " + game.engineRAMLoaderManagerBytesFd.length);
		return game.engineRAMLoaderManagerBytesFd.length;
	}	

	private static int getRAMLoaderManagerSizeT2() throws Exception {
		logger.info("get RAM Loader Manager size for " + MODE_LABEL[MEGAROM_T2] + "...");

		createFile(FileNames.FILE_INDEX_T2);

		// Compilation du Game Mode Manager
		// -------------------------------------------------		
		
		String prepend = "Gm_Index\n";
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			prepend += "\tfdb $0000\n";
		}		
		String gameModeManagerTmpFile = duplicateFilePrepend(game.engineAsmRAMLoaderManagerT2, "", prepend);		

		compileRAW(gameModeManagerTmpFile, MEGAROM_T2);
		game.engineRAMLoaderManagerBytesT2 = Files.readAllBytes(Paths.get(getBINFileName(gameModeManagerTmpFile)));

		if (game.engineRAMLoaderManagerBytesT2.length > RamImage.PAGE_SIZE) {
			throw new Exception("Le fichier "+game.engineAsmRAMLoaderManagerT2+" est trop volumineux:"+game.engineRAMLoaderManagerBytesT2.length+" octets (max:"+RamImage.PAGE_SIZE+")");
		}	
		
		logger.info("size: " + game.engineRAMLoaderManagerBytesT2.length);
		return game.engineRAMLoaderManagerBytesT2.length;
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

	private static void compileRAMLoaderManager() throws Exception {
		if (!abortFloppyDisk) {	
			compileAndWriteRAMLoaderManager(FLOPPY_DISK);
		}
		compileAndWriteRAMLoaderManager(MEGAROM_T2);
	}	
	
	private static int compileAndWriteRAMLoaderManager(int mode) throws Exception {
		logger.info("Compile and Write RAM Loader Manager for " + MODE_LABEL[mode] + " ...");
		int indexSize = 0;

		// Construction des données de chargement disquette pour chaque Game Mode
		// ---------------------------------------------------------------------------------------
		AsmSourceCode ramLoaderDataIdx;
		if (mode == FLOPPY_DISK) {
			ramLoaderDataIdx = new AsmSourceCode(createFile(FileNames.FILE_INDEX_FD));
			ramLoaderDataIdx.addCommentLine("structure: sector, nb sector, drive (bit 7) track (bit 6-0), end offset, ram dest page, ram dest end addr. hb, ram dest end addr. lb");			
		} else {
			ramLoaderDataIdx = new AsmSourceCode(createFile(FileNames.FILE_INDEX_T2));
			ramLoaderDataIdx.addCommentLine("structure: rom src page, rom src end addr. hb, rom src end addr. lb, ram dest page, ram dest end addr. hb, ram dest end addr. lb");			
		}
		
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			
			if (mode == FLOPPY_DISK) {
				indexSize = gameMode.getValue().fdIdx.size()*7+1; // +1 balise de fin FF
				if (gameMode.getValue().indexSizeFD-2<indexSize) {
					throw new Exception("Builder: FD indexSize too large fix the builder code !");	
				}
			} else {
				indexSize = gameMode.getValue().t2Idx.size()*6+1;
				logger.debug("Final t2Idx: "+gameMode.getValue().fdIdx.size());
				if (gameMode.getValue().indexSizeT2-2<indexSize) {
					throw new Exception("Builder: T2 indexSize too large fix the builder code !");	
				}				
			}
			
			ramLoaderDataIdx.addFdb(new String[] { "RL_RAM_index+"+indexSize});	
			ramLoaderDataIdx.addLabel("gm_" + gameMode.getKey());
			
			// Ecriture de l'index de chargement des demi-pages
			if (mode == FLOPPY_DISK) {
				Enumeration<RAMLoaderIndex> enumFd = Collections.enumeration(gameMode.getValue().fdIdx);
				while(enumFd.hasMoreElements()) {
					RAMLoaderIndex di = enumFd.nextElement();
					
					// Inversion des demi-pages liée à la copie de code en zone data qui sera executé depuis la zone cartouche
					int ram_endDest;
					if (di.split) {
						if (di.ram_endAddress <= 0x2000) {
							ram_endDest = di.ram_endAddress + 0xC000;
						} else {
							ram_endDest = di.ram_endAddress + 0x8000;
						}
					} else {
						ram_endDest = di.ram_endAddress + 0xA000;
					}
					
					ramLoaderDataIdx.addFcb(new String[] {
					String.format("$%1$02X", di.fd_sector),
					String.format("$%1$02X", di.fd_nbSector-1),
					String.format("$%1$02X", (di.fd_drive << 7)+di.fd_track),				
					String.format("$%1$02X", -di.fd_endOffset & 0xFF),
					String.format("$%1$02X", di.ram_page),	
					String.format("$%1$02X", ram_endDest >> 8),
					String.format("$%1$02X", ram_endDest & 0x00FF)}); 		
				}
			}
			
			if (mode == MEGAROM_T2) {
				Enumeration<RAMLoaderIndex> enumT2 = Collections.enumeration(gameMode.getValue().t2Idx);
				while(enumT2.hasMoreElements()) {
					RAMLoaderIndex di = enumT2.nextElement();
					
					// Inversion des demi-pages liée à la copie de code en zone data qui sera executé depuis la zone cartouche
					int ram_endDest;
					if (di.split) {
						if (di.ram_endAddress <= 0x2000) {
							ram_endDest = di.ram_endAddress + 0xC000;
						} else {
							ram_endDest = di.ram_endAddress + 0x8000;
						}
					} else {
						ram_endDest = di.ram_endAddress + 0xA000;
					}				
					
					ramLoaderDataIdx.addFcb(new String[] {
						String.format("$%1$02X", di.t2_page),
						String.format("$%1$02X", di.ram_page),						
						String.format("$%1$02X", di.t2_endAddress >> 8),			
						String.format("$%1$02X", di.t2_endAddress & 0x00FF),								
						String.format("$%1$02X", ram_endDest >> 8),			
						String.format("$%1$02X", ram_endDest & 0x00FF)});			
			     }
			}
			ramLoaderDataIdx.addFcb(new String[] { "$FF" });			
		}
		
		ramLoaderDataIdx.addLabel("Gm_Index");
		for (Entry<String, GameMode> gameMode : game.gameModes.entrySet()) {
			ramLoaderDataIdx.addFdb(new String[] {"gm_" + gameMode.getKey()});
		}
				
		ramLoaderDataIdx.flush();

		// Compilation du Game Mode Manager
		// -------------------------------------------------		

		String gameModeManagerTmpFile;
		if (mode == FLOPPY_DISK) {
			gameModeManagerTmpFile = duplicateFile(game.engineAsmRAMLoaderManagerFd);
		} else {
			String prepend = "\torg   " + String.format("$%1$04X", Game.bootSizeT2) + "\n";
			gameModeManagerTmpFile = duplicateFilePrepend(game.engineAsmRAMLoaderManagerT2, "", prepend);
		}
		
		compileRAW(gameModeManagerTmpFile, mode);
		byte[] bin = Files.readAllBytes(Paths.get(getBINFileName(gameModeManagerTmpFile)));
		if (mode == FLOPPY_DISK) {
			game.engineRAMLoaderManagerBytesFd = bin;
			
			// Ecriture disquette
			fd.setIndex(0, 0, 2);
			fd.write(game.engineRAMLoaderManagerBytesFd);
			
		} else if (mode == MEGAROM_T2) {
			game.engineRAMLoaderManagerBytesT2 = bin;

			if (Game.bootSizeT2+bin.length > RamImage.PAGE_SIZE) {
				throw new Exception("Le fichier est trop volumineux:"+(Game.bootSizeT2+bin.length)+" octets (max:"+RamImage.PAGE_SIZE+")");
			}	
			
			// Ecriture T2
			game.romT2.setData(0, Game.bootSizeT2, bin);
		}
		
		return bin.length;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void compileAndWriteBootFd() throws Exception {
		logger.info("Compile boot for FLOPPY_DISK ...");
		if (!abortFloppyDisk) {		
			String RAMLoaderManagerGlobals = FileUtil.removeExtension(Paths.get(game.engineAsmRAMLoaderManagerFd).getFileName().toString())+".glb";
			String prepend = "\tINCLUDE \"" + Game.generatedCodeDirName + FileNames.GAME_GLOBALS + "\"\n";
			prepend += "\tINCLUDE \"" + Game.generatedCodeDirName + RAMLoaderManagerGlobals + "\"\n";
			String bootTmpFile = duplicateFilePrepend(game.engineAsmBootFd, "", prepend);
			game.glb.addConstant("Build_BootLastBlock", String.format("$%1$02X", (0x0000 + game.engineRAMLoaderManagerBytesFd.length) >> 8)+"00"); // On tronque l'octet de poids faible
			game.glb.flush();
			compileRAW(bootTmpFile, FLOPPY_DISK);
	
			// Traitement du binaire issu de la compilation et génération du secteur d'amorçage
			Bootloader bootLoader = new Bootloader();
			
			// Ecriture disquette du boot
			fd.setIndex(0, 0, 1);
			fd.write(bootLoader.encodeBootLoader(getBINFileName(bootTmpFile)));
			
			logger.info("Write Floppy Disk Image to output file ...");
			
			fd.save(game.outputDiskName);
			fd.saveToSd(game.outputDiskName);
			
			logger.info("Build done !");
		} else {
			logger.info("***** No way to produce a FD version ! *****");
		}
	}
	
	private static void compileAndWriteBootT2() throws Exception {
		logger.info("Compile boot for MEGAROM_T2 ...");
		
		String prepend = "\tINCLUDE \"" + Game.generatedCodeDirName + FileNames.GAME_GLOBALS + "\"\n";
		String bootTmpFile = duplicateFilePrepend(game.engineAsmBootT2, "", prepend);
		compileRAW(bootTmpFile, MEGAROM_T2);
		byte[] bin = Files.readAllBytes(Paths.get(getBINFileName(bootTmpFile)));
		
		//game.romT2.writeT2Header(bin);
		game.romT2.setData(0, 0, bin);
		t2.write(game.romT2);
		
		logger.info("Write Megarom T.2 Image to output file ...");
		
		t2.save(game.outputDiskName);
		
		logger.info("Build done !");	
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void buildT2Loader() throws Exception {
		logger.info("Build T2 Loader for SDDRIVE ...");
		
		String tmpFile = duplicateFile(game.engineAsmBootT2Loader);
		compileRAW(tmpFile, MEGAROM_T2);
		byte[] bin;
		
		// Traitement du binaire issu de la compilation et génération du secteur d'amorçage
		Bootloader bootLoader = new Bootloader();
		
		t2L.setIndex(0, 0, 1);
		t2L.write(bootLoader.encodeBootLoader(getBINFileName(tmpFile)));
		logger.info("Write Megarom T.2 Boot to output file ...");

		String prepend = "Builder_End_Page equ "+(game.romT2.endPage+1)+"\n";
		prepend += "Builder_Progress_Step equ "+((Game.T2_NB_PAGES/(game.romT2.endPage+1))*256+(int)(256*(((double)Game.T2_NB_PAGES/(game.romT2.endPage+1))-(Game.T2_NB_PAGES/(game.romT2.endPage+1)))))+"\n";
		tmpFile = duplicateFilePrepend(game.engineAsmT2Loader, "", prepend);
		compileRAW(tmpFile, MEGAROM_T2);
		bin = Files.readAllBytes(Paths.get(getBINFileName(tmpFile)));
		
		t2L.setIndex(0, 0, 2);		
		t2L.write(bin);
		logger.info("Write Megarom T.2 Loader to output file ...");
		
		t2L.writeRom(t2.t2Bytes);		
		logger.info("Write Megarom T.2 Data to output file ...");		
		
		t2L.save(game.outputDiskName);
		logger.info("Build done !");	
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

	private static int writeAniIndex(AsmSourceCode asm, Object object) throws Exception {
		int size = 0;
		
		// Add animation data at start
		for (Entry<String, String[]> animationDataProperties : object.animationDataProperties.entrySet()) {
			if (asm != null) {
				asm.add("\tINCLUDE \"" + animationDataProperties.getValue()[0] + "\"\n");
			}
			size += getBINSize(animationDataProperties.getValue()[0]);
		}			
		
		for (Entry<String, String[]> animationProperties : object.animationsProperties.entrySet()) {
			int i = 0;

			// automatic detection of animation script version
			// if first field does not contains a comma, then it is v00
			// if first field contains a comma, then it is v02
			if (!animationProperties.getValue()[0].contains(",")) {
			
				// ** Animation **
				// ***************
				// Duration is the (number of frames-1) for each images
				// so 0 means 1 frame per image
				// TODO upgrade all demo animation script to reflect real frame nb
				// and apply the same -1 calc as the v02 version
				
				// Write animation frame duration followed by animation label
				// so animation duration will be accessed by -1,x
				if (asm != null) {
					asm.addFcb(new String[] { animationProperties.getValue()[0] });
					asm.addLabel(animationProperties.getKey() + " ");				
				}
				size++;
	
				for (i = 1; i < animationProperties.getValue().length; i++) {
	
					if (Animation.tagSize.get(animationProperties.getValue()[i]) == null) {
						
						// not an end tag, this is a pointer to an image
						if (asm != null)
							asm.addFdb(new String[] { animationProperties.getValue()[i] });
						size += 2;
						
					} else {
						
						// this is an end tag, process each end tag + parameter length
						switch (Animation.tagSize.get(animationProperties.getValue()[i])) {
						case 1:
							if (asm != null)
								asm.addFcb(new String[] { animationProperties.getValue()[i] });
							size += 1;
							break;
						case 2:
							if (asm != null) {
								asm.addFcb(new String[] { animationProperties.getValue()[i++] });
								asm.addFcb(new String[] { animationProperties.getValue()[i] });								
							}
							size += 2;
							break;
						case 3:
							if (asm != null) {
								asm.addFcb(new String[] { animationProperties.getValue()[i++] });
								asm.addFdb(new String[] { animationProperties.getValue()[i] });								
							}
							size += 3;
							break;
						}
					}
				}
			} else {
				
				// ** Animation Advanced **
				// ************************
				// Duration is the number of frames for each images
				// so 1 means 1 frame per image
				
				// Write animation label
				if (asm != null) {
					asm.addLabel(animationProperties.getKey() + " ");				
				}
	
				for (i = 0; i < animationProperties.getValue().length; i++) {
	
					if (Animation.tagSize.get(animationProperties.getValue()[i]) == null) {
						
						// not an end tag, this is a pointer to an image, a duration value and animation flags offset
						String[] data = animationProperties.getValue()[i].split(",");
						if (data.length != 3)
							throw new Exception ("Animation v02 need three comma separated parameters : image_name,duration,animation_flags\n ex: Img_5e9a2,8,$0000\n duration is the number of frames for the image");
						
						// decrement duration to simplify asm code
						data[1] = Integer.toString(Integer.parseInt(data[1]) - 1); 
						
						if (asm != null) {
							asm.addFdb(new String[] {data[0]});
							asm.addFcb(new String[] {data[1]});
							asm.addFcb(new String[] {data[2]});
						}
						size += 5;
						
					} else {
						
						// this is an end tag, process each end tag + parameter length
						switch (Animation.tagSize.get(animationProperties.getValue()[i])) {
						case 1:
							if (asm != null)
								asm.addFcb(new String[] { animationProperties.getValue()[i] });
							size += 1;
							break;
						case 2:
							if (asm != null) {
								asm.addFcb(new String[] { animationProperties.getValue()[i++] });
								asm.addFcb(new String[] { animationProperties.getValue()[i] });								
							}
							size += 2;
							break;
						case 3:
							if (asm != null) {
								asm.addFcb(new String[] { animationProperties.getValue()[i++] });
								asm.addFdb(new String[] { animationProperties.getValue()[i] });								
							}
							size += 3;
							break;
						}
					}
				}
				
			}
		}
		
		if (asm != null)		
			asm.flush();
		return size;
	}
	
	private static int writeImgIndex(AsmSourceCode asm, GameMode gm, Sprite sprite, int mode) {
		
		// Sorry for this code ... should be a better way of doing that
		// Note : index to image sub set is limited to an offset of +127
		// this version go up to +102 so it's fine
		
		List<String> line = new ArrayList<String>();
		int imageSet_header = 7, imageSubSet_header = 6;
		int x_size = 0;
		int y_size = 0;
		int center_offset = 0;
		int n_offset = 0;
		int n_x1 = 0;
		int n_y1 = 0;
		int x_offset = 0;
		int x_x1 = 0;
		int x_y1 = 0;		
		int y_offset = 0;
		int y_x1 = 0;
		int y_y1 = 0;		
		int xy_offset = 0;
		int xy_x1 = 0;
		int xy_y1 = 0;		
		int nb0_offset = 0;
		int nd0_offset = 0;
		int nb1_offset = 0;
		int nd1_offset = 0;
		int xb0_offset = 0;
		int xd0_offset = 0;
		int xb1_offset = 0;
		int xd1_offset = 0;
		int yb0_offset = 0;
		int yd0_offset = 0;
		int yb1_offset = 0;
		int yd1_offset = 0;
		int xyb0_offset = 0;
		int xyd0_offset = 0;
		int xyb1_offset = 0;
		int xyd1_offset = 0;		
		
		if (asm != null) {
			if (sprite.associatedIdx != null) {
				asm.addConstant("Id"+sprite.name, sprite.associatedIdx);
				asm.addFcb(new String[]{sprite.associatedIdx});
			}
			asm.addLabel(sprite.name+" ");
		}
		
		if (sprite.subSprites.containsKey("NB0") || sprite.subSprites.containsKey("ND0") || sprite.subSprites.containsKey("NB1") || sprite.subSprites.containsKey("ND1")) {
			n_offset = imageSet_header;			
		}

		if (sprite.subSprites.containsKey("NB0")) {
			nb0_offset = imageSubSet_header;
			n_x1 = sprite.subSprites.get("NB0").x1_offset;
			n_y1 = sprite.subSprites.get("NB0").y1_offset;
		}
		
		if (sprite.subSprites.containsKey("ND0")) {
			nd0_offset = (nb0_offset>0?7:0) + imageSubSet_header;
			n_x1 = sprite.subSprites.get("ND0").x1_offset;	
			n_y1 = sprite.subSprites.get("ND0").y1_offset;
		}

		if (sprite.subSprites.containsKey("NB1")) {
			nb1_offset = (nd0_offset>0?3:0) + (nb0_offset>0?7:0) + imageSubSet_header;
			n_x1 = sprite.subSprites.get("NB1").x1_offset;
			n_y1 = sprite.subSprites.get("NB1").y1_offset;
		}
		
		if (sprite.subSprites.containsKey("ND1")) {
			nd1_offset = (nb1_offset>0?7:0) + (nd0_offset>0?3:0) + (nb0_offset>0?7:0) + imageSubSet_header;
			n_x1 = sprite.subSprites.get("ND1").x1_offset;
			n_y1 = sprite.subSprites.get("ND1").y1_offset;
		}		
		
		if (sprite.subSprites.containsKey("XB0") || sprite.subSprites.containsKey("XD0") || sprite.subSprites.containsKey("XB1") || sprite.subSprites.containsKey("XD1")) {
			x_offset = (nd1_offset>0?3:0) + (nb1_offset>0?7:0) + (nd0_offset>0?3:0) + (nb0_offset>0?7:0) + (n_offset>0?n_offset+imageSubSet_header:imageSet_header);			
		}		
		
		if (sprite.subSprites.containsKey("XB0")) {
			xb0_offset = imageSubSet_header;
			x_x1 = sprite.subSprites.get("XB0").x1_offset;
			x_y1 = sprite.subSprites.get("XB0").y1_offset;
		}
		
		if (sprite.subSprites.containsKey("XD0")) {
			xd0_offset = (xb0_offset>0?7:0) + imageSubSet_header;
			x_x1 = sprite.subSprites.get("XD0").x1_offset;
			x_y1 = sprite.subSprites.get("XD0").y1_offset;			
		}

		if (sprite.subSprites.containsKey("XB1")) {
			xb1_offset = (xd0_offset>0?3:0) + (xb0_offset>0?7:0) + imageSubSet_header;
			x_x1 = sprite.subSprites.get("XB1").x1_offset;
			x_y1 = sprite.subSprites.get("XB1").y1_offset;			
		}
		
		if (sprite.subSprites.containsKey("XD1")) {
			xd1_offset = (xb1_offset>0?7:0) + (xd0_offset>0?3:0) + (xb0_offset>0?7:0) + imageSubSet_header;
			x_x1 = sprite.subSprites.get("XD1").x1_offset;
			x_y1 = sprite.subSprites.get("XD1").y1_offset;			
		}		
		
		if (sprite.subSprites.containsKey("YB0") || sprite.subSprites.containsKey("YD0") || sprite.subSprites.containsKey("YB1") || sprite.subSprites.containsKey("YD1")) {
			y_offset = (xd1_offset>0?3:0) + (xb1_offset>0?7:0) + (xd0_offset>0?3:0) + (xb0_offset>0?7:0) + (x_offset>0?x_offset+imageSubSet_header:imageSet_header);			
		}		
		
		if (sprite.subSprites.containsKey("YB0")) {
			yb0_offset = imageSubSet_header;
			y_x1 = sprite.subSprites.get("YB0").x1_offset;
			y_y1 = sprite.subSprites.get("YB0").y1_offset;
		}
		
		if (sprite.subSprites.containsKey("YD0")) {
			yd0_offset = (yb0_offset>0?7:0) + imageSubSet_header;
			y_x1 = sprite.subSprites.get("YD0").x1_offset;
			y_y1 = sprite.subSprites.get("YD0").y1_offset;			
		}

		if (sprite.subSprites.containsKey("YB1")) {
			yb1_offset = (yd0_offset>0?3:0) + (yb0_offset>0?7:0) + imageSubSet_header;
			y_x1 = sprite.subSprites.get("YB1").x1_offset;
			y_y1 = sprite.subSprites.get("YB1").y1_offset;			
		}
		
		if (sprite.subSprites.containsKey("YD1")) {
			yd1_offset = (yb1_offset>0?7:0) + (yd0_offset>0?3:0) + (yb0_offset>0?7:0) + imageSubSet_header;
			y_x1 = sprite.subSprites.get("YD1").x1_offset;
			y_y1 = sprite.subSprites.get("YD1").y1_offset;
		}
		
		if (sprite.subSprites.containsKey("XYB0") || sprite.subSprites.containsKey("XYD0") || sprite.subSprites.containsKey("XYB1") || sprite.subSprites.containsKey("XYD1")) {
			xy_offset = (yd1_offset>0?3:0) + (yb1_offset>0?7:0) + (yd0_offset>0?3:0) + (yb0_offset>0?7:0) + (y_offset>0?y_offset+imageSubSet_header:imageSet_header);			
		}		
		
		if (sprite.subSprites.containsKey("XYB0")) {
			xyb0_offset = imageSubSet_header;
			xy_x1 = sprite.subSprites.get("XYB0").x1_offset;
			xy_y1 = sprite.subSprites.get("XYB0").y1_offset;
		}
		
		if (sprite.subSprites.containsKey("XYD0")) {
			xyd0_offset = (xyb0_offset>0?7:0) + imageSubSet_header;
			xy_x1 = sprite.subSprites.get("XYD0").x1_offset;
			xy_y1 = sprite.subSprites.get("XYD0").y1_offset;			
		}

		if (sprite.subSprites.containsKey("XYB1")) {
			xyb1_offset = (xyd0_offset>0?3:0) + (xyb0_offset>0?7:0) + imageSubSet_header;
			xy_x1 = sprite.subSprites.get("XYB1").x1_offset;
			xy_y1 = sprite.subSprites.get("XYB1").y1_offset;
		}
		
		if (sprite.subSprites.containsKey("XYD1")) {
			xyd1_offset = (xyb1_offset>0?7:0) + (xyd0_offset>0?3:0) + (xyb0_offset>0?7:0) + imageSubSet_header;
			xy_x1 = sprite.subSprites.get("XYD1").x1_offset;
			xy_y1 = sprite.subSprites.get("XYD1").y1_offset;
		}		
		
		for (Entry<String, SubSprite> subSprite : sprite.subSprites.entrySet()) {
			x_size = subSprite.getValue().x_size;
			y_size = subSprite.getValue().y_size;
			center_offset = subSprite.getValue().center_offset;
			break;
		}
		
		// assigne les images symétriques vides afin d'empêcher les crashs au runtime
		int def_value = 0;
		
		// search a value by priority
		if (xy_offset > 0)
			def_value = xy_offset;
		if (y_offset > 0)
			def_value = y_offset;		
		if (x_offset > 0)
			def_value = x_offset;		
		if (n_offset > 0)
			def_value = n_offset;
		
		// assign to empty offset
		if (xy_offset == 0)
			xy_offset = def_value;
		if (y_offset == 0)
			y_offset = def_value;		
		if (x_offset == 0)
			x_offset = def_value;		
		if (n_offset == 0)
			n_offset = def_value;		
		
		line.add(String.format("$%1$02X", n_offset)); // unsigned value
		line.add(String.format("$%1$02X", x_offset)); // unsigned value
		line.add(String.format("$%1$02X", y_offset)); // unsigned value
		line.add(String.format("$%1$02X", xy_offset)); // unsigned value		
		line.add(String.format("$%1$02X", x_size)); // unsigned value
		line.add(String.format("$%1$02X", y_size)); // unsigned value
		line.add(String.format("$%1$02X", center_offset)); // unsigned value
		
		if (nb0_offset+nd0_offset+nb1_offset+nd1_offset>0) {
			line.add(String.format("$%1$02X", nb0_offset)); // unsigned value
			line.add(String.format("$%1$02X", nd0_offset)); // unsigned value
			line.add(String.format("$%1$02X", nb1_offset)); // unsigned value
			line.add(String.format("$%1$02X", nd1_offset)); // unsigned value
			line.add(String.format("$%1$02X", n_x1 & 0xFF)); // signed value		
			line.add(String.format("$%1$02X", n_y1 & 0xFF)); // signed value			
			if (sprite.subSprites.containsKey("NB0")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("NB0"), line, mode);
			}

			if (sprite.subSprites.containsKey("ND0")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("ND0"), line, mode);
			}

			if (sprite.subSprites.containsKey("NB1")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("NB1"), line, mode);
			}

			if (sprite.subSprites.containsKey("ND1")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("ND1"), line, mode);
			}
		}
		
		if (xb0_offset+xd0_offset+xb1_offset+xd1_offset>0) {
			line.add(String.format("$%1$02X", xb0_offset)); // unsigned value
			line.add(String.format("$%1$02X", xd0_offset)); // unsigned value
			line.add(String.format("$%1$02X", xb1_offset)); // unsigned value
			line.add(String.format("$%1$02X", xd1_offset)); // unsigned value
			line.add(String.format("$%1$02X", x_x1 & 0xFF)); // signed value		
			line.add(String.format("$%1$02X", x_y1 & 0xFF)); // signed value			
			if (sprite.subSprites.containsKey("XB0")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("XB0"), line, mode);
			}

			if (sprite.subSprites.containsKey("XD0")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("XD0"), line, mode);
			}

			if (sprite.subSprites.containsKey("XB1")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("XB1"), line, mode);
			}

			if (sprite.subSprites.containsKey("XD1")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("XD1"), line, mode);
			}
		}
		
		if (yb0_offset+yd0_offset+yb1_offset+yd1_offset>0) {
			line.add(String.format("$%1$02X", yb0_offset)); // unsigned value
			line.add(String.format("$%1$02X", yd0_offset)); // unsigned value
			line.add(String.format("$%1$02X", yb1_offset)); // unsigned value
			line.add(String.format("$%1$02X", yd1_offset)); // unsigned value
			line.add(String.format("$%1$02X", y_x1 & 0xFF)); // signed value		
			line.add(String.format("$%1$02X", y_y1 & 0xFF)); // signed value			
			if (sprite.subSprites.containsKey("YB0")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("YB0"), line, mode);
			}

			if (sprite.subSprites.containsKey("YD0")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("YD0"), line, mode);
			}

			if (sprite.subSprites.containsKey("YB1")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("YB1"), line, mode);
			}

			if (sprite.subSprites.containsKey("YD1")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("YD1"), line, mode);
			}
		}
		
		if (xyb0_offset+xyd0_offset+xyb1_offset+xyd1_offset>0) {
			line.add(String.format("$%1$02X", xyb0_offset)); // unsigned value
			line.add(String.format("$%1$02X", xyd0_offset)); // unsigned value
			line.add(String.format("$%1$02X", xyb1_offset)); // unsigned value
			line.add(String.format("$%1$02X", xyd1_offset)); // unsigned value
			line.add(String.format("$%1$02X", xy_x1 & 0xFF)); // signed value		
			line.add(String.format("$%1$02X", xy_y1 & 0xFF)); // signed value			
			if (sprite.subSprites.containsKey("XYB0")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("XYB0"), line, mode);
			}

			if (sprite.subSprites.containsKey("XYD0")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("XYD0"), line, mode);
			}

			if (sprite.subSprites.containsKey("XYB1")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("XYB1"), line, mode);
			}

			if (sprite.subSprites.containsKey("XYD1")) {
				getImgSubSpriteIndex(gm, sprite.subSprites.get("XYD1"), line, mode);
			}
		}		
		
		String[] result = line.toArray(new String[0]);
		if (asm != null) {
			asm.addFcb(result);
			asm.flush();
		}
		return line.size()+(sprite.associatedIdx != null?1:0);
	}
	
	private static void getImgSubSpriteIndex(GameMode gm, SubSprite s, List<String> line, int mode) {
		
		if (gm == null) {
			line.add(String.format("$%1$02X", 0));
			line.add(String.format("$%1$02X", 0));		
			line.add(String.format("$%1$02X", 0));
		
			if (s.erase != null) {
				line.add(String.format("$%1$02X", 0));
				line.add(String.format("$%1$02X", 0));		
				line.add(String.format("$%1$02X", 0));
				line.add(String.format("$%1$02X", s.nb_cell)); // unsigned value
			}
		} else {
			if (mode == FLOPPY_DISK) {
				line.add(String.format("$%1$02X", s.draw.dataIndex.get(gm).fd_ram_page + 0x60));
				line.add(String.format("$%1$02X", s.draw.dataIndex.get(gm).fd_ram_address >> 8));		
				line.add(String.format("$%1$02X", s.draw.dataIndex.get(gm).fd_ram_address & 0xFF));
			
				if (s.erase != null) {
					line.add(String.format("$%1$02X", s.erase.dataIndex.get(gm).fd_ram_page + 0x60));
					line.add(String.format("$%1$02X", s.erase.dataIndex.get(gm).fd_ram_address >> 8));		
					line.add(String.format("$%1$02X", s.erase.dataIndex.get(gm).fd_ram_address & 0xFF));
					line.add(String.format("$%1$02X", s.nb_cell)); // unsigned value
				}
			} else if (mode == MEGAROM_T2 && s.parent.inRAM) {
				line.add(String.format("$%1$02X", s.draw.dataIndex.get(gm).t2_ram_page + 0x60));
				line.add(String.format("$%1$02X", s.draw.dataIndex.get(gm).t2_ram_address >> 8));		
				line.add(String.format("$%1$02X", s.draw.dataIndex.get(gm).t2_ram_address & 0xFF));
			
				if (s.erase != null) {
					line.add(String.format("$%1$02X", s.erase.dataIndex.get(gm).t2_ram_page + 0x60));
					line.add(String.format("$%1$02X", s.erase.dataIndex.get(gm).t2_ram_address >> 8));		
					line.add(String.format("$%1$02X", s.erase.dataIndex.get(gm).t2_ram_address & 0xFF));
					line.add(String.format("$%1$02X", s.nb_cell)); // unsigned value
				}
			} else if (mode == MEGAROM_T2 && !s.parent.inRAM) {
				line.add(String.format("$%1$02X", s.draw.t2_page + 0x80));
				line.add(String.format("$%1$02X", s.draw.t2_address >> 8));		
				line.add(String.format("$%1$02X", s.draw.t2_address & 0xFF));
			
				if (s.erase != null) {
					line.add(String.format("$%1$02X", s.erase.t2_page + 0x80));
					line.add(String.format("$%1$02X", s.erase.t2_address >> 8));		
					line.add(String.format("$%1$02X", s.erase.t2_address & 0xFF));
					line.add(String.format("$%1$02X", s.nb_cell)); // unsigned value
				}
			}
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void writeObjIndex(AsmSourceCode asmBuilder, GameMode gm, int mode) {	
		String[][] objIndexPage = new String[gm.objectsId.entrySet().size() + 1][];
		String[][] objIndex = new String[gm.objectsId.entrySet().size() + 1][];
		
		// Game Mode Common
		for (GameModeCommon common : gm.gameModeCommon) {
			if (common != null) {
				for (Entry<String, Object> obj : common.objects.entrySet()) {
					writeObjIndex(objIndexPage, objIndex, gm, obj.getValue(), mode);				
				}
			}
		}
		
		// Objets du Game Mode
		for (Entry<String, Object> obj : gm.objects.entrySet()) {
			writeObjIndex(objIndexPage, objIndex, gm, obj.getValue(), mode);		
		}			
		
		asmBuilder.addLabel("Obj_Index_Page");
		for (int i = 0; i < objIndexPage.length; i++) {
			if (objIndexPage[i] == null) {
				objIndexPage[i] = new String[] { "$00" };
			}
			asmBuilder.addFcb(objIndexPage[i]);
		}

		asmBuilder.addLabel("Obj_Index_Address");
		for (int i = 0; i < objIndex.length; i++) {
			if (objIndex[i] == null) {
				objIndex[i] = new String[] { "$00", "$00" };
			}
			asmBuilder.addFcb(objIndex[i]);
		}	
	}

	private static void writeObjIndex(String[][] objIndexPage, String[][] objIndex, GameMode gm, Object obj, int mode) {
		
		if (obj.gmCode.get(gm).code.dataIndex.get(gm) == null) {
			obj.gmCode.get(gm).code.dataIndex.put(gm, new DataIndex());
		}
		
		if (mode == FLOPPY_DISK) {
			objIndexPage[gm.objectsId.get(obj)] = new String[] {String.format("$%1$02X", obj.gmCode.get(gm).code.dataIndex.get(gm).fd_ram_page + 0x60) };
			objIndex[gm.objectsId.get(obj)] = new String[] {String.format("$%1$02X", obj.gmCode.get(gm).code.dataIndex.get(gm).fd_ram_address >> 8), String.format("$%1$02X", obj.gmCode.get(gm).code.dataIndex.get(gm).fd_ram_address & 0x00FF) };
		} else if (mode == MEGAROM_T2) {
			objIndexPage[gm.objectsId.get(obj)] = new String[] {String.format("$%1$02X", obj.gmCode.get(gm).code.dataIndex.get(gm).t2_ram_page + 0x60) };
			objIndex[gm.objectsId.get(obj)] = new String[] {String.format("$%1$02X", obj.gmCode.get(gm).code.dataIndex.get(gm).t2_ram_address >> 8), String.format("$%1$02X", obj.gmCode.get(gm).code.dataIndex.get(gm).t2_ram_address & 0x00FF) };					
		}	
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private static void writeSndIndex(AsmSourceCode asmSndIndex, GameMode gameMode, int mode) {
		
		// Game Mode Common
		for (GameModeCommon common : gameMode.gameModeCommon) {
			if (common != null) {
				for (Entry<String, Object> object : common.objects.entrySet()) {
					for (Sound sound : object.getValue().sounds) {
						writeSndIndex(asmSndIndex, sound, gameMode, mode);
					}
				}
			}
		}
		
		// Objets du Game Mode
		for (Entry<String, Object> object : gameMode.objects.entrySet()) {
			for (Sound sound : object.getValue().sounds) {
				writeSndIndex(asmSndIndex, sound, gameMode, mode);
			}
		}
	}
	
	private static void writeSndIndex(AsmSourceCode asmSndIndex, Sound sound, GameMode gm, int mode) {
		asmSndIndex.addLabel(sound.name + " ");
		for (SoundBin sb : sound.sb) {
			String[] line = new String[]{"0","0","0","0","0"};
			if (sb.dataIndex.get(gm) != null || (mode == MEGAROM_T2 && !sb.inRAM)) {
				if (mode == FLOPPY_DISK) {
					line[0] = String.format("$%1$02X", sb.dataIndex.get(gm).fd_ram_page + 0x60);
					line[1] = String.format("$%1$02X", sb.dataIndex.get(gm).fd_ram_address >> 8);
					line[2] = String.format("$%1$02X", sb.dataIndex.get(gm).fd_ram_address & 0x00FF);
					line[3] = String.format("$%1$02X", sb.dataIndex.get(gm).fd_ram_endAddress >> 8);
					line[4] = String.format("$%1$02X", sb.dataIndex.get(gm).fd_ram_endAddress & 0x00FF);
				} else if (mode == MEGAROM_T2 && sb.inRAM) {
					line[0] = String.format("$%1$02X", sb.dataIndex.get(gm).t2_ram_page + 0x60);
					line[1] = String.format("$%1$02X", sb.dataIndex.get(gm).t2_ram_address >> 8);
					line[2] = String.format("$%1$02X", sb.dataIndex.get(gm).t2_ram_address & 0x00FF);
					line[3] = String.format("$%1$02X", sb.dataIndex.get(gm).t2_ram_endAddress >> 8);
					line[4] = String.format("$%1$02X", sb.dataIndex.get(gm).t2_ram_endAddress & 0x00FF);					
				} else if (mode == MEGAROM_T2 && !sb.inRAM) {
					line[0] = String.format("$%1$02X", sb.t2_page + 0x80);
					line[1] = String.format("$%1$02X", sb.t2_address >> 8);
					line[2] = String.format("$%1$02X", sb.t2_address & 0x00FF);
					line[3] = String.format("$%1$02X", sb.t2_endAddress >> 8);
					line[4] = String.format("$%1$02X", sb.t2_endAddress & 0x00FF);					
				}
			}
			asmSndIndex.addFcb(line);
		}
		asmSndIndex.addFcb(new String[] { "$00" });
	}	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	private static void writeBackgroundImageIndex(AsmSourceCode asmSndIndex, GameMode gm, int mode) {
		
		for (Entry<Act, PngToBottomUpB16Bin> img : gm.backgroundImages.entrySet()) {
			asmSndIndex.addLabel("Bgi_"+img.getValue().act.name + " ");
			String[] line = new String[]{"0","0","0"};
			if (img.getValue().dataIndex.get(gm) != null || (mode == MEGAROM_T2 && !img.getValue().inRAM)) {
				if (mode == FLOPPY_DISK) {
					line[0] = String.format("$%1$02X", img.getValue().dataIndex.get(gm).fd_ram_page + 0x60);
					line[1] = String.format("$%1$02X", img.getValue().dataIndex.get(gm).fd_ram_address >> 8);
					line[2] = String.format("$%1$02X", img.getValue().dataIndex.get(gm).fd_ram_address & 0x00FF);
				} else if (mode == MEGAROM_T2 && img.getValue().inRAM) {
					line[0] = String.format("$%1$02X", img.getValue().dataIndex.get(gm).t2_ram_page + 0x60);
					line[1] = String.format("$%1$02X", img.getValue().dataIndex.get(gm).t2_ram_address >> 8);
					line[2] = String.format("$%1$02X", img.getValue().dataIndex.get(gm).t2_ram_address & 0x00FF);
				} else if (mode == MEGAROM_T2 && !img.getValue().inRAM) {
					line[0] = String.format("$%1$02X", img.getValue().t2_page + 0x80);
					line[1] = String.format("$%1$02X", img.getValue().t2_address >> 8);
					line[2] = String.format("$%1$02X", img.getValue().t2_address & 0x00FF);
				}
			}
			asmSndIndex.addFcb(line);
		}
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void writeImgPgIndex(AsmSourceCode asmBuilder, GameMode gameMode, int mode) throws Exception {
		asmBuilder.addLabel("Img_Page_Index");	
		asmBuilder.addFcb(new String[] {"$00"});
		
		// Game Mode Common
		for (GameModeCommon common : gameMode.gameModeCommon) {
			if (common != null) {
				for (Entry<String, Object> object : common.objects.entrySet()) {
					writeImgPgIndex(asmBuilder, object.getValue().imageSet, object.getValue().imageSetInRAM, mode, gameMode);
				}
			}
		}
		
		// Objets du Game Mode
		for (Entry<String, Object> object : gameMode.objects.entrySet()) {
			writeImgPgIndex(asmBuilder, object.getValue().imageSet, object.getValue().imageSetInRAM, mode, gameMode);
		}
	}	
	
	private static void writeImgPgIndex(AsmSourceCode asmBuilder, ImageSetBin ibin, boolean objInRAM, int mode, GameMode gm) throws Exception {
		if (ibin != null && ((ibin.dataIndex != null && ibin.dataIndex.get(gm) != null) || (mode == MEGAROM_T2 && !objInRAM))) {
			if (mode == FLOPPY_DISK) {
				asmBuilder.addFcb(new String[] { String.format("$%1$02X", ibin.dataIndex.get(gm).fd_ram_page + 0x60) });
			} else if (mode == MEGAROM_T2) {
				if (objInRAM) {
					asmBuilder.addFcb(new String[] { String.format("$%1$02X", ibin.dataIndex.get(gm).t2_ram_page + 0x60) });
				} else {
					asmBuilder.addFcb(new String[] { String.format("$%1$02X", ibin.t2_page + 0x80) });
				}			
			}
		} else {
			asmBuilder.addFcb(new String[] {"$00"});			
		}
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void writeAniPgIndex(AsmSourceCode asmBuilder, GameMode gameMode, int mode) throws Exception {
		asmBuilder.addLabel("Ani_Page_Index");	
		asmBuilder.addFcb(new String[] {"$00"});
		
		// Game Mode Common
		for (GameModeCommon common : gameMode.gameModeCommon) {
			if (common != null) {
				for (Entry<String, Object> object : common.objects.entrySet()) {
					writeAniPgIndex(asmBuilder, object.getValue().animation, object.getValue().animationInRAM, mode, gameMode);
				}
			}
		}
		
		// Objets du Game Mode
		for (Entry<String, Object> object : gameMode.objects.entrySet()) {
			writeAniPgIndex(asmBuilder, object.getValue().animation, object.getValue().animationInRAM, mode, gameMode);
		}
	}	
	
	private static void writeAniPgIndex(AsmSourceCode asmBuilder, AnimationBin abin, boolean objInRAM, int mode, GameMode gm) throws Exception {
		if (abin != null && ((abin.dataIndex != null && abin.dataIndex.get(gm) != null) || (mode == MEGAROM_T2 && !objInRAM))) {
			if (mode == FLOPPY_DISK) {
				asmBuilder.addFcb(new String[] { String.format("$%1$02X", abin.dataIndex.get(gm).fd_ram_page + 0x60) });
			} else if (mode == MEGAROM_T2) {
				if (objInRAM) {
					asmBuilder.addFcb(new String[] { String.format("$%1$02X", abin.dataIndex.get(gm).t2_ram_page + 0x60) });
				} else {
					asmBuilder.addFcb(new String[] { String.format("$%1$02X", abin.t2_page + 0x80) });
				}			
			}
		} else {
			asmBuilder.addFcb(new String[] {"$00"});			
		}

	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void writeAniAsdIndex(AsmSourceCode asmBuilder, GameMode gameMode, int mode) throws Exception {
		asmBuilder.addLabel("Ani_Asd_Index");	
		asmBuilder.addFdb(new String[] {"$0000"});
		
		// Game Mode Common
		for (GameModeCommon common : gameMode.gameModeCommon) {
			if (common != null) {
				for (Entry<String, Object> object : common.objects.entrySet()) {
					writeAniAsdIndex(asmBuilder, object.getValue().animation, object.getValue().animationInRAM, mode, gameMode);
				}
			}
		}
		
		// Objets du Game Mode
		for (Entry<String, Object> object : gameMode.objects.entrySet()) {
			writeAniAsdIndex(asmBuilder, object.getValue().animation, object.getValue().animationInRAM, mode, gameMode);
		}
	}	
	
	private static void writeAniAsdIndex(AsmSourceCode asmBuilder, AnimationBin abin, boolean objInRAM, int mode, GameMode gm) throws Exception {
		if (abin != null && ((abin.dataIndex != null && abin.dataIndex.get(gm) != null) || (mode == MEGAROM_T2 && !objInRAM))) {
			if (mode == FLOPPY_DISK) {
				asmBuilder.addFdb(new String[] { String.format("$%1$04X", abin.dataIndex.get(gm).fd_ram_address & 0xFFFF) });
			} else if (mode == MEGAROM_T2) {
				if (objInRAM) {
					asmBuilder.addFdb(new String[] { String.format("$%1$04X", abin.dataIndex.get(gm).t2_ram_address & 0xFFFF) });
				} else {
					asmBuilder.addFdb(new String[] { String.format("$%1$04X", abin.t2_address & 0xFFFF) });
				}			
			}
		} else {
			asmBuilder.addFdb(new String[] {"$0000"});			
		}

	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	private static void compressData() throws Exception {
		logger.info("Compress data ...");
		
		for(Entry<String, GameMode> gm : game.gameModes.entrySet()) {
			logger.info("\t"+gm.getValue().name);
			if (!abortFloppyDisk) {	
				compressData(FLOPPY_DISK, gm.getValue().ramFD, gm.getValue().fdIdx, gm.getValue().name);
			}
			compressData(MEGAROM_T2, gm.getValue().ramT2, gm.getValue().t2Idx, gm.getValue().name);
		}
	}
	
	private static void compressData(int mode, RamImage ram, List<RAMLoaderIndex> ldi, String gmName) throws Exception {
		logger.debug("\t\t" + MODE_LABEL[mode] + "...");
		
		String tmpFile = Game.generatedCodeDirName+"RAM data/"+MODE_LABEL[mode]+"/";
		
		Enumeration<RAMLoaderIndex> edi = Collections.enumeration(ldi);
		while(edi.hasMoreElements()) {
			
			RAMLoaderIndex di = edi.nextElement();
			logger.debug("Page: " + di.ram_page+" "+String.format("$%1$04X", di.ram_address)+" "+String.format("$%1$04X", di.ram_endAddress));
			byte[] fileData = new byte[di.ram_endAddress-di.ram_address];
			int j = 0;
			
			for (int i = di.ram_address; i < di.ram_endAddress; i++) {
				fileData[j++] = ram.data[di.ram_page][i];
			}

			String filename = tmpFile+gmName+"_p"+String.format("%03d", di.ram_page)+"_"+String.format("0x%1$04X", di.ram_address)+"_"+String.format("0x%1$04X", di.ram_endAddress);
			File file = new File (filename+".raw");
			file.getParentFile().mkdirs();
			Files.write(Paths.get(filename+".raw"), fileData);

			if (game.exobin != null) {
				di.encBin = exomize(filename);
			} else {
				di.encBin = zx0(filename);
			}
			
		}
	}	
	
	/**
	 * Encode binary file with exomizer
	 * 
	 * @param binFile binary file to encode
	 * @return
	 */
	public static byte[] exomize(String binFile) {
		try {
			ProcessBuilder pb = new ProcessBuilder(game.exobin, "raw", "-B", "-b", "-P0", "-o", Paths.get(binFile+".exo").toString(), Paths.get(binFile+".raw").toString());
			pb.redirectErrorStream(true);
			Process p = pb.start();			
			BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
			String line;

			while((line=br.readLine())!=null){
				logger.debug("\t\t\t" + line);
			}

			if (p.waitFor() != 0) {
				throw new Exception ("Erreur de compression "+binFile);
			}
			return Files.readAllBytes(Paths.get(binFile+".exo"));

		} catch (Exception e) {
			e.printStackTrace();
			logger.debug(e); 
			return null;
		}
	}	
	
	/**
	 * Encode binary file with ZX0
	 * 
	 * @param binFile binary file to encode
	 * @return
	 */
	public static byte[] zx0(String binFile) {
		byte[] output = null;
        int[] delta = { 0 };
        
		try {
			byte[] data = Files.readAllBytes(Paths.get(binFile+".raw"));
			
			reverse(data);
			output = new Compressor().compress(new Optimizer().optimize(data, 0, 32640, 4, true), data, 0, true, false, delta);
			reverse(output);
			
			Files.write(Paths.get(binFile+".zx0"), output);			
			return output;

		} catch (Exception e) {
			e.printStackTrace();
			logger.debug(e); 
			return null;
		}
	}
	
	private static void reverse(byte[] array) {
	        int i = 0;
	        int j = array.length-1;
	        while (i < j) {
	            byte k = array[i];
	            array[i++] = array[j];
	            array[j--] = k;
	        }
	    }


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
		
	
	/**
	 * Effectue la compilation du code assembleur
	 * 
	 * @param asmFile fichier contenant le code assembleur a compiler
	 * @return
	 */

	private static int compileRAW(String asmFile, int mode) throws Exception {
		return compile(asmFile, "--raw", mode, null, DynamicContent.NOPAGE);
	}
	
	private static int compileRAW(String asmFile, int mode, GameMode gm, int page) throws Exception {
		return compile(asmFile, "--raw", mode, gm, page);
	}	

	private static int compileLIN(String asmFile, int mode, GameMode gm, int page) throws Exception {
		return compile(asmFile, "--decb", mode, gm, page);
	}

	private static int compile(String asmFile, String option, int mode, GameMode gm, int page) throws Exception {
		Path path = Paths.get(asmFile).toAbsolutePath().normalize();
		String asmFileName = FileUtil.removeExtension(asmFile);
		String binFile = asmFileName + ".bin";
		String lstFile = asmFileName + ".lst";
		String glbFile = asmFileName + ".glb";			
		String glbTmpFile = asmFileName + ".tmp";	
		
		if (mode==MEGAROM_T2)
			dynamicContentT2.patchSource(path);
		else if (mode==FLOPPY_DISK)
			dynamicContentFD.patchSource(path);
		
		File del = new File (binFile);
		del.delete();
		del = new File (lstFile);
		del.delete();
		del = new File (glbFile);
		del.delete();
		del = new File (glbTmpFile);
		del.delete();

		logger.debug("\t# Compile "+path.toString());
		
		List<String> command = new ArrayList<String>(List.of(game.lwasm,
				   path.toString(),
				   "--output=" + binFile,
				   "--list=" + lstFile,
				   "--6809",	
				   "--includedir="+path.getParent().toString(),
				   "--includedir=./",
				   "--symbol-dump=" + glbTmpFile,
				   Game.pragma				   
				   ));
		
		for (int i=0; i<Game.includeDirs.length; i++)
			command.add(Game.includeDirs[i]);
		
		if (Game.define != null && Game.define.length()>0) command.add(Game.define);
		if (mode==MEGAROM_T2) command.add("--define=T2");
		if (option != null && option.length() >0) command.add(option);
			
		logger.debug(command);
		Process p = new ProcessBuilder(command).inheritIO().start();
	
		int result = p.waitFor();
	
	    Pattern pattern = Pattern.compile("^.*[^\\}]\\sEQU\\s.*$", Pattern.MULTILINE);
	    FileInputStream input = new FileInputStream(glbTmpFile);
	    FileChannel channel = input.getChannel();
	    Path out = Paths.get(glbFile);
	    String data = "";

	    ByteBuffer bbuf = channel.map(FileChannel.MapMode.READ_ONLY, 0, (int) channel.size());
	    CharBuffer cbuf = Charset.forName("8859_1").newDecoder().decode(bbuf);

	    Matcher matcher = pattern.matcher(cbuf);
	    while (matcher.find()) {
	    	String match = matcher.group();
		    data += match + System.lineSeparator();
	    }
	    
	    Files.write(out, data.getBytes());
	    input.close();
	    
		if (mode==MEGAROM_T2)
			dynamicContentT2.savePatchLocations(path, out, gm, page);
		else if (mode==FLOPPY_DISK)
			dynamicContentFD.savePatchLocations(path, out, gm, page);
	    
		return result;
	}
	
	private static int getBINSize(String inAsmFile) {
		try {
			String asmFile = duplicateFilePrepend(inAsmFile, "", " SECTION GETSIZE\n");
			
			Path asmPath = Paths.get(asmFile).toAbsolutePath().normalize();
			
			Files.write(asmPath, (" ENDSECTION\n").getBytes(), StandardOpenOption.APPEND);
			
			String asmFileName = FileUtil.removeExtension(asmPath.toFile().toString());
			String binFile = asmFileName + ".bin";
			String lstFile = asmFileName + ".lst";
			
			dynamicContentFD.patchSourceNoTag(asmPath);
			dynamicContentT2.patchSourceNoTag(asmPath);
			
			logger.debug("\t# Compile : " + asmPath.toString());

			List<String> command = new ArrayList(List.of(game.lwasm,
										   asmPath.toString(),
										   "--output=" + binFile,
										   "--list=" + lstFile,
										   "--6809",	
										   "--includedir="+asmPath.getParent().toString(),
										   "--includedir=./",
										   "--obj",
										   Game.pragma));
			
			for (int i=0; i<Game.includeDirs.length; i++)
				command.add(Game.includeDirs[i]);
			
			if (Game.define != null && Game.define.length()>0) command.add(Game.define);
										   
			
			Process p = new ProcessBuilder(command)
					.directory(new File("."))
					.inheritIO().start();

			int result = p.waitFor();
			if (result != 0) {
				throw new Exception ("Error "+asmFile);
			}
			
			return LWASMUtil.countSize(lstFile);

		} catch (Exception e) {
			e.printStackTrace();
			logger.debug(e); 
			return -1;
		}
	}			
	
	public static String duplicateFile(String fileName) throws IOException {
		String basename = FileUtil.removeExtension(Paths.get(fileName).getFileName().toString());
		String destFileName = Game.generatedCodeDirName+basename+".asm";

		Path original = Paths.get(fileName);        
		Path copied = Paths.get(destFileName);
		Files.copy(original, copied, StandardCopyOption.REPLACE_EXISTING);
		return destFileName;
	}
	
	public static String duplicateFile(String fileName, String subDir) throws IOException {
		String basename = FileUtil.removeExtension(Paths.get(fileName).getFileName().toString());
		String destFileName = Game.generatedCodeDirName+subDir+"/"+basename+".asm";

		// Creation du chemin si les répertoires sont manquants
		File file = new File (destFileName);
		file.getParentFile().mkdirs();
		
		Path original = Paths.get(fileName);        
		Path copied = Paths.get(destFileName);
		Files.copy(original, copied, StandardCopyOption.REPLACE_EXISTING);
		return destFileName;
	}	
	
	public static String duplicateFilePrepend(String fileName, String subDir, String prepend) throws IOException {
		String basename = FileUtil.removeExtension(Paths.get(fileName).getFileName().toString());
		String destFileName = Game.generatedCodeDirName+subDir+"/"+basename+".asm";
		
		// Creation du chemin si les répertoires sont manquants
		File file = new File (destFileName);
		file.getParentFile().mkdirs();
		
		List<String> result = new ArrayList<>();
		result.add(prepend);
	    try (Stream<String> lines = Files.lines(Paths.get(fileName))) {
	        result.addAll(lines.collect(Collectors.toList()));
	    }
		
	    Files.write(Paths.get(destFileName), result);
		
		return destFileName;
	}				

	public static String getBINFileName (String name) {
		return FileUtil.removeExtension(name)+".bin";
	}

	public static String getEXOFileName (String name) {
		return FileUtil.removeExtension(name)+".exo";
	}
	
	public static Path createFile (String fileName) throws Exception {
		return createFile (fileName, "");
	}
	
	public static Path createFile (String fileName, String subDir) throws Exception {	
		
		String newFileName = Game.generatedCodeDirName + subDir + "/" + fileName;
		
		// Creation du chemin si les répertoires sont manquants
		File file = new File (newFileName);
		file.getParentFile().mkdirs();
		file.createNewFile();
		
		return Paths.get(newFileName);
	}		
}