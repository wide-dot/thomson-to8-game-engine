	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_72
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$ee4b
	STD -41,U
	LDD #$e442
	STD 39,U
	LDD #$44ee
	STD -1,U
	LDD #$2ee2
	STD 79,U
	LDD #$444b
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDA #$b4
	STD ,U
	LDA #$44
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$ee44
	STD 39,U
	STD -1,U
	LDD #$e2ee
	STD 79,U
	LDD #$dddd
	STD 119,U
	LDD #$e4ee
	STD -41,U
	LDB #$b4
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

