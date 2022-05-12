	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater03_0
	LEAU 777,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDD #$cfc2
	LDX #$cfc2
	LDY #$cfc2
	PSHU D,X,Y
	LDX #$cfff
	LDY #$ffc2
	PSHU D,X,Y
	LDD #$f8cc
	LDX #$ccc2
	LDY #$ffff
	PSHU D,X,Y
	LDD #$208c
	LDX #$dc2f
	LDY #$d2dd
	PSHU D,X,Y
	LDD #$ffff
	LDX #$c2cf
	LDY #$c2cf
	PSHU D,X,Y
	LDA -4,U
	ANDA #$F0
	ORA #$0f
	STA -4,U
	LDA #$cf
	PSHU A,X

	LDU <glb_screen_location_1
	LEAU 778,U

	LDD #$bfbf
	LDX #$bfbf
	LDY #$bfff
	PSHU D,X,Y
	LDB #$f0
	LDX #$f2bf
	LDY #$bfbf
	PSHU D,X,Y
	LDD #$ccbf
	LDX #$f0f2
	PSHU D,X,Y
	LDD #$8fdf
	LDX #$df22
	LDY #$ddcc
	PSHU D,X,Y
	LDD #$bfbf
	LDX #$bfbf
	LDY #$c20f
	PSHU D,X,Y
	LDA #$ff
	LDY #$f0f2
	PSHU A,X,Y
	RTS

