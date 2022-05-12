	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_288

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA #$35
	STA 80,U
	LDA #$33
	STA ,U
	STA -80,U
	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	LDD -121,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -121,U
	LEAU -280,U

	LDD #$4535
	STD 39,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD 119,U
	ANDA #$F0
	ORA #$04
	LDB #$33
	STD 119,U
	LDD #$5535
	STD -41,U
	LDB #$33
	STD -121,U
	LEAU -180,U

	LDA #$34
	STD -21,U
	LDD #$dddd
	STD 19,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDA #$dd
	STA 120,U
	LDD #$dddd
	STD -41,U
	STD -121,U
	LDD 39,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 39,U
	LDD -1,U
	ANDA #$F0
	ORA #$03
	LDB #$55
	STD -1,U
	STB 80,U
	LDD #$3334
	STD -81,U
	LEAU -280,U

	LDB #$45
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$5555
	STD -41,U
	LDA #$53
	STD 39,U
	STD -121,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDD #$3334
	STD -21,U
	RTS

