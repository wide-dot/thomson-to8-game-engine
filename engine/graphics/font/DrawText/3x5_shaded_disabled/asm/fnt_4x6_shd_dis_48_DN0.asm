
	OPT C,CT
adr_fnt_4x6_shd_dis_48_DN0
	LEAU 100,U

	LDA 100,U
	ANDA #$F0

	STA 100,U
	LDA #$10
	STA 60,U
	STA 20,U
	LDA #$11
	STA -20,U
	LDA #$10
	STA -60,U
	LDA #$11
	STA -100,U

	LEAU -$2000-100,U
	LDA 120,U
	ANDA #$0F

	STA 120,U
	LDA 80,U
	ANDA #$F0

	STA 80,U
	LDA 40,U
	ANDA #$0F
	ORA #$10
	STA 40,U
	RTS
