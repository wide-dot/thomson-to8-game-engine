	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_059_0
	STS glb_register_s

	LEAS ,Y
	LEAU -600,U

	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$eb
	STD -81,U
	LDD -1,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$bb
	STD -1,U
	LDA -120,U
	LDB -40,U
	PSHS B,A
	LDA #$ed
	STA -120,U
	LDA #$eb
	STA -40,U
	LDD 40,U
	PSHS D
	LDA #$bf
	ANDB #$0F
	ORB #$b0
	STD 40,U
	LDA 1,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 1,U
	LDA 81,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 81,U
	LDD 79,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$30f0
	STD 79,U
	LDD 120,U
	PSHS U,D
	ANDA #$0F
	ANDB #$0F
	ADDD #$f030
	STD 120,U
	LEAU 201,U

	LDA -40,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA -40,U
	LDA ,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA ,U
	LDA 40,U
	PSHS U,A
	ANDA #$0F
	ORA #$30
	STA 40,U
	LEAU 199,U

	LDD -79,U
	PSHS D
	LDA #$33
	ANDB #$0F
	ORB #$e0
	STD -79,U
	LDX -40,U
	PSHS X
	LDA -122,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -122,U
	LDA -119,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA -119,U
	LDA -82,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -82,U
	LDA -42,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -42,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -38,U
	LDA -2,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -2,U
	LDD #$cc3c
	STD -40,U
	LDD 38,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$030d
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$bcad
	PSHU A,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$e9
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$bcaa
	PSHU A,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$d9
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$ccda
	PSHU A,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$e9
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$cfda
	PSHU A,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$03e0
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$cfda
	PSHU A,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$eaea
	PSHU A,X
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$fc
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$fc
	STD 79,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$e9
	STD 119,U
	LDX 41,U
	LDY 81,U
	PSHS Y,X
	LDD 121,U
	PSHS D
	LDD #$aaea
	STD 41,U
	LDB #$aa
	STD 81,U
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$9aea
	PSHU A,X
	LEAU 160,U

	PULU A,X
	PSHS U,X,A
	LDA #$c9
	LDX #$9aca
	PSHU A,X
	LEAU 40,U

	LDX 41,U
	LDA #$9a
	STD 41,U
	LDY 81,U
	PSHS Y,X
	LDD 121,U
	PSHS D
	LDD #$aaaa
	STD 81,U
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDX #$9aca
	PSHU B,X
	LEAU 281,U

	LDX -120,U
	PSHS X
	LDD #$aaaa
	STD -120,U
	LDD -80,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$a0a0
	STD -80,U
	LDA -41,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA -41,U
	LDA -39,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -39,U
	LDA ,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA ,U
	LDA 40,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 40,U
	LDA 80,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 80,U
	LDA 120,U
	PSHS U,A
	ANDA #$F0
	ORA #$09
	STA 120,U

	LDU <glb_screen_location_1
	LEAU -600,U

	LDA -121,U
	LDB 80,U
	LDX -41,U
	LDY -1,U
	PSHS Y,X,B,A
	LDD -81,U
	PSHS D
	LDA #$db
	ANDB #$0F
	ORB #$d0
	STD -81,U
	LDX 39,U
	PSHS X
	LDA 120,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 120,U
	LDD 78,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$030e
	STD 78,U
	LDD 118,U
	PSHS U,D
	ANDA #$F0
	ANDB #$F0
	ADDD #$030e
	STD 118,U
	LDD #$debb
	STD 39,U
	LDA #$dd
	STA -121,U
	LDA #$f3
	STA 80,U
	LDA #$db
	STD -1,U
	LDB #$bd
	STD -41,U
	LEAU 239,U

	LDD -81,U
	PSHS D
	LDA #$33
	ANDB #$F0
	ORB #$09
	STD -81,U
	LDD -41,U
	PSHS D
	LDA #$33
	ANDB #$F0
	ORB #$0a
	STD -41,U
	LDA -79,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -79,U
	LDD -1,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$300a
	STD -1,U
	LDD 39,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$300a
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$300a
	STD 79,U
	LDA 1,U
	LDB 41,U
	LDX 81,U
	PSHS U,X,B,A
	LDD #$eeed
	STD 81,U
	STA 1,U
	STA 41,U
	LEAU 239,U

	LDX -118,U
	LDB #$cd
	STD -118,U
	LDY -78,U
	PSHS Y,X
	LDB #$cf
	STD -78,U
	LDD -120,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$300a
	STD -120,U
	LDD -80,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$aa
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$0F
	ORA #$d0
	LDB #$aa
	STD -40,U
	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 4,U
	LDX -38,U
	PSHS X
	LDD #$e3fd
	STD -38,U
	PULU D,X
	PSHS U,X,D
	LDD #$3da9
	LDX #$e3fd
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$3ea9
	LDX #$e9ff
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$33a9
	LDX #$e9ff
	PSHU D,X
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$33
	LDX #$9ef9
	LDY #$ffa9
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$d3
	LDX #$9e99
	LDY #$afa9
	PSHU A,X,Y
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$ae
	STD 40,U
	LDD 81,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$99
	STD 81,U
	LDD 121,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$a9
	STD 121,U
	LDX 42,U
	PSHS X
	LDD #$99aa
	STD 42,U
	LDA 44,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 44,U
	LDD 83,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 83,U
	LDD 123,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 123,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$3d
	LDX #$9399
	LDY #$afa9
	PSHU A,X,Y
	LEAU 282,U

	LDD -121,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0e09
	STD -121,U
	LDX 40,U
	LDY ,U
	PSHS Y,X
	LDD -40,U
	LDX 80,U
	PSHS X,D
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -78,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$9c
	STD -80,U
	LDD 120,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$9a
	STD 120,U
	LDD #$99ae
	STD -40,U
	STD ,U
	LDD #$9a99
	STD 40,U
	STD 80,U
	LDD -119,U
	PSHS U,D
	LDA #$ae
	ANDB #$0F
	ORB #$a0
	STD -119,U
	LEAU 201,U

	LDA -40,U
	PSHS A
	LDA #$9a
	STA -40,U
	LDA ,U
	LDB 40,U
	PSHS U,B,A
	ANDB #$0F
	ORB #$a0
	STB 40,U
	LDA #$aa
	STA ,U
	LEAU ,S
SSAV_Img_sonic_059_0
	LDS glb_register_s
	RTS
