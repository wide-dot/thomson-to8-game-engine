	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_tk_055_0
	LEAU 3760,U

	LDA 125,U
	ANDA #$F0
	ORA #$09
	STA 125,U
	LDA 45,U
	ANDA #$F0
	ORA #$09
	STA 45,U
	LDA -125,U
	ANDA #$0F
	ORA #$90
	STA -125,U
	LEAU -249,U

	LDA 117,U
	ANDA #$F0
	ORA #$0b
	STA 117,U
	LDA -116,U
	ANDA #$F0
	ORA #$09
	STA -116,U
	LEAU -239,U

	LDA 43,U
	ANDA #$F0
	ORA #$09
	STA 43,U
	LDA -43,U
	ANDA #$F0
	ORA #$0b
	STA -43,U
	LEAU -402,U

	LDA 120,U
	ANDA #$0F
	ORA #$b0
	STA 120,U
	LDA 60,U
	ANDA #$0F
	ORA #$b0
	STA 60,U
	LDA 46,U
	ANDA #$0F
	ORA #$90
	STA 46,U
	LDA -34,U
	ANDA #$0F
	ORA #$90
	STA -34,U
	LDA -40,U
	ANDA #$F0
	ORA #$0b
	STA -40,U
	LDA -106,U
	ANDA #$F0
	ORA #$0b
	STA -106,U
	LDA -120,U
	ANDA #$F0
	ORA #$0b
	STA -120,U
	LDA #$99
	STA -114,U
	LDA #$bb
	STA 40,U
	LEAU -313,U

	LDA #$99
	STA 119,U
	STA 39,U
	STA -41,U
	LDA 127,U
	ANDA #$F0
	ORA #$0b
	STA 127,U
	LDA 52,U
	ANDA #$F0
	ORA #$0b
	STA 52,U
	LDA 47,U
	ANDA #$F0
	ORA #$0b
	STA 47,U
	LDA 34,U
	ANDA #$0F
	ORA #$b0
	STA 34,U
	LDA -113,U
	ANDA #$0F
	ORA #$b0
	STA -113,U
	LDA -121,U
	ANDA #$F0
	ORA #$09
	STA -121,U
	LDA -126,U
	ANDA #$F0
	ORA #$0b
	STA -126,U
	LDA #$bb
	STA -46,U
	LEAU -279,U

	LDD -2,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -2,U
	LDD -82,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -82,U
	LDA 86,U
	ANDA #$0F
	ORA #$b0
	STA 86,U
	LDA 78,U
	ANDA #$F0
	ORA #$09
	STA 78,U
	LDA 73,U
	ANDA #$F0
	ORA #$0b
	STA 73,U
	LDA 6,U
	ANDA #$0F
	ORA #$b0
	STA 6,U
	LDA -74,U
	ANDA #$0F
	ORA #$b0
	STA -74,U
	LDA -86,U
	ANDA #$0F
	ORA #$b0
	STA -86,U
	LEAU -235,U

	LDA 85,U
	ANDA #$F0
	ORA #$0b
	STA 85,U
	LDA 81,U
	ANDA #$0F
	ORA #$b0
	STA 81,U
	LDA 1,U
	ANDA #$0F
	ORA #$b0
	STA 1,U
	LDD -80,U
	LDA #$cc
	ANDB #$0F
	ORB #$b0
	STD -80,U
	LDA #$bb
	STA 69,U
	STA -11,U
	LDA #$99
	STA 74,U
	STA -6,U
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -77,U

	LDA -11,U
	ANDA #$F0
	ORA #$0b
	STA -11,U
	LDD -6,U
	LDA #$99
	ANDB #$F0
	ORB #$0c
	STD -6,U
	LDD #$cccc
	PSHU D,X
	LEAU -74,U

	LDD -13,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0bb0
	STD -13,U
	LDD #$98cc
	STD -8,U
	LDD -81,U
	LDA #$c8
	ANDB #$0F
	ORB #$80
	STD -81,U
	LDD #$cccc
	LDY #$ccc8
	PSHU D,X,Y
	LEAU -75,U

	LDA #$88
	STA -7,U
	LDA #$bb
	STA -11,U
	LDA #$8c
	LDY #$cccc
	PSHU D,X,Y
	LEAU -72,U

	LDA #$cc
	LDY #$c888
	PSHU D,X,Y
	LDA #$bb
	STA -7,U
	LDD #$8888
	LDX #$88cc
	PSHU D,X
	LEAU -69,U

	LDA #$bb
	STA -14,U
	LDA #$88
	STD -11,U
	LDD -9,U
	LDA #$88
	ANDB #$0F
	ORB #$c0
	STD -9,U
	LDD #$cccc
	LDX #$cccc
	LDY #$8888
	PSHU D,X,Y
	LEAU -73,U

	LDX #$cc88
	LDY #$8889
	PSHU A,X,Y
	LEAU -4,U

	LDD -5,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$b008
	STD -5,U
	LDA #$bb
	STA -6,U
	LDA #$88
	LDX #$8888
	PSHU A,X
	LEAU -68,U

	LDA -5,U
	ANDA #$F0
	ORA #$0c
	STA -5,U
	LDD #$cc88
	PSHU D,X
	LEAU -5,U

	LDD #$bbbb
	LDY #$8888
	PSHU D,X,Y
	LEAU -65,U

	LDA -5,U
	ANDA #$F0
	ORA #$0c
	STA -5,U
	LDA -15,U
	ANDA #$F0
	ORA #$0b
	STA -15,U
	LDD -10,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDD -81,U
	LDA #$8c
	ANDB #$0F
	ORB #$c0
	STD -81,U
	LDD -12,U
	ANDA #$0F
	ORA #$80
	LDB #$88
	STD -12,U
	LDD #$bb88
	STD -14,U
	LDA #$cc
	PSHU D,X
	LEAU -77,U

	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA #$cc
	PSHU A,X
	LEAU -4,U

	LDA -7,U
	ANDA #$F0
	ORA #$0b
	STA -7,U
	LDD #$bcc8
	STD -6,U
	LDA #$88
	PSHU A,X
	LEAU -68,U

	LDA -6,U
	ANDA #$F0
	ORA #$0c
	STA -6,U
	LDA #$cc
	LDY #$8ccc
	PSHU A,X,Y
	LEAU -4,U

	LDB #$cc
	STD -6,U
	LDA #$88
	PSHU A,X
	LEAU -68,U

	LDA #$cc
	STD -6,U
	STD -15,U
	LDD -10,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDD -81,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -81,U
	LDD -85,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -85,U
	LDD -12,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -12,U
	LDD #$888c
	STD -83,U
	LDA #$cc
	STA -86,U
	LDA #$88
	PSHU A,Y
	LEAU -85,U

	LDD -5,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$c008
	STD -5,U
	LDA -8,U
	ANDA #$F0
	ORA #$0c
	STA -8,U
	LDD #$cccc
	STD -7,U
	LDA #$88
	PSHU A,X
	LEAU -68,U

	LDD -5,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$c008
	STD -5,U
	LDD #$cccc
	STD -7,U
	LDA #$8c
	LDX #$cccc
	PSHU A,X
	LEAU -6,U

	LDD -5,U
	LDA #$cc
	ANDB #$F0
	ORB #$08
	STD -5,U
	LDA #$88
	LDX #$8888
	PSHU A,X
	LEAU -2,U

	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -63,U

	STX -7,U
	LDD -5,U
	LDA #$cc
	ANDB #$F0
	ORB #$08
	STD -5,U
	LDD -10,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDA #$8c
	PSHU A,X
	LEAU -7,U

	LDA #$cc
	STA -7,U
	LDD #$cccc
	LDX #$ccc8
	LDY #$8888
	PSHU D,X,Y
	LEAU -64,U

	STA -7,U
	LDX #$888c
	LDY #$cccc
	PSHU D,X,Y
	LEAU -2,U

	STD -8,U
	LDA -9,U
	ANDA #$0F
	ORA #$c0
	STA -9,U
	LDD -73,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -73,U
	LDD #$cccc
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -67,U

	LDX #$cc88
	LDY #$8ccc
	PSHU D,X,Y
	LEAU -1,U

	LDA -10,U
	ANDA #$F0
	ORA #$0c
	STA -10,U
	LDD -8,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -8,U
	LDD #$cccc
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -65,U

	LDD -5,U
	LDA #$d7
	ANDB #$0F
	ORB #$80
	STD -5,U
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -2,U

	LDA #$88
	STA -7,U
	LDD #$8888
	LDX #$88cc
	LDY #$dddd
	PSHU D,X,Y
	LEAU -2,U

	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA #$cc
	STA -6,U
	LDX #$cccc
	PSHU A,X
	LEAU -64,U

	LDD #$dddd
	LDX #$88cc
	LDY #$cccc
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	LDY #$dddd
	PSHU D,X,Y
	LEAU -1,U

	LDA #$cc
	STA -6,U
	LDX #$cccc
	PSHU A,X
	LEAU -64,U

	LDD #$dddd
	LDX #$78cc
	LDY #$cccc
	PSHU D,X,Y
	LDA #$88
	LDX #$8877
	LDY #$77dd
	PSHU A,X,Y
	LEAU -2,U

	LDD -71,U
	LDA #$d7
	ANDB #$F0
	ORB #$0c
	STD -71,U
	LDD #$cccc
	STD -69,U
	LDA -6,U
	ANDA #$0F
	ORA #$c0
	STA -6,U
	LDX #$cccc
	PSHU B,X
	LEAU -68,U

	LDA -7,U
	ANDA #$F0
	ORA #$08
	STA -7,U
	LDD #$8877
	LDX #$77dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -3,U

	LDD -70,U
	ANDA #$0F
	ORA #$70
	LDB #$cc
	STD -70,U
	LDD -68,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -68,U
	LDX #$cccc
	PSHU A,X
	LEAU -67,U

	LDA #$77
	STA -7,U
	LDD #$7777
	LDX #$77dd
	LDY #$7777
	PSHU D,X,Y
	LEAU -4,U

	LDA -7,U
	ANDA #$F0
	ORA #$0c
	STA -7,U
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -63,U

	LDD #$777d
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LDA #$dd
	LDX #$777a
	LDY #$7777
	PSHU A,X,Y
	LEAU -3,U

	LDA -7,U
	ANDA #$F0
	ORA #$0c
	STA -7,U
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -63,U

	LDD #$7ddd
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDX #$d7aa
	LDY #$aa77
	PSHU B,X,Y
	LEAU -3,U

	LDD -70,U
	LDA #$dd
	ANDB #$F0
	ORB #$0c
	STD -70,U
	LDD #$cccc
	STD -68,U
	LDA -7,U
	ANDA #$0F
	ORA #$c0
	STA -7,U
	LDX #$cccc
	PSHU B,X
	LEAU -67,U

	STX -78,U
	LDD -11,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -11,U
	LDD -80,U
	LDA #$7d
	ANDB #$0F
	ORB #$d0
	STD -80,U
	LDD -13,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -13,U
	LDD #$dddd
	STD -8,U
	LDB #$77
	LDX #$aaaa
	LDY #$77dd
	PSHU D,X,Y
	LEAU -74,U

	LDD -13,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -13,U
	LDD -11,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -11,U
	LDD #$dddd
	STD -8,U
	LDB #$d7
	LDX #$77aa
	LDY #$a777
	PSHU D,X,Y
	LEAU -70,U

	LDD #$aa77
	LDX #$7777
	LDY #$cccc
	PSHU D,X,Y
	LDD -75,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -75,U
	STY -10,U
	LDD -8,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$c00d
	STD -8,U
	LDD #$dddd
	LDX #$dd77
	LDY #$7777
	PSHU D,X,Y
	LEAU -69,U

	LDB #$77
	LDX #$7777
	LDY #$77cc
	PSHU D,X,Y
	LDB #$dd
	LDX #$dddd
	LDY #$777d
	PSHU D,X,Y
	LDD -68,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -68,U
	LDX #$cccc
	PSHU A,X
	LEAU -65,U

	LDD #$dddd
	LDX #$dd77
	LDY #$77cc
	PSHU D,X,Y
	LDX #$dddd
	LDY #$77dd
	PSHU D,X,Y
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -63,U

	LDA #$dd
	LDX #$dd7c
	LDY #$cccc
	PSHU D,X,Y
	LDX #$77dd
	LDY #$dddd
	PSHU D,X,Y
	LDA #$cc
	LDX #$cccc
	PSHU A,X,Y
	LEAU -63,U

	LDA #$dd
	LDX #$dddc
	LDY #$cccc
	PSHU D,X,Y
	LDB #$d7
	LDX #$77dd
	LDY #$dddd
	PSHU D,X,Y
	LDA -5,U
	ANDA #$F0
	ORA #$0c
	STA -5,U
	LDD #$cccc
	PSHU D,Y
	LEAU -64,U

	LDD #$dddd
	LDX #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LDB #$d7
	LDX #$77dd
	LDY #$dddd
	PSHU D,X,Y
	LDA -5,U
	ANDA #$F0
	ORA #$0c
	STA -5,U
	LDD #$cccd
	PSHU D,Y
	LEAU -64,U

	LDD #$dddd
	LDX #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LDB #$d7
	LDX #$7ddd
	LDY #$dddd
	PSHU D,X,Y
	LDD #$ccdd
	PSHU D,Y
	LEAU -64,U

	LDA #$dd
	LDX #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LDA #$77
	LDX #$7ddd
	LDY #$dddd
	PSHU A,X,Y
	LEAU -1,U

	LDA #$cc
	PSHU D,Y
	LEAU -64,U

	LDA #$dd
	LDX #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LDD -5,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD -5,U
	LDA #$dd
	PSHU A,X
	LEAU -4,U

	LDA #$cc
	PSHU A,X
	LEAU -64,U

	LDD #$dddd
	PSHU D,X,Y
	LDA #$77
	STA -5,U
	STX -9,U
	LDD -75,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -75,U
	LDA -10,U
	ANDA #$F0
	ORA #$0c
	STA -10,U
	LDA -18,U
	ANDA #$F0
	ORA #$0b
	STA -18,U
	LDA #$dd
	PSHU A,X
	LEAU -72,U

	STX -8,U
	LDA #$77
	STA -10,U
	LDD -13,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -13,U
	LDD -80,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -80,U
	LDA -23,U
	ANDA #$F0
	ORA #$0b
	STA -23,U
	LDA #$dd
	STA -14,U
	LDD #$dddd
	LDY #$ddcc
	PSHU D,X,Y
	LEAU -74,U

	LDD -8,U
	LDA #$dd
	ANDB #$F0
	ORB #$0d
	STD -8,U
	LDA #$77
	STA -10,U
	LDD #$dddd
	LDY #$dddc
	PSHU D,X,Y
	LEAU -5,U

	LDD -69,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -69,U
	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	LDA #$dd
	PSHU A,X
	LEAU -66,U

	LDD -8,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDA #$77
	STA -10,U
	STX -13,U
	LDA -14,U
	ANDA #$F0
	ORA #$0d
	STA -14,U
	LDA -23,U
	ANDA #$0F
	ORA #$b0
	STA -23,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -72,U

	LDA #$77
	STA -12,U
	LDD -10,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0dd0
	STD -10,U
	STX -8,U
	STX -15,U
	LDA -17,U
	ANDA #$0F
	ORA #$c0
	STA -17,U
	LDA -25,U
	ANDA #$0F
	ORA #$b0
	STA -25,U
	LDD #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LEAU -74,U

	PSHU D,X,Y
	STD -9,U
	LDD -7,U
	ANDA #$0F
	ORA #$d0
	LDB #$77
	STD -7,U
	LDA #$dd
	PSHU A,X
	LEAU -71,U

	LDD -8,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -8,U
	STB -9,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -5,U

	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	LDX #$dd77
	PSHU B,X
	LEAU -66,U

	LDD #$7777
	STD -8,U
	LDX #$7777
	PSHU D,X,Y
	LEAU -3,U

	LDA -9,U
	ANDA #$F0
	ORA #$0c
	STA -9,U
	LDA #$dd
	LDX #$dd77
	LDY #$7777
	PSHU A,X,Y
	LEAU -66,U

	STY -8,U
	STB -11,U
	LDD -10,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -10,U
	LDD -18,U
	LDA #$cc
	ANDB #$F0
	ORB #$07
	STD -18,U
	STY -16,U
	LDD #$7777
	LDX #$7777
	LDY #$cccc
	PSHU D,X,Y
	LEAU -74,U

	LDD -8,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD -8,U
	LDD #$7777
	PSHU D,X,Y
	LEAU -2,U

	PSHU A,X
	LEAU -2,U

	LDA #$88
	STA -7,U
	LDB #$88
	LDY #$7777
	PSHU D,X,Y
	LEAU -61,U

	LDA #$77
	STA -7,U
	STA -10,U
	LDB #$77
	LDX #$aaaa
	LDY #$88cc
	PSHU D,X,Y
	LEAU -7,U

	LDD #$8888
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LDA -5,U
	ANDA #$F0
	ORA #$08
	STA -5,U
	LDA -7,U
	ANDA #$F0
	ORA #$0b
	STA -7,U
	LDD #$8888
	LDX #$8888
	PSHU D,X
	LEAU -57,U

	LDD #$aaaa
	STD -8,U
	LDA -9,U
	ANDA #$F0
	ORA #$07
	STA -9,U
	LDD #$aaaa
	LDX #$aaaa
	LDY #$8888
	PSHU D,X,Y
	LEAU -4,U

	LDD #$7777
	LDX #$7777
	LDY #$8877
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	PSHU D,X,Y
	LDA #$99
	PSHU D,X
	LEAU -52,U

	LDD #$a333
	LDY #$9999
	PSHU D,X,Y
	LDA #$89
	LDX #$aaaa
	LDY #$aaaa
	PSHU A,X,Y
	LEAU -1,U

	LDD #$7777
	LDX #$7777
	LDY #$9977
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	LDY #$8877
	PSHU D,X,Y
	LDA -7,U
	ANDA #$F0
	ORA #$09
	STA -7,U
	LDD #$9999
	LDX #$9988
	LDY #$8888
	PSHU D,X,Y
	LEAU -50,U

	LDD #$3333
	LDX #$8888
	LDY #$9999
	PSHU D,X,Y
	LDD #$7389
	LDX #$aaaa
	LDY #$3333
	PSHU D,X,Y
	LEAU -1,U

	LDD #$7777
	LDX #$7777
	LDY #$7799
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LDA #$99
	STA -7,U
	LDB #$99
	LDX #$9999
	PSHU D,X,Y
	LEAU -49,U

	LDD #$3333
	LDX #$8888
	LDY #$9999
	PSHU D,X,Y
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD #$7777
	LDX #$7777
	LDY #$8833
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	LDY #$8877
	PSHU D,X,Y
	LDD #$9999
	STD -8,U
	LDX #$9988
	LDY #$8888
	PSHU D,X,Y
	LEAU -52,U

	LDD #$3333
	LDX #$3333
	PSHU D,X,Y
	LDD -7,U
	LDA #$37
	ANDB #$0F
	ORB #$70
	STD -7,U
	LDA #$33
	LDY #$3333
	PSHU A,X,Y
	LEAU -2,U

	LDD #$8888
	LDX #$7777
	LDY #$7773
	PSHU D,X,Y
	LDD #$9999
	STD -8,U
	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDD #$8888
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -55,U

	LDD #$3333
	LDX #$3333
	PSHU D,X,Y
	LDA #$99
	LDY #$3333
	PSHU D,X,Y
	LDD #$88aa
	LDX #$7733
	PSHU D,X,Y
	LDD #$9988
	STD -8,U
	STB -63,U
	LDA #$88
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -58,U

	LDD #$3333
	LDX #$3333
	LDY #$33aa
	PSHU D,X,Y
	LDX #$8833
	LDY #$3333
	PSHU D,X,Y
	LDD #$8888
	LDX #$aaaa
	PSHU D,X,Y
	STA -61,U
	LDA #$99
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -56,U

	LDD #$3333
	LDX #$3333
	LDY #$33aa
	PSHU D,X,Y
	LDY #$3333
	PSHU D,X,Y
	LDD #$88aa
	LDX #$aaaa
	PSHU D,X,Y
	LDD -6,U
	LDA #$99
	ANDB #$F0
	ORB #$08
	STD -6,U
	LDA #$88
	STA -61,U
	LDD #$8888
	LDX #$8888
	PSHU D,X
	LEAU -58,U

	LDD #$3333
	LDX #$3333
	LDY #$33aa
	PSHU D,X,Y
	LDY #$3333
	PSHU D,X,Y
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X,Y
	LDA #$88
	STA -61,U
	LDA #$99
	STA -6,U
	LDD #$8888
	LDX #$8888
	PSHU D,X
	LEAU -58,U

	LDD #$3333
	LDX #$3333
	LDY #$33aa
	PSHU D,X,Y
	LDY #$3333
	PSHU D,X,Y
	LDD #$aaaa
	LDX #$aa33
	PSHU D,X,Y
	LDA #$99
	STA -6,U
	LDD -62,U
	ANDA #$0F
	ORA #$30
	LDB #$88
	STD -62,U
	LDX #$88aa
	PSHU B,X
	LEAU -59,U

	LDD #$3333
	LDX #$3333
	LDY #$33aa
	PSHU D,X,Y
	LDY #$3333
	PSHU D,X,Y
	LDD #$aaaa
	STD -8,U
	LDA #$99
	STA -12,U
	LDA #$aa
	PSHU D,X,Y
	LEAU -60,U

	LDD #$3333
	LDX #$333a
	LDY #$a388
	PSHU D,X,Y
	LDB #$83
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDB #$33
	PSHU D,X,Y
	LDA #$99
	STA -8,U
	LDA #$aa
	LDX #$aaaa
	LDY #$aaa3
	PSHU A,X,Y
	LEAU -57,U

	LDA #$33
	LDX #$333a
	LDY #$aa88
	PSHU D,X,Y
	LDD #$3899
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD #$3333
	PSHU D,X,Y
	LDA #$99
	STA -8,U
	LDD #$aaaa
	LDX #$aaaa
	LDY #$aa33
	PSHU D,X,Y
	LEAU -56,U

	LDD #$3333
	LDX #$333a
	LDY #$aa88
	PSHU D,X,Y
	LDD -7,U
	LDA #$33
	ANDB #$F0
	ORB #$08
	STD -7,U
	LDA #$99
	LDX #$3333
	LDY #$3333
	PSHU A,X,Y
	LEAU -2,U

	LDD #$3333
	PSHU D,X,Y
	LDD -7,U
	LDA #$99
	ANDB #$F0
	ORB #$0a
	STD -7,U
	LDA #$aa
	LDX #$aaaa
	LDY #$aa33
	PSHU A,X,Y
	LEAU -56,U

	LDD #$3333
	LDX #$3337
	LDY #$aaa8
	PSHU D,X,Y
	LDA #$88
	LDX #$3333
	LDY #$3333
	PSHU A,X,Y
	LEAU -1,U

	LDA #$33
	PSHU D,X,Y
	LDD #$99aa
	STD -8,U
	LDA #$aa
	LDX #$aaa3
	PSHU D,X,Y
	LEAU -56,U

	LDD #$3333
	LDX #$3337
	LDY #$aaaa
	PSHU D,X,Y
	LDA #$78
	LDX #$3333
	LDY #$3333
	PSHU A,X,Y
	LEAU -1,U

	LDA #$33
	PSHU D,X,Y
	LDD -63,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -63,U
	LDD #$aaaa
	STD -8,U
	LDX #$aa33
	PSHU D,X,Y
	LEAU -57,U

	LDD #$3333
	LDX #$3333
	LDY #$37aa
	PSHU D,X,Y
	LDB #$38
	LDX #$9933
	LDY #$3333
	PSHU D,X,Y
	LDB #$33
	LDX #$3333
	PSHU D,X,Y
	LDD #$aaaa
	STD -8,U
	LDX #$aa33
	PSHU D,X,Y
	LEAU -54,U

	LDD #$3333
	LDX #$37aa
	LDY #$aaaa
	PSHU D,X,Y
	LDA #$83
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDA #$33
	PSHU D,X,Y
	LDA #$a3
	PSHU D,X,Y
	LDA -5,U
	ANDA #$F0
	ORA #$0a
	STA -5,U
	LDD -57,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -57,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -53,U

	LDD #$3333
	LDX #$3333
	LDY #$aaaa
	PSHU D,X,Y
	LDY #$3333
	PSHU D,X,Y
	PSHU D,X,Y
	LDA #$aa
	PSHU D,X,Y
	LDB #$aa
	STD -56,U
	LDD -59,U
	LDA #$33
	ANDB #$0F
	ORB #$90
	STD -59,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -55,U

	LDD #$3333
	LDX #$3333
	PSHU D,X,Y
	PSHU D,X,Y
	PSHU D,X,Y
	LDA #$aa
	STA -58,U
	LDB #$aa
	STD -8,U
	LDA #$33
	PSHU A,X
	LEAU -57,U

	LDB #$33
	PSHU D,X,Y
	LDY #$8333
	PSHU D,X,Y
	LDY #$3333
	PSHU D,X,Y
	LDD #$8aaa
	STD -11,U
	LDA #$33
	PSHU A,X,Y
	LEAU -57,U

	LDB #$33
	LDX #$3388
	PSHU D,X,Y
	LDX #$3338
	LDY #$9933
	PSHU D,X,Y
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD -63,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -63,U
	LDD #$3333
	PSHU D,X,Y
	LEAU -57,U

	LDD -8,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD -8,U
	LDD #$3333
	LDY #$8933
	PSHU D,X,Y
	LEAU -2,U

	LDY #$3333
	PSHU D,X,Y
	PSHU D,X,Y
	LDA #$99
	STA -8,U
	PSHU B,X
	LEAU -55,U

	LDA #$33
	LDX #$8983
	PSHU D,X,Y
	LDD -7,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -7,U
	LDD -11,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -11,U
	LDD #$7788
	PSHU D,Y
	LEAU -7,U

	LDD #$3333
	LDX #$3333
	PSHU D,X,Y
	LDA #$99
	STA -7,U
	PSHU B,X
	LEAU -54,U

	LDD -7,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0880
	STD -7,U
	LDD -13,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -13,U
	LDD #$7778
	STD -10,U
	LDA #$33
	LDX #$8883
	PSHU A,X,Y
	LEAU -11,U

	LDB #$33
	LDX #$3333
	PSHU D,X,Y
	LDD -59,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -59,U
	LDA #$99
	STA -8,U
	LDA -5,U
	ANDA #$F0
	ORA #$03
	STA -5,U
	PSHU X,Y
	LEAU -55,U

	LDD -9,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD -9,U
	LDD -6,U
	LDA #$88
	ANDB #$0F
	ORB #$90
	STD -6,U
	LDA -12,U
	ANDA #$F0
	ORA #$03
	STA -12,U
	LDA #$77
	LDX #$9333
	PSHU A,X
	LEAU -20,U

	LDA #$99
	STA -6,U
	STA -86,U
	LDD #$8898
	STD -63,U
	LDA -58,U
	ANDA #$F0
	ORA #$03
	STA -58,U
	LDA -65,U
	ANDA #$0F
	ORA #$80
	STA -65,U
	LDA #$89
	STA -60,U
	STY -57,U
	LDD -84,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -84,U
	PSHU B,Y
	LEAU -228,U

	STY 94,U
	LDA #$88
	STA 91,U
	STA 65,U
	LDA #$89
	STA -15,U
	LDD #$7888
	STD 88,U
	LDD #$9933
	STD -95,U
	LDD #$7789
	STD 8,U
	LDA #$33
	STA -13,U
	LDD -65,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -65,U
	LDD 67,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 67,U
	LDD 15,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 15,U
	LDD -72,U
	LDA #$88
	ANDB #$0F
	ORB #$90
	STD -72,U

	LDU <glb_screen_location_1
	LEAU 3972,U

	LDA ,U
	ANDA #$0F
	ORA #$b0
	STA ,U
	LEAU -321,U

	LDA ,U
	ANDA #$F0
	ORA #$0b
	STA ,U
	LEAU -455,U

	LDA 128,U
	ANDA #$F0
	ORA #$0b
	STA 128,U
	LDA 39,U
	ANDA #$0F
	ORA #$90
	STA 39,U
	LDA -26,U
	ANDA #$0F
	ORA #$90
	STA -26,U
	LDA -41,U
	ANDA #$0F
	ORA #$90
	STA -41,U
	LDA -47,U
	ANDA #$0F
	ORA #$b0
	STA -47,U
	LDA -112,U
	ANDA #$0F
	ORA #$b0
	STA -112,U
	LDA -127,U
	ANDA #$F0
	ORA #$0b
	STA -127,U
	LDA #$99
	STA -121,U
	LEAU -319,U

	STA 118,U
	LDA 127,U
	ANDA #$0F
	ORA #$b0
	STA 127,U
	LDA 38,U
	ANDA #$F0
	ORA #$09
	STA 38,U
	LDA -42,U
	ANDA #$F0
	ORA #$09
	STA -42,U
	LDA -122,U
	ANDA #$F0
	ORA #$09
	STA -122,U
	LDA -127,U
	ANDA #$0F
	ORA #$b0
	STA -127,U
	LEAU -324,U

	LDA 43,U
	ANDA #$0F
	ORA #$90
	STA 43,U
	LDA 37,U
	ANDA #$F0
	ORA #$0b
	STA 37,U
	LDA -37,U
	ANDA #$0F
	ORA #$90
	STA -37,U
	LDA #$bb
	STA 117,U
	LDA #$99
	STA -117,U
	LEAU -311,U

	LDA 126,U
	ANDA #$F0
	ORA #$0b
	STA 126,U
	LDA 109,U
	ANDA #$0F
	ORA #$b0
	STA 109,U
	LDA -39,U
	ANDA #$F0
	ORA #$0b
	STA -39,U
	LDA -119,U
	ANDA #$F0
	ORA #$0b
	STA -119,U
	LDA #$99
	STA 114,U
	STA 34,U
	STA -46,U
	STA -126,U
	LDA #$bb
	STA 29,U
	STA -51,U
	LEAU -131,U

	LDA ,U
	ANDA #$F0
	ORA #$0b
	STA ,U
	LEAU -147,U

	LDA #$99
	STA 72,U
	LDD #$cccc
	STD 76,U
	LDA 79,U
	ANDA #$F0
	ORA #$0b
	STA 79,U
	LDA 68,U
	ANDA #$0F
	ORA #$b0
	STA 68,U
	LDA -77,U
	ANDA #$F0
	ORA #$09
	STA -77,U
	LDD -8,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -8,U
	LDD -81,U
	LDA #$cc
	ANDB #$0F
	ORB #$80
	STD -81,U
	LDA #$bb
	STA -12,U
	LDD #$cccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -75,U

	LDA #$99
	STA -7,U
	LDA #$bb
	STA -11,U
	LDA #$88
	PSHU D,X,Y
	LEAU -72,U

	LDA #$cc
	LDY #$cc88
	PSHU D,X,Y
	LDA #$bb
	STA -7,U
	LDA -72,U
	ANDA #$0F
	ORA #$90
	STA -72,U
	LDA #$88
	LDX #$88cc
	PSHU A,X
	LEAU -70,U

	LDA #$cc
	LDX #$cccc
	LDY #$8888
	PSHU D,X,Y
	LDD -8,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -8,U
	LDD -75,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -75,U
	LDD #$8888
	PSHU D,X
	LEAU -71,U

	LDA -5,U
	ANDA #$F0
	ORA #$0c
	STA -5,U
	LDY #$cc88
	PSHU X,Y
	LEAU -2,U

	LDD -7,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -7,U
	LDD #$8888
	LDX #$88cc
	PSHU D,X
	LEAU -68,U

	LDD -10,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDD -81,U
	LDA #$88
	ANDB #$0F
	ORB #$c0
	STD -81,U
	LDD #$8888
	STD -12,U
	LDA #$bb
	STA -14,U
	LDA #$cc
	LDX #$cc88
	LDY #$8888
	PSHU A,X,Y
	LEAU -76,U

	PSHU A,Y
	LEAU -4,U

	LDD #$bbb8
	LDX #$8888
	PSHU D,X,Y
	LEAU -65,U

	STX -11,U
	LDA #$cc
	LDX #$c888
	LDY #$88cc
	PSHU A,X,Y
	LEAU -7,U

	LDA #$bb
	LDX #$cc88
	PSHU A,X
	LEAU -65,U

	LDD -14,U
	LDA #$cc
	ANDB #$0F
	ORB #$80
	STD -14,U
	LDD -81,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -81,U
	LDD #$8888
	STD -11,U
	LDA #$bb
	STA -15,U
	LDA #$cc
	LDX #$c888
	PSHU A,X,Y
	LEAU -76,U

	LDD -9,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -9,U
	LDD -13,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -13,U
	LDA #$88
	STA -10,U
	LDA #$bb
	STA -14,U
	LDD #$cccc
	LDX #$8888
	PSHU D,X
	LEAU -74,U

	LDY #$cccc
	PSHU D,X,Y
	LEAU -3,U

	LDA #$88
	PSHU A,X
	LEAU -1,U

	PSHU B,Y
	LEAU -64,U

	STY -6,U
	PSHU A,Y
	LEAU -6,U

	PSHU A,X
	LEAU -1,U

	PSHU B,Y
	LEAU -64,U

	STY -6,U
	STY -16,U
	STY -86,U
	LDD -10,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDD -14,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -14,U
	LDD -81,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -81,U
	STX -12,U
	LDD #$88cc
	STD -83,U
	PSHU A,Y
	LEAU -85,U

	STB -7,U
	LDA -9,U
	ANDA #$F0
	ORA #$0c
	STA -9,U
	LDD #$cccc
	LDY #$8888
	PSHU D,X,Y
	LEAU -65,U

	LDD -6,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -6,U
	STA -7,U
	LDD #$88cc
	LDX #$cccc
	PSHU D,X
	LEAU -5,U

	STB -7,U
	STB -9,U
	LDA #$cc
	LDX #$8888
	PSHU D,X,Y
	LEAU -65,U

	LDD -8,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -8,U
	LDD #$cccc
	LDX #$88cc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -2,U

	LDD #$8888
	LDX #$8888
	PSHU D,X
	LEAU -1,U

	LDA #$cc
	STA -5,U
	PSHU A,Y
	LEAU -64,U

	LDD -8,U
	ANDA #$F0
	ORA #$0c
	LDB #$cd
	STD -8,U
	LDD #$dddd
	LDX #$88cc
	PSHU D,X,Y
	LEAU -2,U

	LDD #$8888
	LDX #$8888
	PSHU D,X
	LEAU -1,U

	LDA -5,U
	ANDA #$0F
	ORA #$c0
	STA -5,U
	LDD -68,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -68,U
	LDD -70,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -70,U
	PSHU B,Y
	LEAU -67,U

	STX -8,U
	LDD #$8887
	LDX #$dddd
	LDY #$dd78
	PSHU D,X,Y
	LEAU -4,U

	LDD -68,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -68,U
	LDD -70,U
	ANDA #$0F
	ORA #$80
	LDB #$cc
	STD -70,U
	LDX #$cccc
	PSHU B,X
	LEAU -67,U

	LDD #$8888
	STD -8,U
	LDB #$77
	LDX #$7ddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -4,U

	LDA -6,U
	ANDA #$F0
	ORA #$0c
	STA -6,U
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -63,U

	LDD #$dddd
	LDX #$78cc
	LDY #$cccc
	PSHU D,X,Y
	LDA #$cc
	STA -14,U
	LDD -11,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -11,U
	LDD -9,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -9,U
	LDA #$88
	LDX #$7777
	LDY #$77dd
	PSHU A,X,Y
	LEAU -69,U

	LDD #$7777
	LDX #$77cc
	LDY #$cccc
	PSHU D,X,Y
	STY -76,U
	LDD -9,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -9,U
	LDD -78,U
	LDA #$dd
	ANDB #$F0
	ORB #$0c
	STD -78,U
	LDD -11,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -11,U
	LDA -5,U
	ANDA #$F0
	ORA #$08
	STA -5,U
	LDA -14,U
	ANDA #$0F
	ORA #$c0
	STA -14,U
	LDD #$7777
	LDX #$77dd
	PSHU D,X
	LEAU -74,U

	LDA #$dd
	STA -7,U
	LDA #$77
	LDX #$aa77
	LDY #$7777
	PSHU D,X,Y
	LEAU -3,U

	LDD -71,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -71,U
	LDD #$cccc
	STD -69,U
	LDX #$cccc
	PSHU A,X
	LEAU -68,U

	LDA #$dd
	STA -7,U
	LDB #$77
	LDX #$aaa7
	LDY #$77dd
	PSHU D,X,Y
	LEAU -3,U

	LDD -68,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -68,U
	LDX #$cccc
	PSHU A,X
	LEAU -65,U

	LDD #$aa77
	LDX #$77dd
	LDY #$ddcc
	PSHU D,X,Y
	LDA -5,U
	ANDA #$F0
	ORA #$0d
	STA -5,U
	LDD #$dddd
	LDX #$d77a
	PSHU D,X
	LEAU -2,U

	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -63,U

	LDD #$7777
	LDX #$ddcc
	LDY #$cccc
	PSHU D,X,Y
	LDA #$dd
	STA -7,U
	LDB #$dd
	LDX #$dd77
	LDY #$7aaa
	PSHU D,X,Y
	LEAU -2,U

	LDA -8,U
	ANDA #$F0
	ORA #$0c
	STA -8,U
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -63,U

	LDD #$a777
	LDX #$77cc
	LDY #$cccc
	PSHU D,X,Y
	LDA #$dd
	STA -7,U
	LDB #$dd
	LDX #$dd77
	LDY #$7777
	PSHU D,X,Y
	LEAU -2,U

	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -63,U

	LDD #$7777
	LDX #$777c
	LDY #$cccc
	PSHU D,X,Y
	LDA #$dd
	STA -7,U
	LDB #$dd
	LDX #$d777
	LDY #$ddd7
	PSHU D,X,Y
	LEAU -2,U

	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -63,U

	LDA #$dd
	LDX #$7777
	LDY #$cccc
	PSHU D,X,Y
	STY -10,U
	LDD -8,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -8,U
	LDA -11,U
	ANDA #$F0
	ORA #$0c
	STA -11,U
	LDD #$dddd
	LDX #$777d
	LDY #$dddd
	PSHU D,X,Y
	LEAU -68,U

	LDX #$dd77
	LDY #$cccc
	PSHU D,X,Y
	LDX #$777d
	LDY #$dddd
	PSHU D,X,Y
	LDD #$cccc
	PSHU D,Y
	LEAU -64,U

	LDD #$dddd
	LDX #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LDX #$77dd
	LDY #$dddd
	PSHU D,X,Y
	LDD -69,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -69,U
	LDD #$cccc
	PSHU D,Y
	LEAU -65,U

	LDD #$dddd
	LDX #$dddd
	LDY #$ddcc
	PSHU D,X,Y
	LDX #$dd77
	LDY #$dddd
	PSHU D,X,Y
	LDD -68,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -68,U
	LDX #$ccdd
	PSHU A,X
	LEAU -65,U

	LDD #$dddd
	LDX #$dddd
	LDY #$ddcc
	PSHU D,X,Y
	LDX #$dd77
	LDY #$dddd
	PSHU D,X,Y
	LDA #$cc
	LDX #$ccdd
	PSHU A,X
	LEAU -63,U

	LDA #$dd
	LDX #$dddc
	LDY #$cccc
	PSHU D,X,Y
	LDA #$77
	LDX #$dddd
	LDY #$dddd
	PSHU A,X,Y
	LEAU -2,U

	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA -11,U
	ANDA #$0F
	ORA #$b0
	STA -11,U
	LDA #$cc
	PSHU A,X
	LEAU -64,U

	LDA #$dd
	LDX #$dddc
	LDY #$cccc
	PSHU D,X,Y
	LDD -9,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -9,U
	LDA #$cd
	STA -10,U
	LDA -18,U
	ANDA #$0F
	ORA #$b0
	STA -18,U
	LDA #$77
	LDX #$dddd
	LDY #$dddd
	PSHU A,X,Y
	LEAU -69,U

	LDD #$dddd
	LDY #$cccc
	PSHU D,X,Y
	LDA #$77
	LDY #$dddd
	PSHU A,X,Y
	LEAU -2,U

	PSHU B,X
	LEAU -64,U

	LDA #$dd
	LDY #$cccc
	PSHU D,X,Y
	LDA -6,U
	ANDA #$F0
	ORA #$07
	STA -6,U
	LDA #$77
	LDY #$dddd
	PSHU A,X,Y
	LEAU -2,U

	PSHU B,X
	LEAU -64,U

	LDA #$dd
	LDY #$cccc
	PSHU D,X,Y
	LDD -5,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD -5,U
	STX -9,U
	LDA -6,U
	ANDA #$F0
	ORA #$07
	STA -6,U
	LDA -10,U
	ANDA #$0F
	ORA #$d0
	STA -10,U
	LDA #$dd
	PSHU A,X
	LEAU -71,U

	LDD #$dddd
	PSHU D,X,Y
	LDD -6,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD -6,U
	LDD -8,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -8,U
	STA -9,U
	PSHU A,X
	LEAU -71,U

	LDD -8,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -8,U
	LDD -12,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD -12,U
	LDA #$dd
	STA -9,U
	LDB #$dd
	PSHU D,X,Y
	LEAU -6,U

	PSHU A,X
	LEAU -65,U

	STA -7,U
	STA -9,U
	LDD -12,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD -12,U
	STX -14,U
	LDA -15,U
	ANDA #$F0
	ORA #$0d
	STA -15,U
	LDA -17,U
	ANDA #$F0
	ORA #$0c
	STA -17,U
	LDA -25,U
	ANDA #$F0
	ORA #$0b
	STA -25,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -74,U

	STA -7,U
	LDA -9,U
	ANDA #$F0
	ORA #$0d
	STA -9,U
	LDA -25,U
	ANDA #$F0
	ORA #$0b
	STA -25,U
	LDA #$cc
	STA -17,U
	STX -14,U
	LDD -12,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD -12,U
	LDD -82,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -82,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -76,U

	STA -12,U
	LDD #$7777
	STD -9,U
	LDD -7,U
	LDA #$77
	ANDB #$F0
	ORB #$07
	STD -7,U
	LDD -11,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -11,U
	LDD -79,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -79,U
	LDD -81,U
	LDA #$77
	ANDB #$F0
	ORB #$0c
	STD -81,U
	LDA #$cc
	STA -15,U
	LDA #$bb
	STA -23,U
	LDA #$77
	LDX #$7777
	LDY #$7777
	PSHU A,X,Y
	LEAU -76,U

	PSHU X,Y
	LEAU -1,U

	PSHU A,X
	LEAU -2,U

	LDA #$bb
	STA -12,U
	LDD -68,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -68,U
	LDD #$cc77
	PSHU D,X
	LEAU -64,U

	STB -9,U
	LDD -8,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -8,U
	LDD #$7777
	LDY #$777c
	PSHU D,X,Y
	LEAU -6,U

	LDA #$88
	STA -7,U
	LDD -68,U
	LDA #$8c
	ANDB #$0F
	ORB #$c0
	STD -68,U
	LDA -12,U
	ANDA #$0F
	ORA #$b0
	STA -12,U
	LDD #$8888
	LDX #$8777
	LDY #$7777
	PSHU D,X,Y
	LEAU -62,U

	LDA #$77
	STA -10,U
	LDD -9,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -9,U
	LDD #$7777
	LDX #$77aa
	LDY #$aa38
	PSHU D,X,Y
	LEAU -5,U

	LDD #$8887
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LDA -7,U
	ANDA #$0F
	ORA #$b0
	STA -7,U
	LDA #$88
	LDX #$8888
	LDY #$8888
	PSHU A,X,Y
	LEAU -56,U

	LDD #$aaaa
	LDX #$aa38
	LDY #$8889
	PSHU D,X,Y
	LDD -7,U
	ANDA #$F0
	ORA #$08
	LDB #$77
	STD -7,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -4,U

	LDD #$8887
	LDX #$7777
	LDY #$7777
	PSHU D,X,Y
	LDD -8,U
	ANDA #$F0
	ORA #$09
	LDB #$98
	STD -8,U
	LDD #$8888
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -54,U

	LDD #$aa33
	LDX #$3888
	LDY #$8999
	PSHU D,X,Y
	LDD -7,U
	ANDA #$0F
	ORA #$90
	LDB #$77
	STD -7,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -3,U

	LDD #$8777
	LDX #$7777
	LDY #$7788
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LDA #$99
	LDX #$9999
	LDY #$9888
	PSHU A,X,Y
	LEAU -49,U

	LDD #$3338
	LDX #$8888
	LDY #$9999
	PSHU D,X,Y
	LDD -8,U
	LDA #$98
	ANDB #$F0
	ORB #$07
	STD -8,U
	LDD #$33aa
	LDX #$aa33
	LDY #$3333
	PSHU D,X,Y
	LEAU -2,U

	LDD #$8777
	LDX #$7777
	LDY #$7788
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LDD #$9999
	LDX #$9999
	LDY #$9888
	PSHU D,X,Y
	LEAU -48,U

	LDD #$3338
	LDX #$8888
	LDY #$9999
	PSHU D,X,Y
	LDB #$33
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD #$7777
	LDX #$7778
	LDY #$8833
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	LDY #$8777
	PSHU D,X,Y
	LDD #$9999
	STD -8,U
	LDX #$9888
	LDY #$8888
	PSHU D,X,Y
	LEAU -52,U

	LDD #$3333
	LDX #$3333
	PSHU D,X,Y
	LDA #$89
	LDY #$3333
	PSHU D,X,Y
	LDD #$8777
	LDX #$7777
	LDY #$3377
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LDD #$9999
	LDX #$9888
	PSHU D,X
	LEAU -52,U

	LDD #$3333
	LDX #$3333
	PSHU D,X,Y
	LDA #$93
	LDY #$3333
	PSHU D,X,Y
	LDD #$aa77
	LDX #$7333
	LDY #$3388
	PSHU D,X,Y
	LDD #$8888
	LDX #$8888
	LDY #$8888
	PSHU D,X,Y
	LDA #$99
	LDX #$9888
	PSHU A,X
	LEAU -53,U

	LDD #$3333
	LDX #$3333
	PSHU D,X,Y
	LDY #$3333
	PSHU D,X,Y
	LDD #$aaa3
	LDY #$3338
	PSHU D,X,Y
	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDD #$8888
	STD -8,U
	LDX #$8888
	LDY #$88aa
	PSHU D,X,Y
	LEAU -56,U

	LDD #$3333
	LDX #$33a3
	LDY #$8888
	PSHU D,X,Y
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD #$aaa3
	PSHU D,X,Y
	LDA #$88
	STA -7,U
	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDD #$8888
	LDX #$8888
	LDY #$aaaa
	PSHU D,X,Y
	LEAU -56,U

	LDD #$3333
	LDX #$33a3
	LDY #$8888
	PSHU D,X,Y
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD #$aaa3
	PSHU D,X,Y
	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDD #$8888
	LDX #$88aa
	LDY #$aaaa
	PSHU D,X,Y
	LEAU -56,U

	LDD #$3333
	LDX #$33aa
	LDY #$8888
	PSHU D,X,Y
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDA #$aa
	PSHU D,X,Y
	LDA -6,U
	ANDA #$F0
	ORA #$08
	STA -6,U
	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDA #$88
	LDX #$aaaa
	LDY #$aaaa
	PSHU A,X,Y
	LEAU -57,U

	LDA #$33
	LDX #$33aa
	LDY #$8888
	PSHU D,X,Y
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	PSHU D,X,Y
	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDA #$aa
	LDX #$aaaa
	LDY #$aaaa
	PSHU A,X,Y
	LEAU -57,U

	LDA #$33
	LDX #$33aa
	LDY #$8888
	PSHU D,X,Y
	LDA #$88
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDA #$33
	PSHU D,X,Y
	LDA -6,U
	ANDA #$F0
	ORA #$0a
	STA -6,U
	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDA #$aa
	LDX #$aaaa
	LDY #$aa33
	PSHU A,X,Y
	LEAU -57,U

	LDA #$33
	LDX #$33aa
	LDY #$3888
	PSHU D,X,Y
	LDA #$89
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDA #$33
	PSHU D,X,Y
	LDA #$99
	STA -9,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X,Y
	LEAU -56,U

	LDD #$3333
	LDX #$33aa
	LDY #$a388
	PSHU D,X,Y
	LDD #$8983
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD #$3333
	PSHU D,X,Y
	LDA #$aa
	STA -7,U
	LDA #$99
	STA -9,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X,Y
	LEAU -56,U

	LDD #$3333
	LDX #$33aa
	LDY #$aa88
	PSHU D,X,Y
	LDD #$8883
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD #$3333
	PSHU D,X,Y
	LDD #$aaaa
	LDX #$aa33
	PSHU D,X,Y
	LDA #$99
	LDX #$aaaa
	PSHU A,X
	LEAU -53,U

	LDD #$3333
	LDX #$33aa
	LDY #$aaa8
	PSHU D,X,Y
	LDD #$7793
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD #$3333
	PSHU D,X,Y
	LDD #$aaaa
	PSHU D,X,Y
	LDA #$9a
	LDX #$aaaa
	PSHU A,X
	LEAU -53,U

	LDD #$3333
	LDX #$337a
	LDY #$aaaa
	PSHU D,X,Y
	LDA #$89
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDA #$33
	PSHU D,X,Y
	LDD #$aaa3
	PSHU D,X,Y
	LDD -57,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -57,U
	LDX #$aaaa
	PSHU A,X
	LEAU -54,U

	LDD #$3333
	LDX #$3333
	LDY #$7aaa
	PSHU D,X,Y
	LDB #$88
	LDY #$3333
	PSHU D,X,Y
	LDB #$33
	PSHU D,X,Y
	LDD #$aaaa
	PSHU D,X,Y
	LDX #$aaaa
	PSHU A,X
	LEAU -51,U

	PSHU A,X
	LEAU -1,U

	LDD #$3333
	LDX #$3333
	PSHU D,X,Y
	PSHU D,X,Y
	PSHU D,X,Y
	LDD #$aaaa
	STD -8,U
	LDD -59,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -59,U
	STA -60,U
	LDD #$aaaa
	LDX #$aa33
	PSHU D,X,Y
	LEAU -55,U

	LDD #$3333
	LDX #$3333
	LDY #$3338
	PSHU D,X,Y
	LDY #$3333
	PSHU D,X,Y
	PSHU D,X,Y
	LDD -10,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -10,U
	LDD -60,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -60,U
	PSHU X,Y
	LEAU -58,U

	LDD #$3333
	PSHU D,X,Y
	LDY #$8833
	PSHU D,X,Y
	LDY #$3333
	PSHU D,X,Y
	LDA #$aa
	STA -10,U
	STA -59,U
	PSHU B,X,Y
	LEAU -56,U

	LDA #$33
	LDX #$3383
	PSHU D,X,Y
	LDX #$3389
	PSHU D,X,Y
	LDX #$3333
	PSHU D,X,Y
	PSHU D,X,Y
	LEAU -56,U

	LDD -5,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -5,U
	LDA #$99
	PSHU A,X
	LEAU -2,U

	LDD -5,U
	LDA #$33
	ANDB #$F0
	ORB #$09
	STD -5,U
	LDA #$83
	PSHU A,X
	LEAU -2,U

	LDD #$3333
	PSHU D,X,Y
	PSHU D,X,Y
	LDA -7,U
	ANDA #$0F
	ORA #$90
	STA -7,U
	PSHU B,X
	LEAU -55,U

	LDD #$8333
	STD -8,U
	STB -12,U
	LDA #$33
	LDX #$7899
	PSHU D,X,Y
	LEAU -9,U

	LDX #$3333
	PSHU D,X,Y
	LDA #$99
	STA -8,U
	LDA -5,U
	ANDA #$F0
	ORA #$03
	STA -5,U
	PSHU X,Y
	LEAU -54,U

	LDD -10,U
	LDA #$77
	ANDB #$0F
	ORB #$90
	STD -10,U
	LDA #$88
	STA -7,U
	LDA #$33
	STA -13,U
	LDD #$3377
	LDX #$8833
	PSHU D,X,Y
	LEAU -10,U

	LDB #$33
	LDX #$3333
	PSHU D,X,Y
	LDA #$99
	STA -8,U
	PSHU B,X,Y
	LEAU -53,U

	STA -7,U
	STA -30,U
	LDA #$89
	STA -10,U
	LDA #$88
	STA -90,U
	STA -110,U
	STX -27,U
	STB -13,U
	LDA -28,U
	ANDA #$F0
	ORA #$03
	STA -28,U
	STX -82,U
	STX -108,U
	LDD -85,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD -85,U
	LDD -88,U
	ANDA #$F0
	ORA #$07
	LDB #$99
	STD -88,U
	LDA #$77
	LDX #$7833
	PSHU A,X,Y
	LEAU -250,U

	STY 94,U
	LDA 91,U
	ANDA #$0F
	ORA #$80
	STA 91,U
	LDD -65,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -65,U
	LDD -95,U
	LDA #$93
	ANDB #$0F
	ORB #$30
	STD -95,U
	LDA #$88
	STA 65,U
	LDD #$9933
	STD -15,U
	LDD 87,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD 87,U
	LDD 66,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 66,U
	LDD 14,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 14,U
	LDD 7,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD 7,U
	LDA #$99
	STA -72,U
	RTS
