	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_068_0
	STS glb_register_s

	LEAS ,Y
	LEAU -181,U

	LDD -60,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -60,U
	LDX -20,U
	LDD #$9aa9
	STD -20,U
	LDY 20,U
	PSHS Y,X
	LDD 60,U
	PSHS U,D
	LDD #$aaaa
	STD 20,U
	STD 60,U
	LEAU 220,U

	LDX -120,U
	LDY -80,U
	PSHS Y,X
	STD -120,U
	STD -80,U
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -78,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$a0
	STA -38,U
	LDX -40,U
	PSHS X
	LDD #$afaa
	STD -40,U
	PULU A,X
	PSHS U,X,A
	LDA #$af
	LDX #$aaa9
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$af
	LDX #$aaa9
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
	LDX #$aaa9
	PSHU B,X
	LEAU 40,U

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
	LDX #$aaaa
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$a9
	LDX #$aaa9
	PSHU A,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$9a
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD 80,U
	LDA 42,U
	LDB 82,U
	LDX 121,U
	PSHS X,B,A
	LDA #$a9
	STA 42,U
	LDD #$9999
	STD 121,U
	STA 82,U
	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aaa9
	PSHU A,X
	LEAU 221,U

	LDX -60,U
	LDY -20,U
	PSHS Y,X
	LDD 20,U
	PSHS D
	LDD #$9999
	STD -60,U
	STD -20,U
	STD 20,U
	LDD 60,U
	PSHS U,D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD 60,U

	LDU <glb_screen_location_1
	LEAU -241,U

	LDA ,U
	PSHS U,A
	LDA #$99
	STA ,U
	LEAU 159,U

	LDD -80,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD -80,U
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -40,U
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -78,U
	LDA -38,U
	PSHS A
	LDA #$a9
	STA -38,U
	LDA -119,U
	STB -119,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$9a
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aaaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$faaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$faaa
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
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
	LDA #$aa
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
	LDA #$9a
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
	LDA #$9a
	LDX #$aaaa
	PSHU A,X
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
	LDB #$aa
	STD 80,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$aa
	STD 120,U
	LDX 42,U
	LDY 82,U
	PSHS Y,X
	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 3,U
	LDX 122,U
	PSHS X
	LDD #$aa99
	STD 42,U
	STD 82,U
	STD 122,U
	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aaaa
	PSHU A,X
	LEAU 161,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$aa99
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$aa99
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$aa99
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$a999
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$9a
	LDX #$aa99
	PSHU A,X
	LEAU 40,U

	LDX 40,U
	PSHS X
	LDA #$99
	STD 40,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 42,U
	LDA 82,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 82,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 80,U
	LDA 121,U
	STB 121,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU 161,U

	LDA ,U
	PSHS U,A
	LDA #$99
	STA ,U
	LEAU ,S
SSAV_Img_sonic_068_0
	LDS glb_register_s
	RTS
