	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_025_0
	STS glb_register_s

	LEAS ,Y
	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA -40,U
	LDA ,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA ,U
	LDA 40,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA 40,U
	LDA 80,U
	PSHS U,A
	ANDA #$0F
	ORA #$20
	STA 80,U

	LDU <glb_screen_location_1
	LEAU 99,U

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
SSAV_Img_SSShadow_025_0
	LDS glb_register_s
	RTS

