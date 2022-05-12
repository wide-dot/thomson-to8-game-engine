	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSRing_003_0
	STS glb_register_s

	LEAS ,Y
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$10
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$10
	STD -41,U
	LDD -1,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$1a
	STD -1,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$1a
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$01
	LDB #$1a
	STD 79,U
	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$00
	STA -120,U
	LDA 120,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA 120,U

	LDU <glb_screen_location_1
	LEAU -141,U

	LDA -20,U
	LDB 20,U
	PSHS U,B,A
	LDA #$a0
	STA -20,U
	LDA #$11
	STA 20,U
	LEAU 280,U

	LDA -20,U
	LDB 20,U
	PSHS U,B,A
	LDA #$01
	STA -20,U
	LDA #$33
	STA 20,U
	LEAU ,S
SSAV_Img_SSRing_003_0
	LDS glb_register_s
	RTS

