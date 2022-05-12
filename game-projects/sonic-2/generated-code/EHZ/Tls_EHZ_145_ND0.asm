	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_145

	stb   <glb_alphaTiles
	LEAU 440,U

	LDD #$8787
	STD 120,U
	STD 40,U
	STD -40,U
	STA -120,U
	LEAU -200,U

	LDA ,U
	ANDA #$F0
	ORA #$07
	STA ,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDD #$7878
	STD 120,U
	STD 40,U
	LDD -40,U
	LDA #$78
	ANDB #$F0
	ORB #$08
	STD -40,U
	STA -120,U
	LEAU -200,U

	LDA ,U
	ANDA #$F0
	ORA #$08
	STA ,U
	RTS

