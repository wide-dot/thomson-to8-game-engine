	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_021_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_021_0
	PULS A,U
	STA 40,U

	PULS A,B
	STA ,U
	STB -40,U

	PULS A,U
	STA -120,U

	PULS A,B
	STA -40,U
	STB -80,U

	PULS A,B
	STA 40,U
	STB 120,U

	PULS A,B
	STA ,U
	STB 80,U

	PULS A,B,U
	STA 120,U
	STB 40,U

	PULS A,B,X
	STA -80,U
	STB 80,U
	STX -120,U

	PULS A,B
	STA -40,U
	STB ,U

	PULS D,U
	STD 121,U

	PULS D,X,Y
	STD 81,U
	STX 41,U
	STY 1,U

	PULS D,X
	STD -79,U
	STX -39,U

	PULS A,X
	STA -121,U
	STX -119,U

	PULS D,X,U
	PSHU D,X

	PULS A,B
	STA 124,U
	STB 84,U

	PULS A,B,X,Y
	STA 44,U
	STB 4,U
	STX 40,U
	STY 42,U

	PULS A,B,X,Y
	STA 80,U
	STB 120,U
	STX 122,U
	STY 82,U

	PULS D,X,U
	PSHU D,X

	PULS A
	STA 4,U

	PULS D,X,U
	PSHU D,X

	PULS A
	STA 4,U

	PULS D,X,U
	PSHU D,X

	PULS A
	STA 4,U

	PULS D,X,U
	PSHU D,X

	PULS D,X
	STD 42,U
	STX 40,U

	PULS D,X,U
	PSHU D,X

	PULS A
	STA 4,U

	PULS A,X,Y,U
	PSHU A,X,Y

	PULS A,X,Y,U
	PSHU A,X,Y

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 38,U

	PULS D,X,U
	PSHU D,X

	PULS A,B,X,Y
	STA -37,U
	STB -77,U
	STX -79,U
	STY -39,U

	PULS D,X
	STD 39,U
	STX -119,U

	PULS A,U
	STA 20,U

	PULS A,B,X
	STA -20,U
	STB -60,U
	STX 59,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 80,U
	STB 40,U

	PULS A,B
	STA -40,U
	STB ,U

	PULS A,B
	STA -120,U
	STB -80,U

	PULS A,B,U
	STA 80,U
	STB 120,U

	PULS A,B
	STA ,U
	STB 40,U

	PULS A,B
	STA -80,U
	STB -40,U

	PULS A
	STA -120,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 40,U
	STB -40,U

	PULS A,B
	STA ,U
	STB -120,U

	PULS A
	STA -80,U

	PULS A,X,U
	PSHU A,X

	PULS A,B,X,Y
	STA 42,U
	STB 122,U
	STX 81,U
	STY 40,U

	PULS A,X,U
	PSHU A,X

	PULS A
	STA 3,U

	PULS D,X,U
	PSHU D,X

	PULS D,X
	STD -38,U
	STX -40,U

	PULS D,X,U
	PSHU D,X

	PULS D
	STD 119,U

	PULS A,X,Y
	STA 43,U
	STX 39,U
	STY 41,U

	PULS D,X,Y
	STD 121,U
	STX 79,U
	STY 81,U

	PULS D,X,U
	PSHU D,X

	PULS A,X,U
	PSHU A,X

	PULS A
	STA 3,U

	PULS A,X,U
	PSHU A,X

	PULS A,B,X,Y
	STA 83,U
	STB 43,U
	STX 41,U
	STY 81,U

	PULS D,X
	STD 79,U
	STX 39,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD -39,U
	STX -119,U
	STY -79,U

	PULS A,U
	STA -20,U

	PULS D
	STD 20,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0107