	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_128
	LEAU 481,U

	LDD #$bbe1
	STD 119,U
	STD 79,U
	LDA #$ee
	STD 39,U
	LDA #$e5
	STD -1,U
	LDD #$b5e0
	STD -41,U
	LDB #$b0
	STD -81,U
	LDD #$bebe
	STD -121,U
	LEAU -280,U

	LDD #$b4ee
	STD -121,U
	LDA #$bb
	STD 79,U
	STD 39,U
	LDB #$eb
	STD -1,U
	LDA #$ee
	STD -41,U
	LDA #$55
	STD -81,U
	LDD #$bbbe
	STD 119,U
	LEAU -201,U

	LDD #$ee44
	STD ,U
	LDB #$e4
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ee12
	STD 119,U
	LDD #$b511
	STD -81,U
	LDD #$eb12
	STD -1,U
	STD -41,U
	LDA #$55
	STD 79,U
	STD 39,U
	LDB #$11
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	LDD #$45be
	STD -121,U
	LDD #$bbe0
	STD 39,U
	LDB #$ee
	STD -1,U
	LDA #$eb
	STD -41,U
	LDD #$5ebe
	STD -81,U
	LDD #$bb01
	STD 79,U
	LEAU -201,U

	LDD #$b4be
	STD 40,U
	LDD #$eeee
	STD ,U
	RTS

