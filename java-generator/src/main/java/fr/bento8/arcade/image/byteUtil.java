package fr.bento8.arcade.image;

public class byteUtil {
	public static int getInt16(byte[] arr, int off) {
		return arr[off]<<8 &0xFF00 | arr[off+1]&0xFF;
	}	

	public static int getInt32(byte[] arr, int off) {
		return arr[off]<<24 &0xFF0000 | arr[off+1]<<16 &0xFF0000 | arr[off+2]<<8 &0xFF00 | arr[off+3]&0xFF;
	}	
}
