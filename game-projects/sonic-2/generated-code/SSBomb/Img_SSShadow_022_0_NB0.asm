	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_022_0
	STS glb_register_s

	LEAS ,Y
	LEAU 100,U

	LDA 20,U
	LDB -60,U
	PSHS B,A
	ANDB #$0F
	ORB #$20
	STB -60,U
	LDA -20,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -20,U
	LDA 60,U
	PSHS U,A
	ANDA #$F0
	ORA #$02
	STA 60,U
	LDA #$22
	STA 20,U

	LDU <glb_screen_location_1
	LEAU -21,U

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
	LDA 60,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA 60,U
	LDA 100,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA 100,U
	LDA -20,U
	LDB 20,U
	PSHS U,B,A
	LDA #$22
	STA -20,U
	STA 20,U
	LEAU ,S
SSAV_Img_SSShadow_022_0
	LDS glb_register_s
	RTS
