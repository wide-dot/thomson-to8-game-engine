	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_061_0
	STS glb_register_s

	LEAS ,Y
	LEAU -439,U

	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -81,U
	LDA -120,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -120,U
	LDA 41,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 41,U
	LDX 79,U
	LDY 39,U
	PSHS Y,X
	LDD -41,U
	LDX 119,U
	LDY -1,U
	PSHS U,Y,X,D
	LDD #$aaaa
	STD -41,U
	LDD #$a999
	STD 39,U
	STD 79,U
	LDB #$a9
	STD -1,U
	STD 119,U
	LEAU 180,U

	LDX -21,U
	PSHS X
	LDB #$aa
	STD -21,U
	LDD 18,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 18,U
	LDD 20,U
	PSHS U,D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 20,U
	LEAU 179,U

	LDD -119,U
	PSHS D
	LDA #$a9
	ANDB #$0F
	ORB #$a0
	STD -119,U
	LDD 41,U
	PSHS D
	LDA #$a9
	ANDB #$F0
	ORB #$09
	STD 41,U
	LDX -79,U
	LDY -39,U
	PSHS Y,X
	LDD #$a99a
	STD -79,U
	STD -39,U
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
	LDB #$aa
	STD -41,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$aa
	STD 39,U
	PULU A,X
	PSHS U,X,A
	LDX #$a99a
	PSHU B,X
	LEAU 79,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$ec
	STD 40,U
	LDA 83,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA 83,U
	LDA 123,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 123,U
	LDA 42,U
	LDX 81,U
	LDY 121,U
	PSHS Y,X,A
	LDA #$a9
	STA 42,U
	LDD #$fe99
	STD 81,U
	LDA #$ee
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$ed
	LDX #$aea9
	PSHU A,X
	LEAU 281,U

	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ee
	STD -121,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$ee
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$0F
	ORA #$b0
	LDB #$ee
	STD -41,U
	LDD -1,U
	PSHS D
	ANDA #$0F
	ORA #$b0
	LDB #$ea
	STD -1,U
	LDD 39,U
	PSHS D
	ANDA #$0F
	ORA #$30
	LDB #$ed
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$ea
	STD 79,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$ee
	STD 119,U
	LDA 1,U
	LDB 41,U
	PSHS B,A
	LDA 81,U
	LDB 121,U
	PSHS B,A
	ANDB #$0F
	ORB #$a0
	STB 121,U
	LDD -119,U
	PSHS D
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -119,U
	LDD -79,U
	PSHS D
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -79,U
	LDD -39,U
	PSHS U,D
	LDA #$a9
	ANDB #$0F
	ORB #$90
	STD -39,U
	STA 1,U
	STA 41,U
	STA 81,U
	LEAU 240,U

	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$ee
	STD -81,U
	LDA -79,U
	LDB 80,U
	PSHS B,A
	ANDB #$F0
	ORB #$0d
	STB 80,U
	LDX -40,U
	LDY ,U
	PSHS Y,X
	LDD #$e399
	STD -40,U
	STD ,U
	STB -79,U
	LDD 40,U
	PSHS U,D
	LDA #$d3
	ANDB #$0F
	ORB #$90
	STD 40,U

	LDU <glb_screen_location_1
	LEAU -499,U

	LDD -21,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -21,U
	LDA -61,U
	PSHS A
	LDD 18,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD 18,U
	LDD 58,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 58,U
	LDA 20,U
	STB -61,U
	STB 20,U
	LDB 60,U
	PSHS U,B,A
	LDA #$9a
	STA 60,U
	LEAU 218,U

	LDX -120,U
	LDY -80,U
	PSHS Y,X
	LDA -118,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -118,U
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -78,U
	LDX -40,U
	PSHS X
	LDD #$aa9a
	STD -120,U
	STD -80,U
	STD -40,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$9aaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$af
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$af
	LDX #$aa9a
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ff
	LDX #$aa99
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$aa99
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	PSHS X
	LDB #$aa
	STD 40,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 42,U
	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$aa99
	PSHU A,X
	LEAU 80,U

	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$aa9a
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ce
	LDX #$ea99
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ec
	LDX #$ea99
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$ef
	LDX #$aa99
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	LDA #$ee
	STD 40,U
	LDY 80,U
	PSHS Y,X
	LDB #$99
	STD 80,U
	LDA 122,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 122,U
	LDX 120,U
	PSHS X
	LDD #$eeea
	STD 120,U
	PULU A,X
	PSHS U,X,A
	LDA #$fe
	LDX #$a999
	PSHU A,X
	LEAU 280,U

	LDD -120,U
	PSHS D
	ANDA #$F0
	ORA #$0e
	LDB #$aa
	STD -120,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$99
	STD 80,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$39
	STD 120,U
	LDD -79,U
	PSHS D
	LDA #$ee
	ANDB #$0F
	ORB #$90
	STD -79,U
	LDA -118,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -118,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -38,U
	LDX -40,U
	LDY ,U
	PSHS Y,X
	LDD #$33ee
	STD -40,U
	STD ,U
	LDD 40,U
	PSHS U,D
	LDD #$d339
	STD 40,U
	LEAU 161,U

	LDA ,U
	PSHS U,A
	LDA #$d9
	STA ,U
	LEAU ,S
SSAV_Img_sonic_061_0
	LDS glb_register_s
	RTS
