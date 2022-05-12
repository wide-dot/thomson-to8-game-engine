	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_387

	stb   <glb_alphaTiles
	LEAU 520,U

	LDD 40,U
	LDA #$44
	ANDB #$0F
	ORB #$70
	STD 40,U
	LDD #$dddd
	STD 80,U
	STA ,U
	LDA #$44
	STA -40,U
	LDA -80,U
	ANDA #$0F
	ORA #$d0
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 560,U

	LDA -40,U
	ANDA #$0F
	ORA #$d0
	STA -40,U
	LDA #$dd
	STA 40,U
	LDA #$d3
	STA ,U
	RTS

