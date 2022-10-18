package fr.bento8.to8.build;

public class ChecksumUtils
{
	public static byte calculate(byte[] data, byte seed)
	{
		return calculate(data, seed, 0, data.length);
	}

	public static byte calculate(byte[] data, byte seed, int startIndex, int length)
	{		
		byte result = seed;
		for (int i = startIndex; i < length; i++)
		{
			result += data[i];
		}
		return result;
	}
}
