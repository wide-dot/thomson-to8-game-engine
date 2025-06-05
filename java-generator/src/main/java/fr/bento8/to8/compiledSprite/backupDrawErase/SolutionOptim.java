package fr.bento8.to8.compiledSprite.backupDrawErase;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Random;
import java.util.function.Supplier;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.InstructionSet.Register;
import fr.bento8.to8.compiledSprite.backupDrawErase.patterns.Pattern;

public class SolutionOptim{

	private static final Logger logger = LogManager.getLogger("log");

	private int[] fact = new int[]{0, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880};
	private int maxTries;
	private int combMax;

	private Solution solution;
	private byte[] data;
	int sizesaveU;

	List<String> asmCode = new ArrayList<String>(); // Contient le code de sauvegarde du fond et du dessin de sprite
	List<String> asmECode = new ArrayList<String>(); // Contient le code d'effacement du sprite (restauration du fond)

	private int asmCodeCycles;
	private int asmCodeSize;
	private int asmECodeCycles;
	private int asmECodeSize;

	int lastLeau;
	// les variables Save sont pour les essais de solutions
	boolean[] regSet, regSetSave, regSetBest;
	byte[][] regVal, regValSave, regValBest;
	boolean[] regBBSet = new boolean[7];
	Integer[] offsetBBSet = new Integer[7];
	int regBBIdx = -1;

	// Variables pour le code de sauvegarde du fond
	List<List<Integer>> pshuGroup = new ArrayList<List<Integer>>();

	// Variables pour le code de retablissement du fond
	List<Integer> regE = new ArrayList<Integer>(), regEBest = new ArrayList<Integer>();
	List<Integer> offsetE = new ArrayList<Integer>(), offsetEBest = new ArrayList<Integer>();

	public SolutionOptim(Solution solution, byte[] data, int maxT) {
		this.solution = solution;
		this.data = data;
		this.maxTries = (maxT<0?0:maxT);
		
		// An image is made of patterns.
		// Patterns are organised in nodes.
		// Nodes are divided in groups of instructions.
		// The solution optim will try to rearrange the order of each groups inside a node
		// to get the fastest execution time.
		// Depending on the number of groups inside a node, the algorithm cannot try all combinations.
		// If the number of groups in a node is <= 9 this programm will try all the exact combinations.
		// If it's > 9, the we will try random orders in a limit of number of tries try (maxTries parameter).
		
		// The following code will handle the case when maxTries is lower than the number of combinations
		// when the nb of groups is <= 9, in this case the algorithm will be ramdom instead of "all" combinations
		combMax = 0;
		while (combMax < fact.length && maxTries >= fact[combMax]) {
			combMax++;				
		}
	}

	private void saveState(boolean[] saveSet, byte[][] saveVal) {
		// Sauvegarde de l'état des registres
		for (int i = 0; i < regSet.length; i++) {
			saveSet[i] = regSet[i];
		}

		for (int i = 0; i < regVal.length; i++) {
			for (int j = 0; j < regVal[0].length; j++) {
				saveVal[i][j] = regVal[i][j];	
			}
		}
	}
	
	private void restoreState(boolean[] saveSet, byte[][] saveVal) {

		// Rétablissement de l'état des registres
		for (int i = 0; i < regSet.length; i++) {
			regSet[i] = saveSet[i];
		}

		for (int i = 0; i < regVal.length; i++) {
			for (int j = 0; j < regVal[0].length; j++) {
				regVal[i][j] = saveVal[i][j];	
			}
		}
	}	

	private void restoreState() {

		regBBIdx = -1;
		for (int i = 0; i < regBBSet.length; i++) {
			regBBSet[i] = false;
			offsetBBSet[i] = null;
		}

		regE.clear();
		offsetE.clear();

		// Rétablissement de l'état des registres
		for (int i = 0; i < regSet.length; i++) {
			regSet[i] = regSetSave[i];
		}

		for (int i = 0; i < regVal.length; i++) {
			for (int j = 0; j < regVal[0].length; j++) {
				regVal[i][j] = regValSave[i][j];	
			}
		}
	}

