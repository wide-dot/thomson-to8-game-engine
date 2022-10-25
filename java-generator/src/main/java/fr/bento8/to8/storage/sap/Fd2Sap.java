package fr.bento8.to8.storage.sap;

import java.nio.file.Files;
import java.nio.file.Paths;

import fr.bento8.to8.util.FileUtil;

public class Fd2Sap {

	public static void main(String[] args) throws Exception {
		String inputFile = args[0];
		String outputDiskName = FileUtil.removeExtension(inputFile)+".sap";
		byte[] fdBytes = Files.readAllBytes(Paths.get(inputFile));
		Sap sap = new Sap(fdBytes, Sap.SAP_FORMAT1);
		sap.write(outputDiskName);
		System.out.println("Done.");
	}
	
}
