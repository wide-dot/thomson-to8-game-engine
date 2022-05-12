	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_369

	stb   <glb_alphaTiles
	LEAU 280,U

	LDD #$3334
	STD -120,U
	LDA #$44
	STD 40,U
	STD -40,U
	STA 120,U
	LEAU -239,U

	LDD #$ddd4
	STD 39,U
	LDB #$dd
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 280,U

	LDD #$3344
	STD -40,U
	STD -120,U
	STA 40,U
	LDA 120,U
	ANDA #$0F
	ORA #$30
	STA 120,U
	LEAU -239,U

	LDD #$dddd
	STD -41,U
	LDB #$44
	STD 39,U
	RTS

