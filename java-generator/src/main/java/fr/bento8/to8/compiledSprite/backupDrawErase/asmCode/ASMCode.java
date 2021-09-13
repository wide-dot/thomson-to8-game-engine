package fr.bento8.to8.compiledSprite.backupDrawErase.asmCode;

import java.util.List;

public abstract class ASMCode {

	public abstract List<String> getCode (int offset) throws Exception;
	public abstract int getCycles (int offset) throws Exception;
	public abstract int getSize (int offset) throws Exception;

}