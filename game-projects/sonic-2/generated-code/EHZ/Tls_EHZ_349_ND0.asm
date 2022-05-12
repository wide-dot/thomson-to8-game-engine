	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_349

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8888
	STD -41,U
	STD -121,U
	LDD #$8787
	STD 119,U
	STD 39,U
	LEAU -280,U

	LDD #$8888
	STD 79,U
	LDA -80,U
	ANDA #$F0
	ORA #$06
	STA -80,U
	LDD #$8866
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDA #$66
	STA -80,U
	LDB #$66
	STD -1,U
	LDD #$8888
	STD 79,U
	RTS

