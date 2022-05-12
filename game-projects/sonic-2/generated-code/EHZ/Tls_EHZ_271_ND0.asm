	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_271

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA 120,U
	ANDA #$0F
	ORA #$30
	STA 120,U
	LDA #$44
	STA 40,U
	STA -40,U
	LDD #$34dd
	STD -120,U
	LEAU -319,U

	LDD #$44d3
	STD 39,U
	LDD #$d3dd
	STD 119,U
	LDD #$34d3
	STD -41,U
	LDD #$dddd
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 280,U

	LDD #$4344
	STD -120,U
	LDA #$3d
	STA 40,U
	LDD #$ddd3
	STD -40,U
	LDA #$44
	STA 120,U
	LEAU -239,U

	LDD #$3333
	STD 39,U
	LDD #$ddd3
	STD -41,U
	RTS

