package fr.bento8.to8.audio;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import fr.bento8.to8.storage.BinUtil;

public class Sound{

	public String name = "";
	public String soundFile;
	public List<SoundBin> sb = new ArrayList<SoundBin>();
	public boolean inRAM = false;
	
	public Sound (String name) {
		this.name = name;
	}
	
	public void setAllBinaries(String fileName, boolean inRAM) throws Exception {
		int pageSize = 0x4000 - BinUtil.linearHeaderTrailerSize;
		byte[] buffer = new byte[pageSize];
		int i = 0, j = 0;
		
		byte[] data = Files.readAllBytes(Paths.get(fileName));
		
		while (j < data.length) {
			for (i = 0; i < pageSize && j < data.length; i++) {
				buffer[i] = data[j++];
			}
			int dataSize = i;
			byte[] writebuffer = new byte[dataSize];
			for (int k = 0; k < dataSize; k++) {
				writebuffer[k] = buffer[k];
			}

			SoundBin nsb = new SoundBin();
			nsb.bin = writebuffer;
			nsb.uncompressedSize = dataSize;
			nsb.inRAM = this.inRAM;
			sb.add(nsb);
		}
	}	
}