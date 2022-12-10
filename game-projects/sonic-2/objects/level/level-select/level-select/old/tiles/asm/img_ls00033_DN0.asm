	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00033_DN0
	LEAU 161,U

	LDD #$4544
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$5555
	STD 119,U
	LEAU -161,U

	LDD #$4544
	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$5555
	STD 119,U
	LDA #$54
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -161,U

	STD ,U
	RTS

