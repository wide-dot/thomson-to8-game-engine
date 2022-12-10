	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00028_DN0
	LEAU 161,U

	LDD #$5555
	STD 119,U
	LDD #$0044
	STD -121,U
	LDA #$44
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$54
	STD 79,U
	LEAU -161,U

	LDA #$44
	STD ,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDD #$5555
	STD 119,U
	LDD #$0545
	STD -121,U
	LDA #$40
	STD 39,U
	LDA #$45
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$4455
	STD 79,U
	LEAU -161,U

	LDB #$05
	STD ,U
	RTS

