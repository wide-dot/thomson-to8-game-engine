	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSRing_010_0
	STS glb_register_s

	LEAS ,Y

	LDU <glb_screen_location_1
	LEAU 19,U

	LDA -60,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA -60,U
	LDA -20,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA -20,U
	LDA 20,U
	PSHS A
	ANDA #$F0
	ORA #$01
	STA 20,U
	LDA 60,U
	PSHS U,A
	ANDA #$F0
	ORA #$01
	STA 60,U
	LEAU ,S
SSAV_Img_SSRing_010_0
	LDS glb_register_s
	RTS

