	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_tk_025_0
	LEAU 3971,U

	LDD 3,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 3,U
	STA 2,U
	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -14,U

	LDD -9,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -9,U
	LDD #$9999
	PSHU D,X
	LEAU -54,U

	LDA -4,U
	ANDA #$F0
	ORA #$0b
	STA -4,U
	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -2,U

	LDX #$9999
	PSHU B,X
	LEAU -14,U

	LDA -4,U
	ANDA #$F0
	ORA #$09
	STA -4,U
	LDA -9,U
	ANDA #$F0
	ORA #$0b
	STA -9,U
	LDD -8,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -8,U
	LDA #$99
	PSHU A,X
	LEAU -55,U

	LDA -4,U
	ANDA #$F0
	ORA #$0b
	STA -4,U
	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -2,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -14,U

	PSHU A,X
	LEAU -3,U

	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -49,U

	LDD -7,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -7,U
	STA -8,U
	LDD #$bbbb
	PSHU D,X
	LEAU -18,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -3,U

	LDX #$bbbb
	PSHU B,X
	LEAU -49,U

	LDD -7,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -7,U
	LDD -23,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -23,U
	LDD -29,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -29,U
	STX -31,U
	LDD -25,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -25,U
	STB -8,U
	LDD #$bbbb
	PSHU D,X
	LEAU -76,U

	LDD #$9999
	STD -8,U
	LDD #$bbbb
	PSHU D,X
	LEAU -17,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -3,U

	LDA #$bb
	LDX #$bbbb
	PSHU D,X
	LEAU -49,U

	LDD #$9999
	STD -8,U
	LDA -5,U
	ANDA #$F0
	ORA #$0b
	STA -5,U
	LDD #$bbbb
	PSHU D,X
	LEAU -17,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -3,U

	LDA -5,U
	ANDA #$F0
	ORA #$0b
	STA -5,U
	LDD #$bbbb
	LDX #$bbbb
	PSHU D,X
	LEAU -49,U

	LDA -5,U
	ANDA #$F0
	ORA #$0b
	STA -5,U
	LDA -24,U
	ANDA #$F0
	ORA #$09
	STA -24,U
	LDD #$9999
	STD -8,U
	LDD -28,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -28,U
	LDD #$9999
	STD -23,U
	LDD #$bbbb
	PSHU D,X
	LEAU -24,U

	PSHU D,X
	LEAU -48,U

	LDD -8,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -8,U
	LDD #$9999
	STD -23,U
	LDA #$bb
	LDY #$bbbb
	PSHU A,X,Y
	LEAU -21,U

	LDB #$bb
	PSHU D,X,Y
	LEAU -48,U

	LDD -8,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -8,U
	LDD -22,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -22,U
	STA -23,U
	LDA #$bb
	PSHU A,X,Y
	LEAU -21,U

	LDD #$bbbb
	PSHU D,X,Y
	LEAU -48,U

	LDA -5,U
	ANDA #$F0
	ORA #$0b
	STA -5,U
	LDA -23,U
	ANDA #$F0
	ORA #$09
	STA -23,U
	LDD -22,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -22,U
	LDD -27,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -27,U
	LDA #$99
	STA -8,U
	PSHU X,Y
	LEAU -23,U

	LDA #$bb
	PSHU A,X,Y
	LEAU -48,U

	LDD -9,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -9,U
	LDD #$9999
	STD -22,U
	PSHU X,Y
	LEAU -21,U

	LDA #$bb
	STA -7,U
	LDB #$bb
	PSHU D,X,Y
	LEAU -49,U

	LDD #$9999
	STD -22,U
	LDD -9,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -9,U
	PSHU X,Y
	LEAU -21,U

	LDA #$bb
	STA -7,U
	LDB #$bb
	PSHU D,X,Y
	LEAU -49,U

	LDD -9,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -9,U
	STB -21,U
	LDD -27,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -27,U
	PSHU X,Y
	LEAU -23,U

	PSHU A,X,Y
	LEAU -48,U

	LDA -4,U
	ANDA #$F0
	ORA #$0b
	STA -4,U
	LDD -21,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -21,U
	LDD -9,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -9,U
	LDA #$bb
	PSHU A,X
	LEAU -23,U

	LDB #$bb
	PSHU D,X,Y
	LEAU -48,U

	LDD -9,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -9,U
	LDD -21,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -21,U
	LDA #$bb
	PSHU A,X
	LEAU -23,U

	LDB #$bb
	PSHU D,X,Y
	LEAU -48,U

	LDA #$99
	STA -20,U
	LDD -9,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -9,U
	LDD -28,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -28,U
	PSHU A,X
	LEAU -25,U

	PSHU X,Y
	LEAU -48,U

	LDA #$99
	STA -20,U
	LDA #$bb
	PSHU A,X
	LEAU -24,U

	LDA -56,U
	ANDA #$F0
	ORA #$0b
	STA -56,U
	LDA -72,U
	ANDA #$0F
	ORA #$90
	STA -72,U
	STX -55,U
	LDA #$bb
	PSHU A,X,Y
	LEAU -75,U

	LDA #$99
	STA -72,U
	STX -55,U
	LDA #$bb
	PSHU A,X,Y
	LEAU -75,U

	STX -55,U
	PSHU A,X,Y
	LEAU -75,U

	STX -55,U
	LDD -82,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -82,U
	PSHU A,X,Y
	LEAU -77,U

	LDD -53,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -53,U
	PSHU B,X
	LEAU -76,U

	STB -53,U
	PSHU X,Y
	LEAU -76,U

	STB -53,U
	PSHU X,Y
	LEAU -76,U

	STB -53,U
	PSHU X,Y
	LEAU -76,U

	STB -53,U
	PSHU X,Y
	LEAU -76,U

	LDA -53,U
	ANDA #$F0
	ORA #$0b
	STA -53,U
	LDD -82,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -82,U
	STX -84,U
	PSHU X,Y
	LEAU -237,U

	LDA 108,U
	ANDA #$F0
	ORA #$0b
	STA 108,U
	LDD 79,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 79,U
	STX 77,U
	PSHU A,X
	LEAU -77,U

	LDA -59,U
	ANDA #$F0
	ORA #$08
	STA -59,U
	LDA #$bb
	PSHU A,X
	LEAU -77,U

	PSHU A,X
	LEAU -77,U

	LDA -58,U
	ANDA #$0F
	ORA #$70
	STA -58,U
	LDA -62,U
	ANDA #$F0
	ORA #$0d
	STA -62,U
	LDA #$bb
	PSHU A,X
	LEAU -77,U

	LDA #$77
	STA -58,U
	LDA #$dd
	STA -61,U
	LDA #$bb
	PSHU A,X
	LEAU -77,U

	LDD -58,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0770
	STD -58,U
	LDD #$dddd
	STD -61,U
	LDA #$bb
	PSHU A,X
	LEAU -77,U

	LDA -64,U
	ANDA #$F0
	ORA #$07
	STA -64,U
	LDD -60,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -60,U
	LDD -82,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -82,U
	LDA #$dd
	STA -61,U
	LDD -58,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD -58,U
	LDA #$bb
	STA -83,U
	PSHU A,X
	LEAU -147,U

	STB 13,U
	STB 7,U
	LDD -12,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -12,U
	LDA 9,U
	ANDA #$F0
	ORA #$0d
	STA 9,U
	LDD #$dddd
	STD 10,U
	LDA #$bb
	STA -13,U
	LEAU -146,U

	LDD 78,U
	ANDA #$0F
	ORA #$d0
	LDB #$77
	STD 78,U
	LDD #$dddd
	STD 76,U
	LDD 74,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD 74,U
	LDA 73,U
	ANDA #$F0
	ORA #$07
	STA 73,U
	STX 53,U
	STX -27,U
	LDD #$7777
	LDX #$dddd
	LDY #$dd77
	PSHU D,X,Y
	LEAU -74,U

	STD -6,U
	LDD #$bbbb
	STD -27,U
	STD -107,U
	LDD -85,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -85,U
	LDD -83,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -83,U
	LDD -81,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0770
	STD -81,U
	LDA #$77
	STA -86,U
	LDA #$dd
	PSHU A,Y
	LEAU -279,U

	LDD 121,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d070
	STD 121,U
	LDA #$dd
	STA 120,U
	STA 40,U
	LDD 117,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD 117,U
	LDA 116,U
	ANDA #$F0
	ORA #$07
	STA 116,U
	LDA -40,U
	ANDA #$F0
	ORA #$0d
	STA -40,U
	LDD #$bbbb
	STD 95,U
	STD 15,U
	STD -65,U
	LDD 41,U
	ANDA #$0F
	ORA #$d0
	LDB #$77
	STD 41,U
	LDD #$7777
	STD 37,U
	LDD #$d7a7
	STD -39,U
	LDD #$7a77
	STD -43,U
	LDD #$dda7
	STD -119,U
	LDA #$77
	STD -123,U
	LEAU -144,U

	LDD #$bbbb
	STD -1,U
	LEAU -135,U

	LDD 81,U
	ANDA #$0F
	ORA #$a0
	LDB #$dd
	STD 81,U
	LDD 76,U
	ANDA #$F0
	ORA #$07
	LDB #$a7
	STD 76,U
	LDD -79,U
	ANDA #$F0
	ORA #$0a
	LDB #$dd
	STD -79,U
	LDD #$aa77
	STD -83,U
	LDD #$bbbb
	STD 54,U
	STD -26,U
	STD -106,U
	LDD #$aadd
	STD 1,U
	LDA -4,U
	ANDA #$F0
	ORA #$07
	STA -4,U
	LDD 79,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD 79,U
	LDD -81,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -81,U
	LDA #$aa
	LDX #$7777
	PSHU A,X
	LEAU -169,U

	LDD 13,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$70d0
	STD 13,U
	LDD -14,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -14,U
	LDD #$7a77
	STD 9,U
	LDA 12,U
	ANDA #$F0
	ORA #$07
	STA 12,U
	LEAU -149,U

	LDA 81,U
	ANDA #$F0
	ORA #$0d
	STA 81,U
	LDA 77,U
	ANDA #$F0
	ORA #$07
	STA 77,U
	LDA -77,U
	ANDA #$F0
	ORA #$07
	STA -77,U
	STX 78,U
	LDD 55,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 55,U
	LDD -25,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -25,U
	LDD -105,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -105,U
	LDD -82,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD -82,U
	LDA #$dd
	STA 1,U
	STA -79,U
	STB -83,U
	PSHU B,X
	LEAU -249,U

	LDA 13,U
	ANDA #$0F
	ORA #$d0
	STA 13,U
	LDD 90,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD 90,U
	LDD 10,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD 10,U
	STB 89,U
	STB 9,U
	LDD 93,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD 93,U
	LDD 67,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 67,U
	LDD 14,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD 14,U
	LDD -69,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD -69,U
	LDA #$bb
	STA -13,U
	STA -93,U
	LDD #$77dd
	STD -66,U
	LDD -72,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0770
	STD -72,U
	LEAU -232,U

	LDD #$77dd
	STD 86,U
	STD 3,U
	LDA 6,U
	ANDA #$F0
	ORA #$07
	STA 6,U
	LDA -74,U
	ANDA #$F0
	ORA #$07
	STA -74,U
	LDD #$dddd
	STD 77,U
	LDA #$bb
	STA 59,U
	STA -21,U
	LDD 83,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD 83,U
	LDD 79,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 79,U
	LDD 7,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD 7,U
	LDD ,U
	ANDA #$0F
	ORA #$d0
	LDB #$dd
	STD ,U
	LDD -73,U
	ANDA #$F0
	ORA #$0d
	LDB #$77
	STD -73,U
	LDD #$dddd
	LDX #$dddd
	PSHU D,X
	LEAU -71,U

	LDX #$77dd
	PSHU D,X
	LEAU -1,U

	LDA -74,U
	ANDA #$F0
	ORA #$07
	STA -74,U
	LDD -73,U
	LDA #$7d
	ANDB #$F0
	ORB #$07
	STD -73,U
	LDD -77,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD -77,U
	LDA #$bb
	STA -21,U
	STA -101,U
	LDD #$dddd
	STD -79,U
	STD -82,U
	LDX #$dddd
	PSHU A,X
	LEAU -234,U

	LDA #$bb
	STA 56,U
	STA -24,U
	LDA 83,U
	ANDA #$F0
	ORA #$07
	STA 83,U
	LDA 3,U
	ANDA #$F0
	ORA #$07
	STA 3,U
	LDA -77,U
	ANDA #$F0
	ORA #$07
	STA -77,U
	LDD 80,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070d
	STD 80,U
	LDD 4,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$70d0
	STD 4,U
	LDD ,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$d00d
	STD ,U
	STX 78,U
	STX 75,U
	LDD 84,U
	LDA #$7d
	ANDB #$0F
	ORB #$d0
	STD 84,U
	LDD -81,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -81,U
	LDD -76,U
	ANDA #$0F
	ORA #$70
	LDB #$dd
	STD -76,U
	LDD #$dd77
	PSHU D,X
	LEAU -77,U

	LDA -5,U
	ANDA #$F0
	ORA #$07
	STA -5,U
	LDA #$bb
	STA -23,U
	STA -103,U
	LDD #$77dd
	STD -82,U
	LDD -80,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -80,U
	LDD -84,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD -84,U
	LDD -75,U
	ANDA #$0F
	ORA #$70
	LDB #$dd
	STD -75,U
	LDD #$7777
	STD -86,U
	LDA #$dd
	LDX #$77dd
	PSHU A,X
	LEAU -155,U

	LDA #$bb
	STA -25,U
	LDA -7,U
	ANDA #$F0
	ORA #$07
	STA -7,U
	LDA -9,U
	ANDA #$0F
	ORA #$70
	STA -9,U
	STX 3,U
	STX -77,U
	LDD #$7777
	LDY #$dddd
	PSHU D,X,Y
	LEAU -74,U

	LDA #$79
	STA -10,U
	STB -77,U
	LDA #$bb
	STA -25,U
	LDA #$a7
	PSHU D,X,Y
	LEAU -74,U

	LDA #$aa
	STA -7,U
	LDA #$bb
	STA -25,U
	LDD -11,U
	ANDA #$F0
	ORA #$08
	LDB #$89
	STD -11,U
	LDD #$7799
	STD -77,U
	LDD -81,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -81,U
	LDD #$a777
	PSHU D,X,Y
	LEAU -75,U

	LDA #$bb
	STA -24,U
	LDA #$aa
	STA -7,U
	STB -9,U
	LDD -6,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -6,U
	LDD -76,U
	LDA #$77
	ANDB #$F0
	ORB #$09
	STD -76,U
	LDD -80,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -80,U
	LDD #$7777
	PSHU D,Y
	LEAU -76,U

	LDD #$39aa
	STD -9,U
	LDA #$bb
	STA -24,U
	LDD -76,U
	LDA #$77
	ANDB #$F0
	ORB #$09
	STD -76,U
	LDD -79,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$70d0
	STD -79,U
	LDD #$7777
	PSHU D,Y
	LEAU -75,U

	LDD -80,U
	ANDA #$0F
	ORA #$70
	LDB #$dd
	STD -80,U
	LDD -77,U
	LDA #$77
	ANDB #$F0
	ORB #$07
	STD -77,U
	LDA -10,U
	ANDA #$0F
	ORA #$30
	STA -10,U
	LDA #$77
	PSHU A,X,Y
	LEAU -75,U

	STA -77,U
	LDA #$88
	PSHU A,X,Y
	LEAU -73,U

	LDA #$77
	STA -79,U
	LDA -77,U
	ANDA #$0F
	ORA #$80
	STA -77,U
	LDA #$89
	STA -7,U
	LDD #$87dd
	LDX #$dddd
	LDY #$77dd
	PSHU D,X,Y
	LEAU -74,U

	LDA #$78
	STA -7,U
	LDA #$77
	STA -79,U
	LDA -77,U
	ANDA #$0F
	ORA #$80
	STA -77,U
	LDD #$97dd
	PSHU D,X,Y
	LEAU -74,U

	LDA #$aa
	STA -18,U
	LDA #$77
	STA -7,U
	STA -79,U
	LDA #$d8
	STA -77,U
	LDD #$877d
	PSHU D,X,Y
	LEAU -74,U

	LDD -7,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -7,U
	LDD -78,U
	LDA #$aa
	ANDB #$0F
	ORB #$d0
	STD -78,U
	LDA #$77
	STA -79,U
	LDD #$aaaa
	STD -19,U
	LDA #$7d
	LDY #$d7dd
	PSHU A,X,Y
	LEAU -75,U

	LDA #$88
	STA -7,U
	LDD -78,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -78,U
	LDD #$aaaa
	STD -19,U
	LDD -80,U
	ANDA #$0F
	ORA #$d0
	LDB #$77
	STD -80,U
	LDY #$d77d
	PSHU B,X,Y
	LEAU -75,U

	PSHU B,X,Y
	LEAU -12,U

	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -56,U

	LDD -5,U
	LDA #$7d
	ANDB #$0F
	ORB #$d0
	STD -5,U
	LDA #$77
	PSHU A,X
	LEAU -2,U

	LDD #$77dd
	LDX #$ddd7
	PSHU D,X
	LEAU -12,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDD -60,U
	LDA #$aa
	ANDB #$F0
	ORB #$08
	STD -60,U
	LDX #$aaaa
	PSHU A,X
	LEAU -57,U

	LDD #$77dd
	STD -8,U
	LDD #$ddd7
	LDX #$7ddd
	LDY #$77aa
	PSHU D,X,Y
	LEAU -14,U

	LDD #$aaaa
	LDX #$aaa3
	PSHU D,X
	LEAU -54,U

	LDD -8,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -8,U
	LDD #$78dd
	STD -10,U
	LDA #$7d
	LDX #$77aa
	LDY #$aa38
	PSHU D,X,Y
	LEAU -17,U

	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -53,U

	LDD #$7ddd
	LDX #$77aa
	LDY #$aaa3
	PSHU D,X,Y
	LDA -4,U
	ANDA #$F0
	ORA #$07
	STA -4,U
	LDD -19,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -19,U
	LDD #$aaaa
	STD -21,U
	STD -76,U
	LDD -78,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070a
	STD -78,U
	LDA #$dd
	LDX #$dddd
	PSHU A,X
	LEAU -75,U

	LDD -7,U
	LDA #$88
	ANDB #$F0
	ORB #$07
	STD -7,U
	LDA #$dd
	LDY #$77dd
	PSHU A,X,Y
	LEAU -15,U

	LDD #$aaaa
	STD -58,U
	LDD -60,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070a
	STD -60,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -56,U

	LDD -8,U
	ANDA #$F0
	ORA #$07
	LDB #$99
	STD -8,U
	LDA #$7d
	LDX #$dddd
	PSHU A,X,Y
	LEAU -15,U

	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -52,U

	LDD -5,U
	LDA #$dd
	ANDB #$F0
	ORB #$07
	STD -5,U
	LDA #$88
	PSHU A,X
	LEAU -2,U

	LDD -7,U
	ANDA #$F0
	ORA #$07
	LDB #$89
	STD -7,U
	LDD #$7ddd
	LDX #$dd77
	PSHU D,X
	LEAU -16,U

	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -51,U

	LDD #$7ddd
	STD -9,U
	LDD -5,U
	LDA #$dd
	ANDB #$F0
	ORB #$07
	STD -5,U
	LDD -7,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -7,U
	LDD -12,U
	ANDA #$F0
	ORA #$07
	LDB #$79
	STD -12,U
	LDA #$89
	PSHU A,X
	LEAU -22,U

	LDA -5,U
	ANDA #$F0
	ORA #$0a
	STA -5,U
	LDD #$aaaa
	PSHU D,X
	LEAU -51,U

	LDD -5,U
	LDA #$dd
	ANDB #$F0
	ORB #$07
	STD -5,U
	LDD -7,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -7,U
	LDD #$a7dd
	STD -9,U
	LDD -12,U
	ANDA #$F0
	ORA #$07
	LDB #$98
	STD -12,U
	LDA #$78
	PSHU A,X
	LEAU -23,U

	LDD #$aaaa
	PSHU D,X
	LEAU -50,U

	LDD -7,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -7,U
	LDD #$a7dd
	STD -9,U
	LDA #$98
	STA -11,U
	LDX #$d777
	LDY #$8aaa
	PSHU B,X,Y
	LEAU -21,U

	LDD -60,U
	ANDA #$0F
	ORA #$70
	LDB #$dd
	STD -60,U
	LDD -58,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d080
	STD -58,U
	STY -56,U
	LDA #$aa
	LDX #$aaaa
	LDY #$aaaa
	PSHU A,X,Y
	LEAU -55,U

	LDA #$77
	LDX #$dddd
	PSHU A,X
	LEAU -18,U

	LDD #$aaaa
	PSHU D,Y
	LEAU -49,U

	LDD -5,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -5,U
	LDA #$88
	LDX #$7aaa
	PSHU A,X
	LEAU -2,U

	LDD #$77dd
	LDX #$dd77
	PSHU D,X
	LEAU -18,U

	LDA -5,U
	ANDA #$F0
	ORA #$0a
	STA -5,U
	LDD #$aaaa
	PSHU D,Y
	LEAU -49,U

	LDD -5,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -5,U
	LDX #$7aaa
	PSHU A,X
	LEAU -2,U

	LDD -24,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -24,U
	LDD #$88dd
	LDX #$dd77
	PSHU D,X
	LEAU -20,U

	LDA #$aa
	PSHU A,Y
	LEAU -48,U

	LDA #$77
	LDX #$dddd
	LDY #$7aaa
	PSHU D,X,Y
	LDA -4,U
	ANDA #$F0
	ORA #$07
	STA -4,U
	LDA #$99
	PSHU A,X
	LEAU -19,U

	LDD #$7a3a
	STD -54,U
	LDD -56,U
	LDA #$88
	ANDB #$0F
	ORB #$d0
	STD -56,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -52,U

	LDA -6,U
	ANDA #$F0
	ORA #$07
	STA -6,U
	LDA #$89
	LDX #$dddd
	LDY #$77dd
	PSHU A,X,Y
	LEAU -19,U

	LDD #$7a33
	STD -54,U
	LDD -56,U
	LDA #$99
	ANDB #$0F
	ORB #$70
	STD -56,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -52,U

	LDA -6,U
	ANDA #$F0
	ORA #$07
	STA -6,U
	LDA #$79
	LDX #$dddd
	LDY #$77d7
	PSHU A,X,Y
	LEAU -20,U

	LDD -55,U
	LDA #$89
	ANDB #$0F
	ORB #$70
	STD -55,U
	LDD #$7733
	STD -53,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -52,U

	LDA -6,U
	ANDA #$F0
	ORA #$07
	STA -6,U
	LDA #$98
	LDX #$dd88
	PSHU A,X,Y
	LEAU -20,U

	LDD -55,U
	LDA #$79
	ANDB #$0F
	ORB #$70
	STD -55,U
	LDD #$7733
	STD -53,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -52,U

	LDA #$77
	STD -78,U
	STX -28,U
	LDD -80,U
	LDA #$98
	ANDB #$0F
	ORB #$70
	STD -80,U
	LDX #$dd89
	LDY #$87d7
	PSHU A,X,Y
	LEAU -75,U

	LDD #$aaaa
	STD -28,U
	LDD #$7733
	STD -78,U
	LDD -80,U
	LDA #$98
	ANDB #$0F
	ORB #$70
	STD -80,U
	LDD #$dd78
	LDX #$97d7
	PSHU D,X
	LEAU -76,U

	LDD -28,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -28,U
	LDD -80,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -80,U
	LDD #$7733
	STD -78,U
	LDD #$dd77
	LDX #$87dd
	PSHU D,X
	LEAU -76,U

	LDD -80,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -80,U
	LDD #$7833
	STD -78,U
	LDA #$aa
	STA -28,U
	LDD #$7d88
	PSHU D,X
	LEAU -76,U

	LDA #$aa
	STA -28,U
	LDD -80,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -80,U
	LDD #$7a33
	STD -78,U
	LDD #$ad88
	LDX #$d7dd
	PSHU D,X
	LEAU -76,U

	LDA #$a3
	STA -28,U
	LDD #$addd
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 3975,U

	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -1,U

	LDA -4,U
	ANDA #$F0
	ORA #$09
	STA -4,U
	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -15,U

	LDD #$bbbb
	STD -8,U
	LDA #$99
	PSHU A,X
	LEAU -55,U

	LDD -6,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -6,U
	LDD -23,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -23,U
	LDD -81,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -81,U
	LDD -8,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -8,U
	STX -25,U
	STX -87,U
	LDD #$bbbb
	STD -30,U
	STD -83,U
	LDA -88,U
	ANDA #$F0
	ORA #$09
	STA -88,U
	LDX #$bbbb
	PSHU B,X
	LEAU -98,U

	LDD -8,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -8,U
	STA -9,U
	LDD #$9999
	LDX #$9999
	PSHU D,X
	LEAU -54,U

	STD -8,U
	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDD #$bbbb
	LDX #$bbbb
	PSHU D,X
	LEAU -18,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -3,U

	LDA -4,U
	ANDA #$F0
	ORA #$0b
	STA -4,U
	LDX #$bbbb
	PSHU B,X
	LEAU -49,U

	LDA -5,U
	ANDA #$F0
	ORA #$0b
	STA -5,U
	LDD #$bbbb
	PSHU D,X
	LEAU -2,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -13,U

	PSHU A,X
	LEAU -3,U

	LDA #$bb
	LDX #$bbbb
	PSHU D,X
	LEAU -48,U

	LDY #$bbbb
	PSHU A,X,Y
	LEAU -1,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -13,U

	PSHU A,X
	LEAU -3,U

	LDA #$bb
	PSHU D,Y
	LEAU -48,U

	LDD -8,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -8,U
	STA -9,U
	STX -24,U
	LDA -25,U
	ANDA #$F0
	ORA #$09
	STA -25,U
	LDA #$bb
	LDX #$bbbb
	PSHU A,X,Y
	LEAU -22,U

	PSHU A,X,Y
	LEAU -48,U

	LDD #$9999
	STD -9,U
	STA -24,U
	LDD -23,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -23,U
	LDA #$bb
	PSHU A,X,Y
	LEAU -22,U

	PSHU A,X,Y
	LEAU -48,U

	LDD #$9999
	STD -9,U
	LDA #$bb
	PSHU A,X,Y
	LEAU -16,U

	LDX #$9999
	PSHU B,X
	LEAU -3,U

	LDX #$bbbb
	PSHU A,X,Y
	LEAU -48,U

	LDA -6,U
	ANDA #$F0
	ORA #$0b
	STA -6,U
	LDD #$9999
	STD -9,U
	STD -23,U
	LDA #$bb
	PSHU A,X,Y
	LEAU -21,U

	LDB #$bb
	PSHU D,X,Y
	LEAU -48,U

	LDA -6,U
	ANDA #$0F
	ORA #$b0
	STA -6,U
	LDD #$9999
	STD -9,U
	STD -23,U
	LDA #$bb
	PSHU A,X,Y
	LEAU -21,U

	LDB #$bb
	PSHU D,X,Y
	LEAU -48,U

	LDD -9,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -9,U
	LDD -27,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -27,U
	LDD -23,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -23,U
	LDA #$bb
	PSHU A,X,Y
	LEAU -22,U

	PSHU A,X,Y
	LEAU -48,U

	LDD -9,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -9,U
	LDD -22,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -22,U
	LDA -5,U
	ANDA #$F0
	ORA #$0b
	STA -5,U
	PSHU X,Y
	LEAU -22,U

	LDD #$bbbb
	PSHU D,X,Y
	LEAU -48,U

	LDA #$99
	STA -9,U
	LDB #$99
	STD -22,U
	PSHU X,Y
	LEAU -22,U

	LDD #$bbbb
	PSHU D,X,Y
	LEAU -48,U

	LDD -28,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -28,U
	LDA #$99
	STA -9,U
	STA -21,U
	PSHU X,Y
	LEAU -24,U

	PSHU X,Y
	LEAU -48,U

	STA -9,U
	STA -21,U
	PSHU X,Y
	LEAU -23,U

	LDA #$bb
	PSHU A,X,Y
	LEAU -48,U

	LDD -21,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -21,U
	LDA #$99
	STA -9,U
	LDA -4,U
	ANDA #$F0
	ORA #$0b
	STA -4,U
	LDA #$bb
	PSHU A,X
	LEAU -24,U

	PSHU A,X,Y
	LEAU -48,U

	LDA #$99
	STA -9,U
	STA -20,U
	LDA #$bb
	PSHU A,X
	LEAU -24,U

	PSHU A,X,Y
	LEAU -48,U

	LDD -29,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -29,U
	LDA #$99
	STA -9,U
	STA -20,U
	LDA #$bb
	PSHU A,X
	LEAU -26,U

	PSHU A,X
	LEAU -48,U

	LDD -29,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -29,U
	LDA -9,U
	ANDA #$0F
	ORA #$90
	STA -9,U
	LDA #$bb
	PSHU A,X
	LEAU -26,U

	STX -53,U
	LDA -54,U
	ANDA #$F0
	ORA #$0b
	STA -54,U
	LDA -60,U
	ANDA #$0F
	ORA #$90
	STA -60,U
	LDA -70,U
	ANDA #$0F
	ORA #$90
	STA -70,U
	LDA #$bb
	PSHU A,X
	LEAU -76,U

	STX -54,U
	PSHU X,Y
	LEAU -76,U

	STX -54,U
	PSHU X,Y
	LEAU -76,U

	STX -54,U
	PSHU X,Y
	LEAU -76,U

	STX -54,U
	STX -84,U
	LDD -82,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -82,U
	PSHU X,Y
	LEAU -157,U

	LDD 27,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD 27,U
	STB -52,U
	PSHU B,X
	LEAU -77,U

	STB -52,U
	PSHU B,X
	LEAU -77,U

	STB -52,U
	PSHU B,X
	LEAU -77,U

	STB -52,U
	PSHU B,X
	LEAU -77,U

	STB -52,U
	PSHU B,X
	LEAU -77,U

	STB -83,U
	LDD -82,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -82,U
	LDA -52,U
	ANDA #$F0
	ORA #$0b
	STA -52,U
	LDA #$bb
	PSHU A,X
	LEAU -254,U

	LDA 125,U
	ANDA #$F0
	ORA #$0b
	STA 125,U
	LDA 118,U
	ANDA #$0F
	ORA #$70
	STA 118,U
	LDA 114,U
	ANDA #$F0
	ORA #$0d
	STA 114,U
	LDA 38,U
	ANDA #$F0
	ORA #$07
	STA 38,U
	LDA 35,U
	ANDA #$0F
	ORA #$d0
	STA 35,U
	LDD 95,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 95,U
	STA 94,U
	STX 14,U
	STX -66,U
	LDA #$77
	STA -41,U
	STA -121,U
	LDD -125,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -125,U
	STB -45,U
	LEAU -185,U

	STX 39,U
	STX -41,U
	LDA -22,U
	ANDA #$0F
	ORA #$70
	STA -22,U
	LDD #$dddd
	STD -19,U
	LDA #$77
	STA -16,U
	LEAU -174,U

	LDD 78,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD 78,U
	LDD 76,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 76,U
	STA 75,U
	LDD 72,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0770
	STD 72,U
	LDA #$77
	STA -7,U
	STX 53,U
	STX -27,U
	LDD #$77dd
	LDX #$dddd
	LDY #$7777
	PSHU D,X,Y
	LEAU -74,U

	LDD -6,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -6,U
	STA -7,U
	LDD #$bbbb
	STD -27,U
	STD -107,U
	LDA -87,U
	ANDA #$F0
	ORA #$07
	STA -87,U
	STY -86,U
	LDD -82,U
	ANDA #$0F
	ORA #$d0
	LDB #$77
	STD -82,U
	LDD -84,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -84,U
	LDY #$d777
	PSHU X,Y
	LEAU -156,U

	LDD #$ddaa
	STD -82,U
	LDD -27,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -27,U
	LDD -107,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -107,U
	LDD #$7777
	STD -6,U
	STD -86,U
	LDA -83,U
	ANDA #$F0
	ORA #$0d
	STA -83,U
	LDA #$dd
	LDX #$dd77
	PSHU A,X
	LEAU -251,U

	LDB #$aa
	STD 92,U
	LDB #$7a
	STD -68,U
	LDD 67,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 67,U
	LDD 12,U
	LDA #$dd
	ANDB #$F0
	ORB #$0a
	STD 12,U
	LDD -13,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -13,U
	LDD -71,U
	LDA #$aa
	ANDB #$0F
	ORB #$70
	STD -71,U
	LDD 8,U
	ANDA #$F0
	ORA #$07
	LDB #$aa
	STD 8,U
	LDD #$77aa
	STD 88,U
	LDA #$bb
	STA -93,U
	LEAU -227,U

	LDD 80,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD 80,U
	LDD 78,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD 78,U
	LDD 76,U
	LDA #$aa
	ANDB #$0F
	ORB #$70
	STD 76,U
	LDD ,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD ,U
	LDD -81,U
	LDA #$77
	ANDB #$F0
	ORB #$07
	STD -81,U
	LDA #$bb
	STA 54,U
	STA -26,U
	LDD -79,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0dd0
	STD -79,U
	LDD #$7a77
	LDX #$7777
	PSHU D,X
	LEAU -77,U

	LDA #$bb
	STA -25,U
	STA -105,U
	LDD -82,U
	LDA #$a7
	ANDB #$0F
	ORB #$70
	STD -82,U
	LDA -78,U
	ANDA #$F0
	ORA #$0d
	STA -78,U
	LDA #$77
	STA -83,U
	PSHU A,X
	LEAU -279,U

	LDA 123,U
	ANDA #$0F
	ORA #$d0
	STA 123,U
	LDA -42,U
	ANDA #$F0
	ORA #$07
	STA -42,U
	LDD #$77a7
	STD 119,U
	STD 39,U
	LDA #$bb
	STA 97,U
	STA 17,U
	STA -63,U
	LDA #$dd
	STA 43,U
	LDD #$777a
	STD -41,U
	LDD -38,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0dd0
	STD -38,U
	LDA #$a7
	STA -116,U
	LDD -119,U
	ANDA #$0F
	ORA #$70
	LDB #$dd
	STD -119,U
	LDD -121,U
	ANDA #$0F
	ORA #$70
	LDB #$7a
	STD -121,U
	LDA #$77
	STA -122,U
	LEAU -183,U

	LDA #$bb
	STA 40,U
	STA -40,U
	LDA -12,U
	ANDA #$0F
	ORA #$70
	STA -12,U
	LDD -16,U
	ANDA #$0F
	ORA #$70
	LDB #$dd
	STD -16,U
	LDA #$77
	STA -17,U
	STA -19,U
	LEAU -174,U

	LDA #$bb
	STA 54,U
	LDD 78,U
	ANDA #$0F
	ORA #$70
	LDB #$dd
	STD 78,U
	LDD 1,U
	ANDA #$0F
	ORA #$70
	LDB #$d7
	STD 1,U
	LDA #$77
	STA 77,U
	STA 75,U
	LDA 82,U
	ANDA #$F0
	ORA #$07
	STA 82,U
	LDA #$77
	LDX #$77dd
	PSHU A,X
	LEAU -2,U

	LDD -74,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$70d0
	STD -74,U
	LDD -79,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$d007
	STD -79,U
	LDA #$bb
	STA -21,U
	LDD -77,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -77,U
	LDD #$dddd
	LDX #$dddd
	PSHU D,X
	LEAU -76,U

	LDA #$bb
	STA -21,U
	STA -101,U
	LDA #$77
	STD -74,U
	LDD -77,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -77,U
	LDD -79,U
	LDA #$dd
	ANDB #$F0
	ORB #$07
	STD -79,U
	LDD -81,U
	LDA #$dd
	ANDB #$F0
	ORB #$0d
	STD -81,U
	STX -83,U
	LDA -84,U
	ANDA #$F0
	ORA #$0d
	STA -84,U
	LDA #$dd
	LDY #$dddd
	PSHU A,X,Y
	LEAU -151,U

	STX -7,U
	LDD -5,U
	LDA #$dd
	ANDB #$F0
	ORB #$0d
	STD -5,U
	LDD #$77dd
	STD 2,U
	STD -78,U
	LDA #$bb
	STA -25,U
	LDX #$dd77
	PSHU B,X
	LEAU -77,U

	STA -25,U
	LDA #$77
	STD -78,U
	LDA #$dd
	LDX #$dddd
	LDY #$dd77
	PSHU D,X,Y
	LEAU -74,U

	LDA #$bb
	STA -25,U
	LDA #$77
	STD -78,U
	LDD #$ddd7
	PSHU D,X,Y
	LEAU -75,U

	LDA #$77
	STA -6,U
	LDD -77,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD -77,U
	LDA #$bb
	STA -24,U
	LDD #$d7dd
	PSHU D,X
	LEAU -76,U

	LDD -6,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -6,U
	STA -7,U
	STA -77,U
	LDA #$bb
	STA -24,U
	LDD -76,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0dd0
	STD -76,U
	LDD #$d7dd
	PSHU D,X
	LEAU -76,U

	LDA #$bb
	STA -24,U
	STB -75,U
	LDA #$77
	STA -77,U
	LDB #$77
	LDX #$d7dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -74,U

	LDA -6,U
	ANDA #$F0
	ORA #$0a
	STA -6,U
	LDA -9,U
	ANDA #$0F
	ORA #$90
	STA -9,U
	LDA -75,U
	ANDA #$F0
	ORA #$0d
	STA -75,U
	STB -77,U
	LDA #$bb
	STA -24,U
	LDX #$77dd
	PSHU B,X,Y
	LEAU -74,U

	LDD -8,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -8,U
	LDD #$7789
	STD -11,U
	LDA #$bb
	STA -25,U
	LDD -78,U
	LDA #$77
	ANDB #$F0
	ORB #$09
	STD -78,U
	LDD -81,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -81,U
	LDD #$7777
	LDX #$dddd
	LDY #$dd77
	PSHU D,X,Y
	LEAU -75,U

	LDA #$bb
	STA -24,U
	LDD #$3378
	STD -10,U
	LDD -8,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -8,U
	LDD -76,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$900a
	STD -76,U
	LDA -77,U
	ANDA #$F0
	ORA #$07
	STA -77,U
	LDD -80,U
	LDA #$d7
	ANDB #$F0
	ORB #$0d
	STD -80,U
	LDD #$aa77
	LDX #$77dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -74,U

	LDD -10,U
	LDA #$33
	ANDB #$0F
	ORB #$90
	STD -10,U
	LDD -80,U
	LDA #$d7
	ANDB #$F0
	ORB #$0d
	STD -80,U
	LDA -5,U
	ANDA #$F0
	ORA #$07
	STA -5,U
	LDA -77,U
	ANDA #$F0
	ORA #$07
	STA -77,U
	LDA #$aa
	STA -75,U
	PSHU X,Y
	LEAU -76,U

	LDA #$da
	STA -75,U
	LDA #$33
	STA -10,U
	LDA -77,U
	ANDA #$F0
	ORA #$07
	STA -77,U
	LDD -80,U
	LDA #$d7
	ANDB #$F0
	ORB #$0d
	STD -80,U
	PSHU X,Y
	LEAU -76,U

	LDA #$dd
	STA -75,U
	LDA -77,U
	ANDA #$F0
	ORA #$07
	STA -77,U
	LDD #$887d
	PSHU D,Y
	LEAU -75,U

	LDA -6,U
	ANDA #$F0
	ORA #$07
	STA -6,U
	LDA #$dd
	STA -76,U
	LDD -79,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$d007
	STD -79,U
	LDD -81,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -81,U
	LDA #$99
	LDX #$7ddd
	PSHU A,X,Y
	LEAU -76,U

	LDD -78,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$d007
	STD -78,U
	LDA -5,U
	ANDA #$F0
	ORA #$07
	STA -5,U
	LDA -75,U
	ANDA #$F0
	ORA #$0d
	STA -75,U
	LDD #$8977
	PSHU D,Y
	LEAU -74,U

	LDA -7,U
	ANDA #$F0
	ORA #$07
	STA -7,U
	LDA -77,U
	ANDA #$F0
	ORA #$0d
	STA -77,U
	LDD -18,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -18,U
	LDD #$7977
	LDX #$dddd
	LDY #$dd77
	PSHU D,X,Y
	LEAU -73,U

	LDD -8,U
	ANDA #$F0
	ORA #$07
	LDB #$98
	STD -8,U
	LDA #$aa
	STA -78,U
	LDB #$aa
	STD -19,U
	LDD #$77dd
	LDY #$77dd
	PSHU D,X,Y
	LEAU -74,U

	LDA #$98
	STA -7,U
	LDA #$77
	PSHU D,X,Y
	LEAU -11,U

	LDA #$7a
	STA -62,U
	LDD -61,U
	LDA #$aa
	ANDB #$0F
	ORB #$80
	STD -61,U
	LDX #$aaaa
	PSHU A,X
	LEAU -60,U

	LDA -6,U
	ANDA #$F0
	ORA #$07
	STA -6,U
	LDA #$dd
	LDX #$dddd
	PSHU A,X,Y
	LEAU -12,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA #$7a
	STA -62,U
	LDD -61,U
	LDA #$aa
	ANDB #$0F
	ORB #$30
	STD -61,U
	LDX #$aaaa
	PSHU A,X
	LEAU -60,U

	LDD -19,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -19,U
	LDA -6,U
	ANDA #$F0
	ORA #$07
	STA -6,U
	STX -21,U
	LDA #$7d
	LDX #$dddd
	PSHU A,X,Y
	LEAU -71,U

	LDA #$7a
	LDX #$aaa3
	PSHU A,X
	LEAU -1,U

	LDA #$7d
	LDX #$dddd
	PSHU A,X,Y
	LEAU -13,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -55,U

	LDA #$7d
	PSHU A,X
	LEAU -1,U

	LDD -20,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -20,U
	LDD -80,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d070
	STD -80,U
	STX -22,U
	STX -78,U
	LDA #$87
	LDX #$dddd
	PSHU A,X,Y
	LEAU -75,U

	LDA #$a7
	PSHU A,X,Y
	LEAU -14,U

	LDD #$77aa
	STD -60,U
	LDD -58,U
	LDA #$aa
	ANDB #$0F
	ORB #$30
	STD -58,U
	LDD -62,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -62,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -58,U

	LDA #$88
	STA -6,U
	LDA -23,U
	ANDA #$F0
	ORA #$0a
	STA -23,U
	STX -22,U
	LDD -20,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -20,U
	LDD #$a7dd
	LDX #$dd77
	PSHU D,X
	LEAU -70,U

	LDD -6,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -6,U
	LDD #$77aa
	LDX #$aaa3
	PSHU D,X
	LEAU -2,U

	LDD -6,U
	LDA #$89
	ANDB #$0F
	ORB #$80
	STD -6,U
	LDD #$7add
	LDX #$dd77
	PSHU D,X
	LEAU -15,U

	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -51,U

	LDD #$dddd
	LDX #$77aa
	LDY #$aaaa
	PSHU D,X,Y
	LDD -6,U
	LDA #$78
	ANDB #$0F
	ORB #$90
	STD -6,U
	LDD #$7add
	LDX #$dd77
	PSHU D,X
	LEAU -15,U

	LDA -5,U
	ANDA #$F0
	ORA #$0a
	STA -5,U
	LDD #$aaaa
	PSHU D,Y
	LEAU -51,U

	LDD #$dddd
	LDX #$779a
	PSHU D,X,Y
	LDD -6,U
	LDA #$77
	ANDB #$0F
	ORB #$80
	STD -6,U
	LDD #$7add
	LDX #$dd77
	PSHU D,X
	LEAU -16,U

	LDD #$aaaa
	PSHU D,Y
	LEAU -50,U

	LDD #$dddd
	LDX #$7789
	PSHU D,X,Y
	LDA #$88
	STA -6,U
	LDD -5,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$8007
	STD -5,U
	LDA #$dd
	LDX #$dd77
	PSHU A,X
	LEAU -17,U

	LDA #$aa
	LDX #$aaaa
	PSHU A,X,Y
	LEAU -49,U

	LDD #$dddd
	LDX #$7779
	PSHU D,X,Y
	LDA #$88
	STA -6,U
	LDA -4,U
	ANDA #$F0
	ORA #$07
	STA -4,U
	LDX #$ddd7
	PSHU B,X
	LEAU -18,U

	LDD #$aaaa
	PSHU D,Y
	LEAU -49,U

	LDD #$dddd
	LDX #$7798
	PSHU D,X,Y
	LDX #$ddd7
	PSHU A,X
	LEAU -18,U

	LDD -55,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -55,U
	LDD -57,U
	ANDA #$F0
	ORA #$07
	LDB #$98
	STD -57,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X,Y
	LEAU -52,U

	LDA #$dd
	LDX #$ddd7
	LDY #$dddd
	PSHU A,X,Y
	LEAU -19,U

	LDD -54,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -54,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -52,U

	LDD #$887d
	LDX #$ddd7
	PSHU D,X,Y
	LEAU -18,U

	LDD -54,U
	ANDA #$F0
	ORA #$03
	LDB #$aa
	STD -54,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -51,U

	LDA #$89
	STA -7,U
	LDD -27,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -27,U
	STX -29,U
	LDD -79,U
	ANDA #$F0
	ORA #$03
	LDB #$aa
	STD -79,U
	LDD #$8ddd
	LDX #$d7dd
	LDY #$dd77
	PSHU D,X,Y
	LEAU -74,U

	LDA #$78
	STA -7,U
	LDA #$9d
	LDX #$dd7d
	LDY #$8877
	PSHU D,X,Y
	LEAU -20,U

	LDD -53,U
	ANDA #$F0
	ORA #$03
	LDB #$aa
	STD -53,U
	LDX #$aaaa
	PSHU B,X
	LEAU -51,U

	LDA #$77
	STA -7,U
	LDD #$8ddd
	LDX #$dd7d
	LDY #$8987
	PSHU D,X,Y
	LEAU -20,U

	LDD -53,U
	ANDA #$F0
	ORA #$03
	LDB #$3a
	STD -53,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -51,U

	STX -29,U
	LDA #$88
	STA -7,U
	LDD -79,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -79,U
	LDD #$87dd
	LDX #$887d
	LDY #$7897
	PSHU D,X,Y
	LEAU -74,U

	LDD -79,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -79,U
	LDD #$aaaa
	STD -29,U
	LDA #$88
	STA -7,U
	LDD #$77d7
	LDX #$997d
	LDY #$7787
	PSHU D,X,Y
	LEAU -74,U

	LDA #$aa
	STA -29,U
	LDD -79,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -79,U
	LDD -82,U
	LDA #$88
	ANDB #$F0
	ORB #$07
	STD -82,U
	LDD #$7ad7
	LDX #$897d
	LDY #$8887
	PSHU D,X,Y
	LEAU -76,U

	LDD -77,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -77,U
	LDA #$aa
	STA -27,U
	LDD #$7ad7
	LDX #$797d
	PSHU D,X
	LEAU -75,U

	LDA -5,U
	ANDA #$F0
	ORA #$07
	STA -5,U
	LDA -28,U
	ANDA #$0F
	ORA #$a0
	STA -28,U
	LDD #$7333
	STD -78,U
	LDD #$d798
	LDX #$77dd
	PSHU D,X
	LEAU -76,U

	LDA -5,U
	ANDA #$F0
	ORA #$07
	STA -5,U
	LDD #$7333
	STD -78,U
	LDD #$dd98
	PSHU D,X
	LEAU -76,U

	LDA -5,U
	ANDA #$F0
	ORA #$07
	STA -5,U
	LDD #$dddd
	PSHU D,X
	RTS
