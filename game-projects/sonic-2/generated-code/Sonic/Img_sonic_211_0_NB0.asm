	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_211_0
	STS glb_register_s

	LEAS ,Y
	LEAU -620,U

	LDA -60,U
	LDX 20,U
	LDY 60,U
	PSHS Y,X,A
	LDD -20,U
	PSHS U,D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -20,U
	STA -60,U
	LDD #$9aaa
	STD 20,U
	LDD #$999a
	STD 60,U
	LEAU 220,U

	LDD -120,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$9a
	STD -120,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$ce
	STD -80,U
	LDA -118,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA -118,U
	LDA -78,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA -78,U
	LDX -39,U
	PSHS X
	LDD #$cea9
	STD -39,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$caa9
	PSHU A,X
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$0F
	ORA #$e0
	LDB #$9a
	STD 79,U
	LDX 41,U
	LDY 81,U
	PSHS Y,X
	LDD #$aaaa
	STD 41,U
	STD 81,U
	PULU A,X
	PSHS U,X,A
	LDX #$caa9
	PSHU B,X
	LEAU 119,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$fe99
	LDX #$eaaa
	PSHU D,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	LDA #$ef
	ANDB #$F0
	ORB #$09
	STD 40,U
	LDD 80,U
	PSHS D
	LDA #$ef
	ANDB #$F0
	ORB #$09
	STD 80,U
	LDX 42,U
	LDY 82,U
	PSHS Y,X
	LDD #$aadd
	STD 42,U
	STD 82,U
	PULU D,X
	PSHS U,X,D
	LDD #$ff99
	LDX #$aaaa
	PSHU D,X
	LEAU 120,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$39
	LDX #$fadd
	PSHU D,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$3c
	STD 40,U
	LDX 42,U
	LDD #$cced
	STD 42,U
	LDY 81,U
	PSHS Y,X
	LDD #$93cc
	STD 81,U
	LDD 121,U
	PSHS D
	LDD #$99ee
	STD 121,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$efc3
	LDX #$cfce
	PSHU D,X
	LEAU 283,U

	LDD 78,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$d9
	STD 78,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$3c
	STD 119,U
	LDA -42,U
	LDB -2,U
	PSHS B,A
	LDD -122,U
	PSHS D
	LDA #$99
	ANDB #$0F
	ORB #$30
	STD -122,U
	LDD -82,U
	PSHS D
	LDA #$9e
	ANDB #$0F
	ORB #$30
	STD -82,U
	LDD 38,U
	PSHS D
	LDA #$9a
	ANDB #$0F
	ORB #$90
	STD 38,U
	STA -2,U
	LDA #$9e
	STA -42,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0b30
	STD 80,U
	LDA 41,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 41,U
	LDA 121,U
	PSHS U,A
	ANDA #$0F
	ORA #$d0
	STA 121,U
	LEAU 279,U

	LDX -40,U
	LDY ,U
	PSHS Y,X
	LDD 40,U
	LDX 120,U
	LDY 80,U
	PSHS Y,X,D
	LDA -118,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -118,U
	LDX -80,U
	PSHS X
	LDD -120,U
	PSHS U,D
	ANDA #$F0
	ORA #$0d
	LDB #$bc
	STD -120,U
	LDD #$afbd
	STD -80,U
	LDB #$c3
	STD -40,U
	LDD #$eff3
	STD ,U
	LDD #$eed3
	STD 40,U
	LDA #$e3
	STD 80,U
	LDB #$33
	STD 120,U
	LEAU 221,U

	LDD -61,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$3d
	STD -61,U
	LDD -21,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$3d
	STD -21,U
	LDA 20,U
	STB 20,U
	LDB 60,U
	PSHS U,B,A
	ANDB #$F0
	ORB #$0d
	STB 60,U

	LDU <glb_screen_location_1
	LEAU -600,U

	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD -41,U
	LDA ,U
	LDB -81,U
	PSHS B,A
	ANDB #$F0
	ORB #$0a
	STB -81,U
	LDD 40,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 40,U
	STA ,U
	LDX 80,U
	PSHS U,X
	LDD #$9aaa
	STD 80,U
	LEAU 239,U

	LDX -119,U
	LDY 41,U
	PSHS Y,X
	STD -119,U
	STD 41,U
	LDD -79,U
	LDX -39,U
	PSHS X,D
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$99
	STD 39,U
	LDD #$99aa
	STD -79,U
	LDA #$a9
	STD -39,U
	PULU A,X
	PSHS U,X,A
	LDX #$99aa
	PSHU B,X
	LEAU 79,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0e09
	STD 40,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0ee0
	STD 120,U
	LDX 42,U
	LDY 82,U
	PSHS Y,X
	LDA 80,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA 80,U
	LDD #$aafe
	STD 42,U
	LDX 122,U
	PSHS X
	LDB #$ff
	STD 82,U
	STD 122,U
	PULU D,X
	PSHS U,X,D
	LDD #$ef99
	LDX #$aafa
	PSHU D,X
	LEAU 161,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ee
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$0f
	LDB #$e3
	STD 79,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$a9
	STD 119,U
	LDX 41,U
	LDY 81,U
	PSHS Y,X
	LDD 121,U
	PSHS D
	LDD #$9aff
	STD 41,U
	LDA #$9e
	STD 81,U
	LDB #$cc
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$e3
	LDX #$aaff
	PSHU A,X
	LEAU 160,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$ed
	STD 40,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 42,U
	LDA 81,U
	LDB 121,U
	PSHS B,A
	LDA #$3e
	STA 81,U
	LDA #$ce
	STA 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$33ce
	PSHU A,X
	LEAU 282,U

	LDA 1,U
	LDB -39,U
	PSHS B,A
	LDD -42,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$9d
	STD -42,U
	LDD 38,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$9a
	STD 38,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$9e
	STD 119,U
	LDA -81,U
	LDB -121,U
	PSHS B,A
	LDA #$dd
	STA 1,U
	LDD -2,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$09a0
	STD -2,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0a90
	STD 79,U
	LDA #$ce
	STA -121,U
	LDA 41,U
	LDB -79,U
	PSHS B,A
	ANDB #$F0
	ORB #$0d
	STB -79,U
	LDA #$b3
	STA -39,U
	LDA #$c3
	STA -81,U
	LDA 81,U
	LDB 121,U
	PSHS U,B,A
	LDA #$3d
	STA 41,U
	STA 81,U
	STA 121,U
	LEAU 280,U

	LDX -120,U
	LDD #$ff33
	STD -120,U
	LDY -80,U
	PSHS Y,X
	LDD -40,U
	PSHS D
	LDD #$3fdd
	STD -80,U
	LDA #$bb
	STD -40,U
	LDD ,U
	PSHS D
	LDA #$bb
	ANDB #$0F
	ORB #$d0
	STD ,U
	LDD 40,U
	PSHS D
	LDA #$bb
	ANDB #$0F
	ORB #$30
	STD 40,U
	LDD 80,U
	PSHS D
	LDA #$bb
	ANDB #$0F
	ORB #$30
	STD 80,U
	LDD 120,U
	PSHS U,D
	LDA #$3d
	ANDB #$0F
	ORB #$d0
	STD 120,U
	LEAU 180,U

	LDD -20,U
	PSHS D
	LDA #$3d
	ANDB #$0F
	ORB #$d0
	STD -20,U
	LDA 20,U
	PSHS U,A
	LDA #$dd
	STA 20,U
	LEAU ,S
SSAV_Img_sonic_211_0
	LDS glb_register_s
	RTS
