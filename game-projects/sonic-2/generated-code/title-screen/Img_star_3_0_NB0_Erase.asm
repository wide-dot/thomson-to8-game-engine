	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_star_3_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_star_3_0
	PULS A,U
	STA 80,U

	PULS A,B
	STA 40,U
	STB -40,U

	PULS A,X
	STA -80,U
	STX ,U

	PULS A,U
	STA ,U

	PULS A,U
	STA 120,U

	PULS A,B
	STA 80,U
	STB 40,U

	PULS A,B
	STA -40,U
	STB ,U

	PULS A,X
	STA -80,U
	STX -121,U

	PULS A,B,U
	STA 80,U
	STB 120,U

	PULS A,B
	STA 40,U
	STB ,U

	PULS A,B
	STA -40,U
	STB -80,U

	PULS A
	STA -120,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $001E
