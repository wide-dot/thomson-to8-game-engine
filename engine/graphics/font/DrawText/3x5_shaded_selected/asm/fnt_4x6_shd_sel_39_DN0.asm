
	OPT C,CT
adr_fnt_4x6_shd_sel_39_DN0
	LEAU 80,U

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
	LDA #$f0
	STA 40,U
	LDA #$ff
	STA ,U

	LEAU -$2000+20,U

	LDA #$f0
	STA 60,U
	STA 20,U
	CLRA
	STA 100,U
	STA -60,U
	LDA -20,U
	ANDA #$0F
	ORA #$f0
	STA -20,U
	LDA -100,U
	ANDA #$0F
	ORA #$f0
	STA -100,U
	RTS

