package fr.bento8.to8.util;

import java.util.Optional;

public class FileUtil {
	
	public static String removeExtension(String filename) {

		// Remove the extension.
		int extensionIndex = filename.lastIndexOf(".");
        return (extensionIndex < 0 ) ? filename :filename.substring(0, extensionIndex);				

	}
	
	public static Optional<String> getExtensionByStringHandling(String filename) {
	    return Optional.ofNullable(filename)
	      .filter(f -> f.contains("."))
	      .map(f -> f.substring(filename.lastIndexOf(".") + 1));
	}		

}