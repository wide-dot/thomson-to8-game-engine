	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_278

	stb   <glb_alphaTiles
	LEAU 200,U

	LDA 120,U
	ANDA #$0F
	ORA #$30
	STA 120,U
	LDA #$33
	STA 40,U
	STA -40,U
	LDD -120,U
	LDA #$34
	ANDB #$0F
	ORB #$40
	STD -120,U
	LEAU -199,U

	LDD #$3343
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 120,U

	LDA 120,U
	ANDA #$0F
	ORA #$30
	STA 120,U
	LDA #$44
	STA 40,U
	STA -40,U
	LDD -120,U
	LDA #$44
	ANDB #$0F
	ORB #$30
	STD -120,U
	RTS

