	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSShadow_019_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSShadow_019_0
	PULS A,B,U
	STA ,U
	STB 40,U

	PULS A,B
	STA 80,U
	STB -40,U

	PULS A
	STA -80,U

	PULS A,B,U
	STA ,U
	STB 40,U

	PULS A,B
	STA 120,U
	STB 80,U

	PULS A,B
	STA -80,U
	STB -40,U

	PULS A
	STA -120,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0010
