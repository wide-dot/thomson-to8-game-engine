	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SegaSonic_43_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SegaSonic_43_0
	PULS A,U
	STA 60,U

	PULS A,B
	STA 20,U
	STB -20,U

	PULS A
	STA -60,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 80,U
	STB 40,U

	PULS A,B
	STA -40,U
	STB ,U

	PULS A,B
	STA -120,U
	STB -80,U

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

	PULS A,B,U
	STA 79,U
	STB 119,U

	PULS D,X
	STD -41,U
	STX -81,U

	PULS A,X,Y
	STA -120,U
	STX -1,U
	STY 39,U

	PULS A,B,U
	STA 80,U
	STB 120,U

	PULS A,B
	STA ,U
	STB -40,U

	PULS A,B
	STA -80,U
	STB 40,U

	PULS A
	STA -120,U

	PULS A,U
	STA ,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 80,U
	STB 40,U

	PULS A,B
	STA ,U
	STB -40,U

	PULS A,B
	STA -80,U
	STB -120,U

	PULS A,U
	STA -40,U

	PULS D,X,Y
	STD 119,U
	STX 79,U
	STY 39,U

	PULS D
	STD -1,U

	PULS A,B
	STA -120,U
	STB -80,U

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

DataSize equ $0050