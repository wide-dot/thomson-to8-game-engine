package fr.bento8.to8.compiledSprite.backupDrawErase;

import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.compiledSprite.backupDrawErase.patterns.Pattern;

public class PatternCluster{
	// Regroupe les Patterns d'une solution en noeuds
	// recalcul les offset dans la plage -128 +127 autour de l'adresse de chaque noeud

	private static final Logger logger = LogManager.getLogger("log");

	public Solution solution;
	private List<Integer> AssignedPatterns;
	int center;

	public PatternCluster(Solution solution, int center) {
		this.solution = solution;
		this.center = center;
		AssignedPatterns = new ArrayList<Integer>();
	}

	public void cluster(boolean isForward) {
		initAssignmentStep();
		clusterPatternsToExistingNodes(isForward);
		createNewNodesAndClusterRemainingPatterns(isForward);
		setLEAOffsetRelativeToEachOthers();
		//displayDebug();
	}

	private boolean initAssignmentStep() {
		boolean result = false;

		// Initialisation � -1 des patterns utilisant l'adressage index�
		// Initialisation avec la valeur d'offset pour les autres patterns

		for (int i=0; i<solution.patterns.size(); i++) {
			solution.computedNodes.add(solution.positions.get(i));
			if (solution.patterns.get(i).useIndexedAddressing()) {
				AssignedPatterns.add(-1);
				result=true;
			} else {
				AssignedPatterns.add(solution.positions.get(i));
			}
		}

		return result;
	}

	private void clusterPatternsToExistingNodes(boolean isForward) {	   
		int distance, nodeStart = -1;

		// Traite les noeuds fixes impos�s par les patterns n'utilisant pas l'indexation
		// Cherche pour chacun tous les pattern index�s pouvant s'y rattacher (-128 +127)
		for (int i = 0; i < solution.computedNodes.size(); i++) {
			if (!solution.patterns.get(i).useIndexedAddressing()) {
				// Noeud impos� on recherche les patterns pouvant y etre rattach�s
				for (int j = 0; j < solution.computedNodes.size(); j++) {
					// On arr�te la recherche lorsqu'un noeud impos� est rencontr�
					if (j >= i+1 && !solution.patterns.get(j).useIndexedAddressing()) {
						break;
					}

					// On cherche des patterns index�s non affect�s
					if (solution.patterns.get(j).useIndexedAddressing() && AssignedPatterns.get(j) == -1) {
						if (isForward) {
							distance = solution.computedNodes.get(j) - solution.computedNodes.get(i);
						} else {
							distance = solution.computedNodes.get(i) - solution.computedNodes.get(j);
						}
						if ( -128 <= distance && distance <= 127) {
							AssignedPatterns.set(j, i);
							if (nodeStart == -1) {
								if (i < j) {
									nodeStart = i;
								} else {
									nodeStart = j;
								}
							}
							solution.computedNodes.set(j, nodeStart);
							solution.computedOffsets.set(j, solution.positions.get(j)-solution.positions.get(i));
						}
					}
				}

				// s'il n'y a pas de pattern avant le noeud impos�, on utilis� le noeud impos� comme noeud de d�part
				if (nodeStart == -1 || i < nodeStart) {
					nodeStart = i;
				}
				solution.computedLeau.put(nodeStart, solution.positions.get(i));
				solution.computedNodes.set(i, nodeStart);
				nodeStart = -1;
			}
		}
	}

	private void createNewNodesAndClusterRemainingPatterns(boolean isForward) {	 

		List<Integer> minMaxI = new ArrayList<Integer>();
		int i = 0, j;

		//  Séléction des patterns à regrouper en noeuds
		while (i < solution.computedNodes.size()) {
			while (i < solution.computedNodes.size() && AssignedPatterns.get(i) != -1) {
				i++;
			}
			minMaxI.add(i);

			while (i < solution.computedNodes.size() && AssignedPatterns.get(i) == -1) {
				i++;
			}
			minMaxI.add(i-1);
		}

		// Regroupement
		ListIterator<Integer> it1 = minMaxI.listIterator();
		int start, end, node;

		while (it1.hasNext()) {
			start = it1.next();
			end = it1.next();
			i = start;

			while (i <= end) {

				while (i++ < end && Math.abs(solution.positions.get(start) - solution.positions.get(i)) < 256) {
				}

				if (isForward) {
					node = ((Math.abs(solution.positions.get(start) - solution.positions.get(i-1))+1) / 2) + solution.positions.get(start);
				} else {
					node = -((Math.abs(solution.positions.get(start) - solution.positions.get(i-1))+1) / 2) + solution.positions.get(start);
				}
				solution.computedLeau.put(start, node);

				for (j = start; j < i; j++) {
					solution.computedNodes.set(j, start);
					solution.computedOffsets.set(j, solution.positions.get(j)-node);
				}

				start = i;
			}
		}
	}

	public void setLEAOffsetRelativeToEachOthers() {
		// Remplace les valeurs d'offset des LEA relatives au départ par des valeurs relatives entre les LEA
		int curOffset = 0, newOffset = 0, lastOffset = center;
		for (int i = 0; i < solution.patterns.size(); i++) {
			if (solution.computedLeau.containsKey(i)) {
				curOffset = solution.computedLeau.get(i);
				newOffset = curOffset - lastOffset;
				solution.computedLeau.replace(i, newOffset);
				lastOffset = curOffset;
			}
		}
	}

	public void displayDebug() {
		ListIterator<Integer> it1 = solution.positions.listIterator();
		ListIterator<Integer> it2 = solution.computedNodes.listIterator();
		ListIterator<Integer> it3 = solution.computedOffsets.listIterator();
		int currentNode, oldNode = -1;
		int i=0;
		for (Pattern snippet : solution.patterns) {
			currentNode = it2.next();
			if (oldNode != currentNode) {
				logger.debug("");
				logger.debug("Noeud: "+currentNode);
				logger.debug("(index:position:offset:pattern)");
				oldNode = currentNode;
			}

			logger.debug("("+i+":"+it1.next()+":"+it3.next()+":"+snippet.getClass().getSimpleName()+")");
			i++;
		}
		logger.debug("");
		logger.debug("LEAS: (noeud=offset) "+solution.computedLeau);
		logger.debug("");
	}
}