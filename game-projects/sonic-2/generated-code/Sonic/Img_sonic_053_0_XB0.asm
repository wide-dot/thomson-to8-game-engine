	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_053_0
	STS glb_register_s

	LEAS ,Y
	LEAU -481,U

	LDA -118,U
	LDX -38,U
	PSHS X,A
	LDA #$dd
	STA -118,U
	LDD #$aa99
	STD -38,U
	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	LDD -78,U
	PSHS D
	LDA #$da
	ANDB #$0F
	ORB #$90
	STD -78,U
	PULU A,X
	PSHS U,X,A
	LDA #$33
	LDX #$b3da
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$33
	LDX #$b3dd
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$dd
	LDX #$beff
	PSHU A,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$3ebe
	LDX #$ffaa
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$33ee
	LDX #$ffaa
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$3e
	LDX #$ffaa
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$ee
	LDX #$aaaa
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$e3
	LDX #$aaaa
	PSHU D,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$0F
	ORA #$d0
	LDB #$e3
	STD 40,U
	LDX 42,U
	PSHS X
	LDD #$aaca
	STD 42,U
	PULU D,X
	PSHS U,X,D
	LDD #$ede3
	LDX #$aaca
	PSHU D,X
	LEAU 81,U

	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$aaea
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$9a9a
	PSHU A,X
	LEAU 40,U

	LDA 38,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$999a
	PSHU A,X
	LEAU 40,U

	LDA 38,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$999a
	PSHU A,X
	LEAU 40,U

	LDA 38,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 38,U
	LDA 42,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 42,U
	LDA 78,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 78,U
	LDA 82,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 82,U
	LDA 118,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 118,U
	LDA 122,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 122,U
	LDD 40,U
	PSHS D
	LDA #$ee
	ANDB #$F0
	ORB #$09
	STD 40,U
	LDD 80,U
	PSHS D
	LDA #$ee
	ANDB #$F0
	ORB #$09
	STD 80,U
	LDD 120,U
	PSHS D
	LDA #$ef
	ANDB #$F0
	ORB #$09
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$9a9a
	PSHU A,X
	LEAU 279,U

	LDD -119,U
	PSHS D
	LDA #$9e
	ANDB #$F0
	ORB #$09
	STD -119,U
	LDD 80,U
	PSHS D
	LDA #$ee
	ANDB #$0F
	ORB #$b0
	STD 80,U
	LDD 120,U
	PSHS D
	LDA #$be
	ANDB #$0F
	ORB #$b0
	STD 120,U
	LDD -1,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0d0d
	STD -1,U
	LDA -121,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -121,U
	LDA -117,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA -117,U
	LDA -81,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -81,U
	LDA -77,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA -77,U
	LDA -41,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -41,U
	LDA 1,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 1,U
	LDA 41,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 41,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$eb
	STD 39,U
	LDA -79,U
	LDB -39,U
	PSHS U,B,A
	LDA #$9c
	STA -79,U
	LDA #$9e
	STA -39,U
	LEAU 200,U

	LDD -40,U
	PSHS D
	LDA #$bb
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDA ,U
	LDB 40,U
	PSHS U,B,A
	LDA #$eb
	STA ,U
	LDA #$dd
	STA 40,U

	LDU <glb_screen_location_1
	LEAU -521,U

	LDD -79,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ea0
	STD -79,U
	LDD -39,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$aa
	STD -39,U
	PULU A,X
	PSHS U,X,A
	LDA #$33
	LDX #$ceaa
	PSHU A,X
	LEAU 40,U

	LDX 41,U
	PSHS X
	LDA #$cf
	STD 41,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$d3
	STD 39,U
	PULU A,X
	PSHS U,X,A
	LDA #$3d
	LDX #$cfaa
	PSHU A,X
	LEAU 79,U

	LDD 120,U
	PSHS D
	LDA #$d3
	ANDB #$F0
	ORB #$0e
	STD 120,U
	LDX 82,U
	LDY 122,U
	PSHS Y,X
	LDA 80,U
	LDB 40,U
	LDX 42,U
	PSHS X,B,A
	LDD #$cfaa
	STD 122,U
	LDB #$ea
	STD 42,U
	LDA #$dd
	STA 40,U
	LDA #$ca
	STD 82,U
	LDA #$33
	STA 80,U
	PULU X,Y
	PSHS U,Y,X
	LDB #$3b
	LDX #$cfaa
	PSHU D,X
	LEAU 161,U

	LDD -1,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0d0e
	STD -1,U
	LDX 1,U
	PSHS U,X
	LDD #$cfaa
	STD 1,U
	LEAU 160,U

	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$9e
	STD -121,U
	LDD -80,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$ea
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$99
	STD -40,U
	LDA -78,U
	LDB -38,U
	LDX -119,U
	PSHS X,B,A
	LDD #$ceaa
	STD -119,U
	LDA #$ae
	STA -78,U
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDA #$9c
	LDX #$99a9
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$f9aa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$f99a
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	LDD #$aeca
	STD 40,U
	LDY 80,U
	PSHS Y,X
	LDA #$a9
	STD 80,U
	LDD 119,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$aa
	STD 119,U
	LDD 121,U
	PSHS D
	LDA #$ea
	ANDB #$0F
	ORB #$a0
	STD 121,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 42,U
	LDA 82,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 82,U
	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$f99a
	PSHU A,X
	LEAU 279,U

	LDX ,U
	LDY 80,U
	PSHS Y,X
	LDD 40,U
	LDX 120,U
	PSHS X,D
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA -38,U
	LDA 2,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 2,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 42,U
	LDA 82,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 82,U
	LDD #$bfda
	STD 80,U
	LDB #$ee
	STD 120,U
	LDD #$33a9
	STD ,U
	LDD #$b3ae
	STD 40,U
	LDD -118,U
	PSHS D
	LDA #$ea
	ANDB #$0F
	ORB #$90
	STD -118,U
	LDD -78,U
	PSHS D
	LDA #$ea
	ANDB #$0F
	ORB #$90
	STD -78,U
	LDD -120,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$aa
	STD -120,U
	LDD -80,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$a9
	STD -80,U
	LDD -40,U
	PSHS U,D
	ANDA #$0F
	ORA #$30
	LDB #$a9
	STD -40,U
	LEAU 221,U

	LDX -61,U
	PSHS X
	LDD #$dfef
	STD -61,U
	LDA 60,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 60,U
	LDD -21,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$ee
	STD -21,U
	LDD 19,U
	PSHS U,D
	ANDA #$F0
	ORA #$0d
	LDB #$bd
	STD 19,U
	LEAU ,S
SSAV_Img_sonic_053_0
	LDS glb_register_s
	RTS
