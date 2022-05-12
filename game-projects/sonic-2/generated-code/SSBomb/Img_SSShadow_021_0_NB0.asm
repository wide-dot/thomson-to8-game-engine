	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_021_0
	STS glb_register_s

	LEAS ,Y
	LDD -1,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -1,U
	LDA -40,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -40,U
	LDA 40,U
	PSHS U,A
	ANDA #$0F
	ORA #$20
	STA 40,U

	LDU <glb_screen_location_1
	LEAU -1,U

	LDA -40,U
	LDB ,U
	PSHS B,A
	LDA 40,U
	PSHS U,A
	LDA #$22
	STA -40,U
	STA ,U
	STA 40,U
	LEAU ,S
SSAV_Img_SSShadow_021_0
	LDS glb_register_s
	RTS

