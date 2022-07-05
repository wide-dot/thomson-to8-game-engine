package fr.bento8.to8.compiledSprite.draw;

import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import fr.bento8.to8.compiledSprite.draw.patterns.Pattern;

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

		// Initialisation à -1 des patterns utilisant l'adressage indexé
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

		// Traite les noeuds fixes imposés par les patterns n'utilisant pas l'indexation
		// Cherche pour chacun tous les pattern indexés pouvant s'y rattacher (-128 +127)
		for (int i = 0; i < solution.computedNodes.size(); i++) {
			if (!solution.patterns.get(i).useIndexedAddressing()) {
				// Noeud imposé on recherche les patterns pouvant y etre rattachés
				for (int j = 0; j < solution.computedNodes.size(); j++) {
					// On arrête la recherche lorsqu'un noeud imposé est rencontré
					if (j >= i+1 && !solution.patterns.get(j).useIndexedAddressing()) {
						break;
					}

					// On cherche des patterns indexés non affectés
					if (solution.patterns.get(j).useIndexedAddressing() && AssignedPatterns.get(j) == -1) {
						if (isForward) {
							distance = solution.computedNodes.get(j) - solution.computedNodes.get(i);
						} else {
							// Tous les noeuds traités ici sont rattachés à un pattern PSH, par conséquent le début du noeud est +1
							// par rapport à la position car le PSH est remontant et son point de départ est +1
							distance = (solution.computedNodes.get(i) + 1) - solution.computedNodes.get(j);
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
							// +1 pour début du PSH
							solution.computedOffsets.set(j, solution.positions.get(j) - (solution.positions.get(i) + 1 + solution.patterns.get(j).getNbBytes()-1));
						}
					}
				}

				// s'il n'y a pas de pattern avant le noeud imposé, on utilise le noeud imposé comme noeud de départ
				if (nodeStart == -1 || i < nodeStart) {
					nodeStart = i;
				}
				// +1 pour début du PSH
				solution.computedLeau.put(nodeStart, solution.positions.get(i) + 1);
				// Enregistrement de la taille du PSH pour calculer le leas suivant
				solution.computedNodeOffset.put(nodeStart, solution.patterns.get(i).getNbBytes());
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
					if ((center-128 <= solution.positions.get(start)) && (solution.positions.get(i-1) <= center+127)) {
						node = center; // in this case the node is not centered but the first leau is skipped
					} else {
						node = ((Math.abs(solution.positions.get(start) - solution.positions.get(i-1))+1) / 2) + solution.positions.get(start);						
					}
				} else {
					if ((center-128 <= solution.positions.get(i-1)) && (solution.positions.get(start) <= center+127)) {
						node = center; // in this case the node is not centered but the first leau is skipped
					} else {
						node = -((Math.abs(solution.positions.get(start) - solution.positions.get(i-1))+1) / 2) + solution.positions.get(start);
					}
				}
				solution.computedLeau.put(start, node);

				for (j = start; j < i; j++) {
					solution.computedNodes.set(j, start);
					solution.computedOffsets.set(j, solution.positions.get(j)-node-(solution.patterns.get(j).getNbBytes()-1));
					solution.computedNodeOffset.put(j, 0);
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
				lastOffset = curOffset - solution.computedNodeOffset.get(i);
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
				//logger.debug("");
				//logger.debug("Noeud: "+currentNode);
				//logger.debug("(index:position:offset:pattern)");
				oldNode = currentNode;
			}

			//logger.debug("("+i+":"+it1.next()+":"+it3.next()+":"+snippet.getClass().getSimpleName()+")");
			i++;
		}
		//logger.debug("");
		//logger.debug("LEAS: (noeud=offset) "+solution.computedLeau);
		//logger.debug("");
	}
}