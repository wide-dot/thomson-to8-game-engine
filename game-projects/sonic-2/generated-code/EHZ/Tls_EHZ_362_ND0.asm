	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_362

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$33dd
	STD 119,U
	LDD #$3434
	STD 39,U
	LDD #$44dd
	STD -41,U
	STB -120,U
	LEAU -200,U

	LDA #$d4
	STA ,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$4344
	STD 39,U
	LDD #$3d3d
	STD 119,U
	LDD #$dd34
	STD -41,U
	LDB #$d3
	STD -121,U
	LEAU -280,U

	LDA -80,U
	ANDA #$F0
	ORA #$03
	STA -80,U
	LDA #$44
	STA 80,U
	STA ,U
	RTS

