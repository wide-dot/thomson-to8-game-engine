#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>	// for isspace
#include <stddef.h>	// for NULL
//#include <malloc.h>
#include <string.h>

char DeltaArray[16] = {
	0, 1, 2, 4, 8, 0x10, 0x20, 0x40,
	-0x80, -1, -2, -4, -8, -0x10, -0x20, -0x40
};

static void ParseDPCMArray(const char* String);
static void PrintHelp(void);
static unsigned char ReadWAVHeader(FILE* infile, size_t* RetDataBytes);

int main (int argc, char* argv[]) {

	int argbase;
	unsigned char aos_mode;	// "Anti-overflow system" mode
	char* fn_in;
	char* fn_out;
	char* ext_pos;
	FILE* input;
	FILE* output;
	size_t RemBytes;
	unsigned char retval;
	int delta,read_val;
	unsigned char dpcm_start;
	unsigned char next,prev;
	unsigned int outval,bits;
	unsigned char newsmpl;

	// Write about info...
	printf("PCM 2 DPCM converter v.1.1\n");
	printf("2013, Vladikcomper, Valley Bell\n\n");

	dpcm_start = 0x80;

	argbase = 1;
	while(argbase < argc)
	{
		if (! strcasecmp(argv[argbase], "-help"))
		{
			PrintHelp();
			return 0;
		}
		else if (! strcasecmp(argv[argbase], "-dpcmdata"))
		{
			argbase ++;
			if (argbase >= argc)
			{
				printf("Argument incomplete!\n");
				return -3;
			}
			ParseDPCMArray(argv[argbase]);
		}
		else if (! strcasecmp(argv[argbase], "-dpcmstart"))
		{
			argbase ++;
			if (argbase >= argc)
			{
				printf("Argument incomplete!\n");
				return -3;
			}
			dpcm_start = (unsigned char)strtoul(argv[argbase], NULL, 0);
		}
		else if (! strcasecmp(argv[argbase], "-aos"))
		{
			argbase ++;
			if (argbase >= argc)
			{
				printf("Argument incomplete!\n");
				return -3;
			}
			aos_mode = (unsigned char)strtoul(argv[argbase], NULL, 0);
			if (aos_mode > 2)
				aos_mode = 0;
		}
		else
		{
			break;
		}
		argbase ++;
	}

	// Check if we have enough args to start on it...
	if (argc<argbase+1) {
		printf("ERROR: No file to convert. Please drag & drop any file on the executable to start conversion.");
		getchar();
		return -2;
	}

	fn_in = argv[argbase];
	if (argbase + 1 < argc)
	{
		// use second argument as destination file name
		fn_out = (char*)malloc(strlen(argv[argbase + 1]) + 1);	// +1 - \0 terminator
		strcpy(fn_out, argv[argbase + 1]);
	}
	else
	{
		// construct an output file name from the source file name
		fn_out = (char*)malloc(strlen(argv[argbase]) + 5);	// +4 - optional ".bin", +1 - \0 terminator
		strcpy(fn_out, argv[argbase]);

		// Adds .bin extention to output filename, or replaces the existing
		ext_pos = strrchr(fn_out, '.');
		if (ext_pos != NULL)
			strcpy(ext_pos, ".bin");
		else
			strcat(fn_out, ".bin");
	}

	// Start on it!
	input = fopen(fn_in, "rb");
	output = fopen(fn_out, "wb");
	free(fn_out);	fn_out = NULL;

	if (input == NULL || output == NULL) {
		if (input != NULL)
			fclose(input);
		if (output != NULL)
			fclose(output);
		printf("ERROR: Unable to load input or create output file");
		getchar();
		return -1;
	}

	// Verifies if we're opening WAV file, rather than raw sound stream.
	// And it that's the case, it skips the header and returns the number of bytes to process.
	retval = ReadWAVHeader(input, &RemBytes);
	if (retval == 0xFF)	// if not a .wav file
	{
		fseek(input, 0, SEEK_END);
		RemBytes = ftell(input);	// get file length
		fseek(input, 0, SEEK_SET);
		// and continue reading it as a binary file
	}
	else if (retval)
	{
		// some other error happened - exit the program
		switch(retval)
		{
		case 0xFE:
			printf("Unsupported WAV format.\n");
			break;
		case 0x80:
			printf("Not a PCM Mono Wave\n");
			break;
		case 0x81:
			printf("Not an 8-bit Wave\n");
			break;
		case 0x40:
			printf("Wave data block not found!\n");
			break;
		default:
			printf("Unknown error in .wav file!\n");
			break;
		}
		fclose(input);
		fclose(output);
		return -4;	// .wav file format error
	}

	// Compression routine

	//prev=128;
	prev = dpcm_start;
	outval=0;
	bits=0;

	while(RemBytes --) {
		int mindelta, thisdelta, minpos, i;

		read_val = fgetc(input);
		if (read_val == EOF) break;	// if the file was all read
		next = (unsigned char)read_val;

		delta=(unsigned int)next-(unsigned int)prev;

		// Find the most suitable delta in the table
		mindelta=256;
		minpos=0;

		for (i=0; i<16; i++) {
		//for (int i=15; i>=0; i--) {
			thisdelta = delta-DeltaArray[i];
			if (thisdelta<0) thisdelta=-thisdelta;
			thisdelta &= 0xFF;	// catch a delta of 0x100

			if (thisdelta<mindelta) {
				mindelta=thisdelta;
				minpos=i;
				if (mindelta == 0)
					break;	// it can't get better than 100% exact
			}
		}

		switch(aos_mode)
		{
		case 0:	// no overflow protection
			break;
		case 1:	// vladikcomper's Anti-overflow system (tm)
			while ( (DeltaArray[minpos]>0 && (unsigned char)(prev+((char)DeltaArray[minpos]))<prev)  ||
					(DeltaArray[minpos]<0 && (unsigned char)(prev+((char)DeltaArray[minpos]))>prev) )
					minpos-=2;
			break;
		case 2:
			if (mindelta == 0)
				break;

			newsmpl = prev + DeltaArray[minpos];
			if ((next >= 0xC0 && newsmpl <= 0x40) ||
				(next <= 0x40 && newsmpl >= 0xC0))
			{
#ifdef _DEBUG
				printf("Overflow: got %02X, should be %02X", newsmpl, next);
#endif

				mindelta=256;
				minpos=0;
				for (i=0; i<16; i++)
				{
					newsmpl = prev + DeltaArray[i];
					thisdelta = delta-DeltaArray[i];
					if (thisdelta<0) thisdelta=-thisdelta;
					thisdelta &= 0xFF;

					// only refresh the delta, if the sign of "actual" sample and DPCM sample is the same
					if (((next ^ newsmpl) & 0x80) == 0x00 && thisdelta < mindelta)
					{
						mindelta=thisdelta;
						minpos=i;
					}
				}
				newsmpl = prev + DeltaArray[minpos];
#ifdef _DEBUG
				printf("-> %02X\n", newsmpl);
#endif
			}
			break;
		}

		// Get data stream value and send it to the output stream
		outval<<=4;
		outval|=minpos;
		bits+=4;

		// If byte is ready, send it
		if (bits>=8) {
			fputc((unsigned char)outval, output);
			bits=0;
		}

		prev+=(char)DeltaArray[minpos];

	}
	fclose(input);
	fclose(output);

	// All Done
	printf("Conversion sucessfully finised!\n");
#ifdef _DEBUG
	getchar();
#endif

	return 0;
}

