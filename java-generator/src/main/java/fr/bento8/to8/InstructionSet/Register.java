package fr.bento8.to8.InstructionSet;

public class Register {
	// Les registres sont ordonn�s dans le sens du PUL
	public static final String[] name = new String[] {"A", "B", "D", "X", "Y", "U", "S"};
	public static final int[] size = new int[] {1, 1, 2, 2, 2, 2, 2};
	
	public static final int A = 0;
	public static final int B = 1;
	public static final int D = 2;
	public static final int X = 3;
	public static final int Y = 4;
	public static final int U = 5;
	public static final int S = 6;

	public static final int[] costDirectST = new int[] {4, 4, 5, 5, 6, 5, 6};
	public static final int[] costIndexedST= new int[] {4, 4, 5, 5, 6, 5, 6};
	public static final int[] costExtendedST= new int[] {5, 5, 6, 6, 7, 6, 7};
	
	public static final int[] sizeDirectST = new int[] {2, 2, 2, 2, 3, 2, 3};
	public static final int[] sizeIndexedST= new int[] {2, 2, 2, 2, 3, 2, 3};
	public static final int[] sizeExtendedST= new int[] {3, 3, 3, 3, 4, 3, 4};
	
	public static final int[] costImmediateLD = new int[] {2, 2, 3, 3, 4, 3, 4};
	public static final int[] costDirectLD = new int[] {4, 4, 5, 5, 6, 5, 6};
	public static final int[] costIndexedLD = new int[] {4, 4, 5, 5, 6, 5, 6};
	public static final int[] costExtendedLD= new int[] {5, 5, 6, 6, 7, 6, 7};

	public static final int[] sizeImmediateLD = new int[] {2, 2, 3, 3, 4, 3, 4};
	public static final int[] sizeDirectLD = new int[] {2, 2, 2, 2, 3, 2, 3};
	public static final int[] sizeIndexedLD = new int[] {2, 2, 2, 2, 3, 2, 3};
	public static final int[] sizeExtendedLD= new int[] {2, 2, 3, 3, 4, 3, 4};
	
	public static final int[] costImmediateAND = new int[] {2, 2};
	public static final int[] costDirectAND = new int[] {4, 4};
	public static final int[] costIndexedAND = new int[] {4, 4};
	public static final int[] costExtendedAND= new int[] {5, 5};
	
	public static final int[] sizeImmediateAND = new int[] {2, 2};
	public static final int[] sizeDirectAND = new int[] {2, 2};
	public static final int[] sizeIndexedAND = new int[] {2, 2};
	public static final int[] sizeExtendedAND= new int[] {3, 3};
	
	public static final int[] costImmediateADD = new int[] {2, 2, 4};
	public static final int[] costDirectADD = new int[] {4, 4, 6};
	public static final int[] costIndexedADD = new int[] {4, 4, 6};
	public static final int[] costExtendedADD= new int[] {5, 5, 7};

	public static final int[] sizeImmediateADD = new int[] {2, 2, 3};
	public static final int[] sizeDirectADD = new int[] {2, 2, 2};
	public static final int[] sizeIndexedADD = new int[] {2, 2, 2};
	public static final int[] sizeExtendedADD= new int[] {3, 3, 3};

	public static final int[] costImmediateOR = new int[] {2, 2};
	public static final int[] costDirectOR = new int[] {4, 4};
	public static final int[] costIndexedOR = new int[] {4, 4};
	public static final int[] costExtendedOR= new int[] {5, 5};

	public static final int[] sizeImmediateOR = new int[] {2, 2};
	public static final int[] sizeDirectOR = new int[] {2, 2};
	public static final int[] sizeIndexedOR = new int[] {2, 2};
	public static final int[] sizeExtendedOR= new int[] {3, 3};
	
	public static final int costIndexedLEA = 4;
	public static final int sizeIndexedLEA = 2;
	
	public static final int[] costIndexedOffset = new int[] {0, 1, 1, 4};
	public static final int[] sizeIndexedOffset = new int[] {0, 0, 1, 2};
	public static final int[] rangeMinIndexedOffset = new int[] {0, -16, -128, -32768};
	public static final int[] rangeMaxIndexedOffset = new int[] {0, 15, 127, 32767};
	
	public static final int[] costIndexedOffsetPCR = new int[] {1, 5};
	public static final int[] sizeIndexedOffsetPCR = new int[] {1, 2};
	public static final int[] rangeMinIndexedOffsetPCR = new int[] {-128, -32768};
	public static final int[] rangeMaxIndexedOffsetPCR = new int[] {127, 32767};	
	
	public static final int sizeImmediatePULPSH = 2;
	public static int getCostImmediatePULPSH(int nbByte) {
		return 5+nbByte;
	}
	
	public static int getIndexedOffsetCost(int offset) throws Exception {
		int cost = -1;
		for (int i = 0; i < costIndexedOffset.length; i++) {
			if (offset <= rangeMaxIndexedOffset[i] && offset >= rangeMinIndexedOffset[i]) {
				cost = costIndexedOffset[i];
				break;
			}
		}

		if (cost < 0) {
			throw new Exception("Offset: "+offset+" en dehors de la plage autorisée.");
		}

		return cost;
	}
	
	public static int getIndexedOffsetSize(int offset) throws Exception {
		int size = -1;
		for (int i = 0; i < sizeIndexedOffset.length; i++) {
			if (offset <= rangeMaxIndexedOffset[i] && offset >= rangeMinIndexedOffset[i]) {
				size = sizeIndexedOffset[i];
				break;
			}
		}

		if (size < 0) {
			throw new Exception("Offset: "+offset+" en dehors de la plage autorisée.");
		}

		return size;
	}
	
	public static int getIndexedOffsetCostPCR(int offset) throws Exception {
		int cost = -1;
		for (int i = 0; i < costIndexedOffsetPCR.length; i++) {
			if (offset <= rangeMaxIndexedOffsetPCR[i] && offset >= rangeMinIndexedOffsetPCR[i]) {
				cost = costIndexedOffsetPCR[i];
				break;
			}
		}

		if (cost < 0) {
			throw new Exception("Offset: "+offset+" en dehors de la plage autorisée.");
		}

		return cost;
	}
	
	public static int getIndexedOffsetSizePCR(int offset) throws Exception {
		int size = -1;
		for (int i = 0; i < sizeIndexedOffsetPCR.length; i++) {
			if (offset <= rangeMaxIndexedOffsetPCR[i] && offset >= rangeMinIndexedOffsetPCR[i]) {
				size = sizeIndexedOffsetPCR[i];
				break;
			}
		}

		if (size < 0) {
			throw new Exception("Offset: "+offset+" en dehors de la plage autorisée.");
		}

		return size;
	}	
}