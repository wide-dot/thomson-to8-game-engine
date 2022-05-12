	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_96

	stb   <glb_alphaTiles
	LEAU 81,U

	LDD #$8787
	STD -81,U
	LDD -1,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD -1,U
	LDA 80,U
	ANDA #$F0
	ORA #$07
	STA 80,U

	LDU <glb_screen_location_1
	LEAU 81,U

	LDA #$78
	STA 80,U
	LDD #$7878
	STD -1,U
	STD -81,U
	RTS

