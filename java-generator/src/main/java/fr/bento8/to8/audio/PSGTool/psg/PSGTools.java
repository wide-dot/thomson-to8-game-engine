package fr.bento8.to8.audio.PSGTool.psg;

import java.io.IOException;
import java.util.Arrays;
import fr.bento8.to8.audio.PSGTool.vgm.VGMInterpreter;
import fr.bento8.to8.audio.PSGTool.vgm.VGMListener;

public class PSGTools {
  public static int[] getPSGdata(VGMInterpreter paramVGMInterpreter, int paramInt) throws IOException {
    int[] arrayOfInt1 = new int[53248];
    int b = 0;
    final int[] latchedRegister = { -1 };
    final int[] frameRegs = new int[8];
    final boolean[] loopMarkerHit = new boolean[1];
    int[] arrayOfInt4 = new int[8];
    paramVGMInterpreter.addVGMPortListener(new VGMListener() {
          public void writePSGport(int param1Int) {
            if ((param1Int & 0x80) != 0) {
              latchedRegister[0] = (param1Int & 0x70) >> 4;
              if ((latchedRegister[0] & 0x1) != 0) {
                frameRegs[latchedRegister[0]] = param1Int & 0xF;
              } else if (latchedRegister[0] >> 1 == 3) {
                frameRegs[latchedRegister[0]] = 0x400 | param1Int & 0xF;
              } else {
                frameRegs[latchedRegister[0]] = frameRegs[latchedRegister[0]] & 0x3F0 | param1Int & 0xF;
              } 
            } else if (latchedRegister[0] >= 0) {
              if ((latchedRegister[0] & 0x1) != 0) {
                frameRegs[latchedRegister[0]] = param1Int & 0xF;
              } else if (latchedRegister[0] >> 1 == 3) {
                frameRegs[latchedRegister[0]] = frameRegs[latchedRegister[0]] & 0x400 | param1Int & 0xF;
              } else {
                frameRegs[latchedRegister[0]] = (param1Int & 0x3F) << 4 | frameRegs[latchedRegister[0]] & 0xF;
              } 
            } 
          }
          
          public void loopPointHit() {
            loopMarkerHit[0] = true;
          }
        });
    Arrays.fill(arrayOfInt4, -1);
    System.arraycopy(arrayOfInt4, 0, frameRegs, 0, arrayOfInt4.length);
    while (paramVGMInterpreter.run(paramInt)) {
      if (loopMarkerHit[0]) {
        if (b==0 && b < arrayOfInt1.length)
          arrayOfInt1[b++] = 1; 
        loopMarkerHit[0] = false;
      } 
      for (byte b1 = 0; b1 < arrayOfInt4.length && b < arrayOfInt1.length; b1++) {
        if (arrayOfInt4[b1] != frameRegs[b1]) {
          arrayOfInt1[b++] = 0x80 | b1 << 4 | frameRegs[b1] & 0xF;
          if ((b1 & 0x1) == 0 && b1 >> 1 < 3 && (arrayOfInt4[b1] & 0xFFFFFFF0) != (frameRegs[b1] & 0xFFFFFFF0) && b < arrayOfInt1.length)
            arrayOfInt1[b++] = 0x40 | frameRegs[b1] >> 4; 
        } 
        frameRegs[b1] = frameRegs[b1] & 0x3FF;
        arrayOfInt4[b1] = frameRegs[b1];
      } 
      if (b > 0 && (arrayOfInt1[b - 1] & 0xF8) == 56 && (arrayOfInt1[b - 1] & 0x7) < 7) {
        arrayOfInt1[b - 1] = arrayOfInt1[b - 1] + 1;
      } else if (b < arrayOfInt1.length) {
        arrayOfInt1[b++] = 56;
      } 
      if (b >= arrayOfInt1.length)
        break; 
    } 
    if (b < arrayOfInt1.length) {
      arrayOfInt1[b++] = 0;
    } else {
      arrayOfInt1[arrayOfInt1.length - 1] = 0;
    } 
    int[] arrayOfInt5 = new int[b];
    System.arraycopy(arrayOfInt1, 0, arrayOfInt5, 0, b);
    return arrayOfInt5;
  }
  
