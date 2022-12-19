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

import static java.nio.file.StandardOpenOption.*;
import java.nio.file.*;

public class Main {
    public static final int MAX_OFFSET_ZX0 = 32640;
    //public static final int MAX_OFFSET_ZX7 = 2176;
    public static final int MAX_OFFSET_ZX7 = 512;
    public static final int DEFAULT_THREADS = 4;

    private static int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return -1;
        }
    }

    private static void reverse(byte[] array) {
        int i = 0;
        int j = array.length-1;
        while (i < j) {
            byte k = array[i];
            array[i++] = array[j];
            array[j--] = k;
        }
    }

    private static byte[] zx0(byte[] input, int skip, boolean backwardsMode, boolean classicMode, boolean quickMode, int threads, boolean verbose, int delta[]) {
        return new Compressor().compress(
                new Optimizer().optimize(input, skip, quickMode ? MAX_OFFSET_ZX7 : MAX_OFFSET_ZX0, threads, verbose),
                input, skip, backwardsMode, !classicMode && !backwardsMode, delta);
    }

    private static byte[] dzx0(byte[] input, boolean backwardsMode, boolean classicMode) {
        return new Decompressor().decompress(input, backwardsMode, !classicMode && !backwardsMode);
    }

    public static void main(String[] args) throws Exception {
        System.out.println("ZX0 v2.2: Optimal data compressor by Einar Saukas");

        // process optional parameters
        int threads = DEFAULT_THREADS;
        boolean forcedMode = false;
        boolean classicMode = false;
        boolean backwardsMode = false;
        boolean quickMode = false;
        boolean decompress = false;
        int skip = 0;
        int i = 0;
        while (i < args.length && (args[i].startsWith("-") || args[i].startsWith("+"))) {
            if (args[i].startsWith("-p")) {
                threads = parseInt(args[i].substring(2));
                if (threads <= 0) {
                    System.err.println("Error: Invalid parameter " + args[i]);
                    System.exit(1);
                }
            } else {
                switch (args[i]) {
                    case "-f":
                        forcedMode = true;
                        break;
                    case "-c":
                        classicMode = true;
                        break;
                    case "-b":
                        backwardsMode = true;
                        break;
                    case "-q":
                        quickMode = true;
                        break;
                    case "-d":
                        decompress = true;
                        break;
                    default:
                        skip = parseInt(args[i]);
                        if (skip <= 0) {
                            System.err.println("Error: Invalid parameter " + args[i]);
                            System.exit(1);
                        }
                }
            }
            i++;
        }

        if (decompress && skip > 0) {
            System.err.println("Error: Decompressing with "+(backwardsMode ? "suffix" : "prefix")+" not supported");
            System.exit(1);
        }

        // determine output filename
        String outputName = null;
        if (args.length == i+1) {
            if (!decompress) {
                outputName = args[i] + ".zx0";
            } else {
                if (args[i].length() > 4 && args[i].endsWith(".zx0")) {
                    outputName = args[i].substring(0, args[i].length()-4);
                } else {
                    System.err.println("Error: Cannot infer output filename");
                    System.exit(1);
                }
            }
        } else if (args.length == i+2) {
            outputName = args[i + 1];
        } else {
            System.err.println("Usage: java -jar zx0.jar [-pN] [-f] [-c] [-b] [-q] [-d] input [output.zx0]\n" +
                    "  -p      Parallel processing with N threads\n" +
                    "  -f      Force overwrite of output file\n" +
                    "  -c      Classic file format (v1.*)\n" +
                    "  -b      Compress backwards\n" +
                    "  -q      Quick non-optimal compression\n" +
                    "  -d      Decompress");
            System.exit(1);
        }

        // read input file
        byte[] input = null;
        try {
            input = Files.readAllBytes(Paths.get(args[i]));
        } catch (Exception e) {
            System.err.println("Error: Cannot read input file " + args[i]);
            System.exit(1);
        }

        // determine input size
        if (input.length == 0) {
            System.err.println("Error: Empty input file " + args[i]);
            System.exit(1);
        }

        // validate skip against input size
        if (skip >= input.length) {
            System.err.println("Error: Skipping entire input file " + args[i]);
            System.exit(1);
        }

        // check output file
        if (!forcedMode && Files.exists(Paths.get(outputName))) {
            System.err.println("Error: Already existing output file " + outputName);
            System.exit(1);
        }

        // conditionally reverse input file
        if (backwardsMode) {
            reverse(input);
        }

        // generate output file
        byte[] output = null;
        int[] delta = { 0 };

        if (!decompress) {
            output = zx0(input, skip, backwardsMode, classicMode, quickMode, threads, true, delta);
        } else {
            try {
                output = dzx0(input, backwardsMode, classicMode);
            } catch (ArrayIndexOutOfBoundsException e) {
                System.err.println("Error: Invalid input file " + args[i]);
                System.exit(1);
            }
        }

        // conditionally reverse output file
        if (backwardsMode) {
            reverse(output);
        }

        // write output file
        try {
            Files.write(Paths.get(outputName), output, CREATE, forcedMode ? TRUNCATE_EXISTING : CREATE_NEW);
        } catch (Exception e) {
            System.err.println("Error: Cannot write output file " + outputName);
            System.exit(1);
        }

        // done!
        if (!decompress) {
            System.out.println("File " + (skip > 0 ? "partially " : "") + "compressed " + (backwardsMode ? "backwards " : "") + "from " + (input.length-skip) + " to " + output.length + " bytes! (delta " + delta[0] + ")");
        } else {
            System.out.println("File decompressed " + (backwardsMode ? "backwards " : "") + "from " + (input.length-skip) + " to " + output.length + " bytes!");
        }
    }
}
