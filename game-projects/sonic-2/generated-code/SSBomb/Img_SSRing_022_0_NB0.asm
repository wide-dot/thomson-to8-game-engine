	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSRing_022_0
	STS glb_register_s

	LEAS ,Y
	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA -120,U
	LDA -80,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -40,U
	LDA ,U
	PSHS A
	ANDA #$0F
	ORA #$00
	STA ,U
	LDA 40,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 40,U
	LDA 80,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 80,U
	LDA 120,U
	PSHS U,A
	ANDA #$0F
	ORA #$10
	STA 120,U
	LEAU 160,U

	LDA ,U
	PSHS U,A
	ANDA #$0F
	ORA #$30
	STA ,U

	LDU <glb_screen_location_1
	LEAU ,S
SSAV_Img_SSRing_022_0
	LDS glb_register_s
	RTS

