	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_065_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_065_0
	PULS A,X,U
	PSHU A,X

	PULS A,B,X,Y
	STA 121,U
	STB 42,U
	STX 81,U
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

	PULS A
	STA 3,U

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

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS A,X,U
	PSHU A,X

	PULS D
	STD -40,U

	PULS A,B,X
	STA -119,U
	STB -38,U
	STX -79,U

	PULS A,U
	STA -78,U

	PULS D,X,Y
	STD 80,U
	STX ,U
	STY 40,U

	PULS D,X
	STD -80,U
	STX -40,U

	PULS D,X,U
	PSHU D,X

	PULS D,X,Y
	STD 122,U
	STX 42,U
	STY 82,U

	PULS D,X,Y
	STD 120,U
	STX 80,U
	STY 40,U

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

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,U
	PSHU D,X

	PULS D,X,Y
	STD -78,U
	STX -118,U
	STY -38,U

	PULS D,X,Y
	STD -40,U
	STX -80,U
	STY -120,U

	PULS A,U
	STA 81,U

	PULS D,X,Y
	STD 39,U
	STX 79,U
	STY -41,U

	PULS D,X
	STD -1,U
	STX -81,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0112