	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSShadow_020_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSShadow_020_0
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
	STA 60,U

	PULS A,B
	STA 20,U
	STB -20,U

	PULS A
	STA -60,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0012
