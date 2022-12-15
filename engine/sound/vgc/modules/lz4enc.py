#!/usr/bin/env python
# lz4enc.py
# Python LZ4 compression module based on smallz4 
# smallz4 by Stephan Brumme (https://create.stephan-brumme.com/smallz4/)
# lz4enc.py by @simondotm (https://github.com/simondotm)



import struct
import os
import sys
import argparse

from timeit import default_timer as timer
import profile

# LZ4 compression with optimal parsing, based on smallz4, refactored for more general purpose use within Python scripts.
class LZ4():

  # version string
  Version = "1.3"

  # compression level thresholds, made public because I display them in the help screen ...

  # greedy mode for short chains (compression level <= 3) instead of optimal parsing / lazy evaluation
  ShortChainsGreedy = 3
  # lazy evaluation for medium-sized chains (compression level > 3 and <= 6)
  ShortChainsLazy   = 6

  # ----- constants and types -----
  # a block can be 4 MB
  # matches must start within the most recent 64k

  # each match's length must be >= 4
  MinMatch          =  4
  # last match must not be closer than 12 bytes to the end
  BlockEndNoMatch   = 12
  # last 5 bytes must be literals, no matching allowed
  BlockEndLiterals  =  5
  # match finder's hash table size (2^HashBits entries, must be less than 32)
  HashBits          = 20
  # input buffer size, can be any number but zero ;-)
  BufferSize     = 64*1024
  # maximum match distance
  MaxDistance    = 65535
  # marker for "no match"
  NoPrevious     =       0
  # stop match finding after MaxChainLength steps (default is unlimited => optimal parsing)
  MaxChainLength = NoPrevious
  # significantly speed up parsing if the same byte is repeated a lot, may cause sub-optimal compression
  MaxSameLetter  =   19 + 255*256 # was: 19 + 255
  # refer to location of the previous match (implicit hash chain)
  PreviousSize   = 1 << 16
  # maximum block size as defined in LZ4 spec: { 0,0,0,0,64*1024,256*1024,1024*1024,4*1024*1024 }
  # I only work with the biggest maximum block size (7)
  #  note: xxhash header checksum is precalculated only for 7, too
  MaxBlockSizeId = 7
  MaxBlockSize   = 4*1024*1024

  # Number of bytes used to store match distances.
  # 2 bytes (16-bits) is the LZ4 default
  # If MaxDistance < 256, this can be set to 1 and the compressor will emit only 1 byte for distance offset rather than 2.
  # Note that changing this value will create non-compliant LZ4 data streams and require a customized decompressor
  DistanceByteSize = 2

  # Verbose mode
  Verbose = False

  # Debug mode
  Debug = False

  #  ----- code -----
  
  #-------------------------------------------------------------------------------------------------
  # create new compressor instance
  # Sets default compression level of 9
  #-------------------------------------------------------------------------------------------------
  def __init__(self, level = 9):
    self.setCompression(level)
    self.stats = {}

  #-------------------------------------------------------------------------------------------------
  # The encoder tracks compression statistics to enable output analysis
  # LZ4.resetStats() is called by LZ4.beginFrame()
  # it can also be called manually if compressing using LZ4.compressBlock()
  #-------------------------------------------------------------------------------------------------
  def resetStats(self):
    self.stats = {}
    # OLD COMMENT matchLength can be 4 + 14 + 254 in 12-bits = 272
    self.stats["tokenCount"] = 0      # number of tokens in this block
    self.stats["largestOffset"] = 0   # largest stored match distance in this block
    self.stats["largestLength"] = 0   # largest stored match length in this block
    self.stats["byteOffsetCount"] = 0 # number of match distances that were 255 or less
    self.stats["sameOffsetCount"] = 0 # number of match distances that were the same as the previous one
    self.stats["lastOffset"] = -1     # temporary var for tracking the last match distance

    # Gather LZ4 output data streams as separate blocks rather than the usual interleaved output (useful for creating custom formats)
    # Inspired by LZ5, more optimal non-LZ4 compatible output formats can be created by huffman encoding this data. 
    self.stats["tokens"] = []         # array of tokens stored in this block
    self.stats["offsets"] = []        # array of offsets (match distances) stored in this block
    self.stats["lengths"] = []        # array of match lengths stored in this block
    self.stats["literal_bytes"] = []  # array of literals byte stream data (as per LZ5)
    self.stats["lengths_bytes"] = []  # array of lengths byte stream data (as per LZ5) - literal lengths first, then match lengths (where length stored in the token was 15)
    

  #-------------------------------------------------------------------------------------------------
  # match struct
  #-------------------------------------------------------------------------------------------------
  class Match:
  
    def __init__(self):
      # length of match
      self.length = 0
      # start of match
      self.distance = 0

    # true, if long enough
    def isMatch(self):
      return self.length >= LZ4.MinMatch


  #-------------------------------------------------------------------------------------------------
  # find longest match of data[pos] between data[begin] and data[end], use match chain stored in previous
  # returns a Match object
  #
  # data - bytearray
  # pos, begin, end - int
  # previous - Distance list/array
  #-------------------------------------------------------------------------------------------------
  def findLongestMatch(self, data, pos, begin, end, previous):
  
    # return true, if the four bytes at data[a] and data[b] match
    def match4(a, b):
      # bytewise equivalence is fine
      return data[a:a+4] == data[b:b+4]
  
    result = self.Match()
    result.length = 1

    # compression level: look only at the first n entries of the match chain
    stepsLeft = self.maxChainLength

    # pointer to position that is matched against everything in data
    current = pos - begin

    # don't match beyond this point
    stop    = current + end - pos

    # get distance to previous match, abort if 0 => not existing
    distance = previous[pos % self.PreviousSize]
    totalDistance = 0
    while (distance != self.NoPrevious):
      # too far back ?
      totalDistance += distance
      if (totalDistance > self.MaxDistance):
        break

      # prepare next position
      distance = previous[(pos - totalDistance) % self.PreviousSize]
      
      # stop searching on lower compression levels
      if (stepsLeft <= 0):
        break
      stepsLeft -= 1


      # let's introduce a new pointer atLeast that points to the first "new" byte of a potential longer match
      atLeast = current + result.length + 1

      # the idea is to split the comparison algorithm into 2 phases
      # (1) scan backward from atLeast to current, abort if mismatch
      # (2) scan forward  until a mismatch is found and store length/distance of this new best match
      # current                  atLeast
      #    |                        |
      #    -<<<<<<<< phase 1 <<<<<<<<
      #                              >>> phase 2 >>>
      # impossible to find a longer match because not enough bytes left ?
      if (atLeast > stop):
        break
      # all bytes between current and atLeast shall be identical, compare 4 bytes at once
      compare = atLeast - 4

      INLINE_MATCH4 = True

      ok = True
      while (compare > current):

        # mismatch ?

        if INLINE_MATCH4:
          a = compare
          b = compare - totalDistance
          if data[a:a+4] != data[b:b+4]:
            ok = False
            break
        else:
          if (not match4(compare, compare - totalDistance)):
            ok = False
            break

        # keep going ...
        compare -= 4
        # note: - the first four bytes always match
        #       - in the last iteration, compare is either current + 1 or current + 2 or current + 3
        #       - therefore we compare a few bytes twice => but a check to skip these checks is more expensive
      

      # mismatch ?
      if (not ok):
        continue

      # we have a new best match, now scan forward from the end
      compare = atLeast

      # fast loop: check four bytes at once
      if INLINE_MATCH4:
        compare2 = compare - totalDistance
        while (compare + 4 <= stop and data[compare:compare+4] == data[compare2:compare2+4]):
          compare += 4
          compare2 += 4
      else:
        while (compare + 4 <= stop and match4(compare,     compare - totalDistance)):
          compare += 4



      # slow loop: check the last 1/2/3 bytes
      while (compare < stop and data[compare] == data[compare - totalDistance]):
        compare += 1

      # store new best match
      result.distance = totalDistance
      result.length   = compare - current
    
    return result
  
  #-------------------------------------------------------------------------------------------------
  # create shortest output
  #  data points to block's begin; we need it to extract literals
  #
  # returns bytearray
  #-------------------------------------------------------------------------------------------------
  def selectBestMatches(self, matches, data, index):
    # store encoded data
    result = bytearray()

    # indices of current literal run
    literalsFrom = 0
    literalsTo   = 0 # point beyond last literal of the current run

    # walk through the whole block
    offset = 0
    while (offset < len(matches)): # increment inside of loop

      # get best cost-weighted match
      match = self.Match()
      match.length = matches[offset].length
      match.distance = matches[offset].distance
      
      # debug output
      if self.Debug:
        print("offset="+str(offset)+", length="+str(match.length)+", distance="+str(match.distance))
      
      # if no match, then count literals instead
      if (not match.isMatch()):
      
        # first literal
        if (literalsFrom == literalsTo):
          literalsFrom = literalsTo = offset

        # one more literal
        literalsTo += 1
        # ... and definitely no match
        match.length = 1
      
      offset += match.length

      lastToken = (offset == len(matches))
      # continue if simple literal
      if (not match.isMatch() and not lastToken):
        continue

      # emit token
      # count literals
      numLiterals = literalsTo - literalsFrom

      # store literals' length
      if (numLiterals < 15):
        token = numLiterals
      else:
        token = 15

      token <<= 4

      # store match length (4 is implied because it's the minimum match length)
      matchLength = match.length - 4
      if (not lastToken):
        if (matchLength < 15):
          token |= matchLength
        else:
          token |= 15

      result.append( token ) #struct.pack('B', token) )
      self.stats["tokens"].append( token )

      self.stats["tokenCount"] += 1    
      self.stats["offsets"].append( match.distance )
      self.stats["lengths"].append( matchLength )


      # >= 15 literals ? (extra bytes to store length)
      if (numLiterals >= 15):
      
        # 15 is already encoded in token
        numLiterals -= 15
        # emit 255 until remainder is below 255
        while (numLiterals >= 255):       
          result.append(255)
          self.stats["lengths_bytes"].append(255)
          numLiterals -= 255
        
        # and the last byte (can be zero, too)
        result.append(numLiterals)
        self.stats["lengths_bytes"].append(numLiterals)
      
      # copy literals
      if (literalsFrom != literalsTo):
      
        subset = data[index + literalsFrom:index + literalsTo]
        result.extend( subset )
        for z in subset:
          self.stats["literal_bytes"].append(z)

        literalsFrom = 0
        literalsTo = 0
      
      # last token doesn't have a match
      if (lastToken):
        break

      # stats
      if match.distance > self.stats["largestOffset"]:
        self.stats["largestOffset"] = match.distance
      if matchLength > self.stats["largestLength"]:
        self.stats["largestLength"] = matchLength
      if match.distance < 256:
        self.stats["byteOffsetCount"] += 1
      if match.distance == self.stats["lastOffset"]:
        self.stats["sameOffsetCount"] += 1
      self.stats["lastOffset"] = match.distance

      # distance stored as 1 or two bytes in data stream
      if self.DistanceByteSize == 1:
        assert match.distance < 256
        # distance stored in 8 bits (non LZ4 compliant, but optimal data size - requires modified decoder)
        result.append( match.distance & 0xFF )
      else:
        # distance stored in 16 bits / little endian
        result.append( match.distance & 0xFF )
        result.append( (match.distance >> 8) & 0xFF )



      # >= 15+4 bytes matched (4 is implied because it's the minimum match length)
      if (matchLength >= 15):
        # 15 is already encoded in token
        matchLength -= 15
        # emit 255 until remainder is below 255
        while (matchLength >= 255):
          result.append(255)
          self.stats["lengths_bytes"].append(255)
          matchLength -= 255
        
        # and the last byte (can be zero, too)
        result.append(matchLength)
        self.stats["lengths_bytes"].append(matchLength)
      

    # debug output
    if LZ4.Debug:
      print("    largestOffset=" + str(largestOffset))
      print("    largestLength=" + str(largestLength))
      print("       tokenCount=" + str(tokenCount))
      print("  byteOffsetCount=" + str(byteOffsetCount) + " (ie. offsets were <256)")
      print("  sameOffsetCount=" + str(sameOffsetCount) + " (ie. number of offsets that were repeated)")

    return result
  
  #-------------------------------------------------------------------------------------------------
  # walk backwards through all matches and compute number of compressed bytes from current position to the end of the block
  #  note: matches are modified (shortened length) if necessary
  #-------------------------------------------------------------------------------------------------
  def estimateCosts(self, matches):
    blockEnd = len(matches)

    # minimum cost from this position to the end of the current block
    cost = [0] * len(matches)
    
    # "cost" represents the number of bytes needed
    # backwards optimal parsing
    posLastMatch = blockEnd

    # ignore the last 5 bytes, they are always literals
    blockRange = blockEnd - (1 + self.BlockEndLiterals)
    for i in range(blockRange, -1, -1 ): # lower range is -1 so we hit 0

      # show progress
      if (i & 511) == 0:
        sys.stdout.write("   Calculating cost data " + str(100-int(i*100/(blockRange))) + "%...\r")
        sys.stdout.flush()

      # watch out for long literal strings that need extra bytes
      numLiterals = posLastMatch - i
      # assume no match
      minCost = cost[i + 1] + 1
      # an extra byte for every 255 literals required to store length (first 14 bytes are "for free")
      if (numLiterals >= 15 and (numLiterals - 15) % 255 == 0):
        minCost += 1

      # if encoded as a literal
      bestLength = 1

      # analyze longest match
      match = self.Match()
      match.length = matches[i].length
      match.distance = matches[i].distance    
      
      # match must not cross block borders
      if (match.isMatch() and i + match.length + self.BlockEndLiterals > blockEnd):
        match.length = blockEnd - (i + self.BlockEndLiterals)

      # try all match lengths (first short ones)
      for length in range(self.MinMatch, match.length+1):
      
        # token (1 byte) + offset (1 or 2 bytes)
        currentCost = cost[i + length] + 1 + self.DistanceByteSize # might be 1 byte offset cost instead of 2

        # very long matches need extra bytes for encoding match length
        if (length >= 19):
          currentCost += 1 + (length - 19) / 255
        
        # better choice ?
        if (currentCost <= minCost):
        
          # regarding the if-condition:
          # "<"  prefers literals and shorter matches
          # "<=" prefers longer matches
          # they should produce the same number of bytes (because of the same cost)
          # ... but every now and then it doesn't !
          # that's why: too many consecutive literals require an extra length byte
          # (which we took into consideration a few lines above)
          # but we only looked at literals beyond the current position
          # if there are many literal in front of the current position
          # then it may be better to emit a match with the same cost as the literals at the current position
          # => it "breaks" the long chain of literals and removes the extra length byte
          minCost    = currentCost
          bestLength = length
          # performance-wise, a long match is usually faster during decoding than multiple short matches
          # on the other hand, literals are faster than short matches as well (assuming same cost)
        
        # workaround: very long self-referencing matches can slow down the program A LOT
        if (match.distance == 1 and match.length >= self.MaxSameLetter):
        
          # assume that longest match is always the best match
          # however, this assumption might not be optimal
          bestLength = match.length
          minCost    = cost[i + match.length] + 1 + self.DistanceByteSize + 1 + (match.length - 19) / 255
          break
        
      
      # remember position of last match to detect number of consecutive literals
      if (bestLength >= self.MinMatch):
        posLastMatch = i

      # store lowest cost so far
      cost[i] = minCost
      # and adjust best match
      matches[i].length = bestLength
      if (bestLength == 1):
        matches[i].distance = self.NoPrevious

      # note: if bestLength is smaller than the previous matches[i].length then there might be a closer match
      #       which could be more cache-friendly (=> faster decoding)
    
  #--------------------------------------------------------------------------------------------------------------------------------
  # create an LZ4 compressed block from the input buffer
  # return the compressed block as an output buffer
  # improve compression with a predefined dictionary
  #--------------------------------------------------------------------------------------------------------------------------------
  # inputData, and dictionary are bytearray's
  # returns a bytearray containing the compressed LZ4 stream
  def compressBlock(self, inputData, dictionary = bytearray()):

    outputData = bytearray()

    # write a byte array to the output buffer, data can be a byte or a byte array
    def sendBytes(data):
      if len(data) == 1:
        outputData.append(data)
      else:
        outputData.extend(data)

    # read upto count bytes from the input buffer, returned in a new bytearray 'buffer'. Returns an empty buffer if no more data available.
    def getBytes(count):
      ptr = getBytes.inputPointer
      if ptr >= len(inputData):
        return bytearray()
      else:
        if ptr+count >= len(inputData):
          count = len(inputData) - ptr

        buf = inputData[ptr:ptr+count]
        getBytes.inputPointer = ptr + count
        return buf

    # initialise getByte read stream
    getBytes.inputPointer = 0
   
    # ==================== declarations ====================
    # read the file in chunks/blocks, data will contain only bytes which are relevant for the current block
    data = bytearray()
    # file position corresponding to data[0]
    dataZero = 0
    # last already read position
    numRead  = 0
    # passthru data (but still wrap in LZ4 format)
    uncompressed = (self.maxChainLength == 0)
    # last time we saw a hash
    HashSize   = 1 << self.HashBits
    NoLastHash = 0x7FFFFFFF

    lastHash = [NoLastHash] * HashSize

    HashMultiplier = 22695477 # taken from https:#en.wikipedia.org/wiki/Linear_congruential_generator
    HashShift  = 32 - self.HashBits # uint8
    
    # previous position which starts with the same bytes
    previousHash = [self.NoPrevious] * self.PreviousSize
    previousExact = [self.NoPrevious] * self.PreviousSize
    
    
    # change buffer size as you like
    buffer = bytearray(self.BufferSize)

    # first and last offset of a block (next is end-of-block plus 1)
    lastBlock = 0
    nextBlock = 0
    parseDictionary = len(dictionary) > 0

    while (True):
    
      # ==================== start new block ====================
      # first byte of the currently processed block (std::vector data may contain the last 64k of the previous block, too)

      # dataBlock is an offset within data[] - see below

      # prepend dictionary
      if (parseDictionary):

        if LZ4.Verbose:
          print(" Loading Dictionary...")

        # prepend exactly 64k
        MaxDictionary = 65536
        if (len(dictionary) < MaxDictionary):
          # add garbage data
          unused = 65536 - len(dictionary)
          data.extend( bytearray(unused) )
        else:
          # copy only the most recent 64k of the dictionary
          doffset = len(dictionary) - MaxDictionary
          data.extend( bytearray( dictionary[doffset:]) )

        nextBlock = len(data)
        numRead   = len(data)
      
      # read more bytes from input
      maxBlockSize = self.MaxBlockSize



      while (numRead - nextBlock < maxBlockSize):
      
        # buffer can be significantly smaller than MaxBlockSize, that's the only reason for this while-block
        buffer = getBytes(self.BufferSize)
        incoming = len(buffer)
        if (incoming == 0):
          break
        numRead += incoming

        data.extend( buffer )
      
      # no more data ? => WE'RE DONE !
      if (nextBlock == numRead):
        break

      if LZ4.Verbose:
        print(" Processing Block... " + str(numRead>>10) + "Kb, (maxBlockSize=" + str(maxBlockSize>>10) + "Kb, windowSize=" + str(self.MaxDistance>>10) + "Kb)")

      # determine block borders
      lastBlock  = nextBlock
      nextBlock += maxBlockSize

      # not beyond end-of-file
      if (nextBlock > numRead):
        nextBlock = numRead

      # first byte of the currently processed block (std::vector data may contain the last 64k of the previous block, too)

      # dataBlock is an offset into data[]
      dataBlock = lastBlock - dataZero
      blockSize = nextBlock - lastBlock

      # ==================== full match finder ====================
      if LZ4.Verbose:
        print("  Finding matches...")
      # greedy mode is much faster but produces larger output
      isGreedy = (self.maxChainLength <= self.ShortChainsGreedy)
      # lazy evaluation: if there is a (match, then try running match finder on next position, too, but not after that
      isLazy   = (isGreedy == False) and (self.maxChainLength <= self.ShortChainsLazy)

      # skip match finding on the next x bytes in greedy mode
      skipMatches = 0
      # allow match finding on the next byte but skip afterwards (in lazy mode)
      lazyEvaluation = False

      # the last literals of the previous block skipped matching, so they are missing from the hash chains
      lookback = dataZero
      if (lookback > self.BlockEndNoMatch and (parseDictionary == False)):
        lookback = self.BlockEndNoMatch

      if (parseDictionary):
        lookback = len(dictionary)

      # so let's go back a few bytes
      lookback = -lookback
 
      matches = [ self.Match() for i in range(blockSize) ]

      # find longest matches for each position
      for i in range(lookback, blockSize):

        # show progress
        if (i & 511) == 0 or i == (blockSize - 1):
          sys.stdout.write("   Scanning block data " + str(int(i*100/(blockSize-1))) + "%...\r")
          sys.stdout.flush()

        # no matches at the end of the block (or matching disabled by command-line option -0 )
        if (i + self.BlockEndNoMatch > blockSize or uncompressed):
          continue
      
        # detect self-matching
        if (i > 0 and data[dataBlock + i] == data[dataBlock + i - 1]):

          prevMatch = matches[i - 1]  # Python version of prevMatch is a reference not an instance
          
          # predecessor had the same match ?
          if (prevMatch.distance == 1 and prevMatch.length > self.MaxSameLetter): # TODO: handle very long self-referencing matches          
            # just copy predecessor without further (expensive) optimizations
            matches[i].length = prevMatch.length - 1
            matches[i].distance = prevMatch.distance
            continue
          
        def getLong(buffer, offset):
          end = offset + 4
          buf = buffer[offset:end]
          four = struct.unpack('>L', buf)[0]
          return four

        # read next four bytes
        four = getLong(data, dataBlock + i)

        # convert to a shorter hash
        hash = ((four * HashMultiplier) >> HashShift) & (HashSize - 1)
        
        # get last occurrence of these bits
        last = lastHash[hash]
        
        # and store current position
        lastHash[hash] = i + lastBlock
        
        # remember: i could be negative, too
        prevIndex = (i + self.PreviousSize) % self.PreviousSize
        
        # no predecessor or too far away ?
        distance = i + lastBlock - last
        if (last == NoLastHash or distance > self.MaxDistance):
          previousHash[prevIndex] = self.NoPrevious
          previousExact[prevIndex] = self.NoPrevious
          continue
        
        # build hash chain, i.e. store distance to last match
        previousHash[prevIndex] = distance

        # skip pseudo-matches (hash collisions) and build a second chain where the first four bytes must match exactly
        while (distance != self.NoPrevious):
          curFour = getLong(data, last - dataZero)  # may be in the previous block, too

          # actual match found, first 4 bytes are identical
          if (curFour == four):
            break

          # prevent from accidently hopping on an old, wrong hash chain
          curHash = ((curFour * HashMultiplier) >> HashShift) & (HashSize - 1)
          if (curHash != hash):
            distance = self.NoPrevious
            break
          
          # try next pseudo-match
          next = previousHash[last % self.PreviousSize]

          # pointing to outdated hash chain entry ?
          distance += next

          if (distance > self.MaxDistance):
            previousHash[last % self.PreviousSize] = self.NoPrevious
            distance = self.NoPrevious
            break
          
          # closest match is out of range ?
          last -= next
          if (next == self.NoPrevious or last < dataZero):
            distance = self.NoPrevious
            break
          
        
        # no match at all ?
        if (distance == self.NoPrevious):
          previousExact[prevIndex] = self.NoPrevious
          continue
        
        # store distance to previous match
        previousExact[prevIndex] = distance

        # no matching if crossing block boundary, just update hash tables
        if (i < 0):
          continue

        # skip match finding if in greedy mode
        if (skipMatches > 0):
          skipMatches -= 1
          if (not lazyEvaluation):
            continue

          lazyEvaluation = False
        
        # and look for longest match
        longest = self.findLongestMatch(data, i + lastBlock, dataZero, nextBlock - self.BlockEndLiterals + 1, previousExact)
        matches[i] = longest

        # no match finding needed for the next few bytes in greedy/lazy mode
        if (longest.isMatch() and (isLazy or isGreedy)):
          lazyEvaluation = (skipMatches == 0)
          skipMatches = longest.length
        
      
      # dictionary applies only to the first block
      parseDictionary = False
      
      # ==================== estimate costs (number of compressed bytes) ====================
      if LZ4.Verbose:
        print("")
        print("  Estimating costs...")

      # not needed in greedy mode and/or very short blocks
      if (len(matches) > self.BlockEndNoMatch and self.maxChainLength > self.ShortChainsGreedy):
        self.estimateCosts(matches)

      # ==================== select best matches ====================
      if LZ4.Verbose:
        print("")
        print("  Selecting best matches...")
      
      block = bytearray()
      if (not uncompressed):
        block = self.selectBestMatches(matches, data, lastBlock - dataZero )
      
      # ==================== output ====================
      # automatically decide whether compressed or uncompressed
      uncompressedSize = nextBlock - lastBlock

      # did compression do harm ?
      useCompression   = len(block) < uncompressedSize and not uncompressed

      if LZ4.Verbose:
        print(" Writing output block - uncompressed (" + str(uncompressedSize) + "), compressed (" + str(len(block)) + ") ...")
        if useCompression:
          print("  Compressed data selected for this block.")
        else:
          print("  Uncompressed data selected for this block.")
     
      # block size
      if useCompression:
        numBytes = len(block)
      else:
        numBytes = uncompressedSize

      numBytesTagged = numBytes
      if (not useCompression):
        numBytesTagged |= 0x80000000

      num1 =  numBytesTagged         & 0xFF
      sendBytes( struct.pack('B', num1) )
      num2 = (numBytesTagged >>  8)  & 0xFF
      sendBytes( struct.pack('B', num2) )
      num3 = (numBytesTagged >> 16)  & 0xFF
      sendBytes( struct.pack('B', num3) )
      num4 = (numBytesTagged >> 24)  & 0xFF
      sendBytes( struct.pack('B', num4) )
      
      if (useCompression):
        sendBytes(block)
      else: # uncompressed ? => copy input data
        index = lastBlock - dataZero
        sendBytes( data[index:index + numBytes] )

      # disable matching across blocks if True (was a legacy format code path)
      if (False):
        dataZero += len(data)
        data = bytearray()

        # clear hash tables
        for i in range(len(previousHash)):
          previousHash[i] = self.NoPrevious
          previousExact[i] = self.NoPrevious

        for i in range(len(lastHash)):
          lastHash[i] = self.NoLastHash
    
      else:
      
        # remove already processed data except for the last 64kb which could be used for intra-block matches
        if (len(data) > self.MaxDistance):
          remove = len(data) - self.MaxDistance
          dataZero += remove
          data = data[remove:]

    return outputData
    
  #-------------------------------------------------------------------------------------------------
  # Emit an LZ4 compatible frame header to the outputBuffer bytearray  
  #-------------------------------------------------------------------------------------------------
  def beginFrame(self, outputBuffer):

    # ==================== write LZ4 header ====================
    # magic bytes
    outputBuffer.extend( bytearray([0x04, 0x22, 0x4D, 0x18]) )
      
    # flags
    # (7-6) FieldName	Version (5)	B.Indep (4)	B.Checksum (3)	C.Size (2)	C.Checksum (1) Reserved (0)	DictID
    flags = 1 << 6 # Version, dependent blocks, no block checksum, no size, no content checksum, no dict ID 
    outputBuffer.append( struct.pack('B', flags) )

    # max blocksize
    maxBlockSizeId = self.MaxBlockSizeId << 4
    outputBuffer.append( struct.pack('B', maxBlockSizeId) )
    
    # header checksum (precomputed)
    checksum = 0xDF
    outputBuffer.append( struct.pack('B', checksum) )

    # reset stats for each frame
    # (can be manually called per-block also if desired)
    self.resetStats()


  
  #-------------------------------------------------------------------------------------------------
  # Emit an LZ4 compatible frame end signal (a block with size 0)
  #-------------------------------------------------------------------------------------------------
  def endFrame(self, outputBuffer):
    # add an empty block
    outputBuffer.extend(struct.pack('i', 0))    

  #-------------------------------------------------------------------------------------------------
  # setCompression
  # Set the encoder match parameter for compression ratio/speed tradeoff
  # compressionLevel can be 0 (uncompressed), or 1 (low compression, high encoding speed) to 9 (optimal compression, low encoding speed) 
  #-------------------------------------------------------------------------------------------------
  def setCompression(self, compressionLevel, windowSize = 65535):
    assert windowSize < 65536
    if (compressionLevel >= 9):
      newMaxChainLength = 65536  # "unlimited" because search window contains only 2^16 bytes 
    else:
      newMaxChainLength = compressionLevel

    # how many matches are checked in findLongestMatch, lower values yield faster encoding at the cost of worse compression ratio
    self.maxChainLength = newMaxChainLength
    # => no limit, but can be changed by setMaxChainLength

    # set the sliding window size, 65535 is the default since that is the maximum supported by the 16-bit offset format (ignoring 0, which is an invalid value)
    self.MaxDistance = windowSize

  #-------------------------------------------------------------------------------------------------
  # enable a byte optimized compression mode
  # LZ4 offsets will be output as 8-bits rather than 16-bits, and windowSize will be set to 255
  # For many data streams this will add a few % to the compression ratio
  # Note that this will create output that is no longer LZ4 format compatible and the decoder is assumed to be modified accordingly
  #-------------------------------------------------------------------------------------------------
  def optimizedCompression(self, enable = True):
    if enable:
      self.DistanceByteSize = 1
      if self.MaxDistance > 255:
        self.MaxDistance = 255
    else:
        self.DistanceByteSize = 2



  def getCompressionLevel(self):
    return self.maxChainLength

  def getWindowSize(self):
    return self.MaxDistance

  #--------------------------------------------------------------------------------------------------------------------------------
  # compress everything in input stream (accessed via getByte) and write to complete LZ4 output stream
  # improve compression with a predefined dictionary
  #--------------------------------------------------------------------------------------------------------------------------------
  # inputData, and dictionary are bytearray's
  # returns a bytearray containing the compressed LZ4 stream
  def compress(self, inputData, dictionary = bytearray()):
    outputBuffer = bytearray()
    self.beginFrame(outputBuffer)
    compressedBlock = self.compressBlock(inputData, dictionary)
    outputBuffer.extend(compressedBlock)
    self.endFrame(outputBuffer)
    return outputBuffer


