package fr.bento8.to8.storage;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.util.FileUtil;

/**
 * @author Benoà®t Rousseau
 * @version 1.0
 *
 */
public class FdUtil {
	private static final Logger logger = LogManager.getLogger("log");

	public static int DRIVESIZE = 327680;
	private final byte[] fdBytes = new byte[DRIVESIZE*2];
	private int index = 0;

	public FdUtil() {
	}

	// fd2sd
	public static void main(String[] args) throws Exception {
		File fd = new File(args[0]);
		FdUtil fdu = new FdUtil();
		try {
			byte[] tmp = Files.readAllBytes(fd.toPath());
			if (tmp.length <= fdu.fdBytes.length) {
				for (int i = 0; i < tmp.length; i++) {
					fdu.fdBytes[i] = tmp[i];
				}
				fdu.saveToSd(FileUtil.removeExtension(args[0]));
			} else {
				System.out.println("Input file too big. Max "+DRIVESIZE*2+" bytes");
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * Positionne l'index d'écriture sur un secteur dans une image fd en fonction
	 * d'une unité, d'une piste et d'un numéro de secteur Un TO8 gère jusqu'a 4
	 * unités (têtes de lecture) soit deux lecteurs double face L'image fd permet le
	 * stockage de deux disquettes double face en un seul fichier
	 * 
	 * @param unité   numéro de l'unité (0-3)
	 * @param piste   numéro de la piste (0-79)
	 * @param secteur numéro du secteur (1-16)
	 */
	public void setIndex(int unite, int piste, int secteur) {
		if (unite < 0 || unite > 3 || piste < 0 || piste > 79 || secteur < 1 || secteur > 16) {
			logger.debug("DiskUtil.getIndex: paramètres incorrects");
			logger.debug("unité (0-3):" + unite + " piste (0-79):" + piste + " secteur (1-16):" + secteur);
		} else {
			index = (unite * 327680) + (piste * 4096) + ((secteur - 1) * 256);
		}
	}

	/**
	 * Positionne l'index d'écriture à  une valeur donnée
	 * 
	 * @param position Index d'écriture
	 */
	public void setIndex(int position) {
		index = position;
	}

	/**
	 * Récupère l'index d'écriture
	 * 
	 */
	public int getIndex() {
		return index;
	}

	/**
	 * Récupère l'unité
	 * 
	 */
	public int getUnit() {
		return index / 327680;
	}

	/**
	 * Récupère la piste
	 * 
	 */
	public int getTrack() {
		return (index - (getUnit() * 327680)) / 4096;
	}

	/**
	 * Récupère le secteur
	 * 
	 */
	public int getSector() {
		return ((index - (getTrack() * 4096) - (getUnit() * 327680)) / 256) + 1;
	}

	/**
	 * Positionne l'index d'écriture au secteur suivant avance de la piste si
	 * nécessaire avance de l'unité si nécessaire
	 * 
	 */
	public void nextSector() {
		index = Math.floorDiv(index, 256) * 256 + 256;
	}

	/**
	 * Eciture de données à  l'index courant dans le fichier fd monté en mémoire
	 * 
	 * @param bytes données à  copier
	 */
	public void write(byte[] bytes) {
		logger.debug("Ecriture Disquette en :" + index + " ($" + String.format("%1$04X", index) + ")");
		int i;
		for (i = 0; i < bytes.length; i++) {
			fdBytes[index + i] = bytes[i];
		}
		index += i;
	}

	/**
	 * Eciture de données à  l'index courant dans le fichier fd monté en mémoire
	 * 
	 * @param bytes données à copier
	 */
	public void write(byte[] bytes, int start, int length) {
		logger.debug("Ecriture Disquette en :" + index + " ($" + String.format("%1$04X", index) + ")");
		int i;
		for (i = start; i < start + length; i++) {
			fdBytes[index + i - start] = bytes[i];
		}
		index += i;
	}

	/**
	 * Eciture (et remplacement) du fichier fd
	 * 
	 * @param outputFileName nom du fichier a écrire
	 */
	public void save(String outputFileName) {
		Path outputFile = Paths.get(outputFileName + ".fd");
		try {
			Files.deleteIfExists(outputFile);
			Files.createFile(outputFile);
			Files.write(outputFile, fdBytes);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Eciture (et remplacement) du fichier sd
	 * 
	 * @param outputFileName nom du fichier a écrire
	 */
	public void saveToSd(String outputFileName) {
		final byte[] sdBytes = new byte[0x140000];

		// Génération des données au format .sd
		for (int ifd = 0, isd = 0; ifd < fdBytes.length; ifd++) {
			// copie des données fd
			sdBytes[isd] = fdBytes[ifd];
			isd++;
			// a chaque intervalle de 256 octets on ajoute 256 octets de valeur FF
			if ((ifd + 1) % 256 == 0)
				for (int i = 0; i < 256; i++)
					sdBytes[isd++] = (byte) 0xFF;
		}

		Path outputFile = Paths.get(outputFileName + ".sd");
		try {
			Files.deleteIfExists(outputFile);
			Files.createFile(outputFile);
			Files.write(outputFile, sdBytes);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void saveToSap(String outputDiskName) {
		Sap sap = new Sap(fdBytes, Sap.SAP_FORMAT2);
		sap.write(outputDiskName);
	}

}