	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_262

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$34dd
	STD 119,U
	LDD #$d433
	STD -121,U
	LDD #$343d
	STD 39,U
	LDB #$33
	STD -41,U
	LEAU -200,U

	STB ,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$4434
	STD -41,U
	STD -121,U
	LDB #$dd
	STD 39,U
	LDA #$3d
	STD 119,U
	LEAU -200,U

	LDD -1,U
	ANDA #$F0
	ORA #$03
	LDB #$34
	STD -1,U
	RTS

