	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater01_0
	LEAU 697,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDD #$0000
	LDX #$0000
	LDY #$0000
	PSHU D,X,Y
	LDX #$2d2d
	PSHU D,X,Y
	LDD #$bddb
	LDX #$002d
	LDY #$2d00
	PSHU D,X,Y
	LDD #$d208
	LDX #$0dd2
	LDY #$d282
	PSHU D,X,Y
	LDD #$2d00
	LDX #$0000
	LDY #$00c2
	PSHU D,X,Y
	LDA #$f0
	LDX #$002d
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 698,U

	LDD #$0202
	LDX #$0202
	LDY #$0fff
	PSHU D,X,Y
	LDY #$0202
	PSHU D,X,Y
	LDA #$d2
	PSHU D,X,Y
	LDD #$8882
	LDX #$8828
	LDY #$822d
	PSHU D,X,Y
	LDD #$0202
	LDX #$020d
	LDY #$2dd8
	PSHU D,X,Y
	LDA #$ff
	LDX #$0202
	LDY #$0202
	PSHU D,X,Y
	RTS

