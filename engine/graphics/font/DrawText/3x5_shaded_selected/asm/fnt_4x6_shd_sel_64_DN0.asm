
	OPT C,CT
adr_fnt_4x6_shd_sel_64_DN0
	LDA 40,U
	ANDA #$F0
	ORA #$0f
	STA 40,U
	LDA ,U
	ANDA #$0F
	ORA #$f0
	STA ,U

	LEAU -$2000,U
	LDA 80,U
	ANDA #$0F

	STA 80,U
	RTS

