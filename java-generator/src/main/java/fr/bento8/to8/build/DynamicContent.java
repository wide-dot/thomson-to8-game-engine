package fr.bento8.to8.build;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DynamicContent
{
	public HashMap<String, HashMap<String, byte[]>> objectsMap = new HashMap<String, HashMap<String, byte[]>>();
	public HashMap<String, String[]> tags = new HashMap<String, String[]>();
	public HashMap<String, GameMode> tagsGm = new HashMap<String, GameMode>();
	public static String TAG = "gentag_";
	public static int NOPAGE = -1;
	private static AtomicLong idCounter = new AtomicLong();
	
	public DynamicContent() {
	}
	
	public byte[] get(String object, String method) {
		return objectsMap.get(object).get(method);
	}
	
	public void set(String object, String method, int nbBytes) {
		byte[] data = new byte[nbBytes];
		set(object, method, data);	
	}	

	public void set(String object, String method, byte[] data) {
		if (objectsMap.containsKey(object)) {
			objectsMap.get(object).put(method, data);
		} else {
			HashMap<String, byte[]> methodsMap = new HashMap<String, byte[]>();
			methodsMap.put(method, data);
			objectsMap.put(object, methodsMap);
		}			
	}		
	
	public void patchSource(Path path) throws IOException {
		List<String> fileContent = new ArrayList<>(Files.readAllLines(path, StandardCharsets.ISO_8859_1));
		Pattern p = Pattern.compile("(.*)INCLUDEGEN\\s*([a-zA-Z0-9_]+)\\s*([a-zA-Z0-9_]+)(.*)");      
		Matcher m;   
		
		for (int i = 0; i < fileContent.size(); i++) {
			m = p.matcher(fileContent.get(i));
		    if (m.matches()) {
		    	String tag = TAG+String.valueOf(idCounter.getAndIncrement());
		    	fileContent.add(i++, tag); // generate unique asm tag to be able to retreive compiled address of data table
		        fileContent.set(i, m.group(1)+"fill  0,"+get(m.group(2), m.group(3)).length+m.group(4));
		        tags.put(tag, new String[]{m.group(2), m.group(3), null, null}); // object, method, data dest page, data dest address
		    }
		}

		Files.write(path, fileContent, StandardCharsets.ISO_8859_1);
	}
	
	public void patchSourceNoTag(Path path) throws IOException {
		List<String> fileContent = new ArrayList<>(Files.readAllLines(path, StandardCharsets.ISO_8859_1));
		Pattern p = Pattern.compile("(.*)INCLUDEGEN\\s*([a-zA-Z0-9_]+)\\s*([a-zA-Z0-9_]+)(.*)");      
		Matcher m;   
		
		for (int i = 0; i < fileContent.size(); i++) {
			m = p.matcher(fileContent.get(i));
		    if (m.matches()) {
		        fileContent.set(i, m.group(1)+"fill  0,"+get(m.group(2), m.group(3)).length+m.group(4));
		    }
		}

		Files.write(path, fileContent, StandardCharsets.ISO_8859_1);
	}	
	
	public void savePatchLocations(Path path, GameMode gm, int page) throws IOException {
		if (gm == null) return;
		
		List<String> fileContent = new ArrayList<>(Files.readAllLines(path, StandardCharsets.ISO_8859_1));
		Pattern p = Pattern.compile("\\s*("+TAG+"[0-9]+)\\s+EQU\\s+\\$(\\S*)\\s*");
		Matcher m;   
		
		for (int i = 0; i < fileContent.size(); i++) {
			m = p.matcher(fileContent.get(i));
		    if (m.matches()) {
		        tags.put(m.group(1), new String[] {tags.get(m.group(1))[0], tags.get(m.group(1))[1], Integer.toString(page), m.group(2)});
		        tagsGm.put(m.group(1), gm);
		    }
		}
	}	
}