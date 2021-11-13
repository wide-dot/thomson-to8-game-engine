package fr.bento8.to8.image.encoder;

import java.io.IOException;

public abstract class Encoder {

	public abstract void compileCode(String string);

	public abstract int getX1_offset();

	public abstract int getY1_offset();

	public abstract int getX_size();

	public abstract int getY_size();

	public abstract String getDrawBINFile();

	public abstract int getDSize() throws IOException;

}
