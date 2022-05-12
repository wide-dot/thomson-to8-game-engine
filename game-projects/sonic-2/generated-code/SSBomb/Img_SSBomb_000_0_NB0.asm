	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSBomb_000_0
	STS glb_register_s

	LEAS ,Y
	LEAU 20,U

	LDA -60,U
	LDB -20,U
	PSHS B,A
	LDA 20,U
	LDB 60,U
	PSHS U,B,A
	LDA #$23
	STA -60,U
	STA 60,U
	LDA #$35
	STA -20,U
	STA 20,U

	LDU <glb_screen_location_1
	LEAU 20,U

	LDA -60,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -60,U
	LDA -20,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA -20,U
	LDA 20,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 20,U
	LDA 60,U
	PSHS U,A
	ANDA #$0F
	ORA #$20
	STA 60,U
	LEAU ,S
SSAV_Img_SSBomb_000_0
	LDS glb_register_s
	RTS

