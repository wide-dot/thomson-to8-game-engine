	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_057_0
	STS glb_register_s

	LEAS ,Y
	LEAU -639,U

	LDA -120,U
	LDB -80,U
	PSHS B,A
	LDA #$33
	STA -120,U
	STA -80,U
	LDA -40,U
	PSHS A
	LDA #$3d
	STA -40,U
	LDA ,U
	LDB 41,U
	PSHS B,A
	ANDB #$F0
	ORB #$03
	STB 41,U
	LDA #$d3
	STA ,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 79,U
	LDD 119,U
	PSHS U,D
	ANDA #$F0
	ORA #$03
	LDB #$3e
	STD 119,U
	LEAU 219,U

	LDD -60,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$ee
	STD -60,U
	LDA -58,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -58,U
	LDX -20,U
	LDD #$dbed
	STD -20,U
	LDY 20,U
	PSHS Y,X
	LDD 60,U
	PSHS U,D
	LDD #$bb9d
	STD 20,U
	STD 60,U
	LEAU 219,U

	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$3b
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$cb
	STD -40,U
	LDA -38,U
	LDB -116,U
	PSHS B,A
	ANDB #$0F
	ORB #$30
	STB -116,U
	LDA -78,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA -78,U
	LDA -76,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -76,U
	LDA -36,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA -36,U
	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 4,U
	LDX -119,U
	PSHS X
	LDD #$bb99
	STD -119,U
	LDA #$cc
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDA #$da
	LDX #$ceee
	PSHU A,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 4,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$ccee
	PSHU A,X
	LEAU 40,U

	LDD 3,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$a0b0
	STD 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$ad
	LDX #$ccfe
	PSHU A,X
	LEAU 40,U

	LDD 3,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$a0e0
	STD 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$ad
	LDX #$fcfe
	PSHU A,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$adfc
	LDX #$fead
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$aeae
	LDX #$fe9a
	PSHU D,X
	LEAU 40,U

	LDD 3,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ab0
	STD 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$ae
	LDX #$a9ee
	PSHU A,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$aeaa
	LDX #$cfea
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$aaaa
	LDX #$cffe
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$9ebf
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$aca9
	LDX #$9cdb
	PSHU D,X
	LEAU 40,U

	LDX 40,U
	LDA #$aa
	STD 40,U
	LDY 80,U
	PSHS Y,X
	LDA 3,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA 3,U
	LDX 120,U
	PSHS X
	LDD #$aaaa
	STD 80,U
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$ac
	LDX #$a9aa
	PSHU A,X
	LEAU 281,U

	LDX -121,U
	PSHS X
	LDA #$aa
	STD -121,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0a0a
	STD -81,U
	LDA -41,U
	PSHS A
	ANDA #$F0
	ORA #$0a
	STA -41,U
	LDA -39,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -39,U
	LDA ,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA ,U
	LDA 40,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 40,U
	LDA 80,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 80,U
	LDA 120,U
	PSHS U,A
	ANDA #$0F
	ORA #$90
	STA 120,U

	LDU <glb_screen_location_1
	LEAU -598,U

	LDD -42,U
	PSHS D
	LDA #$33
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD -2,U
	PSHS D
	LDA #$3d
	ANDB #$0F
	ORB #$d0
	STD -2,U
	LDD 38,U
	PSHS D
	LDA #$de
	ANDB #$0F
	ORB #$d0
	STD 38,U
	LDD 78,U
	PSHS D
	LDA #$3e
	ANDB #$0F
	ORB #$d0
	STD 78,U
	LDA -121,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -121,U
	LDA 80,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 80,U
	LDA 120,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 120,U
	LDD -82,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$03d0
	STD -82,U
	LDD 118,U
	PSHS U,D
	ANDA #$0F
	ANDB #$0F
	ADDD #$30d0
	STD 118,U
	LEAU 200,U

	LDA -40,U
	LDB ,U
	PSHS B,A
	LDA 38,U
	LDB 40,U
	PSHS U,B,A
	LDA #$33
	STA -40,U
	STA ,U
	STA 40,U
	LDA #$ee
	STA 38,U
	LEAU 197,U

	LDD -78,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$a003
	STD -78,U
	LDD -38,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$e003
	STD -38,U
	LDA -117,U
	LDX -40,U
	LDY -80,U
	PSHS Y,X,A
	LDA #$33
	STA -117,U
	LDA 3,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 3,U
	LDD #$deee
	STD -80,U
	LDA #$dc
	STD -40,U
	LDA -119,U
	STB -119,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$fc
	LDX #$eeea
	PSHU A,X
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$df
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ff
	STD 79,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ff
	STD 119,U
	LDX 41,U
	LDD #$3e9a
	STD 41,U
	LDY 81,U
	PSHS Y,X
	LDA #$9e
	STD 81,U
	LDA 3,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 3,U
	LDA 43,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA 43,U
	LDA 83,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA 83,U
	PULU A,X
	PSHS U,X,A
	LDA #$df
	LDX #$3eaa
	PSHU A,X
	LEAU 121,U

	PULU A,X
	PSHS U,X,A
	LDA #$9e
	LDX #$9abe
	PSHU A,X
	LEAU 38,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$ff9f
	LDY #$e9bb
	PSHU B,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$fa99
	LDY #$e9eb
	PSHU B,X,Y
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 40,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$9a
	LDX #$fa99
	LDY #$39eb
	PSHU A,X,Y
	LEAU 42,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$e9eb
	PSHU A,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 38,U
	LDD 78,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ea
	STD 78,U
	LDD 118,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$c9
	STD 118,U
	LDD 40,U
	PSHS D
	LDA #$9a
	ANDB #$0F
	ORB #$c0
	STD 40,U
	LDA 42,U
	LDB 120,U
	PSHS B,A
	ANDB #$0F
	ORB #$90
	STB 120,U
	LDA #$dd
	STA 42,U
	LDD 80,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$90e0
	STD 80,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$caeb
	PSHU A,X
	LEAU 279,U

	LDA 80,U
	LDB 120,U
	LDX ,U
	LDY -120,U
	PSHS Y,X,B,A
	LDD -40,U
	LDX -80,U
	PSHS X,D
	LDD #$99a9
	STD -40,U
	STD ,U
	STB 80,U
	LDD #$ea99
	STD -120,U
	STD -80,U
	LDA #$aa
	STA 120,U
	LDD 40,U
	PSHS U,D
	LDA #$a9
	ANDB #$F0
	ORB #$0a
	STD 40,U
	LEAU 160,U

	LDA ,U
	PSHS U,A
	ANDA #$F0
	ORA #$0a
	STA ,U
	LEAU ,S
SSAV_Img_sonic_057_0
	LDS glb_register_s
	RTS
