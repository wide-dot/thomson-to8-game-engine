
	OPT C,CT
adr_fnt_4x6_shd_sel_36_DN0
	LEAU 100,U

	LDA 100,U
	ANDA #$F0

	STA 100,U
	LDA #$ff
	STA 60,U
	LDA #$f0
	STA 20,U
	STA -20,U
	STA -60,U
	LDA #$ff
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
	ORA #$f0
	STA -80,U
	LDA #$f0
	STA ,U
	STA -40,U
	RTS
