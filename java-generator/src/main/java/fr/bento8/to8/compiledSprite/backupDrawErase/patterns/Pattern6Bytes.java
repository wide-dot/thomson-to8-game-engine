package fr.bento8.to8.compiledSprite.backupDrawErase.patterns;

public class Pattern6Bytes extends PatternStackBlast {

	public Pattern6Bytes() {
		nbPixels = 12;
		nbBytes = nbPixels/2;
		useIndexedAddressing = false;
		isBackgroundBackupAndDrawDissociable = false;
		registerCombi.add(new boolean[] {false, false, true, true, true, false, false});
	}

	public boolean matchesForward (byte[] data, Integer offset) {
		if (offset+11 >= data.length) {
			return false;
		}
		return (data[offset] != 0x00 && data[offset+1] != 0x00 && data[offset+2] != 0x00 && data[offset+3] != 0x00 && data[offset+4] != 0x00 && data[offset+5] != 0x00 && data[offset+6] != 0x00 && data[offset+7] != 0x00 && data[offset+8] != 0x00 && data[offset+9] != 0x00 && data[offset+10] != 0x00 && data[offset+11] != 0x00);
	}

	public boolean matchesRearward (byte[] data, Integer offset) {
		if (offset-10 < 0) {
			return false;
		}
		return (data[offset-10] != 0x00 && data[offset-9] != 0x00 && data[offset-8] != 0x00 && data[offset-7] != 0x00 && data[offset-6] != 0x00 && data[offset-5] != 0x00 && data[offset-4] != 0x00 && data[offset-3] != 0x00 && data[offset-2] != 0x00 && data[offset-1] != 0x00 && data[offset] != 0x00 && data[offset+1] != 0x00);
	}
}
