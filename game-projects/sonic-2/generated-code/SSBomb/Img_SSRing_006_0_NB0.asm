	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSRing_006_0
	STS glb_register_s

	LEAS ,Y
	LEAU -160,U

	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$01
	LDB #$a0
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$3a
	STD -41,U
	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$00
	STA -120,U
	LDA 119,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 119,U
	LDD -1,U
	PSHS D
	LDA #$1a
	ANDB #$F0
	ORB #$03
	STD -1,U
	LDA 39,U
	LDB 79,U
	PSHS U,B,A
	LDA #$a1
	STA 39,U
	STA 79,U
	LEAU 279,U

	LDD 80,U
	PSHS D
	LDA #$1a
	ANDB #$F0
	ORB #$01
	STD 80,U
	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -120,U
	LDA -80,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$0F
	ORA #$00
	STA -40,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$01
	LDB #$aa
	STD 120,U
	LDA ,U
	LDB 40,U
	PSHS U,B,A
	LDA #$00
	STA ,U
	LDA #$a0
	STA 40,U
	LEAU 181,U

	LDD -21,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$a3
	STD -21,U
	LDA 20,U
	PSHS U,A
	ANDA #$0F
	ORA #$30
	STA 20,U

	LDU <glb_screen_location_1
	LEAU -160,U

	LDD -1,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$3000
	STD -1,U
	LDA 80,U
	LDB -121,U
	PSHS B,A
	LDA #$a0
	STA 80,U
	LDA 120,U
	PSHS A
	LDA #$10
	STA -121,U
	STA 120,U
	LDD -41,U
	PSHS D
	LDA #$13
	ANDB #$0F
	ORB #$00
	STD -41,U
	LDA -81,U
	LDB 40,U
	PSHS U,B,A
	ANDB #$0F
	ORB #$a0
	STB 40,U
	LDA #$aa
	STA -81,U
	LEAU 280,U

	LDD 79,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$a0a0
	STD 79,U
	LDD 119,U
	PSHS D
	LDA #$00
	ANDB #$0F
	ORB #$10
	STD 119,U
	LDA ,U
	LDB -120,U
	PSHS B,A
	ANDB #$F0
	ORB #$00
	STB -120,U
	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$F0
	ORA #$0a
	STA -40,U
	LDA 40,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA 40,U
	LDA #$1a
	STA ,U
	LEAU 179,U

	LDA -20,U
	LDB 20,U
	PSHS U,B,A
	LDA #$1a
	STA -20,U
	LDA #$33
	STA 20,U
	LEAU ,S
SSAV_Img_SSRing_006_0
	LDS glb_register_s
	RTS