	public List<Snippet> OptimizeUFactorial(List<List<Integer[]>> pattern, Integer lastPattern, boolean saveU, int[] ind) throws Exception {

		saveState(regSetSave, regValSave);

		// Initialisation de la solution
		Snippet s = null;
		List<Snippet> testSolution = new ArrayList<Snippet>();
		List<Snippet> bestSolution = new ArrayList<Snippet>();

		// Initialisation des contraintes
		HashMap<Integer, Boolean> constaints = new HashMap<Integer, Boolean>();
		Boolean isValidSolution = true;
		Boolean isOneValidSolution = false;		

		// Gestion des combinaisons		
		boolean has_next = true;
		int score = 0, bestScore = Integer.MAX_VALUE;

		// Optimisation de la liste
		while(has_next) {
			has_next = false;

			// Vérification des contraintes
			for (List<Integer[]> pl : pattern) {
				for (Integer[] p : pl) {
					if (p[0] != null) {
						constaints.put(p[0], true);
					}
					if (p[1] != null && !constaints.containsKey(p[1])) {
						isValidSolution = false;
						break;
					}
				}
			}
			
			// allow to tell if a failure is detected
	        if (isValidSolution)
	        	isOneValidSolution = true;			

			if (isValidSolution) {

				// Calcul de la proposition
				score = 0;
				s = null;
				for (List<Integer[]> pl : pattern) {
					for (Integer[] p : pl) {
						if (p[0] != null) {
							s = processPatternBackgroundBackup(p[0], saveU, s);
							testSolution.add(s);
						}
						if (p[1] != null) {
							testSolution.add(processPatternDraw(p[1], s));
						}
					}
				}

				if (lastPattern != null) {
					s = processPatternBackgroundBackup(lastPattern, saveU, s);
					testSolution.add(s);
					testSolution.add(processPatternDraw(lastPattern, s));
				}

				// flush du précédent pattern et purge des registres
				for (int i = regBBSet.length-1; i >= 0; i--) {
					if (regBBSet[i]) {
						s.addRegisterPSH(i);

						// Pour chaque registre sauvegardé dans les données du fond
						// On enregistre l'id du registre et l'offset associé
						// dans le cas d'un stack blast, on enregistre un index null
						regE.add(i);
						offsetE.add(offsetBBSet[i]);
					}
					regBBSet[i] = false;
					offsetBBSet[i] = null;
				}
				regBBIdx = -1;

				// Calcul des cycles pour la solution
				for (Snippet ts : testSolution) {
					score += ts.getCycles();
				}

				score = Pattern.getEraseCodeBufCycles_(testSolution, regE, offsetE, score, bestScore);

				if (score < bestScore) {
					bestScore = score;
					//logger.debug("score: "+score);
					bestSolution.clear();
					bestSolution.addAll(testSolution);
					regEBest.clear();
					regEBest.addAll(regE);
					offsetEBest.clear();
					offsetEBest.addAll(offsetE);
					saveState(regSetBest, regValBest);
				}

				testSolution.clear();
				restoreState();
			}

			constaints.clear();
			isValidSolution = true;

			// Génération de combinaisons uniques
			// Ne permute pas les éléments d'un même groupe
			for(int tail = ind.length - 1;tail > 0;tail--) {
				if (ind[tail - 1] < ind[tail]) {

					// trouve le dernier élément qui ne dépasse pas ind[tail-1]
					int l = ind.length - 1;
					while(ind[tail-1] >= ind[l])
						l--;

					swap(ind, tail-1, l);
					Collections.swap(pattern, tail-1, l);

					// inverse l'ordre en fin de tableau
					for(int i = tail, j = ind.length - 1; i < j; i++, j--){
						swap(ind, i, j);
						Collections.swap(pattern, i, j);
					}
					has_next = true;
					break;
				}
			}
		}
		
		if (!isOneValidSolution)
			throw new Exception("No valid solution after trying all combinations.");

		return bestSolution;
	}

	private void swap(int[] arr, int i, int j){
		int t = arr[i];
		arr[i] = arr[j];
		arr[j] = t;
	}

	Map<Object, Object> cache = new HashMap<>(); // use ConcurrentHashMap if needed

	<T> T getCached(Object key, Supplier<T> creator) {
		@SuppressWarnings("unchecked")
		T t = (T)cache.computeIfAbsent(Arrays.asList(key, Thread.currentThread()), x->creator.get());
		return t;
	}

