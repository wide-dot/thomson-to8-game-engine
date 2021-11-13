/*
 * (c) Copyright 2021 by Einar Saukas. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * The name of its author may not be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package zx0;

import java.util.*;

public class Decompressor {
    private int lastOffset;
    private byte[] inputData;
    private List<Byte> output;
    private int inputIndex;
    private int bitMask;
    private int bitValue;
    private boolean backwards;
    private boolean inverted;
    private boolean backtrack;
    private int lastByte;

    private static byte[] toByteArray(List<Byte> list) {
        byte array[] = new byte[list.size()];
        int i = 0;
        for (Byte b : list) {
            array[i++] = b;
        }
        return array;
    }

    private int readByte() {
        lastByte = inputData[inputIndex++] & 0xff;
        return lastByte;
    }

    private int readBit() {
        if (backtrack) {
            backtrack = false;
            return inputData[inputIndex-1] & 0x01;
        }
        bitMask >>= 1;
        if (bitMask == 0) {
            bitMask = 128;
            bitValue = readByte();
        }
        return (bitValue & bitMask) != 0 ? 1 : 0;
    }

    private int readInterlacedEliasGamma(boolean msb) {
            int value = 1;
            while (readBit() == (backwards ? 1 : 0)) {
                value = value << 1 | readBit() ^ (msb && inverted ? 1 : 0);
            }
            return value;
    }

    private void writeByte(int value) {
        output.add((byte)(value & 0xff));
    }

    void copyBytes(int length) {
        while (length-- > 0) {
            output.add(output.get(output.size()-lastOffset));
        }
    }

    public byte[] decompress(byte[] input, boolean backwardsMode, boolean invertMode) {
        lastOffset = Optimizer.INITIAL_OFFSET;
        inputData = input;
        output = new ArrayList<Byte>();
        inputIndex = 0;
        bitMask = 0;
        backwards = backwardsMode;
        inverted = invertMode;
        backtrack = false;

        State state = State.COPY_LITERALS;
        while (state != null) {
            state = state.process(this);
        }
        return toByteArray(output);
    }

    private enum State {
        COPY_LITERALS {
            @Override
            State process(Decompressor d) {
                int length = d.readInterlacedEliasGamma(false);
                for (int i = 0; i < length; i++) {
                    d.writeByte(d.readByte());
                }
                return d.readBit() == 0 ? COPY_FROM_LAST_OFFSET : COPY_FROM_NEW_OFFSET;
            }

        },
        COPY_FROM_LAST_OFFSET {
            @Override
            State process(Decompressor d) {
                int length = d.readInterlacedEliasGamma(false);
                d.copyBytes(length);
                return d.readBit() == 0 ? COPY_LITERALS : COPY_FROM_NEW_OFFSET;
            }
        },
        COPY_FROM_NEW_OFFSET {
            @Override
            State process(Decompressor d) {
                int msb = d.readInterlacedEliasGamma(true);
                if (msb == 256) {
                    return null;
                }
                int lsb = d.readByte() >> 1;
                d.lastOffset = d.backwards ? msb*128+lsb-127 : msb*128-lsb;
                d.backtrack = true;
                int length = d.readInterlacedEliasGamma(false)+1;
                d.copyBytes(length);
                return d.readBit() == 0 ? COPY_LITERALS : COPY_FROM_NEW_OFFSET;
            }
        };

        abstract State process(Decompressor d);
    }
}
