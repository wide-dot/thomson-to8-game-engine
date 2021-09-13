package fr.bento8.to8.compiledSprite.draw;

import java.util.List;

import fr.bento8.to8.compiledSprite.draw.asmCode.ASMCode;
import fr.bento8.to8.compiledSprite.draw.patterns.Pattern;

public class Snippet {
	private Pattern pattern;
	private ASMCode asmCode;
	private int method;

	private List<Integer> registerIndexes;
	private List<Integer> registerIndexesPUL, registerIndexesPSH;
	private Integer offset;
	private byte[] data;
	private int position;
	private List<Boolean> loadMask;
	private int combiIdx;

	public static final int BACKGROUND = 0;
	public static final int DRAW = 1;
	public static final int LEAS = 2;

	public Snippet(Pattern pattern, List<Integer> registerIndexesPUL, List<Integer> registerIndexesPSH, Integer offset, int combiIdx) {
		method = BACKGROUND;
		this.pattern = pattern;
		this.registerIndexesPUL = registerIndexesPUL;
		this.registerIndexesPSH = registerIndexesPSH;
		this.offset = offset;
		this.combiIdx = combiIdx;
	}

	public Snippet(Pattern pattern, byte[] data, int position, List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset, int combiIdx) {
		method = DRAW;
		this.pattern = pattern;
		this.data = data;
		this.position = position;
		this.registerIndexes = registerIndexes;
		this.loadMask = loadMask;
		this.offset = offset;
	}

	public Snippet(ASMCode asmCode, Integer offset) {
		method = LEAS;
		this.asmCode = asmCode;
		this.offset = offset;
	}

	public List<String> call() throws Exception {
		List<String> code = null;
		switch (method) {
		case BACKGROUND: code=pattern.getBackgroundCode(registerIndexesPUL, registerIndexesPSH, offset); break;
		case DRAW: code=pattern.getDrawCode(data, position, registerIndexes, loadMask, offset); break;
		case LEAS: code=asmCode.getCode(offset); break;
		}
		return code;
	}

	public int getCycles() throws Exception {
		int cycles = 0;
		switch (method) {
		case BACKGROUND: cycles=pattern.getBackgroundCodeCycles(registerIndexesPUL, registerIndexesPSH, offset); break;
		case DRAW: cycles=pattern.getDrawCodeCycles(registerIndexes, loadMask, offset); break;
		case LEAS: cycles=asmCode.getCycles(offset); break;
		}
		return cycles;
	}

	public int getSize() throws Exception {
		int size = 0;
		switch (method) {
		case BACKGROUND: size=pattern.getBackgroundCodeSize(registerIndexesPUL, registerIndexesPSH, offset); break;
		case DRAW: size=pattern.getDrawCodeSize(registerIndexes, loadMask, offset); break;
		case LEAS: size=asmCode.getSize(offset); break;
		}
		return size;
	}

	public int getMethod() {
		return method;
	}

	public List<Integer> getRegisterIndexes() {
		return registerIndexes;
	}
	
	public List<Integer> getRegisterIndexesPUL() {
		return registerIndexesPUL;
	}
	
	public List<Integer> getRegisterIndexesPSH() {
		return registerIndexesPSH;
	}

	public void addRegisterPSH(Integer value) {
		this.registerIndexesPSH.add(value);
	}
	
	public void prependRegisterPSH(Integer value) {
		this.registerIndexesPSH.add(0, value);
	}
	
	public Integer getOffset() {
		return offset;
	}

	public int getCombiIdx() {
		return combiIdx;
	}
}