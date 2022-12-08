package fr.bento8.to8.build;

import fr.bento8.to8.util.knapsack.ItemBin;
import fr.bento8.to8.build.Object;
import fr.bento8.to8.storage.RAMLoaderIndex;

public class ObjectBin extends ItemBin{

	public String name = "";
	public Object parent;
	
	public ObjectBin() {
	}
	
	public ObjectBin(Object obj) {
		this.parent = obj;
	}	
	
	public void setName(String name) {
		this.name = name;
	}	
	
	public String getFullName() {
		return "ObjectBin "+this.name;
	}

	public Object getObject() {
		return parent;
	}

	public RAMLoaderIndex getRAMLoaderIndex() {
		return null;
	}
			
}