package fr.bento8.to8.image;

import java.util.ArrayList;
import java.util.List;

public class Tileset {

	public String name = "";
	public String fileName;
	public int nbTiles;
	public int nbColumns;
	public int nbRows;
	public int centerMode;
	public boolean inRAM = false;
	public String mapFile = null;

	public List<TileBin> tiles;
	public int mapBitDepth;
	public int bufferLength;

	public Tileset(String name) {
		this.name = name;
		this.tiles = new ArrayList<TileBin>();
	}
}