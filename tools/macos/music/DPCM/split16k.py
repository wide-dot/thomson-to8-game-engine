import os
import binascii
import math

#------------------------------------------------------
#------------------------------------------------------
#------------------------------------------------------

# filename='audio_bin/pacman_beginning-8000.bin'
# filename='audio_bin/splashscreen-01-version-LOOP2.bin'
# filename='audio_bin/LOOP2B(RAW).BIN'
# filename='audio_bin/pac.bin'
filename='audio_bin/pdr.bin'

#------------------------------------------------------
#------------------------------------------------------
#------------------------------------------------------

file_stats = os.stat(filename)
file_size = file_stats.st_size
print("raw file size : ",file_size)
chunk_size = 16383
nbr_bin_files = int(math.ceil(file_size/chunk_size)) + 1
print(file_size,chunk_size,nbr_bin_files)
size_array = []
rest = file_size + chunk_size
for x in range(nbr_bin_files):
	rest = rest - chunk_size
	if (rest > chunk_size):
		size_array.append(chunk_size)
	else:
		size_array.append(rest)

print("bin files size : ",size_array)

#------------------------------------------------------
#------------------------------------------------------
#------------------------------------------------------

def outputBin(data,filename):
    f = open(filename,'w')
    f.write(data)

#------------------------------------------------------
#------------------------------------------------------
#------------------------------------------------------

#-------------------------
# add byte datas
#-------------------------
elements = []
bin_header_end = ['FF','00','00','00','00']
file = open(filename, "rb")
current_byte = 0
count = 0
start_byte = 0
end_byte = 0
for x in range(nbr_bin_files):
    print( "--------------------------------------------")
    #-- extract lenght of datas in Hex value for header
    #print (f"{16393:0>4X}")
    # sizeInHex = hex(size_array[count])
    sizeInHex =  hex( size_array[count] )[2:].zfill(4)
    sHex = list( sizeInHex )
    print(count, size_array[count], "size in Hex {}".format( sizeInHex ), sHex)
    oct1 = sHex[0] + sHex[1]
    oct2 = sHex[2] + sHex[3]
    bin_header_start = ['00',oct1,oct2,'A0','00']
    print( "bin_header_start", bin_header_start )
    #-- reset datas for nex bin file
    elements = []
    current_byte = current_byte
    #-- add Thomson BIN header start
    for value in bin_header_start:
        hexadecimal_string = value
        binary_string = binascii.unhexlify(hexadecimal_string)
        elements.append(binary_string)

    #-- add datas
    print( "BIN ZONE", current_byte, size_array[count] )
    with open(filename, "rb") as f:
        byte = f.read(file_size)
    print ("byte lenght ", len(byte) )
    start_byte = current_byte
    end_byte += size_array[count]
    for xx in range(start_byte, end_byte ):
        try:
            # print ( byte[current_byte] )
            elements.append( byte[current_byte] )
            current_byte+=1
        except:
            pass
            # print("byte not found")
        finally:
            pass
            # print("The 'try except' is finished")

    #-- add Thomson BIN header end
    for value in bin_header_end:
        hexadecimal_string = value
        binary_string = binascii.unhexlify(hexadecimal_string)
        elements.append(binary_string)

    #-- create bin file
    values = bytearray(elements)
    outputfile = "OUT"+str(count)+".BIN"
    outputBin(values,outputfile)
    count+=1
    print( "--------------------------------------------")

#------------------------------------------------------
#------------------------------------------------------
#------------------------------------------------------
