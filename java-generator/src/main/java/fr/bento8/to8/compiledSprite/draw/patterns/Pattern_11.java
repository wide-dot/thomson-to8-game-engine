package fr.bento8.to8.compiledSprite.draw.patterns;

public class Pattern_11 extends PatternStackBlast {

	public Pattern_11() {
		nbPixels = 2;
		nbBytes = nbPixels/2;
		useIndexedAddressing = true;
		isBackgroundBackupAndDrawDissociable = true;
		registerCombi.add(new boolean[] {true, false, false, false, false, false, false});
		registerCombi.add(new boolean[] {false, true, false, false, false, false, false});
	}

	public boolean matchesForward (byte[] data, Integer offset) {
		if (offset+1 >= data.length) {
			return false;
		}
		return (data[offset] != 0x00 && data[offset+1] != 0x00);
	}
	
	public boolean matchesRearward (byte[] data, Integer offset) {
		if (offset < 0) {
			return false;
		}
		return (data[offset] != 0x00 && data[offset+1] != 0x00);
	}
}
