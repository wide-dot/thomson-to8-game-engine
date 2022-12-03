
	OPT C,CT
adr_fnt_4x6_shd_sel_02_DN0
	LDA 80,U
	ANDA #$F0

	STA 80,U
	LDA ,U
	ANDA #$0F
	ORA #$f0
	STA ,U
	LDA #$f0
	STA 40,U

	LEAU -$2000,U
	LDA 80,U
	ANDA #$F0

	STA 80,U
	LDA ,U
	ANDA #$0F
	ORA #$f0
	STA ,U
	LDA #$f0
	STA 40,U
	RTS

