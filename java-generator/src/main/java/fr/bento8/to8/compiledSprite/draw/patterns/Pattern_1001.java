package fr.bento8.to8.compiledSprite.draw.patterns;

import java.util.ArrayList;
import java.util.List;

import fr.bento8.to8.InstructionSet.Register;

public class Pattern_1001 extends PatternAlpha {

	public Pattern_1001() {
		nbPixels = 4;
		nbBytes = nbPixels/2;
		useIndexedAddressing = true;
		isBackgroundBackupAndDrawDissociable = false;
		resetRegisters.add(new boolean[] {true, true, true, false, false, false, false});
		registerCombi.add(new boolean[] {false, false, true, false, false, false, false});
	}

	public boolean matchesForward (byte[] data, Integer offset) {
		if (offset+3 >= data.length) {
			return false;
		}
		return (data[offset] != 0x00 && data[offset+1] == 0x00 && data[offset+2] == 0x00 && data[offset+3] != 0x00);
	}
	
	public boolean matchesRearward (byte[] data, Integer offset) {
		if (offset-2 < 0) {
			return false;
		}
		return (data[offset-2] != 0x00 && data[offset-1] == 0x00 && data[offset] == 0x00 && data[offset+1] != 0x00);
	}

	public List<String> getDrawCode (byte[] data, int position, List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset) throws Exception {
		List<String> asmCode = new ArrayList<String>();
		asmCode.add("\tANDA #$0F");
		asmCode.add("\tANDB #$F0");
		asmCode.add("\tADDD "+"#$"+String.format("%01x%01x%01x%01x", data[position]&0xff, data[position+1]&0xff, data[position+2]&0xff, data[position+3]&0xff));
		asmCode.add("\tSTD "+(offset!= 0?offset:"")+",U");
		return asmCode;
	}
	
	public int getDrawCodeCycles (List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset) throws Exception {
		int cycles = 0;
		cycles += Register.costImmediateAND[Register.A];
		cycles += Register.costImmediateAND[Register.B];
		cycles += Register.costImmediateADD[Register.D];
		cycles += Register.costIndexedST[Register.D] + Register.getIndexedOffsetCost(offset);
		return cycles;
	}
	
	public int getDrawCodeSize (List<Integer> registerIndexes, List<Boolean> loadMask, Integer offset) throws Exception {
		int size = 0;
		size += Register.sizeImmediateAND[Register.A]; 
		size += Register.sizeImmediateAND[Register.B]; 
		size += Register.sizeImmediateADD[Register.D]; 
		size += Register.sizeIndexedST[Register.D] + Register.getIndexedOffsetSize(offset);
		return size;	
	}
}