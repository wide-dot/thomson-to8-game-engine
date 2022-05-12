	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_emblemFront07_0
	LEAU 3161,U

	LDD ,U
	LDA #$11
	ANDB #$0F
	ORB #$10
	STD ,U
	LDD -40,U
	LDA #$11
	ANDB #$0F
	ORB #$10
	STD -40,U
	LDX #$1111
	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -35,U

	LDY #$1111
	PSHU A,X,Y
	LEAU -35,U

	LDA #$bb
	LDX #$bbbb
	LDY #$bbbb
	PSHU A,X,Y
	LEAU -35,U

	LDA #$dd
	LDX #$dddd
	LDY #$dddb
	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -35,U

	LDY #$ddd0
	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -35,U

	LDX #$1111
	LDY #$1110
	PSHU A,X,Y
	LEAU -35,U

	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -42,U
	LDX #$00bb
	LDY #$0b00
	PSHU A,X,Y
	LEAU -37,U

	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$b0
	STD -40,U
	LDX #$dddd
	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -35,U

	LDY #$ddd1
	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -35,U

	LDA #$1d
	LDY #$dddb
	PSHU A,X,Y

	LDU <glb_screen_location_1
	LEAU 3162,U

	LDD #$1111
	LDX #$1111
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$1111
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$1111
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$0b
	STA -5,U
	LDD #$bbbb
	LDX #$bbbb
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dddd
	LDX #$dddd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dddd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dddd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dddd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dddd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dddd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dddd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dddd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dd11
	LDX #$1111
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dd0b
	LDX #$bbbb
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$dddd
	LDX #$dddb
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$00
	STA -5,U
	LDD #$dddd
	LDX #$dddd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$00
	STA -5,U
	LDD #$dcdd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$00
	STA -5,U
	LDD #$dcdd
	PSHU D,X
	LEAU -36,U

	LDA #$dd
	PSHU D,X
	RTS

