	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_76
	LEAU 441,U

	LDD #$dd43
	STD -121,U
	LDD #$3345
	STD 39,U
	STD -41,U
	LDD #$d454
	STD 119,U
	LEAU -320,U

	LDD #$3555
	STD 119,U
	STD -121,U
	LDA #$44
	STD 39,U
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$35d4
	STD 119,U
	LDD #$444d
	STD 39,U
	STD -41,U
	LDD #$33dd
	STD -121,U
	LEAU -320,U

	LDD #$5553
	STD 39,U
	STD -41,U
	LDD #$4544
	STD 119,U
	STD -121,U
	RTS
