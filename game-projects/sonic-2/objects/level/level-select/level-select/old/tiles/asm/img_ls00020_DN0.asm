	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00020_DN0
	LEAU 161,U

	LDD #$4404
	STD 119,U
	STD 79,U
	STD -81,U
	LDB #$44
	STD 39,U
	STD -1,U
	STD -41,U
	LDD #$0050
	STD -121,U
	LEAU -161,U

	LDD #$5555
	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$0000
	STD -121,U
	LDD #$4444
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -161,U

	LDD #$5555
	STD ,U
	RTS
