	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00024_DN0
	LEAU 161,U

	LDD #$5555
	STD 119,U
	LDD #$4445
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$44
	STD -81,U
	STD -121,U
	LEAU -161,U

	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$4444
	STD -81,U
	STD -121,U
	LDA #$45
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDD #$5555
	STD 119,U
	LEAU -161,U

	LDD #$4444
	STD ,U
	RTS

