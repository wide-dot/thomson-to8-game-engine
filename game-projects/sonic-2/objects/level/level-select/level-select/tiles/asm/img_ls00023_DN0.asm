	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00023_DN0
	LEAU 604,U

	LDD #$5555
	LDX #$5555
	PSHU D,X
	LEAU -36,U

	LDX #$4455
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDX #$4445
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDX #$4444
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDX #$4404
	PSHU D,X
	LEAU -36,U

	LDX #$4450
	PSHU D,X
	LEAU -36,U

	LDX #$0055
	PSHU D,X
	LEAU -36,U

	LDX #$5555
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 604,U

	LDD #$5555
	LDX #$5555
	PSHU D,X
	LEAU -36,U

	LDX #$4544
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDX #$4444
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDX #$4044
	PSHU D,X
	LEAU -36,U

	LDX #$0500
	PSHU D,X
	LEAU -36,U

	LDX #$5555
	PSHU D,X
	RTS

