	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_53
	LEAU 481,U

	LDD #$5544
	STD 119,U
	LDD #$eebb
	STD -81,U
	LDD #$b455
	STD 39,U
	LDD #$bb54
	STD -1,U
	LDD #$ee4b
	STD -41,U
	LDD #$4545
	STD 79,U
	LDD #$beee
	STD -121,U
	LEAU -280,U

	LDA #$bb
	STD 119,U
	LDB #$bb
	STD 79,U
	LDD #$4444
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$b4bb
	STD 39,U
	STD -1,U
	LEAU -201,U

	LDD #$4454
	STD 40,U
	LDB #$55
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$5454
	STD 79,U
	LDD #$4455
	STD 119,U
	LDD #$554b
	STD 39,U
	LDD #$45bb
	STD -1,U
	LDD #$b4be
	STD -41,U
	LDD #$ebee
	STD -81,U
	LDD #$eeeb
	STD -121,U
	LEAU -280,U

	LDD #$bebb
	STD 119,U
	LDA #$bb
	STD 79,U
	LDD #$4b4b
	STD 39,U
	LDD #$4444
	STD -1,U
	LDA #$b4
	STD -41,U
	LDD #$44b4
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$5554
	STD ,U
	LDD #$4544
	STD 40,U
	RTS

