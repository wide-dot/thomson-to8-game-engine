	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_131
	LEAU 441,U

	LDD #$4455
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDB #$44
	STD -121,U
	LDD #$4555
	STD -41,U
	LDA #$44
	STD 119,U
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$5555
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDD #$4444
	STD -121,U
	LDD #$5555
	STD 119,U
	STD 39,U
	STD -41,U
	RTS
