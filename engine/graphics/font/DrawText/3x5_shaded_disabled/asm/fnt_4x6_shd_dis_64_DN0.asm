
	OPT C,CT
adr_fnt_4x6_shd_dis_64_DN0
	LDA 40,U
	ANDA #$F0
	ORA #$01
	STA 40,U
	LDA ,U
	ANDA #$0F
	ORA #$10
	STA ,U

	LEAU -$2000,U
	LDA 80,U
	ANDA #$0F

	STA 80,U
	RTS

