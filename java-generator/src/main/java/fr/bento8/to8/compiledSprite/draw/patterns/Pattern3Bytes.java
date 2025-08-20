package fr.bento8.to8.compiledSprite.draw.patterns;

public class Pattern3Bytes extends PatternStackBlast {

	public Pattern3Bytes() {
		nbPixels = 6;
		nbBytes = nbPixels/2;
		useIndexedAddressing = false;
		isBackgroundBackupAndDrawDissociable = false;
		registerCombi.add(new boolean[] {true, false, false, true, false, false, false});
		registerCombi.add(new boolean[] {true, false, false, false, true, false, false});
		registerCombi.add(new boolean[] {false, true, false, true, false, false, false});
		registerCombi.add(new boolean[] {false, true, false, false, true, false, false});
	}

	public boolean matchesForward (byte[] data, Integer offset) {
		if (offset+5 >= data.length) {
			return false;
		}
		return (data[offset] != 0x00 && data[offset+1] != 0x00 && data[offset+2] != 0x00 && data[offset+3] != 0x00 && data[offset+4] != 0x00 && data[offset+5] != 0x00);
	}
	
	public boolean matchesRearward (byte[] data, Integer offset) {
		if (offset-4 < 0) {
			return false;
		}
		return (data[offset-4] != 0x00 && data[offset-3] != 0x00 && data[offset-2] != 0x00 && data[offset-1] != 0x00 && data[offset] != 0x00 && data[offset+1] != 0x00);
	}
}
