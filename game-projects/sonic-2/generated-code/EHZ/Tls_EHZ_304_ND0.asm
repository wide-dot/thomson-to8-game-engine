	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_304
	LEAU 441,U

	LDD #$33dd
	STD 119,U
	LDD #$4433
	STD -121,U
	LDA #$dd
	STD 39,U
	STD -41,U
	LEAU -320,U

	LDA #$44
	STD 119,U
	STD 39,U
	LDD #$3344
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dd44
	STD -121,U
	LDD #$33dd
	STD 39,U
	STD -41,U
	LDD #$dd33
	STD 119,U
	LEAU -320,U

	LDA #$44
	STD -41,U
	STD -121,U
	LDD #$3344
	STD 119,U
	STD 39,U
	RTS
