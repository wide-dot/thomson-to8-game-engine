
	OPT C,CT
adr_fnt_4x6_shd_sel_12_DN0
	LEAU 160,U

	LDA 40,U
	ANDA #$F0

	STA 40,U
	LDA ,U
	ANDA #$0F
	ORA #$f0
	STA ,U
	LDA -40,U
	ANDA #$F0
	ORA #$0f
	STA -40,U

	LEAU -$2000,U

	LDA ,U
	ANDA #$0F

	STA ,U
	RTS

