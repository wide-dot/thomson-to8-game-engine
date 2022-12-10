	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00007_DN0
	LEAU 161,U

	LDD #$5555
	STD 119,U
	LDD #$5444
	STD 79,U
	LDA #$44
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -161,U

	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$4455
	STD 79,U
	LDA #$55
	STD 119,U
	LDD #$4045
	STD 39,U
	LDA #$45
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -161,U

	STD ,U
	RTS

