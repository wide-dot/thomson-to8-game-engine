	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_006_0
	STS glb_register_s

	LEAS ,Y
	LEAU -559,U

	LDA -120,U
	LDB -80,U
	LDX 39,U
	LDY 119,U
	PSHS Y,X,B,A
	LDD 79,U
	LDX -1,U
	PSHS X,D
	LDD #$9aac
	STD -1,U
	LDA 1,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 1,U
	LDD #$aaec
	STD 39,U
	STA -120,U
	STA -80,U
	LDB #$ae
	STD 119,U
	LDB #$cc
	STD 79,U
	LDD -41,U
	PSHS U,D
	ANDA #$F0
	ORA #$0a
	LDB #$ae
	STD -41,U
	LEAU 279,U

	LDX -120,U
	LDY -80,U
	PSHS Y,X
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -78,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -38,U
	LDX -40,U
	PSHS X
	LDD #$aafa
	STD -40,U
	LDB #$aa
	STD -120,U
	STD -80,U
	PULU A,X
	PSHS U,X,A
	LDX #$fa99
	PSHU B,X
	LEAU 40,U

	LDX 40,U
	LDY 80,U
	PSHS Y,X
	LDD #$dff9
	STD 80,U
	LDD 120,U
	PSHS D
	LDD #$dea9
	STD 120,U
	LDD #$dafa
	STD 40,U
	PULU A,X
	PSHS U,X,A
	LDX #$fa99
	PSHU B,X
	LEAU 281,U

	LDX -121,U
	LDY 119,U
	PSHS Y,X
	LDD #$33e3
	STD 119,U
	LDD -81,U
	LDX -41,U
	LDY 79,U
	PSHS Y,X,D
	LDD #$ccc9
	STD -81,U
	LDA #$dc
	STD -121,U
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
	LDA 121,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 121,U
	LDX -1,U
	PSHS X
	LDD 39,U
	PSHS U,D
	ANDA #$F0
	ORA #$03
	LDB #$ec
	STD 39,U
	LDD #$3e9d
	STD -1,U
	LDD #$e3ee
	STD 79,U
	LDB #$e9
	STD -41,U
	LEAU 280,U

	LDX -121,U
	LDD #$3ffe
	STD -121,U
	LDY ,U
	PSHS Y,X
	LDA -119,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA -119,U
	LDA -79,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA -79,U
	LDA -39,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA -39,U
	LDA 80,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 80,U
	LDA 120,U
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 120,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$e3
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ed
	STD -41,U
	LDD #$aaee
	STD ,U
	LDD 40,U
	PSHS U,D
	ANDA #$F0
	ANDB #$0F
	ADDD #$09e0
	STD 40,U
	LEAU 220,U

	LDD -21,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$09a0
	STD -21,U
	LDA -60,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -60,U
	LDX 19,U
	LDD #$e9fe
	STD 19,U
	LDY 59,U
	PSHS U,Y,X
	LDD #$eeee
	STD 59,U
	LEAU 218,U

	LDA -38,U
	LDX -119,U
	LDY -79,U
	PSHS Y,X,A
	LDD #$eef3
	STD -119,U
	LDD #$3dbf
	STD -79,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$d3
	STD -40,U
	LDA #$be
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDA #$33
	LDX #$dbbb
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$dd
	LDX #$dddd
	PSHU A,X

	LDU <glb_screen_location_1
	LEAU -559,U

	LDA -40,U
	LDB ,U
	LDX -81,U
	PSHS X,B,A
	LDD -42,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD -42,U
	LDD -2,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD -2,U
	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD 38,U
	LDD 78,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD 78,U
	LDD 118,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 118,U
	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -120,U
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
	ORA #$a0
	STA 120,U
	LDA #$99
	STA -40,U
	STA ,U
	LDA #$aa
	STD -81,U
	LEAU 279,U

	LDA -119,U
	PSHS A
	STB -119,U
	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -121,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$af
	STD -41,U
	LDD -1,U
	PSHS D
	ANDA #$F0
	ORA #$0f
	LDB #$af
	STD -1,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0f
	LDB #$ff
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$0f
	LDB #$df
	STD 79,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$df
	STD 119,U
	LDA 41,U
	LDB 121,U
	PSHS B,A
	ANDB #$0F
	ORB #$90
	STB 121,U
	LDA 1,U
	LDB -39,U
	PSHS B,A
	LDA 81,U
	LDB -79,U
	PSHS U,B,A
	LDA #$99
	STA 1,U
	STA 41,U
	STA 81,U
	LDA #$a9
	STA -79,U
	STA -39,U
	LEAU 280,U

	LDD 80,U
	PSHS D
	LDA #$33
	ANDB #$0F
	ORB #$c0
	STD 80,U
	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$df
	STD -121,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ef
	STD -81,U
	LDA -119,U
	LDB -79,U
	LDX 40,U
	LDY 120,U
	PSHS Y,X,B,A
	LDD ,U
	LDX -40,U
	PSHS U,X,D
	LDD #$eeec
	STD 120,U
	LDB #$99
	STD 40,U
	LDA #$cc
	STD -40,U
	STD ,U
	STB -119,U
	STB -79,U
	LEAU 280,U

	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$de
	STD 80,U
	LDX -40,U
	LDY -120,U
	PSHS Y,X
	LDD ,U
	LDX -80,U
	LDY 40,U
	PSHS Y,X,D
	LDD #$ffed
	STD -80,U
	LDD #$effe
	STD -40,U
	LDD #$deef
	STD 40,U
	LDD 120,U
	PSHS U,D
	LDA #$9d
	ANDB #$F0
	ORB #$09
	STD 120,U
	LDD #$eef3
	STD ,U
	LDD #$fe9e
	STD -120,U
	LEAU 281,U

	LDD 78,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0e0f
	STD 78,U
	LDX 118,U
	PSHS X
	LDA -121,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -121,U
	LDA -81,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -81,U
	LDA -41,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -41,U
	LDA 39,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 39,U
	LDA 120,U
	PSHS U,A
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LDD #$e33b
	STD 118,U
	LEAU 199,U

	LDX -41,U
	PSHS X
	LDB #$bb
	STD -41,U
	LDA -39,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -39,U
	LDA 1,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 1,U
	LDA 41,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 41,U
	LDX -1,U
	LDD #$3ebb
	STD -1,U
	LDY 39,U
	PSHS U,Y,X
	LDD #$dddd
	STD 39,U
	LEAU ,S
SSAV_Img_sonic_006_0
	LDS glb_register_s
	RTS
