	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_57

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$6766
	STD -121,U
	LDD 119,U
	ANDA #$F0
	ORA #$06
	LDB #$66
	STD 119,U
	LDD 39,U
	ANDA #$F0
	ORA #$06
	LDB #$66
	STD 39,U
	LDD -41,U
	ANDA #$0F
	ORA #$70
	LDB #$66
	STD -41,U
	LEAU -320,U

	LDD #$6663
	STD 119,U
	LDD #$3464
	STD 39,U
	LDD #$4434
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD 119,U
	LDA #$66
	ANDB #$0F
	ORB #$70
	STD 119,U
	LDD 39,U
	LDA #$67
	ANDB #$0F
	ORB #$60
	STD 39,U
	LDD #$3767
	STD -41,U
	LDD #$7766
	STD -121,U
	LEAU -320,U

	LDD #$4744
	STD 39,U
	LDD #$6743
	STD 119,U
	LDD #$4344
	STD -41,U
	LDA #$44
	STD -121,U
	RTS
