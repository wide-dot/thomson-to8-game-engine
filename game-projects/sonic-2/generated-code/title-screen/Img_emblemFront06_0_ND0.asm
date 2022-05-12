	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_emblemFront06_0
	LEAU 2403,U

	LDA #$1d
	LDX #$dddd
	LDY #$dddb
	PSHU A,X,Y
	LEAU -35,U

	LDA #$01
	LDX #$bddd
	PSHU A,X,Y
	LEAU -35,U

	LDA #$10
	PSHU A,X,Y
	LEAU -35,U

	LDA #$11
	LDX #$1111
	LDY #$1ddb
	PSHU A,X,Y
	LEAU -35,U

	LDD #$bddb
	STD -42,U
	STX -45,U
	LDA #$11
	LDX #$0bbb
	LDY #$bddb
	PSHU A,X,Y
	LEAU -75,U

	LDA #$bb
	LDX #$1111
	PSHU A,X,Y
	LEAU -35,U

	LDA #$dd
	PSHU A,X,Y
	LEAU -35,U

	LDY #$0cdb
	PSHU A,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$01
	STA -6,U
	LDD -41,U
	LDA #$db
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDA #$dd
	LDX #$bbbb
	LDY #$cbdb
	PSHU A,X,Y
	LEAU -36,U

	LDA #$1b
	LDX #$dddd
	LDY #$ddbd
	PSHU A,X,Y
	LEAU -33,U

	LDA #$bc
	STA -7,U
	LDD #$dddd
	LDX #$ccbd
	LDY #$dbb1
	PSHU D,X,Y
	LEAU -34,U

	LDA #$cc
	STA -7,U
	LDA #$dd
	LDX #$cbbd
	LDY #$dbcb
	PSHU D,X,Y
	LEAU -34,U

	LDD -8,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -8,U
	LDD #$dddd
	LDX #$bbbd
	LDY #$dbcc
	PSHU D,X,Y
	LEAU -34,U

	LDD #$dbbb
	STD -8,U
	LDD #$dddc
	LDX #$bbcd
	LDY #$18dc
	PSHU D,X,Y
	LEAU -34,U

	LDD #$bc88
	STD -8,U
	LDD #$ddcb
	LDX #$00cd
	LDY #$18bd
	PSHU D,X,Y
	LEAU -34,U

	LDD #$cd88
	STD -8,U
	LDD #$1dbb
	LDX #$00bc
	LDY #$088b
	PSHU D,X,Y
	LEAU -34,U

	LDD #$db88
	STD -8,U
	LDD #$01bb
	LDY #$8888
	PSHU D,X,Y
	LEAU -34,U

	LDD #$b888
	STD -8,U
	LDD #$8011
	LDX #$1111
	PSHU D,X,Y
	LEAU -34,U

	LDD #$6888
	STD -8,U
	LDD #$8800
	LDX #$0000
	PSHU D,X,Y
	LEAU -34,U

	LDD #$6666
	STD -8,U
	LDX #$0066
	LDY #$6666
	PSHU D,X,Y
	LEAU -34,U

	LDD #$7777
	STD -8,U
	LDX #$8877
	LDY #$7777
	PSHU D,X,Y
	LEAU -34,U

	LDA #$37
	STD -8,U
	LDA #$77
	LDX #$6677
	PSHU D,X,Y
	LEAU -34,U

	LDD #$3333
	STD -8,U
	LDX #$2233
	LDY #$3333
	PSHU D,X,Y
	LEAU -34,U

	LDD #$2222
	STD -8,U
	LDX #$2722
	LDY #$2222
	PSHU D,X,Y
	LEAU -34,U

	LDD #$1111
	STD -8,U
	LDA #$21
	LDX #$1111
	LDY #$1111
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0100
	STD -8,U
	LDD #$2010
	LDX #$0000
	LDY #$0101
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0100
	STD -8,U
	LDD #$2010
	LDY #$1100
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0011
	STD -8,U
	LDD #$2010
	LDX #$0110
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0001
	STD -8,U
	LDD #$2010
	LDY #$0100
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0111
	STD -8,U
	LDD #$2010
	LDX #$0111
	LDY #$1100
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0100
	STD -8,U
	LDD #$2010
	LDX #$0000
	LDY #$0101
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 2402,U

	LDD #$dddd
	LDX #$dddd
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -36,U

	LDA #$1d
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD #$b111
	LDX #$11dd
	PSHU D,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$01
	STA -5,U
	LDD -42,U
	ANDA #$F0
	ORA #$01
	LDB #$dd
	STD -42,U
	LDD -45,U
	ANDA #$F0
	ORA #$01
	LDB #$11
	STD -45,U
	LDD #$1bbb
	LDX #$bbdd
	PSHU D,X
	LEAU -76,U

	LDX #$bb11
	LDY #$11cd
	PSHU A,X,Y
	LEAU -35,U

	LDA #$11
	LDX #$dd11
	PSHU A,X,Y
	LEAU -35,U

	LDD -41,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDA #$11
	LDY #$11dd
	PSHU A,X,Y
	LEAU -36,U

	LDD #$d1dd
	LDX #$0bbb
	PSHU D,X
	LEAU -34,U

	LDA #$b1
	LDX #$bcdc
	LDY #$ddbd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$1d
	STA -7,U
	LDA #$c1
	LDX #$bbcb
	LDY #$ddcb
	PSHU D,X,Y
	LEAU -33,U

	LDD #$dbd1
	STD -8,U
	LDD #$ddbb
	LDX #$bbdd
	LDY #$dc1f
	PSHU D,X,Y
	LEAU -34,U

	LDD #$bcb1
	STD -8,U
	LDD #$ddcb
	LDX #$b0dd
	LDY #$bdb1
	PSHU D,X,Y
	LEAU -34,U

	LDD #$cd80
	STD -8,U
	LDD #$ddbb
	LDY #$8bcb
	PSHU D,X,Y
	LEAU -34,U

	LDD #$db80
	STD -8,U
	LDD #$dcb0
	LDX #$0bdd
	LDY #$88cc
	PSHU D,X,Y
	LEAU -34,U

	LDD #$b888
	STD -8,U
	LDD #$cbb0
	LDY #$88dc
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$bb00
	LDX #$0bc1
	LDY #$88bd
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$1111
	LDX #$1110
	LDY #$888b
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$0000
	LDX #$0008
	LDY #$8886
	PSHU D,X,Y
	LEAU -34,U

	LDD #$6666
	STD -8,U
	LDB #$88
	LDX #$8666
	LDY #$6666
	PSHU D,X,Y
	LEAU -34,U

	LDD #$7777
	STD -8,U
	LDB #$68
	LDX #$8677
	LDY #$7777
	PSHU D,X,Y
	LEAU -34,U

	STY -8,U
	LDB #$78
	LDX #$6777
	LDY #$7773
	PSHU D,X,Y
	LEAU -34,U

	LDD #$3333
	STD -8,U
	LDB #$37
	LDX #$2333
	LDY #$3333
	PSHU D,X,Y
	LEAU -34,U

	LDD #$2222
	STD -8,U
	LDX #$6722
	LDY #$2222
	PSHU D,X,Y
	LEAU -34,U

	LDA #$11
	STD -8,U
	LDB #$11
	LDX #$1111
	LDY #$1111
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0022
	STD -8,U
	LDD #$1001
	LDX #$1110
	LDY #$0100
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0022
	STD -8,U
	LDD #$1001
	LDX #$0010
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0022
	STD -8,U
	LDB #$11
	LDY #$0010
	PSHU D,X,Y
	LEAU -34,U

	LDB #$22
	STD -8,U
	LDB #$01
	PSHU D,X,Y
	LEAU -34,U

	LDB #$22
	STD -8,U
	LDD #$1011
	LDY #$0110
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0022
	STD -8,U
	LDD #$1001
	LDX #$1110
	LDY #$0100
	PSHU D,X,Y
	RTS

