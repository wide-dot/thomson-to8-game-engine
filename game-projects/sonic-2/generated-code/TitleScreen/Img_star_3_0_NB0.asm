	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_star_3_0
	STS glb_register_s

	LEAS ,Y
	LEAU -160,U

	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA -120,U
	LDA -80,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA -40,U
	LDA ,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA ,U
	LDA 40,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 40,U
	LDA 80,U
	LDB 120,U
	PSHS U,B,A
	LDA #$ab
	STA 80,U
	LDA #$0c
	STA 120,U
	LEAU 280,U

	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$00
	STD -121,U
	LDA -80,U
	PSHS A
	LDA #$0c
	STA -80,U
	LDA -40,U
	LDB ,U
	PSHS B,A
	ANDB #$0F
	ORB #$a0
	STB ,U
	LDA 40,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 40,U
	LDA 80,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 80,U
	LDA 120,U
	PSHS U,A
	ANDA #$0F
	ORA #$c0
	STA 120,U
	LDA #$0b
	STA -40,U
	LEAU 160,U

	LDA ,U
	PSHS U,A
	ANDA #$0F
	ORA #$c0
	STA ,U

	LDU <glb_screen_location_1
	LEAU -1,U

	LDX ,U
	PSHS X
	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$F0
	ORA #$0c
	STA -40,U
	LDA 40,U
	PSHS A
	ANDA #$F0
	ORA #$0c
	STA 40,U
	LDA 80,U
	PSHS U,A
	ANDA #$F0
	ORA #$0b
	STA 80,U
	LDD #$b0bc
	STD ,U
	LEAU ,S
SSAV_Img_star_3_0
	LDS glb_register_s
	RTS
