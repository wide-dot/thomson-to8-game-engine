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

public class Compressor {
    private byte[] output;
    private int outputIndex;
    private int inputIndex;
    private int bitIndex;
    private int bitMask;
    private int diff;
    private boolean backtrack;

    private void readBytes(int n, int delta[]) {
        inputIndex += n;
        diff += n;
        if (delta[0] < diff)
            delta[0] = diff;
    }

    private void writeByte(int value) {
        output[outputIndex++] = (byte)(value & 0xff);
        diff--;
    }

    private void writeBit(int value) {
        if (backtrack) {
            if (value > 0) {
                output[outputIndex-1] |= 1;
            }
            backtrack = false;
        } else {
            if (bitMask == 0) {
                bitMask = 128;
                bitIndex = outputIndex;
                writeByte(0);
            }
            if (value > 0) {
                output[bitIndex] |= bitMask;
            }
            bitMask >>= 1;
        }
    }

    private void writeInterlacedEliasGamma(int value, boolean backwardsMode, boolean invertMode) {
        int i = 2;
        while (i <= value) {
            i <<= 1;
        }
        i >>= 1;
        while ((i >>= 1) > 0) {
            //writeBit(backwardsMode ? 1 : 0);
        	writeBit(0);
            writeBit(invertMode == ((value & i) == 0) ? 1 : 0);
        }
        //writeBit(!backwardsMode ? 1 : 0);
        writeBit(1);
    }

    public byte[] compress(Block optimal, byte[] input, int skip, boolean backwardsMode, boolean invertMode, int delta[]) {
        int lastOffset = Optimizer.INITIAL_OFFSET;

        // calculate and allocate output buffer
        output = new byte[(optimal.getBits()+25)/8];

        // un-reverse optimal sequence
        Block prev = null;
        while (optimal != null) {
            Block next = optimal.getChain();
            optimal.setChain(prev);
            prev = optimal;
            optimal = next;
        }

        // initialize data
        diff = output.length-input.length+skip;
        delta[0] = 0;
        inputIndex = skip;
        outputIndex = 0;
        bitMask = 0;
        backtrack = true;

        // generate output
        for (optimal = prev.getChain(); optimal != null; prev = optimal, optimal = optimal.getChain()) {
            int length = optimal.getIndex()-prev.getIndex();
            if (optimal.getOffset() == 0) {
                // copy literals indicator
                writeBit(0);

                // copy literals length
                writeInterlacedEliasGamma(length, backwardsMode, false);

                // copy literals values
                for (int i = 0; i < length; i++) {
                    writeByte(input[inputIndex]);
                    readBytes(1, delta);
                }
            } else if (optimal.getOffset() == lastOffset) {
                // copy from last offset indicator
                writeBit(0);

                // copy from last offset length
                writeInterlacedEliasGamma(length, backwardsMode, false);
                readBytes(length, delta);
            } else {
                // copy from new offset indicator
                writeBit(1);

                // copy from new offset MSB
                writeInterlacedEliasGamma((optimal.getOffset()-1)/128+1, backwardsMode, invertMode);

                // copy from new offset LSB
                writeByte(backwardsMode ? ((optimal.getOffset()-1)%128)<<1 : (127-(optimal.getOffset()-1)%128)<<1);

                // copy from new offset length
                backtrack = true;
                writeInterlacedEliasGamma(length-1, backwardsMode, false);
                readBytes(length, delta);

                lastOffset = optimal.getOffset();
            }
        }

        // end marker
        writeBit(1);
        writeInterlacedEliasGamma(256, backwardsMode, invertMode);

        // done!
        return output;
    }
}
