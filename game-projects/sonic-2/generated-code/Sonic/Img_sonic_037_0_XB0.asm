	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_037_0
	STS glb_register_s

	LEAS ,Y
	LEAU -519,U

	LDD -120,U
	PSHS D
	LDA #$33
	ANDB #$0F
	ORB #$d0
	STD -120,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$e3
	STD -41,U
	LDD -1,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$e3
	STD -1,U
	LDA 40,U
	LDB 80,U
	PSHS B,A
	ANDB #$0F
	ORB #$30
	STB 80,U
	LDA 120,U
	PSHS U,A
	ANDA #$0F
	ORA #$f0
	STA 120,U
	LDA #$ee
	STA 40,U
	LEAU 260,U

	LDD -100,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$a0e0
	STD -100,U
	LDD -60,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$a0f0
	STD -60,U
	LDD 60,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ee0
	STD 60,U
	LDD 100,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ee0
	STD 100,U
	LDD -20,U
	PSHS D
	LDA #$9e
	ANDB #$0F
	ORB #$f0
	STD -20,U
	LDD 20,U
	PSHS U,D
	LDA #$ae
	ANDB #$0F
	ORB #$f0
	STD 20,U
	LEAU 257,U

	LDD -118,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$3e
	STD -118,U
	LDA -116,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -116,U
	LDA -76,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA -76,U
	LDA -36,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA -36,U
	LDD -78,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$03e0
	STD -78,U
	LDX -38,U
	PSHS X
	LDD #$93ce
	STD -38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$bb
	LDX #$ffae
	LDY #$3edd
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$cc
	LDX #$f9aa
	LDY #$3cfd
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$bb
	LDX #$e99a
	LDY #$ecfd
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$bb
	LDX #$eeda
	LDY #$9cfe
	PSHU A,X,Y
	LEAU 40,U

	LDD 40,U
	PSHS D
	LDA #$33
	ANDB #$0F
	ORB #$d0
	STD 40,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$33
	LDX #$3ed9
	LDY #$acfe
	PSHU A,X,Y
	LEAU 42,U

	LDA 38,U
	PSHS A
	LDA #$dd
	STA 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aafe
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ae
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$e9
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$e9
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aacc
	PSHU A,X
	LEAU 40,U

	LDX 41,U
	LDD #$9a9e
	STD 41,U
	LDY 81,U
	PSHS Y,X
	LDD #$9999
	STD 81,U
	LDD 121,U
	PSHS D
	LDD #$a9aa
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDX #$9acc
	PSHU B,X
	LEAU 242,U

	LDX -81,U
	PSHS X
	LDD #$aaaa
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$aa
	STD -41,U
	LDA ,U
	STB ,U
	LDB -2,U
	PSHS B,A
	ANDB #$F0
	ORB #$09
	STB -2,U
	LDA 40,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 40,U
	LDA 80,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA 80,U
	LEAU 199,U

	LDA ,U
	PSHS U,A
	ANDA #$F0
	ORA #$09
	STA ,U

	LDU <glb_screen_location_1
	LEAU -520,U

	LDA 40,U
	LDB 80,U
	LDX -120,U
	LDY -80,U
	PSHS Y,X,B,A
	LDD -40,U
	PSHS D
	LDD #$333b
	STD -40,U
	STB 40,U
	LDB #$33
	STD -120,U
	LDD ,U
	PSHS D
	LDA #$33
	ANDB #$0F
	ORB #$b0
	STD ,U
	LDD 120,U
	PSHS U,D
	LDA #$de
	ANDB #$F0
	ORB #$0e
	STD 120,U
	STA 80,U
	LDD #$dddd
	STD -80,U
	LEAU 240,U

	LDX -80,U
	PSHS X
	LDD #$deee
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$ef
	STD -40,U
	LDD ,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$ef
	STD ,U
	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$ef
	STD 40,U
	LDD 80,U
	PSHS U,D
	ANDA #$F0
	ORA #$09
	LDB #$ef
	STD 80,U
	LEAU 239,U

	LDX -119,U
	LDD #$daef
	STD -119,U
	LDY -39,U
	PSHS Y,X
	LDD -79,U
	PSHS D
	LDA #$e3
	ANDB #$F0
	ORB #$0e
	STD -79,U
	LDD #$ceec
	STD -39,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$c3cc
	PSHU A,X
	LEAU 39,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$e3aa
	LDX #$f3cc
	PSHU D,X
	LEAU 39,U

	LDX 80,U
	LDY 124,U
	PSHS Y,X
	LDA #$aa
	STD 124,U
	LDD 122,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$ad
	STD 122,U
	LDX 120,U
	LDY 43,U
	PSHS Y,X
	LDD 40,U
	LDX 83,U
	PSHS X,D
	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 5,U
	LDA 45,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 45,U
	LDA 85,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 85,U
	LDD #$bcfb
	STD 40,U
	LDD #$aecf
	STD 43,U
	LDD #$3be3
	STD 80,U
	LDA #$d3
	STD 120,U
	LDD #$adff
	STD 83,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$db
	LDX #$f399
	LDY #$e3cf
	PSHU A,X,Y
	LEAU 162,U

	LDD -2,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$e3
	STD -2,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$9999
	LDX #$aaaa
	PSHU D,X
	LEAU 39,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$dd
	LDX #$ea99
	LDY #$aaaa
	PSHU A,X,Y
	LEAU 41,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$ee
	LDX #$aaaa
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$9a
	LDX #$afaa
	PSHU D,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$aa
	STD 40,U
	LDD 121,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$a9
	STD 121,U
	LDD 42,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 42,U
	LDD 82,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 82,U
	LDA 80,U
	PSHS A
	ANDA #$F0
	ORA #$0a
	STA 80,U
	LDA 123,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 123,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$eeaa
	LDX #$aaaa
	PSHU D,X
	LEAU 282,U

	LDA 80,U
	LDB 120,U
	LDX 39,U
	LDY -41,U
	PSHS Y,X,B,A
	LDD #$99a9
	STD -41,U
	LDD -1,U
	PSHS D
	LDA #$9a
	ANDB #$F0
	ORB #$09
	STD -1,U
	STA 80,U
	STA 120,U
	LDA -119,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -119,U
	LDA -79,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -79,U
	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$a9
	STD -121,U
	LDD -81,U
	PSHS U,D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD -81,U
	LDD #$aa99
	STD 39,U
	LEAU 200,U

	LDA -40,U
	LDB ,U
	PSHS B,A
	ANDB #$0F
	ORB #$a0
	STB ,U
	LDA 40,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA 40,U
	LDA #$aa
	STA -40,U
	LEAU ,S
SSAV_Img_sonic_037_0
	LDS glb_register_s
	RTS