	boolean generateSolution(List<List<Integer[]>> pattern) {
		Random rand = getCached("rand", Random::new);
		int size = pattern.size();
		if (size > 0) {
			int a = rand.nextInt(size);
			int b = rand.nextInt(size);
			Collections.swap(pattern, a, b);
		}

		// int max = 10_000;
		// Set<Object> uniq = getCached("uniq", () -> Collections.newSetFromMap(new LinkedHashMap<Object,Boolean>(max,  0.9f, true) {
		// 	protected boolean removeEldestEntry(Map.Entry<Object,Boolean> ignored) {
		// 		return size()>max;
		// 	}
		// }));
		// if(!uniq.add(new ArrayList<>(pattern))) return false;

		Map<Integer, Boolean> constaints = getCached("constraint", HashMap::new);
		constaints.clear();
		// Vérification des contraintes
		for (List<Integer[]> pl : pattern) {
			for (Integer[] p : pl) {
				if (p[0] != null) {
					constaints.put(p[0], true);
				}
				if (p[1] != null && !constaints.containsKey(p[1])) {
					return false;
				}
			}
		}
		return true;
	}

	public List<Snippet> OptimizeRandom(List<List<Integer[]>> pattern, Integer lastPattern, boolean saveU) throws Exception {

		saveState(regSetSave, regValSave);

		// Initialisation de la solution
		List<Snippet> bestSolution = new ArrayList<Snippet>();
		
		// Initialisation des contraintes
		boolean isOneValidSolution = false;

		// Test des combinaisons
		int bestScore = Integer.MAX_VALUE;
		int essais = maxTries;
		while (!isOneValidSolution || essais-- > 0) {
			
			if (essais == -500000)
				throw new Exception("No valid solution after more than 500000 tries.");
				
			boolean isValidSolution = generateSolution(pattern);
			
			// allow to override maxTries/essais until a solution is found
	        if (isValidSolution) {
	        	isOneValidSolution = true;
				bestScore = evalSolution(pattern, lastPattern, saveU, bestSolution, bestScore);
			}
		}
		return bestSolution;
	}

	private int evalSolution(List<List<Integer[]>> pattern, Integer lastPattern, boolean saveU, List<Snippet> bestSolution,
			int bestScore) throws Exception {
		List<Snippet> testSolution = new ArrayList<Snippet>();
		// Calcul de la proposition
		int score = 0;
		Snippet s = null;
		for (List<Integer[]> pl : pattern) {
			for (Integer[] p : pl) {
				if (p[0] != null) {
					s = processPatternBackgroundBackup(p[0], saveU, s);
					testSolution.add(s);
				}
				if (p[1] != null) {
					testSolution.add(processPatternDraw(p[1], s));
				}
			}
		}

		if (lastPattern != null) {
			s = processPatternBackgroundBackup(lastPattern, saveU, s);
			testSolution.add(s);
			testSolution.add(processPatternDraw(lastPattern, s));
		}

		// flush du précédent pattern et purge des registres
		for (int i = regBBSet.length-1; i >= 0; i--) {
			if (regBBSet[i]) {
				s.addRegisterPSH(i);

				// Pour chaque registre sauvegardé dans les données du fond
				// On enregistre l'id du registre et l'offset associé
				// dans le cas d'un stack blast, on enregistre un index null
				regE.add(i);
				offsetE.add(offsetBBSet[i]);
			}
			regBBSet[i] = false;
			offsetBBSet[i] = null;
		}
		regBBIdx = -1;

		// Calcul des cycles pour la solution
		for (Snippet ts : testSolution) {
			score += ts.getCycles();
			if(score>=bestScore) break;
		}

		score = Pattern.getEraseCodeBufCycles_(testSolution, regE, offsetE, score, bestScore);

		if (score < bestScore) {
			bestScore = score;
			//logger.debug("score: "+score);
			bestSolution.clear();
			bestSolution.addAll(testSolution);
			regEBest.clear();
			regEBest.addAll(regE);
			offsetEBest.clear();
			offsetEBest.addAll(offsetE);
			saveState(regSetBest, regValBest);
		}

		restoreState();
		return bestScore;
	}

