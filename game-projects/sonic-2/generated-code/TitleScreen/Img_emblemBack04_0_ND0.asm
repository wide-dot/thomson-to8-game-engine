	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_emblemBack04_0
	LEAU -2715,U

	LDD #$8888
	LDX #$8677
	LDY #$dbd0
	PSHU D,X,Y
	LDA #$dc
	LDX #$c77b
	PSHU A,X
	LEAU -31,U

	LDD #$6666
	LDX #$6777
	LDY #$bc0d
	PSHU D,X,Y
	LDD -36,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -36,U
	LDA #$0d
	LDX #$dc77
	PSHU A,X
	LEAU -33,U

	LDA #$c0
	STA -7,U
	LDD #$bd77
	LDX #$7777
	LDY #$777c
	PSHU D,X,Y
	LEAU -33,U

	LDD -8,U
	ANDA #$F0
	ORA #$0c
	LDB #$cb
	STD -8,U
	LDD #$c777
	LDY #$ddcd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$dc
	STA -7,U
	LDA #$dd
	LDX #$777c
	LDY #$bbd0
	PSHU D,X,Y
	LEAU -34,U

	LDA #$0d
	STA -7,U
	LDD #$bbdd
	LDX #$dddd
	LDY #$cc0d
	PSHU D,X,Y
	LEAU -35,U

	LDD #$d0dc
	LDX #$bbbb
	LDY #$bbdd
	PSHU D,X,Y
	LEAU -34,U

	LDD -42,U
	LDA #$d0
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDA #$0d
	LDX #$cccc
	LDY #$cd00
	PSHU A,X,Y
	LEAU -37,U

	LDA #$c0
	LDX #$dddd
	PSHU A,X
	LEAU -36,U

	LDA #$00
	LDX #$000c
	PSHU A,X

	LDU <glb_screen_location_1
	LEAU -2717,U

	LDD ,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD ,U
	LDD #$cbbd
	STD -8,U
	LDD #$77b8
	LDX #$8888
	LDY #$d677
	PSHU D,X,Y
	LEAU -33,U

	LDD #$cb77
	STD -8,U
	LDA -9,U
	ANDA #$F0
	ORA #$0c
	STA -9,U
	LDD #$7666
	LDX #$66b7
	LDY #$7dcd
	PSHU D,X,Y
	LEAU -34,U

	LDD #$dcd7
	STD -8,U
	LDD #$7777
	LDX #$7777
	LDY #$dbd0
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0dbd
	STD -8,U
	LDD -42,U
	LDA #$cd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD #$7777
	LDY #$bc0d
	PSHU D,X,Y
	LEAU -36,U

	LDD #$c0cb
	LDX #$d777
	LDY #$77dd
	PSHU D,X,Y
	LEAU -33,U

	LDA -7,U
	ANDA #$F0
	ORA #$0c
	STA -7,U
	LDD #$dcbd
	LDX #$dddd
	LDY #$bbd0
	PSHU D,X,Y
	LEAU -34,U

	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD #$0dcb
	LDX #$bbbb
	LDY #$cc0c
	PSHU D,X,Y
	LEAU -36,U

	LDD #$c0dc
	LDX #$cccc
	PSHU D,X
	LEAU -35,U

	LDD #$0ddd
	LDX #$dd00
	PSHU D,X
	LEAU -37,U

	LDA #$d0
	LDX #$0000
	PSHU A,X
	RTS

