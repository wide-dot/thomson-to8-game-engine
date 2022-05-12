	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_star_2_0
	STS glb_register_s

	LEAS ,Y
	LDA ,U
	LDB -120,U
	PSHS B,A
	ANDB #$F0
	ORB #$0c
	STB -120,U
	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA -40,U
	LDA 40,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA 40,U
	LDA 80,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA 80,U
	LDA 120,U
	PSHS U,A
	ANDA #$F0
	ORA #$0c
	STA 120,U
	LDA #$b0
	STA ,U

	LDU <glb_screen_location_1
	LDA ,U
	PSHS U,A
	ANDA #$0F
	ORA #$b0
	STA ,U
	LEAU ,S
SSAV_Img_star_2_0
	LDS glb_register_s
	RTS

