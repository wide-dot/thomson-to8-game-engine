package fr.bento8.to8.storage.sap;

// based on jteo code from Gilles Fetis
public class Sector{
	public byte format;
	public byte protection;
	public byte track;
	public byte sector;
	public byte data[];
	public byte crc1sect;
	public byte crc2sect;
	private int type;
	
	transient private int crcpuk;

	public Sector(int type, int drive, int track, int sector, byte[] data) {
		this.type = type;
		
		this.format = 0;
		this.protection = 0;
		this.track = (byte) track;
		this.sector = (byte) (sector+1);
		
		this.data = new byte[SapType.sectorSize[type]];
		int p = (drive * SapType.driveSize[type]) + (track * (Sap.NB_SECT * SapType.sectorSize[type])) + (sector * SapType.sectorSize[type]);
		for (int i = 0; i < SapType.sectorSize[type]; i++) {
			this.data[i] = (byte) (data[p+i]^Sap.SAP_MAGIC_NUM);
		}

		doCrc();
		
		crc1sect = (byte) ((crcpuk >> 8) & 0xff);
		crc2sect = (byte) (crcpuk & 0xff);
	}
	
	private void doCrc() {
		crcpuk = 0xffff;
		crcPukall(format);
		crcPukall(protection);
		crcPukall(track);
		crcPukall(sector);

		for (int l_index = 0; l_index < SapType.sectorSize[type]; l_index++) {
			crcPukall(data[l_index]^Sap.SAP_MAGIC_NUM);
		}		
	}
	
	private void crcPukall(int c) {
		int index;

		index = (crcpuk ^ c) & 0xf;
		crcpuk = ((crcpuk >> 4) & 0xfff) ^ Sap.puktable[index];

		c >>= 4;

		index = (crcpuk ^ c) & 0xf;
		crcpuk = ((crcpuk >> 4) & 0xfff) ^ Sap.puktable[index];
	}	
}