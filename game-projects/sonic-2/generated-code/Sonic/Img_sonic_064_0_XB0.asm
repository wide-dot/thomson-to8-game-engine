	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_064_0
	STS glb_register_s

	LEAS ,Y
	LEAU -520,U

	LDA ,U
	PSHS U,A
	ANDA #$0F
	ORA #$30
	STA ,U
	LEAU 239,U

	LDD -120,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0be0
	STD -120,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0be0
	STD -80,U
	LDA -118,U
	LDB -78,U
	PSHS B,A
	LDA #$aa
	STA -118,U
	STA -78,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$fe
	STD -40,U
	LDA -38,U
	PSHS A
	LDA #$da
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDA #$bb
	LDX #$fffa
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$b3
	LDX #$fffa
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$f3
	LDX #$ffaa
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$ff
	LDX #$ffaa
	PSHU A,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$be
	LDX #$aaaa
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$aa9a
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$3fae
	LDX #$aaaa
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$afaa
	LDX #$aaaa
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$aaaa
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$ae
	LDX #$aa9a
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$aaa9
	LDX #$aa9a
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$99
	LDX #$aa9a
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$a9
	LDX #$aa9a
	PSHU D,X
	LEAU 40,U

	LDD 120,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0909
	STD 120,U
	LDA 43,U
	LDB 83,U
	PSHS B,A
	LDD 122,U
	PSHS D
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 122,U
	LDD 41,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 41,U
	LDD 81,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 81,U
	LDA #$9a
	STA 43,U
	STA 83,U
	PULU X,Y
	PSHS U,Y,X
	LDA #$99
	LDX #$999a
	PSHU D,X
	LEAU 242,U

	LDX -41,U
	LDY -1,U
	PSHS Y,X
	STD -41,U
	STD -1,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -81,U
	LDD 39,U
	PSHS D
	ANDA #$0F
	ORA #$90
	LDB #$99
	STD 39,U
	LDA -79,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -79,U
	LDA -39,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -39,U
	LDA 80,U
	PSHS U,A
	ANDA #$0F
	ORA #$90
	STA 80,U

	LDU <glb_screen_location_1
	LEAU -440,U

	LDD -1,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$b0d0
	STD -1,U
	LDA -81,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA -81,U
	LDA -41,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -41,U
	LDA 81,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 81,U
	LDD 39,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$de
	STD 39,U
	LDD 79,U
	PSHS U,D
	ANDA #$0F
	ORA #$30
	LDB #$dd
	STD 79,U
	LEAU 239,U

	LDA -118,U
	LDB -78,U
	PSHS B,A
	LDD -120,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$cd
	STD -120,U
	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ff
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ef
	STD -40,U
	LDA -38,U
	PSHS A
	LDA #$aa
	STA -118,U
	STA -78,U
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDX #$afaa
	PSHU B,X
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$ff
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$ff
	STD 79,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$af
	STD 119,U
	LDX 41,U
	LDY 81,U
	PSHS Y,X
	LDD 121,U
	PSHS D
	LDD #$eaaa
	STD 41,U
	LDB #$99
	STD 81,U
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$eaaa
	PSHU A,X
	LEAU 280,U

	LDX -119,U
	PSHS X
	LDA #$ea
	STD -119,U
	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$fc
	STD -121,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$fc
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$ea
	STD -41,U
	LDX -79,U
	LDD #$aaa9
	STD -79,U
	LDY -39,U
	PSHS Y,X
	LDB #$aa
	STD -39,U
	PULU A,X
	PSHS U,X,A
	LDX #$aaaa
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$aaa9
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$9a99
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$9090
	STD 40,U
	LDD 81,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$9090
	STD 81,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 42,U
	LDA 121,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU 241,U

	LDD -41,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0909
	STD -41,U
	LDA 40,U
	LDB ,U
	PSHS U,B,A
	ANDB #$F0
	ORB #$09
	STB ,U
	LDA #$99
	STA 40,U
	LEAU ,S
SSAV_Img_sonic_064_0
	LDS glb_register_s
	RTS
