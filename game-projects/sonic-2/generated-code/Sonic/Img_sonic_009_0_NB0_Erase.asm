	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_009_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_009_0
	PULS D,X,U
	PSHU D,X

	PULS D
	STD 123,U

	PULS A,X,Y
	STA 83,U
	STX 40,U
	STY 80,U

	PULS D,X
	STD 120,U
	STX 42,U

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS A
	STA 4,U

	PULS D,X,U
	PSHU D,X

	PULS A
	STA 4,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 3,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X
	STA 42,U
	STX 40,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD -78,U
	STX -80,U
	STY -40,U

	PULS A,B,X
	STA -38,U
	STB -118,U
	STX -120,U

	PULS A,U
	STA 21,U

	PULS A,X,Y
	STA -19,U
	STX -21,U
	STY 19,U

	PULS D,U
	STD 118,U

	PULS D
	STD -81,U

	PULS A,B
	STA 81,U
	STB 41,U

	PULS A,B
	STA 1,U
	STB -39,U

	PULS A,B,X,Y
	STA -120,U
	STB -79,U
	STX 120,U
	STY -41,U

	PULS D,X,Y
	STD -1,U
	STX 39,U
	STY 79,U

	PULS A,B,X,U
	PSHU B,X
	STA 42,U

	PULS D
	STD 40,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 40,U

	PULS A,X,Y
	STA 42,U
	STX 78,U
	STY 38,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 38,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 38,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 38,U

	PULS D,X,U
	PSHU D,X

	PULS D
	STD 39,U

	PULS D,X,U
	PSHU D,X

	PULS D,X,Y
	STD 42,U
	STX 82,U
	STY 80,U

	PULS D
	STD 40,U

	PULS D,X,U
	PSHU D,X

	PULS A,X,U
	PSHU A,X

	PULS D
	STD -38,U

	PULS A,B,X,Y
	STA -78,U
	STB 3,U
	STX -40,U
	STY -80,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD 121,U
	STX 41,U
	STY 81,U

	PULS A,B,X,U
	PSHU B,X
	STA -38,U

	PULS D,X,Y
	STD -40,U
	STX -79,U
	STY -119,U

	PULS A,U
	STA ,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00D2