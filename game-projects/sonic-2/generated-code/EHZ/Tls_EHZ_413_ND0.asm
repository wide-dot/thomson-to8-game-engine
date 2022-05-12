	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_413
	LEAU 441,U

	LDD #$d88d
	STD 119,U
	LDD #$dddd
	STD 39,U
	STD -41,U
	LDB #$3d
	STD -121,U
	LEAU -320,U

	LDB #$33
	STD 119,U
	STD 39,U
	LDD #$33dd
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	LDD #$33dd
	STD -121,U
	LDD #$ddd8
	STD 39,U
	LDB #$dd
	STD -41,U
	LEAU -320,U

	LDB #$33
	STD -41,U
	STD -121,U
	LDD #$33dd
	STD 119,U
	STD 39,U
	RTS

