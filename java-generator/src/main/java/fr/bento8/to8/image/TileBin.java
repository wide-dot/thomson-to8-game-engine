package fr.bento8.to8.image;

import fr.bento8.to8.build.Object;
import fr.bento8.to8.storage.RAMLoaderIndex;
import fr.bento8.to8.util.knapsack.ItemBin;

public class TileBin extends ItemBin{

	public Tileset parent;
	public String name = "";
	public boolean inRAM = false;

	public TileBin(Tileset p) {
		parent = p;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public String getFullName() {
		return "TileBin " + this.parent.name + " " + this.name;
	}

	@Override
	public Object getObject() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public RAMLoaderIndex getRAMLoaderIndex() {
		// TODO Auto-generated method stub
		return null;
	}
}