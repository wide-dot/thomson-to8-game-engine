	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSShadow_027_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSShadow_027_0
	PULS A,U
	STA 20,U

	PULS A
	STA -20,U

	PULS A,U
	STA 20,U

	PULS A
	STA -20,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0008
