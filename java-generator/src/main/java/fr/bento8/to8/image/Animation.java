package fr.bento8.to8.image;

import java.util.HashMap;

public class Animation {

	public static HashMap<String, Integer> tagSize = new HashMap<String, Integer>();
	static {
		tagSize.put("_resetAnim", 1);
		tagSize.put("_goBackNFrames", 2);
		tagSize.put("_goToAnimation", 3);
		tagSize.put("_nextRoutine", 1);
		tagSize.put("_resetAnimAndSubRoutine", 1);
		tagSize.put("_nextSubRoutine", 1);				
	}
}