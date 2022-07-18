package fr.bento8.to8.audio;

import fr.bento8.to8.audio.YmVoice.OPNVoice;
import fr.bento8.to8.audio.YmVoice.OPNVoice.OPNSlotParam;

public class SmpsVoiceConverter {

	public static byte[] fIN = new byte[] {
	0x04,0x37,0x77,0x72,0x49,0x1F,0x1F,0x1F,0x1F,0x07,0x07,0x0A,
	0x0D,0x00,0x00,0x0B,0x0B,0x1F,0x1F,0x0F,0x0F,0x23,0x23,(byte) 0x80,(byte) 0x80
	};	
	
	public static void main(String[] args) throws Throwable {

		System.out.println("*** YM2612 to YM2413 Smps voice converter ***");
        byte[] result = estimateOPPLLVoice1234(0);
		System.out.printf("        fcb   $%02X,$%02X\n", result[0], result[1]);

	}
	
	public static byte[] estimateOPPLLVoice1324(int pos) {
		OPNVoice opn = new OPNVoice((byte) ((fIN[pos] & 0x38) >> 3), (byte) (fIN[pos] & 0x07), (byte) 0, (byte) 0,
				new OPNSlotParam((byte) ((fIN[pos + 1 + 0] & 0x70) >> 4), (byte) (fIN[pos + 1 + 0] & 0xF),
						(byte) (fIN[pos + 21 + 0] & 0x7F), (byte) ((fIN[pos + 5 + 0] & 0x70) >> 6),
						(byte) (fIN[pos + 5 + 0] & 0x1F), (byte) ((fIN[pos + 9 + 0] & 0x80) >> 7),
						(byte) (fIN[pos + 9 + 0] & 0x7F), (byte) (fIN[pos + 13 + 0] & 0x1F),
						(byte) ((fIN[pos + 17 + 0] & 0xF0) >> 4), (byte) (fIN[pos + 17 + 0] & 0xF), (byte) 0),
				new OPNSlotParam((byte) ((fIN[pos + 1 + 1] & 0x70) >> 4), (byte) (fIN[pos + 1 + 1] & 0xF),
						(byte) (fIN[pos + 21 + 1] & 0x7F), (byte) ((fIN[pos + 5 + 1] & 0x70) >> 6),
						(byte) (fIN[pos + 5 + 1] & 0x1F), (byte) ((fIN[pos + 9 + 1] & 0x80) >> 7),
						(byte) (fIN[pos + 9 + 1] & 0x7F), (byte) (fIN[pos + 13 + 1] & 0x1F),
						(byte) ((fIN[pos + 17 + 1] & 0xF0) >> 4), (byte) (fIN[pos + 17 + 1] & 0xF), (byte) 0),
				new OPNSlotParam((byte) ((fIN[pos + 1 + 2] & 0x70) >> 4), (byte) (fIN[pos + 1 + 2] & 0xF),
						(byte) (fIN[pos + 21 + 2] & 0x7F), (byte) ((fIN[pos + 5 + 2] & 0x70) >> 6),
						(byte) (fIN[pos + 5 + 2] & 0x1F), (byte) ((fIN[pos + 9 + 2] & 0x80) >> 7),
						(byte) (fIN[pos + 9 + 2] & 0x7F), (byte) (fIN[pos + 13 + 2] & 0x1F),
						(byte) ((fIN[pos + 17 + 2] & 0xF0) >> 4), (byte) (fIN[pos + 17 + 2] & 0xF), (byte) 0),
				new OPNSlotParam((byte) ((fIN[pos + 1 + 3] & 0x70) >> 4), (byte) (fIN[pos + 1 + 3] & 0xF),
						(byte) (fIN[pos + 21 + 3] & 0x7F), (byte) ((fIN[pos + 5 + 3] & 0x70) >> 6),
						(byte) (fIN[pos + 5 + 3] & 0x1F), (byte) ((fIN[pos + 9 + 3] & 0x80) >> 7),
						(byte) (fIN[pos + 9 + 3] & 0x7F), (byte) (fIN[pos + 13 + 3] & 0x1F),
						(byte) ((fIN[pos + 17 + 3] & 0xF0) >> 4), (byte) (fIN[pos + 17 + 3] & 0xF), (byte) 0));
		return opn.toOPL().toOPLLROMVoice();
	}

	public static byte[] estimateOPPLLVoice1234(int pos) {
		OPNVoice opn = new OPNVoice((byte) ((fIN[pos] & 0x38) >> 3), (byte) (fIN[pos] & 0x07), (byte) 0, (byte) 0,
				new OPNSlotParam((byte) ((fIN[pos + 1 + 0] & 0x70) >> 4), (byte) (fIN[pos + 1 + 0] & 0xF),
						(byte) (fIN[pos + 21 + 0] & 0x7F), (byte) ((fIN[pos + 5 + 0] & 0x70) >> 6),
						(byte) (fIN[pos + 5 + 0] & 0x1F), (byte) ((fIN[pos + 9 + 0] & 0x80) >> 7),
						(byte) (fIN[pos + 9 + 0] & 0x7F), (byte) (fIN[pos + 13 + 0] & 0x1F),
						(byte) ((fIN[pos + 17 + 0] & 0xF0) >> 4), (byte) (fIN[pos + 17 + 0] & 0xF), (byte) 0),
				new OPNSlotParam((byte) ((fIN[pos + 1 + 2] & 0x70) >> 4), (byte) (fIN[pos + 1 + 2] & 0xF),
						(byte) (fIN[pos + 21 + 2] & 0x7F), (byte) ((fIN[pos + 5 + 2] & 0x70) >> 6),
						(byte) (fIN[pos + 5 + 2] & 0x1F), (byte) ((fIN[pos + 9 + 2] & 0x80) >> 7),
						(byte) (fIN[pos + 9 + 2] & 0x7F), (byte) (fIN[pos + 13 + 2] & 0x1F),
						(byte) ((fIN[pos + 17 + 2] & 0xF0) >> 4), (byte) (fIN[pos + 17 + 2] & 0xF), (byte) 0),
				new OPNSlotParam((byte) ((fIN[pos + 1 + 1] & 0x70) >> 4), (byte) (fIN[pos + 1 + 1] & 0xF),
						(byte) (fIN[pos + 21 + 1] & 0x7F), (byte) ((fIN[pos + 5 + 1] & 0x70) >> 6),
						(byte) (fIN[pos + 5 + 1] & 0x1F), (byte) ((fIN[pos + 9 + 1] & 0x80) >> 7),
						(byte) (fIN[pos + 9 + 1] & 0x7F), (byte) (fIN[pos + 13 + 1] & 0x1F),
						(byte) ((fIN[pos + 17 + 1] & 0xF0) >> 4), (byte) (fIN[pos + 17 + 1] & 0xF), (byte) 0),
				new OPNSlotParam((byte) ((fIN[pos + 1 + 3] & 0x70) >> 4), (byte) (fIN[pos + 1 + 3] & 0xF),
						(byte) (fIN[pos + 21 + 3] & 0x7F), (byte) ((fIN[pos + 5 + 3] & 0x70) >> 6),
						(byte) (fIN[pos + 5 + 3] & 0x1F), (byte) ((fIN[pos + 9 + 3] & 0x80) >> 7),
						(byte) (fIN[pos + 9 + 3] & 0x7F), (byte) (fIN[pos + 13 + 3] & 0x1F),
						(byte) ((fIN[pos + 17 + 3] & 0xF0) >> 4), (byte) (fIN[pos + 17 + 3] & 0xF), (byte) 0));
		return opn.toOPL().toOPLLROMVoice();
	}

}