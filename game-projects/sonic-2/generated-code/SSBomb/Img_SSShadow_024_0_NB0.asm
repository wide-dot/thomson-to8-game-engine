	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_024_0
	STS glb_register_s

	LEAS ,Y
	LDA ,U
	LDB -40,U
	PSHS B,A
	ANDB #$0F
	ORB #$20
	STB -40,U
	LDA 40,U
	PSHS U,A
	ANDA #$0F
	ORA #$20
	STA 40,U
	LDA #$22
	STA ,U

	LDU <glb_screen_location_1
	LEAU -1,U

	LDA ,U
	LDB -40,U
	PSHS B,A
	ANDB #$F0
	ORB #$02
	STB -40,U
	LDA 40,U
	PSHS U,A
	ANDA #$F0
	ORA #$02
	STA 40,U
	LDA #$22
	STA ,U
	LEAU ,S
SSAV_Img_SSShadow_024_0
	LDS glb_register_s
	RTS

