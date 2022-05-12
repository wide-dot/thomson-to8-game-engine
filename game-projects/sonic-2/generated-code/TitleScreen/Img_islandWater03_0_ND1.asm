	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater03_0
	LEAU 779,U

	LDD #$fcfc
	LDX #$fcfc
	LDY #$ffff
	PSHU D,X,Y
	LDB #$0f
	LDX #$2ffc
	LDY #$fcfc
	PSHU D,X,Y
	LDD #$ccfc
	LDX #$0f2f
	PSHU D,X,Y
	LDD #$fdf2
	LDX #$fd2d
	LDY #$dfcc
	PSHU D,X,Y
	LDD #$fcfc
	LDX #$fcfc
	LDY #$22f8
	PSHU D,X,Y
	LDY #$0f2f
	PSHU A,X,Y

	LDU <glb_screen_location_1
	LEAU 778,U

	LDD #$2bfb
	LDX #$2bfb
	LDY #$2bff
	PSHU D,X,Y
	LDB #$ff
	LDX #$fffb
	LDY #$2bfb
	PSHU D,X,Y
	LDD #$cccb
	LDX #$2fff
	LDY #$fbfb
	PSHU D,X,Y
	LDD #$c8cd
	LDX #$fd22
	LDY #$dd8c
	PSHU D,X,Y
	LDD #$fb2b
	LDX #$fb2b
	LDY #$fc00
	PSHU D,X,Y
	LDA #$ff
	LDY #$ffff
	PSHU A,X,Y
	RTS

