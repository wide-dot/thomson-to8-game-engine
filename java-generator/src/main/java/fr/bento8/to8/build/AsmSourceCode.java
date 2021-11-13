package fr.bento8.to8.build;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;

public class AsmSourceCode
{
	private Path path;
	public String content = "";

	public AsmSourceCode(Path path) throws Exception {
		String content = "* Generated Code\n";
		this.path = path;
		Files.write(path, content.getBytes(StandardCharsets.ISO_8859_1));
	}	
	
	public AsmSourceCode() throws Exception {
	}		
	
	public void add(String text) {
		content += "\n"+text;
	}		

	public void appendComment(String comment) {
		content += " * "+comment;
	}
	
	public void addCommentLine(String comment) {
		content += "\n* "+comment;
	}		
	
	public void addConstant(String name, String value) {
		content += "\n" + name + " equ " + value; 
	}

	public void addLabel(String value) { 
		content += "\n" + value; 
	}

	public void addFdb(String[] value) {
		boolean firstpass = true;
		content += "\n        fdb   "; 
		for (int i = 0; i < value.length; i++ ) {
			if (firstpass) {
				firstpass = false;
			} else {
				content += ",";
			}
			content += value[i];
		}
	}

	public void addFcb(String[] value) {
		boolean firstpass = true;
		int i = 0;
		while (i < value.length) {
			if (i%14 == 0) {
				firstpass = true;
				content += "\n        fcb   ";
			}

			if (firstpass) {
				firstpass = false;
			} else {
				content += ",";
			}
			
			content += value[i++];
		}
	}
	
	public void addFcb(byte[] value) {
		boolean firstpass = true;
		int i = 0;
		while (i < value.length) {
			if (i%14 == 0) {
				firstpass = true;
				content += "\n        fcb   ";
			}

			if (firstpass) {
				firstpass = false;
			} else {
				content += ",";
			}
			
			content += "$"+String.format("%02X", value[i++] & 0xff);
		}
	}

	public void flush() {
		if(Files.exists(path)) {
			try {
				Files.write(path, content.getBytes(StandardCharsets.ISO_8859_1), StandardOpenOption.APPEND);
				content = "";
			} catch (IOException ioExceptionObj) {
				System.out.println("Problème à l'écriture du fichier "+path.getFileName()+": " + ioExceptionObj.getMessage());
			}
		} else {
			System.out.println(path.getFileName()+" introuvable.");
		}   
	}
}