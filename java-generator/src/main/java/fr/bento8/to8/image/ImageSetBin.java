package fr.bento8.to8.image;

import fr.bento8.to8.build.FileNames;
import fr.bento8.to8.build.Object;
import fr.bento8.to8.storage.RAMLoaderIndex;
import fr.bento8.to8.util.knapsack.ItemBin;

public class ImageSetBin extends ItemBin{

	public String name = "";
	public String fileName;	

	public ImageSetBin(String objName) {
		this.fileName = objName + FileNames.IMAGE_SET;
	}
	
	public void setName(String name) {
		this.name = name;
	}	
	
	public String getFullName() {
		return "ImageSetBin "+this.name;
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