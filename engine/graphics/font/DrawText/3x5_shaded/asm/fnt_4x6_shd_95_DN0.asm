
	OPT C,CT
adr_fnt_4x6_shd_95_DN0
	LEAU 100,U

	LDA #$33
	STA 60,U
	STA 20,U
	STA -20,U
	STA -60,U
	STA -100,U
	LDA 100,U
	ANDA #$F0

	STA 100,U

	LEAU -$2000,U

	CLRA
	STA 100,U
	LDA -100,U
	ANDA #$0F
	ORA #$30
	STA -100,U
	LDA #$30
	STA 60,U
	STA 20,U
	STA -20,U
	STA -60,U
	RTS