	public void build() {
		asmCode.clear();
		asmECode.clear();
		asmCodeCycles = 0;
		asmCodeSize = 0;
		asmECodeCycles = 0;
		asmECodeSize = 0;

		regSet = new boolean[] {false, false, false, false, false, false, false};
		regSetBest = new boolean[] {false, false, false, false, false, false, false};
		regVal = new byte[7][4];
		regValBest = new byte[7][4];
		regSetSave = new boolean[] {false, false, false, false, false, false, false};
		regValSave = new byte[7][4];

		List<Snippet> bestSolution = new ArrayList<Snippet>();
		List<List<Integer[]>> patterns = new ArrayList<List<Integer[]>>();
		Integer lastPattern;

		lastLeau = Integer.MAX_VALUE;	
		int currentNode = 0;
		boolean saveU;
		sizesaveU = 0;

		int[] ind;
		HashMap<Integer, Integer> hm = new HashMap<Integer, Integer>();

		try {
			// Parcours de tous les patterns
			int i = 0;

			// Au début de l'image on sauvegarde U même s'il n'y a pas de LEAU
			saveU = true;
			Integer hash;

			while (i < solution.patterns.size()) {
				patterns.clear();
				lastPattern = null;

				currentNode = solution.computedNodes.get(i);
				hm.clear();
				int g = 0;
				Integer value1 = null, value2 = null, value3 = null, value4 = null;
				while (i < solution.patterns.size() && currentNode == solution.computedNodes.get(i)) {
					Integer leauOffset = solution.computedLeau.getOrDefault(currentNode, 0);
					// Ecriture du LEAU				
					if (currentNode != lastLeau // le noeud courant est différent de celui du dernier LEAU
					// && solution.computedLeau.containsKey(solution.computedNodes.get(i)) // Le noeud courant est un noeud de LEAU
					// && solution.computedLeau.get(solution.computedNodes.get(i)) != 0) { // Ignore les LEAU avec offset de 0
					&& leauOffset!=0) {
						asmCode.add("\tLEAU "+leauOffset+",U");
						asmCode.add("");
						asmCodeCycles += Register.costIndexedLEA + Register.getIndexedOffsetCost(leauOffset);
						asmCodeSize += Register.sizeIndexedLEA + Register.getIndexedOffsetSize(leauOffset);
						lastLeau = currentNode;
						saveU = true; // On enregistre le fait qu'un LEAU a été produit pour ce noeud
					}

					// Parcours des patterns et assignation d'un groupe
					// Split des patterns en deux (sauvegadre fond et écriture)
					Pattern currentPattern = solution.patterns.get(i);
					if (!currentPattern.isBackgroundBackupAndDrawDissociable() && currentPattern.useIndexedAddressing()) {
						value1 = null;
						value2 = null;
						value3 = null;
						value4 = null;
						hash = Objects.hash(0, currentPattern.getNbBytes(),
								currentPattern.isBackgroundBackupAndDrawDissociable(),
								Arrays.deepToString(currentPattern.getResetRegisters().toArray()), value1, value2, value3, value4);
						Integer n = hm.get(hash);
						if (n == null){
							hm.put(hash, g);
							n = g;
							patterns.add(new ArrayList<Integer[]>());
							g++;
						}
						patterns.get(n).add(new Integer[] {i, i});

					} else if (!currentPattern.useIndexedAddressing()) {
						// Le stack blast doit être positionné en fin de noeud pour être exécuté en début de rétablissement de fond
						// en particulier il doit être joué juste après le premier PULS ...,U car le PSHU va décaler le pointeur U
						// et le positonner correctement pour les accès mémoire indexées.
						// Si on veut le positionner ailleurs il faut recalculer les offsets : c'est réalisable ... mais risque d'être long à coder
						lastPattern = i;
					} else {
						value1 = null;
						value2 = null;
						value3 = null;
						value4 = null;
						//						hash = Objects.hash(0, solution.patterns.get(i).getNbBytes(),
						//								solution.patterns.get(i).isBackgroundBackupAndDrawDissociable(),
						//								Arrays.deepToString(solution.patterns.get(i).getResetRegisters().toArray()), value1, value2, value3, value4);
						//						Integer n = hm.get(hash);
						Integer n = null;
						if (n == null){
							n = g;
							//hm.put(hash, g);
							patterns.add(new ArrayList<Integer[]>());
							g++;
						}
						patterns.get(n).add(new Integer[] {i, null});

						if (currentPattern.getNbBytes() == 1) {
							value1 = (int)data[(solution.positions.get(i)*2)];
							value2 = (int)data[(solution.positions.get(i)*2)+1];
							value3 = null;
							value4 = null;
						} else {
							value1 = (int)data[(solution.positions.get(i)*2)];
							value2 = (int)data[(solution.positions.get(i)*2)+1];
							value3 = (int)data[(solution.positions.get(i)*2)+2];
							value4 = (int)data[(solution.positions.get(i)*2)+3];
						}

						hash = Objects.hash(1, solution.patterns.get(i).getNbBytes(),
								solution.patterns.get(i).isBackgroundBackupAndDrawDissociable(),
								Arrays.deepToString(solution.patterns.get(i).getResetRegisters().toArray()), value1, value2, value3, value4);
						n = hm.get(hash);
						if (n == null){
							hm.put(hash, g);
							n = g;
							patterns.add(new ArrayList<Integer[]>());
							g++;
						}
						patterns.get(n).add(new Integer[] {null, i});
					}

					i++;
				}		

				int nbPatterns = 0;
				ind = new int[patterns.size()];
				for (int j = 0; j < ind.length; j++) {
					ind[j] = j;
					nbPatterns += patterns.get(j).size();
				}

				//logger.debug("Noeud: "+currentNode+" nb. patterns: "+nbPatterns+" nb. groupes: "+ind.length);

				// Optimisation combinatoire
				if (ind.length < combMax) {
					bestSolution = OptimizeUFactorial(patterns, lastPattern, saveU, ind);
				} else {
					bestSolution = OptimizeRandom(patterns, lastPattern, saveU);
				}	

				// Enrichissement de la solution avec le positionnement de la sauvegarde du U
				Pattern.placeU(saveU, bestSolution, regEBest, offsetEBest);
				if (saveU)
					sizesaveU += 2;

				// Execution de la solution optimisée
				for (Snippet s : bestSolution) {
					asmCode.addAll(s.call());
					asmCodeCycles += s.getCycles();
					asmCodeSize += s.getSize();
				}
				restoreState(regSetBest, regValBest);
				
				//logger.debug("Cycles: "+asmCodeCycles);

				asmECode.addAll(0, Pattern.getEraseCodeBuf(bestSolution, regEBest, offsetEBest));
				asmECodeCycles += Pattern.getEraseCodeBufCycles(bestSolution, regEBest, offsetEBest);
				asmECodeSize += Pattern.getEraseCodeBufSize(bestSolution, regEBest, offsetEBest);

				//logger.debug("CyclesE: "+asmECodeCycles);
			}

			saveU = false;

		} catch (Exception e) {
			logger.fatal("", e);
		}
	}

