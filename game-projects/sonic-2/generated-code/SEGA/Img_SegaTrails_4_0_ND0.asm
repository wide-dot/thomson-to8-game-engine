	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_SegaTrails_4_0
	LEAU 1356,U

	LDD #$ffff
	LDX #$ffff
	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 1356,U

	LDD #$ffff
	LDX #$ffff
	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -76,U

	PSHU D,X
	RTS
