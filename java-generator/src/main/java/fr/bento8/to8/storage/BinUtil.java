package fr.bento8.to8.storage;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

/**
 * @author Benoît Rousseau
 * @version 1.0
 *
 */
public class BinUtil
{
	
	/**
	 * Format BIN
	 * Header: $00, Taille des données sur 16bits, Adresse de chargement sur 16bits
	 * Trailer: $FF $00 $00 $00 $00
	 * ex: compilation -bh (hybride)
	 * 00 00 80 B5 42 => Le header est répété tous les 128 octets, la taille est fixe, l'adresse �volue
	 * ex: compilation -bl (lineaire)
	 * 00 06 CE B5 42 => Le header est mentionné uniquement au début
	 * ex: compilation -bd (donnees)
	 * Pas de header ni de trailer
	 */
	
	public static int linearHeaderTrailerSize = 10;
	
	public static byte[] trailer = new byte[]{-1,0,0,0,0}; 
	
	public static int RawToLinear(String fileName, int address) throws Exception {
		
		byte[] data = Files.readAllBytes(Paths.get(fileName));
		byte[] header = new byte[5];
		
		header[0] = (byte) 0;
		header[1] = (byte) (data.length >> 8); 
		header[2] = (byte) (data.length & 0x00FF);
		header[3] = (byte) (address >> 8); 
		header[4] = (byte) (address & 0x00FF);		
		
		Files.deleteIfExists(Paths.get(fileName));
		Files.write(Paths.get(fileName), header,StandardOpenOption.CREATE);
		Files.write(Paths.get(fileName), data,StandardOpenOption.APPEND);
	    Files.write(Paths.get(fileName), trailer,StandardOpenOption.APPEND);	
	    
	    return data.length;
	}
}