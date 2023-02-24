package fr.bento8.arcade.rtype;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Rom {
	
	public String filepath;
	
	public byte[] maincpu = new byte[0x100000];
	public byte[] gfx1 = new byte[0x80000];
	public byte[] gfx2 = new byte[0x20000];
	public byte[] gfx3 = new byte[0x20000];
	
	public Rom (String filepath) throws IOException {
		this.filepath = filepath;
		
		ROM_LOAD16_BYTE(maincpu, "rt_r-h0-b.1b", 0x00001);
		ROM_LOAD16_BYTE(maincpu, "rt_r-l0-b.3b", 0x00000);
		ROM_LOAD16_BYTE(maincpu, "rt_r-h1-b.1c", 0x20001);
		ROM_LOAD16_BYTE(maincpu, "rt_r-h1-b.1c", 0xe0001);
		ROM_LOAD16_BYTE(maincpu, "rt_r-l1-b.3c", 0x20000);
		ROM_LOAD16_BYTE(maincpu, "rt_r-l1-b.3c", 0xe0000);

		ROM_LOAD(gfx1, "rt_r-00.1h", 0x00000);    /* sprites */
		ROM_LOAD(gfx1, "rt_r-01.1j", 0x10000);
		ROM_LOAD(gfx1, "rt_r-01.1j", 0x18000);
		ROM_LOAD(gfx1, "rt_r-10.1k", 0x20000);
		ROM_LOAD(gfx1, "rt_r-11.1l", 0x30000);
		ROM_LOAD(gfx1, "rt_r-11.1l", 0x38000);
		ROM_LOAD(gfx1, "rt_r-20.3h", 0x40000);
		ROM_LOAD(gfx1, "rt_r-21.3j", 0x50000);
		ROM_LOAD(gfx1, "rt_r-21.3j", 0x58000);
		ROM_LOAD(gfx1, "rt_r-30.3k", 0x60000);
		ROM_LOAD(gfx1, "rt_r-31.3l", 0x70000);
		ROM_LOAD(gfx1, "rt_r-31.3l", 0x78000);

		ROM_LOAD(gfx2, "rt_b-a0.3c", 0x00000);    /* tiles #1 */
		ROM_LOAD(gfx2, "rt_b-a1.3d", 0x08000);
		ROM_LOAD(gfx2, "rt_b-a2.3a", 0x10000);
		ROM_LOAD(gfx2, "rt_b-a3.3e", 0x18000);

		ROM_LOAD(gfx3, "rt_b-b0.3j", 0x00000);    /* tiles #2 */
		ROM_LOAD(gfx3, "rt_b-b1.3k", 0x08000);
		ROM_LOAD(gfx3, "rt_b-b2.3h", 0x10000);
		ROM_LOAD(gfx3, "rt_b-b3.3f", 0x18000);
	}
	
	public void ROM_LOAD16_BYTE(byte[] data, String filename, int addr) throws IOException {
		Path path = Paths.get(filepath+"/"+filename);
		byte[] in = Files.readAllBytes(path);
		for (int i=0; i < in.length; i++) {
			data[addr+i*2] = in[i];
		}
	}
	
	public void ROM_LOAD(byte[] data, String filename, int addr) throws IOException {
		Path path = Paths.get(filepath+"/"+filename);
		byte[] in = Files.readAllBytes(path);
		for (int i=0; i < in.length; i++) {
			data[addr+i] = in[i];
		}
	}

}
