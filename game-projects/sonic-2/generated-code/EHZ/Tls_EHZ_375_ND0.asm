	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_375

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$5433
	STD 79,U
	LDD #$5535
	STD -1,U
	STD -81,U
	LEAU -280,U

	LDD #$3433
	STD 39,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$5533
	STD 119,U
	LDA #$44
	STD -41,U
	LDD -121,U
	LDA #$55
	ANDB #$0F
	ORB #$30
	STD -121,U
	LEAU -181,U

	STA -20,U
	LDD 20,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 20,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$5355
	STD -1,U
	LDA #$33
	STD 79,U
	LDA #$55
	STD -81,U
	LEAU -281,U

	LDD #$4354
	STD 120,U
	LDD #$dddd
	STD 80,U
	LDD 40,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 40,U
	LDD ,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD ,U
	LDA #$33
	STA -40,U
	LDA #$dd
	STA -80,U
	LDA #$53
	STA -120,U
	LEAU -180,U

	LDA #$54
	STA -20,U
	LDA #$dd
	STA 20,U
	RTS

