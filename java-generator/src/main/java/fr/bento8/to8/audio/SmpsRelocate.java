package fr.bento8.to8.audio;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import fr.bento8.to8.audio.YmVoice.OPNVoice;
import fr.bento8.to8.audio.YmVoice.OPNVoice.OPNSlotParam;

public class SmpsRelocate{

	private static int SMPS_VOICE = 0;
	private static int SMPS_NB_FM = 2;
	private static int SMPS_NB_PSG = 3;
	private static int SMPS_TEMPO = 5;
	private static int SMPS_FM_START = 6;
	private static int SMPS_FM_SIZE = 4;
	private static int SMPS_PSG_SIZE = 6;

	private static byte[] fIN;
	private static byte[] fOUT;
	private static int offset = 0;
	
	// for Sonic2 music            use parameters : "-4992 -m80"
	// for Sonic2 Staff Roll music use parameters : "-55191 -m80"
	// for Sonic2 sound fx         use parameters : "0 -z80"	
	// for Sonic1 or vgm2smps SMPS use parameters : "0 -m68"

	public static void main(String[] args) throws Throwable {

		System.out.println("*** YM2612 to YM2413 Smps converter ***");

		if (args.length != 3) {
			System.out.println("Arguments: inputfile address_offset voicefile");
			System.out.println(" the first parameter is the smps file.");
			System.out.println(" the second parameter is the address offset to apply to pointers in the smps file.");
			System.out.println(" ex: -10 will substract 10 to address pointers");
			System.out.println(" the third parameter is the type:");
			System.out.println(" -m80 : Z80 music");
			System.out.println(" -s80 : Z80 sound fx");
			System.out.println(" -m68 : 68K music");
			return;
		}

		fIN = Files.readAllBytes(Paths.get(args[0]));
		if (fIN == null) {
			System.out.println("Fatal: can't open input file");
			return;
		}
		
		offset = Integer.parseInt(args[1]);

		// Relocate Voice
		// ********************************************************************

		int voicePos = 0;
		int nbVoices = 0;
		
		if (args[2].equals("-m80")) {
		    voicePos = relocate(SMPS_VOICE);
		} else {
			voicePos = ((fIN[SMPS_VOICE] & 0xff) << 8) | (fIN[SMPS_VOICE+1] & 0xff);			
		}

		int curVoice = voicePos, dstVoice = voicePos;
		byte[] result;
		if (voicePos != 0) {
			while (curVoice<fIN.length) {
				result = estimateOPPLLVoice1234(curVoice);
				fIN[dstVoice++] = result[0];
				fIN[dstVoice++] = result[1];
				curVoice += 25;
				nbVoices++;
			}
		}
		
		if (args[2].equals("-m68")) {
			if (fIN[SMPS_TEMPO] == 0) {
				fIN[SMPS_TEMPO] = (byte) 0xff;
			} else {
				fIN[SMPS_TEMPO] = (byte) (((fIN[SMPS_TEMPO]-1)*256+fIN[SMPS_TEMPO]/2)/fIN[SMPS_TEMPO]);
			}
		}
		
		if (args[2].contains("-m")) {

			// Relocate Tracks
			// ********************************************************************		

			int nbFMTracks = fIN[SMPS_NB_FM];
			int pos = SMPS_FM_START;
			for (int i = 0; i < nbFMTracks; i++) {
				relocateTrack(pos, args[2]);
				pos += SMPS_FM_SIZE;
			}

			int nbPSGTracks = fIN[SMPS_NB_PSG];
			for (int i = 0; i < nbPSGTracks; i++) {
				relocateTrack(pos, args[2]);
				pos += SMPS_PSG_SIZE;
			}		

			while (pos < fIN.length) {
				// Coordination flags
				// ********************************************************************
				switch (fIN[pos]) {
				case (byte)0xE1:
					// TODO piste FM seulement, diviser le detune par (((53693100/15/72)/524288)/((53693100/14/72)/2097152))
					// TODO arrondir au plus près
					pos += 2;
					break;			
				case (byte)0xF0: //F0wwxxyyzz
					// TODO piste FM seulement, et appliquer un coef 4/(((53693100/15/72)/524288)/((53693100/14/72)/2097152)) a la valeur delta
					// TODO arrondir au plus près					
					// TODO tester si la valeur obtenue est > 255, on cap a 255 et on log un message
					//modulation(pos+2);
					pos += 5;
				break;			
				case (byte)0xF6: //$F6zzzz
				case (byte)0xF8: //$F8zzzz					
					relocateOffsetBack(pos+1, args[2]);
				pos += 3;
				break;
				case (byte)0xF7: //$F7xxyyzzzz
					relocateOffsetBack(pos+3, args[2]);
				pos += 5;
				break;
				case (byte)0xE0: case (byte)0xE2: case (byte)0xE5: case (byte)0xE6: case (byte)0xE8: case (byte)0xE9: case (byte)0xEA: case (byte)0xEB: case (byte)0xEF:
					pos += 2;
				break;				
				default:
					pos++;
					break;
				}			
			}
		}
		
		if (voicePos!=0) {
			fOUT = new byte[voicePos+(nbVoices*2)];
			for (int i=0; i<voicePos+(nbVoices*2); i++) {
				fOUT[i] = fIN[i];
			}		
		} else {
			fOUT = fIN;
		}
		
		Path path = Paths.get(args[0]+".smp");
		Files.write(path, fOUT);
	}

