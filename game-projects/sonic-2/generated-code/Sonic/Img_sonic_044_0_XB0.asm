	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_044_0
	STS glb_register_s

	LEAS ,Y
	LEAU -480,U

	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA -120,U
	LDA -80,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA -40,U
	LDA ,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA ,U
	LDA 40,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 40,U
	LDA 80,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 80,U
	LDA 118,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA 118,U
	LDA 120,U
	PSHS U,A
	ANDA #$0F
	ORA #$b0
	STA 120,U
	LEAU 220,U

	LDA -60,U
	LDB -20,U
	LDX 60,U
	PSHS X,B,A
	LDA #$ee
	STA -60,U
	LDD 20,U
	PSHS D
	LDA #$ed
	ANDB #$0F
	ORB #$e0
	STD 20,U
	LDA -62,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -62,U
	LDA -22,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA -22,U
	LDA 18,U
	PSHS A
	ANDA #$F0
	ORA #$0e
	STA 18,U
	LDA 58,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA 58,U
	LDA 62,U
	PSHS U,A
	ANDA #$0F
	ORA #$d0
	STA 62,U
	LDD #$edfe
	STD 60,U
	STA -20,U
	LEAU 220,U

	LDX -120,U
	PSHS X
	LDA -122,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA -122,U
	LDA -118,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA -118,U
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
	LDD #$ddfe
	STD -120,U
	LDX -80,U
	LDY -40,U
	PSHS Y,X
	LDA #$9c
	STD -80,U
	STD -40,U
	LDD -82,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0bf0
	STD -82,U
	LDD -42,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$da
	STD -42,U
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
	LDB #$d9
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ae
	LDX #$ecda
	PSHU A,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0dd0
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$ae
	LDX #$ecda
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$a3
	LDX #$ecfa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$ccfa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$d9
	LDX #$eefa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aafa
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD 40,U
	LDA 42,U
	STB 42,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$a9
	LDX #$aaea
	PSHU A,X
	LEAU 80,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aaac
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aacc
	PSHU A,X
	LEAU 40,U

	LDX 41,U
	LDD #$9aee
	STD 41,U
	LDY 81,U
	PSHS Y,X
	LDB #$99
	STD 81,U
	LDD 121,U
	PSHS D
	LDD #$aaaa
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDX #$aace
	PSHU B,X
	LEAU 281,U

	LDD -81,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$09a0
	STD -81,U
	LDA -41,U
	PSHS A
	ANDA #$F0
	ORA #$0a
	STA -41,U
	LDA -39,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -39,U
	LDA 1,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 1,U
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
	PSHS A
	ANDA #$F0
	ORA #$09
	STA 120,U
	LDA -79,U
	LDX -120,U
	PSHS U,X,A
	LDD #$aaaa
	STD -120,U
	STA -79,U
	LEAU 160,U

	LDA ,U
	PSHS U,A
	ANDA #$F0
	ORA #$0a
	STA ,U

	LDU <glb_screen_location_1
	LEAU -561,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0d03
	STD 39,U
	LDA -120,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -120,U
	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -40,U
	LDA ,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA ,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$d3
	STD 79,U
	LDX 119,U
	PSHS U,X
	LDD #$dbde
	STD 119,U
	LEAU 279,U

	LDX -120,U
	STD -120,U
	LDY -80,U
	PSHS Y,X
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -38,U
	LDD #$bbd3
	STD -80,U
	LDX -40,U
	PSHS X
	LDA #$bc
	STD -40,U
	PULU A,X
	PSHS U,X,A
	LDA #$ff
	LDX #$d39a
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	LDA #$b3
	ANDB #$F0
	ORB #$03
	STD 40,U
	LDD 80,U
	PSHS D
	LDA #$bf
	ANDB #$F0
	ORB #$0d
	STD 80,U
	LDD 82,U
	PSHS D
	LDA #$ee
	ANDB #$F0
	ORB #$03
	STD 82,U
	LDA 42,U
	LDB 120,U
	LDX 122,U
	PSHS X,B,A
	LDA #$9e
	STA 42,U
	LDA #$3f
	STA 120,U
	LDD #$eeec
	STD 122,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$d3de
	PSHU A,X
	LEAU 160,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$eeaa
	LDX #$eecc
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$ed
	LDX #$eecf
	PSHU D,X
	LEAU 40,U

	LDA 40,U
	LDX 42,U
	LDY 82,U
	PSHS Y,X,A
	LDA #$3e
	STA 40,U
	LDD 80,U
	PSHS D
	LDA #$dd
	ANDB #$F0
	ORB #$09
	STD 80,U
	LDD 123,U
	PSHS D
	LDA #$af
	ANDB #$0F
	ORB #$a0
	STD 123,U
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
	LDD #$cdaf
	STD 82,U
	LDD 121,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$39
	STD 121,U
	LDD #$eeff
	STD 42,U
	PULU X,Y
	PSHS U,Y,X
	LDB #$99
	LDX #$3fff
	PSHU D,X
	LEAU 161,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$9a
	STD 40,U
	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 3,U
	LDD 42,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 42,U
	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$9aaa
	PSHU A,X
	LEAU 81,U

	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aaa9
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	PSHS X
	LDD #$a9aa
	STD 40,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 42,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$a9
	STD 79,U
	LDD 81,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 81,U
	LDD 121,U
	PSHS D
	LDA #$ac
	ANDB #$0F
	ORB #$a0
	STD 121,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0a09
	STD 119,U
	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aaa9
	PSHU A,X
	LEAU 281,U

	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$a9
	STD -121,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$a9
	STD -81,U
	LDA 120,U
	LDX 39,U
	LDY -41,U
	PSHS Y,X,A
	LDD -1,U
	LDX 79,U
	PSHS X,D
	LDA -119,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -119,U
	LDA -79,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA -79,U
	LDD #$99a9
	STD -41,U
	LDD #$aa9a
	STD 79,U
	LDA #$9a
	STD -1,U
	STD 39,U
	STA 120,U
	LEAU 200,U

	LDA -40,U
	LDB ,U
	PSHS B,A
	LDA #$aa
	STA -40,U
	STA ,U
	LDA 40,U
	PSHS U,A
	ANDA #$0F
	ORA #$a0
	STA 40,U
	LEAU ,S
SSAV_Img_sonic_044_0
	LDS glb_register_s
	RTS
