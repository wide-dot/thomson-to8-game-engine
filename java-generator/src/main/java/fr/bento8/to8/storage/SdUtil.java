package fr.bento8.to8.storage;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * @author Benoît Rousseau
 * @version 1.0
 *
 */
public class SdUtil
{
	private static final Logger logger = LogManager.getLogger("log");
	
	private final byte[] lbytes = new byte[2621440];
	private int index = 0;

	public SdUtil() {
	}

	/**
	 * Positionne l'index d'écriture sur un secteur dans une image fd
	 * en fonction d'une unité, d'une piste et d'un numéro de secteur
	 * Un TO8 gère jusqu'a 4 unités (têtes de lecture) soit deux lecteurs double face
	 * L'image fd permet le stockage de deux disquettes double face en un seul fichier
	 * 
	 * @param unité numéro de l'unité (0-7)
	 * @param piste numéro de la piste (0-79)
	 * @param secteur numéro du secteur (1-16)
	 */
	public void setIndex(int unite, int piste, int secteur) {
		if (unite < 0 || unite > 7 || piste < 0 || piste > 79 || secteur < 1 || secteur > 16) {
			logger.debug("DiskUtil.getIndex: paramètres incorrects");
			logger.debug("unité (0-7):"+unite+" piste (0-79):"+piste+" secteur (1-16):"+secteur);
		} else {
			index = (unite*327680)+(piste*4096)+((secteur-1)*256);
		}
	}
	
	/**
	 * Eciture de données à l'index courant dans le fichier fd monté en mémoire
	 * 
	 * @param bytes données à copier
	 */
	public void write(byte[] bytes) {
		logger.debug("Ecriture Disquette en :"+index+" ($"+String.format("%1$04X",index)+")");
		int i;
		for (i=0; i<bytes.length; i++) {
			lbytes[index+i] = bytes[i];
		}
		index+=i;
	}
	
	/**
	 * Eciture des données à partir d'une image ROM,
	 * répartit 16 pages sur chacune des 2 faces des 4 disquettes dans les pistes 16 à 79.
	 * 
	 * @param bytes données à copier
	 */
	public void writeRom(byte[] bytes) {
		logger.debug("Ecriture ROM sur disquette.");
		int end, i=0;

		for (int unite = 0; unite < 8; unite++) {
			setIndex(unite,16,1);
			end = index + 0x40000;
			while (index<end) {
				lbytes[index++] = bytes[i++];
			}
		}
	}
	
	/**
	 * Eciture (et remplacement) du fichier sd
	 * 
	 * @param outputFileName nom du fichier a écrire
	 */
	public void save(String outputFileName) {
		final byte[] sdBytes = new byte[5242880];

		// Génération des données au format .sd
		for (int ifd=0, isd=0; ifd<lbytes.length; ifd++) {
			// copie des données fd
			sdBytes[isd] = lbytes[ifd];
			isd++;
			// a chaque intervalle de 256 octets on ajoute 256 octets de valeur FF
			if ((ifd+1) % 256 == 0)
				for (int i=0; i<256; i++)
					sdBytes[isd++] = (byte) 0xFF;
		}

		Path outputFile = Paths.get(outputFileName+"_T2Loader.sd");
		try {
			Files.deleteIfExists(outputFile);
			Files.createFile(outputFile);
			Files.write(outputFile, sdBytes);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

}