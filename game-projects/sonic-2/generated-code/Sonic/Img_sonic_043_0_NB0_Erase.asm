	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_043_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_043_0
	PULS A,U
	STA 40,U

	PULS A,B
	STA -40,U
	STB ,U

	PULS D,U
	STD 120,U

	PULS D,X,Y
	STD -120,U
	STX ,U
	STY 80,U

	PULS D
	STD 40,U

	PULS A,X,Y
	STA -118,U
	STX -80,U
	STY -40,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD 122,U
	STX 82,U
	STY -38,U

	PULS D,X,Y
	STD -118,U
	STX 120,U
	STY 80,U

	PULS D,X,Y
	STD 40,U
	STX -40,U
	STY -80,U

	PULS D
	STD -120,U

	PULS A,X
	STA 42,U
	STX -78,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD -118,U
	STX -40,U
	STY -80,U

	PULS D
	STD -78,U

	PULS A,B
	STA 122,U
	STB 82,U

	PULS A,B,X,Y
	STA -38,U
	STB 42,U
	STX 40,U
	STY -120,U

	PULS D,X
	STD 120,U
	STX 80,U

	PULS A,U
	STA 1,U

	PULS D
	STD -1,U

	PULS A,U
	STA -80,U

	PULS A,X,Y
	STA -120,U
	STX 118,U
	STY 78,U

	PULS A,B,X
	STA 80,U
	STB -40,U
	STX 39,U

	PULS A,B
	STA ,U
	STB 120,U

	PULS A,U
	STA 20,U

	PULS A
	STA -20,U

	PULS A,X,Y,U
	STA 1,U
	STX -121,U
	STY -81,U

	PULS A,B
	STA 120,U
	STB 80,U

	PULS A,B
	STA 40,U
	STB -39,U

	PULS A,B,X
	STA -41,U
	STB -79,U
	STX -1,U

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

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A
	STA 3,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS D
	STD -78,U

	PULS A,X,Y
	STA -38,U
	STX -40,U
	STY -80,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD -79,U

	PULS A,B
	STA 82,U
	STB 42,U

	PULS A,X,Y
	STA -38,U
	STX 119,U
	STY -40,U

	PULS A,B,X,Y
	STA 121,U
	STB -119,U
	STX 80,U
	STY 40,U

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

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00CF