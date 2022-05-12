	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater05_0
	LEAU 856,U

	LDA -7,U
	ANDA #$F0
	ORA #$0f
	STA -7,U
	LDA -11,U
	ANDA #$F0
	ORA #$0f
	STA -11,U
	LDD #$bfff
	STD -10,U
	LDX #$bfff
	LDY #$bfff
	PSHU D,X,Y
	LEAU -6,U

	LDD #$ccc2
	LDX #$c2ff
	PSHU D,X,Y
	LDD #$fff8
	LDX #$2f22
	LDY #$2dcb
	PSHU D,X,Y
	LDD #$bfff
	STD -7,U
	LDA -4,U
	ANDA #$F0
	ORA #$0f
	STA -4,U
	LDA -8,U
	ANDA #$F0
	ORA #$0f
	STA -8,U
	LDA #$bf
	LDX #$ffbf
	PSHU A,X

	LDU <glb_screen_location_1
	LEAU 854,U

	LDA #$ff
	STA -9,U
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
	LDD -12,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD -12,U
	LDX #$ffff
	LDY #$ffff
	PSHU A,X,Y
	LEAU -7,U

	LDD #$ddcb
	LDX #$282c
	LDY #$cfff
	PSHU D,X,Y
	LDD #$ffff
	STD -8,U
	STA -12,U
	LDD -11,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD -11,U
	LDD #$ffff
	LDX #$fd2c
	LDY #$fc22
	PSHU D,X,Y
	RTS

