package fr.bento8.to8.boot;

import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Paths;

/**
 * @author Beno�t Rousseau
 * @version 1.0
 *
 */
public class DecodeBootloader {

	public static void main(String[] args)
	{
		try
		{
			if (args.length==1) {
				// Decodage d'un bootloader a partir d'une image disquette fd
				byte[] bootLoaderBytes = decodeBootLoader(args[0]);
				try (FileOutputStream fos = new FileOutputStream(args[0]+".bin")) {
					fos.write(bootLoaderBytes);
				}
				
				Process p = new ProcessBuilder("dasm6809.exe", args[0]+".bin", "6200").start();
				BufferedReader br=new BufferedReader(new InputStreamReader(p.getInputStream()));
				String line;

				while((line=br.readLine())!=null){
					System.out.println(line);
				}

				p.waitFor();
			}
			else {
				System.out.println("Parametres invalides !");
			}
		} 
		catch (Exception e)
		{
			e.printStackTrace(); 
			System.out.println(e); 
		}
	}

	public static byte[] decodeBootLoader(String file) {
		byte[] signature = {0x42, 0x41, 0x53, 0x49, 0x43, 0x32, 0x00}; // "BASIC2 "
		byte[] decodedBootLoader = new byte[128];
		int i;
		try {
			byte[] fd = Files.readAllBytes(Paths.get(file));

			for (i = 0; i < fd.length-signature.length; i++) {
				if (fd[i] == signature[0] && fd[i+1] == signature[1] && fd[i+2] == signature[2] && fd[i+3] == signature[3] && fd[i+4] == signature[4] && fd[i+5] == signature[5] && fd[i+6] == signature[6]) {
					for (int j = i-120, k = 0; j < i; j++) {
						decodedBootLoader[k++] = (byte) (256 - fd[j]);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(e);
		}
		return decodedBootLoader;
	}
}