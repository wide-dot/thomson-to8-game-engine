	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00030_DN0
	LEAU 161,U

	LDD #$4544
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$0500
	STD -121,U
	LEAU -161,U

	LDD #$5555
	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$5055
	STD -121,U
	LDA #$54
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -161,U

	LDA #$55
	STD ,U
	RTS

