	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_015_0
	STS glb_register_s

	LEAS ,Y
	LEAU -1,U

	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -80,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD 80,U
	LDX -40,U
	LDY ,U
	PSHS Y,X
	LDD 40,U
	PSHS U,D
	LDD #$2222
	STD -40,U
	STD ,U
	STD 40,U

	LDU <glb_screen_location_1
	LEAU -1,U

	LDA -80,U
	LDB 80,U
	LDX ,U
	PSHS X,B,A
	LDD -40,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD -40,U
	LDD 40,U
	PSHS U,D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD 40,U
	STA -80,U
	STA 80,U
	LDD #$2222
	STD ,U
	LEAU ,S
SSAV_Img_SSShadow_015_0
	LDS glb_register_s
	RTS

