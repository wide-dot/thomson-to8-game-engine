	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_tk_038b_0
	LEAU 3947,U

	LDA #$bb
	STA -54,U
	LDA 26,U
	ANDA #$F0
	ORA #$0b
	STA 26,U
	LDA 7,U
	ANDA #$F0
	ORA #$09
	STA 7,U
	LDA #$99
	STA 18,U
	LDD -53,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -53,U
	LDD -81,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -81,U
	LDD #$bbbb
	STD 27,U
	LDD -63,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -63,U
	LDD -83,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -83,U
	LDX #$bbbb
	PSHU B,X
	LEAU -156,U

	STX 25,U
	LDD #$9999
	STD 16,U
	LDA 7,U
	ANDA #$0F
	ORA #$90
	STA 7,U
	LDA #$bb
	PSHU A,X
	LEAU -50,U

	LDD -11,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -11,U
	LDD -28,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -28,U
	LDA -20,U
	ANDA #$0F
	ORA #$90
	STA -20,U
	LDA -100,U
	ANDA #$0F
	ORA #$90
	STA -100,U
	LDD -30,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -30,U
	STX -83,U
	LDA #$99
	STA -91,U
	PSHU B,X
	LEAU -103,U

	LDD -66,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -66,U
	LDA -58,U
	ANDA #$F0
	ORA #$0b
	STA -58,U
	LDA -74,U
	ANDA #$F0
	ORA #$09
	STA -74,U
	LDA -83,U
	ANDA #$F0
	ORA #$0b
	STA -83,U
	STX -57,U
	STX -82,U
	LDA #$bb
	PSHU A,X
	LEAU -156,U

	LDD 22,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 22,U
	STA 21,U
	LDA -60,U
	ANDA #$F0
	ORA #$0b
	STA -60,U
	STX -59,U
	LDD #$9999
	STD 13,U
	STA -67,U
	LDA #$bb
	PSHU A,X
	LEAU -77,U

	LDD -59,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -59,U
	LDD -68,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -68,U
	LDA #$bb
	STA -60,U
	PSHU A,X
	LEAU -66,U

	LDD -12,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -12,U
	LDD -79,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -79,U
	LDA -72,U
	ANDA #$F0
	ORA #$0b
	STA -72,U
	STX -71,U
	LDA #$bb
	STA -13,U
	LDA #$cc
	LDX #$ccbb
	PSHU A,X
	LEAU -76,U

	LDD #$bccc
	LDX #$cccc
	LDY #$ccbb
	PSHU D,X,Y
	LEAU -5,U

	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -56,U

	LDD -10,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -10,U
	LDA #$bb
	PSHU A,X
	LEAU -7,U

	LDA -7,U
	ANDA #$F0
	ORA #$08
	STA -7,U
	STX -13,U
	LDD #$cccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -65,U

	LDD -8,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -8,U
	LDD -10,U
	LDA #$cc
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -7,U

	STA -12,U
	LDD -11,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -11,U
	LDD #$8ccc
	LDX #$cccc
	PSHU D,X,Y
	LEAU -64,U

	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -3,U

	LDA #$cc
	LDX #$8888
	LDY #$8999
	PSHU D,X,Y
	LDD -5,U
	LDA #$88
	ANDB #$F0
	ORB #$0c
	STD -5,U
	LDD #$bbbb
	STD -9,U
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -66,U

	LDX #$bbbb
	PSHU B,X
	LEAU -2,U

	LDB #$cc
	LDX #$8888
	LDY #$8899
	PSHU D,X,Y
	LDD #$bbbb
	STD -9,U
	LDD -74,U
	LDA #$99
	ANDB #$F0
	ORB #$0b
	STD -74,U
	LDD #$bbbb
	STD -72,U
	LDA #$88
	LDX #$cccc
	LDY #$cccc
	PSHU A,X,Y
	LEAU -69,U

	LDD #$cc88
	LDX #$8888
	LDY #$8889
	PSHU D,X,Y
	LDD -6,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -6,U
	LDD -72,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -72,U
	STA -8,U
	LDD #$cccc
	LDX #$cccc
	PSHU D,X
	LEAU -68,U

	LDD #$8888
	LDX #$8888
	LDY #$99bb
	PSHU D,X,Y
	LDD #$cccc
	LDX #$cccc
	LDY #$c888
	PSHU D,X,Y
	LDD -70,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -70,U
	LDX #$8888
	PSHU A,X
	LEAU -67,U

	LDD #$8888
	LDY #$8888
	PSHU D,X,Y
	LDA -7,U
	ANDA #$F0
	ORA #$0c
	STA -7,U
	LDD -74,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -74,U
	LDD #$888c
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -69,U

	LDA #$cc
	STA -7,U
	LDD #$8888
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -3,U

	LDA #$bb
	STA -69,U
	LDA #$cc
	LDX #$88cc
	PSHU A,X
	LEAU -68,U

	LDA -7,U
	ANDA #$F0
	ORA #$07
	STA -7,U
	LDD #$bbbb
	STD -78,U
	LDD #$cc8d
	STD -12,U
	LDD #$8888
	LDX #$8888
	LDY #$88cc
	PSHU D,X,Y
	LEAU -74,U

	LDD -7,U
	LDA #$77
	ANDB #$F0
	ORB #$08
	STD -7,U
	LDD -11,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -11,U
	LDD -81,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -81,U
	LDD #$bbbb
	STD -78,U
	LDD -13,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -13,U
	LDA #$88
	LDY #$cccc
	PSHU A,X,Y
	LEAU -76,U

	PSHU X,Y
	LEAU -1,U

	LDD -72,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -72,U
	LDA #$cc
	STA -7,U
	LDD #$cddd
	LDX #$dddd
	LDY #$7777
	PSHU D,X,Y
	LEAU -67,U

	LDA #$cc
	STD -14,U
	LDD -12,U
	LDA #$dd
	ANDB #$F0
	ORB #$0d
	STD -12,U
	LDD -78,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -78,U
	LDD #$aa77
	STD -9,U
	LDD #$78cc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -74,U

	LDD -10,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -10,U
	LDD #$bbbb
	STD -78,U
	LDA #$cc
	STA -14,U
	LDD -13,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -13,U
	LDA #$cc
	PSHU A,X,Y
	LEAU -75,U

	LDD -11,U
	ANDA #$0F
	ORA #$70
	LDB #$aa
	STD -11,U
	LDD -7,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -7,U
	LDA #$cc
	PSHU A,X,Y
	LEAU -6,U

	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDD #$bbbb
	STD -67,U
	LDA #$cc
	LDX #$7777
	PSHU A,X
	LEAU -66,U

	LDB #$cc
	PSHU D,Y
	LEAU -1,U

	LDA #$dd
	LDX #$dddd
	PSHU A,X
	LEAU -1,U

	LDD -69,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -69,U
	LDD #$ccc7
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LEAU -65,U

	LDD #$dddd
	STD -8,U
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -3,U

	LDA #$bb
	STA -68,U
	LDA #$cc
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -65,U

	LDD -8,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -8,U
	LDD #$dddd
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -2,U

	LDA #$cc
	STA -7,U
	LDD -69,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -69,U
	LDD #$dddd
	LDX #$dddd
	LDY #$dd77
	PSHU D,X,Y
	LEAU -66,U

	LDX #$dccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$dd77
	LDY #$77dd
	PSHU D,X,Y
	LDD #$bbbb
	STD -65,U
	LDA #$cc
	LDX #$dddd
	PSHU A,X
	LEAU -65,U

	LDD #$dddd
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$ddd7
	LDY #$77dd
	PSHU D,X,Y
	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDD -69,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -69,U
	LDD #$bbbb
	STD -65,U
	LDA #$cd
	LDX #$dddd
	PSHU A,X
	LEAU -66,U

	LDD #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LDD -70,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -70,U
	LDA -9,U
	ANDA #$F0
	ORA #$0c
	STA -9,U
	LDD #$cddd
	STD -8,U
	LDD -74,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -74,U
	LDD #$dddd
	LDY #$dd77
	PSHU D,X,Y
	LEAU -68,U

	LDY #$cccc
	PSHU D,X,Y
	LDY #$dd77
	PSHU D,X,Y
	LDA #$bb
	STA -63,U
	LDD -68,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -68,U
	PSHU A,X
	LEAU -65,U

	LDD #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LDY #$dd77
	PSHU D,X,Y
	LDA #$bb
	STA -63,U
	LDD -68,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -68,U
	PSHU A,X
	LEAU -65,U

	LDD #$dddd
	LDY #$dccc
	PSHU D,X,Y
	LDY #$dd77
	PSHU D,X,Y
	LDD -63,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -63,U
	LDA #$cc
	PSHU A,X
	LEAU -63,U

	LDD #$dddd
	LDX #$dccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$dd77
	LDY #$7ddd
	PSHU D,X,Y
	LDD -65,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -65,U
	LDA #$cc
	LDX #$dddd
	LDY #$dddd
	PSHU A,X,Y
	LEAU -63,U

	LDD #$dddd
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$dd77
	LDY #$7ddd
	PSHU D,X,Y
	LDD #$bbbb
	STD -65,U
	LDA #$cc
	LDX #$dddd
	LDY #$dddd
	PSHU A,X,Y
	LEAU -62,U

	LDD #$dddd
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$777d
	LDY #$dddd
	PSHU D,X,Y
	LDA -7,U
	ANDA #$F0
	ORA #$0c
	STA -7,U
	LDD -66,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -66,U
	LDD #$cddd
	LDX #$dddd
	PSHU D,X,Y
	LEAU -62,U

	LDA #$dd
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$777d
	LDY #$dddd
	PSHU D,X,Y
	LDD -69,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -69,U
	LDD -66,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -66,U
	LDA -7,U
	ANDA #$F0
	ORA #$0c
	STA -7,U
	LDD #$cddd
	LDX #$dddd
	PSHU D,X,Y
	LEAU -63,U

	LDD -10,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -10,U
	LDD #$7ddd
	STD -8,U
	LDA #$dd
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -4,U

	LDD #$cc77
	STD -8,U
	LDA #$bb
	STA -66,U
	LDA #$77
	LDX #$77dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -62,U

	LDD #$ddcc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDB #$77
	LDX #$7ddd
	LDY #$dddd
	PSHU D,X,Y
	LDA #$cc
	STD -8,U
	LDA #$bb
	STA -66,U
	LDA #$77
	LDX #$7777
	LDY #$77dd
	PSHU D,X,Y
	LEAU -62,U

	LDD #$ddcc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDB #$77
	LDX #$7ddd
	LDY #$dddd
	PSHU D,X,Y
	LDA #$cc
	STD -8,U
	LDA #$bb
	STA -66,U
	LDD -69,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -69,U
	LDD #$7777
	LDX #$7777
	LDY #$777d
	PSHU D,X,Y
	LEAU -63,U

	LDD #$dddd
	LDX #$dccc
	LDY #$cccc
	PSHU D,X,Y
	LDD #$7777
	LDX #$777d
	LDY #$dddd
	PSHU D,X,Y
	LDA #$cc
	STA -7,U
	LDA #$bb
	STA -65,U
	LDA #$aa
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LEAU -60,U

	LDD #$dccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDD #$7777
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LDA #$aa
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LDD -61,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -61,U
	LDA #$cc
	LDX #$aaaa
	PSHU A,X
	LEAU -59,U

	LDD #$dccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDD #$aa77
	STD -10,U
	LDD -8,U
	LDA #$77
	ANDB #$F0
	ORB #$07
	STD -8,U
	LDD -12,U
	LDA #$aa
	ANDB #$F0
	ORB #$0a
	STD -12,U
	LDD #$7777
	LDX #$7777
	LDY #$dddd
	PSHU D,X,Y
	LEAU -6,U

	LDD -61,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -61,U
	LDA #$cc
	LDX #$33aa
	PSHU A,X
	LEAU -59,U

	LDD #$dccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDD #$aaa8
	STD -10,U
	LDD -8,U
	LDA #$77
	ANDB #$F0
	ORB #$07
	STD -8,U
	LDD #$7777
	LDX #$7777
	LDY #$77dd
	PSHU D,X,Y
	LEAU -5,U

	LDD -62,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -62,U
	LDD -64,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -64,U
	LDD #$cc33
	LDX #$3333
	PSHU D,X
	LEAU -60,U

	LDD #$7777
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDD -7,U
	LDA #$33
	ANDB #$F0
	ORB #$07
	STD -7,U
	LDA #$77
	LDX #$8877
	LDY #$7777
	PSHU A,X,Y
	LEAU -2,U

	LDA #$cc
	STA -7,U
	LDD #$3333
	LDX #$3333
	LDY #$aaa8
	PSHU D,X,Y
	LEAU -57,U

	LDD #$cccc
	LDX #$cccc
	LDY #$bbbb
	PSHU D,X,Y
	LDD #$7777
	LDX #$7777
	LDY #$88cc
	PSHU D,X,Y
	LDD -9,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -9,U
	LDD -5,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -5,U
	LDD -7,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -7,U
	LDA #$77
	LDX #$9877
	PSHU A,X
	LEAU -6,U

	LDD -61,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -61,U
	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA #$cc
	LDX #$3333
	PSHU A,X
	LEAU -58,U

	LDD #$8888
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDA -7,U
	ANDA #$F0
	ORA #$08
	STA -7,U
	LDA -17,U
	ANDA #$F0
	ORA #$0c
	STA -17,U
	LDD -10,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$3003
	STD -10,U
	LDD #$cc33
	STD -16,U
	LDD -14,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -14,U
	LDD #$3333
	STD -12,U
	LDD #$8877
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LEAU -66,U

	LDD #$8ccc
	LDX #$cccc
	LDY #$cbbb
	PSHU D,X,Y
	LDD #$8777
	STD -8,U
	LDD -15,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -15,U
	LDD -13,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -13,U
	LDA -9,U
	ANDA #$F0
	ORA #$08
	STA -9,U
	LDD #$7777
	LDX #$7777
	LDY #$8888
	PSHU D,X,Y
	LEAU -9,U

	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA #$c3
	LDX #$3333
	PSHU A,X
	LEAU -56,U

	LDD #$88cc
	LDX #$cccc
	LDY #$ccbb
	PSHU D,X,Y
	LDD -9,U
	ANDA #$F0
	ORA #$09
	LDB #$77
	STD -9,U
	LDA #$33
	STA -14,U
	LDD -13,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -13,U
	LDD #$7777
	LDX #$7777
	LDY #$8888
	PSHU D,X,Y
	LEAU -9,U

	LDD #$cc83
	LDX #$3333
	PSHU D,X
	LEAU -55,U

	LDD #$8888
	LDX #$cccc
	LDY #$ccbb
	PSHU D,X,Y
	LDD -14,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$3003
	STD -14,U
	LDA #$98
	STA -8,U
	LDD -16,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -16,U
	LDA #$77
	LDX #$7777
	LDY #$8888
	PSHU A,X,Y
	LEAU -11,U

	LDA #$cc
	LDX #$8333
	PSHU A,X
	LEAU -55,U

	LDX #$ccbb
	PSHU A,X
	LEAU -1,U

	LDA #$88
	STA -10,U
	LDD -17,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -17,U
	LDD #$7777
	LDX #$8888
	PSHU D,X,Y
	LEAU -11,U

	LDD #$ccbb
	STD -61,U
	LDD -63,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$800c
	STD -63,U
	LDD #$cc83
	LDX #$3333
	PSHU D,X
	LEAU -59,U

	LDA -6,U
	ANDA #$F0
	ORA #$07
	STA -6,U
	LDD -17,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -17,U
	LDA #$77
	LDX #$8888
	PSHU A,X,Y
	LEAU -12,U

	LDD #$ccbb
	STD -61,U
	LDD #$c883
	LDX #$3333
	PSHU D,X
	LEAU -58,U

	LDD -18,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -18,U
	LDD #$a788
	LDX #$8888
	PSHU D,X,Y
	LEAU -12,U

	LDA #$bb
	STA -60,U
	LDD #$8883
	LDX #$3333
	PSHU D,X
	LEAU -58,U

	LDA -7,U
	ANDA #$F0
	ORA #$0a
	STA -7,U
	LDD #$aa88
	LDX #$8888
	PSHU D,X,Y
	LEAU -11,U

	LDD -5,U
	LDA #$88
	ANDB #$F0
	ORB #$03
	STD -5,U
	LDA #$9b
	STA -61,U
	LDA #$33
	LDX #$3333
	PSHU A,X
	LEAU -60,U

	LDA -7,U
	ANDA #$F0
	ORA #$0a
	STA -7,U
	LDD #$aaaa
	LDX #$8888
	PSHU D,X,Y
	LEAU -11,U

	LDD -5,U
	LDA #$88
	ANDB #$F0
	ORB #$03
	STD -5,U
	LDD #$99bb
	STD -61,U
	LDD -64,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8080
	STD -64,U
	LDA #$33
	LDX #$3333
	PSHU A,X
	LEAU -61,U

	LDA #$88
	STA -11,U
	LDD -18,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -18,U
	LDD -20,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -20,U
	LDD -22,U
	ANDA #$F0
	ORA #$09
	LDB #$88
	STD -22,U
	LDD -80,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -80,U
	LDD -77,U
	LDA #$99
	ANDB #$F0
	ORB #$0b
	STD -77,U
	LDA #$aa
	LDX #$aa88
	PSHU A,X,Y
	LEAU -75,U

	LDD -18,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -18,U
	LDA #$98
	STA -11,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X,Y
	LEAU -13,U

	LDA #$99
	STA -59,U
	LDB #$88
	LDX #$33a3
	PSHU D,X
	LEAU -56,U

	LDD -14,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -14,U
	LDD -20,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -20,U
	LDD #$aaaa
	LDX #$8888
	PSHU D,X,Y
	LEAU -14,U

	LDA #$88
	STA -61,U
	LDA #$99
	STA -59,U
	LDD -58,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$9009
	STD -58,U
	LDD #$9888
	LDX #$33a3
	PSHU D,X
	LEAU -58,U

	LDD -12,U
	ANDA #$F0
	ORA #$08
	LDB #$87
	STD -12,U
	LDD -18,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -18,U
	LDD #$aaaa
	LDX #$aa88
	PSHU D,X
	LEAU -14,U

	LDA -5,U
	ANDA #$F0
	ORA #$09
	STA -5,U
	LDD -59,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -59,U
	LDD -61,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -61,U
	LDD #$9888
	LDX #$33a3
	PSHU D,X
	LEAU -58,U

	LDD -12,U
	ANDA #$F0
	ORA #$09
	LDB #$77
	STD -12,U
	LDD -18,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -18,U
	LDA #$aa
	LDX #$aa88
	PSHU A,X
	LEAU -15,U

	STY -61,U
	LDD -59,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -59,U
	LDD -63,U
	LDA #$aa
	ANDB #$0F
	ORB #$80
	STD -63,U
	LDA #$99
	STA -56,U
	LDA #$98
	STA -73,U
	LDD #$aaaa
	STD -65,U
	LDA -79,U
	ANDA #$0F
	ORA #$30
	STA -79,U
	LDA #$99
	LDX #$9888
	LDY #$3aa3
	PSHU A,X,Y
	LEAU -75,U

	LDD -5,U
	LDA #$99
	ANDB #$F0
	ORB #$08
	STD -5,U
	LDD -59,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -59,U
	LDD -56,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -56,U
	LDA #$88
	PSHU A,Y
	LEAU -56,U

	STA -14,U
	LDD -23,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -23,U
	LDD -80,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -80,U
	STA -76,U
	LDD #$9999
	STD -27,U
	LDD -25,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -25,U
	LDA #$aa
	LDX #$aa88
	LDY #$8888
	PSHU A,X,Y
	LEAU -75,U

	LDD -80,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -80,U
	LDD #$88aa
	STD -24,U
	LDA #$99
	STA -27,U
	STA -76,U
	LDD -22,U
	LDA #$a3
	ANDB #$0F
	ORB #$30
	STD -22,U
	LDD -26,U
	LDA #$99
	ANDB #$F0
	ORB #$08
	STD -26,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X,Y
	LEAU -75,U

	LDA -5,U
	ANDA #$F0
	ORA #$0a
	STA -5,U
	LDA #$88
	STA -16,U
	PSHU X,Y
	LEAU -16,U

	LDA #$99
	STA -7,U
	LDA -5,U
	ANDA #$F0
	ORA #$08
	STA -5,U
	LDA -56,U
	ANDA #$F0
	ORA #$09
	STA -56,U
	LDD #$88aa
	LDX #$3333
	PSHU D,X
	LEAU -54,U

	LDA #$98
	STA -18,U
	LDA #$aa
	LDX #$a888
	LDY #$8999
	PSHU D,X,Y
	LEAU -16,U

	LDA -5,U
	ANDA #$F0
	ORA #$08
	STA -5,U
	LDA #$99
	STA -7,U
	LDA #$83
	LDX #$3833
	PSHU D,X
	LEAU -54,U

	LDA -27,U
	ANDA #$F0
	ORA #$08
	STA -27,U
	LDA -29,U
	ANDA #$0F
	ORA #$90
	STA -29,U
	LDD -24,U
	LDA #$88
	ANDB #$0F
	ORB #$90
	STD -24,U
	LDD #$83aa
	STD -26,U
	LDD -19,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -19,U
	LDD #$aaaa
	LDX #$aa88
	PSHU D,X,Y
	LEAU -74,U

	LDA #$88
	STA -21,U
	LDD -19,U
	ANDA #$F0
	ORA #$08
	LDB #$87
	STD -19,U
	LDA #$aa
	PSHU A,X,Y
	LEAU -17,U

	LDA -5,U
	ANDA #$F0
	ORA #$08
	STA -5,U
	LDA -85,U
	ANDA #$F0
	ORA #$08
	STA -85,U
	STY -60,U
	LDD #$aaaa
	STD -63,U
	LDD -77,U
	ANDA #$F0
	ORA #$09
	LDB #$77
	STD -77,U
	LDA #$99
	STA -79,U
	LDD #$7788
	STD -82,U
	LDD -84,U
	LDA #$3a
	ANDB #$0F
	ORB #$a0
	STD -84,U
	LDD #$33aa
	LDX #$8898
	PSHU D,X
	LEAU -256,U

	STY 120,U
	LDA #$aa
	STD 117,U
	LDA #$88
	STA 24,U
	LDD 101,U
	LDA #$98
	ANDB #$0F
	ORB #$70
	STD 101,U
	LDD 21,U
	LDA #$88
	ANDB #$0F
	ORB #$70
	STD 21,U
	LDD 18,U
	LDA #$88
	ANDB #$0F
	ORB #$90
	STD 18,U
	LDD -42,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -42,U
	LDD -59,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -59,U
	LDD #$7789
	STD 98,U
	LDD 95,U
	ANDA #$F0
	ORA #$08
	LDB #$aa
	STD 95,U
	LDD 40,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 40,U
	LDD 15,U
	ANDA #$F0
	ORA #$08
	LDB #$aa
	STD 15,U
	LDD -63,U
	ANDA #$F0
	ORA #$03
	LDB #$38
	STD -63,U
	LDD -65,U
	ANDA #$F0
	ORA #$03
	LDB #$aa
	STD -65,U
	LDD -122,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -122,U
	STB 38,U
	LDA #$98
	STA 104,U
	LDA #$99
	STA -39,U
	STA -119,U
	LEAU -262,U

	STA 123,U
	LDD 119,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 119,U
	LDD 117,U
	LDA #$3a
	ANDB #$0F
	ORB #$a0
	STD 117,U
	LDD 39,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 39,U
	LDA #$aa
	STA 61,U
	STA 37,U
	STA -19,U
	STA -43,U
	STA -99,U
	STA -123,U
	LDA #$88
	STA 43,U
	LDA #$33
	STA -41,U
	STA -121,U
	LEAU -323,U

	STA 122,U
	STA 42,U
	LDD 119,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 119,U
	LDD -39,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -39,U
	LDA 65,U
	ANDA #$0F
	ORA #$a0
	STA 65,U
	LDA -12,U
	ANDA #$0F
	ORA #$a0
	STA -12,U
	LDA -95,U
	ANDA #$F0
	ORA #$0a
	STA -95,U
	LDD 39,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 39,U
	LDD -119,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -119,U
	LDA #$aa
	STA -15,U
	STA -41,U
	STA -92,U
	STA -121,U
	LEAU -293,U

	LDA 121,U
	ANDA #$F0
	ORA #$0a
	STA 121,U
	LDA 42,U
	ANDA #$0F
	ORA #$a0
	STA 42,U
	LDA -118,U
	ANDA #$0F
	ORA #$a0
	STA -118,U
	LDA -121,U
	ANDA #$F0
	ORA #$03
	STA -121,U
	LDD 94,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 94,U
	LDD 11,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 11,U
	STA -38,U
	STA -69,U
	LDA #$33
	STA 14,U
	STA -66,U
	LDD 91,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 91,U
	LEAU -268,U

	LDD 121,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 121,U
	LDD 41,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 41,U
	LDA #$aa
	STA 119,U
	STA 39,U
	LDA 70,U
	ANDA #$0F
	ORA #$80
	STA 70,U
	LDA -41,U
	ANDA #$0F
	ORA #$80
	STA -41,U
	LDA -92,U
	ANDA #$0F
	ORA #$30
	STA -92,U
	LDA #$99
	STA -10,U
	STA -90,U
	LDA #$98
	STA -121,U
	LDD -39,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -39,U
	STA -119,U
	LEAU -290,U

	LDA 38,U
	ANDA #$F0
	ORA #$03
	STA 38,U
	LDA #$33
	STA 118,U
	STA 91,U
	STA 11,U
	LDA #$99
	STA 120,U
	STA 89,U
	STA 40,U
	STA 9,U
	LDD -41,U
	ANDA #$0F
	ORA #$30
	LDB #$88
	STD -41,U
	LDD -70,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -70,U
	LDD -121,U
	ANDA #$0F
	ORA #$30
	LDB #$98
	STD -121,U
	LDA #$88
	STA -71,U
	LEAU -270,U

	LDD 120,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD 120,U
	LDA #$77
	STA 119,U
	LDD #$3399
	STD 69,U
	STD -11,U
	LDD #$7833
	STD 39,U
	LDA #$99
	STD -121,U
	LDD -91,U
	ANDA #$F0
	ORA #$03
	LDB #$38
	STD -91,U
	LDD #$8933
	STD -41,U
	LEAU -290,U

	LDD 9,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 9,U
	LDD #$9333
	STD 89,U
	STB 120,U
	STB 40,U
	STB -40,U
	STB -71,U
	STB -120,U
	LEAU -231,U

	STB 80,U
	STB ,U
	LDA 31,U
	ANDA #$F0
	ORA #$03
	STA 31,U
	LDA -80,U
	ANDA #$0F
	ORA #$30
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 3867,U

	LDD 107,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 107,U
	LDD 97,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 97,U
	LDD 78,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 78,U
	STA 106,U
	STA 77,U
	LDA #$99
	STA 87,U
	STA 17,U
	STA 7,U
	LDD #$bbbb
	STD 26,U
	LDA 25,U
	ANDA #$F0
	ORA #$0b
	STA 25,U
	LDX #$bbbb
	PSHU B,X
	LEAU -49,U

	LDA #$99
	STA -11,U
	STA -21,U
	LDA -101,U
	ANDA #$F0
	ORA #$09
	STA -101,U
	LDD -31,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -31,U
	LDD -92,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -92,U
	STX -83,U
	LDD -29,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -29,U
	PSHU A,X
	LEAU -104,U

	LDA -57,U
	ANDA #$F0
	ORA #$0b
	STA -57,U
	LDA -83,U
	ANDA #$F0
	ORA #$0b
	STA -83,U
	STX -56,U
	STX -82,U
	LDD #$9999
	STD -65,U
	LDA #$bb
	PSHU A,X
	LEAU -156,U

	STX 22,U
	LDD 14,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 14,U
	STA -66,U
	LDA -59,U
	ANDA #$F0
	ORA #$0b
	STA -59,U
	STX -58,U
	LDA #$bb
	PSHU A,X
	LEAU -77,U

	LDD -58,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -58,U
	LDD -81,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -81,U
	STA -59,U
	STA -82,U
	LDD -67,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -67,U
	LDA -74,U
	ANDA #$0F
	ORA #$b0
	STA -74,U
	LDA #$bb
	PSHU A,X
	LEAU -145,U

	STX 9,U
	LDA 8,U
	ANDA #$F0
	ORA #$0b
	STA 8,U
	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	STB 1,U
	LDA #$bb
	STA -6,U
	LDA #$cc
	LDX #$cbbb
	PSHU A,X
	LEAU -8,U

	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -55,U

	PSHU A,X
	LEAU -6,U

	LDB #$cc
	STD -8,U
	LDD -14,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -14,U
	LDD -81,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -81,U
	LDD -83,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -83,U
	STX -74,U
	LDA #$bb
	STA -15,U
	LDA -75,U
	ANDA #$F0
	ORA #$0b
	STA -75,U
	LDD #$cccc
	LDX #$cccc
	LDY #$bb99
	PSHU D,X,Y
	LEAU -77,U

	LDY #$cccc
	PSHU A,X,Y
	LEAU -4,U

	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -57,U

	LDD -9,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -9,U
	LDA #$bb
	PSHU A,X
	LEAU -6,U

	STX -13,U
	LDD #$88cc
	STD -8,U
	LDA #$cc
	LDX #$cccc
	LDY #$cc88
	PSHU D,X,Y
	LEAU -66,U

	LDD -7,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -7,U
	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -4,U

	LDD #$cccc
	LDX #$cccc
	LDY #$8888
	PSHU D,X,Y
	LDD #$bbbb
	STD -8,U
	LDA #$88
	PSHU A,X
	LEAU -64,U

	LDA -4,U
	ANDA #$F0
	ORA #$0b
	STA -4,U
	LDX #$bbbb
	PSHU B,X
	LEAU -2,U

	LDD #$cc88
	LDX #$8888
	LDY #$8999
	PSHU D,X,Y
	LDD -9,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -9,U
	LDD #$8888
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -64,U

	LDD -5,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -5,U
	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -2,U

	LDD #$ccc8
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LDD -8,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -8,U
	LDA #$88
	LDX #$8ccc
	LDY #$cccc
	PSHU A,X,Y
	LEAU -65,U

	LDB #$88
	LDX #$89bb
	LDY #$bbbb
	PSHU D,X,Y
	LDD #$cccc
	LDX #$cc88
	LDY #$8888
	PSHU D,X,Y
	LDD -5,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0b08
	STD -5,U
	LDD -72,U
	ANDA #$0F
	ORA #$80
	LDB #$bb
	STD -72,U
	LDA #$88
	LDX #$8ccc
	PSHU A,X
	LEAU -69,U

	LDB #$88
	LDX #$8888
	PSHU D,X,Y
	LDD -73,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -73,U
	LDD #$c888
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -68,U

	LDD #$bbbb
	STD -79,U
	LDD #$c88c
	STD -12,U
	STX -8,U
	LDD #$8888
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -74,U

	LDD -13,U
	ANDA #$F0
	ORA #$0c
	LDB #$c8
	STD -13,U
	LDD -79,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -79,U
	LDA #$88
	STA -7,U
	LDB #$88
	LDY #$88cc
	PSHU D,X,Y
	LEAU -74,U

	LDA #$77
	STA -8,U
	LDA #$88
	LDY #$cccc
	PSHU D,X,Y
	LEAU -4,U

	LDD -68,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -68,U
	LDA #$cc
	LDX #$8ddd
	PSHU A,X
	LEAU -67,U

	LDD #$7888
	LDX #$8ccc
	PSHU D,X,Y
	LEAU -1,U

	LDD #$bbbb
	STD -71,U
	LDD #$ccdd
	LDX #$dddd
	LDY #$d777
	PSHU D,X,Y
	LEAU -67,U

	STD -13,U
	LDA -8,U
	ANDA #$0F
	ORA #$a0
	STA -8,U
	LDA -10,U
	ANDA #$0F
	ORA #$d0
	STA -10,U
	LDA -14,U
	ANDA #$F0
	ORA #$0c
	STA -14,U
	LDD #$bbbb
	STD -78,U
	LDD #$778c
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -74,U

	LDD #$aaaa
	STD -9,U
	LDA -5,U
	ANDA #$F0
	ORA #$0c
	STA -5,U
	PSHU X,Y
	LEAU -7,U

	LDD -67,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -67,U
	LDD -70,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -70,U
	LDX #$cdd7
	PSHU A,X
	LEAU -67,U

	LDD #$dddd
	STD -6,U
	LDA #$cc
	PSHU A,Y
	LEAU -4,U

	LDD -69,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -69,U
	LDD -73,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -73,U
	LDD #$cc77
	LDX #$7777
	LDY #$aaaa
	PSHU D,X,Y
	LEAU -67,U

	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD #$dddd
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -2,U

	LDD #$bbbb
	STD -68,U
	LDA #$cc
	LDX #$7777
	LDY #$7777
	PSHU A,X,Y
	LEAU -65,U

	LDD #$dddd
	STD -8,U
	LDB #$dc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -3,U

	LDD #$bbbb
	STD -69,U
	LDA -7,U
	ANDA #$F0
	ORA #$0c
	STA -7,U
	LDD #$ccdd
	LDX #$dddd
	LDY #$dd77
	PSHU D,X,Y
	LEAU -65,U

	LDA #$dd
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$d777
	LDY #$dddd
	PSHU D,X,Y
	LDD -66,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -66,U
	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA #$cd
	PSHU A,Y
	LEAU -65,U

	LDD #$dddd
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$dd77
	LDY #$dddd
	PSHU D,X,Y
	LDD -66,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -66,U
	LDD #$ccdd
	PSHU D,Y
	LEAU -64,U

	LDA #$dd
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$dd77
	LDY #$dddd
	PSHU D,X,Y
	LDA #$bb
	STA -65,U
	LDA #$cc
	PSHU D,Y
	LEAU -64,U

	LDA #$dd
	LDX #$dccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$dd77
	LDY #$7ddd
	PSHU D,X,Y
	LDD -65,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -65,U
	LDD #$ccdd
	LDX #$dddd
	PSHU D,X
	LEAU -64,U

	LDA #$dd
	LDX #$dccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$dd77
	LDY #$7ddd
	PSHU D,X,Y
	LDD -65,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -65,U
	LDD #$ccdd
	LDX #$dddd
	PSHU D,X
	LEAU -64,U

	LDA #$dd
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$ddd7
	LDY #$77dd
	PSHU D,X,Y
	LDD #$bbbb
	STD -65,U
	LDD #$cddd
	LDX #$dddd
	PSHU D,X
	LEAU -64,U

	LDA #$dd
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LDD -75,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -75,U
	LDD #$cddd
	STD -10,U
	LDA -11,U
	ANDA #$F0
	ORA #$0c
	STA -11,U
	LDD -8,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -8,U
	LDD -71,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -71,U
	LDD #$dddd
	LDX #$ddd7
	LDY #$77dd
	PSHU D,X,Y
	LEAU -69,U

	LDX #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LDD -8,U
	LDA #$dd
	ANDB #$F0
	ORB #$0d
	STD -8,U
	LDD #$ccdd
	STD -10,U
	LDD -70,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -70,U
	LDD #$dddd
	LDY #$d777
	PSHU D,X,Y
	LEAU -66,U

	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	STD -8,U
	LDD -10,U
	LDA #$dd
	ANDB #$F0
	ORB #$0d
	STD -10,U
	LDA #$bb
	STA -71,U
	LDD #$ccdd
	STD -12,U
	LDA #$dd
	LDX #$dd77
	LDY #$dddd
	PSHU D,X,Y
	LEAU -68,U

	LDD -10,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -10,U
	STY -8,U
	LDD #$dddd
	LDX #$dccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -4,U

	LDA #$cc
	STD -8,U
	LDA #$bb
	STA -67,U
	LDD -71,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -71,U
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -65,U

	STA -7,U
	LDX #$dddc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -2,U

	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LDD -62,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -62,U
	LDA #$cc
	PSHU A,X
	LEAU -61,U

	LDD #$dddd
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDX #$dddd
	PSHU A,X
	LEAU -1,U

	LDA #$77
	LDY #$dddd
	PSHU D,X,Y
	LDD -62,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -62,U
	LDA #$cc
	LDX #$7777
	PSHU A,X
	LEAU -61,U

	LDD #$dddd
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDD -5,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -5,U
	LDX #$dddd
	PSHU A,X
	LEAU -2,U

	LDD #$cc77
	STD -8,U
	LDD -67,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -67,U
	LDD -70,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -70,U
	LDD #$7777
	LDX #$7777
	LDY #$77dd
	PSHU D,X,Y
	LEAU -64,U

	LDD #$dddd
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LDA #$77
	LDX #$dd77
	LDY #$dddd
	PSHU D,X,Y
	LDD #$bbbb
	STD -65,U
	LDD #$c777
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LEAU -60,U

	LDD #$ddcc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDB #$77
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LDD #$caaa
	STD -8,U
	LDA -9,U
	ANDA #$F0
	ORA #$0c
	STA -9,U
	LDD -67,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -67,U
	LDD #$7777
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LEAU -62,U

	LDD #$ddcc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDD #$7777
	LDX #$77dd
	LDY #$dddd
	PSHU D,X,Y
	LDD #$caaa
	STD -8,U
	LDD -6,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -6,U
	LDD -69,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -69,U
	LDA -9,U
	ANDA #$F0
	ORA #$0c
	STA -9,U
	LDD -67,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -67,U
	LDD #$7777
	LDX #$7777
	PSHU D,X
	LEAU -65,U

	LDD #$dddd
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDD #$7777
	LDX #$7777
	LDY #$77dd
	PSHU D,X,Y
	LDD -5,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -5,U
	LDX #$a777
	PSHU A,X
	LEAU -2,U

	LDA #$bb
	STA -60,U
	LDA #$cc
	LDX #$d33a
	PSHU A,X
	LEAU -58,U

	LDD #$cccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDD -8,U
	ANDA #$0F
	ORA #$70
	LDB #$77
	STD -8,U
	LDD #$7777
	LDX #$7777
	LDY #$77dd
	PSHU D,X,Y
	LEAU -2,U

	LDA #$aa
	LDX #$aa87
	PSHU A,X
	LEAU -1,U

	LDA #$bb
	STA -61,U
	LDD #$ccd3
	LDX #$3333
	PSHU D,X
	LEAU -58,U

	LDB #$cc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDD -10,U
	LDA #$aa
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDD -13,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -13,U
	LDA #$77
	STA -7,U
	LDD #$8877
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LEAU -7,U

	LDD -61,U
	ANDA #$0F
	ORA #$c0
	LDB #$bb
	STD -61,U
	LDA #$cc
	LDX #$3333
	PSHU A,X
	LEAU -58,U

	LDD #$88cc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LDA #$33
	STA -10,U
	LDD -8,U
	LDA #$33
	ANDB #$F0
	ORB #$07
	STD -8,U
	LDD -13,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -13,U
	LDD #$9987
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LEAU -7,U

	LDA #$cc
	LDX #$3333
	PSHU A,X
	LEAU -56,U

	LDB #$cc
	LDX #$cccc
	LDY #$ccbb
	PSHU D,X,Y
	LDA #$33
	STA -10,U
	STA -12,U
	LDD #$9987
	STD -8,U
	LDD #$7777
	LDX #$7777
	LDY #$8888
	PSHU D,X,Y
	LEAU -7,U

	LDA #$cc
	LDX #$3333
	LDY #$3333
	PSHU A,X,Y
	LEAU -56,U

	LDD #$88cc
	LDX #$cccc
	LDY #$ccbb
	PSHU D,X,Y
	LDB #$77
	STD -8,U
	LDA #$33
	STA -12,U
	LDA #$77
	LDX #$7777
	LDY #$8888
	PSHU D,X,Y
	LEAU -7,U

	LDD -62,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -62,U
	LDA #$cc
	LDX #$3333
	LDY #$3333
	PSHU A,X,Y
	LEAU -57,U

	LDD #$8888
	LDX #$88cc
	LDY #$cccc
	PSHU D,X,Y
	LDD -6,U
	LDA #$77
	ANDB #$F0
	ORB #$07
	STD -6,U
	LDA #$87
	STA -7,U
	LDA #$33
	STA -11,U
	LDD #$7777
	LDX #$7788
	PSHU D,X
	LEAU -8,U

	LDD -62,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -62,U
	LDA #$cc
	LDX #$3333
	LDY #$3333
	PSHU A,X,Y
	LEAU -57,U

	LDD #$8888
	LDX #$888c
	LDY #$cccc
	PSHU D,X,Y
	LDA #$33
	STA -11,U
	LDD -7,U
	LDA #$99
	ANDB #$0F
	ORB #$80
	STD -7,U
	LDA -4,U
	ANDA #$F0
	ORA #$07
	STA -4,U
	LDA #$77
	LDX #$7788
	PSHU A,X
	LEAU -9,U

	LDD -62,U
	LDA #$cb
	ANDB #$0F
	ORB #$b0
	STD -62,U
	LDA #$c8
	LDX #$3333
	LDY #$3333
	PSHU A,X,Y
	LEAU -57,U

	LDA -9,U
	ANDA #$F0
	ORA #$07
	STA -9,U
	LDA -13,U
	ANDA #$F0
	ORA #$08
	STA -13,U
	LDD #$7788
	STD -8,U
	LDD -20,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -20,U
	LDD #$8888
	LDX #$8888
	LDY #$cccc
	PSHU D,X,Y
	LEAU -14,U

	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDD -60,U
	LDA #$cb
	ANDB #$0F
	ORB #$b0
	STD -60,U
	LDA #$cc
	STA -61,U
	LDA #$88
	LDX #$3333
	PSHU A,X
	LEAU -59,U

	LDD -18,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -18,U
	LDD #$7788
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -12,U

	LDD #$cbbb
	STD -60,U
	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA -61,U
	ANDA #$F0
	ORA #$0c
	STA -61,U
	LDA #$88
	LDX #$3333
	PSHU A,X
	LEAU -59,U

	LDA #$33
	STA -17,U
	LDD #$aa88
	LDX #$8888
	PSHU D,X,Y
	LEAU -12,U

	LDD -63,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -63,U
	LDD #$cbbb
	STD -60,U
	LDD #$cc88
	LDX #$3333
	PSHU D,X
	LEAU -59,U

	LDD -17,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -17,U
	LDA #$aa
	LDX #$a888
	PSHU A,X,Y
	LEAU -12,U

	LDD -60,U
	ANDA #$F0
	ORA #$09
	LDB #$bb
	STD -60,U
	LDD #$c888
	LDX #$3333
	PSHU D,X
	LEAU -57,U

	LDA #$aa
	STA -7,U
	LDD -19,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -19,U
	LDD -79,U
	ANDA #$F0
	ORA #$09
	LDB #$9b
	STD -79,U
	LDD -23,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -23,U
	STX -21,U
	LDD #$aa88
	LDX #$8888
	PSHU D,X,Y
	LEAU -75,U

	LDA -12,U
	ANDA #$F0
	ORA #$08
	STA -12,U
	LDA -78,U
	ANDA #$F0
	ORA #$09
	STA -78,U
	LDD #$aa33
	STD -20,U
	LDD -18,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -18,U
	LDD -22,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -22,U
	LDD -77,U
	LDA #$99
	ANDB #$0F
	ORB #$b0
	STD -77,U
	LDD -81,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -81,U
	LDD #$aaaa
	LDX #$aa88
	PSHU D,X,Y
	LEAU -75,U

	LDD -79,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0880
	STD -79,U
	LDD #$aa33
	STD -19,U
	LDD -11,U
	LDA #$99
	ANDB #$0F
	ORB #$80
	STD -11,U
	LDD -17,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -17,U
	LDD -21,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -21,U
	LDD -76,U
	LDA #$99
	ANDB #$F0
	ORB #$0b
	STD -76,U
	LDD #$aaaa
	PSHU D,Y
	LEAU -75,U

	LDD #$9987
	STD -12,U
	LDB #$88
	STD -23,U
	STA -77,U
	LDA #$aa
	STA -20,U
	LDD -19,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -19,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X,Y
	LEAU -73,U

	LDD #$8877
	STD -14,U
	LDD -21,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -21,U
	LDD -82,U
	ANDA #$0F
	ORA #$80
	LDB #$88
	STD -82,U
	LDA #$aa
	STA -22,U
	LDA #$99
	STD -25,U
	STA -77,U
	STA -79,U
	LDD #$aaaa
	LDX #$8888
	PSHU D,X,Y
	LEAU -76,U

	LDA #$33
	STA -18,U
	LDD #$8777
	STD -12,U
	LDA #$aa
	STA -20,U
	LDD #$9988
	STD -23,U
	LDA -24,U
	ANDA #$F0
	ORA #$09
	STA -24,U
	LDD -75,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -75,U
	LDA #$99
	STA -77,U
	LDD -80,U
	ANDA #$0F
	ORA #$80
	LDB #$88
	STD -80,U
	LDD #$aaaa
	LDX #$aa88
	PSHU D,X
	LEAU -76,U

	LDD -12,U
	LDA #$99
	ANDB #$0F
	ORB #$80
	STD -12,U
	LDA #$33
	STA -18,U
	LDD -21,U
	ANDA #$F0
	ORA #$03
	LDB #$aa
	STD -21,U
	PSHU B,X
	LEAU -18,U

	LDA #$99
	STA -53,U
	LDD -57,U
	ANDA #$0F
	ORA #$80
	LDB #$99
	STD -57,U
	LDX #$9988
	PSHU B,X
	LEAU -54,U

	LDD -24,U
	LDA #$88
	ANDB #$F0
	ORB #$03
	STD -24,U
	LDD -26,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -26,U
	LDD -76,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -76,U
	LDD #$aa33
	STD -22,U
	LDA -14,U
	ANDA #$F0
	ORA #$08
	STA -14,U
	LDD -80,U
	ANDA #$0F
	ORA #$80
	LDB #$99
	STD -80,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X,Y
	LEAU -75,U

	LDA -5,U
	ANDA #$F0
	ORA #$0a
	STA -5,U
	PSHU X,Y
	LEAU -16,U

	LDD -56,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -56,U
	STB -6,U
	LDD #$8833
	LDX #$aa33
	PSHU D,X
	LEAU -54,U

	LDA -18,U
	ANDA #$F0
	ORA #$08
	STA -18,U
	LDD #$aaaa
	LDX #$a888
	LDY #$8899
	PSHU D,X,Y
	LEAU -16,U

	LDA #$99
	STA -6,U
	STA -55,U
	LDD #$883a
	LDX #$aa33
	PSHU D,X
	LEAU -54,U

	LDD -24,U
	ANDA #$0F
	ORA #$a0
	LDB #$88
	STD -24,U
	LDD -18,U
	LDA #$99
	ANDB #$0F
	ORB #$80
	STD -18,U
	LDA -6,U
	ANDA #$F0
	ORA #$0a
	STA -6,U
	LDA -28,U
	ANDA #$0F
	ORA #$90
	STA -28,U
	LDA -77,U
	ANDA #$F0
	ORA #$09
	STA -77,U
	LDD #$883a
	STD -26,U
	LDA #$aa
	LDX #$aa88
	PSHU A,X,Y
	LEAU -75,U

	LDD #$9987
	STD -18,U
	LDA #$aa
	PSHU A,X,Y
	LEAU -17,U

	STY -60,U
	LDD -62,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -62,U
	STA -63,U
	LDD #$8877
	STD -76,U
	LDD -82,U
	ANDA #$F0
	ORA #$07
	LDB #$89
	STD -82,U
	LDA -78,U
	ANDA #$0F
	ORA #$80
	STA -78,U
	LDD #$88aa
	STD -84,U
	LDX #$a399
	PSHU D,X
	LEAU -236,U

	LDA #$aa
	STD 18,U
	STD -62,U
	LDD 98,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 98,U
	LDD 4,U
	LDA #$99
	ANDB #$0F
	ORB #$80
	STD 4,U
	LDD -84,U
	LDA #$3a
	ANDB #$0F
	ORB #$a0
	STD -84,U
	LDA 97,U
	ANDA #$F0
	ORA #$0a
	STA 97,U
	LDA -76,U
	ANDA #$F0
	ORA #$08
	STA -76,U
	LDD #$8777
	STD 84,U
	LDD 81,U
	ANDA #$F0
	ORA #$09
	LDB #$88
	STD 81,U
	LDD 78,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD 78,U
	LDD 20,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD 20,U
	LDD #$83aa
	STD 76,U
	STY 100,U
	LDD #$8988
	STD 1,U
	LDA #$99
	STA -59,U
	LDD #$8877
	STD -79,U
	LDD #$3399
	STD -82,U
	LDB #$aa
	LDX #$3777
	PSHU D,X
	LEAU -256,U

	LDA #$99
	STA 121,U
	LDD 118,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 118,U
	LDD 21,U
	ANDA #$F0
	ORA #$09
	LDB #$88
	STD 21,U
	LDD -65,U
	ANDA #$F0
	ORA #$03
	LDB #$aa
	STD -65,U
	LDD #$9877
	STD 101,U
	LDD #$3388
	STD 98,U
	LDA #$aa
	STA 96,U
	STA 39,U
	STA 16,U
	STA -41,U
	LDA #$33
	STA 18,U
	STA -62,U
	LDD -121,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0aa0
	STD -121,U
	LDA -38,U
	ANDA #$0F
	ORA #$90
	STA -38,U
	LDA -58,U
	ANDA #$0F
	ORA #$80
	STA -58,U
	LDA -118,U
	ANDA #$F0
	ORA #$09
	STA -118,U
	LEAU -264,U

	LDD 41,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 41,U
	LDD 119,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0aa0
	STD 119,U
	LDA #$aa
	STA 64,U
	STA 39,U
	STA -16,U
	STA -41,U
	STA -121,U
	LDA #$33
	STA 122,U
	STA -119,U
	LDD -39,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -39,U
	LDA -96,U
	ANDA #$F0
	ORA #$0a
	STA -96,U
	LEAU -293,U

	LDA 120,U
	ANDA #$F0
	ORA #$0a
	STA 120,U
	LDA 38,U
	ANDA #$0F
	ORA #$a0
	STA 38,U
	LDA -39,U
	ANDA #$0F
	ORA #$a0
	STA -39,U
	LDA -42,U
	ANDA #$0F
	ORA #$a0
	STA -42,U
	LDA #$33
	STA 94,U
	STA 14,U
	LDD 11,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 11,U
	LDD 91,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 91,U
	LDD -67,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -67,U
	LDA #$aa
	STA -69,U
	STA -119,U
	LEAU -267,U

	STA 118,U
	STA 38,U
	LDD 120,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 120,U
	LDD 68,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0a70
	STD 68,U
	LDD 40,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 40,U
	LDD -40,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -40,U
	LDA -42,U
	ANDA #$0F
	ORA #$a0
	STA -42,U
	LDA -94,U
	ANDA #$0F
	ORA #$30
	STA -94,U
	LDA #$33
	STA -120,U
	LEAU -266,U

	LDA 94,U
	ANDA #$F0
	ORA #$09
	STA 94,U
	LDA 92,U
	ANDA #$F0
	ORA #$03
	STA 92,U
	LDA 12,U
	ANDA #$F0
	ORA #$03
	STA 12,U
	LDA #$33
	STA 66,U
	LDD 14,U
	LDA #$89
	ANDB #$0F
	ORB #$90
	STD 14,U
	LDD -15,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -15,U
	LDD #$9999
	STD -66,U
	LDD -95,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -95,U
	LEAU -224,U

	LDD -32,U
	ANDA #$0F
	ORA #$80
	LDB #$33
	STD -32,U
	LDD #$8898
	STD 78,U
	LDD 49,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 49,U
	LDA 128,U
	ANDA #$0F
	ORA #$80
	STA 128,U
	LDA 77,U
	ANDA #$0F
	ORA #$30
	STA 77,U
	LDA 48,U
	ANDA #$0F
	ORA #$80
	STA 48,U
	LDA #$33
	LDX #$8888
	PSHU A,X
	LEAU -77,U

	LDA -83,U
	ANDA #$F0
	ORA #$03
	STA -83,U
	LDD -32,U
	ANDA #$0F
	ORA #$80
	LDB #$33
	STD -32,U
	LDD -82,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -82,U
	LDD -112,U
	ANDA #$0F
	ORA #$70
	LDB #$33
	STD -112,U
	LDX #$9977
	PSHU B,X
	LEAU -278,U

	LDD #$3899
	STD 119,U
	LDD 89,U
	LDA #$73
	ANDB #$0F
	ORB #$30
	STD 89,U
	LDD 9,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 9,U
	LDD #$3398
	STD 39,U
	LDB #$33
	STD -41,U
	STD -121,U
	STA -71,U
	LEAU -256,U

	LDA -55,U
	ANDA #$0F
	ORA #$30
	STA -55,U
	LDD 55,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 55,U
	STB 105,U
	STB 25,U
	STB -24,U
	STB -104,U
	LEAU -224,U

	STB 40,U
	LDA -40,U
	ANDA #$F0
	ORA #$03
	STA -40,U
	RTS
