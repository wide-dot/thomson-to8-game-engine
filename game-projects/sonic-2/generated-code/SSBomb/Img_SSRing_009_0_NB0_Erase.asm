	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSRing_009_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSRing_009_0
	PULS A,X,U
	STA 40,U
	STX -40,U

	PULS D
	STD ,U

	PULS A,B,U
	STA -1,U
	STB 41,U

	PULS A,B
	STA 79,U
	STB 39,U

	PULS A,B
	STA 1,U
	STB -39,U

	PULS A,B
	STA -79,U
	STB 121,U

	PULS A,B
	STA -119,U
	STB -41,U

	PULS A,B
	STA 81,U
	STB -81,U

	PULS A,X
	STA -121,U
	STX 119,U

	PULS A,B,U
	STA 39,U
	STB -41,U

	PULS A,B
	STA 121,U
	STB 81,U

	PULS A,B
	STA 41,U
	STB 1,U

	PULS A,B
	STA -39,U
	STB -79,U

	PULS A,B
	STA -81,U
	STB -119,U

	PULS A,B
	STA -121,U
	STB -1,U

	PULS A,B
	STA 79,U
	STB 119,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 118,U
	STB 78,U

	PULS A,X,Y
	STA 38,U
	STX -41,U
	STY -81,U

	PULS A,B,X
	STA ,U
	STB -121,U
	STX -2,U

	PULS A,B
	STA 80,U
	STB 40,U

	PULS A,X,U
	STA 40,U
	STX -41,U

	PULS D
	STD -1,U

	PULS A,U
	STA 81,U

	PULS A,B
	STA 41,U
	STB 39,U

	PULS A,B
	STA 1,U
	STB -1,U

	PULS A,B
	STA -39,U
	STB -79,U

	PULS A,X,Y
	STA -119,U
	STX 119,U
	STY 79,U

	PULS A,U
	STA 121,U

	PULS A,B
	STA 81,U
	STB 41,U

	PULS A,B
	STA 1,U
	STB -39,U

	PULS A,B
	STA -79,U
	STB -119,U

	PULS A
	STA -121,U

	PULS D,U
	STD 38,U

	PULS D
	STD -82,U

	PULS A,B
	STA 120,U
	STB 118,U

	PULS A,B,X,Y
	STA 78,U
	STB -121,U
	STX -42,U
	STY -2,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0065