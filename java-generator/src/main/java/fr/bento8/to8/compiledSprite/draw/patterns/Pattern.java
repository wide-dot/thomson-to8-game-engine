package fr.bento8.to8.compiledSprite.draw.patterns;

import java.util.ArrayList;
import java.util.List;

import fr.bento8.to8.InstructionSet.Register;

public abstract class Pattern {

	protected int nbPixels;
	protected int nbBytes;

	protected boolean useIndexedAddressing;
	protected boolean isBackgroundBackupAndDrawDissociable;	
	protected List<boolean[]> resetRegisters = new ArrayList<boolean[]>();
	protected List<boolean[]> registerCombi = new ArrayList<boolean[]>();

	public abstract boolean matchesForward (byte[] data, Integer offset);
	public abstract boolean matchesRearward (byte[] data, Integer offset);

	public abstract List<String> getDrawCode (byte[] data, int position, List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset) throws Exception;
	public abstract int getDrawCodeCycles (List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset) throws Exception;	
	public abstract int getDrawCodeSize (List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset) throws Exception;

	public List<String> getBackgroundCode (List<Integer> registerIndexesPUL, List<Integer> registerIndexesPSH, Integer offset) throws Exception {
		List<String> asmCode = new ArrayList<String>();

		// Quand on charge uniquement B pour un pattern D, il faut ajouter 1 à l'offset 
		if (registerIndexesPUL.get(0)==Register.B && nbBytes==2) {
			offset += 1;
		}
		asmCode.add("\tLD"+Register.name[registerIndexesPUL.get(0)]+" "+(offset!= 0?offset:"")+",U");

		return asmCode;
	}

	public int getBackgroundCodeCycles (List<Integer> registerIndexesPUL, List<Integer> registerIndexesPSH, Integer offset) throws Exception {
		int cycles = 0;
		
		// Quand on charge uniquement B pour un pattern D, il faut ajouter 1 à l'offset 
		if (registerIndexesPUL.get(0)==Register.B && nbBytes==2) {
			offset += 1;
		}
		cycles += Register.costIndexedLD[registerIndexesPUL.get(0)] + Register.getIndexedOffsetCost(offset);

		return cycles;
	}

	public int getBackgroundCodeSize (List<Integer> registerIndexesPUL, List<Integer> registerIndexesPSH, Integer offset) throws Exception {
		int size = 0;

		// Quand on charge uniquement B pour un pattern D, il faut ajouter 1 à l'offset 
		if (registerIndexesPUL.get(0)==Register.B && nbBytes==2) {
			offset += 1;
		}
		size += Register.sizeIndexedLD[registerIndexesPUL.get(0)] + Register.getIndexedOffsetSize(offset);

		return size;
	}	
	
	public static boolean areAllNull (Integer[] tab, boolean[] mask) {
		boolean result = true;
		for (int i = 0 ; i < tab.length; i++) {
			if (mask[i] && tab[i] != null) {
				result = false;
				break;
			}
				
		}
		return result;
	}
	
	public int getNbPixels() {
		return nbPixels;
	}

	public int getNbBytes() {
		return nbBytes;
	}

	public boolean useIndexedAddressing() {
		return useIndexedAddressing;
	}

	public List<boolean[]> getResetRegisters() {
		return resetRegisters;
	}

	public List<boolean[]> getRegisterCombi() {
		return registerCombi;
	}
	
	public boolean isBackgroundBackupAndDrawDissociable() {
		return isBackgroundBackupAndDrawDissociable;
	}	
}