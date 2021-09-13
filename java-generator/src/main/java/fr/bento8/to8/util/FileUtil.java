package fr.bento8.to8.util;

public class FileUtil {
	
	public static String removeExtension(String filename) {

		// Remove the extension.
		int extensionIndex = filename.lastIndexOf(".");
        return (extensionIndex < 0 ) ? filename :filename.substring(0, extensionIndex);				

	}

}