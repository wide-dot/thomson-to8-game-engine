	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00004_DN0
	LEAU 604,U

	LDD #$5555
	LDX #$5555
	PSHU D,X
	LEAU -36,U

	LDB #$44
	LDX #$5444
	PSHU D,X
	LEAU -36,U

	LDX #$4444
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDX #$4400
	PSHU D,X
	LEAU -36,U

	LDX #$4455
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

	LDX #$0444
	PSHU D,X
	LEAU -36,U

	LDB #$00
	LDX #$5000
	PSHU D,X
	LEAU -36,U

	LDB #$55
	LDX #$5555
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 604,U

	LDD #$5555
	LDX #$5555
	PSHU D,X
	LEAU -36,U

	LDA #$54
	LDX #$4455
	PSHU D,X
	LEAU -36,U

	LDX #$4045
	PSHU D,X
	LEAU -36,U

	LDX #$4545
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDX #$4505
	PSHU D,X
	LEAU -36,U

	LDX #$4555
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

	LDX #$4545
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDX #$4405
	PSHU D,X
	LEAU -36,U

	LDA #$50
	LDX #$0055
	PSHU D,X
	LEAU -36,U

	LDA #$55
	LDX #$5555
	PSHU D,X
	RTS
