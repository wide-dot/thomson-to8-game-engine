
	OPT C,CT
adr_fnt_4x6_shd_sel_32_DN0
	LEAU 80,U

	LDA #$f0
	STA 40,U
	LDA #$ff
	STA ,U
	LDA 80,U
	ANDA #$F0
	ORA #$0f
	STA 80,U
	LDA -40,U
	ANDA #$0F
	ORA #$f0
	STA -40,U
	LDA -80,U
	ANDA #$F0
	ORA #$0f
	STA -80,U

	LEAU -$2000+40,U

	LDA 40,U
	ANDA #$0F
	ORA #$f0
	STA 40,U
	LDA -80,U
	ANDA #$0F
	ORA #$f0
	STA -80,U
	CLRA
	STA 80,U
	STA ,U
	LDA #$f0
	STA -40,U
	RTS

