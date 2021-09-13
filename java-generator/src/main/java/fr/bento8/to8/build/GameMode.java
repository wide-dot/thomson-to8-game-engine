package fr.bento8.to8.build;

import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import fr.bento8.to8.image.PngToBottomUpB16Bin;
import fr.bento8.to8.image.PngToBottomUpB16Bin;
import fr.bento8.to8.ram.RamImage;
import fr.bento8.to8.storage.RAMLoaderIndex;
import fr.bento8.to8.util.knapsack.Item;

public class GameMode {

	public String name;
	public String fileName;
	public ObjectBin code; // Main Engine
	
	public String engineAsmMainEngine;
	public List<GameModeCommon> gameModeCommon = new ArrayList<GameModeCommon>();	
	public HashMap<String, Object> objects = new HashMap<String, Object>();
	public HashMap<Object, Integer> objectsId = new HashMap<Object, Integer>();
	public HashMap<String, Palette> palettes = new HashMap<String, Palette>();
	public HashMap<String, Act> acts = new HashMap<String, Act>(); 
	public HashMap<Act, PngToBottomUpB16Bin> backgroundImages = new HashMap<Act, PngToBottomUpB16Bin>();
	public String actBoot;
	public AsmSourceCode glb;
	
	// Ram
	public Item[] items;
	public RamImage ramFD;
	public RamImage ramT2;	
	public int indexSizeFD;	
	public int indexSizeT2;

	// Storage Index
	public List<RAMLoaderIndex> fdIdx = new ArrayList<RAMLoaderIndex>();
	public List<RAMLoaderIndex> t2Idx = new ArrayList<RAMLoaderIndex>();
	
	public GameMode(String gameModeName, String fileName) throws Exception {
		
		this.name = gameModeName;
		this.fileName = fileName;
		
		glb = new AsmSourceCode(BuildDisk.createFile(FileNames.OBJECTID, name));
		this.ramFD = new RamImage(Game.nbMaxPagesRAM);	
		ramFD.mode = BuildDisk.FLOPPY_DISK;
		this.ramT2 = new RamImage(Game.nbMaxPagesRAM);
		ramT2.mode = BuildDisk.MEGAROM_T2;
		
		Properties prop = new Properties();
		try {
			InputStream input = new FileInputStream(fileName);
			prop.load(input);
		} catch (Exception e) {
			throw new Exception("Impossible de charger le fichier de configuration: " + fileName, e);
		}

		// Main Engine
		// ********************************************************************

		engineAsmMainEngine = prop.getProperty("engine.asm.mainEngine");
		if (engineAsmMainEngine == null) {
			throw new Exception("engine.asm.mainEngine not found in " + fileName);
		}

		// Game Mode Common
		// ********************************************************************

		HashMap<String, String[]> gameModeCommonProperties = PropertyList.get(prop, "gameModeCommon");
		
		if (gameModeCommonProperties != null && gameModeCommonProperties.size() >= 1) {
			
			// Chargement des fichiers de configuration du Game Mode Common
			for (Map.Entry<String,String[]> curGameModeCommon : gameModeCommonProperties.entrySet()) {
				
				BuildDisk.logger.debug("\tLoad Game Mode Common "+curGameModeCommon.getKey()+": "+curGameModeCommon.getValue()[0]);
				
				Integer i = 0;
				try {
					i = Integer.parseInt(curGameModeCommon.getKey());
				} catch (NumberFormatException nfe)
			    {
					BuildDisk.logger.fatal("In "+gameModeName+" GameMode definition, gameModeCommon."+curGameModeCommon.getKey()+" shoud be of type gameModeCommon.<n> where <n> is a number.\n" + nfe.getMessage());
				}
				
				// construction du catalgue des objets communs
				GameModeCommon newCommon;
				if (!Game.allGameModeCommons.containsKey(curGameModeCommon.getValue()[0])) {
					newCommon = new GameModeCommon(this, curGameModeCommon.getValue()[0]);
					Game.allGameModeCommons.put(curGameModeCommon.getValue()[0], newCommon);
				} else {
					newCommon = Game.allGameModeCommons.get(curGameModeCommon.getValue()[0]);
					newCommon.registerNewGameMode(this);
				}
				gameModeCommon.add(i, newCommon);
			}
		}
		
		// Objects
		// ********************************************************************
		
		HashMap<String, String[]> objectProperties = PropertyList.get(prop, "object");
		
		if (objectProperties == null)
			throw new Exception("object not found in " + fileName);
		
		// Chargement des fichiers de configuration des Objets
		Object object;
		for (Map.Entry<String,String[]> curObject : objectProperties.entrySet()) {
			BuildDisk.logger.debug("\tLoad Object "+curObject.getKey()+": "+curObject.getValue()[0]);
			
			if (!Game.allObjects.containsKey(curObject.getKey())) {
				object = new Object(this, curObject.getKey(), curObject.getValue()[0]);
				Game.allObjects.put(curObject.getKey(), object);
			} else {
				object = Game.allObjects.get(curObject.getKey());
				object.addGameMode(this);
			}			

			objects.put(curObject.getKey(), object);
		}	
		
		// Palettes
		// ********************************************************************
		
		HashMap<String, String[]> paletteProperties = PropertyList.get(prop, "palette");
		if (paletteProperties == null)
			throw new Exception("palette not found in " + fileName);
		
		// Chargement des fichiers de configuration des Palettes
		for (Map.Entry<String,String[]> curPalette : paletteProperties.entrySet()) {
			BuildDisk.logger.debug("\tLoad Palette "+curPalette.getKey()+": "+curPalette.getValue()[0]);
			palettes.put(curPalette.getKey(), new Palette(name, curPalette.getKey(), curPalette.getValue()[0]));
		}			

		// Act Sequence
		// ********************************************************************

		actBoot = prop.getProperty("actBoot");

		// Act Definition
		// ********************************************************************

		HashMap<String, String[]> actProperties = PropertyList.get(prop, "act");
		
		for (Map.Entry<String, String[]> curActProperty : actProperties.entrySet()) {
			if (!acts.containsKey(curActProperty.getKey().split("\\.",2)[0])) {
				acts.put(curActProperty.getKey().split("\\.",2)[0], new Act(curActProperty.getKey().split("\\.",2)[0]));
			}
			acts.get(curActProperty.getKey().split("\\.",2)[0]).setProperty(curActProperty.getKey().split("\\.",2)[1], curActProperty.getValue());
		}
	}
}