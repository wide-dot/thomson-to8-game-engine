	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00013_DN0
	LEAU 161,U

	LDD #$4454
	STD 119,U
	STD 79,U
	LDB #$50
	STD 39,U
	LDB #$55
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$00
	STD -121,U
	LEAU -161,U

	LDA #$55
	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$4544
	STD 119,U
	STD 79,U
	LDD #$0555
	STD -121,U
	LDA #$45
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$00
	STD 39,U
	LEAU -161,U

	LDD #$5555
	STD ,U
	RTS

