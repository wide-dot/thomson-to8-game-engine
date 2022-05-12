	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_018_0
	STS glb_register_s

	LEAS ,Y
	LDA -80,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -80,U
	LDA 80,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA 80,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -41,U
	LDD -1,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -1,U
	LDD 39,U
	PSHS U,D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD 39,U

	LDU <glb_screen_location_1
	LEAU -1,U

	LDA -80,U
	LDB -40,U
	PSHS B,A
	LDD ,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD ,U
	LDA 40,U
	LDB 80,U
	PSHS U,B,A
	LDA #$22
	STA -80,U
	STA -40,U
	STA 40,U
	STA 80,U
	LEAU ,S
SSAV_Img_SSShadow_018_0
	LDS glb_register_s
	RTS

