	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSShadow_000_0
	STS glb_register_s

	LEAS ,Y
	LEAU -82,U

	LDX -119,U
	LDY -79,U
	PSHS Y,X
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD -40,U
	LDX -38,U
	PSHS X
	LDA -77,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA -77,U
	LDD #$2222
	STD -119,U
	STD -79,U
	STD -38,U
	PULU X,Y
	PSHS U,Y,X
	LDX #$2222
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$2222
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$2222
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$2222
	PSHU D,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$02
	LDB #$22
	STD 40,U
	LDX 42,U
	LDY 81,U
	PSHS Y,X
	LDD 121,U
	PSHS D
	LDA 83,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA 83,U
	LDD #$2222
	STD 42,U
	STD 81,U
	STD 121,U
	PULU X,Y
	PSHS U,Y,X
	LDX #$2222
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU -162,U

	LDD -39,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD -39,U
	PULU A,X
	PSHS U,X,A
	LDA #$22
	LDX #$2222
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$22
	LDX #$2222
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$22
	LDX #$2222
	PSHU A,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$2222
	LDX #$2222
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$2222
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$2222
	PSHU D,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$20
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDX #$2222
	PSHU B,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$2222
	PSHU B,X
	LEAU 40,U

	LDD 41,U
	PSHS D
	LDA #$22
	ANDB #$0F
	ORB #$20
	STD 41,U
	PULU A,X
	PSHS U,X,A
	LDA #$22
	LDX #$2222
	PSHU A,X
	LEAU ,S
SSAV_Img_SSShadow_000_0
	LDS glb_register_s
	RTS
