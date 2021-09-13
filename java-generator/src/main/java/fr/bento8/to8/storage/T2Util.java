package fr.bento8.to8.storage;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.ram.RamImage;

/**
 * @author BenoÃ®t Rousseau
 * @version 1.0
 *
 */
public class T2Util
{
	private static final Logger logger = LogManager.getLogger("log");	
	
    public static int NB_PAGES = 128;	
    public static int PAGE_SIZE = 0x4000;	
	public final byte[] t2Bytes = new byte[NB_PAGES*PAGE_SIZE];

	public T2Util() {
	}

	/**
	 * Eciture de données à l'index courant
	 * 
	 * @param bytes données à copier
	 */
	public void write(RamImage rom) {
		logger.debug("Ecriture T2 ...");

		for (int p = 0; p < rom.lastPage; p++) {
			for (int i=0; i < rom.data[p].length; i++) {
				t2Bytes[i+(p*PAGE_SIZE)] = rom.data[p][i];
			}
		}
	}
	
	/**
	 * Eciture (et remplacement) du fichier bin
	 * 
	 * @param outputFileName nom du fichier a écrire
	 */
	public void save(String outputFileName) {
		Path outputFile = Paths.get(outputFileName+".rom");
		try {
			Files.deleteIfExists(outputFile);
			Files.createFile(outputFile);
			Files.write(outputFile, t2Bytes);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}	
}