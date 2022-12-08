package fr.bento8.to8.compiledSprite.draw.patterns;

import java.util.ArrayList;
import java.util.List;

import fr.bento8.to8.InstructionSet.Register;

public abstract class PatternStackBlast extends Pattern{

	public List<String> getDrawCode (byte[] data, int position, List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset) throws Exception {
		List<String> asmCode = new ArrayList<String>();
		String pixelValues;
		String pshs = "\tPSHU ";
		boolean firstPass;

		// loadMask :
		//    true = Ecrire le LD et avancer la position de lecture des data
		//    false = Ne pas ecrire le LD mais avancer la position de lecture des data
		//    null = Ne pas ecrire le LD et ne pas avancer la position de lecture des data

		// registerIndexes :
		//    Liste des index de registre pour l'écriture

		// Création du LD
		for (int i=0; i<loadMask.size(); i++) {
			if (loadMask.get(i) != null) {
				if (loadMask.get(i)) {
					if (Register.size[i] == 1) {
						pixelValues = String.format("%01x%01x", data[position]&0xff, data[position+1]&0xff);
						position += 2;
					} else {
						pixelValues = String.format("%01x%01x%01x%01x", data[position]&0xff, data[position+1]&0xff, data[position+2]&0xff, data[position+3]&0xff);
						position += 4;
					}
					asmCode.add("\tLD"+Register.name[i]+" #$"+pixelValues);
				} else {
					if (Register.size[i] == 1) {
						position += 2;
					} else {
						position += 4;
					}
				}
			}
		}

		if (this.nbBytes <= 2) {
			asmCode.add("\tST"+Register.name[registerIndexes.get(0)]+" "+(offset!= 0?offset:"")+",U");
		} else {
			// Création du PSHS
			firstPass = true;
			for (int i=0; i<registerIndexes.size(); i++) {
				if (firstPass) {
					pshs += Register.name[registerIndexes.get(i)];
					firstPass = false;
				} else {
					pshs += ","+Register.name[registerIndexes.get(i)];
				}
			}
			asmCode.add(pshs);
		}

		return asmCode;
	}

	public int getDrawCodeCycles (List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset) throws Exception {
		int cycles = 0, nbByte = 0;

		for (int i=0; i<loadMask.size(); i++) {
			if (loadMask.get(i) != null) {
				if (loadMask.get(i)) {
					cycles += Register.costImmediateLD[i];
				}
			}
		}

		if (this.nbBytes <= 2) {
			cycles += Register.costIndexedST[registerIndexes.get(0)];
			cycles += Register.getIndexedOffsetCost(offset);
		} else {
			for (int i=0; i<registerIndexes.size(); i++) {
				nbByte += Register.size[registerIndexes.get(i)];
			}
			cycles += Register.getCostImmediatePULPSH(nbByte);
		}
		
		return cycles;
	}

	public int getDrawCodeSize (List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset) throws Exception {
		int size = 0;

		for (int i=0; i<loadMask.size(); i++) {
			if (loadMask.get(i) != null) {
				if (loadMask.get(i)) {
					size += Register.sizeImmediateLD[i];
				}
			}
		}

		if (this.nbBytes <= 2) {
			size += Register.sizeIndexedST[registerIndexes.get(0)];
			size += Register.getIndexedOffsetSize(offset);
		} else {
			size += Register.sizeImmediatePULPSH;
		}
		
		return size;
	}
}