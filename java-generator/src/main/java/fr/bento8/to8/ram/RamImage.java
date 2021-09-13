package fr.bento8.to8.ram;

/**
 * @author Benoît Rousseau
 * @version 1.0
 *
 */
public class RamImage
{
    public static int PAGE_SIZE = 0x4000;	
	
    public byte[][] data;
    public int[] startAddress;
    public int[] endAddress;
    
	public int startPage;    
	public int endPage;	
	public int curPage;
	public int curAddress;	
	public int lastPage;
	
	public int mode;
	
	public RamImage (int lastPage) {
		this.data = new byte[lastPage][PAGE_SIZE];
		
		this.startAddress = new int[lastPage];
		this.endAddress = new int[lastPage];
		this.lastPage = lastPage;
		this.startPage = lastPage+1;
		this.endPage = -1;
		this.curPage = 0;		
	}
	
	public RamImage (int lastPage, boolean testMode) {
		this.data = new byte[lastPage][PAGE_SIZE];

        // Pour test de copie vers T.2: valorise tt les données d'une page par son numéro		
		for (int i=0; i<lastPage; i++) {
			for (int j=0; j<PAGE_SIZE; j++) {
				this.data[i][j] = (byte)i;
			}
		}
		
		this.startAddress = new int[lastPage];
		this.endAddress = new int[lastPage];
		this.lastPage = lastPage;
		this.startPage = 0;
		this.endPage = lastPage-1;
		this.curPage = 0;		
	}	
	
	public void setData (int page, int startPos, byte[] newData) {
		int endPos = newData.length+startPos;		
		
		if (startPos < this.startAddress[page]) {
			this.startAddress[page] = startPos;
		}
		
		if (endPos > this.endAddress[page]) {
			this.endAddress[page] = endPos;
		}
		
		for (int i = startPos, j = 0; i < endPos; i++) {
			this.data[page][i] = newData[j++];
		}
		
		if (page < this.startPage) {
			this.startPage = page;
		}
		
		if (page > this.endPage) {
			this.endPage = page;
		}		
	}
	
	public void updateEndPage() {
		if (curPage > this.endPage) {
			this.endPage = curPage;
		}		
	}
	
	public void setDataAtCurPos (byte[] newData) {
		int startPos = this.endAddress[curPage];	
		this.endAddress[curPage] = newData.length+startPos;
		
		for (int i = startPos, j = 0; i < this.endAddress[curPage]; i++) {
			this.data[curPage][i] = newData[j++];
		}
		
		this.curAddress = this.endAddress[curPage];
	}	
	
	public boolean isOutOfMemory() {
		return (curPage>=lastPage);
	}
	
	public void reserveT2Header () {
		for (int p = 1; p < lastPage; p++) {
			this.endAddress[p] = 32;
		}
	}	

	public void writeT2Header (byte[] newData) {
		for (int p = 1; p < lastPage; p++) {
			for (int i = 0; i < 32; i++) {
				this.data[p][i] = newData[i];
			}
		}
	}
}