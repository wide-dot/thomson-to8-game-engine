	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_062_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_062_0
	PULS D,U
	STD 20,U

	PULS D
	STD -20,U

	PULS A,X,U
	PSHU A,X

	PULS A,B,X,Y
	STA 82,U
	STB 122,U
	STX 120,U
	STY 80,U

	PULS A,X
	STA 42,U
	STX 40,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X
	STA 42,U
	STX 40,U

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

	PULS A
	STA 3,U

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

	PULS A
	STA 3,U

	PULS A,X,U
	PSHU A,X

	PULS A,X,Y
	STA -38,U
	STX 80,U
	STY 40,U

	PULS D,X
	STD -40,U
	STX -79,U

	PULS A,B,X
	STA 42,U
	STB 82,U
	STX -119,U

	PULS A,U
	STA 19,U

	PULS A,X
	STA -60,U
	STX 60,U

	PULS A,B,U
	STA 60,U
	STB 20,U

	PULS D
	STD -60,U

	PULS D,X,U
	PSHU D,X

	PULS A,X,Y
	STA 122,U
	STX 82,U
	STY 42,U

	PULS D,X,Y
	STD 120,U
	STX 80,U
	STY 40,U

	PULS A,X,U
	PSHU A,X

	PULS A
	STA 3,U

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS A,B,X,U
	PSHU B,X
	STA -38,U

	PULS D
	STD -81,U

	PULS A,X,Y
	STA -118,U
	STX -79,U
	STY 41,U

	PULS D,X,Y
	STD 39,U
	STX -40,U
	STY -120,U

	PULS A,U
	STA 41,U

	PULS A,X
	STA -80,U
	STX 79,U

	PULS A,X,Y
	STA -40,U
	STX -1,U
	STY 39,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00E3