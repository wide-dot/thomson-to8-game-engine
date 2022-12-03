
	OPT C,CT
adr_fnt_4x6_shd_sel_94_DN0
	LDA 80,U
	ANDA #$F0

	STA 80,U
	LDA ,U
	ANDA #$F0
	ORA #$0f
	STA ,U
	LDA #$ff
	STA 40,U

	LEAU -$2000,U
	CLRA
	STA 40,U
	LDA 80,U
	ANDA #$0F

	STA 80,U
	LDA ,U
	ANDA #$0F
	ORA #$f0
	STA ,U
	RTS

