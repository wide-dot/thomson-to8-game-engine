package fr.bento8.to8.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.LineNumberReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class C6809Util {

	public static int countCycles(String lstFile) throws IOException {
		int cycles = 0;

		Path path = Paths.get(lstFile);
		Pattern regexp = Pattern.compile("^[\\s0-9]{7}\\s\\s([^\\s]+).*$");
		Matcher matcher = regexp.matcher("");

		BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.ISO_8859_1);
		LineNumberReader lineReader = new LineNumberReader(reader);
		String line = null;
		while ((line = lineReader.readLine()) != null) {
			matcher.reset(line); //reset the input
			if(matcher.matches())
			{
				String[] result = matcher.group(1).split("\\+");

				cycles += Integer.parseInt(result[0]);
				if (result.length == 2) {
					cycles += Integer.parseInt(result[1]);
				}
			}
		}      

		return cycles;
	}
	
	public static int countErrors(String lstFile) throws IOException {
		int errors = 0;

		Path path = Paths.get(lstFile);
		Pattern regexp = Pattern.compile("^([0-9]{6}) Total Errors.*$");
		Matcher matcher = regexp.matcher("");
		
		BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.ISO_8859_1);
		LineNumberReader lineReader = new LineNumberReader(reader);
		String line = null;
		while ((line = lineReader.readLine()) != null) {
			matcher.reset(line); //reset the input
			if(matcher.matches())
			{
				errors += Integer.parseInt(matcher.group(1));
			}
		}      

		return errors;
	}
}