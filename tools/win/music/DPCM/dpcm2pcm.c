#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>	// for strtoul
#include <ctype.h>	// for isspace
#include <stddef.h>	// for NULL
#include <malloc.h>
#include <string.h>

#ifndef _MSC_VER
#define _stricmp	strcasecomp
#endif

char DeltaArray[16] = {
	0, 1, 2, 4, 8, 0x10, 0x20, 0x40,
	-0x80, -1, -2, -4, -8, -0x10, -0x20, -0x40
};

static void ParseDPCMArray(const char* String);
static void PrintHelp(void);

int main (int argc, char* argv[]) {

	int argbase;
	char* fn_out;
	FILE* input;
	FILE* output;
	int read_val;
	unsigned char dpcm_start;
	unsigned char data,val;

	// Write about info...
	printf("DPCM 2 PCM converter v.1.1\n");
	printf("2013, Vladikcomper, Valley Bell\n\n");

	dpcm_start = 0x80;

	argbase = 1;
	while(argbase < argc)
	{
		if (! _stricmp(argv[argbase], "-help"))
		{
			PrintHelp();
			return 0;
		}
		else if (! _stricmp(argv[argbase], "-dpcmdata"))
		{
			argbase ++;
			if (argbase >= argc)
			{
				printf("Argument incomplete!\n");
				return -3;
			}
			ParseDPCMArray(argv[argbase]);
		}
		else if (! _stricmp(argv[argbase], "-dpcmstart"))
		{
			argbase ++;
			if (argbase >= argc)
			{
				printf("Argument incomplete!\n");
				return -3;
			}
			dpcm_start = (unsigned char)strtoul(argv[argbase], NULL, 0);
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

	// Start on it!
	if (argbase + 1 <= argc)
	{
		// fn_out = argv[1] + ".snd"
		fn_out = (char*)malloc(strlen(argv[argbase]) + 5);
		strcpy(fn_out, argv[argbase]);	strcat(fn_out, ".snd");
	}
	else
	{
		// fn_out = argv[2]
		fn_out = (char*)malloc(strlen(argv[argbase + 1]));
		strcpy(fn_out, argv[argbase + 1]);
	}
	input = fopen(argv[argbase], "rb");
	output = fopen(fn_out, "wb");
	free(fn_out);	fn_out = NULL;

	if (input == NULL || output == NULL) {
		if (input != NULL)
			fclose(input);
		if (output != NULL)
			fclose(output);
		printf("ERROR: Error on accessing input/output file.");
		getchar();
		return -1;
	}

	// Conversion
	//val=0x80;
	val = dpcm_start;
	
	for (;;) {

		read_val = fgetc(input);
		if (read_val == EOF) break;	// if the file was all read
		data = (unsigned char)read_val;
		
		val+=DeltaArray[(data>>4)&0xF];
		fputc(val, output);
		val+=DeltaArray[data&0xF];
		fputc(val, output);

	}
	fclose(input);
	fclose(output);

	// All Done
	printf("Conversion sucessfully finised!\n");

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
	printf("Usage: dpcm2pcm [-dpcmdata \"0 1 2 ... -0x40\" [-dpcmstart 0x80] in_file [out_file]\n");
	printf("Numbers can be given in C-style (dec/oct/hex) or hexadecimal with $\n");
	printf("dpcmdata can also be given as 16 unseparated hex numbers.\n");
	return;
}
