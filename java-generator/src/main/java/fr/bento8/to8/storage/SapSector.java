package fr.bento8.to8.storage;

// based on jteo code from Gilles Fetis
public class SapSector{
	public byte format;
	public byte protection;
	public byte track;
	public byte sector;
	public byte data[] = new byte[Sap.SECT_SIZE];
	public byte crc1sect;
	public byte crc2sect;
	
	transient private int crcpuk_temp;

	public SapSector(int sapDriveSize, int drive, int track, int sector, byte[] data) {
		crcpuk_temp = 0xffff;
		sector++; // sector (1-16) instead of (0-15)
		
		format = 0;
		protection = 0;
		this.track = (byte) track;
		this.sector = (byte) (sector);
		for (int i = 0; i < Sap.SECT_SIZE; i++) {
			this.data[i] = data[(drive * sapDriveSize) + (track * Sap.TRACK_SIZE) + (sector * Sap.SECT_SIZE) + i];
		}

		crc_pukall(format);
		crc_pukall(protection);
		crc_pukall(track);
		crc_pukall(sector);

		for (int l_index = 0; l_index < Sap.SECT_SIZE; l_index++) {
			crc_pukall(data[l_index] ^ 0xB3);
		}

		crc1sect = (byte) ((crcpuk_temp >> 8) & 0xFF);
		crc2sect = (byte) (crcpuk_temp & 255);
	}

	private void crc_pukall(int c) {
		int index;

		index = (crcpuk_temp ^ c) & 0xf;
		crcpuk_temp = ((crcpuk_temp >> 4) & 0xfff) ^ Sap.puktable[index];

		c >>= 4;

		index = (crcpuk_temp ^ c) & 0xf;
		crcpuk_temp = ((crcpuk_temp >> 4) & 0xfff) ^ Sap.puktable[index];
	}
	
}