	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_038_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_038_0
	PULS A,U
	STA 40,U

	PULS A,B
	STA -40,U
	STB ,U

	PULS D,U
	STD -81,U

	PULS D
	STD -121,U

	PULS A,B,X,Y
	STA -79,U
	STB -119,U
	STX 40,U
	STY ,U

	PULS A,X,Y
	STA 120,U
	STX 80,U
	STY -40,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 82,U

	PULS A,X,Y
	STA 42,U
	STX 122,U
	STY 120,U

	PULS D,X
	STD 80,U
	STX 40,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS D
	STD -38,U

	PULS A,B,X,Y
	STA 42,U
	STB 3,U
	STX 40,U
	STY -40,U

	PULS D,X,Y
	STD 38,U
	STX -2,U
	STY -42,U

	PULS D,X,U
	PSHU D,X

	PULS A,B,X,Y
	STA 81,U
	STB 44,U
	STX 121,U
	STY 83,U

	PULS D,X,Y
	STD 119,U
	STX 79,U
	STY 42,U

	PULS D,X
	STD 40,U
	STX 123,U

	PULS D,X,U
	PSHU D,X

	PULS A,B,X,U
	PSHU B,X
	STA -79,U

	PULS A,X
	STA -119,U
	STX -40,U

	PULS A,U
	STA ,U

	PULS A,U
	STA 80,U

	PULS A,B
	STA 40,U
	STB ,U

	PULS A,B
	STA -80,U
	STB -40,U

	PULS A,B,U
	STA -80,U
	STB -40,U

	PULS D,X
	STD 120,U
	STX 80,U

	PULS A,X,Y
	STA -120,U
	STX 40,U
	STY ,U

	PULS A,U
	STA ,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 80,U
	STB 40,U

	PULS A,B
	STA -1,U
	STB -39,U

	PULS A,B,X,Y
	STA -41,U
	STB -79,U
	STX -81,U
	STY -121,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD 80,U
	STX 40,U
	STY 120,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,B,X
	STA 42,U
	STB 4,U
	STX 40,U

	PULS A,X,U
	PSHU A,X

	PULS A
	STA 4,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 3,U

	PULS A,X,Y,U
	PSHU A,X,Y

	PULS A,X,Y,U
	PSHU A,X,Y

	PULS A,X,Y,U
	PSHU A,X,Y

	PULS A,X,Y,U
	PSHU A,X,Y

	PULS A,B,X,Y
	STA -118,U
	STB -78,U
	STX -38,U
	STY -40,U

	PULS D,X
	STD -80,U
	STX -120,U

	PULS A,U
	STA 60,U

	PULS D,X,Y
	STD 58,U
	STX 19,U
	STY -21,U

	PULS D
	STD -61,U

	PULS A,U
	STA ,U

	PULS A,B
	STA -120,U
	STB 120,U

	PULS A,B
	STA -40,U
	STB 80,U

	PULS A,B
	STA 40,U
	STB -80,U

	PULS A,B,U
	STA -40,U
	STB 40,U

	PULS A,B,X
	STA 80,U
	STB -121,U
	STX -81,U

	PULS A,B
	STA ,U
	STB 120,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00FE