
	OPT C,CT
adr_fnt_4x6_shd_83_DN0
	LEAU 120,U

	LDA 80,U
	ANDA #$F0

	STA 80,U
	LDA ,U
	ANDA #$F0
	ORA #$03
	STA ,U
	LDA -80,U
	ANDA #$F0
	ORA #$03
	STA -80,U
	LDA #$33
	STA 40,U
	STA -40,U

	LEAU -$2000,U

	LDA 80,U
	ANDA #$0F

	STA 80,U
	LDA ,U
	ANDA #$0F
	ORA #$30
	STA ,U
	LDA -80,U
	ANDA #$0F
	ORA #$30
	STA -80,U
	CLRA
	STA 40,U
	STA -40,U
	RTS

