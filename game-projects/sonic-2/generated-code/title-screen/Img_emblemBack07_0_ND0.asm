	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_emblemBack07_0
	LEAU -1428,U

	LDD #$99b8
	STD -8,U
	LDD #$8bdc
	LDX #$0000
	LDY #$0000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$9d88
	STD -8,U
	LDD #$1bdc
	PSHU D,X,Y
	LEAU -34,U

	LDD #$9d88
	STD -8,U
	LDD #$d8cc
	PSHU D,X,Y
	LEAU -34,U

	LDD #$9b88
	STD -8,U
	LDD #$d1cd
	LDY #$00cd
	PSHU D,X,Y
	LEAU -34,U

	LDD #$dc88
	STD -8,U
	LDD #$bbcd
	LDY #$00bc
	PSHU D,X,Y
	LEAU -34,U

	LDD #$bc88
	STD -8,U
	LDD #$d8cb
	LDY #$00bb
	PSHU D,X,Y
	LEAU -34,U

	LDD #$cd88
	STD -8,U
	LDD #$b8cb
	LDY #$000b
	PSHU D,X,Y
	LEAU -34,U

	LDD #$cd88
	STD -8,U
	LDD #$86d0
	LDY #$0000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$cb88
	STD -8,U
	LDD #$87d0
	PSHU D,X,Y
	LEAU -34,U

	LDD #$d888
	STD -8,U
	LDD #$67b0
	PSHU D,X,Y
	LEAU -34,U

	LDD #$b888
	STD -8,U
	LDD #$77b0
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$7d00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$7b00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$7c00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$dc00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$bc00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8186
	STD -8,U
	LDD #$cd00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8b87
	STD -8,U
	LDD #$cd00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$1b67
	STD -8,U
	LDD #$cb00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$dd77
	STD -8,U
	LDD #$db00
	PSHU D,X,Y
	LEAU -34,U

	LDB #$7d
	STD -8,U
	LDD #$bdb0
	PSHU D,X,Y
	LEAU -34,U

	LDA #$d8
	STA -8,U
	LDD -7,U
	LDA #$7d
	ANDB #$0F
	ORB #$c0
	STD -7,U
	LDA #$db
	PSHU A,X,Y
	LEAU -35,U

	LDA #$d6
	STA -8,U
	LDD -7,U
	LDA #$db
	ANDB #$0F
	ORB #$d0
	STD -7,U
	LDD #$bb00
	PSHU D,X
	LEAU -36,U

	LDD #$b7bc
	STD -8,U
	LDD #$1c00
	PSHU D,X
	LEAU -36,U

	LDD #$67cc
	STD -8,U
	LDA #$bb
	PSHU A,X
	LEAU -37,U

	LDD #$77cd
	STD -8,U
	LDD #$7dbc
	STD -88,U
	LDD #$7cdb
	STD -48,U
	LDD #$1c00
	STD -82,U
	LDA #$bb
	STD -42,U
	LDA #$b0
	STA -121,U
	LDD -128,U
	LDA #$db
	ANDB #$0F
	ORB #$c0
	STD -128,U
	LDA #$1c
	PSHU A,X
	LEAU -202,U

	LDA #$db
	STA 44,U
	LDA 4,U
	ANDA #$F0
	ORA #$01
	STA 4,U
	LDD 37,U
	LDA #$bc
	ANDB #$0F
	ORB #$d0
	STD 37,U
	LDA #$cc
	STA -3,U
	LDA #$cd
	STA -43,U

	LDU <glb_screen_location_1
	LEAU -1428,U

	LDD #$bcb8
	STD -8,U
	LDD #$86d0
	LDX #$0000
	LDY #$0000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$cdb1
	STD -8,U
	LDD #$87b0
	PSHU D,X,Y
	LEAU -34,U

	LDD #$cb8d
	STD -8,U
	LDD #$87b0
	PSHU D,X,Y
	LEAU -34,U

	LDD #$cb1d
	STD -8,U
	LDD #$8700
	LDY #$bb1b
	PSHU D,X,Y
	LEAU -34,U

	LDD #$d8bb
	STD -8,U
	LDD #$6d00
	LDY #$0bd1
	PSHU D,X,Y
	LEAU -34,U

	LDD #$b88d
	STD -8,U
	LDD #$7d00
	LDY #$00cd
	PSHU D,X,Y
	LEAU -34,U

	LDD #$888b
	STD -8,U
	LDD #$7b00
	LDY #$00bc
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$7c00
	LDY #$00bb
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$dc00
	LDY #$000b
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$bc00
	LDY #$0000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$cc00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$cd00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8886
	STD -8,U
	LDD #$cd00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8887
	STD -8,U
	LDD #$cb00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8867
	STD -8,U
	LDD #$d000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8877
	STD -8,U
	LDD #$b000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$887d
	STD -8,U
	LDD #$0000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$887d
	STD -8,U
	LDD #$0000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$88db
	STD -8,U
	LDD #$0000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$86dc
	STD -8,U
	LDD #$b000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$17bc
	STD -8,U
	LDD #$cb00
	PSHU D,X,Y
	LEAU -34,U

	LDD #$67cd
	STD -8,U
	LDA #$bb
	PSHU A,X,Y
	LEAU -35,U

	LDD #$77cb
	STD -8,U
	LDA #$1c
	PSHU A,X,Y
	LEAU -35,U

	LDD #$77dc
	STD -8,U
	LDD #$bb00
	PSHU D,X
	LEAU -36,U

	LDD #$7dbd
	STD -8,U
	LDD #$1c00
	PSHU D,X
	LEAU -36,U

	LDD -8,U
	LDA #$db
	ANDB #$0F
	ORB #$c0
	STD -8,U
	LDA #$bb
	PSHU A,X
	LEAU -37,U

	LDD -8,U
	LDA #$bc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDD #$bb00
	STD -42,U
	LDA #$b0
	STA -121,U
	LDA #$1c
	STD -82,U
	LDA #$cc
	STA -48,U
	LDA #$cd
	STA -88,U
	LDA #$1c
	PSHU A,X
	LEAU -165,U

	LDA -33,U
	ANDA #$F0
	ORA #$0d
	STA -33,U
	LDA -40,U
	ANDA #$0F
	ORA #$c0
	STA -40,U
	LDA #$cb
	STA 7,U
	LDA #$0c
	STA ,U
	LDA #$db
	STA 40,U
	RTS

