package fr.bento8.to8.storage;

/**
 * @author Benoît Rousseau
 * @version 1.0
 *
 */
public class DataIndex
{
	// RAM FD
	public int fd_ram_page;       // page de destination RAM
	public int fd_ram_address;	  // adresse RAM
	public int fd_ram_endAddress; // adresse de destination (ptr de fin) RAM	

	// RAM T.2	
	public int t2_ram_page;       // page de destination RAM
	public int t2_ram_address;	  // adresse RAM
	public int t2_ram_endAddress; // adresse de destination (ptr de fin) RAM	
	
	public DataIndex() {
	}
}