	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSRing_007_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSRing_007_0
	PULS A,B,U
	STA 39,U
	STB 79,U

	PULS D
	STD -1,U

	PULS A,X
	STA -80,U
	STX -41,U

	PULS A,U
	STA 80,U

	PULS A,B
	STA 40,U
	STB ,U

	PULS A,B
	STA -40,U
	STB -80,U

	PULS A,B
	STA 120,U
	STB -120,U

	PULS A,B,U
	STA 80,U
	STB 120,U

	PULS D
	STD -1,U

	PULS A,B,X,Y
	STA -121,U
	STB 40,U
	STX -41,U
	STY -81,U

	PULS D,U
	STD 39,U

	PULS D,X
	STD -1,U
	STX -41,U

	PULS A,B
	STA -81,U
	STB 80,U

	PULS A,U
	STA 80,U

	PULS A,B
	STA 40,U
	STB ,U

	PULS A,B
	STA -40,U
	STB -80,U

	PULS A,B
	STA 120,U
	STB -120,U

	PULS A,B,U
	STA 39,U
	STB 119,U

	PULS D
	STD -1,U

	PULS A,B,X,Y
	STA -120,U
	STB 79,U
	STX -41,U
	STY -81,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $003D