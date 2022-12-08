package fr.bento8.to8.compiledSprite.backupDrawErase.patterns;

public class Pattern_11111111 extends PatternStackBlast {

	public Pattern_11111111() {
		nbPixels = 8;
		nbBytes = nbPixels/2;
		useIndexedAddressing = false;
		isBackgroundBackupAndDrawDissociable = false;
		registerCombi.add(new boolean[] {false, false, true, true, false, false, false});
		registerCombi.add(new boolean[] {false, false, true, false, true, false, false});
		registerCombi.add(new boolean[] {false, false, false, true, true, false, false});
	}

	public boolean matchesForward (byte[] data, Integer offset) {
		if (offset+7 >= data.length) {
			return false;
		}
		return (data[offset] != 0x00 && data[offset+1] != 0x00 && data[offset+2] != 0x00 && data[offset+3] != 0x00 && data[offset+4] != 0x00 && data[offset+5] != 0x00 && data[offset+6] != 0x00 && data[offset+7] != 0x00);
	}
	
	public boolean matchesRearward (byte[] data, Integer offset) {
		if (offset-6 < 0) {
			return false;
		}
		return (data[offset-6] != 0x00 && data[offset-5] != 0x00 && data[offset-4] != 0x00 && data[offset-3] != 0x00 && data[offset-2] != 0x00 && data[offset-1] != 0x00 && data[offset] != 0x00 && data[offset+1] != 0x00);
	}
}
