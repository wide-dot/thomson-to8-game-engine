	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_076_0
	STS glb_register_s

	LEAS ,Y
	LEAU -399,U

	LDD -41,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -41,U
	LDA ,U
	LDB 40,U
	PSHS U,B,A
	LDA #$a9
	STA ,U
	LDA #$aa
	STA 40,U
	LEAU 199,U

	LDA -119,U
	LDX -40,U
	PSHS X,A
	LDD #$aa9a
	STD -40,U
	STA -119,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -38,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$a9
	STD -80,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$9ca9
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aca9
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 40,U
	LDA 42,U
	STB 42,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$99
	LDX #$eaa9
	PSHU A,X
	LEAU 80,U

	PULU A,X
	PSHS U,X,A
	LDA #$a9
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$a9
	LDX #$aeaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$afaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$afaa
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	LDD #$99ff
	STD 40,U
	LDY 80,U
	PSHS Y,X
	LDB #$cc
	STD 80,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 42,U
	LDA 82,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 82,U
	LDA 122,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 122,U
	LDX 120,U
	PSHS X
	LDD #$aefc
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$afaa
	PSHU A,X
	LEAU 200,U

	LDX -40,U
	PSHS X
	LDD #$a3ee
	STD -40,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDA #$93
	LDX #$feee
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ee
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$ee
	STD 80,U
	LDA 42,U
	STB 42,U
	LDB 82,U
	PSHS B,A
	ANDB #$0F
	ORB #$d0
	STB 82,U
	LDD 120,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$90e0
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$93
	LDX #$eeed
	PSHU A,X
	LEAU 281,U

	LDX -1,U
	LDY -41,U
	PSHS Y,X
	LDD #$eeee
	STD -41,U
	LDD 39,U
	LDX 119,U
	LDY 79,U
	PSHS Y,X,D
	LDD -121,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -121,U
	LDD #$33de
	STD 39,U
	LDD #$3ebd
	STD 79,U
	LDB #$bb
	STD 119,U
	LDB #$e3
	STD -1,U
	LDD -81,U
	PSHS D
	LDA #$ef
	ANDB #$0F
	ORB #$e0
	STD -81,U
	LDA 121,U
	PSHS U,A
	ANDA #$0F
	ORA #$30
	STA 121,U
	LEAU 160,U

	LDX -1,U
	PSHS X
	LDD #$dddd
	STD -1,U
	LDA 1,U
	PSHS U,A
	ANDA #$0F
	ORA #$d0
	STA 1,U

	LDU <glb_screen_location_1
	LEAU -380,U

	LDD 20,U
	PSHS D
	LDA #$9a
	ANDB #$0F
	ORB #$a0
	STD 20,U
	LDD 60,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$a9
	STD 60,U
	LDA -60,U
	LDB -20,U
	PSHS U,B,A
	LDA #$aa
	STA -60,U
	LDA #$9a
	STA -20,U
	LEAU 219,U

	LDX -119,U
	LDY 81,U
	PSHS Y,X
	LDD 121,U
	LDX -79,U
	LDY 41,U
	PSHS Y,X,D
	LDD #$a9aa
	STD -79,U
	LDA #$aa
	STD 81,U
	LDB #$ea
	STD 121,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -40,U
	LDD #$99aa
	STD -119,U
	LDA #$9a
	STD 41,U
	LDA -38,U
	STB -38,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$a9
	LDX #$9aaa
	PSHU A,X
	LEAU 240,U

	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -40,U
	LDA -78,U
	LDB -38,U
	PSHS B,A
	LDA #$ea
	STA -78,U
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDA #$a9
	LDX #$9eea
	PSHU A,X
	LEAU 40,U

	LDA 122,U
	LDX 41,U
	LDY 81,U
	PSHS Y,X,A
	LDD #$9cea
	STD 41,U
	LDB #$ed
	STD 81,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ee
	STD 120,U
	LDA #$cd
	STA 122,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$9eda
	PSHU A,X
	LEAU 261,U

	LDA -59,U
	LDB 100,U
	PSHS B,A
	ANDB #$0F
	ORB #$a0
	STB 100,U
	LDD -101,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$3e
	STD -101,U
	LDD -61,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$cf
	STD -61,U
	LDD -21,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$3e
	STD -21,U
	LDA -19,U
	LDB 20,U
	PSHS B,A
	LDA 60,U
	LDB -99,U
	PSHS U,B,A
	LDA #$e3
	STA -59,U
	LDA #$ce
	STA -99,U
	STA 20,U
	LDA #$a9
	STA 60,U
	LDA #$3d
	STA -19,U
	LEAU 301,U

	LDA -81,U
	LDB -121,U
	PSHS B,A
	LDA 40,U
	LDB 120,U
	PSHS B,A
	LDA #$ee
	STA -81,U
	LDD -1,U
	PSHS D
	LDA #$fe
	ANDB #$0F
	ORB #$e0
	STD -1,U
	STA -121,U
	LDA -41,U
	LDB 80,U
	PSHS B,A
	LDA #$d3
	STA 40,U
	LDA #$bd
	STA 80,U
	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$bb
	STD 38,U
	LDD 78,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$bb
	STD 78,U
	LDD 118,U
	PSHS U,D
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 118,U
	STB 120,U
	LDA #$3e
	STA -41,U
	LEAU ,S
SSAV_Img_sonic_076_0
	LDS glb_register_s
	RTS