#-------------------------
# main()
#-------------------------

def main(args):

  start_time = timer()  

  src = args.input
  dst = args.output
  if dst == None:
    dst = src + ".lz4"

  # enable verbose mode
  LZ4.Verbose = args.verbose

  # check for missing files
  if not os.path.isfile(src):
    print("ERROR: File '" + src + "' not found")
    sys.exit()

  # create the instance
  compressor = LZ4()

  # set the compression parameters
  compressor.setCompression(args.compress, args.window)

  # load the input file into memory
  fh = open(src, 'rb')
  file_in = bytearray(fh.read())
  fh.close()

  # compress into LZ4 file stream
  if LZ4.Verbose:
    print("Compressing file '" + src + "' to '" + dst + "', using compression level " + str(args.compress) )
  file_out = compressor.compress(file_in, bytearray())

  # write the LZ4 stream to output file
  fh = open(dst, 'wb')
  fh.write(file_out)
  fh.close()

  # stats
  src_size = os.path.getsize(src)
  dst_size = os.path.getsize(dst)
  if src_size == 0:
    ratio = 0
  else:
    ratio = 100 - (int)((dst_size*100 / src_size))

  print("Compressed " + str(src_size) + " bytes into " + str(dst_size) + " bytes => " + str(ratio) + "%" )

  end_time = timer()

  if LZ4.Verbose:
    t = '{:.2f}'.format(end_time-start_time)
    print("Completed in " + t + "s.")

