	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00035_DN0
	LEAU 161,U

	LDD #$5555
	STD 119,U
	LDA #$44
	STD -81,U
	LDB #$00
	STD -41,U
	LDB #$44
	STD 79,U
	STD 39,U
	STD -1,U
	STD -121,U
	LEAU -161,U

	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$5555
	STD 119,U
	LDA #$44
	STD -121,U
	LDD #$4005
	STD -41,U
	LDD #$4555
	STD -81,U
	LDD #$4445
	STD 79,U
	STD 39,U
	STD -1,U
	LEAU -161,U

	LDB #$55
	STD ,U
	RTS

