
	OPT C,CT
adr_fnt_4x6_shd_sel_44_DN0
	LEAU 100,U

	LDA 100,U
	ANDA #$F0

	STA 100,U
	LDA -100,U
	ANDA #$0F
	ORA #$f0
	STA -100,U
	LDA #$ff
	STA 60,U
	LDA #$f0
	STA 20,U
	STA -20,U
	STA -60,U

	LEAU -$2000+80,U

	LDA -20,U
	ANDA #$0F
	ORA #$f0
	STA -20,U
	CLRA
	STA 20,U
	RTS
