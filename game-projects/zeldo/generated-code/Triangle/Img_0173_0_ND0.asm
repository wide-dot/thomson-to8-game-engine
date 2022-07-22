	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_0173_0
	LEAU 1167,U

	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	STA -7,U
	LDD -36,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -36,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -30,U

	PSHU D,X,Y
	LDD -34,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -34,U
	LDA #$dd
	PSHU A,X,Y
	LEAU -29,U

	LDD -6,U
	LDA #$cc
	ANDB #$F0
	ORB #$0d
	STD -6,U
	LDD #$cccc
	LDX #$cccc
	PSHU D,X
	LEAU -2,U

	LDD -34,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -34,U
	LDA #$dc
	LDY #$cccc
	PSHU A,X,Y
	LEAU -29,U

	LDD -6,U
	LDA #$cc
	ANDB #$F0
	ORB #$0d
	STD -6,U
	PSHU X,Y
	LEAU -2,U

	LDD -34,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -34,U
	LDA #$dc
	PSHU A,X,Y
	LEAU -29,U

	PSHU X,Y
	LEAU -1,U

	LDD #$dccc
	PSHU D,X,Y
	LEAU -28,U

	PSHU B,X,Y
	LEAU -1,U

	LDA -6,U
	ANDA #$F0
	ORA #$0c
	STA -6,U
	PSHU B,X,Y
	LEAU -29,U

	PSHU B,X,Y
	LEAU -1,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	PSHU B,X,Y
	LEAU -29,U

	PSHU B,X,Y
	LEAU -1,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDY #$cccd
	PSHU B,X,Y
	LEAU -29,U

	LDY #$cccc
	PSHU B,X,Y
	LEAU -1,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDY #$cccd
	PSHU B,X,Y
	LEAU -29,U

	LDY #$cccc
	PSHU B,X,Y
	LEAU -1,U

	LDY #$cccd
	PSHU B,X,Y
	LEAU -29,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -8,U
	LDY #$cccc
	PSHU A,X,Y
	LEAU -3,U

	PSHU A,X
	LEAU -29,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDA #$dc
	PSHU A,X,Y
	LEAU -3,U

	LDA #$cc
	PSHU A,X
	LEAU -29,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDA #$dc
	LDY #$cccd
	PSHU A,X,Y
	LEAU -3,U

	LDA #$cc
	PSHU A,X
	LEAU -29,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDA #$dc
	PSHU A,X,Y
	LEAU -3,U

	LDA #$cc
	PSHU A,X
	LEAU -29,U

	LDA -5,U
	ANDA #$F0
	ORA #$0c
	STA -5,U
	LDY #$ccdd
	PSHU X,Y
	LEAU -3,U

	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -35,U
	LDA -38,U
	ANDA #$F0
	ORA #$0d
	STA -38,U
	STX -37,U
	LDD #$cccc
	PSHU D,X
	LEAU -36,U

	STD -37,U
	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -35,U
	LDA -38,U
	ANDA #$F0
	ORA #$0d
	STA -38,U
	LDD #$cccc
	PSHU D,X
	LEAU -36,U

	LDA #$dc
	PSHU D,X
	LEAU -30,U

	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	PSHU B,X
	LEAU -3,U

	LDD #$dccc
	PSHU D,X
	LEAU -30,U

	PSHU B,X
	LEAU -3,U

	LDA #$dd
	PSHU D,X
	LEAU -30,U

	PSHU B,X
	LEAU -3,U

	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	PSHU B,X
	LEAU -31,U

	PSHU B,X
	LEAU -3,U

	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	PSHU B,X
	LEAU -31,U

	PSHU B,X
	LEAU -3,U

	LDX #$cccd
	PSHU B,X
	LEAU -31,U

	LDX #$cccc
	PSHU B,X
	LEAU -3,U

	LDX #$cccd
	PSHU B,X
	LEAU -31,U

	LDA #$dc
	LDX #$cccc
	PSHU A,X
	LEAU -3,U

	PSHU B,Y
	LEAU -31,U

	STB -9,U
	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDA #$dc
	LDX #$cccd
	PSHU A,X
	LEAU -37,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDD -82,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -82,U
	LDD -122,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -122,U
	STX -42,U
	STA -9,U
	LDA -43,U
	ANDA #$F0
	ORA #$0c
	STA -43,U
	LDA -83,U
	ANDA #$F0
	ORA #$0d
	STA -83,U
	LDA -123,U
	ANDA #$F0
	ORA #$0d
	STA -123,U
	LDD #$cccc
	STD -49,U
	STD -89,U
	LDA #$dc
	PSHU A,X
	LEAU -245,U

	STD 119,U
	STD 79,U
	STD 39,U
	LDD -1,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -1,U
	LDD -41,U
	ANDA #$F0
	ORA #$0d
	LDB #$cc
	STD -41,U
	LDD -81,U
	ANDA #$F0
	ORA #$0d
	LDB #$cd
	STD -81,U
	LDD -121,U
	ANDA #$F0
	ORA #$0d
	LDB #$cd
	STD -121,U
	LDA 85,U
	ANDA #$F0
	ORA #$0d
	STA 85,U
	LDA #$cc
	STA 6,U
	STA -34,U
	STA -74,U
	STA -114,U
	LDD 86,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD 86,U
	LDD 46,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD 46,U
	LEAU -177,U

	STA 23,U
	LDA #$cd
	STA 17,U
	LDA #$cc
	STA -17,U
	LDA -23,U
	ANDA #$0F
	ORA #$c0
	STA -23,U
	LEAU -176,U

	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDA 113,U
	ANDA #$0F
	ORA #$d0
	STA 113,U
	LDA 73,U
	ANDA #$0F
	ORA #$d0
	STA 73,U
	LDA 33,U
	ANDA #$0F
	ORA #$d0
	STA 33,U
	LDA #$dc
	STA 119,U
	LDA #$dd
	STA 79,U
	STA 39,U
	STA -7,U
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -36,U

	PSHU A,X,Y
	LEAU -34,U

	LDD #$dccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -34,U

	LDA -6,U
	ANDA #$F0
	ORA #$0c
	STA -6,U
	PSHU B,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	PSHU B,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	PSHU B,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	PSHU B,X,Y
	LEAU -35,U

	PSHU B,X,Y
	LEAU -35,U

	PSHU B,X,Y
	LEAU -35,U

	LDY #$cccd
	PSHU B,X,Y
	LEAU -35,U

	PSHU B,X,Y
	LEAU -35,U

	LDD -42,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -42,U
	PSHU A,X,Y
	LEAU -37,U

	LDD -40,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -40,U
	PSHU A,X
	LEAU -37,U

	LDD -40,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -40,U
	PSHU A,X
	LEAU -37,U

	LDD -40,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDA #$dc
	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -36,U

	LDD #$ddcc
	PSHU D,X
	LEAU -36,U

	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	PSHU B,X
	LEAU -37,U

	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	PSHU B,X
	LEAU -37,U

	PSHU B,X
	LEAU -37,U

	PSHU B,X
	LEAU -37,U

	PSHU B,Y
	LEAU -37,U

	PSHU B,Y
	LEAU -37,U

	LDD -42,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -42,U
	LDD -82,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -82,U
	LDD -122,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -122,U
	STA -43,U
	STA -83,U
	LDA #$dc
	STA -123,U
	LDA #$cc
	PSHU A,Y
	LEAU -279,U

	LDD 120,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD 120,U
	LDA #$dc
	STA 119,U
	LDD #$dccc
	STD 79,U
	LDD 39,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD 39,U
	LDD -1,U
	ANDA #$F0
	ORA #$0d
	LDB #$cc
	STD -1,U
	LDD -41,U
	ANDA #$F0
	ORA #$0d
	LDB #$cc
	STD -41,U
	LDD -81,U
	ANDA #$F0
	ORA #$0d
	LDB #$cc
	STD -81,U
	STB -120,U
	LEAU -260,U

	LDA -60,U
	ANDA #$0F
	ORA #$d0
	STA -60,U
	LDA -100,U
	ANDA #$0F
	ORA #$d0
	STA -100,U
	LDA #$dd
	STA -20,U
	STB 100,U
	LDA #$cd
	STA 60,U
	STA 20,U

	LDU <glb_screen_location_1
	LEAU 1166,U

	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -28,U

	PSHU D,X,Y
	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -28,U

	LDD #$cccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD #$cccc
	LDY #$cccd
	PSHU D,X,Y
	LEAU -28,U

	LDY #$cccc
	PSHU D,X,Y
	LDY #$cccd
	PSHU D,X,Y
	LEAU -28,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -8,U
	LDD #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -2,U

	PSHU D,X
	LEAU -28,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDD #$dccc
	PSHU D,X,Y
	LEAU -2,U

	PSHU X,Y
	LEAU -28,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDD #$dccc
	LDY #$cccd
	PSHU D,X,Y
	LEAU -2,U

	LDA #$cc
	PSHU D,X
	LEAU -28,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDD #$ddcc
	PSHU D,X,Y
	LEAU -2,U

	LDA #$cc
	PSHU D,X
	LEAU -28,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDY #$ccdd
	PSHU B,X,Y
	LEAU -2,U

	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -35,U
	LDA #$dc
	LDY #$cccc
	PSHU A,X,Y
	LEAU -30,U

	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	LDA #$cc
	PSHU A,X
	LEAU -2,U

	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -35,U
	LDA #$dc
	PSHU A,X,Y
	LEAU -30,U

	LDA #$cc
	PSHU A,X
	LEAU -2,U

	LDA #$dc
	PSHU A,X,Y
	LEAU -29,U

	PSHU X,Y
	LEAU -2,U

	LDA -5,U
	ANDA #$F0
	ORA #$0c
	STA -5,U
	PSHU X,Y
	LEAU -30,U

	PSHU X,Y
	LEAU -2,U

	LDA -5,U
	ANDA #$F0
	ORA #$0d
	STA -5,U
	PSHU X,Y
	LEAU -30,U

	PSHU X,Y
	LEAU -2,U

	LDA -5,U
	ANDA #$F0
	ORA #$0d
	STA -5,U
	LDY #$cccd
	PSHU X,Y
	LEAU -30,U

	LDD #$cccc
	PSHU D,X
	LEAU -2,U

	LDA -5,U
	ANDA #$F0
	ORA #$0d
	STA -5,U
	PSHU X,Y
	LEAU -30,U

	LDD #$cccc
	PSHU D,X
	LEAU -2,U

	PSHU D,Y
	LEAU -30,U

	STD -10,U
	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -8,U
	LDD #$cccc
	PSHU D,X
	LEAU -36,U

	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	STX -10,U
	LDD #$dccc
	PSHU D,X
	LEAU -36,U

	STX -10,U
	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDD #$dccc
	PSHU D,Y
	LEAU -36,U

	STX -10,U
	LDD -8,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDD #$dccc
	PSHU D,Y
	LEAU -36,U

	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	PSHU B,Y
	LEAU -4,U

	LDD -37,U
	ANDA #$F0
	ORA #$0d
	LDB #$cc
	STD -37,U
	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -35,U
	PSHU A,X
	LEAU -37,U

	LDD -37,U
	ANDA #$F0
	ORA #$0d
	LDB #$cc
	STD -37,U
	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -35,U
	PSHU A,X
	LEAU -37,U

	LDD -37,U
	ANDA #$F0
	ORA #$0d
	LDB #$cc
	STD -37,U
	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -35,U
	LDA #$dc
	PSHU A,X
	LEAU -37,U

	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -35,U
	STA -36,U
	LDA #$dc
	PSHU A,X
	LEAU -37,U

	STX -36,U
	STX -76,U
	STX -116,U
	STY -122,U
	LDA -43,U
	ANDA #$F0
	ORA #$0d
	STA -43,U
	LDA -83,U
	ANDA #$F0
	ORA #$0d
	STA -83,U
	STX -42,U
	STX -82,U
	LDA #$dd
	PSHU A,X
	LEAU -276,U

	STX 123,U
	STY 117,U
	STX 83,U
	STY 43,U
	LDD #$ccdd
	STD 77,U
	LDD 37,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD 37,U
	LDD -3,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -3,U
	LDD -77,U
	LDA #$dd
	ANDB #$0F
	ORB #$c0
	STD -77,U
	LDD #$dccd
	STD 3,U
	STD -37,U
	LDA #$cc
	STA -43,U
	STA -83,U
	LDD -117,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0dd0
	STD -117,U
	LDA #$dc
	STA -123,U
	LEAU -180,U

	STA 17,U
	STA -23,U
	LDD 23,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0dd0
	STD 23,U
	LDA -16,U
	ANDA #$0F
	ORA #$d0
	STA -16,U
	LEAU -176,U

	LDA 113,U
	ANDA #$F0
	ORA #$0c
	STA 113,U
	LDA 73,U
	ANDA #$F0
	ORA #$0d
	STA 73,U
	LDA 33,U
	ANDA #$F0
	ORA #$0d
	STA 33,U
	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	PSHU D,X,Y
	LEAU -34,U

	LDD #$cccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -34,U

	LDY #$cccd
	PSHU D,X,Y
	LEAU -34,U

	PSHU D,X,Y
	LEAU -34,U

	LDD -42,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD #$cccc
	LDY #$ccdd
	PSHU D,X,Y
	LEAU -36,U

	LDD -40,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDD #$cccc
	PSHU D,X
	LEAU -36,U

	PSHU D,X
	LEAU -35,U

	LDA #$dc
	LDY #$cccc
	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -35,U

	LDA #$dd
	PSHU A,X,Y
	LEAU -35,U

	LDA -5,U
	ANDA #$F0
	ORA #$0d
	STA -5,U
	PSHU X,Y
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$0d
	STA -5,U
	PSHU X,Y
	LEAU -36,U

	PSHU X,Y
	LEAU -36,U

	PSHU X,Y
	LEAU -36,U

	LDY #$cccd
	PSHU X,Y
	LEAU -36,U

	PSHU X,Y
	LEAU -36,U

	LDD -42,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -42,U
	LDD -82,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -82,U
	LDD -122,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD -122,U
	LDD #$dccc
	STD -124,U
	STX -44,U
	STX -84,U
	PSHU X,Y
	LEAU -197,U

	LDD 39,U
	LDA #$cc
	ANDB #$0F
	ORB #$d0
	STD 39,U
	STX -42,U
	LDD #$dccc
	STD 37,U
	LDA -43,U
	ANDA #$F0
	ORA #$0c
	STA -43,U
	LDA -83,U
	ANDA #$F0
	ORA #$0d
	STA -83,U
	LDA -123,U
	ANDA #$F0
	ORA #$0d
	STA -123,U
	STX -82,U
	STX -122,U
	LDA #$dc
	PSHU A,X
	LEAU -278,U

	STX 119,U
	LDD #$ccdd
	STD -81,U
	STX 79,U
	STX 39,U
	STY -1,U
	STY -41,U
	LDA 118,U
	ANDA #$F0
	ORA #$0d
	STA 118,U
	LDD -121,U
	LDA #$dc
	ANDB #$0F
	ORB #$d0
	STD -121,U
	LEAU -261,U

	LDA 20,U
	ANDA #$F0
	ORA #$0c
	STA 20,U
	LDA -20,U
	ANDA #$F0
	ORA #$0d
	STA -20,U
	LDA -60,U
	ANDA #$F0
	ORA #$0d
	STA -60,U
	LDA -100,U
	ANDA #$F0
	ORA #$0d
	STA -100,U
	LDA #$dc
	STA 60,U
	LDD 100,U
	LDA #$dc
	ANDB #$0F
	ORB #$d0
	STD 100,U
	RTS

