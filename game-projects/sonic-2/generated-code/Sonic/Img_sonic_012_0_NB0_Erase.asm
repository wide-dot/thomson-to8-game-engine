	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_012_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_012_0
	PULS D,U
	STD 118,U

	PULS D,X
	STD 78,U
	STX 38,U

	PULS A,B
	STA 120,U
	STB 40,U

	PULS A,B,X
	STA -41,U
	STB -81,U
	STX -1,U

	PULS A,B
	STA 80,U
	STB -121,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 80,U
	STB 1,U

	PULS A,X,Y
	STA -39,U
	STX 39,U
	STY -1,U

	PULS D,X,Y
	STD -81,U
	STX -41,U
	STY -121,U

	PULS D,U
	STD 120,U

	PULS D,X,Y
	STD 80,U
	STX -40,U
	STY ,U

	PULS D,X,Y
	STD -80,U
	STX -120,U
	STY 40,U

	PULS D,U
	STD 119,U

	PULS D,X,Y
	STD 80,U
	STX 40,U
	STY ,U

	PULS D,X,Y
	STD -40,U
	STX 78,U
	STY 38,U

	PULS D,X
	STD -2,U
	STX -42,U

	PULS A,B
	STA 121,U
	STB -79,U

	PULS A,X,Y
	STA -119,U
	STX -121,U
	STY -81,U

	PULS A,U
	STA 120,U

	PULS A,B,X,Y
	STA -81,U
	STB -121,U
	STX 78,U
	STY 118,U

	PULS D,X,Y
	STD -2,U
	STX 38,U
	STY -42,U

	PULS A,U
	STA 21,U

	PULS A,X,Y
	STA -19,U
	STX -21,U
	STY 19,U

	PULS D,U
	STD -40,U

	PULS D,X,Y
	STD -80,U
	STX -120,U
	STY 120,U

	PULS D,X,Y
	STD 80,U
	STX ,U
	STY 40,U

	PULS D,X,Y,U
	STD -41,U
	STX 39,U
	STY -1,U

	PULS D,X
	STD -81,U
	STX -121,U

	PULS A,X
	STA 120,U
	STX 79,U

	PULS D,U
	STD 79,U

	PULS D,X,Y
	STD 39,U
	STX -1,U
	STY -41,U

	PULS D,X
	STD -81,U
	STX -121,U

	PULS A,B,X
	STA 81,U
	STB -79,U
	STX 120,U

	PULS A,B
	STA 41,U
	STB -119,U

	PULS A,B
	STA 1,U
	STB -39,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD 121,U
	STX 41,U
	STY 81,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS D
	STD -119,U

	PULS A,B,X,Y
	STA -38,U
	STB -78,U
	STX -40,U
	STY -80,U

	PULS A,B,U
	STA 20,U
	STB -20,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00C2