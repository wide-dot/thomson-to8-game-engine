package fr.bento8.to8.image;

public class SubSprite {

	public Sprite parent;
	public String name = "";

	public SubSpriteBin draw;
	public SubSpriteBin erase;

	public int x_size;
	public int y_size;	
	public int x1_offset;	
	public int y1_offset;
	public int nb_cell;
	public int center_offset;
	
	public SubSprite(Sprite p) {
		parent = p;
	}

	public void setName(String name) {
		this.name = name;
	}
}