	private static int relocate (int pos) throws Exception {
		if (pos > fIN.length) {
			throw new Exception ("File is invalid.");
		}
		int address = ((fIN[pos+1] & 0xff) << 8) | (fIN[pos] & 0xff);
		address += offset;
		fIN[pos] = (byte) (address >> 8);
		fIN[pos+1] = (byte) (address);
		return address;
	}

	private static void relocateTrack (int pos, String mode) throws Exception {
		if (pos > fIN.length) {
			throw new Exception ("File is invalid.");
		}
		int address;
		if (mode.contains("80")) {
			address = ((fIN[pos+1] & 0xff) << 8) | (fIN[pos] & 0xff);
		} else {
			address = ((fIN[pos] & 0xff) << 8) | (fIN[pos+1] & 0xff);
		}
		address += offset;
		fIN[pos] = (byte) (address >> 8);
		fIN[pos+1] = (byte) (address);
	}

	private static void relocateOffsetBack (int pos, String mode) throws Exception {
		if (pos > fIN.length) {
			throw new Exception ("File is invalid.");
		}
		int address;
		if (mode.contains("80")) {
			address = ((fIN[pos+1] & 0xff) << 8) | (fIN[pos] & 0xff);
			address += offset-pos;			
		} else {
			address = ((fIN[pos] & 0xff) << 8) | (fIN[pos+1] & 0xff);
			address++;
		}
		fIN[pos] = (byte) (address >> 8);
		fIN[pos+1] = (byte) (address);
	}

	private static void modulation (int pos) throws Exception {
		if (pos > fIN.length) {
			throw new Exception ("File is invalid.");
		}
		int value = (fIN[pos] & 0xff);
		fIN[pos] = (byte) (Math.ceil(value/3.733333333));
	}	

	public static byte[] estimateOPPLLVoice1324 (int pos) {
		OPNVoice opn = new OPNVoice(
				(byte)((fIN[pos] & 0x38) >> 3),
				(byte)(fIN[pos] & 0x07),
				(byte)0,
				(byte)0,
				new OPNSlotParam((byte)((fIN[pos+1+0] & 0x70) >> 4), (byte)(fIN[pos+1+0] & 0xF), (byte)(fIN[pos+21+0] & 0x7F), (byte)((fIN[pos+5+0] & 0x70) >> 6), (byte)(fIN[pos+5+0] & 0x1F), (byte)((fIN[pos+9+0] & 0x80) >> 7), (byte)(fIN[pos+9+0] & 0x7F), (byte)(fIN[pos+13+0] & 0x1F), (byte)((fIN[pos+17+0] & 0xF0) >> 4), (byte)(fIN[pos+17+0] & 0xF), (byte)0),
				new OPNSlotParam((byte)((fIN[pos+1+1] & 0x70) >> 4), (byte)(fIN[pos+1+1] & 0xF), (byte)(fIN[pos+21+1] & 0x7F), (byte)((fIN[pos+5+1] & 0x70) >> 6), (byte)(fIN[pos+5+1] & 0x1F), (byte)((fIN[pos+9+1] & 0x80) >> 7), (byte)(fIN[pos+9+1] & 0x7F), (byte)(fIN[pos+13+1] & 0x1F), (byte)((fIN[pos+17+1] & 0xF0) >> 4), (byte)(fIN[pos+17+1] & 0xF), (byte)0),
				new OPNSlotParam((byte)((fIN[pos+1+2] & 0x70) >> 4), (byte)(fIN[pos+1+2] & 0xF), (byte)(fIN[pos+21+2] & 0x7F), (byte)((fIN[pos+5+2] & 0x70) >> 6), (byte)(fIN[pos+5+2] & 0x1F), (byte)((fIN[pos+9+2] & 0x80) >> 7), (byte)(fIN[pos+9+2] & 0x7F), (byte)(fIN[pos+13+2] & 0x1F), (byte)((fIN[pos+17+2] & 0xF0) >> 4), (byte)(fIN[pos+17+2] & 0xF), (byte)0),
				new OPNSlotParam((byte)((fIN[pos+1+3] & 0x70) >> 4), (byte)(fIN[pos+1+3] & 0xF), (byte)(fIN[pos+21+3] & 0x7F), (byte)((fIN[pos+5+3] & 0x70) >> 6), (byte)(fIN[pos+5+3] & 0x1F), (byte)((fIN[pos+9+3] & 0x80) >> 7), (byte)(fIN[pos+9+3] & 0x7F), (byte)(fIN[pos+13+3] & 0x1F), (byte)((fIN[pos+17+3] & 0xF0) >> 4), (byte)(fIN[pos+17+3] & 0xF), (byte)0)
				);
		return opn.toOPL().toOPLLROMVoice();
	}
	
