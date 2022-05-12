	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSShadow_025_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSShadow_025_0
	PULS A,U
	STA 80,U

	PULS A,B
	STA 40,U
	STB ,U

	PULS A,B
	STA -40,U
	STB -80,U

	PULS A,U
	STA 20,U

	PULS A
	STA -20,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $000B
