
	OPT C,CT
adr_fnt_4x6_shd_dis_68_DN0
	LEAU 100,U

	LDA 60,U
	ANDA #$F0
	ORA #$01
	STA 60,U
	LDA -20,U
	ANDA #$0F
	ORA #$10
	STA -20,U
	LDA -60,U
	ANDA #$F0
	ORA #$01
	STA -60,U
	LDA #$10
	STA 20,U

	LEAU -$2000,U

	CLRA
	STA 100,U
	LDA #$10
	STA 60,U
	STA 20,U
	STA -20,U
	STA -60,U
	LDA -100,U
	ANDA #$0F
	ORA #$10
	STA -100,U
	RTS
