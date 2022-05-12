	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSShadow_021_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSShadow_021_0
	PULS A,U
	STA 40,U

	PULS A,B
	STA -40,U
	STB ,U

	PULS A,U
	STA 40,U

	PULS A,X
	STA -40,U
	STX -1,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $000B
