	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_205_0
	STS glb_register_s

	LEAS ,Y
	LEAU -520,U

	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -40,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0aa0
	STD -80,U
	LDA 1,U
	LDB 81,U
	PSHS B,A
	LDA 41,U
	LDB -120,U
	LDX 120,U
	PSHS U,X,B,A
	LDA #$ea
	STA 41,U
	LDA #$c9
	STA 81,U
	LDD #$aa9a
	STD 120,U
	STA -120,U
	STA 1,U
	LEAU 279,U

	LDX -119,U
	LDD #$a9aa
	STD -119,U
	LDY -79,U
	PSHS Y,X
	LDA #$9a
	STD -79,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$9a
	STD -40,U
	LDX -38,U
	PSHS X
	LDA -117,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -117,U
	LDA -77,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -77,U
	LDA 39,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA 39,U
	LDD #$aaa9
	STD -38,U
	PULU X,Y
	PSHS U,Y,X
	LDB #$9a
	LDX #$aea9
	PSHU D,X
	LEAU 41,U

	LDX 41,U
	PSHS X
	LDD #$efaa
	STD 41,U
	LDD 39,U
	PSHS D
	ANDA #$0F
	ORA #$e0
	LDB #$9a
	STD 39,U
	PULU A,X
	PSHS U,X,A
	LDX #$af99
	PSHU B,X
	LEAU 79,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$fe
	LDX #$9aff
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$fe
	LDX #$aaff
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$aacd
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$ea
	LDX #$aacd
	PSHU A,X
	LEAU 40,U

	LDX 41,U
	LDD #$efcc
	STD 41,U
	LDY 81,U
	PSHS Y,X
	LDD #$ccee
	STD 81,U
	LDD 121,U
	PSHS D
	LDD #$ec3e
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$a9
	LDX #$eece
	PSHU A,X
	LEAU 281,U

	LDA -119,U
	STB -119,U
	LDB -40,U
	LDX -81,U
	PSHS X,B,A
	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ec
	STD -121,U
	LDD 40,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$ff
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$bb
	STD 80,U
	LDD #$aaae
	STD -81,U
	LDA #$da
	STA -40,U
	LDA 121,U
	LDB -38,U
	PSHS B,A
	ANDB #$0F
	ORB #$b0
	STB -38,U
	LDA ,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA ,U
	LDA 2,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 2,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 42,U
	LDA 119,U
	PSHS U,A
	ANDA #$F0
	ORA #$0e
	STA 119,U
	LDA #$bd
	STA 121,U
	LEAU 279,U

	LDA -78,U
	LDB -120,U
	PSHS B,A
	LDA #$3e
	STA -120,U
	LDA -118,U
	LDB -38,U
	PSHS B,A
	LDD 120,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0eb0
	STD 120,U
	LDA #$3d
	STA -38,U
	LDA ,U
	LDB 2,U
	PSHS B,A
	ANDB #$0F
	ORB #$30
	STB 2,U
	LDA 40,U
	LDB 80,U
	PSHS B,A
	LDA #$d3
	STA 40,U
	LDA #$b3
	STA -118,U
	LDA -40,U
	LDB -80,U
	PSHS U,B,A
	LDA #$33
	STA -80,U
	STA -78,U
	STA -40,U
	STA ,U
	LDA #$de
	STA 80,U
	LEAU 181,U

	LDD -21,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0db0
	STD -21,U
	LDA 20,U
	PSHS U,A
	ANDA #$0F
	ORA #$d0
	STA 20,U

	LDU <glb_screen_location_1
	LEAU -560,U

	LDA -80,U
	LDB ,U
	LDX 80,U
	PSHS X,B,A
	LDD 40,U
	PSHS D
	LDA #$ae
	ANDB #$0F
	ORB #$a0
	STD 40,U
	STA ,U
	LDA -40,U
	PSHS U,A
	LDD #$acaa
	STD 80,U
	STB -80,U
	STB -40,U
	LEAU 239,U

	LDX -119,U
	LDY -79,U
	PSHS Y,X
	STD -119,U
	STD -79,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -40,U
	LDA -38,U
	STB -38,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$aa
	LDX #$afaa
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$aaea
	PSHU A,X
	LEAU 40,U

	LDA 119,U
	LDB 79,U
	LDX 41,U
	PSHS X,B,A
	LDD 39,U
	PSHS D
	LDA #$fe
	ANDB #$F0
	ORB #$09
	STD 39,U
	LDA #$ee
	STA 119,U
	LDX 81,U
	LDY 121,U
	PSHS Y,X
	LDD #$aafa
	STD 41,U
	STD 81,U
	LDA #$ef
	STA 79,U
	LDD #$ecda
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aafa
	PSHU A,X
	LEAU 199,U

	LDX -38,U
	LDA #$cc
	STD -38,U
	LDY 42,U
	PSHS Y,X
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$9a
	STD -40,U
	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ec
	STD 40,U
	LDD #$ecfd
	STD 42,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$efce
	LDX #$ccea
	PSHU D,X
	LEAU 81,U

	LDD 80,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ae0
	STD 80,U
	LDA 82,U
	LDX 41,U
	PSHS X,A
	LDD #$eede
	STD 41,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$9a
	STD 39,U
	LDA #$3e
	STA 82,U
	PULU A,X
	PSHS U,X,A
	LDX #$3ced
	PSHU B,X
	LEAU 120,U

	LDD 40,U
	PSHS D
	LDA #$9a
	ANDB #$0F
	ORB #$a0
	STD 40,U
	LDA 80,U
	LDB 42,U
	PSHS B,A
	ANDB #$0F
	ORB #$e0
	STB 42,U
	LDA #$9d
	STA 80,U
	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$c3ee
	PSHU A,X
	LEAU 281,U

	LDD -120,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$bb
	STD -120,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$ee
	STD -41,U
	LDD -1,U
	PSHS D
	LDA #$d9
	ANDB #$F0
	ORB #$0e
	STD -1,U
	LDD 39,U
	PSHS D
	LDA #$d9
	ANDB #$F0
	ORB #$0b
	STD 39,U
	LDA 1,U
	LDB -39,U
	LDX -80,U
	PSHS X,B,A
	LDD 79,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$e00b
	STD 79,U
	LDD 119,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$f00d
	STD 119,U
	LDA 41,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 41,U
	LDA 81,U
	PSHS U,A
	ANDA #$0F
	ORA #$d0
	STA 81,U
	LDA #$3d
	STA 1,U
	LDA #$d3
	STA -39,U
	LDD #$afbd
	STD -80,U
	LEAU 259,U

	LDD -100,U
	PSHS D
	LDA #$3e
	ANDB #$F0
	ORB #$0d
	STD -100,U
	LDA -60,U
	PSHS A
	LDA #$ef
	STA -60,U
	LDA -20,U
	LDB 20,U
	PSHS B,A
	LDA 60,U
	LDB 100,U
	PSHS U,B,A
	LDA #$3b
	STA -20,U
	STA 20,U
	STA 60,U
	LDA #$dd
	STA 100,U
	LEAU ,S
SSAV_Img_sonic_205_0
	LDS glb_register_s
	RTS
