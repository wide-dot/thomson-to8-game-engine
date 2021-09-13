package fr.bento8.to8.compiledSprite.backupDrawErase.patterns;

import java.util.ArrayList;
import java.util.List;

import fr.bento8.to8.InstructionSet.Register;
import fr.bento8.to8.compiledSprite.backupDrawErase.Snippet;

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

	public List<String> getBackgroundBackupCode (List<Integer> registerIndexesPUL, List<Integer> registerIndexesPSH, Integer offset) throws Exception {
		List<String> asmCode = new ArrayList<String>();
		String pulu = "\tPULU ";
		String pshs = null;
		boolean firstPass;
		int nbBytesPulu = 0;

		for (Integer reg : registerIndexesPUL) {
			nbBytesPulu += Register.size[reg];
		}

		if (nbBytesPulu <= 2) {
			asmCode.add("\tLD"+Register.name[registerIndexesPUL.get(0)]+" "+(offset!= 0?offset:"")+",U");
		} else {
			firstPass = true;
			for (int i=0; i<registerIndexesPUL.size(); i++) {
				// Création du PULU
				if (firstPass) {
					pulu += Register.name[registerIndexesPUL.get(i)];
					firstPass = false;
				} else {
					pulu += ","+Register.name[registerIndexesPUL.get(i)];
				}
			}
			asmCode.add(pulu);
		}

		firstPass = true;
		for (int i=0; i<registerIndexesPSH.size(); i++) {
			// Création du PSHS
			if (firstPass) {
				pshs = "\tPSHS " + Register.name[registerIndexesPSH.get(i)];
				firstPass = false;
			} else {
				pshs += ","+Register.name[registerIndexesPSH.get(i)];
			}
		}
		if (pshs != null) {
			asmCode.add(pshs);
		}

		return asmCode;
	}

	public int getBackgroundBackupCodeCycles (List<Integer> registerIndexesPUL, List<Integer> registerIndexesPSH, Integer offset) throws Exception {
		int cycles = 0;
		int nbBytesPulu = 0;
		int nbBytesPshs = 0;

		for (Integer reg : registerIndexesPUL) {
			nbBytesPulu += Register.size[reg];
		}
		
		if (nbBytesPulu <= 2) {
			cycles += Register.costIndexedLD[registerIndexesPUL.get(0)] + Register.getIndexedOffsetCost(offset);
		} else {
			cycles += Register.getCostImmediatePULPSH(nbBytesPulu);
		}

		for (Integer reg : registerIndexesPSH) {
			nbBytesPshs += Register.size[reg];
		}
		if (nbBytesPshs > 0) {
			cycles += Register.getCostImmediatePULPSH(nbBytesPshs);
		}

		return cycles;
	}

	public int getBackgroundBackupCodeSize (List<Integer> registerIndexesPUL, List<Integer> registerIndexesPSH, Integer offset) throws Exception {
		int size = 0;
		int nbBytesPulu = 0;
		int nbBytesPshs = 0;

		for (Integer reg : registerIndexesPUL) {
			nbBytesPulu += Register.size[reg];
		}

		if (nbBytesPulu <= 2) {
			size += Register.sizeIndexedLD[registerIndexesPUL.get(0)] + Register.getIndexedOffsetSize(offset);
		} else {
			size += Register.sizeImmediatePULPSH;
		}
		
		for (Integer reg : registerIndexesPSH) {
			nbBytesPshs += Register.size[reg];
		}
		if (nbBytesPshs > 0) {
			size += Register.sizeImmediatePULPSH;
		}
		return size;
	}

	public static List<String> getEraseCodeBuf (List<Snippet> solution, List<Integer> regE, List<Integer> offsetE) throws Exception {
		boolean[] regECache = new boolean[]{false, false, false, false, false, false, false};
		Integer[] offsetECache = new Integer[]{null, null, null, null, null, null, null};
		List<String> asmECode = new ArrayList<String>();
		String read = "", writeSB = "";
		String readInit = "\tPULS ";
		String writeSBInit = "\tPSHU ";
		String writeSTInit = "\tST";
		List<String> writeST = new ArrayList<String>();
		List<Integer> currentRegisters = new ArrayList<Integer>();
		Integer offsetSB = 0;

		int posR = regE.size()-1;
		// Parcours de toutes les données sauvegardées et construction du code de retablissement du fond
		while (posR >= 0) {
			currentRegisters.clear();

			if (Register.size[regE.get(posR)] == 1) {
				if (!regECache[Register.A] && !regECache[Register.B] && !regECache[Register.D] && !regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.A);
					offsetECache[Register.A] = offsetE.get(posR);
				} else if (!regECache[Register.B] && !regECache[Register.D] && !regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.B);
					offsetECache[Register.B] = offsetE.get(posR);
				}
			} else if (Register.size[regE.get(posR)] == 2) {
				if (regE.get(posR) == Register.U) {
					currentRegisters.add(Register.U);
					offsetECache[Register.U] = offsetE.get(posR);
				} else if (!regECache[Register.A] && !regECache[Register.B] && !regECache[Register.D] && !regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.D);
					offsetECache[Register.D] = offsetE.get(posR);
				} else if (!regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.X);
					offsetECache[Register.X] = offsetE.get(posR);
				} else if (!regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.Y);
					offsetECache[Register.Y] = offsetE.get(posR);
				}
			}

			if (currentRegisters.size() > 0) {
				for (int i = 0; i < currentRegisters.size(); i++ ) {
					regECache[currentRegisters.get(i)] = true;
				}
				posR--;
			}

			if (currentRegisters.size() == 0 || posR < 0 || regECache[Register.U]) {
				
				// on ecrit les instructions du cache, on purge le cache et on reboucle sans modifier posR
				offsetSB = 0;
				for (int i = 0; i < regECache.length; i++ ) {
					if (regECache[i]) {

						// Construction du puls (lecture des données sauvegardées)
						if (read.contentEquals("")) {
							read = readInit + Register.name[i];
						} else {
							read += "," + Register.name[i];
						}

						// Construction du pshu (ecriture des données sauvegardées)
						// Le pshs est utilisé uniquement si le U a été sauvegardé avec le puls correspondant, sinon on utilise les ST
						if (offsetECache[i] == null && i != Register.U && regECache[Register.U] && areAllNull(offsetECache, regECache)) { // On ne traite pas U
							if (writeSB.contentEquals("")) {
								writeSB = writeSBInit + Register.name[i];
							} else {
								writeSB += "," + Register.name[i];
							}
						}

						// Construction des st (ecriture des données sauvegardées)
						if (offsetECache[i] == null && i != Register.U && regECache[Register.U] && !areAllNull(offsetECache, regECache)) {
							offsetSB += Register.size[i];
							writeST.add(writeSTInit + Register.name[i] + " "+offsetSB+",U");
						} else if (offsetECache[i] != null) {
							writeST.add(writeSTInit + Register.name[i] + " "+(offsetECache[i]!= 0?offsetECache[i]:"")+",U");
						}
					}
					regECache[i] = false;
					offsetECache[i] = null;
				}

				asmECode.add(read);
				if (!writeSB.contentEquals("")) {
					asmECode.add(writeSB);
				}
				if (writeST.size() > 0) {
					asmECode.addAll(writeST);
				}
				asmECode.add("");

				read = "";
				writeSB = "";
				writeST.clear();
			}
		}

		return asmECode;
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
	
	public static void placeU (boolean saveU, List<Snippet> solution, List<Integer> regE, List<Integer> offsetE) throws Exception {

		if (!saveU) {
			return;
		}
		
		// Ajout de la sauvegarde du pointeur U sur le dernier PSHS du noeud
		for (int i = solution.size()-1; i >= 0; i--) {
			if (solution.get(i).getMethod() == Snippet.BACKGROUND_BACKUP) {
				regE.add(regE.size()-solution.get(i).getRegisterIndexesPSH().size(), Register.U);
				offsetE.add(offsetE.size()-solution.get(i).getRegisterIndexesPSH().size(), null);
				solution.get(i).prependRegisterPSH(Register.U);
				break;
			}
		}
	}

	public static int getEraseCodeBufCycles (List<Snippet> solution, List<Integer> regE, List<Integer> offsetE) throws Exception {
		int cycles = 0;
		boolean[] regECache = new boolean[]{false, false, false, false, false, false, false};
		Integer[] offsetECache = new Integer[]{null, null, null, null, null, null, null};

		List<Integer> currentRegisters = new ArrayList<Integer>();
		Integer offsetSB = 0;

		int posR = regE.size()-1;
		// Parcours de toutes les données sauvegardées et construction du code de retablissement du fond
		while (posR >= 0) {
			currentRegisters.clear();

			if (Register.size[regE.get(posR)] == 1) {
				if (!regECache[Register.A] && !regECache[Register.B] && !regECache[Register.D] && !regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.A);
					offsetECache[Register.A] = offsetE.get(posR);
				} else if (!regECache[Register.B] && !regECache[Register.D] && !regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.B);
					offsetECache[Register.B] = offsetE.get(posR);
				}
			} else if (Register.size[regE.get(posR)] == 2) {
				if (regE.get(posR) == Register.U) {
					currentRegisters.add(Register.U);
					offsetECache[Register.U] = offsetE.get(posR);
				} else if (!regECache[Register.A] && !regECache[Register.B] && !regECache[Register.D] && !regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.D);
					offsetECache[Register.D] = offsetE.get(posR);
				} else if (!regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.X);
					offsetECache[Register.X] = offsetE.get(posR);
				} else if (!regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.Y);
					offsetECache[Register.Y] = offsetE.get(posR);
				}
			}

			if (currentRegisters.size() > 0) {
				for (int i = 0; i < currentRegisters.size(); i++ ) {
					regECache[currentRegisters.get(i)] = true;
				}
				posR--;
			}

			if (currentRegisters.size() == 0 || posR < 0 || regECache[Register.U]) {
				
				// on ecrit les instructions du cache, on purge le cache et on reboucle sans modifier posR
				offsetSB = 0;
				int nbBytePul = 0, nbBytePsh = 0;
				for (int i = 0; i < regECache.length; i++ ) {
					if (regECache[i]) {

						nbBytePul += Register.size[i];

						// Construction du pshu (ecriture des données sauvegardées)
						// Le pshu est utilisé uniquement si le U a été sauvegardé avec le puls correspondant, sinon on utilise les ST
						if (offsetECache[i] == null && i != Register.U && regECache[Register.U] && areAllNull(offsetECache, regECache)) { // On ne traite pas U
							nbBytePsh += Register.size[i];
						}

						// Construction des st (ecriture des données sauvegardées)
						if (offsetECache[i] == null && i != Register.U && regECache[Register.U] && !areAllNull(offsetECache, regECache)) {
							offsetSB += Register.size[i];
							cycles += Register.costIndexedST[i] + Register.getIndexedOffsetCost(offsetSB);
						} else if (offsetECache[i] != null) {
							cycles += Register.costIndexedST[i] + Register.getIndexedOffsetCost(offsetECache[i]);
						}
					}
					regECache[i] = false;
					offsetECache[i] = null;
				}
				
				cycles += Register.getCostImmediatePULPSH(nbBytePul);
				if (nbBytePsh>0) {
					cycles += Register.getCostImmediatePULPSH(nbBytePsh);
				}
			}
		}
		return cycles;
	}

	public static int getEraseCodeBufSize (List<Snippet> solution, List<Integer> regE, List<Integer> offsetE) throws Exception {
		int size = 0;
		boolean[] regECache = new boolean[]{false, false, false, false, false, false, false};
		Integer[] offsetECache = new Integer[]{null, null, null, null, null, null, null};

		List<Integer> currentRegisters = new ArrayList<Integer>();
		Integer offsetSB = 0;

		int posR = regE.size()-1;
		// Parcours de toutes les données sauvegardées et construction du code de retablissement du fond
		while (posR >= 0) {
			currentRegisters.clear();

			if (Register.size[regE.get(posR)] == 1) {
				if (!regECache[Register.A] && !regECache[Register.B] && !regECache[Register.D] && !regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.A);
					offsetECache[Register.A] = offsetE.get(posR);
				} else if (!regECache[Register.B] && !regECache[Register.D] && !regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.B);
					offsetECache[Register.B] = offsetE.get(posR);
				}
			} else if (Register.size[regE.get(posR)] == 2) {
				if (regE.get(posR) == Register.U) {
					currentRegisters.add(Register.U);
					offsetECache[Register.U] = offsetE.get(posR);
				} else if (!regECache[Register.A] && !regECache[Register.B] && !regECache[Register.D] && !regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.D);
					offsetECache[Register.D] = offsetE.get(posR);
				} else if (!regECache[Register.X] && !regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.X);
					offsetECache[Register.X] = offsetE.get(posR);
				} else if (!regECache[Register.Y] && !regECache[Register.U]) {
					currentRegisters.add(Register.Y);
					offsetECache[Register.Y] = offsetE.get(posR);
				}
			}

			if (currentRegisters.size() > 0) {
				for (int i = 0; i < currentRegisters.size(); i++ ) {
					regECache[currentRegisters.get(i)] = true;
				}
				posR--;
			}

			if (currentRegisters.size() == 0 || posR < 0 || regECache[Register.U]) {
				
				// on ecrit les instructions du cache, on purge le cache et on reboucle sans modifier posR
				offsetSB = 0;
				int nbBytePsh = 0;
				for (int i = 0; i < regECache.length; i++ ) {
					if (regECache[i]) {

						// Construction du pshu (ecriture des données sauvegardées)
						// Le pshu est utilisé uniquement si le U a été sauvegardé avec le puls correspondant, sinon on utilise les ST
						if (offsetECache[i] == null && i != Register.U && regECache[Register.U] && areAllNull(offsetECache, regECache)) { // On ne traite pas U
							nbBytePsh += Register.size[i];
						}

						// Construction des st (ecriture des données sauvegardées)
						if (offsetECache[i] == null && i != Register.U && regECache[Register.U] && !areAllNull(offsetECache, regECache)) {
							offsetSB += Register.size[i];
							size += Register.sizeIndexedST[i] + Register.getIndexedOffsetSize(offsetSB);
						} else if (offsetECache[i] != null) {
							size += Register.sizeIndexedST[i] + Register.getIndexedOffsetSize(offsetECache[i]);
						}
					}
					regECache[i] = false;
					offsetECache[i] = null;
				}
				
				size += Register.sizeImmediatePULPSH;
				if (nbBytePsh>0) {
					size += Register.sizeImmediatePULPSH;
				}
			}
		}		
		
		return size;
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

	public boolean isBackgroundBackupAndDrawDissociable() {
		return isBackgroundBackupAndDrawDissociable;
	}

	public List<boolean[]> getResetRegisters() {
		return resetRegisters;
	}

	public List<boolean[]> getRegisterCombi() {
		return registerCombi;
	}
}