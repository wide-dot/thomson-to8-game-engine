	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00026_DN0
	LEAU 161,U

	LDD #$4454
	STD -81,U
	LDB #$50
	STD -121,U
	LDB #$44
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$04
	STD -41,U
	LDD #$5555
	STD 119,U
	LEAU -161,U

	LDA #$44
	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$4044
	STD -41,U
	LDA #$44
	STD 79,U
	STD 39,U
	STD -1,U
	LDD #$5555
	STD 119,U
	LDD #$4544
	STD -81,U
	LDB #$00
	STD -121,U
	LEAU -161,U

	LDB #$55
	STD ,U
	RTS

