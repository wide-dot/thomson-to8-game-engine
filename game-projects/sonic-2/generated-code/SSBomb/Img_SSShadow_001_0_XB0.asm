	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_001_0
	STS glb_register_s

	LEAS ,Y
	LEAU -479,U

	LDA -80,U
	LDB -40,U
	PSHS B,A
	LDA ,U
	LDB 40,U
	PSHS B,A
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD 119,U
	LDA 80,U
	STB -80,U
	STB -40,U
	STB ,U
	STB 40,U
	STB 80,U
	LDB -120,U
	PSHS U,B,A
	ANDB #$0F
	ORB #$20
	STB -120,U
	LEAU 279,U

	LDD -120,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -120,U
	LDD -80,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD -80,U
	LDD -40,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD -40,U
	LDD ,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD ,U
	LDD 40,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD 40,U
	LDA 80,U
	LDB 120,U
	PSHS U,B,A
	LDA #$22
	STA 80,U
	STA 120,U
	LEAU 280,U

	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -81,U
	LDD 119,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD 119,U
	LDA -120,U
	LDX -41,U
	LDY -1,U
	PSHS Y,X,A
	LDD 39,U
	LDX 79,U
	PSHS U,X,D
	LDD #$2222
	STD -41,U
	STD -1,U
	STD 39,U
	STD 79,U
	STA -120,U
	LEAU 258,U

	LDD -100,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -100,U
	LDD -60,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -60,U
	LDA -98,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -98,U
	LDA 100,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA 100,U
	LDX -20,U
	LDY 20,U
	PSHS Y,X
	LDD 60,U
	PSHS U,D
	LDD #$2222
	STD -20,U
	STD 20,U
	STD 60,U

	LDU <glb_screen_location_1
	LEAU -440,U

	LDA -40,U
	LDB -120,U
	PSHS B,A
	ANDB #$F0
	ORB #$02
	STB -120,U
	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$02
	STA -80,U
	LDA ,U
	LDB 40,U
	PSHS B,A
	LDA 80,U
	LDB 120,U
	PSHS U,B,A
	LDA #$22
	STA -40,U
	STA ,U
	STA 40,U
	STA 80,U
	STA 120,U
	LEAU 280,U

	LDA -120,U
	LDB -80,U
	LDX 79,U
	LDY 119,U
	PSHS Y,X,B,A
	LDD -1,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -1,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD 39,U
	LDA -40,U
	PSHS U,A
	STB -120,U
	STB -80,U
	STB -40,U
	LDD #$2222
	STD 79,U
	STD 119,U
	LEAU 279,U

	LDX 79,U
	LDY 119,U
	PSHS Y,X
	STD 79,U
	STD 119,U
	LDD -120,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD -120,U
	LDD -80,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD -80,U
	LDD -40,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD -40,U
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
	LEAU 239,U

	LDD ,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD ,U
	LDA 40,U
	LDB 80,U
	LDX -80,U
	LDY -40,U
	PSHS U,Y,X,B,A
	LDD #$2222
	STD -80,U
	STD -40,U
	STA 40,U
	STA 80,U
	LEAU ,S
SSAV_Img_SSShadow_001_0
	LDS glb_register_s
	RTS
