	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SegaSonic_12_0
	STS glb_register_s

	LEAS ,Y
	LEAU -1082,U

	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -40,U
	LDD -78,U
	PSHS D
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -78,U
	LDD -38,U
	PSHS D
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$cccc
	LDX #$ccdd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$ccdd
	PSHU D,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDX #$dddd
	PSHU B,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDX #$dddd
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$67dd
	PSHU B,X
	LEAU 40,U

	LDX 40,U
	LDY 80,U
	PSHS Y,X
	LDA 122,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 122,U
	LDD #$c67d
	STD 40,U
	STD 80,U
	LDX 120,U
	PSHS X
	LDA #$cc
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$67dd
	PSHU A,X
	LEAU 200,U

	LDX -40,U
	PSHS X
	STD -40,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$cc
	LDX #$dcdd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$dcdd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$1c1c
	LDX #$dcdd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$dcdd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$0ccc
	LDX #$dcdd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$dcdd
	PSHU D,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$0c
	LDX #$ccdd
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$0c
	LDX #$ccdd
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$0c
	LDX #$ccdd
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	LDY 80,U
	PSHS Y,X
	LDD #$cccd
	STD 40,U
	STD 80,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 42,U
	LDA 82,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 82,U
	PULU A,X
	PSHS U,X,A
	LDA #$0c
	LDX #$ccdd
	PSHU A,X
	LEAU 120,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$00dd
	LDX #$dccc
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$dccc
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$66
	LDX #$dd66
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$dd66
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$0677
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$0677
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$d0
	LDX #$0004
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$0004
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$7741
	LDX #$0007
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$0007
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$2221
	LDX #$0014
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$0014
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$111d
	PSHU D,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	LDA #$11
	ANDB #$F0
	ORB #$07
	STD 40,U
	LDD 80,U
	PSHS D
	LDA #$11
	ANDB #$F0
	ORB #$07
	STD 80,U
	LDD 120,U
	PSHS D
	LDA #$12
	ANDB #$F0
	ORB #$06
	STD 120,U
	LDX 42,U
	LDY 82,U
	PSHS Y,X
	LDD #$11dd
	STD 42,U
	STD 82,U
	LDD 122,U
	PSHS D
	LDD #$77cd
	STD 122,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$2221
	LDX #$111d
	PSHU D,X
	LEAU 201,U

	LDD -41,U
	PSHS D
	LDA #$12
	ANDB #$F0
	ORB #$06
	STD -41,U
	LDX -39,U
	PSHS X
	LDD #$77cd
	STD -39,U
	PULU A,X
	PSHS U,X,A
	LDA #$d7
	LDX #$7cc3
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$d7
	LDX #$7cc3
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$dd
	LDX #$7ccc
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$dd
	LDX #$7ccc
	PSHU A,X
	LEAU 39,U

	LDA 3,U
	PSHS A
	ANDA #$F0
	ORA #$0c
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$11
	LDX #$33cc
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$F0
	ORA #$0c
	STA 3,U
	LDD 120,U
	PSHS D
	LDA #$41
	ANDB #$0F
	ORB #$30
	STD 120,U
	LDA 40,U
	LDB 80,U
	PSHS B,A
	LDA #$11
	STA 40,U
	STA 80,U
	PULU A,X
	PSHS U,X,A
	LDA #$11
	LDX #$33cc
	PSHU A,X
	LEAU 280,U

	LDA ,U
	LDB 40,U
	PSHS B,A
	LDD -120,U
	PSHS D
	LDA #$41
	ANDB #$0F
	ORB #$30
	STD -120,U
	LDD -80,U
	PSHS D
	LDA #$41
	ANDB #$0F
	ORB #$30
	STD -80,U
	LDD -40,U
	PSHS D
	LDA #$41
	ANDB #$0F
	ORB #$30
	STD -40,U
	STA ,U
	STA 40,U
	LDA 80,U
	LDB 120,U
	PSHS U,B,A
	LDA #$43
	STA 80,U
	STA 120,U
	LEAU 281,U

	LDA -38,U
	LDB -81,U
	LDX 41,U
	LDY 121,U
	PSHS Y,X,B,A
	LDA -41,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA -41,U
	LDA -1,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA -1,U
	LDA 2,U
	LDB -121,U
	LDX 81,U
	PSHS U,X,B,A
	LDA #$43
	STA -121,U
	STA -81,U
	LDD #$4444
	STD 41,U
	STD 81,U
	STD 121,U
	STA -38,U
	STA 2,U
	LEAU 202,U

	LDA ,U
	LDB 40,U
	LDX -41,U
	PSHS X,B,A
	LDD #$4444
	STD -41,U
	LDD -2,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$44
	STD -2,U
	LDD 38,U
	PSHS U,D
	ANDA #$F0
	ORA #$04
	LDB #$44
	STD 38,U
	STB ,U
	STB 40,U

	LDU <glb_screen_location_1
	LEAU -1162,U

	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$ccdd
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$ccdd
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$dddd
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	LDY 80,U
	PSHS Y,X
	LDD 120,U
	PSHS D
	LDD #$c6dd
	STD 40,U
	STD 80,U
	LDA #$66
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$dddd
	PSHU A,X
	LEAU 280,U

	LDX -120,U
	LDA #$66
	STD -120,U
	LDY -80,U
	PSHS Y,X
	LDD -40,U
	PSHS D
	LDD #$c7cc
	STD -80,U
	STD -40,U
	PULU A,X
	PSHS U,X,A
	LDX #$cddd
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$cddd
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$cdcc
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$cdcc
	PSHU B,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$cccd
	LDX #$ccdd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$ccdd
	PSHU D,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$cddd
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$cddd
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$dddd
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	LDY 80,U
	PSHS Y,X
	LDD 120,U
	PSHS D
	LDD #$ccdd
	STD 40,U
	STD 80,U
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$dddd
	PSHU A,X
	LEAU 200,U

	LDX -40,U
	PSHS X
	STD -40,U
	PULU A,X
	PSHS U,X,A
	LDA #$7c
	LDX #$ddcc
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$7c
	LDX #$ddcc
	PSHU A,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$67
	LDX #$d667
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$d667
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$00
	LDX #$6176
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$6176
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$7d12
	LDX #$2146
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$2146
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$4400
	LDX #$1167
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$1167
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$22
	LDX #$117c
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$117c
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$1211
	LDX #$12dd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$12dd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$21
	LDX #$1ddd
	PSHU D,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$0F
	ORA #$20
	LDB #$77
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$0F
	ORA #$20
	LDB #$77
	STD 80,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$66
	STD 120,U
	LDX 42,U
	LDY 82,U
	PSHS Y,X
	LDD #$dcdd
	STD 42,U
	STD 82,U
	LDD 122,U
	PSHS D
	LDA #$cc
	ANDB #$F0
	ORB #$0c
	STD 122,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$2111
	LDX #$1ddd
	PSHU D,X
	LEAU 200,U

	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$66
	STD -40,U
	LDD -38,U
	PSHS D
	LDA #$cc
	ANDB #$F0
	ORB #$0c
	STD -38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$dd77
	LDX #$cccc
	PSHU D,X
	LEAU 40,U

	LDA 43,U
	LDX 40,U
	PSHS X,A
	LDA 83,U
	LDB 120,U
	LDX 80,U
	PSHS X,B,A
	LDA #$c3
	STA 43,U
	STA 83,U
	LDA #$13
	STA 120,U
	LDD #$dd3c
	STD 40,U
	STD 80,U
	PULU X,Y
	PSHS U,Y,X
	LDB #$77
	LDX #$cccc
	PSHU D,X
	LEAU 280,U

	LDA -120,U
	LDB -80,U
	PSHS B,A
	LDA -40,U
	LDB ,U
	PSHS B,A
	LDA 40,U
	PSHS A
	LDA #$11
	STA -80,U
	STA -40,U
	STA ,U
	STA 40,U
	LDA 80,U
	LDB 120,U
	PSHS U,B,A
	LDA #$13
	STA -120,U
	STA 80,U
	STA 120,U
	LEAU 202,U

	LDA 41,U
	LDB -42,U
	PSHS B,A
	ANDB #$0F
	ORB #$30
	STB -42,U
	LDA -39,U
	PSHS A
	ANDA #$F0
	ORA #$04
	STA -39,U
	LDA -2,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA -2,U
	LDA 1,U
	PSHS U,A
	ANDA #$F0
	ORA #$04
	STA 1,U
	LDA #$44
	STA 41,U
	LEAU 199,U

	LDD -79,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$44
	STD -79,U
	LDD -39,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$44
	STD -39,U
	LDA -118,U
	STB -118,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$44
	LDX #$4444
	PSHU A,X
	LEAU 40,U

	LDX 41,U
	LDY 81,U
	PSHS Y,X
	LDD 120,U
	PSHS D
	LDD #$4444
	STD 41,U
	STD 81,U
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDX #$4444
	PSHU B,X
	LEAU 160,U

	LDX ,U
	PSHS U,X
	LDD #$4444
	STD ,U
	LEAU ,S
SSAV_Img_SegaSonic_12_0
	LDS glb_register_s
	RTS
