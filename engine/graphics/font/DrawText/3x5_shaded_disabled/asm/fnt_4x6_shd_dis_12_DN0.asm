
	OPT C,CT
adr_fnt_4x6_shd_dis_12_DN0
	LEAU 160,U

	LDA 40,U
	ANDA #$F0

	STA 40,U
	LDA ,U
	ANDA #$0F
	ORA #$10
	STA ,U
	LDA -40,U
	ANDA #$F0
	ORA #$01
	STA -40,U

	LEAU -$2000,U

	LDA ,U
	ANDA #$0F

	STA ,U
	RTS

