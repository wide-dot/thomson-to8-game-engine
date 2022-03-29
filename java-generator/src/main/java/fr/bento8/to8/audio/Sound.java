package fr.bento8.to8.audio;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import fr.bento8.to8.storage.BinUtil;
import fr.bento8.to8.util.FileUtil;

public class Sound{

	public String name = "";
	public String soundFile;
	public List<SoundBin> sb = new ArrayList<SoundBin>();
	public boolean inRAM = false;
	
	public Sound (String name) {
		this.name = name;
	}
	
	public void setAllBinaries(String fileName, boolean inRAM) throws Exception {
		// split data based on content
		if (FileUtil.getExtensionByStringHandling(fileName).equals(Optional.of("smid"))) {
			processSmid(fileName);
		} else {
			process(fileName);
		}
	}	
	
	public void process(String fileName) throws Exception {
		// Split data in 16Ko chunks
		
		int pageSize = 0x4000 - BinUtil.linearHeaderTrailerSize;
		byte[] buffer = new byte[pageSize];
		byte[] data = Files.readAllBytes(Paths.get(fileName));		
		int i = 0, j = 0;		
		
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
	
	public void processSmid(String fileName) throws Exception {
		// Split data in 16Ko chunks
		// Handle datastructure to avoid cutting in middle of a message
		
		int pageSize = 0x4000 - BinUtil.linearHeaderTrailerSize;
		byte[] buffer = new byte[pageSize*2];
		byte[] data = Files.readAllBytes(Paths.get(fileName));				
		int i = 0, j = 0, si = 0, sj = 0;		
		
		while (j < data.length) {
			
			for (i = 0; i < (pageSize-1) && j < data.length;) {
				
				if (data[j] > 0) {
					buffer[i++] = data[j++]; // wait time (1 byte)
				} else if (data[j] == (byte) 0xf0) {
					while (data[j] != (byte) 0xf7) {
						buffer[i++] = data[j++]; // sysex
					}
					buffer[i++] = data[j++]; // sysex end flag
				} else if ((data[j] & 0b01100000) == (byte) 0b01000000) {
					buffer[i++] = data[j++]; // Cn or Dn Command use one data byte 
					buffer[i++] = data[j++];
				} else {
					buffer[i++] = data[j++]; // other commands are using two data byte
					buffer[i++] = data[j++];
					buffer[i++] = data[j++];
				}
				
				// save position for revert to last data chunk
				si = i;
				sj = j;				

			}
			
			// revert last data chunk to keep data under page size limit 
			if (i >= (pageSize-1)) {
				i = si;
				j = sj;
			}
			
			buffer[i++] = 0; // end of block marker
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