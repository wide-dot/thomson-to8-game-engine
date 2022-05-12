	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_263

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$33dd
	STD 119,U
	LDA #$dd
	STD 39,U
	LDD #$4434
	STD -41,U
	STD -121,U
	LEAU -240,U

	STD 39,U
	LDD -41,U
	ANDA #$F0
	ORA #$04
	LDB #$34
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dd33
	STD 39,U
	LDD #$3dd3
	STD 119,U
	LDD #$3344
	STD -41,U
	STD -121,U
	LEAU -240,U

	STD 39,U
	STD -41,U
	RTS

