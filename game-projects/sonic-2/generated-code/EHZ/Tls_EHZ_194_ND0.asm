	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_194
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