static void ParseDPCMArray(const char* String)
{
	const char* NextNum;
	unsigned char DpcmPos;
	char* EndPtr;
	unsigned char HexStream;
	signed char DpcmVal;
	signed char Sign;

	HexStream = 1;
	for (DpcmPos = 0x00, NextNum = String; DpcmPos < 0x20; DpcmPos ++, NextNum ++)
	{
		if (! isxdigit(*NextNum))
		{
			HexStream = 0;
			break;
		}
	}

	if (HexStream)
	{
		char TempNum[3];

		TempNum[2] = '\0';
		NextNum = String;
		for (DpcmPos = 0x00; DpcmPos < 0x10; DpcmPos ++)
		{
			TempNum[0] = *NextNum;	NextNum ++;
			TempNum[1] = *NextNum;	NextNum ++;
			DpcmVal = (signed char)strtol(TempNum, NULL, 0x10);
			DeltaArray[DpcmPos] = DpcmVal;
		}
	}
	else
	{
		NextNum = String;
		for (DpcmPos = 0x00; DpcmPos < 0x10; DpcmPos ++)
		{
			while(isspace(*NextNum))
				NextNum ++;

			DpcmVal = (signed char)strtol(NextNum, &EndPtr, 0);
			if (EndPtr == NextNum)
			{
				Sign = +1;
				if (*NextNum == '+' || *NextNum == '-')
				{
					Sign = (*NextNum == '-') ? -1 : +1;
					NextNum ++;
				}
				if (*NextNum == '$')
				{
					NextNum ++;
					DpcmVal = (signed char)strtol(NextNum, &EndPtr, 0x10) * Sign;
				}
				else
				{
					return;
				}
			}
			NextNum = EndPtr;

			DeltaArray[DpcmPos] = DpcmVal;
		}
	}

	return;
}