#--------------------------------

# Determine if running as a script
if __name__ == '__main__':

  print("lz4enc.py : LZ4 compressor with optimal parsing, fully compatible with LZ4 by Yann Collet (see https://lz4.org)")
  print("Written in 2019 by Simon M, https://github.com/simondotm/")
  print("Based on smallz4 written in 2016-2018 by Stephan Brumme https://create.stephan-brumme.com/smallz4/")
  print("")

  epilog_string = "Compression levels:\n"
  epilog_string += " -0               No compression\n"
  epilog_string += " -1 ... -" + str(LZ4.ShortChainsGreedy) +"        Greedy search, check 1 to " + str(LZ4.ShortChainsGreedy) + " matches\n"
  epilog_string += " -" + str(LZ4.ShortChainsGreedy+1) + " ... -8        Lazy matching with optimal parsing, check " + str(LZ4.ShortChainsGreedy+1) + " to 8 matches\n"
  epilog_string += " -9               Optimal parsing, check all possible matches (default)\n"

  parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog=epilog_string)

  parser.add_argument("input", help="read from file [input]")
  parser.add_argument("-o", "--output", help="write to file [output] (default is '[input].lz4'")
  parser.add_argument("-D", "--dict", metavar="file", help="Load dictionary file")
  parser.add_argument("-c", "--compress", type=int, default=9, metavar="int", help="Set compression level (0-9), default: 9")
  parser.add_argument("-f", "--force", help="Overwrite an existing file", action="store_true")
  parser.add_argument("-p", "--profile", help="Profile the script", action="store_true")
  parser.add_argument("-w", "--window", type=int, default=LZ4.MaxDistance, help="Set LZ4 window size, default:"+str(LZ4.MaxDistance))
  parser.add_argument("-v", "--verbose", help="Enable verbose mode", action="store_true")
  args = parser.parse_args()

  if args.profile:
    profile.run('main(args)')
  else:
    main(args)