  public static int[] compressPSG(int[] paramArrayOfint) {
    if (paramArrayOfint.length < 4)
      return paramArrayOfint; 
    if (paramArrayOfint[paramArrayOfint.length - 1] != 0)
      throw new IllegalArgumentException("The end marker is missing."); 
    int[] arrayOfInt1 = new int[paramArrayOfint.length];
    System.arraycopy(paramArrayOfint, 0, arrayOfInt1, 0, 4);
    int i = 0;
    int j = 0;
    while (i < paramArrayOfint.length && paramArrayOfint[i] > 0) {
      if (paramArrayOfint[i] < 56 && paramArrayOfint[i] >= 8)
        return paramArrayOfint; 
      int k = 0;
      byte b1 = 0;
      byte b2 = 0;
      int m = 0;
      int n = -1;
      while (m + b1 < j && b2 < 51 && paramArrayOfint[i + b2] > 0) {
        if (arrayOfInt1[m + b2] < 56 && arrayOfInt1[m + b2] >= 8) {
          int i1 = arrayOfInt1[m + b2] - 4;
          int i2 = arrayOfInt1[m + b2 + 2] << 8 | arrayOfInt1[m + b2 + 1];
          byte b3 = b2;
          boolean bool = true;
          byte b4;
          for (b4 = 0; bool && b4 < i1 && i + b2 + b4 < paramArrayOfint.length; b4++) {
            if (arrayOfInt1[i2 + b4] != paramArrayOfint[i + b2 + b4] || b3 >= 51) {
              bool = false;
            } else {
              b3++;
            } 
          } 
          if (bool)
            for (b4 = 0; i + b2 + i1 + b4 < paramArrayOfint.length && b3 < 51 && arrayOfInt1[m + b2 + 3 + b4] == paramArrayOfint[i + b2 + i1 + b4]; b4++)
              b3++;  
          if (b3 + 3 - i1 > b1) {
            n = m + b2;
            k = m;
            b1 = b3;
          } else if (b2 > b1) {
            n = -1;
            k = m;
            b1 = b2;
          } 
          if (b2 == 0) {
            m += 3;
          } else {
            m++;
          } 
          b2 = 0;
          continue;
        } 
        if (arrayOfInt1[m + b2] != paramArrayOfint[i + b2]) {
          if (b2 > b1) {
            n = -1;
            k = m;
            b1 = b2;
          } 
          m++;
          b2 = 0;
          continue;
        } 
        b2++;
      } 
      if (b1 >= 4) {
        int i1 = k;
        byte b = b1;
        int i2 = n;
        int i3 = i;
        int i4;
        for (i4 = i + 1; i4 < i + b1; i4++) {
          b2 = 0;
          m = 0;
          while (m + b < j && b2 < 51 && paramArrayOfint[i + b2] > 0) {
            if (arrayOfInt1[m + b2] < 56 && arrayOfInt1[m + b2] >= 8) {
              int i5 = arrayOfInt1[m + b2] - 4;
              int i6 = arrayOfInt1[m + b2 + 2] << 8 | arrayOfInt1[m + b2 + 1];
              byte b3 = b2;
              boolean bool = true;
              byte b4;
              for (b4 = 0; bool && b4 < i5 && i + b2 + b4 < paramArrayOfint.length; b4++) {
                if (arrayOfInt1[i6 + b4] != paramArrayOfint[i + b2 + b4] || b3 >= 51) {
                  bool = false;
                } else {
                  b3++;
                } 
              } 
              if (bool)
                for (b4 = 0; i + b2 + i5 + b4 < paramArrayOfint.length && b3 < 51 && arrayOfInt1[m + b2 + 3 + b4] == paramArrayOfint[i + b2 + i5 + b4]; b4++)
                  b3++;  
              if (b3 + 3 - i5 > b) {
                i2 = m + b2;
                i1 = m;
                b = b3;
                i3 = i4;
              } else if (b2 > b) {
                i2 = -1;
                i1 = m;
                b = b2;
                i3 = i4;
              } 
              if (b2 == 0) {
                m += 3;
              } else {
                m++;
              } 
              b2 = 0;
              continue;
            } 
            if (arrayOfInt1[m + b2] != paramArrayOfint[i4 + b2]) {
              if (b2 > b) {
                i2 = -1;
                i1 = m;
                b = b2;
                i3 = i4;
              } 
              m++;
              b2 = 0;
              continue;
            } 
            b2++;
          } 
        } 
        if (b > b1) {
          while (i < i3)
            arrayOfInt1[j++] = paramArrayOfint[i++]; 
          k = i1;
          b1 = b;
          n = i2;
        } 
        if (n >= 0) {
          i4 = arrayOfInt1[n] - 4;
          int i5 = arrayOfInt1[n + 2] << 8 | arrayOfInt1[n + 1];
          System.arraycopy(arrayOfInt1, n + 3, arrayOfInt1, n + i4, j - n + 3);
          System.arraycopy(arrayOfInt1, i5, arrayOfInt1, n, i4);
          j += i4 - 3;
          for (m = n + i4; m < j; m++) {
            if (arrayOfInt1[m] < 56 && arrayOfInt1[m] >= 8) {
              i5 = arrayOfInt1[m + 2] << 8 | arrayOfInt1[m + 1];
              if (i5 > n) {
                i5 += i4 - 3;
                arrayOfInt1[m + 1] = i5 & 0xFF;
                arrayOfInt1[m + 2] = i5 >> 8;
              } 
              m += 2;
            } 
          } 
          if (k > n)
            k += i4 - 3; 
        } 
        if (b1 > 51) {
          System.err.println("Match was too long.");
          b1 = 51;
        } 
        arrayOfInt1[j++] = 8 + b1 - 4;
        arrayOfInt1[j++] = k & 0xFF;
        arrayOfInt1[j++] = k >> 8;
        i += b1;
        continue;
      } 
      arrayOfInt1[j++] = paramArrayOfint[i++];
    } 
    arrayOfInt1[j++] = paramArrayOfint[i++];
    int[] arrayOfInt2 = new int[j];
    System.arraycopy(arrayOfInt1, 0, arrayOfInt2, 0, j);
    return arrayOfInt2;
  }
}
