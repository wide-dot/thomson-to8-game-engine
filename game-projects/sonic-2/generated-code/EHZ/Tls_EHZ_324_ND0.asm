	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_324
	LEAU 441,U

	LDD #$33dd
	STD 119,U
	STD 39,U
	LDA #$dd
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDA #$33
	STD -41,U
	STD -121,U
	LDA #$dd
	STD 119,U
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	LDA #$33
	STD -41,U
	STD -121,U
	LEAU -320,U

	STD 119,U
	STD 39,U
	LDA #$dd
	STD -41,U
	STD -121,U
	RTS

