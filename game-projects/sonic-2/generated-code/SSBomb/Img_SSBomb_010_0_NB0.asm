	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_SSBomb_010_0
	STS glb_register_s

	LEAS ,Y
	LEAU -600,U

	LDA ,U
	PSHS U,A
	LDA #$99
	STA ,U
	LEAU 159,U

	LDX 41,U
	LDY 81,U
	PSHS Y,X
	LDD 121,U
	LDX -40,U
	LDY -120,U
	PSHS Y,X,D
	LDA -78,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA -78,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$00
	STA -38,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$90
	STD 39,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$00
	STD 79,U
	LDD 119,U
	PSHS D
	ANDA #$F0
	ORA #$08
	LDB #$00
	STD 119,U
	LDD #$0090
	STD 81,U
	STD 121,U
	LDB #$99
	STD 41,U
	LDD #$8900
	STD -120,U
	LDX -80,U
	PSHS X
	LDA #$99
	STD -80,U
	LDA #$90
	STD -40,U
	PULU A,X
	PSHS U,X,A
	LDX #$0009
	PSHU B,X
	LEAU 199,U

	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$00
	STD -40,U
	LDX -38,U
	PSHS X
	LDD #$0000
	STD -38,U
	PULU D,X
	PSHS U,X,D
	LDD #$7809
	LDX #$0000
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$7999
	LDX #$0000
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$5990
	LDX #$0000
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$5899
	LDX #$9000
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$90
	LDX #$0000
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$5799
	LDX #$9090
	PSHU D,X
	LEAU 40,U

	LDX 42,U
	LDY 122,U
	PSHS Y,X
	LDA #$98
	STD 122,U
	LDD 82,U
	PSHS D
	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$07
	LDB #$59
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$89
	STD 80,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$89
	STD 120,U
	LDD #$0989
	STD 42,U
	LDA #$99
	STD 82,U
	PULU X,Y
	PSHS U,Y,X
	LDA #$57
	LDX #$9999
	PSHU D,X
	LEAU 200,U

	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$85
	STD -40,U
	LDX -38,U
	PSHS X
	LDD #$8887
	STD -38,U
	PULU D,X
	PSHS U,X,D
	LDD #$5575
	LDX #$9897
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$5455
	LDX #$8997
	PSHU D,X
	LEAU 40,U

	LDX 42,U
	LDY 82,U
	PSHS Y,X
	LDA #$58
	STD 82,U
	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$87
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$58
	STD 80,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$55
	STD 120,U
	LDD #$9575
	STD 42,U
	LDX 122,U
	PSHS X
	LDD #$5744
	STD 122,U
	PULU D,X
	PSHS U,X,D
	LDD #$5477
	LDX #$9975
	PSHU D,X
	LEAU 262,U

	LDX 59,U
	LDY -21,U
	PSHS Y,X
	LDD 19,U
	LDX -101,U
	LDY -61,U
	PSHS Y,X,D
	LDD #$4544
	STD -61,U
	STD -21,U
	LDA #$54
	STD 19,U
	LDA #$44
	STD 59,U
	LDA -99,U
	PSHS A
	ANDA #$0F
	ORA #$40
	STA -99,U
	LDA -19,U
	PSHS A
	ANDA #$F0
	ORA #$04
	STA -19,U
	LDA 61,U
	PSHS A
	ANDA #$0F
	ORA #$40
	STA 61,U
	LDA 100,U
	PSHS U,A
	ANDA #$F0
	ORA #$04
	STA 100,U
	LDD #$5555
	STD -101,U

	LDU <glb_screen_location_1
	LEAU -522,U

	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$90
	STD -40,U
	LDA -38,U
	LDX -79,U
	PSHS X,A
	LDD #$9098
	STD -79,U
	LDA #$09
	STA -38,U
	PULU A,X
	PSHS U,X,A
	LDA #$55
	LDX #$9009
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$88
	LDX #$0000
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$79
	LDX #$0000
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$89
	LDX #$0000
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$00
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$89
	LDX #$0000
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$90
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$89
	LDX #$0000
	PSHU A,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$9000
	LDX #$0009
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDX #$0009
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$00
	LDX #$0009
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$09
	LDX #$0009
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$90
	LDX #$0095
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$09
	LDX #$0099
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$9990
	LDX #$0089
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$8500
	LDX #$9958
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$8790
	LDX #$9958
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$00
	LDX #$9998
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$7908
	LDX #$0755
	PSHU D,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$50
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$79
	LDX #$7879
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$50
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$55
	LDX #$9998
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$50
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$78
	LDX #$8895
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$40
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$55
	LDX #$8705
	PSHU A,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$97
	LDX #$8844
	PSHU D,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$40
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$44
	LDX #$5887
	PSHU A,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$40
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$44
	LDX #$5575
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$44
	LDX #$5555
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$44
	LDX #$5445
	PSHU A,X
	LEAU 40,U

	LDD 81,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$4040
	STD 81,U
	LDD 40,U
	PSHS D
	ANDA #$0F
	ORA #$40
	LDB #$44
	STD 40,U
	LDA 42,U
	PSHS A
	ANDA #$0F
	ORA #$40
	STA 42,U
	PULU A,X
	PSHS U,X,A
	LDX #$5544
	PSHU B,X
	LEAU ,S
SSAV_Img_SSBomb_010_0
	LDS glb_register_s
	RTS
