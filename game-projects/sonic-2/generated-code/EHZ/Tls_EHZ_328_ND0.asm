	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_328
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$3345
	STD -1,U
	STD -81,U
	LDD #$d454
	STD 79,U
	LEAU -280,U

	STD 119,U
	STD 39,U
	LDD #$dd34
	STD -41,U
	LDB #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$d353
	STD -121,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDB #$d3
	STD -21,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$444d
	STD -1,U
	STD -81,U
	LDD #$35d4
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDD #$d4d3
	STD -121,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$433d
	STD -41,U
	LDD #$35d4
	STD 119,U
	STD 39,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDD #$3d3d
	STD -21,U
	RTS

