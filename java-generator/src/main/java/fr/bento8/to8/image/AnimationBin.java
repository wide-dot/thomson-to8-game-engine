package fr.bento8.to8.image;

import fr.bento8.to8.build.FileNames;
import fr.bento8.to8.build.Object;
import fr.bento8.to8.storage.RAMLoaderIndex;
import fr.bento8.to8.util.knapsack.ItemBin;

public class AnimationBin extends ItemBin{

	public String name = "";
	public String fileName;

	public AnimationBin(String objName) {
		this.fileName = objName + FileNames.ANIMATION;
	}
	
	public void setName(String name) {
		this.name = name;
	}	
	
	public String getFullName() {
		return "AnimationBin "+this.name;
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