	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_354

	stb   <glb_alphaTiles
	LEAU 440,U

	LDD #$3353
	STD -120,U
	LDD 40,U
	LDA #$34
	ANDB #$0F
	ORB #$40
	STD 40,U
	LDD #$3554
	STD -40,U
	LDA #$33
	STA 120,U
	LEAU -319,U

	LDB #$33
	STD 119,U
	STD 39,U
	LDD #$3555
	STD -121,U
	LDD #$3353
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDA #$34
	STA 120,U
	LDD -120,U
	LDA #$45
	ANDB #$0F
	ORB #$30
	STD -120,U
	LDA #$55
	STA 40,U
	STA -40,U
	LEAU -319,U

	LDD #$3333
	STD 119,U
	LDA #$35
	STD 39,U
	LDA #$55
	STD -41,U
	LDB #$35
	STD -121,U
	RTS
