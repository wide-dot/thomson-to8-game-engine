
	OPT C,CT
adr_fnt_4x6_shd_dis_87_DN0
	LEAU 120,U

	LDA 80,U
	ANDA #$F0

	STA 80,U
	LDA -80,U
	ANDA #$0F
	ORA #$10
	STA -80,U
	LDA #$11
	STA 40,U
	STA ,U
	STA -40,U

	LEAU -$2000,U

	LDA #$10
	STA 40,U
	STA ,U
	STA -40,U
	CLRA
	STA 80,U
	LDA -80,U
	ANDA #$0F
	ORA #$10
	STA -80,U
	RTS
