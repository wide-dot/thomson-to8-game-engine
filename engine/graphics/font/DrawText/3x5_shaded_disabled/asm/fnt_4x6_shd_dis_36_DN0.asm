
	OPT C,CT
adr_fnt_4x6_shd_dis_36_DN0
	LEAU 100,U

	LDA 100,U
	ANDA #$F0

	STA 100,U
	LDA #$11
	STA 60,U
	LDA #$10
	STA 20,U
	STA -20,U
	STA -60,U
	LDA #$11
	STA -100,U

	LEAU -$2000+20,U

	LDA 80,U
	ANDA #$0F

	STA 80,U
	LDA 40,U
	ANDA #$F0

	STA 40,U
	LDA -80,U
	ANDA #$0F
	ORA #$10
	STA -80,U
	LDA #$10
	STA ,U
	STA -40,U
	RTS
