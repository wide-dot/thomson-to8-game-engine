	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_069_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_069_0
	PULS A,U
	STA ,U

	PULS A,B,X,U
	PSHU B,X
	STA 121,U

	PULS D,X
	STD 80,U
	STX 40,U

	PULS A,B
	STA 42,U
	STB 82,U

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

	PULS A,X,U
	PSHU A,X

	PULS A
	STA 3,U

	PULS A,X,U
	PSHU A,X

	PULS A
	STA 3,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,Y
	STA 3,U
	STX -38,U
	STY -40,U

	PULS A,X,U
	PSHU A,X

	PULS D,X,Y
	STD 121,U
	STX 41,U
	STY 81,U

	PULS D,X,Y
	STD 119,U
	STX 79,U
	STY 39,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,B,X,U
	PSHU B,X
	STA -119,U

	PULS D
	STD -40,U

	PULS A,B,X
	STA -38,U
	STB -78,U
	STX -80,U

	PULS A,U
	STA ,U

	PULS D,U
	STD 60,U

	PULS D,X,Y
	STD 20,U
	STX -60,U
	STY -20,U

	PULS A,X,U
	PSHU A,X

	PULS D
	STD 120,U

	PULS A,B,X,Y
	STA 82,U
	STB 42,U
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

	PULS A,X,U
	PSHU A,X

	PULS A,B,X,U
	PSHU B,X
	STA -78,U

	PULS A,X,Y
	STA -38,U
	STX -119,U
	STY -40,U

	PULS D
	STD -80,U

	PULS D,U
	STD 60,U

	PULS D,X,Y
	STD -20,U
	STX 20,U
	STY -60,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00D7