	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSRing_032_0
	STS glb_register_s

	LEAS ,Y
	LEAU -160,U

	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$0a
	STD 80,U
	LDA -121,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -121,U
	LDA 1,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 1,U
	LDA 41,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 41,U
	LDA 121,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA 121,U
	LEAU 280,U

	LDA -119,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -119,U
	LDA 79,U
	PSHS A
	ANDA #$F0
	ORA #$08
	STA 79,U
	LDA 119,U
	PSHS U,A
	ANDA #$F0
	ORA #$09
	STA 119,U
	LEAU 239,U

	LDD -80,U
	PSHS D
	LDA #$9a
	ANDB #$0F
	ORB #$90
	STD -80,U
	LDD -40,U
	PSHS D
	LDA #$00
	ANDB #$0F
	ORB #$00
	STD -40,U
	LDD ,U
	PSHS D
	LDA #$9a
	ANDB #$0F
	ORB #$90
	STD ,U
	LDA 40,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 40,U
	LDA 80,U
	PSHS U,A
	ANDA #$F0
	ORA #$08
	STA 80,U

	LDU <glb_screen_location_1
	LEAU -241,U

	LDA -41,U
	LDB -121,U
	PSHS B,A
	ANDB #$F0
	ORB #$09
	STB -121,U
	LDA -81,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA -81,U
	LDA -1,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA -1,U
	LDA 39,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 39,U
	LDA 41,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA 41,U
	LDA 81,U
	LDB 121,U
	PSHS U,B,A
	LDA #$90
	STA -41,U
	STA 81,U
	LDA #$a0
	STA 121,U
	LEAU 281,U

	LDA -120,U
	LDB -80,U
	PSHS B,A
	LDA #$00
	STA -120,U
	LDA #$a0
	STA -80,U
	LDD -41,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$90
	STD -41,U
	LDA ,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA ,U
	LDA 39,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 39,U
	LDA 79,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 79,U
	LDA 119,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA 119,U
	LEAU 279,U

	LDA 120,U
	LDB 80,U
	PSHS B,A
	LDA 40,U
	LDB -40,U
	PSHS B,A
	LDA -120,U
	LDB 1,U
	PSHS B,A
	ANDB #$0F
	ORB #$a0
	STB 1,U
	LDD -1,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$00
	STD -1,U
	LDA #$a8
	STA -120,U
	STA 120,U
	LDA -80,U
	PSHS U,A
	LDA #$a9
	STA -80,U
	STA 80,U
	LDA #$0a
	STA -40,U
	STA 40,U
	LEAU 240,U

	LDA -80,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -40,U
	LDA ,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA ,U
	LDA 80,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA 80,U
	LEAU ,S
SSAV_Img_SSRing_032_0
	LDS glb_register_s
	RTS
