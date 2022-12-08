package fr.bento8.to8.compiledSprite.backupDrawErase;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.ListIterator;

import fr.bento8.to8.compiledSprite.backupDrawErase.patterns.Pattern;

public class Solution {
	public List<Pattern> patterns;			// Liste des Patterns trouvés dans l'ordre
	public List<Integer> positions;			// Liste des positions pour chaque pattern
	
	public List<Integer> computedNodes;		// Liste des noeuds trouvés (= id du premier pattern du noeud)
	public List<Integer> computedOffsets;  	// Liste des offsets applicables à chaque pattern pour l'adressage indexé
	public HashMap<Integer, Integer> computedLeau; // Ensemble des LEAU (noeud, offset)
	
	public List<Snippet> optimizedSnippets;	// Liste des patterns ordonn�s par l'optimiseur contient des éléments supplémentaires LEAU ...
	
	private int cycles;
	private int size;

	public Solution() {
		patterns = new ArrayList<Pattern>();
		positions = new ArrayList<Integer>();
		computedNodes = new ArrayList<Integer>();
		optimizedSnippets = new ArrayList<Snippet>();
		computedOffsets = new ArrayList<Integer>();
		computedLeau = new HashMap<Integer, Integer>();
		cycles = 0;
		size = 0;
	}

	public void add(Pattern pattern, int i) {
		patterns.add(0, pattern);
		positions.add(0, i);
		computedOffsets.add(0, null);
	}

	public String toString() {
		String display = "[Cycles: "+getCycles()+" Octets: "+getSize()+" ";
		ListIterator<Integer> it = positions.listIterator();
		for (Pattern snippet : patterns) {
			display = display + "("+it.next()+":"+snippet.getClass().getSimpleName()+")";
		}
		return display;
	}
	
	public int getCycles() {
		return cycles;
	}

	public int getSize() {
		return size;
	}
}