	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater04_0
	LEAU 817,U

	LDD #$cfff
	LDX #$ffff
	LDY #$cfff
	PSHU D,X,Y
	LDX #$cfc2
	PSHU D,X,Y
	LDD #$2d22
	LDX #$ccff
	LDY #$c2cf
	PSHU D,X,Y
	LDD #$2f28
	LDX #$2dd0
	LDY #$f2bf
	PSHU D,X,Y
	LDD #$ffcf
	STD -8,U
	LDA #$c2
	LDX #$ffcf
	LDY #$ffcf
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 813,U

	LDD 2,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD 2,U
	LDD ,U
	ANDA #$0F
	ORA #$f0
	LDB #$fc
	STD ,U
	LDD #$c2cc
	LDX #$fffc
	LDY #$fffc
	PSHU D,X,Y
	LDD #$ffc2
	LDX #$ccfc
	PSHU D,X,Y
	LDD #$db2d
	LDX #$d282
	LDY #$2822
	PSHU D,X,Y
	LDD #$fcff
	LDX #$fccc
	LDY #$cc0b
	PSHU D,X,Y
	LDB #$c2
	LDX #$ccff
	PSHU D,X
	RTS

