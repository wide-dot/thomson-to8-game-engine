
	OPT C,CT
adr_fnt_4x6_shd_dis_35_DN0
	LEAU 80,U

	LDA #$10
	STA 40,U
	STA ,U
	LDA 80,U
	ANDA #$F0
	ORA #$01
	STA 80,U
	LDA -40,U
	ANDA #$0F
	ORA #$10
	STA -40,U
	LDA -80,U
	ANDA #$F0
	ORA #$01
	STA -80,U

	LEAU -$2000+20,U

	LDA 60,U
	ANDA #$0F
	ORA #$10
	STA 60,U
	LDA -100,U
	ANDA #$0F
	ORA #$10
	STA -100,U
	CLRA
	STA 100,U
	STA -60,U
	RTS
