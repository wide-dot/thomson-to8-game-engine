	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_279

	stb   <glb_alphaTiles
	LEAU 101,U

	LDA 100,U
	ANDA #$F0
	ORA #$0d
	STA 100,U
	LDA 60,U
	ANDA #$F0
	ORA #$03
	STA 60,U
	LDA #$33
	STA -20,U
	LDA #$34
	STA -100,U
	LDA #$dd
	STA 20,U
	STA -60,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDA #$dd
	STA 80,U
	STA 40,U
	LDA #$d3
	STA ,U
	LDA #$dd
	STA -40,U
	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDD -81,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -81,U
	LDD -121,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -121,U
	LEAU -160,U

	LDD #$d343
	STD -1,U
	RTS

