	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SegaSonic_41_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SegaSonic_41_0
	PULS A,B,U
	STA 60,U
	STB 100,U

	PULS A,B
	STA -20,U
	STB 20,U

	PULS A,B
	STA -100,U
	STB -60,U

	PULS D,U
	STD 120,U

	PULS D
	STD 80,U

	PULS A,X,Y
	STA -120,U
	STX 40,U
	STY ,U

	PULS D,X
	STD -40,U
	STX -80,U

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

	PULS A,U
	STA 80,U

	PULS A,B
	STA 40,U
	STB ,U

	PULS A,B
	STA -80,U
	STB -40,U

	PULS D,X,U
	STD -41,U
	STX -1,U

	PULS A,X,Y
	STA 120,U
	STX -121,U
	STY -81,U

	PULS D,X
	STD 79,U
	STX 39,U

	PULS D,X,U
	STD 80,U
	STX -40,U

	PULS D,X,Y
	STD 120,U
	STX 40,U
	STY -80,U

	PULS D,X
	STD -120,U
	STX ,U

	PULS D,X,U
	STD 80,U
	STX 120,U

	PULS D,X,Y
	STD -40,U
	STX ,U
	STY 40,U

	PULS D,X
	STD -120,U
	STX -80,U

	PULS D,X,U
	STD 80,U
	STX 120,U

	PULS D,X,Y
	STD -40,U
	STX ,U
	STY 40,U

	PULS D,X
	STD -120,U
	STX -80,U

	PULS D,U
	STD 119,U

	PULS D,X
	STD -1,U
	STX -41,U

	PULS A,B,X,Y
	STA -120,U
	STB -80,U
	STX 39,U
	STY 79,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 40,U
	STB 80,U

	PULS A,B
	STA -40,U
	STB ,U

	PULS A,B
	STA -120,U
	STB -80,U

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

	PULS A,U
	STA ,U

	PULS A,U
	STA 40,U

	PULS A,B
	STA -40,U
	STB -120,U

	PULS A,B
	STA ,U
	STB 120,U

	PULS A,B
	STA -80,U
	STB 80,U

	PULS D,X,U
	STD 80,U
	STX 120,U

	PULS D,X,Y
	STD ,U
	STX -40,U
	STY -80,U

	PULS D,X
	STD 40,U
	STX -120,U

	PULS D,X,U
	STD 40,U
	STX 80,U

	PULS D,X,Y
	STD ,U
	STX 120,U
	STY -40,U

	PULS D,X
	STD -80,U
	STX -120,U

	PULS D,X,U
	STD 80,U
	STX 120,U

	PULS D,X,Y
	STD 40,U
	STX ,U
	STY -40,U

	PULS D,X
	STD -80,U
	STX -120,U

	PULS A,U
	STA -80,U

	PULS A,X,Y
	STA -120,U
	STX 120,U
	STY 80,U

	PULS D,X,Y
	STD 40,U
	STX ,U
	STY -40,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $00D0