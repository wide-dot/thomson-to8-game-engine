	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_045_0
	STS glb_register_s

	LEAS ,Y
	LEAU -499,U

	LDD -61,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -61,U
	LDD 19,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$9a
	STD 19,U
	LDX -21,U
	LDD #$99aa
	STD -21,U
	LDY 60,U
	PSHS Y,X
	LDA #$ec
	STD 60,U
	LDA 21,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA 21,U
	LEAU 219,U

	LDX -119,U
	LDD #$9caa
	STD -119,U
	LDY -79,U
	PSHS Y,X
	LDA #$9e
	STD -79,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD -40,U
	LDA -38,U
	STB -38,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$9a
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aaea
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD 40,U
	LDX 81,U
	LDD #$aafd
	STD 81,U
	LDY 121,U
	PSHS Y,X
	LDA #$9a
	STD 121,U
	LDA 42,U
	STB 42,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$99
	LDX #$aafa
	PSHU A,X
	LEAU 160,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$9aff
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$9efc
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$9ecc
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$3e
	LDX #$f9ce
	PSHU A,X
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$3e
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$9e
	STD 79,U
	LDD 41,U
	PSHS D
	LDA #$ee
	ANDB #$0F
	ORB #$b0
	STD 41,U
	LDX 81,U
	PSHS X
	LDD #$eebb
	STD 81,U
	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$e3e3
	PSHU A,X
	LEAU 119,U

	LDX 40,U
	PSHS X
	LDD #$df9a
	STD 40,U
	LDD 42,U
	PSHS D
	ANDA #$0F
	ORA #$c0
	LDB #$bd
	STD 42,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$db99
	LDX #$eeb3
	PSHU D,X
	LEAU 80,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$bfda
	LDX #$e93d
	PSHU D,X
	LEAU 40,U

	LDA 80,U
	LDB 120,U
	LDX 42,U
	PSHS X,B,A
	LDD 40,U
	PSHS D
	LDA #$be
	ANDB #$0F
	ORB #$a0
	STD 40,U
	STA 80,U
	LDD #$d933
	STD 42,U
	LDD 82,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$d3
	STD 82,U
	LDD 122,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$d3
	STD 122,U
	LDA #$bb
	STA 120,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$beaa
	LDX #$9933
	PSHU D,X
	LEAU 281,U

	LDA -121,U
	LDB 120,U
	PSHS B,A
	LDD -79,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0d30
	STD -79,U
	LDA #$eb
	STA -121,U
	LDA -41,U
	LDB -38,U
	PSHS B,A
	ANDB #$0F
	ORB #$30
	STB -38,U
	LDA -1,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA -1,U
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
	LDA 82,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 82,U
	LDD -119,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$d3
	STD -119,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$33
	STD 39,U
	LDA 80,U
	STB 80,U
	STB 120,U
	LDB -81,U
	PSHS U,B,A
	LDA #$df
	STA -41,U
	LDA #$de
	STA -81,U
	LEAU 160,U

	LDD ,U
	PSHS U,D
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD ,U

	LDU <glb_screen_location_1
	LEAU -439,U

	LDX 119,U
	LDY -41,U
	PSHS Y,X
	LDD -1,U
	LDX -81,U
	PSHS X,D
	LDA 1,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 1,U
	LDA 41,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 41,U
	LDA 81,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 81,U
	LDA 121,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 121,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$ca
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 79,U
	LDD #$a9aa
	STD 119,U
	LDA #$aa
	STD -81,U
	LDA #$99
	STD -41,U
	STD -1,U
	LDD -121,U
	PSHS U,D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -121,U
	LEAU 240,U

	LDD -40,U
	PSHS D
	LDA #$af
	ANDB #$0F
	ORB #$a0
	STD -40,U
	LDA -79,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -79,U
	LDA 1,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 1,U
	LDA 41,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 41,U
	LDA 81,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 81,U
	LDD -42,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$a9
	STD -42,U
	LDX 39,U
	LDY -1,U
	PSHS Y,X
	LDD -81,U
	LDX 79,U
	PSHS U,X,D
	LDD #$a9ae
	STD -81,U
	LDB #$af
	STD -1,U
	LDA #$99
	STD 39,U
	STD 79,U
	LEAU 238,U

	LDA 122,U
	LDB 42,U
	LDX -79,U
	PSHS X,B,A
	LDD -119,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$af
	STD -119,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$99
	STD -40,U
	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$fe
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ff
	STD 80,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ff
	STD 120,U
	LDA 82,U
	LDB -117,U
	PSHS B,A
	ANDB #$0F
	ORB #$d0
	STB -117,U
	LDA -77,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -77,U
	LDA #$ee
	STA 82,U
	LDA #$eb
	STA 122,U
	LDD #$a9fa
	STD -79,U
	LDD -38,U
	PSHS D
	LDA #$cf
	ANDB #$0F
	ORB #$d0
	STD -38,U
	LDA #$cc
	STA 42,U
	PULU A,X
	PSHS U,X,A
	LDA #$ac
	LDX #$cfcc
	PSHU A,X
	LEAU 160,U

	PULU A,X
	PSHS U,X,A
	LDA #$b9
	LDX #$eeee
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	LDD #$a9ee
	STD 40,U
	LDY 80,U
	PSHS Y,X
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 42,U
	LDD #$aaac
	STD 80,U
	LDX 120,U
	PSHS X
	LDD #$daae
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$f9
	LDX #$eeee
	PSHU A,X
	LEAU 160,U

	LDA 42,U
	LDB 40,U
	PSHS B,A
	ANDB #$0F
	ORB #$b0
	STB 40,U
	LDA 80,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 80,U
	LDA 120,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 120,U
	LDA 82,U
	LDB 122,U
	PSHS B,A
	LDA #$e3
	STA 42,U
	STA 82,U
	STA 122,U
	PULU A,X
	PSHS U,X,A
	LDA #$ed
	LDX #$aae3
	PSHU A,X
	LEAU 281,U

	LDA -79,U
	LDB -39,U
	PSHS B,A
	LDA 120,U
	LDB -119,U
	LDX 39,U
	PSHS X,B,A
	LDA -81,U
	LDB -1,U
	PSHS B,A
	LDD 79,U
	PSHS D
	LDA #$d3
	ANDB #$0F
	ORB #$30
	STD 79,U
	LDA #$e3
	STA -119,U
	LDA #$f3
	STA -81,U
	LDA #$d3
	STA -79,U
	STA -39,U
	LDA -41,U
	LDB -121,U
	PSHS B,A
	ANDB #$0F
	ORB #$f0
	STB -121,U
	LDA 1,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 1,U
	LDA 41,U
	PSHS U,A
	ANDA #$F0
	ORA #$0d
	STA 41,U
	LDD #$b333
	STD 39,U
	STB 120,U
	STA -41,U
	STA -1,U
	LEAU ,S
SSAV_Img_sonic_045_0
	LDS glb_register_s
	RTS
