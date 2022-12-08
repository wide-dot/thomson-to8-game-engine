package fr.bento8.to8.compiledSprite.backupDrawErase.patterns;

public class Pattern_1111 extends PatternStackBlast {

	public Pattern_1111() {
		nbPixels = 4;
		nbBytes = nbPixels/2;
		useIndexedAddressing = true;
		isBackgroundBackupAndDrawDissociable = true;
		registerCombi.add(new boolean[] {false, false, true, false, false, false, false});
		registerCombi.add(new boolean[] {false, false, false, true, false, false, false});
		registerCombi.add(new boolean[] {false, false, false, false, true, false, false});
	}

	public boolean matchesForward (byte[] data, Integer offset) {
		if (offset+3 >= data.length) {
			return false;
		}
		return (data[offset] != 0x00 && data[offset+1] != 0x00 && data[offset+2] != 0x00 && data[offset+3] != 0x00);
	}
	
	public boolean matchesRearward (byte[] data, Integer offset) {
		if (offset-2 < 0) {
			return false;
		}
		return (data[offset-2] != 0x00 && data[offset-1] != 0x00 && data[offset] != 0x00 && data[offset+1] != 0x00);
	}
}
