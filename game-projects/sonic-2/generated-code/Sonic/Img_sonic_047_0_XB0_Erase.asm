	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_047_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_047_0
	PULS A,B,U
	STA -19,U
	STB 21,U

	PULS D
	STD 19,U

	PULS A,B
	STA -21,U
	STB 60,U

	PULS A,B
	STA -61,U
	STB -59,U

	PULS A,U
	STA 40,U

	PULS A,B
	STA -82,U
	STB -2,U

	PULS A,B
	STA ,U
	STB -42,U

	PULS A,B
	STA 120,U
	STB -80,U

	PULS A,X
	STA 118,U
	STX -121,U

	PULS A,B
	STA 78,U
	STB 80,U

	PULS A,B
	STA -40,U
	STB 38,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 121,U

	PULS A,X,Y
	STA 42,U
	STX 81,U
	STY 40,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD -39,U
	STX -41,U
	STY -81,U

	PULS D
	STD -121,U

	PULS A,X,Y
	STA -79,U
	STX 120,U
	STY 80,U

	PULS A,B
	STA 122,U
	STB 82,U

	PULS A,B,X
	STA 42,U
	STB -119,U
	STX 40,U

	PULS A,B,U
	STA 41,U
	STB 81,U

	PULS D
	STD -39,U

	PULS A,B,X,Y
	STA -79,U
	STB 1,U
	STX 79,U
	STY 39,U

	PULS D,X,Y
	STD -1,U
	STX -41,U
	STY -81,U

	PULS A,U
	STA 80,U

	PULS A,X,Y
	STA 40,U
	STX 118,U
	STY 78,U

	PULS D,X,Y
	STD 38,U
	STX -2,U
	STY -121,U

	PULS A,B,X,Y
	STA 120,U
	STB ,U
	STX -41,U
	STY -81,U

	PULS A,B,X,U
	STA -19,U
	STB 21,U
	STX 60,U

	PULS A,X
	STA -58,U
	STX -60,U

	PULS A,U
	STA 121,U

	PULS D,X,Y
	STD -42,U
	STX -82,U
	STY -120,U

	PULS D
	STD -122,U

	PULS A,B,X
	STA -39,U
	STB 1,U
	STX -80,U

	PULS A,B,X,Y
	STA 41,U
	STB 81,U
	STX 118,U
	STY 78,U

	PULS D,X
	STD 38,U
	STX -2,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD 122,U
	STX 82,U
	STY 80,U

	PULS D
	STD 40,U

	PULS A,B
	STA 42,U
	STB 120,U

	PULS A,X,U
	PSHU A,X

	PULS A,B,X,Y
	STA 42,U
	STB 82,U
	STX 80,U
	STY 40,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 120,U

	PULS A,X,Y
	STA 42,U
	STX 40,U
	STY 80,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS D
	STD -40,U

	PULS A,X,Y
	STA -38,U
	STX -120,U
	STY -80,U

	PULS A,U
	STA 21,U

	PULS D,X,Y
	STD 19,U
	STX -20,U
	STY 59,U

	PULS D
	STD -60,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00E1