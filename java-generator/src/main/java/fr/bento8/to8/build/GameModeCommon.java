package fr.bento8.to8.build;

import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;

import fr.bento8.to8.util.FileUtil;
import fr.bento8.to8.util.knapsack.Item;

public class GameModeCommon {

	public String name;
	public String fileName;
	public Item[] items;
		
	public HashMap<String, Object> objects = new HashMap<String, Object>();
	public AsmSourceCode glb;
	
	public GameModeCommon(GameMode gm, String fileName) throws Exception {
		
		this.fileName = fileName;
		this.name = FileUtil.removeExtension(Paths.get(fileName).getFileName().toString());
		
		glb = new AsmSourceCode(BuildDisk.createFile(name+".glb", FileNames.SHARED_ASSETS));
		
		Properties prop = new Properties();
		try {
			InputStream input = new FileInputStream(fileName);
			prop.load(input);
		} catch (Exception e) {
			throw new Exception("Impossible de charger le fichier de configuration: " + fileName, e);
		}

		// Objects
		// ********************************************************************
		
		HashMap<String, String[]> objectProperties = PropertyList.get(prop, "object");
		if (objectProperties == null) {
			throw new Exception("object not found in " + fileName);
		}
		
		// Chargement des fichiers de configuration des Objets
		Object object;
		for (Map.Entry<String,String[]> curObject : objectProperties.entrySet()) {
			BuildDisk.logger.debug("\tLoad Object "+curObject.getKey()+": "+curObject.getValue()[0]);
			
			if (!Game.allObjects.containsKey(curObject.getKey())) {
				object = new Object(gm, curObject.getKey(), curObject.getValue()[0]);
				Game.allObjects.put(curObject.getKey(), object);
			} else {
				object = Game.allObjects.get(curObject.getKey());
				object.addGameMode(gm);
			}					
			
			objects.put(curObject.getKey(), object);
		}		
	}
	
	public void registerNewGameMode(GameMode gm) throws Exception {
		for (Entry<String, Object> curObject : objects.entrySet() ) {
			curObject.getValue().addGameMode(gm);
		}
	}
}