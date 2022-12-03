
	OPT C,CT
adr_fnt_4x6_shd_dis_14_DN0
	LEAU 160,U

	LDA ,U
	ANDA #$F0
	ORA #$01
	STA ,U

	LEAU -$2000+40,U

	LDA ,U
	ANDA #$0F

	STA ,U
	RTS