static void PrintHelp(void)
{
	printf("Usage: pcm2dpcm [-dpcmdata \"0 1 2 ... -0x40\" [-dpcmstart 0x80] [-aos 1] in_file [out_file]\n");
	printf("Numbers can be given in C-style (dec/oct/hex) or hexadecimal with $\n");
	printf("dpcmdata can also be given as 16 unseparated hex numbers.\n");
	printf("in_file can be a .wav file or contain raw sound data. Format must be PCM mono, 8-bit.\n");
	printf("aos: Anti-overflow system mode - 0 - off, 1 - vladikcomper, 2 - Valley Bell\n");

	return;
}

static unsigned char ReadWAVHeader(FILE* infile, size_t* RetDataBytes)
{
	unsigned int BlkFCC;
	size_t BlkBase;
	unsigned int BlkSize;
	unsigned int TempLng;

	fread(&BlkFCC, 0x04, 0x01, infile);
	if (BlkFCC != 0x46464952)	// 52494646 = 'RIFF'
		return 0xFF;	// Not a WAVE file (no RIFF header)
	fread(&TempLng, 0x04, 0x01, infile);	// read RIFF size (ignored)

	fread(&BlkFCC, 0x04, 0x01, infile);
	if (BlkFCC != 0x45564157)	// 57415645 = 'WAVE'
		return 0xFE;	// Not a WAVE file (bad signature)

	fread(&BlkFCC, 0x04, 0x01, infile);
	if (BlkFCC != 0x20746D66)	// 666D7420 = 'fmt '
		return 0xFE;	// Actually this IS a WAVE file, but we need the fmt chunk to be present at 0x0C.
	fread(&BlkSize, 0x04, 0x01, infile);	// read format chunk size
	BlkBase = ftell(infile);				// save current file offset for later

	fread(&TempLng, 0x04, 0x01, infile);	// read Format (must be 0001 = PCM) + Channels (1)
	if (TempLng != 0x00010001)
		return 0x80;	// Not a PCM Mono Wave
	fread(&TempLng, 0x04, 0x01, infile);	// read sample rate
	fread(&TempLng, 0x04, 0x01, infile);	// read bytes per sample
	fread(&TempLng, 0x04, 0x01, infile);
	if (TempLng != 0x00080001)
		return 0x81;	// Not an 8-bit Wave

	fseek(infile, BlkBase + BlkSize, SEEK_SET);	// skip the rest of the fmt chunk

	// Now search for the data block. ([fmt, data] is as common as [fmt, fact, data])
	while(1)
	{
		TempLng = fread(&BlkFCC, 0x04, 0x01, infile);	// read Four-Char-Code
		if (! TempLng)
			return 0x40;	// data block not found

		fread(&BlkSize, 0x04, 0x01, infile);	// read format chunk size
		if (BlkFCC == 0x61746164)	// 64617461 = 'data'
			break;
		fseek(infile, BlkSize, SEEK_CUR);
	}

	*RetDataBytes = (size_t)BlkSize;

	return 0x00;
}
