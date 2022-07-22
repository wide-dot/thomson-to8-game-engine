package fr.bento8.to8.build;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import fr.bento8.to8.boot.Bootloader;
import fr.bento8.to8.ram.RamImage;
import fr.bento8.to8.storage.SdUtil;
import fr.bento8.to8.storage.T2Util;
import fr.bento8.to8.util.FileUtil;

public class BuildT2CheckDisk
{
	private static T2Util t2 = new T2Util();
	private static SdUtil t2L = new SdUtil();	
	public static RamImage romT2 = new RamImage(Game.T2_NB_PAGES, true);	
		
	public static void main(String[] args) throws Throwable
	{
		try {
			buildT2Flash();
			
		} catch (Exception e) {
			System.out.println(e);
		}
	}
	
	private static void buildT2Flash() throws Exception {
		System.out.println("Build T2 Loader for SDDRIVE ...");
		
		String tmpFile = duplicateFile("./engine/boot/boot-t2-flash.asm");
		compileRAW(tmpFile);
		byte[] bin;
		
		// Traitement du binaire issu de la compilation et génération du secteur d'amorçage
		Bootloader bootLoader = new Bootloader();
		
		t2L.setIndex(0, 0, 1);
		t2L.write(bootLoader.encodeBootLoader(getBINFileName(tmpFile)));
		System.out.println("Write Megarom T.2 Boot to output file ...");

		String prepend = "Builder_End_Page equ "+(romT2.endPage+1)+"\n";
		prepend += "Builder_Progress_Step equ "+((Game.T2_NB_PAGES/(romT2.endPage+1))*256+(int)(256*(((double)Game.T2_NB_PAGES/(romT2.endPage+1))-(Game.T2_NB_PAGES/(romT2.endPage+1)))))+"\n";
		tmpFile = duplicateFilePrepend("./engine/megarom-t2/t2-test.asm", "", prepend);
		compileRAW(tmpFile);
		bin = Files.readAllBytes(Paths.get(getBINFileName(tmpFile)));
		
		t2L.setIndex(0, 0, 2);		
		t2L.write(bin);
		System.out.println("Write Megarom T.2 Loader to output file ...");
		
		t2.write(romT2);
		t2.save("./Disk/TEST");
		
		t2L.writeRom(t2.t2Bytes);		
		System.out.println("Write Megarom T.2 Data to output file ...");		
		
		t2L.save("./Disk/TEST");
		System.out.println("Build done !");	
	}	

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	/**
	 * Effectue la compilation du code assembleur
	 * 
	 * @param asmFile fichier contenant le code assembleur a compiler
	 * @return
	 */

	private static int compileRAW(String asmFile) throws Exception {
		return compile(asmFile, "--raw");
	}	

	private static int compile(String asmFile, String option) throws Exception {
		Path path = Paths.get(asmFile);
		String asmFileName = FileUtil.removeExtension(asmFile);
		String binFile = asmFileName + ".bin";
		String lstFile = asmFileName + ".lst";
		String glbFile = asmFileName + ".glb";			
		String glbTmpFile = asmFileName + ".tmp";

		System.out.println("\t# Compile "+path.toString());
		Process p = new ProcessBuilder("./lwasm.exe", path.toString(), "--output=" + binFile, "--list=" + lstFile, "--6809", "--define=T2", "--symbol-dump=" + glbTmpFile, option).start();
		BufferedReader br=new BufferedReader(new InputStreamReader(p.getErrorStream()));
		String line;

		while((line=br.readLine())!=null){
			System.out.println("\t"+line);
		}

		int result = p.waitFor();
		if (result != 0) {
			throw new Exception ("Error "+asmFile);
		}
		
	    Pattern pattern = Pattern.compile("^.*[^\\}]\\sEQU\\s.*$", Pattern.MULTILINE);
	    FileInputStream input = new FileInputStream(glbTmpFile);
	    FileChannel channel = input.getChannel();
	    Path out = Paths.get(glbFile);
	    String data = "";

	    ByteBuffer bbuf = channel.map(FileChannel.MapMode.READ_ONLY, 0, (int) channel.size());
	    CharBuffer cbuf = Charset.forName("8859_1").newDecoder().decode(bbuf);

	    Matcher matcher = pattern.matcher(cbuf);
	    while (matcher.find()) {
	    	String match = matcher.group();
		    data += match + System.lineSeparator();
	    }
	    
	    Files.write(out, data.getBytes());
	    input.close();
		return result;
	}
	
	public static String duplicateFilePrepend(String fileName, String subDir, String prepend) throws IOException {
		String basename = FileUtil.removeExtension(Paths.get(fileName).getFileName().toString());
		String destFileName = "./generated-code/"+subDir+"/"+basename+".asm";

		// Creation du chemin si les répertoires sont manquants
		File file = new File (destFileName);
		file.getParentFile().mkdirs();
		
		List<String> result = new ArrayList<>();
		result.add(prepend);
	    try (Stream<String> lines = Files.lines(Paths.get(fileName))) {
	        result.addAll(lines.collect(Collectors.toList()));
	    }
		
	    Files.write(Paths.get(destFileName), result);
		
		return destFileName;
	}	
	
	public static String getBINFileName (String name) {
		return FileUtil.removeExtension(name)+".bin";
	}	
	
	public static String duplicateFile(String fileName) throws IOException {
		String basename = FileUtil.removeExtension(Paths.get(fileName).getFileName().toString());
		String destFileName = "./generated-code/"+basename+".asm";

		Path original = Paths.get(fileName);        
		Path copied = Paths.get(destFileName);
		Files.copy(original, copied, StandardCopyOption.REPLACE_EXISTING);
		return destFileName;
	}

}
