	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00017_DN0
	LEAU 161,U

	LDD #$5555
	STD 119,U
	LDD #$4444
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$54
	STD -81,U
	STD -121,U
	LDB #$04
	STD -41,U
	LEAU -161,U

	LDB #$54
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
	STD -121,U
	LEAU -161,U

	STD ,U
	RTS

