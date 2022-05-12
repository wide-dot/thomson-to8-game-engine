	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_026_0
	STS glb_register_s

	LEAS ,Y
	LEAU -20,U

	LDA -100,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -100,U
	LDA -60,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -60,U
	LDA -20,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -20,U
	LDA 20,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA 20,U
	LDA 60,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA 60,U
	LDA 100,U
	PSHS U,A
	ANDA #$0F
	ORA #$20
	STA 100,U

	LDU <glb_screen_location_1
	LEAU ,S
SSAV_Img_SSShadow_026_0
	LDS glb_register_s
	RTS

