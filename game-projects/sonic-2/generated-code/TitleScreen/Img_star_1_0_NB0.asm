	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_star_1_0
	STS glb_register_s

	LEAS ,Y
	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA -80,U
	LDA ,U
	PSHS A
	ANDA #$0F
	ORA #$00
	STA ,U
	LDA 80,U
	PSHS U,A
	ANDA #$F0
	ORA #$0b
	STA 80,U

	LDU <glb_screen_location_1
	LEAU -1,U

	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA -80,U
	LDA 80,U
	PSHS U,A
	ANDA #$F0
	ORA #$0b
	STA 80,U
	LEAU ,S
SSAV_Img_star_1_0
	LDS glb_register_s
	RTS

