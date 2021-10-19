package fr.bento8.to8.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.LineNumberReader;
import java.nio.channels.FileChannel;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LWASMUtil {

	public static int countCycles(String lstFile) throws IOException {
		int cycles = 0;

		Path path = Paths.get(lstFile);
		Pattern regexp = Pattern.compile("^.*\\[[0-9]*\\]\\s*([0-9]+)\\s*.*$");
		Matcher matcher = regexp.matcher("");

		BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.ISO_8859_1);
		LineNumberReader lineReader = new LineNumberReader(reader);
		String line = null;
		while ((line = lineReader.readLine()) != null) {
			matcher.reset(line); //reset the input
			if(matcher.matches())
			{
				cycles = Integer.parseInt(matcher.group(1));
			}
		}      
		
		reader.close();		

		return cycles;
	}
	
	public static int countSize(String lstFile) throws IOException {
		int size = 0;

		Path path = Paths.get(lstFile);
		Pattern regexp = Pattern.compile("^([0-9A-F]{4}\\s([0-9A-F]+)\\s*.*)|(\\\\s{5}([0-9A-F]+))$");
		Matcher matcher = regexp.matcher("");

		BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.ISO_8859_1);
		LineNumberReader lineReader = new LineNumberReader(reader);
		String line = null;
		while ((line = lineReader.readLine()) != null) {
			matcher.reset(line); //reset the input
			if(matcher.matches())
			{
				if (matcher.group(2) != null) {
					size += matcher.group(2).length()/2;
				}
				if (matcher.group(3) != null) {
					size += matcher.group(3).length()/2;
				}				
			}
		}      

		reader.close();
		
		return size;
	}	
	
	public static int getSize(String binFile) throws IOException {
	    Path bin = Paths.get(binFile);
	    FileChannel imageFileChannel = FileChannel.open(bin);
	    int size = Math.toIntExact(imageFileChannel.size());
	    imageFileChannel.close();
		return size;
	}		
	
}