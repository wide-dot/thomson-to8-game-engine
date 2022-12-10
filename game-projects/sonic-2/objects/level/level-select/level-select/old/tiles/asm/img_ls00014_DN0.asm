	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00014_DN0
	LEAU 161,U

	LDD #$5544
	STD 119,U
	STD 79,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$00
	STD 39,U
	STD -121,U
	LEAU -161,U

	LDB #$55
	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$4455
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$45
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$0005
	STD -121,U
	LEAU -161,U

	LDD #$5555
	STD ,U
	RTS

