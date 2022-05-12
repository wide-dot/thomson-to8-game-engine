	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_370

	stb   <glb_alphaTiles
	LEAU 120,U

	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$40
	STD -40,U
	STA 120,U
	STA 40,U
	LDD #$dd44
	STD -120,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$d3
	STA 80,U
	LDA #$d4
	STA ,U
	LDD -80,U
	LDA #$d4
	ANDB #$0F
	ORB #$d0
	STD -80,U
	RTS

