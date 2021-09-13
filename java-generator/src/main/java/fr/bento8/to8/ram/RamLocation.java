package fr.bento8.to8.ram;

/**
 * @author Benoît Rousseau
 * @version 1.0
 *
 */
public class RamLocation
{
	
	public int page;
	public int address;
	public int lastPage;
	
	public RamLocation(int lastPage) {
		this.lastPage = lastPage;
		this.page = 0;
		this.address = 0;
	}
	
	public boolean isOutOfMemory() {
		return (page>lastPage);
	}
}