	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_041_0
	STS glb_register_s

	LEAS ,Y
	LEAU -521,U

	LDD -120,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -120,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$33
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$d3
	STD -40,U
	LDD 81,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ed0
	STD 81,U
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -78,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -38,U
	LDA 120,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA 120,U
	LDD 1,U
	PSHS D
	LDA #$be
	ANDB #$0F
	ORB #$d0
	STD 1,U
	LDD 41,U
	PSHS U,D
	LDA #$bf
	ANDB #$0F
	ORB #$d0
	STD 41,U
	LEAU 240,U

	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA -40,U
	LDD ,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ee0
	STD ,U
	LDD 40,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ee0
	STD 40,U
	LDD 80,U
	PSHS U,D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ee0
	STD 80,U
	LEAU 240,U

	LDD -119,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$03d0
	STD -119,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0d0e
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0d0e
	STD -40,U
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -78,U
	LDA -38,U
	LDB 4,U
	PSHS B,A
	LDA #$ad
	STA -38,U
	LDA #$33
	STA 4,U
	PULU A,X
	PSHS U,X,A
	LDA #$ee
	LDX #$eead
	PSHU A,X
	LEAU 40,U

	LDD 3,U
	PSHS D
	ANDA #$F0
	ORA #$0f
	LDB #$33
	STD 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$df
	LDX #$cda9
	PSHU A,X
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$ad
	LDX #$cead
	LDY #$9dbb
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$ad
	LDX #$ce9d
	LDY #$ddbb
	PSHU A,X,Y
	LEAU 40,U

	LDD 3,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$e3
	STD 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$ad
	LDX #$ce9d
	PSHU A,X
	LEAU 40,U

	LDA 4,U
	STB 4,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$af
	LDX #$ce99
	PSHU A,X
	LEAU 40,U

	LDA 4,U
	LDX 120,U
	PSHS X,A
	LDA #$dd
	STA 4,U
	LDD #$aaa9
	STD 120,U
	LDA 122,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 122,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$af
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$ae
	STD 79,U
	LDD 41,U
	PSHS D
	LDA #$a9
	ANDB #$0F
	ORB #$90
	STD 41,U
	LDD 81,U
	PSHS D
	LDA #$a9
	ANDB #$0F
	ORB #$e0
	STD 81,U
	PULU A,X
	PSHS U,X,A
	LDA #$af
	LDX #$e999
	PSHU A,X
	LEAU 160,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$a9c9
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	LDD #$9aa9
	STD 40,U
	LDY 120,U
	PSHS Y,X
	LDA #$9e
	STD 120,U
	LDD 80,U
	PSHS D
	LDD #$ac99
	STD 80,U
	LDD 42,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$ee
	STD 42,U
	LDD 82,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$fe
	STD 82,U
	LDA 123,U
	STB 123,U
	PULU X,Y
	PSHS U,Y,X,A
	LDD #$aaa9
	LDX #$ceee
	PSHU D,X
	LEAU 260,U

	LDX -100,U
	PSHS X
	LDA 20,U
	LDB -97,U
	PSHS B,A
	ANDB #$0F
	ORB #$f0
	STB -97,U
	LDA 60,U
	PSHS A
	ANDA #$F0
	ORA #$0a
	STA 60,U
	LDA 100,U
	PSHS A
	ANDA #$F0
	ORA #$0a
	STA 100,U
	LDD #$99aa
	STD -100,U
	LDX -60,U
	LDA #$aa
	STD -60,U
	LDY -20,U
	PSHS U,Y,X
	LDB #$99
	STD -20,U
	STA 20,U

	LDU <glb_screen_location_1
	LEAU -521,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$bb
	STD 40,U
	LDD 120,U
	PSHS D
	ANDA #$0F
	ORA #$e0
	LDB #$f3
	STD 120,U
	LDA 81,U
	LDX ,U
	LDY -80,U
	PSHS Y,X,A
	LDD -120,U
	LDX -40,U
	PSHS U,X,D
	LDD #$dddd
	STD -120,U
	LDA #$3b
	STD ,U
	LDD #$d333
	STD -80,U
	LDA #$bd
	STD -40,U
	LDA #$bb
	STA 81,U
	LEAU 261,U

	LDX -101,U
	LDY -61,U
	PSHS Y,X
	LDD -21,U
	PSHS D
	LDA #$ee
	ANDB #$0F
	ORB #$a0
	STD -21,U
	LDD 19,U
	PSHS D
	LDA #$ee
	ANDB #$0F
	ORB #$a0
	STD 19,U
	LDD #$eeee
	STD -101,U
	LDB #$9e
	STD -61,U
	LDX 59,U
	PSHS X
	LDB #$a9
	STD 59,U
	LDA 100,U
	PSHS U,A
	ANDA #$F0
	ORA #$0a
	STA 100,U
	LEAU 259,U

	LDD -120,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$300a
	STD -120,U
	LDD -37,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0e30
	STD -37,U
	LDX -80,U
	LDD #$c33e
	STD -80,U
	LDY -40,U
	PSHS Y,X
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$fc
	STD 39,U
	LDD #$cccc
	STD -40,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$ecd9
	LDY #$3f33
	PSHU B,X,Y
	LEAU 41,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ff
	STD 38,U
	LDD 78,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ff
	STD 78,U
	LDA 40,U
	LDB 80,U
	LDX 42,U
	LDY 82,U
	PSHS Y,X,B,A
	LDA #$da
	STA 40,U
	LDA #$99
	STA 80,U
	LDD #$3e3d
	STD 82,U
	LDD #$ee33
	STD 42,U
	PULU X,Y
	PSHS U,Y,X
	LDB #$dd
	LDX #$ffb3
	PSHU D,X
	LEAU 118,U

	LDD 3,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$d3
	STD 3,U
	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$fa93
	PSHU A,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA 4,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$fa9e
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$fa9c
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$aa9c
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$aa9e
	PSHU A,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$aa
	LDX #$a9ee
	PSHU D,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ea
	STD 80,U
	LDD 82,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$ff
	STD 82,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$9a
	STD 120,U
	LDD 122,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$ef
	STD 122,U
	LDA 43,U
	PSHS A
	LDA #$fe
	STA 43,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$aaae
	LDX #$9aee
	PSHU D,X
	LEAU 281,U

	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -121,U
	LDD -119,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$ef
	STD -119,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$9a
	STD -81,U
	LDD -40,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$99
	STD -40,U
	LDA -79,U
	STB -79,U
	LDB ,U
	PSHS B,A
	ANDB #$0F
	ORB #$90
	STB ,U
	LDA 40,U
	LDB 80,U
	PSHS B,A
	LDA 120,U
	PSHS U,A
	LDA #$a9
	STA 40,U
	STA 80,U
	STA 120,U
	LEAU ,S
SSAV_Img_sonic_041_0
	LDS glb_register_s
	RTS
