	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_027_0
	STS glb_register_s

	LEAS ,Y
	LEAU 20,U

	LDA -20,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -20,U
	LDA 20,U
	PSHS U,A
	ANDA #$0F
	ORA #$20
	STA 20,U

	LDU <glb_screen_location_1
	LEAU 19,U

	LDA -20,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA -20,U
	LDA 20,U
	PSHS U,A
	ANDA #$F0
	ORA #$02
	STA 20,U
	LEAU ,S
SSAV_Img_SSShadow_027_0
	LDS glb_register_s
	RTS