	public static byte[] estimateOPPLLVoice1234 (int pos) {
		OPNVoice opn = new OPNVoice(
				(byte)((fIN[pos] & 0x38) >> 3),
				(byte)(fIN[pos] & 0x07),
				(byte)0,
				(byte)0,
				new OPNSlotParam((byte)((fIN[pos+1+0] & 0x70) >> 4), (byte)(fIN[pos+1+0] & 0xF), (byte)(fIN[pos+21+0] & 0x7F), (byte)((fIN[pos+5+0] & 0x70) >> 6), (byte)(fIN[pos+5+0] & 0x1F), (byte)((fIN[pos+9+0] & 0x80) >> 7), (byte)(fIN[pos+9+0] & 0x7F), (byte)(fIN[pos+13+0] & 0x1F), (byte)((fIN[pos+17+0] & 0xF0) >> 4), (byte)(fIN[pos+17+0] & 0xF), (byte)0),
				new OPNSlotParam((byte)((fIN[pos+1+2] & 0x70) >> 4), (byte)(fIN[pos+1+2] & 0xF), (byte)(fIN[pos+21+2] & 0x7F), (byte)((fIN[pos+5+2] & 0x70) >> 6), (byte)(fIN[pos+5+2] & 0x1F), (byte)((fIN[pos+9+2] & 0x80) >> 7), (byte)(fIN[pos+9+2] & 0x7F), (byte)(fIN[pos+13+2] & 0x1F), (byte)((fIN[pos+17+2] & 0xF0) >> 4), (byte)(fIN[pos+17+2] & 0xF), (byte)0),
				new OPNSlotParam((byte)((fIN[pos+1+1] & 0x70) >> 4), (byte)(fIN[pos+1+1] & 0xF), (byte)(fIN[pos+21+1] & 0x7F), (byte)((fIN[pos+5+1] & 0x70) >> 6), (byte)(fIN[pos+5+1] & 0x1F), (byte)((fIN[pos+9+1] & 0x80) >> 7), (byte)(fIN[pos+9+1] & 0x7F), (byte)(fIN[pos+13+1] & 0x1F), (byte)((fIN[pos+17+1] & 0xF0) >> 4), (byte)(fIN[pos+17+1] & 0xF), (byte)0),				
				new OPNSlotParam((byte)((fIN[pos+1+3] & 0x70) >> 4), (byte)(fIN[pos+1+3] & 0xF), (byte)(fIN[pos+21+3] & 0x7F), (byte)((fIN[pos+5+3] & 0x70) >> 6), (byte)(fIN[pos+5+3] & 0x1F), (byte)((fIN[pos+9+3] & 0x80) >> 7), (byte)(fIN[pos+9+3] & 0x7F), (byte)(fIN[pos+13+3] & 0x1F), (byte)((fIN[pos+17+3] & 0xF0) >> 4), (byte)(fIN[pos+17+3] & 0xF), (byte)0)
				);
		return opn.toOPL().toOPLLROMVoice();
	}	
	
}