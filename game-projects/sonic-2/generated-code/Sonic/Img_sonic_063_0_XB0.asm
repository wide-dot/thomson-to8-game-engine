	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_063_0
	STS glb_register_s

	LEAS ,Y
	LEAU -458,U

	LDX 18,U
	LDY -22,U
	PSHS Y,X
	LDD 58,U
	LDX -62,U
	PSHS X,D
	LDD 98,U
	PSHS D
	LDA #$aa
	ANDB #$0F
	ORB #$f0
	STD 98,U
	LDA -101,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA -101,U
	LDA 100,U
	PSHS U,A
	ANDA #$0F
	ORA #$30
	STA 100,U
	LDD #$aa3f
	STD -22,U
	LDB #$bb
	STD -62,U
	LDB #$f3
	STD 18,U
	LDB #$ed
	STD 58,U
	LEAU 257,U

	LDX -119,U
	PSHS X
	LDB #$ee
	STD -119,U
	LDA -117,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA -117,U
	LDA 3,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 3,U
	LDD -78,U
	PSHS D
	LDA #$fe
	ANDB #$0F
	ORB #$d0
	STD -78,U
	LDD -38,U
	PSHS D
	LDA #$ef
	ANDB #$F0
	ORB #$03
	STD -38,U
	LDD -80,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$aa
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$aa
	STD -40,U
	PULU A,X
	PSHS U,X,A
	LDX #$aaee
	PSHU B,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDX #$aafe
	PSHU B,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA 3,U
	LDD 122,U
	PSHS D
	LDA #$ea
	ANDB #$0F
	ORB #$d0
	STD 122,U
	LDA 42,U
	LDB 82,U
	PSHS B,A
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
	LDB #$aa
	STD 80,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD 120,U
	LDA #$ee
	STA 42,U
	STA 82,U
	PULU A,X
	PSHS U,X,A
	LDX #$aaee
	PSHU B,X
	LEAU 240,U

	LDX -79,U
	PSHS X
	LDD #$aaea
	STD -79,U
	LDA -38,U
	LDB -77,U
	PSHS B,A
	ANDB #$0F
	ORB #$d0
	STB -77,U
	LDD -40,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$aa
	STD -40,U
	STB -38,U
	PULU A,X
	PSHS U,X,A
	LDX #$aaaa
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	LDX 81,U
	LDA #$9a
	STD 81,U
	LDY 121,U
	PSHS Y,X
	LDB #$a9
	STD 121,U
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
	LDA #$99
	LDX #$aaaa
	PSHU A,X
	LEAU 261,U

	LDA -19,U
	LDB 100,U
	LDX -100,U
	LDY -60,U
	PSHS Y,X,B,A
	LDD -21,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$a9
	STD -21,U
	LDA #$e9
	STA -19,U
	LDA #$aa
	STD -100,U
	STD -60,U
	LDD 20,U
	PSHS D
	LDA #$99
	ANDB #$0F
	ORB #$e0
	STD 20,U
	LDD 60,U
	PSHS U,D
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 60,U
	STA 100,U

	LDU <glb_screen_location_1
	LEAU -459,U

	LDD 18,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$33
	STD 18,U
	LDD 58,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$ff
	STD 58,U
	LDD 98,U
	PSHS D
	ANDA #$0F
	ORA #$a0
	LDB #$ef
	STD 98,U
	LDA -61,U
	LDB 100,U
	PSHS B,A
	LDA -101,U
	PSHS A
	LDD -21,U
	PSHS D
	LDA #$ab
	ANDB #$0F
	ORB #$30
	STD -21,U
	STA -101,U
	LDA 60,U
	LDB 20,U
	PSHS U,B,A
	LDA #$d3
	STA 100,U
	LDA #$33
	STA 20,U
	STA 60,U
	LDA #$bb
	STA -61,U
	LEAU 258,U

	LDX -120,U
	LDY -80,U
	PSHS Y,X
	LDA -118,U
	PSHS A
	ANDA #$F0
	ORA #$0d
	STA -118,U
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA -78,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA -38,U
	LDD #$aaf9
	STD -120,U
	LDB #$ed
	STD -80,U
	LDX -40,U
	PSHS X
	LDB #$ea
	STD -40,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$99ee
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$af
	LDX #$aaee
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	LDY 80,U
	PSHS Y,X
	LDB #$ac
	STD 80,U
	LDD #$ffae
	STD 40,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 119,U
	LDX 121,U
	PSHS X
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 42,U
	LDA 82,U
	PSHS A
	ANDA #$0F
	ORA #$e0
	STA 82,U
	LDD #$aead
	STD 121,U
	PULU A,X
	PSHS U,X,A
	LDA #$ff
	LDX #$9aee
	PSHU A,X
	LEAU 280,U

	LDX -79,U
	LDY -39,U
	PSHS Y,X
	LDA #$aa
	STD -79,U
	STD -39,U
	LDD -119,U
	PSHS D
	LDD #$aeae
	STD -119,U
	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -121,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -81,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD -41,U
	PULU A,X
	PSHS U,X,A
	LDX #$aaaa
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$aaaa
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aaa9
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$99
	LDX #$aaa9
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$99
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$99
	STD 80,U
	LDA 82,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 82,U
	LDA 122,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 122,U
	LDX 120,U
	PSHS X
	LDD #$aa99
	STD 120,U
	LDA 42,U
	STB 42,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$99
	LDX #$a9a9
	PSHU A,X
	LEAU 221,U

	LDD 19,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 19,U
	LDA 60,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 60,U
	LDX -61,U
	LDD #$9a99
	STD -61,U
	LDY -21,U
	PSHS U,Y,X
	LDA #$99
	STD -21,U
	LEAU ,S
SSAV_Img_sonic_063_0
	LDS glb_register_s
	RTS
