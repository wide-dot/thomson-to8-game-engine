
	OPT C,CT
adr_fnt_4x6_shd_75_DN0
	LEAU 100,U

	LDA #$30
	STA 60,U
	LDA #$33
	STA 20,U
	STA -20,U
	LDA #$30
	STA -60,U
	LDA 100,U
	ANDA #$F0

	STA 100,U
	LDA -100,U
	ANDA #$0F
	ORA #$30
	STA -100,U

	LEAU -$2000+20,U

	LDA 80,U
	ANDA #$F0

	STA 80,U
	LDA 40,U
	ANDA #$0F
	ORA #$30
	STA 40,U
	LDA ,U
	ANDA #$0F

	STA ,U
	LDA -40,U
	ANDA #$F0

	STA -40,U
	LDA -80,U
	ANDA #$0F
	ORA #$30
	STA -80,U
	RTS
