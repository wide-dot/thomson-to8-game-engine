	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_040_0
	STS glb_register_s

	LEAS ,Y
	LEAU -600,U

	LDA -120,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -120,U
	LDA -40,U
	LDB 40,U
	PSHS B,A
	LDA ,U
	LDB 80,U
	PSHS B,A
	LDA 120,U
	LDB -80,U
	PSHS U,B,A
	LDA #$ef
	STA 80,U
	STA 120,U
	LDA #$bc
	STA ,U
	STA 40,U
	LDA #$3c
	STA -40,U
	LDA #$db
	STA -80,U
	LEAU 280,U

	LDX 120,U
	LDY 80,U
	PSHS Y,X
	LDD -40,U
	PSHS D
	LDA #$bf
	ANDB #$F0
	ORB #$0e
	STD -40,U
	LDD ,U
	PSHS D
	LDA #$be
	ANDB #$F0
	ORB #$0e
	STD ,U
	LDA -120,U
	LDB -42,U
	PSHS B,A
	ANDB #$F0
	ORB #$0d
	STB -42,U
	LDA -2,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -2,U
	LDA 38,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 38,U
	LDA 78,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 78,U
	LDA 118,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA 118,U
	LDD #$ddee
	STD 120,U
	LDA -80,U
	LDX 40,U
	PSHS U,X,A
	LDA #$bb
	STA -120,U
	LDA #$3e
	STD 40,U
	LDB #$3e
	STD 80,U
	LDA #$b3
	STA -80,U
	LEAU 280,U

	LDD -120,U
	PSHS D
	LDA #$dd
	ANDB #$F0
	ORB #$0e
	STD -120,U
	LDD -80,U
	PSHS D
	LDA #$9a
	ANDB #$F0
	ORB #$03
	STD -80,U
	LDA -122,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA -122,U
	LDA -82,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -82,U
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA -78,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -38,U
	LDD -42,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$03f0
	STD -42,U
	LDX -40,U
	PSHS X
	LDD #$9a3c
	STD -40,U
	LDD -2,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$aa
	STD -2,U
	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$dd
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$9e
	LDX #$ecfd
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
	LDA #$9e
	LDX #$ecaa
	PSHU A,X
	LEAU 40,U

	LDA 38,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$ccda
	PSHU A,X
	LEAU 40,U

	LDA 38,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$d3
	LDX #$cfda
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$93
	LDX #$cfda
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$93
	LDX #$eaea
	PSHU A,X
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ec
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$3c
	STD 79,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$e9
	STD 119,U
	LDX 41,U
	LDY 81,U
	PSHS Y,X
	LDA 43,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 43,U
	LDD #$aaea
	STD 41,U
	LDB #$aa
	STD 81,U
	LDX 121,U
	PSHS X
	LDA #$9a
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$ae
	LDX #$9aea
	PSHU A,X
	LEAU 281,U

	LDA 121,U
	LDX ,U
	PSHS X,A
	LDD -122,U
	PSHS D
	ANDA #$F0
	ORA #$0f
	LDB #$e9
	STD -122,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD 119,U
	LDX 40,U
	LDY 80,U
	PSHS Y,X
	LDD #$aa9a
	STD 40,U
	STD 80,U
	LDD -80,U
	LDX -120,U
	LDY -40,U
	PSHS Y,X,D
	LDD #$9aca
	STD -80,U
	STD -40,U
	STD ,U
	LDB #$aa
	STD -120,U
	LDA -82,U
	PSHS A
	ANDA #$F0
	ORA #$0f
	STA -82,U
	LDA -42,U
	PSHS U,A
	ANDA #$F0
	ORA #$0e
	STA -42,U
	STB 121,U
	LEAU 221,U

	LDA -60,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -60,U
	LDA -20,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -20,U
	LDA 59,U
	PSHS U,A
	ANDA #$F0
	ORA #$09
	STA 59,U

	LDU <glb_screen_location_1
	LEAU -440,U

	LDD -2,U
	PSHS D
	LDA #$db
	ANDB #$F0
	ORB #$0b
	STD -2,U
	LDD 38,U
	PSHS D
	LDA #$3b
	ANDB #$F0
	ORB #$0b
	STD 38,U
	LDA -121,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -121,U
	LDA -81,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -81,U
	LDA -41,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -41,U
	LDA 81,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 81,U
	LDX 78,U
	LDY 118,U
	PSHS Y,X
	LDD #$3bdb
	STD 78,U
	STD 118,U
	LDD 120,U
	PSHS U,D
	ANDA #$0F
	ORA #$a0
	LDB #$ee
	STD 120,U
	LEAU 199,U

	LDD -41,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$d3
	STD -41,U
	LDD -1,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$d3
	STD -1,U
	LDX -39,U
	LDY 1,U
	PSHS Y,X
	LDD 39,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$e00d
	STD 39,U
	LDD #$aaee
	STD -39,U
	LDA #$da
	STD 1,U
	LDX 41,U
	PSHS U,X
	LDA #$9a
	STD 41,U
	LEAU 199,U

	LDD -118,U
	PSHS D
	LDA #$a3
	ANDB #$0F
	ORB #$e0
	STD -118,U
	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA -120,U
	LDA -80,U
	LDB -40,U
	LDX -78,U
	LDY -38,U
	PSHS Y,X,B,A
	LDD #$c3ed
	STD -78,U
	LDD #$cecd
	STD -38,U
	LDA #$3e
	STA -80,U
	STA -40,U
	PULU X,Y
	PSHS U,Y,X
	LDB #$99
	LDX #$cecf
	PSHU D,X
	LEAU 40,U

	LDA 40,U
	LDB 80,U
	LDX 42,U
	LDY 122,U
	PSHS Y,X,B,A
	LDD 82,U
	PSHS D
	LDD #$c9ff
	STD 82,U
	STD 122,U
	LDD 120,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$d009
	STD 120,U
	LDA 44,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 44,U
	LDA 84,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 84,U
	LDA 124,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 124,U
	LDD #$adfd
	STD 42,U
	LDA #$3e
	STA 40,U
	STA 80,U
	PULU X,Y
	PSHS U,Y,X
	LDB #$dd
	LDX #$edfd
	PSHU D,X
	LEAU 161,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$9ac9
	LDX #$ffa9
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$ee99
	LDX #$afa9
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$afa9
	PSHU D,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$fe
	LDX #$99aa
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$fe
	LDX #$a9aa
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	LDA #$ff
	ANDB #$F0
	ORB #$09
	STD 40,U
	LDD 42,U
	PSHS D
	LDA #$ae
	ANDB #$0F
	ORB #$a0
	STD 42,U
	LDD 80,U
	PSHS D
	LDA #$fe
	ANDB #$F0
	ORB #$09
	STD 80,U
	LDD 82,U
	PSHS D
	LDA #$ae
	ANDB #$0F
	ORB #$a0
	STD 82,U
	LDD 122,U
	PSHS D
	LDA #$ae
	ANDB #$0F
	ORB #$a0
	STD 122,U
	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	LDD 120,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$e009
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$ff
	LDX #$a9aa
	PSHU A,X
	LEAU 282,U

	LDA 80,U
	LDB ,U
	LDX -41,U
	LDY -121,U
	PSHS Y,X,B,A
	LDD -81,U
	PSHS D
	LDA 40,U
	LDB 120,U
	PSHS U,B,A
	ANDB #$0F
	ORB #$a0
	STB 120,U
	LDD #$99a9
	STD -121,U
	LDB #$9a
	STD -41,U
	STB ,U
	STB 40,U
	STB 80,U
	LDA #$9a
	STD -81,U
	LEAU ,S
SSAV_Img_sonic_040_0
	LDS glb_register_s
	RTS
