	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater06_0
	LEAU 897,U

	LDA -7,U
	ANDA #$F0
	ORA #$0f
	STA -7,U
	LDD #$2fff
	LDX #$2fff
	LDY #$2fff
	PSHU D,X,Y
	LEAU -2,U

	LDA -5,U
	ANDA #$F0
	ORA #$0f
	STA -5,U
	PSHU X,Y
	LEAU -2,U

	LDD #$c22f
	LDX #$dfff
	LDY #$fcff
	PSHU D,X,Y
	LDD #$2fff
	STD -11,U
	LDD -8,U
	ANDA #$F0
	ORA #$0f
	LDB #$2f
	STD -8,U
	LDA -12,U
	ANDA #$F0
	ORA #$0f
	STA -12,U
	LDD #$ff2f
	LDX #$ccdd
	LDY #$ffdf
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 895,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDD -8,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD -8,U
	LDX #$ffff
	LDY #$ffff
	PSHU A,X,Y
	LEAU -3,U

	PSHU A,X
	LEAU -1,U

	LDD #$82cd
	LDX #$22ff
	PSHU D,X,Y
	STY -8,U
	LDA #$ff
	STA -12,U
	LDD -11,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD -11,U
	LDD #$ffcc
	LDX #$b2cd
	LDY #$fdd8
	PSHU D,X,Y
	RTS

