# Huffman.py
# Succinct Huffman encoder with canonical code output
# based on https://github.com/adamldoyle/Huffman
# Written by https://github.com/simondotm 2019
# https://github.com/simondotm/lz4enc-python

from heapq import *
import array
import argparse
import os
import sys
from collections import defaultdict

# Notes about this implementation:
#  1) It does not support EOF huffman codes. This makes it simpler for use with 8-bit/byte based alphabets.
#     Instead we transmit the unpacked size as an indicator for how many symbols exist in the file. We also transmit the number of padding bits.
#  2) We only support huffman code sizes upto and including 16 bits in length.
#  3) Intended for use on small files (ie. < 10Mb), since much of the code uses in-memory manipulation. 
#  4) It is binary byte based rather than text based
#  5) It generates a canonical code table, and emits a header as follows:
#       [4 bytes][Uncompressed data size]
#       [1 byte][Number of symbols Ns in symbol table, 0 means 256]
#       [1 byte][Number of entries Nb in the bitlength table]
#       [Nb bytes][bit length table]
#       [Ns bytes][symbol table]
#       [Data...]
#  6) See decode() for example parsing
#
# TODO: add a peek table

if sys.version_info[0] > 2:
    print("Python 2 only")
    sys.exit()


class Huffman:

    MAX_CODE_BIT_LENGTH = 20    # change this if you need to check the codes are within a specific bit length range
    MAX_SYMBOLS = 256           # just for clarity of code. 
    VERBOSE = False

    def __init__(self):
        self.key = {}
        self.rKey = {}
        self.table_bitlengths = []
        self.table_symbols = []

    def build(self, phrase):
        self.setFrequency(phrase)
        self.buildTree()
        self.buildKey()
        self.buildCanonical()   # convert tree to canonical codes.        

    def setFrequency(self, phrase):
        self.frequency = defaultdict(int)
        for c in phrase:
            self.frequency[c] += 1
        

    def buildTree(self):
        self.heap = [[v, k] for k, v in self.frequency.iteritems()]
        heapify(self.heap)
        while len(self.heap) > 1:
            left, right = heappop(self.heap), heappop(self.heap)
            heappush(self.heap, [left[0] + right[0], left, right])

    def buildKey(self, root=None, code=''):
        if root is None:
            self.buildKey(self.heap[0])
            for k,v in self.key.iteritems():
                self.rKey[v] = k
        elif len(root) == 2:
            self.key[root[1]] = code
        else:
            self.buildKey(root[1], code+'0')
            self.buildKey(root[2], code+'1')

    # replace the previously calculated huffman tree codes with canonical codes
    def buildCanonical(self):

        # convert the tree to an array of (bitlength, symbol) tuples
        ktable = []
        for n in range(self.MAX_SYMBOLS):
            if n in self.key:
                ktable.append( (len(self.key[n]), n ) )

        # sort them into bitlength then symbol order
        ktable.sort( key=lambda x: (x[0], x[1]) )

        # get bit range
        minbits = ktable[0][0]
        maxbits = ktable[-1][0]
        # make sure our codes comply with the length constraints
        assert minbits > 0
        assert maxbits <= self.MAX_CODE_BIT_LENGTH

        # now we build the canonical codes, replacing the previously calculated codes as we go.
        bitlength = ktable[0][0] # start with smallest code length, always the first entry since sort
        code = 0
        numsymbols = len(ktable)
        for n in range(numsymbols):
            k = ktable[n] # tuple (bitlength, symbol)
            bitlength = k[0]
            codestring = format(code, '0' + str(bitlength) + 'b') # convert the code to a binary format string, leading zeros set to bitlength                
            self.key[k[1]] = codestring
            code = (code + 1) 
            if n < (numsymbols - 1):
                code <<= ( ktable[n+1][0] - bitlength )
            if self.VERBOSE:
                print("code=" + str(n) + ", bitlength=" + str(k[0]) + ", symbol=" + str(k[1]) + ", code=" + codestring + ", check=" + str(len(codestring)==bitlength))

        # build the tables needed for decoding 
        # - a sorted array where array[n] is the number of symbols with bitlength n
        # - an array of the symbols, in sorted ascending order 
        # create a local table for the sorted bitlengths and tables
        self.table_bitlengths = [0] * (self.MAX_CODE_BIT_LENGTH+1)
        self.table_symbols = []
        for k in ktable:
            self.table_bitlengths[k[0]] += 1
            self.table_symbols.append(k[1])

        if self.VERBOSE:
            print("decoder tables (size=" + str(len(self.table_bitlengths)+len(self.table_symbols)) + ")")
            print(self.table_bitlengths)
            print(self.table_symbols)



    def addHeader(self, src_data, cmp_data, wastedBits = 0):

        block = bytearray()

        # emit table header for the decoder
        # 4 byte header, representing:
        #  4 bytes unpacked size with top 3 bits being number of wasted bits in the stream. 
        #  this informs the decoder of the size of the uncompressed stream (ie. number of symbols to decode) and how many bits were wasted
        data_size = len(src_data)
        block.append( data_size & 255 )
        block.append( (data_size >> 8) & 255 )
        block.append( (data_size >> 16) & 255 )
        block.append( ((data_size >> 24) & 31) )

        # 1 byte symbol count
        # Note: this could be alternatively calculated as the sum of the non-zero bitlengths.  
        block.append( (len(self.table_symbols) & 255) ) # size of symbol table (0 means 256)          
    
        # emit N bytes for the code bit lengths (ie. the number of symbols that have a code of the given bit length)
        assert len(self.table_bitlengths) == (self.MAX_CODE_BIT_LENGTH+1)

        mincodelen = 65536
        maxcodelen = 0
        for v in self.key:
            codelen = len(self.key[v])
            mincodelen = min(mincodelen, codelen)
            maxcodelen = max(maxcodelen, codelen)

        #print(" codes from " + str(mincodelen) + " to " + str(maxcodelen) + " bits in length")
        # make sure our codes comply with the length constraint
        #assert maxcodelen <= self.MAX_CODE_BIT_LENGTH

        # We exploit the fact that no codes have a bit length of zero, so we use that field to transmit how long the bit length table is (in bytes)
        # This way we have a variable length header, and transmit the minimum amount of header data.
        self.table_bitlengths[0] = maxcodelen #len(self.table_symbols)
        for n in range(maxcodelen+1):
            block.append(self.table_bitlengths[n])

        # emit N bytes for the symbols table
        for n in self.table_symbols:
            block.append(n & 255)

        block += cmp_data
        return block

    # Huffman compress the given bytearray 'phrase' using the tree calculated by build()
    # Returns a bytearray() of the encoded data, with optional header data
    def encode(self, phrase, header = True):

        output = bytearray()

        # huffman encode and transmit the data stream
        currentbyte = 0  # The accumulated bits for the current byte, always in the range [0x00, 0xFF]
        numbitsfilled = 0  # Number of accumulated bits in the current byte, always between 0 and 7 (inclusive)

        sz = 0
        # for each symbol in the input data, fetch the assigned code and emit it to the output bitstream
        fastcount = 0
        bitsize_to_count = 8
        for c in phrase:
            k = self.key[c]
            sz += len(k)
            if len(k) <= bitsize_to_count:
                fastcount += 1
            for b in k:
                bit = int(b)
                assert bit == 0 or bit == 1
                currentbyte = (currentbyte << 1) | bit
                numbitsfilled += 1
                if numbitsfilled == 8:  # full byte, flush to output
                    output.append(currentbyte)
                    currentbyte = 0
                    numbitsfilled = 0                  

        if self.VERBOSE:
            print(" " + str(fastcount) + " of " + str(len(phrase)) + " symbols were " + str(bitsize_to_count) + " bits or less in size (" + str(fastcount*100/len(phrase)) + "%)")

        # align to byte. we could emit code >7 bits in length to prevent decoder finding a spurious code at the end, but its likely
        # some data sets may contain codes <7 bits. Easier to just pad wasted bytes.
        wastedbits = (8 - numbitsfilled) & 7
        while (numbitsfilled < 8) and wastedbits:
            currentbyte = (currentbyte << 1) | 1
            numbitsfilled += 1
        output.append(currentbyte)

        # add headers if required.
        if header:
            output = self.addHeader(phrase, output, wastedBits = wastedbits)

        if header:
            # test decode
            self.decode(output, phrase)

        return output

    # test decoder
    def decode(self, data, source):

        # read the header
        if self.VERBOSE:
            print("Checking data...")

        # get the unpacked size - this tells us how many symbols to decode
        unpacked_size = data[0] + (data[1]<<8) + (data[2]<<16) + ((data[3] & 31)<<24) # uncompressed size
        wastedbits = data[3] >> 5
        
        symbol_table_size = data[4]      # fetch the number of symbols in the symbol table
        length_table_size = data[5] + 1  # fetch the number of entries in the bit length table (+1 because we include zero)

        # interpret 0 as 256
        if symbol_table_size == 0:
            symbol_table_size = 256

        length_table = data[5:5+length_table_size]
        symbol_table = data[5+length_table_size:5+length_table_size+symbol_table_size]

        # decode the stream
        currentbyte = 5 + length_table_size + symbol_table_size

        output = bytearray()

        bitbuffer = 0
        numbitsbuffered = 0
        code = 0
        code_size = 0

        firstCodeWithNumBits = 0
        startIndexForCurrentNumBits = 0

        sourceindex = 0
        unpacked = 0
        while unpacked < unpacked_size:

            # keep the bitbuffer going
            if numbitsbuffered == 0:
                # we're out of data, so any wip codes are invalid due to byte padding.
                bitbuffer = data[currentbyte]
                currentbyte += 1
                numbitsbuffered += 8

            # get a bit
            bit = (bitbuffer & 128) >> 7
            bitbuffer <<= 1
            numbitsbuffered -= 1

            # build code
            code = (code << 1) | bit
            code_size += 1

            # how many canonical codes have this many bits
            assert code_size <= self.MAX_CODE_BIT_LENGTH
            numCodes = length_table[code_size]

            # if input code so far is within the range of the first code with the current number of bits, it's a match
            indexForCurrentNumBits = code - firstCodeWithNumBits
            if indexForCurrentNumBits < numCodes:
                code = startIndexForCurrentNumBits + indexForCurrentNumBits

                symbol = symbol_table[code]
                output.append(symbol)
                expected = source[sourceindex]
                assert symbol == expected
                sourceindex += 1

                code = 0
                code_size = 0

                firstCodeWithNumBits = 0
                startIndexForCurrentNumBits = 0      

                unpacked += 1          

            else:
                # otherwise, move to the next bit length
                firstCodeWithNumBits = (firstCodeWithNumBits + numCodes) << 1
                startIndexForCurrentNumBits += numCodes

        assert len(output) == len(source)
        assert output == source

        if self.VERBOSE:
            print(" Test decode OK.")



# Determine if running as a script
if __name__ == '__main__':

    print("Huffman.py : Canonical Huffman compressor")
    print("Written in 2019 by Simon M, https://github.com/simondotm/")
    print("")

    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument("input", help="read from file [input]")
    parser.add_argument("output", help="output to file [output]")
    parser.add_argument("-v", "--verbose", help="Enable verbose mode", action="store_true")
    args = parser.parse_args()


    src = args.input
    dst = args.output
    if dst == None:
        dst = src + ".lz4"

    # check for missing files
    if not os.path.isfile(src):
        print("ERROR: File '" + src + "' not found")
        sys.exit()

    # load the file
    src_data = bytearray(open(src, "rb").read())

    huffman = Huffman()
    huffman.VERBOSE = args.verbose
    huffman.build(src_data)

    dst_data = huffman.encode( src_data, header = True ) 

    open(dst, "wb").write(dst_data)

    src_size = len(src_data)
    dst_size = len(dst_data)
    if src_size == 0:
        ratio = 0
    else:
        ratio = 100 - (int)((dst_size*100 / src_size))

    print(" Compressed '" + src + "', " + str(src_size) + " into " + str(dst_size) + " bytes => " + str(ratio) + "%")
