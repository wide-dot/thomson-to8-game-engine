	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_017_0
	STS glb_register_s

	LEAS ,Y
	LEAU -679,U

	LDD -81,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -81,U
	LDA -121,U
	PSHS A
	ANDA #$F0
	ORA #$0a
	STA -121,U
	LDA -39,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -39,U
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
	ORA #$90
	STA 81,U
	LDA 121,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 121,U
	LDX -41,U
	LDD #$aaaa
	STD -41,U
	LDY -1,U
	PSHS Y,X
	LDA #$99
	STD -1,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$9a
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$ca
	STD 79,U
	LDD 119,U
	PSHS U,D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 119,U
	LEAU 260,U

	LDX -21,U
	LDY 99,U
	PSHS Y,X
	LDD -101,U
	LDX 19,U
	LDY -61,U
	PSHS Y,X,D
	LDD 58,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 58,U
	LDD 60,U
	PSHS D
	LDA #$af
	ANDB #$0F
	ORB #$a0
	STD 60,U
	LDA -99,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -99,U
	LDA -59,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -59,U
	LDA -19,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -19,U
	LDA 21,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 21,U
	LDA 101,U
	PSHS U,A
	ANDA #$0F
	ORA #$d0
	STA 101,U
	LDD #$a9aa
	STD -101,U
	LDB #$ae
	STD -61,U
	LDD #$99af
	STD -21,U
	STD 19,U
	STD 99,U
	LEAU 258,U

	LDX -79,U
	LDD #$a9fa
	STD -79,U
	LDY -39,U
	PSHS Y,X
	LDB #$cf
	STD -39,U
	LDA -117,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -117,U
	LDA -77,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA -77,U
	LDA -37,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -37,U
	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 3,U
	LDD -119,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$af
	STD -119,U
	PULU A,X
	PSHS U,X,A
	LDA #$fe
	LDX #$c9cc
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$ff
	LDX #$ecec
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	LDA #$fe
	ANDB #$F0
	ORB #$09
	STD 40,U
	LDD 42,U
	PSHS D
	LDA #$dd
	ANDB #$F0
	ORB #$0e
	STD 42,U
	LDD 80,U
	PSHS D
	LDA #$fe
	ANDB #$F0
	ORB #$09
	STD 80,U
	LDX 82,U
	PSHS X
	LDA 3,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA 3,U
	LDD #$e3ee
	STD 82,U
	PULU A,X
	PSHS U,X,A
	LDA #$ff
	LDX #$9ede
	PSHU A,X
	LEAU 120,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$eea9
	LDX #$c33e
	PSHU D,X
	LEAU 40,U

	LDA 82,U
	LDX 41,U
	PSHS X,A
	LDD #$9dc3
	STD 41,U
	LDA #$aa
	STA 82,U
	LDD 121,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$a9
	STD 121,U
	LDA 84,U
	LDB 124,U
	PSHS B,A
	LDA #$b3
	STA 84,U
	LDA #$bd
	STA 124,U
	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$adc3
	PSHU A,X
	LEAU 282,U

	LDD -79,U
	PSHS D
	LDA #$fe
	ANDB #$0F
	ORB #$30
	STD -79,U
	LDA 81,U
	LDB 1,U
	PSHS B,A
	LDA 38,U
	LDB 41,U
	PSHS B,A
	LDD -121,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0d90
	STD -121,U
	LDA #$bd
	STA 41,U
	LDA -39,U
	LDB 121,U
	PSHS B,A
	LDA -81,U
	LDB -118,U
	PSHS B,A
	ANDB #$0F
	ORB #$d0
	STB -118,U
	LDA -41,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -41,U
	LDA -2,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -2,U
	LDA #$be
	STA 1,U
	LDA #$b3
	STA 81,U
	LDA 118,U
	LDB 78,U
	PSHS U,B,A
	LDA #$3e
	STA -39,U
	LDA #$ee
	STA 78,U
	STA 118,U
	LDA #$d9
	STA -81,U
	LDA #$d3
	STA 38,U
	STA 121,U
	LEAU 238,U

	LDA -77,U
	LDB -37,U
	PSHS B,A
	ANDB #$0F
	ORB #$d0
	STB -37,U
	LDA 80,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 80,U
	LDA ,U
	LDB -40,U
	PSHS B,A
	LDA 40,U
	LDB -80,U
	PSHS U,B,A
	LDA #$33
	STA 40,U
	LDA #$3d
	STA -77,U
	LDA #$bb
	STA -40,U
	LDA #$b3
	STA ,U
	LDA #$3e
	STA -80,U

	LDU <glb_screen_location_1
	LEAU -700,U

	LDA -100,U
	LDX -21,U
	LDY 60,U
	PSHS Y,X,A
	LDD #$99a9
	STD -21,U
	LDA 21,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 21,U
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
	LDB #$ac
	STD 19,U
	LDX 100,U
	PSHS U,X
	LDD #$9caa
	STD 60,U
	STD 100,U
	STB -100,U
	LEAU 259,U

	LDX -119,U
	LDA #$9e
	STD -119,U
	LDY -79,U
	PSHS Y,X
	LDA #$aa
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
	LDX #$aaea
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aafa
	PSHU A,X
	LEAU 40,U

	LDX 41,U
	LDY 81,U
	PSHS Y,X
	LDD 121,U
	PSHS D
	LDD #$aafd
	STD 41,U
	LDA #$9a
	STD 81,U
	LDB #$ff
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aafd
	PSHU A,X
	LEAU 200,U

	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$9e
	STD -40,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$3e
	STD 39,U
	LDA -38,U
	PSHS A
	LDA #$fc
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ec
	LDX #$99cc
	PSHU A,X
	LEAU 41,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0f
	LDB #$e9
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDX #$ceee
	PSHU B,X
	LEAU 40,U

	LDA 40,U
	PSHS A
	STB 40,U
	LDD 38,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0fe0
	STD 38,U
	LDD 78,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0fe0
	STD 78,U
	LDA 42,U
	LDB 80,U
	PSHS B,A
	LDA #$3a
	STA 80,U
	LDA 82,U
	LDB 118,U
	PSHS B,A
	ANDB #$F0
	ORB #$0e
	STB 118,U
	LDA #$ee
	STA 42,U
	STA 82,U
	PULU A,X
	PSHS U,X,A
	LDA #$c9
	LDX #$e3ee
	PSHU A,X
	LEAU 120,U

	PULU A,X
	PSHS U,X,A
	LDA #$9e
	LDX #$eeee
	PSHU A,X
	LEAU 40,U

	LDA 40,U
	LDX 120,U
	PSHS X,A
	LDA #$9e
	STA 40,U
	LDD #$da9a
	STD 120,U
	LDA 122,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA 122,U
	LDD 80,U
	PSHS D
	LDA #$da
	ANDB #$0F
	ORB #$a0
	STD 80,U
	PULU A,X
	PSHS U,X,A
	LDA #$9e
	LDX #$33ee
	PSHU A,X
	LEAU 281,U

	LDD -121,U
	PSHS D
	LDA #$9d
	ANDB #$F0
	ORB #$09
	STD -121,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$bd
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$d3
	STD -40,U
	LDD ,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$33
	STD ,U
	LDA -2,U
	LDB -119,U
	PSHS B,A
	LDA 78,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 78,U
	LDA 120,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 120,U
	LDA 38,U
	LDB -42,U
	PSHS B,A
	LDA #$ee
	STA 38,U
	LDA #$ed
	STA -42,U
	LDD 40,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$03d0
	STD 80,U
	LDD 117,U
	PSHS U,D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0db0
	STD 117,U
	LDA #$bb
	STA -119,U
	LDA #$e9
	STA -2,U
	LEAU 277,U

	LDD -120,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0de0
	STD -120,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$03e0
	STD -80,U
	LDA ,U
	LDB -117,U
	PSHS B,A
	ANDB #$F0
	ORB #$0d
	STB -117,U
	LDA -40,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -40,U
	LDA 120,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LDA 40,U
	LDB 80,U
	PSHS U,B,A
	LDA #$d3
	STA ,U
	STA 80,U
	LDA #$db
	STA 40,U
	LEAU ,S
SSAV_Img_sonic_017_0
	LDS glb_register_s
	RTS
