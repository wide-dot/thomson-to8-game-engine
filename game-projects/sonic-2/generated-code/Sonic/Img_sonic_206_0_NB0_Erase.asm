	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_206_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_206_0
	PULS A,B,U
	STA -20,U
	STB 20,U

	PULS A,U
	STA -38,U

	PULS A,B
	STA -40,U
	STB -78,U

	PULS A,B
	STA 80,U
	STB -80,U

	PULS A,B
	STA -120,U
	STB ,U

	PULS A,B
	STA 120,U
	STB 40,U

	PULS A
	STA -118,U

	PULS A,U
	STA -42,U

	PULS A,X,Y
	STA -120,U
	STX -122,U
	STY 80,U

	PULS D,X,Y
	STD 40,U
	STX -40,U
	STY 119,U

	PULS A,X,Y
	STA 121,U
	STX ,U
	STY -82,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,Y
	STA 121,U
	STX 79,U
	STY 41,U

	PULS D,X,Y
	STD 119,U
	STX 81,U
	STY 39,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,B,X,U
	PSHU B,X
	STA 42,U

	PULS D,X,Y
	STD 81,U
	STX 121,U
	STY 40,U

	PULS A,X,U
	PSHU A,X

	PULS A
	STA 3,U

	PULS A,B,X,U
	PSHU B,X
	STA -38,U

	PULS D,X,Y
	STD -40,U
	STX -119,U
	STY -79,U

	PULS A,U
	STA -40,U

	PULS D
	STD 40,U

	PULS A,B,X
	STA -80,U
	STB ,U
	STX 80,U

	PULS A,U
	STA ,U

	PULS A,B,U
	STA 40,U
	STB -78,U

	PULS A,B,X,Y
	STA -80,U
	STB ,U
	STX 120,U
	STY 80,U

	PULS A,B
	STA -120,U
	STB -118,U

	PULS A,B
	STA -40,U
	STB -38,U

	PULS A,B,U
	STA 81,U
	STB 121,U

	PULS D,X
	STD 79,U
	STX -40,U

	PULS A,B
	STA -80,U
	STB 119,U

	PULS A,B
	STA 42,U
	STB -78,U

	PULS A,X,Y
	STA 2,U
	STX 40,U
	STY ,U

	PULS A,B,X
	STA -118,U
	STB -38,U
	STX -121,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,Y
	STA 42,U
	STX 120,U
	STY 80,U

	PULS D
	STD 40,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A
	STA 3,U

	PULS A,X,U
	PSHU A,X

	PULS A,B,X,Y
	STA 82,U
	STB 42,U
	STX 121,U
	STY 119,U

	PULS D,X
	STD 40,U
	STX 80,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,U
	PSHU D,X

	PULS A,B,X,Y
	STA -77,U
	STB -117,U
	STX -38,U
	STY -40,U

	PULS D,X
	STD -119,U
	STX -79,U

	PULS A,B,U
	STA 41,U
	STB 1,U

	PULS D
	STD -40,U

	PULS A,B,X,Y
	STA 81,U
	STB -120,U
	STX 120,U
	STY -80,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00D6