	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_365

	stb   <glb_alphaTiles
	LEAU 440,U

	LDD -120,U
	LDA #$d4
	ANDB #$0F
	ORB #$d0
	STD -120,U
	STA 40,U
	STA -40,U
	LDA 120,U
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LEAU -319,U

	LDD #$44dd
	STD 119,U
	STD 39,U
	LDD #$d4d3
	STD -41,U
	LDD #$34dd
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 280,U

	LDA #$43
	STA 120,U
	LDA #$44
	STA 40,U
	LDD -40,U
	LDA #$44
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDD #$43d3
	STD -120,U
	LEAU -239,U

	LDD #$ddd4
	STD 39,U
	LDD #$3d44
	STD -41,U
	RTS

