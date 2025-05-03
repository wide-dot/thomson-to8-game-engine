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
import java.util.concurrent.*;

public class Optimizer {
    public static final int INITIAL_OFFSET = 1;
    public static final int MAX_SCALE = 50;

    private Block[] lastLiteral;
    private Block[] lastMatch;
    private Block[] optimal;
    private int[] matchLength;
    private int[] bestLength;

    private static int offsetCeiling(int index, int offsetLimit) {
        return Math.min(Math.max(index, INITIAL_OFFSET), offsetLimit);
    }

    private static int eliasGammaBits(int value) {
        int bits = 1;
        if(value > 0xFFFF) {value>>=16; bits += 32;}
        if(value > 0x00FF) {value>>=8; bits += 16;}
        if(value > 0x000F) {value>>=4; bits += 8;}
        if(value > 0x0003) {value>>=2; bits += 4;}
        if(value > 0x0001) {bits += 2;}
        return bits;
    }

    public Block optimize(byte[] input, int skip, int offsetLimit, int threads, boolean verbose) {

        // allocate all main data structures at once
        int arraySize = offsetCeiling(input.length-1, offsetLimit)+1;
        lastLiteral = new Block[arraySize];
        lastMatch = new Block[arraySize];
        optimal = new Block[input.length];
        matchLength = new int[arraySize];
        bestLength = new int[input.length];
        if (bestLength.length > 2) {
            bestLength[2] = 2;
        }

        // start with fake block
        lastMatch[INITIAL_OFFSET] = new Block(-1, skip-1, INITIAL_OFFSET, null);

        int dots = 2;
        if (verbose) {
            System.out.print("[");
        }

        // process remaining bytes
        ForkJoinPool pool = threads<=1 ? null : ForkJoinPool.commonPool(); 
        for (int index = skip; index < input.length; index++) {
            int maxOffset = offsetCeiling(index, offsetLimit);
            if (pool == null) {
                optimal[index] = processTask(1, maxOffset, index, skip, input);
            } else {
                int taskSize = maxOffset/Math.max(threads, pool.getParallelism())+1;
                List<Future<Block>> tasks = new LinkedList<>();
                for (int initialOffset = 1; initialOffset <= maxOffset; initialOffset += taskSize) {
                    final int finalOffset = Math.min(initialOffset+taskSize-1, maxOffset);
                    final int initialOffset0 = initialOffset;
                    final int index0 = index;
                    tasks.add(pool.submit(() -> processTask(initialOffset0, finalOffset, index0, skip, input)));
                }
                for (Future<Block> task: tasks) {
                    try {
                        Block taskBlock = task.get();
                        if (taskBlock != null) {
                            if (optimal[index] == null || optimal[index].getBits() > taskBlock.getBits()) {
                                optimal[index] = taskBlock;
                            }
                        }
                    } catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                }
            }

            // indicate progress
            if (verbose && index*MAX_SCALE/input.length > dots) {
                System.out.print(".");
                dots++;
            }
        }
        
        if (verbose) {
            System.out.println("]");
        }

        return optimal[input.length-1];
    }

    private Block processTask(int initialOffset, int finalOffset, int index, int skip, byte[] input) {
        int bestLengthSize = 2, ml;
        Block optimalBlock = null, lm;
        for (int offset = initialOffset; offset <= finalOffset; ++offset) {
            if (index != skip && index >= offset && input[index] == input[index-offset]) {
                // copy from last offset
                if ((lm=lastLiteral[offset]) != null) {
                    int length = index-lm.getIndex();
                    int bits = lm.getBits() + 1 + eliasGammaBits(length);
                    lm = lastMatch[offset] = new Block(bits, index, offset, lm);
                    if (optimalBlock == null || optimalBlock.getBits() > bits) {
                        optimalBlock = lm;
                    }
                }
                // copy from new offset
                if ((ml = ++matchLength[offset]) > 1) {
                    if (bestLengthSize < ml) {
                        int bits = optimal[index-bestLength[bestLengthSize]].getBits() + eliasGammaBits(bestLength[bestLengthSize]-1);
                        do {
                            ++bestLengthSize;
                            int bits2 = optimal[index-bestLengthSize].getBits() + eliasGammaBits(bestLengthSize-1);
                            if (bits2 <= bits) {
                                bestLength[bestLengthSize] = bestLengthSize;
                                bits = bits2;
                            } else {
                                bestLength[bestLengthSize] = bestLength[bestLengthSize-1];
                            }
                        } while(bestLengthSize < ml);
                    }
                    int length = bestLength[ml];
                    int bits = optimal[index-length].getBits() + 8 + eliasGammaBits((offset-1)/128+1) + eliasGammaBits(length-1);
                    if ((lm = lastMatch[offset]) == null || lm.getIndex() != index || lm.getBits() > bits) {
                        lm = lastMatch[offset] = new Block(bits, index, offset, optimal[index-length]);
                        if (optimalBlock == null || optimalBlock.getBits() > bits) {
                            optimalBlock = lm;
                        }
                    }
                }
            } else {
                // copy literals
                matchLength[offset] = 0;
                if ((lm = lastMatch[offset]) != null) {
                    int length = index-lm.getIndex();
                    int bits = lm.getBits() + 1 + eliasGammaBits(length) + length*8;
                    lm = lastLiteral[offset] = new Block(bits, index, 0, lm);
                    if (optimalBlock == null || optimalBlock.getBits() > bits) {
                        optimalBlock = lm;
                    }
                }
            }
        }
        return optimalBlock;
    }
}
