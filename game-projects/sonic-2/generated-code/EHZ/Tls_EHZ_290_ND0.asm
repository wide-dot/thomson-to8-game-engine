	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_290

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$3555
	STD 79,U
	LDD #$3333
	STD -81,U
	LDB #$53
	STD -1,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD -1,U
	LDD #$3333
	STD 119,U
	LDB #$53
	STD 39,U
	LDA #$35
	STD -41,U
	LDD -81,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -81,U
	LDD -121,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -121,U
	LEAU -181,U

	LDA #$dd
	STA 20,U
	LDA #$33
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$3533
	STD -81,U
	LDD #$5535
	STD 79,U
	LDB #$33
	STD -1,U
	LEAU -281,U

	LDA #$34
	STD 120,U
	LDD 80,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 80,U
	LDD 40,U
	LDA #$55
	ANDB #$0F
	ORB #$30
	STD 40,U
	LDA #$dd
	STA ,U
	STA -80,U
	LDA #$55
	STA -40,U
	LDA #$45
	STA -120,U
	LEAU -180,U

	LDA #$dd
	STA 20,U
	LDA #$33
	STA -20,U
	RTS

