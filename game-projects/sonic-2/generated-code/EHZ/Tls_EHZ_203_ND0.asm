	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_203

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$7734
	STD 119,U
	LDB #$d4
	STD 39,U
	STD -41,U
	LDA #$87
	STD -121,U
	LEAU -320,U

	LDB #$d3
	STD 119,U
	LDD -41,U
	ANDA #$F0
	ORA #$08
	LDB #$7d
	STD -41,U
	LDD -121,U
	ANDA #$F0
	ORA #$07
	LDB #$7d
	STD -121,U
	LDD #$88dd
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dd44
	STD 119,U
	LDA #$7d
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDD #$7733
	STD 39,U
	LDB #$3d
	STD -41,U
	LDD #$7d34
	STD 119,U
	LDD #$87dd
	STD -121,U
	RTS

