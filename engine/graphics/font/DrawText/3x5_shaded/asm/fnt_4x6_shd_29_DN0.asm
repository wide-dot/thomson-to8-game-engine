
	OPT C,CT
adr_fnt_4x6_shd_29_DN0
	LEAU 100,U

	LDA 60,U
	ANDA #$F0

	STA 60,U
	LDA -20,U
	ANDA #$F0

	STA -20,U
	LDA #$33
	STA 20,U
	STA -60,U

	LEAU -$2000,U

	LDA 20,U
	ANDA #$0F
	ORA #$30
	STA 20,U
	LDA -60,U
	ANDA #$0F
	ORA #$30
	STA -60,U
	CLRA
	STA 60,U
	STA -20,U
	RTS
