	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00018_DN0
	LEAU 161,U

	LDD #$5500
	STD -81,U
	LDB #$44
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -121,U
	LDB #$55
	STD 119,U
	LEAU -161,U

	LDB #$44
	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$5555
	STD 119,U
	LDD #$4405
	STD -81,U
	LDB #$45
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$55
	STD -121,U
	LEAU -161,U

	STD ,U
	RTS

