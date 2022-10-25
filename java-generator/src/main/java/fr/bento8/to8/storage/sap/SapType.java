package fr.bento8.to8.storage.sap;

public class SapType {
	public static int[] nbTracks = {0, 80, 40};
	public static int[] sectorSize = {0, 256, 128};
	public static int[] trackSize = {0, (Sap.SAP_SECTOR_META_SIZE+sectorSize[1])*Sap.NB_SECT, (Sap.SAP_SECTOR_META_SIZE*sectorSize[2])*Sap.NB_SECT};
	public static int[] driveSize = {0, Sap.SAP_HEADER_SIZE+nbTracks[1]*trackSize[1], Sap.SAP_HEADER_SIZE+nbTracks[2]*trackSize[2]};
}
