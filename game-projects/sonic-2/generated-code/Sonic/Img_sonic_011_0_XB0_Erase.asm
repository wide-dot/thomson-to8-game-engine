	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_011_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_011_0
	PULS A,U
	STA 120,U

	PULS A,B
	STA 80,U
	STB 40,U

	PULS A,X,Y
	STA -121,U
	STX 118,U
	STY -2,U

	PULS A,B,X,Y
	STA -41,U
	STB -81,U
	STX 78,U
	STY 38,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 80,U
	STB 40,U

	PULS A,B,X,Y
	STA 1,U
	STB -39,U
	STX -1,U
	STY -41,U

	PULS D,X
	STD -80,U
	STX -120,U

	PULS D,U
	STD -121,U

	PULS D,X
	STD -40,U
	STX -80,U

	PULS A,B,X,Y
	STA -119,U
	STB -78,U
	STX ,U
	STY 80,U

	PULS D,X
	STD 40,U
	STX 120,U

	PULS A,X,U
	PSHU A,X

	PULS A,B
	STA 122,U
	STB 42,U

	PULS A,X,Y
	STA 82,U
	STX 120,U
	STY 80,U

	PULS D
	STD 40,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD -78,U

	PULS A,B,X,Y
	STA -118,U
	STB -38,U
	STX -40,U
	STY -80,U

	PULS D
	STD -120,U

	PULS A,U
	STA -100,U

	PULS D,X,Y
	STD 20,U
	STX 60,U
	STY 100,U

	PULS D,X
	STD -60,U
	STX -20,U

	PULS D,U
	STD 78,U

	PULS D,X
	STD 38,U
	STX -1,U

	PULS A,B,X,Y
	STA 80,U
	STB 40,U
	STX -81,U
	STY -41,U

	PULS D,U
	STD 40,U

	PULS D
	STD ,U

	PULS A,X,Y
	STA -40,U
	STX 80,U
	STY -80,U

	PULS D,X
	STD -120,U
	STX 120,U

	PULS A,U
	STA 42,U

	PULS A,X,Y
	STA 2,U
	STX ,U
	STY 40,U

	PULS D,X,Y
	STD 80,U
	STX 120,U
	STY -80,U

	PULS D,X
	STD -120,U
	STX -40,U

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

	PULS A,X,U
	PSHU A,X

	PULS A,X
	STA -38,U
	STX -40,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 120,U

	PULS A,X,Y
	STA 122,U
	STX 40,U
	STY 80,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,B,X,Y
	STA -38,U
	STB -78,U
	STX -40,U
	STY -80,U

	PULS D
	STD -120,U

	PULS A,U
	STA -20,U

	PULS D
	STD 20,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00CB