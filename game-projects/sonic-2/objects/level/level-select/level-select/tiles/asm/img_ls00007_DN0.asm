	INCLUDE "./engine/constants.asm"
	OPT C,CT
adr_img_ls00007_DN0
	LEAU 604,U

	LDD #$5555
	LDX #$5555
	PSHU D,X
	LEAU -36,U

	LDD #$4444
	LDX #$5444
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDB #$40
	PSHU D,X
	LEAU -36,U

	LDB #$45
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDD #$0005
	PSHU D,X
	LEAU -36,U

	LDD #$4444
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDB #$00
	PSHU D,X
	LEAU -36,U

	LDB #$44
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDD #$0000
	LDX #$5000
	PSHU D,X
	LEAU -36,U

	LDD #$5555
	LDX #$5555
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 604,U

	LDD #$5555
	LDX #$5555
	PSHU D,X
	LEAU -36,U

	LDD #$4444
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

	LDA #$00
	PSHU D,X
	LEAU -36,U

	LDA #$44
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDD #$0000
	PSHU D,X
	LEAU -36,U

	LDD #$5444
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDA #$44
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDD #$0000
	LDX #$0005
	PSHU D,X
	LEAU -36,U

	LDD #$5555
	LDX #$5555
	PSHU D,X
	RTS
