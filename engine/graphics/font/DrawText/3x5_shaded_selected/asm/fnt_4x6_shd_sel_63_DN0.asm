
	OPT C,CT
adr_fnt_4x6_shd_sel_63_DN0
	LEAU 180,U

	LDA 20,U
	ANDA #$F0

	STA 20,U
	LDA #$ff
	STA -20,U

	LEAU -$2000,U

	LDA -20,U
	ANDA #$0F
	ORA #$f0
	STA -20,U
	CLRA
	STA 20,U
	RTS

