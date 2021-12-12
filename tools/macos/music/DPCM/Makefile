CC = cc
CFLAGS = -std=c99 -pedantic -Wall
OBJECTS = pcm2dpcm.o

all: pcm2dpcm

pcm2dpcm.o: pcm2dpcm.c
    $(CC) $(CFLAGS) -c pcm2dpcm.c

pcm2dpcm: $(OBJECTS)
    $(CC) $(OBJECTS) -o pcm2dpcm

clean:
    rm -f *.o pcm2dpcm