	public Snippet processPatternBackgroundBackup(int id, boolean saveU, Snippet lastSnippet) throws Exception {

		List<Integer> selectedRegPUL = new ArrayList<Integer>();
		List<Integer> selectedRegPSH = new ArrayList<Integer>();
		Snippet snippet = null;
		
		int bestCombi = -1;
		int minIdx = 8;
		int bestMinIdx = 8;
		int bestMaxIdx = -1;
		int maxIdx = -1;
		boolean isValid = true;

		List<boolean[]> solution_patterns_id_RegisterCombi = solution.patterns.get(id).getRegisterCombi();
		// Parcours des combinaisons possibles
		// Selection de la combinaison qui satisfait les registres déjà occupés
		// et laisse un maximum de registres libres à droite
		for (int j = 0; j < solution_patterns_id_RegisterCombi.size() ; j++) {
			boolean[] solution_patterns_id_RegisterCombi_j = solution_patterns_id_RegisterCombi.get(j);

			for (int k = 0; k < solution_patterns_id_RegisterCombi_j.length; k++) {
				if (solution_patterns_id_RegisterCombi_j[k]) {
					if (k <= regBBIdx || (k == Register.D && regBBIdx <= Register.B)) {
						isValid = false;
						break;
					}
					if (k > maxIdx) {
						maxIdx = k;
					}
					if (k < minIdx) {
						minIdx = k;
					}
				}
			}
			if (isValid && minIdx < bestMinIdx) {
				bestMinIdx = minIdx;
				bestMaxIdx = maxIdx;
				bestCombi = j;
			}
			isValid = true;
			minIdx = solution_patterns_id_RegisterCombi.size()+1;
			maxIdx = -1;
		}

		if (bestCombi == -1) {
			// Il n'y plus la place pour une nouvelle combinaison
			// On rejoue la sélection mais sans la contrainte des précédents registres

			// flush du précédent pattern et purge des registres
			for (int i = regBBSet.length-1; i >= 0; i--) {
				if (regBBSet[i]) {
					lastSnippet.addRegisterPSH(i);

					// Pour chaque registre sauvegardé dans les données du fond
					// On enregistre l'id du registre et l'offset associé
					// dans le cas d'un stack blast, on enregistre un index null
					regE.add(i);
					offsetE.add(offsetBBSet[i]);
				}
				regBBSet[i] = false;
				offsetBBSet[i] = null;
			}
			regBBIdx = -1;
		

			for (int j = 0; j < solution_patterns_id_RegisterCombi.size() ; j++) {
				boolean[] registerCombi_id_j = solution_patterns_id_RegisterCombi.get(j);
				for(maxIdx = registerCombi_id_j.length; !registerCombi_id_j[--maxIdx];);
				for(minIdx = -1; minIdx<bestMinIdx && !registerCombi_id_j[++minIdx];);
				if (minIdx < bestMinIdx) {
					bestMinIdx = minIdx;
					bestMaxIdx = maxIdx;
					bestCombi = j;
				}
			}
		}

		regBBIdx = bestMaxIdx;

		// Parcours des registres de la combinaison
		boolean[] solution_patterns_id_RegisterCombi_bestCombi = solution_patterns_id_RegisterCombi.get(bestCombi);
		int solution_computedOffsets_id = solution.computedOffsets.get(id);

		for (int k = 0; k < solution_patterns_id_RegisterCombi_bestCombi.length; k++) {
			if (solution_patterns_id_RegisterCombi_bestCombi[k]) {
				// Le registre est utilisé dans la combinaison
				selectedRegPUL.add(k);
				regBBSet[k] = true;
				offsetBBSet[k] = solution_computedOffsets_id;
			}
		}

		// Sauvegarde de la méthode a exécuter
		snippet = new Snippet(solution.patterns.get(id), selectedRegPUL, selectedRegPSH, solution_computedOffsets_id, bestCombi);

		// Réinitialisation des registres utilisés par l'écriture du fond
		for (int r : selectedRegPUL) {
			regSet[r] = false;
			if (r == Register.A || r == Register.B) {
				regSet[Register.D] = false;
			}
			if (r == Register.D) {
				regSet[Register.A] = false;
				regSet[Register.B] = false;
			}
		}

		return snippet;
	}

