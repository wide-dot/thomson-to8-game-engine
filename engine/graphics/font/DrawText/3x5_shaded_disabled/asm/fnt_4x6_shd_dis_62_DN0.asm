
	OPT C,CT
adr_fnt_4x6_shd_dis_62_DN0
	LDA 80,U
	ANDA #$F0

	STA 80,U
	LDA 40,U
	ANDA #$0F
	ORA #$10
	STA 40,U
	LDA ,U
	ANDA #$F0
	ORA #$01
	STA ,U

	LEAU -$2000,U
	LDA 80,U
	ANDA #$F0

	STA 80,U
	LDA 40,U
	ANDA #$0F
	ORA #$10
	STA 40,U
	RTS
