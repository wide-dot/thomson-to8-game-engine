	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSRing_019_0
	STS glb_register_s

	LEAS ,Y
	LEAU -320,U

	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$01
	LDB #$0a
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$01
	LDB #$a0
	STD -41,U
	LDD -1,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$1a
	STD -1,U
	LDX 39,U
	PSHS X
	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA -120,U
	LDD #$1a3a
	STD 39,U
	LDD 79,U
	PSHS D
	LDA #$11
	ANDB #$F0
	ORB #$01
	STD 79,U
	LDD 119,U
	PSHS U,D
	LDA #$a1
	ANDB #$F0
	ORB #$01
	STD 119,U
	LEAU 279,U

	LDD -120,U
	PSHS D
	LDA #$a1
	ANDB #$F0
	ORB #$01
	STD -120,U
	LDD -80,U
	PSHS D
	LDA #$a1
	ANDB #$F0
	ORB #$01
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$a001
	STD -40,U
	LDD ,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$a001
	STD ,U
	LDD 40,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$a001
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$a001
	STD 80,U
	LDD 120,U
	PSHS U,D
	ANDA #$0F
	ANDB #$F0
	ADDD #$a001
	STD 120,U
	LEAU 280,U

	LDD -120,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$a001
	STD -120,U
	LDD -80,U
	PSHS D
	LDA #$a1
	ANDB #$F0
	ORB #$01
	STD -80,U
	LDD -40,U
	PSHS D
	LDA #$a1
	ANDB #$F0
	ORB #$01
	STD -40,U
	LDD ,U
	PSHS D
	LDA #$11
	ANDB #$F0
	ORB #$01
	STD ,U
	LDX 40,U
	LDD #$1031
	STD 40,U
	LDY 80,U
	PSHS Y,X
	LDD #$3a1a
	STD 80,U
	LDD 120,U
	PSHS U,D
	ANDA #$F0
	ORA #$01
	LDB #$1a
	STD 120,U
	LEAU 201,U

	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$a1
	STD -41,U
	LDA ,U
	LDB 40,U
	PSHS U,B,A
	ANDB #$0F
	ORB #$30
	STB 40,U
	LDA #$13
	STA ,U

	LDU <glb_screen_location_1
	LEAU -320,U

	LDD -41,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDD -1,U
	PSHS D
	LDA #$13
	ANDB #$0F
	ORB #$a0
	STD -1,U
	LDA -81,U
	LDB 120,U
	PSHS B,A
	LDD 39,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$3000
	STD 39,U
	LDA 80,U
	LDB -121,U
	PSHS U,B,A
	LDA #$01
	STA 80,U
	LDA #$a1
	STA 120,U
	LDA #$11
	STA -121,U
	LDA #$aa
	STA -81,U
	LEAU 279,U

	LDA -39,U
	LDB -79,U
	PSHS B,A
	LDA 81,U
	LDB -121,U
	PSHS B,A
	ANDB #$F0
	ORB #$01
	STB -121,U
	LDA -81,U
	PSHS A
	ANDA #$F0
	ORA #$01
	STA -81,U
	LDA -41,U
	PSHS A
	ANDA #$F0
	ORA #$01
	STA -41,U
	LDA -1,U
	PSHS A
	ANDA #$F0
	ORA #$01
	STA -1,U
	LDA 39,U
	PSHS A
	ANDA #$F0
	ORA #$01
	STA 39,U
	LDA 79,U
	PSHS A
	ANDA #$F0
	ORA #$01
	STA 79,U
	LDA 119,U
	PSHS A
	ANDA #$F0
	ORA #$01
	STA 119,U
	LDA 41,U
	LDB 121,U
	PSHS B,A
	LDA -119,U
	LDB 1,U
	PSHS U,B,A
	LDA #$a0
	STA -39,U
	STA 1,U
	STA 41,U
	STA 81,U
	STA 121,U
	LDA #$aa
	STA -119,U
	STA -79,U
	LEAU 280,U

	LDA -119,U
	LDB 1,U
	LDX 80,U
	PSHS X,B,A
	LDD 40,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$a1
	STD 40,U
	LDA -39,U
	STB -39,U
	STB 1,U
	LDB -79,U
	PSHS B,A
	LDD #$13a3
	STD 80,U
	LDD 120,U
	PSHS D
	LDA #$a1
	ANDB #$0F
	ORB #$10
	STD 120,U
	LDA -121,U
	PSHS A
	ANDA #$F0
	ORA #$01
	STA -121,U
	LDA -81,U
	PSHS U,A
	ANDA #$F0
	ORA #$03
	STA -81,U
	LDA #$a0
	STA -119,U
	LDA #$aa
	STA -79,U
	LEAU 200,U

	LDD -40,U
	PSHS D
	LDA #$1a
	ANDB #$0F
	ORB #$30
	STD -40,U
	LDA ,U
	LDB 40,U
	PSHS U,B,A
	LDA #$11
	STA ,U
	LDA #$33
	STA 40,U
	LEAU ,S
SSAV_Img_SSRing_019_0
	LDS glb_register_s
	RTS