	public Snippet processPatternDraw(int id, Snippet lastSnippet) throws Exception {

		// Recherche pour chaque combinaison de registres d'un pattern,
		// celle qui a le cout le moins élevé en fonction des registres déjà chargés

		int cycles, selectedCombi, minCycles, pos;
		byte b1, b2, b3 = 0x00, b4 = 0x00;
		List<Integer> currentReg = new ArrayList<Integer>();
		List<Boolean> currentLoadMask = new ArrayList<Boolean>();
		List<Integer> selectedReg = new ArrayList<Integer>();
		List<Boolean> selectedLoadMask = new ArrayList<Boolean>();
		Snippet snippet = null;
		List<boolean[]> combiList = new ArrayList<boolean[]>();
		List<boolean[]> resetRegList = new ArrayList<boolean[]>();

		selectedCombi = -1;
		minCycles = Integer.MAX_VALUE;

		// Parcours des combinaisons possibles de registres pour le pattern
		// Cas particulier:
		// Gestion des patterns non dissociables, on doit utiliser la même
		// combinaison que celle utilisée pour la sauvegarde du fond
		
		// Chaque combinaison n'utilise qu'une seule fois un registre donc pas la peine de sauver la valeur 
		// du registre dans le cache regSet et regVal, c'est fait uniquement pour la combinaison retenue dans la 
		// seconde partie de cette méthode
		
		// this force the use of the combi if backgroundbackup and draw is not dissociable
		Pattern solution_patterns_id = solution.patterns.get(id);
		if (!solution_patterns_id.isBackgroundBackupAndDrawDissociable() && solution_patterns_id.useIndexedAddressing()) {
			combiList.add(solution_patterns_id.getRegisterCombi().get(lastSnippet.getCombiIdx()));
			resetRegList.add(solution_patterns_id.getResetRegisters().get(lastSnippet.getCombiIdx()));
		} else {
			combiList = solution_patterns_id.getRegisterCombi();
			resetRegList = solution_patterns_id.getResetRegisters();
		}

		for (int j = 0; j < combiList.size(); j++) {
			cycles = 0;
			pos = solution.positions.get(id)*2;
			currentReg.clear();
			currentLoadMask.clear();

			// Parcours des registres de la combinaison
			boolean[] combiList_j = combiList.get(j);
			boolean[] resetRegList_j = j<resetRegList.size() ? resetRegList.get(j) : null;

			for (int k = 0; k < combiList_j.length; k++) {
				if (combiList_j[k]) {
					// Le registre est utilisé dans la combinaison
					currentReg.add(k);
					
					if (regSet[k] && (resetRegList_j==null || resetRegList_j[k] == false)) {
						// Le registre contient une valeur et n'est pas concerné par un reset dans le pattern
						
						// Chargement des données du sprite
						b1 = data[pos];
						b2 = data[pos+1];
						if (Register.size[k] == 2) {
							b3 = data[pos+2];
							b4 = data[pos+3];
						}							

						if (k == Register.D && regSet[Register.B] && (!regSet[Register.A] || (regSet[Register.A] && (regVal[k][0] != b1 || regVal[k][1] != b2) && regVal[k][2] == b3 && regVal[k][3] == b4))) {
							// Correspondance partielle sur D avec B mais pas A, on charge A
							currentLoadMask.set(Register.A, true);
							currentLoadMask.set(Register.B, false);
							currentLoadMask.add(null);

						} else if (k == Register.D && regSet[Register.A] && regVal[k][0] == b1 && regVal[k][1] == b2 && (!regSet[Register.B] || (regSet[Register.B] && (regVal[k][2] != b3 || regVal[k][3] != b4)))) {
							// Correspondance partielle sur D avec A mais pas B, on charge B
							currentLoadMask.set(Register.A, false);
							currentLoadMask.set(Register.B, true);
							currentLoadMask.add(null);

						} else if (regVal[k][0] == b1 && regVal[k][1] == b2 && (Register.size[k] == 1 || (Register.size[k] == 2 && regVal[k][2] == b3 && regVal[k][3] == b4))){
							// Le registre contient déjà la valeur, on ne charge rien
							currentLoadMask.add(false);

						} else {
							// Le registre contient une valeur différente, on le charge
							currentLoadMask.add(true);
						}
					} else {
						// Le registre ne contient pas de valeur, on le charge
						currentLoadMask.add(true);
					}
					pos += Register.size[k] * 2;
				} else {
					// Le registre n'est pas utilisé dans la combinaison
					currentLoadMask.add(null);
				}
			}

			// Calcul du nombre de cycles de la solution courante
			cycles = solution.patterns.get(id).getDrawCodeCycles(currentReg, currentLoadMask, solution.computedOffsets.get(id));

			// Sauvegarde de la meilleure solution
			if (cycles < minCycles) {
				selectedCombi = j;
				minCycles = cycles;
				selectedReg.clear();
				selectedReg.addAll(currentReg);
				selectedLoadMask.clear();
				selectedLoadMask.addAll(currentLoadMask);
			}
		}

		if (selectedCombi == -1) {
			logger.fatal("Aucune combinaison de registres pour le pattern en position: "+solution.positions.get(id));
		}

		// Sauvegarde de la méthode a exécuter
		snippet = new Snippet(solution_patterns_id, data, solution.positions.get(id)*2, selectedReg, selectedLoadMask, solution.computedOffsets.get(id), selectedCombi);

		// Seconde partie de la méthode, pour la combinaison sélectionnée on met à jour le cache registre dans regSet et regVal 
		pos = solution.positions.get(id)*2;
		boolean[] combiList_selectedCombi = combiList.get(selectedCombi);
		boolean[] resetRegList_selectedCombi = selectedCombi < resetRegList.size() ? resetRegList.get(selectedCombi) : null;

		for (int j = 0; j < combiList_selectedCombi.length; j++) {
			if (combiList_selectedCombi[j] && (resetRegList_selectedCombi==null || !resetRegList_selectedCombi[j])) {
				// On ne charge qui si le registre est dans la combinaison
				// et qu'il n'a pas été réinitialisé dans le pattern

				regSet[j] = true;
				
				regVal[j][0] = data[pos];
				regVal[j][1] = data[pos+1];
				if (Register.size[j] == 2) {
					regVal[j][2] = data[pos+2];
					regVal[j][3] = data[pos+3];
				}

				// Cas particulier de A, on valorise D
				if (j == Register.A && (regSet[Register.B] && 
					(resetRegList_selectedCombi==null || !resetRegList_selectedCombi[Register.B]))) {
					regSet[Register.D] = true;
					regVal[Register.D][0] = regVal[j][0];
					regVal[Register.D][1] = regVal[j][1];
				}

				// Cas particulier de B, on valorise D
				if (j == Register.B && (regSet[Register.A] && 
						(resetRegList_selectedCombi==null || !resetRegList_selectedCombi[Register.A]))) {
					regSet[Register.D] = true;
					regVal[Register.D][2] = regVal[j][0];
					regVal[Register.D][3] = regVal[j][1];
				}

				// Cas particulier de D, on valorise A et B
				if (j == Register.D) {
					if (resetRegList_selectedCombi==null || !resetRegList_selectedCombi[Register.A]) {
						regSet[Register.A] = true;
						regVal[Register.A][0] = regVal[j][0];
						regVal[Register.A][1] = regVal[j][1];
					}

					if (resetRegList_selectedCombi==null || !resetRegList_selectedCombi[Register.B]) {				
						regSet[Register.B] = true;
						regVal[Register.B][0] = regVal[j][2];
						regVal[Register.B][1] = regVal[j][3];
					}

					if (regSet[Register.A] != true || regSet[Register.B] != true ) {
						regSet[Register.D] = false;
					}
				}
			}
			if (combiList.get(selectedCombi)[j]) {
				pos += Register.size[j] * 2;
			}
		}

		boolean flush = false;
		// Réinitialisation des registres écrasés par le pattern
		// Nécessaire si le dernier pattern a bénéficié du cache mais écrase les registres
		if (resetRegList.size() > selectedCombi) {
			for (int j = 0; j < resetRegList_selectedCombi.length; j++) {

				if (resetRegList_selectedCombi[j]) {
					regSet[j] = false;
					if (regBBSet[j] || ((j == Register.A || j == Register.B) && regBBSet[Register.D] == true ) || (j == Register.D && (regBBSet[Register.A] == true || regBBSet[Register.B] == true))) {
						flush = true;
					}
				}
			}
		}		

		for (int i = 0; i < selectedReg.size(); i++) {
			int selectedReg_i = selectedReg.get(i);

			if (regBBSet[selectedReg_i] || ((selectedReg_i == Register.A || selectedReg_i == Register.B) && regBBSet[Register.D] == true ) || (selectedReg_i == Register.D && (regBBSet[Register.A] == true || regBBSet[Register.B] == true))) {
				flush = true;
			}
		}

		if (flush) {
			// flush du précédent pattern et purge des registres
			for (int i = regBBSet.length-1; i >= 0; i--) {
				if (regBBSet[i]) {
					lastSnippet.addRegisterPSH(i);

					// Pour chaque registre sauvegardé dans les données du fond
					// On enregistre l'id du registre et l'offset associé
					// dans le cas d'un stack blast, on enregistre un index null
					regE.add(i);
					offsetE.add(offsetBBSet[i]);
				}
				regBBSet[i] = false;
				offsetBBSet[i] = null;
			}
			regBBIdx = -1;
		}

		return snippet;
	}

	public List<String> getAsmCode() {
		return asmCode;
	}

	public List<String> getAsmECode() {
		return asmECode;
	}

	public int getDataSize() {
		int size = 0;
		for (Pattern pattern : solution.patterns) {
			size += pattern.getNbBytes();
		}
		size += sizesaveU;

		return size;
	}

	public void setSolution(Solution solution) {
		this.solution = solution;
	}

	public void setData(byte[] data) {
		this.data = data;
	}

	public int getAsmCodeCycles() {
		return asmCodeCycles;
	}

	public int getAsmCodeSize() {
		return asmCodeSize;
	}

	public int getAsmECodeCycles() {
		return asmECodeCycles;
	}

	public int getAsmECodeSize() {
		return asmECodeSize;
	}
}