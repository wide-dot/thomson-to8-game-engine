	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSShadow_015_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSShadow_015_0
	PULS D,U
	STD 40,U

	PULS D
	STD -40,U

	PULS A,B,X
	STA -80,U
	STB 80,U
	STX ,U

	PULS D,U
	STD 40,U

	PULS D,X,Y
	STD -40,U
	STX ,U
	STY 80,U

	PULS D
	STD -80,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0016
