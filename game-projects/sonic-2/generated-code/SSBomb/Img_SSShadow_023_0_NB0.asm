	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_023_0
	STS glb_register_s

	LEAS ,Y

	LDU <glb_screen_location_1
	LEAU -41,U

	LDA -120,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA -120,U
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
	ANDA #$F0
	ORA #$02
	STA ,U
	LDA 40,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA 40,U
	LDA 80,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA 80,U
	LDA 120,U
	PSHS U,A
	ANDA #$F0
	ORA #$02
	STA 120,U
	LEAU ,S
SSAV_Img_SSShadow_023_0
	LDS glb_register_s
	RTS

