	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_tk_032_0
	LEAU 3850,U

	LDD 124,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 124,U
	LDD 94,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 94,U
	LDA #$bb
	STA 116,U
	LDA #$99
	STD 44,U
	LDD -36,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -36,U
	LDD -65,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -65,U
	STA 15,U
	STA -116,U
	LDA 36,U
	ANDA #$0F
	ORA #$b0
	STA 36,U
	LDA 24,U
	ANDA #$0F
	ORA #$b0
	STA 24,U
	LDA -44,U
	ANDA #$0F
	ORA #$b0
	STA -44,U
	LDA -56,U
	ANDA #$0F
	ORA #$b0
	STA -56,U
	LDA -124,U
	ANDA #$0F
	ORA #$b0
	STA -124,U
	LEAU -260,U

	LDD #$9999
	STD 115,U
	STD -17,U
	LDA 124,U
	ANDA #$0F
	ORA #$b0
	STA 124,U
	LDA -116,U
	ANDA #$F0
	ORA #$0b
	STA -116,U
	LDD 63,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 63,U
	LDD 35,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 35,U
	LDA #$bb
	STA 44,U
	STA -36,U
	STB -44,U
	LDD -97,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -97,U
	LDD -124,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -124,U
	LEAU -301,U

	STA 124,U
	STA 44,U
	STA -62,U
	LDA 116,U
	ANDA #$F0
	ORA #$0b
	STA 116,U
	LDA 105,U
	ANDA #$F0
	ORA #$0b
	STA 105,U
	LDA 36,U
	ANDA #$F0
	ORA #$0b
	STA 36,U
	LDA -44,U
	ANDA #$F0
	ORA #$0b
	STA -44,U
	LDD 17,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 17,U
	LDD -37,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -37,U
	LDD #$9999
	STD 97,U
	LDD -117,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -117,U
	LDA #$bb
	STA -124,U
	LEAU -262,U

	LDA #$99
	STA 120,U
	STA 65,U
	STA -15,U
	STA -119,U
	LDD -40,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -40,U
	LDD -96,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -96,U
	LDD 40,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 40,U
	LDA 58,U
	ANDA #$0F
	ORA #$b0
	STA 58,U
	LDA -22,U
	ANDA #$0F
	ORA #$b0
	STA -22,U
	LDA -102,U
	ANDA #$0F
	ORA #$b0
	STA -102,U
	LDA -112,U
	ANDA #$0F
	ORA #$b0
	STA -112,U
	LEAU -296,U

	LDA 104,U
	ANDA #$0F
	ORA #$b0
	STA 104,U
	LDA 24,U
	ANDA #$0F
	ORA #$b0
	STA 24,U
	LDA -56,U
	ANDA #$0F
	ORA #$b0
	STA -56,U
	LDD 120,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD 120,U
	LDD -63,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -63,U
	LDA #$99
	STA 97,U
	STA 40,U
	STA 17,U
	STA -40,U
	STA -120,U
	LEAU -259,U

	STA 117,U
	STA 37,U
	STA -43,U
	STA -102,U
	LDA 123,U
	ANDA #$F0
	ORA #$0b
	STA 123,U
	LDA 59,U
	ANDA #$0F
	ORA #$90
	STA 59,U
	LDA 43,U
	ANDA #$F0
	ORA #$0b
	STA 43,U
	LDA -22,U
	ANDA #$F0
	ORA #$09
	STA -22,U
	LDA -108,U
	ANDA #$F0
	ORA #$0b
	STA -108,U
	LDA -123,U
	ANDA #$F0
	ORA #$09
	STA -123,U
	LEAU -305,U

	LDA #$99
	STA 123,U
	STA 43,U
	STA 23,U
	STA -57,U
	LDD 102,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD 102,U
	LDA 117,U
	ANDA #$F0
	ORA #$0b
	STA 117,U
	LDA 37,U
	ANDA #$F0
	ORA #$0b
	STA 37,U
	LDA -37,U
	ANDA #$0F
	ORA #$90
	STA -37,U
	LDA -43,U
	ANDA #$0F
	ORA #$b0
	STA -43,U
	LDA -118,U
	ANDA #$F0
	ORA #$09
	STA -118,U
	LDA -123,U
	ANDA #$0F
	ORA #$b0
	STA -123,U
	LEAU -257,U

	LDA 54,U
	ANDA #$0F
	ORA #$b0
	STA 54,U
	LDA 40,U
	ANDA #$F0
	ORA #$09
	STA 40,U
	LDA -34,U
	ANDA #$0F
	ORA #$b0
	STA -34,U
	LDA -39,U
	ANDA #$0F
	ORA #$90
	STA -39,U
	LDA -105,U
	ANDA #$0F
	ORA #$a0
	STA -105,U
	LDA -114,U
	ANDA #$0F
	ORA #$b0
	STA -114,U
	LDA #$99
	STA 120,U
	STA 59,U
	STA -21,U
	STA -101,U
	STA -119,U
	LEAU -309,U

	LDA #$aa
	STA 124,U
	LDA 128,U
	ANDA #$0F
	ORA #$90
	STA 128,U
	LDA 115,U
	ANDA #$0F
	ORA #$b0
	STA 115,U
	LDA 113,U
	ANDA #$F0
	ORA #$0a
	STA 113,U
	LDA 47,U
	ANDA #$F0
	ORA #$09
	STA 47,U
	LDA -33,U
	ANDA #$F0
	ORA #$09
	STA -33,U
	LDA -50,U
	ANDA #$F0
	ORA #$09
	STA -50,U
	LDA #$99
	STA 110,U
	STA 30,U
	STA -113,U
	LDD 44,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 44,U
	LDD 33,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 33,U
	LDD #$aaaa
	STD -36,U
	STD -116,U
	STD -128,U
	LDD -46,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$a00b
	STD -46,U
	LDD -126,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$a00b
	STD -126,U
	LDD -48,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -48,U
	LEAU -130,U

	LDA ,U
	ANDA #$F0
	ORA #$09
	STA ,U
	LEAU -155,U

	LDD 91,U
	ANDA #$0F
	ORA #$a0
	LDB #$99
	STD 91,U
	LDD #$aaaa
	STD 89,U
	STD 77,U
	STD 9,U
	STD -71,U
	LDD 79,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$a00b
	STD 79,U
	LDA 76,U
	ANDA #$0F
	ORA #$90
	STA 76,U
	LDA 12,U
	ANDA #$0F
	ORA #$90
	STA 12,U
	LDA -73,U
	ANDA #$F0
	ORA #$0b
	STA -73,U
	LDD #$99aa
	LDX #$aaaa
	PSHU D,X
	LEAU -76,U

	LDD -70,U
	LDA #$aa
	ANDB #$F0
	ORB #$09
	STD -70,U
	LDA -73,U
	ANDA #$F0
	ORA #$0b
	STA -73,U
	LDA #$aa
	STA -71,U
	LDD #$99aa
	PSHU D,X
	LEAU -70,U

	LDD -78,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -78,U
	LDD -10,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$090a
	STD -10,U
	LDD -76,U
	LDA #$aa
	ANDB #$F0
	ORB #$09
	STD -76,U
	LDD -80,U
	LDA #$bb
	ANDB #$F0
	ORB #$0b
	STD -80,U
	STX -8,U
	LDX #$bbbb
	PSHU A,X
	LEAU -77,U

	LDD #$aaaa
	STD -8,U
	LDD -10,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$090a
	STD -10,U
	LDA #$bb
	LDY #$bbbb
	PSHU A,X,Y
	LEAU -69,U

	LDD -5,U
	LDA #$b9
	ANDB #$F0
	ORB #$0a
	STD -5,U
	LDA #$aa
	LDX #$aa99
	PSHU A,X
	LEAU -2,U

	LDD -8,U
	LDA #$aa
	ANDB #$F0
	ORB #$09
	STD -8,U
	LDD -77,U
	ANDA #$0F
	ORA #$a0
	LDB #$99
	STD -77,U
	LDA #$aa
	STA -9,U
	LDD #$bbbb
	LDX #$bbbb
	PSHU D,X,Y
	LEAU -71,U

	LDD #$888b
	LDX #$bbb9
	LDY #$9aaa
	PSHU D,X,Y
	LDD -74,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$a090
	STD -74,U
	LDA -7,U
	ANDA #$0F
	ORA #$90
	STA -7,U
	LDD #$aaaa
	LDX #$99bb
	LDY #$bb88
	PSHU D,X,Y
	LEAU -68,U

	LDD #$8888
	LDX #$88b9
	LDY #$9aaa
	PSHU D,X,Y
	LDD #$aaaa
	STD -76,U
	LDA -7,U
	ANDA #$0F
	ORA #$90
	STA -7,U
	LDD #$aaaa
	LDX #$99b8
	LDY #$8888
	PSHU D,X,Y
	LEAU -71,U

	LDD #$8888
	LDX #$8888
	PSHU D,X,Y
	LDD #$aaaa
	STD -73,U
	LDA #$99
	LDX #$aa99
	PSHU D,X
	LEAU -70,U

	LDD #$8888
	LDX #$8888
	PSHU D,X,Y
	LEAU -1,U

	LDD -71,U
	LDA #$aa
	ANDB #$F0
	ORB #$09
	STD -71,U
	STA -72,U
	LDA #$99
	LDX #$aaaa
	PSHU A,X
	LEAU -70,U

	LDA -6,U
	ANDA #$F0
	ORA #$08
	STA -6,U
	LDA -10,U
	ANDA #$F0
	ORA #$09
	STA -10,U
	LDD #$9aaa
	STD -9,U
	LDA #$88
	LDX #$8888
	PSHU A,X,Y
	LEAU -71,U

	LDX #$aa99
	PSHU B,X
	LEAU -1,U

	LDA -6,U
	ANDA #$F0
	ORA #$08
	STA -6,U
	LDA -10,U
	ANDA #$F0
	ORA #$09
	STA -10,U
	LDD #$99aa
	STD -9,U
	LDA #$88
	LDX #$8888
	PSHU A,X,Y
	LEAU -71,U

	LDX #$aa99
	PSHU B,X
	LEAU -1,U

	LDA #$99
	STD -9,U
	LDD -7,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$a008
	STD -7,U
	LDD -78,U
	ANDA #$0F
	ORA #$a0
	LDB #$99
	STD -78,U
	LDA #$aa
	STA -79,U
	LDA #$88
	LDX #$8888
	PSHU A,X,Y
	LEAU -75,U

	STX -82,U
	LDA #$bb
	STA -10,U
	LDA #$aa
	STA -79,U
	LDD -8,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -8,U
	LDD -77,U
	LDA #$8b
	ANDB #$0F
	ORB #$b0
	STD -77,U
	LDD -85,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -85,U
	LDD -88,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -88,U
	LDD -90,U
	LDA #$bb
	ANDB #$0F
	ORB #$80
	STD -90,U
	LDA #$88
	PSHU A,X,Y
	LEAU -199,U

	LDA -47,U
	ANDA #$F0
	ORA #$0b
	STA -47,U
	LDA #$aa
	STA 45,U
	STA -35,U
	LDD 34,U
	LDA #$bb
	ANDB #$0F
	ORB #$80
	STD 34,U
	LDD -43,U
	LDA #$aa
	ANDB #$F0
	ORB #$0c
	STD -43,U
	LDD #$88bb
	STD -33,U
	LDD -45,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$800a
	STD -45,U
	LDD 47,U
	ANDA #$0F
	ORA #$80
	LDB #$bb
	STD 47,U
	LDD 36,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 36,U
	LEAU -204,U

	LDD 8,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0aa0
	STD 8,U
	LDA #$aa
	STA 89,U
	STA 81,U
	STA 1,U
	STA -79,U
	LDD 78,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD 78,U
	LDD -68,U
	ANDA #$0F
	ORA #$80
	LDB #$bb
	STD -68,U
	LDD -70,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -70,U
	LDA #$bb
	STA 77,U
	LDA 13,U
	ANDA #$0F
	ORA #$b0
	STA 13,U
	LDA 7,U
	ANDA #$F0
	ORA #$0c
	STA 7,U
	LDA -72,U
	ANDA #$F0
	ORA #$0a
	STA -72,U
	LDA -83,U
	ANDA #$0F
	ORA #$b0
	STA -83,U
	STB 11,U
	LDD 91,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD 91,U
	STX -82,U
	LDA #$bb
	PSHU A,X
	LEAU -143,U

	LDD -84,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -84,U
	LDD -87,U
	ANDA #$0F
	ORA #$80
	LDB #$aa
	STD -87,U
	LDD -90,U
	ANDA #$F0
	ORA #$0d
	LDB #$33
	STD -90,U
	STX -16,U
	LDD -82,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -82,U
	LDA -4,U
	ANDA #$F0
	ORA #$08
	STA -4,U
	LDA -6,U
	ANDA #$F0
	ORA #$0a
	STA -6,U
	LDA -13,U
	ANDA #$F0
	ORA #$0a
	STA -13,U
	LDA -18,U
	ANDA #$F0
	ORA #$0b
	STA -18,U
	LDA -92,U
	ANDA #$0F
	ORA #$80
	STA -92,U
	STX -96,U
	LDD -98,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0b08
	STD -98,U
	LDA #$88
	LDX #$88bb
	PSHU A,X
	LEAU -164,U

	STY 4,U
	STY -76,U
	LDD ,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$8008
	STD ,U
	LDD -8,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80c0
	STD -8,U
	LDA -5,U
	ANDA #$0F
	ORA #$80
	STA -5,U
	LDA -73,U
	ANDA #$0F
	ORA #$b0
	STA -73,U
	LDA #$bb
	STA -11,U
	LDD -10,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -10,U
	LDD -80,U
	ANDA #$0F
	ORA #$30
	LDB #$88
	STD -80,U
	LDD #$8333
	LDX #$3333
	PSHU D,X
	LEAU -76,U

	LDD -7,U
	ANDA #$F0
	ORA #$0c
	LDB #$88
	STD -7,U
	LDD -76,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -76,U
	STY -10,U
	LDA -11,U
	ANDA #$0F
	ORA #$b0
	STA -11,U
	LDD -74,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -74,U
	LDD #$3333
	PSHU D,X
	LEAU -73,U

	LDY #$888c
	PSHU D,X,Y
	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA -8,U
	ANDA #$0F
	ORA #$b0
	STA -8,U
	LDD #$8888
	STD -7,U
	LDX #$8333
	PSHU A,X
	LEAU -66,U

	LDX #$88bb
	PSHU A,X
	LEAU -2,U

	LDD #$3333
	LDX #$3333
	LDY #$38cc
	PSHU D,X,Y
	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDD #$8888
	STD -7,U
	LDD -71,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -71,U
	STA -72,U
	LDA #$c8
	PSHU A,X
	LEAU -71,U

	LDD #$3333
	LDY #$33cc
	PSHU D,X,Y
	LDD -7,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -7,U
	LDD -71,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -71,U
	LDA -9,U
	ANDA #$F0
	ORA #$0b
	STA -9,U
	LDA #$88
	STA -72,U
	LDA #$cd
	PSHU A,X
	LEAU -71,U

	LDD #$3333
	LDY #$83cc
	PSHU D,X,Y
	LDD -8,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -8,U
	LDA -9,U
	ANDA #$F0
	ORA #$0b
	STA -9,U
	LDD #$8888
	STD -72,U
	LDD -76,U
	LDA #$87
	ANDB #$0F
	ORB #$d0
	STD -76,U
	LDA #$c3
	LDX #$8333
	PSHU A,X
	LEAU -73,U

	LDA #$33
	STA -7,U
	LDD #$9933
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LEAU -4,U

	LDA -66,U
	ANDA #$F0
	ORA #$08
	STA -66,U
	LDD -65,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -65,U
	LDA #$bb
	LDX #$8888
	PSHU A,X
	LEAU -65,U

	LDD #$3333
	LDX #$3333
	LDY #$773d
	PSHU D,X,Y
	LDA -9,U
	ANDA #$0F
	ORA #$b0
	STA -9,U
	LDD #$8888
	STD -8,U
	LDD -70,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -70,U
	LDA #$88
	STA -71,U
	LDA #$33
	LDX #$8933
	PSHU A,X
	LEAU -71,U

	LDD #$3333
	LDX #$3333
	LDY #$8337
	PSHU D,X,Y
	LDD #$8888
	STD -8,U
	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	LDA -9,U
	ANDA #$0F
	ORA #$b0
	STA -9,U
	LDA #$33
	LDX #$8333
	PSHU A,X
	LEAU -65,U

	LDX #$88bb
	PSHU B,X
	LEAU -3,U

	LDB #$33
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LDD #$8888
	STD -8,U
	LDD #$d733
	PSHU D,X
	LEAU -64,U

	LDA #$88
	LDX #$88bb
	PSHU A,X
	LEAU -3,U

	LDA #$33
	LDX #$3333
	PSHU D,X,Y
	LEAU -1,U

	LDA #$88
	STA -70,U
	LDD -7,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -7,U
	LDD -69,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -69,U
	LDD -74,U
	LDA #$33
	ANDB #$0F
	ORB #$d0
	STD -74,U
	LDA #$d7
	PSHU A,X
	LEAU -71,U

	LDD -5,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -5,U
	LDD -7,U
	LDA #$33
	ANDB #$F0
	ORB #$09
	STD -7,U
	LDD -80,U
	LDA #$33
	ANDB #$0F
	ORB #$d0
	STD -80,U
	LDD #$d733
	STD -9,U
	LDA -15,U
	ANDA #$F0
	ORA #$0b
	STA -15,U
	LDD -14,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -14,U
	LDD #$8888
	STD -76,U
	LDA #$39
	LDX #$7333
	PSHU A,X
	LEAU -77,U

	LDA -15,U
	ANDA #$F0
	ORA #$0b
	STA -15,U
	LDD #$d733
	STD -9,U
	LDD -14,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -14,U
	LDD -76,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -76,U
	LDD -5,U
	LDA #$33
	ANDB #$F0
	ORB #$07
	STD -5,U
	LDD -7,U
	LDA #$33
	ANDB #$0F
	ORB #$70
	STD -7,U
	LDA #$39
	PSHU A,X
	LEAU -75,U

	LDA #$33
	STA -7,U
	LDD #$7733
	LDX #$3333
	LDY #$aadd
	PSHU D,X,Y
	LEAU -2,U

	PSHU A,X
	LEAU -3,U

	LDD -64,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -64,U
	LDA #$bb
	LDX #$8888
	PSHU A,X
	LEAU -63,U

	LDD #$8333
	LDX #$3333
	PSHU D,X,Y
	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDA -11,U
	ANDA #$0F
	ORA #$b0
	STA -11,U
	LDA -69,U
	ANDA #$0F
	ORA #$b0
	STA -69,U
	LDD #$8888
	STD -10,U
	STA -71,U
	LDA #$77
	LDY #$3333
	PSHU A,X,Y
	LEAU -69,U

	LDD #$3333
	LDY #$aa7d
	PSHU D,X,Y
	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDA -11,U
	ANDA #$0F
	ORA #$b0
	STA -11,U
	LDD -70,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -70,U
	LDD #$8888
	STD -10,U
	STA -71,U
	LDA #$7a
	LDY #$3333
	PSHU A,X,Y
	LEAU -69,U

	LDD #$3333
	LDY #$aa7d
	PSHU D,X,Y
	LDA #$88
	STA -71,U
	LDD -70,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -70,U
	LDD #$8888
	STD -10,U
	LDD #$dd7a
	LDY #$3333
	PSHU D,X,Y
	LEAU -68,U

	LDD #$3333
	LDY #$aa77
	PSHU D,X,Y
	LDA #$88
	STA -71,U
	LDD -10,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDD -70,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -70,U
	LDD #$dd7a
	LDY #$3333
	PSHU D,X,Y
	LEAU -68,U

	LDD #$3333
	LDY #$aa77
	PSHU D,X,Y
	LDA #$88
	STA -71,U
	LDD -10,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDD -70,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -70,U
	LDD -75,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -75,U
	LDD #$ddaa
	LDY #$3333
	PSHU D,X,Y
	LEAU -69,U

	LDD #$3333
	LDY #$333a
	PSHU D,X,Y
	LDA #$88
	STA -70,U
	LDD -9,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -9,U
	LDD -69,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -69,U
	LDD -74,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -74,U
	LDA #$d7
	LDX #$aa33
	LDY #$3333
	PSHU A,X,Y
	LEAU -69,U

	LDD #$3333
	LDX #$3333
	LDY #$333a
	PSHU D,X,Y
	LDA -11,U
	ANDA #$F0
	ORA #$0b
	STA -11,U
	LDA #$88
	STA -9,U
	LDB #$88
	STD -70,U
	LDA #$d7
	LDX #$aa33
	LDY #$3333
	PSHU A,X,Y
	LEAU -67,U

	LDD #$3333
	LDX #$333a
	LDY #$a7dd
	PSHU D,X,Y
	LEAU -2,U

	LDA -11,U
	ANDA #$F0
	ORA #$0b
	STA -11,U
	LDD -10,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -10,U
	LDD #$8888
	STD -70,U
	LDA #$77
	LDX #$aa33
	LDY #$3333
	PSHU A,X,Y
	LEAU -67,U

	LDA #$33
	LDX #$3333
	LDY #$a77d
	PSHU A,X,Y
	LEAU -3,U

	LDD -10,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -10,U
	LDA -11,U
	ANDA #$F0
	ORA #$0b
	STA -11,U
	LDD #$8888
	STD -70,U
	LDA #$77
	LDX #$aa33
	LDY #$3333
	PSHU A,X,Y
	LEAU -67,U

	LDA -5,U
	ANDA #$F0
	ORA #$03
	STA -5,U
	LDD #$3333
	LDX #$aa77
	PSHU D,X
	LEAU -5,U

	LDD -9,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -9,U
	LDD -69,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -69,U
	LDA -5,U
	ANDA #$F0
	ORA #$0d
	STA -5,U
	LDA -10,U
	ANDA #$0F
	ORA #$b0
	STA -10,U
	LDD #$77aa
	PSHU D,Y
	LEAU -67,U

	LDD #$3333
	PSHU D,X
	LEAU -5,U

	LDA -5,U
	ANDA #$F0
	ORA #$07
	STA -5,U
	LDA -10,U
	ANDA #$0F
	ORA #$b0
	STA -10,U
	LDD -9,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -9,U
	LDD -69,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -69,U
	LDD #$77aa
	PSHU D,Y
	LEAU -67,U

	LDD -11,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -11,U
	LDA -14,U
	ANDA #$F0
	ORA #$07
	STA -14,U
	LDA -19,U
	ANDA #$0F
	ORA #$b0
	STA -19,U
	LDD #$7aa3
	STD -13,U
	LDD -18,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -18,U
	LDD -78,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -78,U
	LDD #$3333
	PSHU D,X
	LEAU -76,U

	PSHU D,X
	LEAU -6,U

	LDD #$bbbb
	STD -63,U
	LDD #$8888
	STD -8,U
	LDA -65,U
	ANDA #$0F
	ORA #$b0
	STA -65,U
	LDD -68,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -68,U
	LDD #$777a
	LDX #$a333
	PSHU D,X
	LEAU -65,U

	LDA -5,U
	ANDA #$F0
	ORA #$03
	STA -5,U
	LDD #$33aa
	LDX #$7788
	PSHU D,X
	LEAU -7,U

	LDD #$8888
	STD -8,U
	LDD -12,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -12,U
	STA -13,U
	LDD #$777a
	LDX #$a333
	PSHU D,X
	LEAU -57,U

	LDD -7,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -7,U
	LDD #$bbbb
	LDX #$bbbb
	PSHU D,X
	LEAU -4,U

	LDA -5,U
	ANDA #$F0
	ORA #$03
	STA -5,U
	LDD #$33aa
	LDX #$7788
	PSHU D,X
	LEAU -6,U

	LDA -6,U
	ANDA #$F0
	ORA #$08
	STA -6,U
	LDD #$8888
	STD -9,U
	LDA #$77
	LDX #$aa33
	PSHU A,X,Y
	LEAU -5,U

	LDD #$bbbb
	LDX #$bbbb
	PSHU D,X
	LEAU -48,U

	LDD -8,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$8008
	STD -8,U
	LDD -6,U
	LDA #$88
	ANDB #$F0
	ORB #$0c
	STD -6,U
	LDD #$bbbb
	PSHU D,X
	LEAU -4,U

	LDD -6,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -6,U
	LDD #$33aa
	LDX #$7788
	PSHU D,X
	LEAU -6,U

	LDD #$8877
	LDX #$aa33
	PSHU D,X,Y
	LEAU -1,U

	LDD -58,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -58,U
	STA -7,U
	LDD #$bbbb
	LDX #$bbcc
	LDY #$8888
	PSHU D,X,Y
	LEAU -52,U

	LDD -5,U
	LDA #$88
	ANDB #$F0
	ORB #$08
	STD -5,U
	LDX #$ccbb
	PSHU A,X
	LEAU -2,U

	LDD -6,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -6,U
	LDD #$333a
	LDX #$a788
	PSHU D,X
	LEAU -6,U

	LDD -8,U
	LDA #$88
	ANDB #$F0
	ORB #$08
	STD -8,U
	LDD #$8877
	LDX #$aa33
	LDY #$3333
	PSHU D,X,Y
	LEAU -3,U

	LDA #$cc
	STA -58,U
	LDA #$bb
	LDX #$bbcc
	PSHU A,X
	LEAU -56,U

	LDD #$333a
	LDX #$aa88
	LDY #$8888
	PSHU D,X,Y
	LEAU -6,U

	LDA -10,U
	ANDA #$F0
	ORA #$0c
	STA -10,U
	LDA -66,U
	ANDA #$F0
	ORA #$09
	STA -66,U
	STY -8,U
	LDD #$8877
	LDX #$aa33
	LDY #$3333
	PSHU D,X,Y
	LEAU -62,U

	LDA -9,U
	ANDA #$F0
	ORA #$03
	STA -9,U
	LDA -12,U
	ANDA #$F0
	ORA #$03
	STA -12,U
	LDD #$3333
	LDX #$aa78
	LDY #$8888
	PSHU D,X,Y
	LEAU -7,U

	LDA -65,U
	ANDA #$F0
	ORA #$09
	STA -65,U
	LDD #$8888
	LDX #$7aaa
	LDY #$3333
	PSHU D,X,Y
	LEAU -62,U

	LDD -14,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -14,U
	STA -8,U
	STA -11,U
	LDX #$33aa
	LDY #$7888
	PSHU A,X,Y
	LEAU -9,U

	LDA #$a3
	STA -81,U
	STY -68,U
	LDD -70,U
	LDA #$33
	ANDB #$0F
	ORB #$a0
	STD -70,U
	LDD -80,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -80,U
	STA -71,U
	STA -77,U
	LDD -75,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -75,U
	LDD -84,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -84,U
	LDA -63,U
	ANDA #$F0
	ORA #$09
	STA -63,U
	LDD #$8888
	LDX #$7aaa
	PSHU D,X
	LEAU -142,U

	LDD -9,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -9,U
	LDA 3,U
	ANDA #$F0
	ORA #$09
	STA 3,U
	LDA -11,U
	ANDA #$F0
	ORA #$03
	STA -11,U
	LDA #$33
	LDX #$3399
	PSHU A,X,Y
	LEAU -7,U

	LDD -5,U
	LDA #$88
	ANDB #$0F
	ORB #$70
	STD -5,U
	LDD -70,U
	LDA #$73
	ANDB #$0F
	ORB #$80
	STD -70,U
	LDD -72,U
	LDA #$33
	ANDB #$0F
	ORB #$80
	STD -72,U
	LDA -65,U
	ANDA #$F0
	ORA #$09
	STA -65,U
	LDA #$33
	STA -73,U
	STA -77,U
	LDA #$a3
	LDX #$3333
	PSHU A,X
	LEAU -77,U

	LDD -71,U
	ANDA #$0F
	ORA #$80
	LDB #$73
	STD -71,U
	STX -73,U
	LDA -77,U
	ANDA #$0F
	ORA #$30
	STA -77,U
	LDA #$88
	LDX #$7733
	LDY #$3333
	PSHU A,X,Y
	LEAU -75,U

	LDD -71,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -71,U
	LDD -5,U
	LDA #$83
	ANDB #$F0
	ORB #$09
	STD -5,U
	STY -73,U
	LDA #$33
	PSHU A,Y
	LEAU -77,U

	LDD -5,U
	LDA #$33
	ANDB #$F0
	ORB #$09
	STD -5,U
	LDD -70,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -70,U
	PSHU A,Y
	LEAU -67,U

	PSHU A,Y
	LEAU -7,U

	LDX #$3333
	PSHU A,X,Y
	LEAU -63,U

	LDD -14,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -14,U
	PSHU A,X,Y
	LEAU -9,U

	LDD -64,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -64,U
	LDA #$33
	PSHU A,X
	LEAU -63,U

	LDD -14,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -14,U
	PSHU A,X,Y
	LEAU -9,U

	LDD -7,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -7,U
	LDA -4,U
	ANDA #$F0
	ORA #$03
	STA -4,U
	LDA #$33
	PSHU A,X
	LEAU -58,U

	LDD -6,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -6,U
	LDD #$8888
	LDX #$8899
	PSHU D,X
	LEAU -2,U

	LDD -13,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -13,U
	LDD #$3333
	PSHU D,Y
	LEAU -9,U

	PSHU D,Y
	LEAU -1,U

	LDA #$99
	LDX #$8888
	PSHU A,X
	LEAU -52,U

	LDD #$3388
	LDX #$9988
	LDY #$9999
	PSHU D,X,Y
	LDX #$3333
	LDY #$3333
	PSHU A,X,Y
	LEAU -8,U

	LDD #$8333
	PSHU D,X,Y
	LDD #$9999
	LDX #$8899
	PSHU D,X
	LEAU -50,U

	LDY #$9999
	PSHU D,X,Y
	LDD #$3333
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LEAU -8,U

	PSHU D,X,Y
	LDA #$99
	LDX #$9997
	LDY #$9999
	PSHU A,X,Y
	LEAU -49,U

	LDB #$99
	LDX #$9899
	PSHU D,X,Y
	LDD #$3333
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LEAU -8,U

	LDA #$83
	PSHU D,X,Y
	LDD #$9999
	LDX #$9978
	LDY #$9999
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 3850,U

	LDD 124,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 124,U
	LDD 94,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 94,U
	LDA #$bb
	STA 103,U
	LDA #$99
	STA 44,U
	LDA 35,U
	ANDA #$F0
	ORA #$0b
	STA 35,U
	LDA 23,U
	ANDA #$F0
	ORA #$0b
	STA 23,U
	LDA -45,U
	ANDA #$F0
	ORA #$0b
	STA -45,U
	LDA -57,U
	ANDA #$F0
	ORA #$0b
	STA -57,U
	LDA -125,U
	ANDA #$F0
	ORA #$0b
	STA -125,U
	LDD #$9999
	STD 14,U
	STD -117,U
	LDD -37,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -37,U
	LDD -66,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -66,U
	LEAU -261,U

	LDA 124,U
	ANDA #$F0
	ORA #$0b
	STA 124,U
	LDA -104,U
	ANDA #$0F
	ORA #$b0
	STA -104,U
	STB 116,U
	STB -16,U
	LDD -97,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -97,U
	LDD -124,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -124,U
	LDA #$bb
	STA 56,U
	STA -24,U
	LDA #$99
	STD -44,U
	LDD 64,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 64,U
	LDD 36,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 36,U
	LEAU -297,U

	LDD #$9999
	STD 120,U
	LDD 40,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 40,U
	LDD -66,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -66,U
	STA 94,U
	STA 14,U
	STA -40,U
	STA -120,U
	LDA 113,U
	ANDA #$0F
	ORA #$b0
	STA 113,U
	LDA 102,U
	ANDA #$0F
	ORA #$b0
	STA 102,U
	LDA 22,U
	ANDA #$0F
	ORA #$b0
	STA 22,U
	LDA -58,U
	ANDA #$0F
	ORA #$b0
	STA -58,U
	LEAU -261,U

	LDD 115,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 115,U
	LDD 60,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 60,U
	LDA #$bb
	STA 123,U
	LDA 43,U
	ANDA #$F0
	ORA #$0b
	STA 43,U
	LDA -37,U
	ANDA #$F0
	ORA #$0b
	STA -37,U
	LDA -107,U
	ANDA #$F0
	ORA #$0b
	STA -107,U
	LDA -117,U
	ANDA #$F0
	ORA #$0b
	STA -117,U
	STB 36,U
	STB -44,U
	STB -100,U
	LDD -20,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -20,U
	LDD -124,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -124,U
	LEAU -304,U

	LDA 117,U
	ANDA #$F0
	ORA #$0b
	STA 117,U
	LDA 37,U
	ANDA #$F0
	ORA #$0b
	STA 37,U
	LDA -43,U
	ANDA #$F0
	ORA #$0b
	STA -43,U
	LDA -123,U
	ANDA #$0F
	ORA #$b0
	STA -123,U
	LDA #$99
	STA 124,U
	STA 44,U
	STA 21,U
	STA -59,U
	STA -117,U
	LDD 100,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD 100,U
	LDD -37,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD -37,U
	LEAU -259,U

	LDA #$99
	STA 120,U
	STA 62,U
	STA -18,U
	STA -119,U
	LDA 56,U
	ANDA #$0F
	ORA #$b0
	STA 56,U
	LDA 40,U
	ANDA #$F0
	ORA #$09
	STA 40,U
	LDA -39,U
	ANDA #$0F
	ORA #$90
	STA -39,U
	LDA -98,U
	ANDA #$0F
	ORA #$90
	STA -98,U
	LDA -113,U
	ANDA #$0F
	ORA #$b0
	STA -113,U
	LEAU -306,U

	LDD 127,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD 127,U
	LDA #$99
	STA 107,U
	STA 47,U
	STA 27,U
	STA -33,U
	STA -113,U
	LDA 113,U
	ANDA #$0F
	ORA #$b0
	STA 113,U
	LDA 33,U
	ANDA #$0F
	ORA #$b0
	STA 33,U
	LDA -47,U
	ANDA #$F0
	ORA #$0b
	STA -47,U
	LDA -53,U
	ANDA #$F0
	ORA #$09
	STA -53,U
	LDA -127,U
	ANDA #$F0
	ORA #$0b
	STA -127,U
	LEAU -252,U

	LDA #$99
	STA 40,U
	STA -40,U
	STA -102,U
	STA -120,U
	LDA 120,U
	ANDA #$0F
	ORA #$90
	STA 120,U
	LDA 59,U
	ANDA #$0F
	ORA #$90
	STA 59,U
	LDA 45,U
	ANDA #$F0
	ORA #$0b
	STA 45,U
	LDA -22,U
	ANDA #$F0
	ORA #$09
	STA -22,U
	LDA -27,U
	ANDA #$F0
	ORA #$0b
	STA -27,U
	LDA -107,U
	ANDA #$F0
	ORA #$0b
	STA -107,U
	LDA -116,U
	ANDA #$F0
	ORA #$0a
	STA -116,U
	LEAU -309,U

	LDA #$99
	STA 127,U
	STA 47,U
	LDA 124,U
	ANDA #$0F
	ORA #$a0
	STA 124,U
	LDA 122,U
	ANDA #$F0
	ORA #$0b
	STA 122,U
	LDA 109,U
	ANDA #$F0
	ORA #$09
	STA 109,U
	LDA 30,U
	ANDA #$0F
	ORA #$90
	STA 30,U
	LDA -33,U
	ANDA #$0F
	ORA #$90
	STA -33,U
	LDA -50,U
	ANDA #$0F
	ORA #$90
	STA -50,U
	LDA -113,U
	ANDA #$0F
	ORA #$90
	STA -113,U
	LDD 43,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 43,U
	LDD 32,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 32,U
	STB 113,U
	LDD -36,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -36,U
	LDD -38,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$b00a
	STD -38,U
	LDD -118,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$b00a
	STD -118,U
	LDD #$aaaa
	STD -48,U
	STD -128,U
	STD -116,U
	LEAU -130,U

	LDA #$99
	STA ,U
	LEAU -143,U

	LDD 78,U
	LDA #$aa
	ANDB #$F0
	ORB #$09
	STD 78,U
	LDD 63,U
	LDA #$99
	ANDB #$F0
	ORB #$0a
	STD 63,U
	LDD 76,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 76,U
	LDA 75,U
	ANDA #$0F
	ORA #$b0
	STA 75,U
	LDA -17,U
	ANDA #$F0
	ORA #$09
	STA -17,U
	LDD #$aaaa
	STD 65,U
	STD -15,U
	LDX #$aa99
	PSHU D,X
	LEAU -76,U

	LDA -12,U
	ANDA #$0F
	ORA #$b0
	STA -12,U
	LDD #$aaaa
	STD -15,U
	STD -84,U
	LDD -82,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$a090
	STD -82,U
	LDD #$aaaa
	PSHU D,X
	LEAU -83,U

	LDA -5,U
	ANDA #$0F
	ORA #$b0
	STA -5,U
	LDA -9,U
	ANDA #$0F
	ORA #$90
	STA -9,U
	LDD -75,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$a090
	STD -75,U
	LDD #$aaaa
	STD -8,U
	STD -77,U
	LDA #$bb
	LDX #$bbbb
	PSHU A,X
	LEAU -75,U

	LDD -8,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$a0b0
	STD -8,U
	LDD -81,U
	LDA #$bb
	ANDB #$0F
	ORB #$90
	STD -81,U
	LDA -11,U
	ANDA #$0F
	ORA #$90
	STA -11,U
	LDD #$aaaa
	STD -10,U
	STD -79,U
	LDD #$bbbb
	LDY #$bbbb
	PSHU D,X,Y
	LEAU -75,U

	LDD -8,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -8,U
	LDD -77,U
	LDA #$aa
	ANDB #$F0
	ORB #$09
	STD -77,U
	LDD #$99aa
	STD -10,U
	LDD #$9bbb
	PSHU D,X,Y
	LEAU -71,U

	LDD #$8888
	LDY #$99aa
	PSHU D,X,Y
	LDD -7,U
	LDA #$99
	ANDB #$F0
	ORB #$0a
	STD -7,U
	LDD -74,U
	LDA #$aa
	ANDB #$F0
	ORB #$09
	STD -74,U
	LDX #$a99b
	LDY #$bbb8
	PSHU A,X,Y
	LEAU -69,U

	LDD #$8888
	LDX #$888b
	LDY #$99aa
	PSHU D,X,Y
	LDD -7,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$090a
	STD -7,U
	LDA #$aa
	LDX #$a99b
	LDY #$8888
	PSHU A,X,Y
	LEAU -67,U

	LDD #$8888
	LDX #$99aa
	LDY #$aa99
	PSHU D,X,Y
	LDD #$aaaa
	STD -7,U
	LDD #$8888
	LDX #$8888
	PSHU D,X
	LEAU -70,U

	LDA #$aa
	PSHU A,Y
	LEAU -1,U

	LDB #$aa
	STD -9,U
	LDD -78,U
	LDA #$a9
	ANDB #$0F
	ORB #$90
	STD -78,U
	LDD -82,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -82,U
	LDA #$aa
	STA -79,U
	LDD #$8888
	LDY #$8888
	PSHU D,X,Y
	LEAU -76,U

	LDA -8,U
	ANDA #$0F
	ORA #$90
	STA -8,U
	LDD #$aaaa
	STD -7,U
	LDD -76,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -76,U
	LDD -80,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -80,U
	LDA #$aa
	STA -77,U
	PSHU X,Y
	LEAU -76,U

	PSHU X,Y
	LEAU -1,U

	LDD #$aa99
	STD -72,U
	LDD -74,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$800a
	STD -74,U
	LDA #$99
	LDX #$aaaa
	PSHU A,X
	LEAU -71,U

	LDA #$88
	LDX #$8888
	PSHU A,X,Y
	LEAU -1,U

	LDA #$bb
	STA -70,U
	LDD -73,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -73,U
	LDA #$99
	LDX #$aaaa
	PSHU A,X
	LEAU -71,U

	LDD -8,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -8,U
	LDD -77,U
	ANDA #$F0
	ORA #$08
	LDB #$bb
	STD -77,U
	LDD -79,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -79,U
	LDD -82,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -82,U
	LDD -90,U
	ANDA #$F0
	ORA #$0b
	LDB #$b8
	STD -90,U
	LDA #$99
	STA -9,U
	STY -85,U
	LDA #$aa
	STA -87,U
	LDA #$88
	LDX #$8888
	PSHU A,X,Y
	LEAU -198,U

	LDD 46,U
	ANDA #$F0
	ORA #$08
	LDB #$bb
	STD 46,U
	LDD -37,U
	ANDA #$0F
	ORA #$c0
	LDB #$aa
	STD -37,U
	LDD 44,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 44,U
	LDD 33,U
	LDA #$bb
	ANDB #$F0
	ORB #$08
	STD 33,U
	LDD #$bb88
	STD -47,U
	LDA -32,U
	ANDA #$0F
	ORA #$b0
	STA -32,U
	LDD -35,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$a008
	STD -35,U
	LDA #$aa
	STA 36,U
	STA -44,U
	LEAU -191,U

	LDD 78,U
	ANDA #$0F
	ORA #$80
	LDB #$bb
	STD 78,U
	LDD 64,U
	ANDA #$0F
	ORA #$b0
	LDB #$88
	STD 64,U
	STB 77,U
	STB -15,U
	STB -83,U
	LDA #$aa
	STA 75,U
	STA 67,U
	STA -5,U
	STA -85,U
	LDA -13,U
	ANDA #$F0
	ORA #$0a
	STA -13,U
	LDA -17,U
	ANDA #$F0
	ORA #$0b
	STA -17,U
	LDA -92,U
	ANDA #$0F
	ORA #$a0
	STA -92,U
	LDD -12,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$a0c0
	STD -12,U
	LDD -82,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -82,U
	LDD -95,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -95,U
	LDD -97,U
	LDA #$bb
	ANDB #$F0
	ORB #$08
	STD -97,U
	LDA #$88
	LDX #$88bb
	PSHU A,X
	LEAU -165,U

	LDD #$bb88
	STD -9,U
	STY 5,U
	LDD -7,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -7,U
	LDA 8,U
	ANDA #$0F
	ORA #$b0
	STA 8,U
	LDA 3,U
	ANDA #$0F
	ORA #$a0
	STA 3,U
	LDA -4,U
	ANDA #$0F
	ORA #$a0
	STA -4,U
	LEAU -159,U

	LDD 86,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD 86,U
	LDD -5,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$8008
	STD -5,U
	STY 84,U
	STY -9,U
	LDA 81,U
	ANDA #$F0
	ORA #$08
	STA 81,U
	LDA 3,U
	ANDA #$F0
	ORA #$0c
	STA 3,U
	LDA #$88
	STA -75,U
	LDD 70,U
	ANDA #$0F
	ORA #$b0
	LDB #$88
	STD 70,U
	LDD 6,U
	ANDA #$0F
	ORA #$80
	LDB #$bb
	STD 6,U
	LDD 4,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD 4,U
	LDD 78,U
	LDA #$33
	ANDB #$0F
	ORB #$d0
	STD 78,U
	LDD 75,U
	LDA #$aa
	ANDB #$F0
	ORB #$08
	STD 75,U
	LDD 72,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD 72,U
	LDD ,U
	LDA #$38
	ANDB #$F0
	ORB #$08
	STD ,U
	LDD -74,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -74,U
	LDD -78,U
	LDA #$88
	ANDB #$0F
	ORB #$c0
	STD -78,U
	LDA #$33
	LDX #$3333
	PSHU A,X
	LEAU -76,U

	LDA -12,U
	ANDA #$F0
	ORA #$0b
	STA -12,U
	STY -10,U
	LDD -6,U
	LDA #$88
	ANDB #$F0
	ORB #$03
	STD -6,U
	LDD -75,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -75,U
	LDD -79,U
	LDA #$88
	ANDB #$0F
	ORB #$c0
	STD -79,U
	STA -76,U
	LDD #$3333
	PSHU D,X
	LEAU -75,U

	LDD -11,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -11,U
	LDD -80,U
	LDA #$8c
	ANDB #$0F
	ORB #$c0
	STD -80,U
	LDD #$c888
	STD -8,U
	LDD -13,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0b08
	STD -13,U
	STY -77,U
	LDD #$3333
	LDY #$3338
	PSHU D,X,Y
	LEAU -74,U

	LDD #$cc83
	STD -8,U
	LDD #$3333
	LDY #$3333
	PSHU D,X,Y
	LEAU -4,U

	LDA -64,U
	ANDA #$0F
	ORA #$b0
	STA -64,U
	LDD -67,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -67,U
	LDA #$bb
	LDX #$8888
	PSHU A,X
	LEAU -66,U

	LDD #$3333
	LDX #$3333
	LDY #$33dc
	PSHU D,X,Y
	LDD #$8888
	STD -7,U
	STA -71,U
	LDD -70,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -70,U
	LDA -8,U
	ANDA #$0F
	ORA #$b0
	STA -8,U
	LDA #$cc
	PSHU A,X
	LEAU -71,U

	LDD #$3333
	LDY #$383c
	PSHU D,X,Y
	LDA -8,U
	ANDA #$0F
	ORA #$b0
	STA -8,U
	LDD #$8888
	STD -7,U
	LDA #$cc
	LDX #$3833
	PSHU A,X
	LEAU -65,U

	LDX #$88bb
	PSHU B,X
	LEAU -3,U

	LDA #$88
	STD -13,U
	LDA -9,U
	ANDA #$F0
	ORA #$0d
	STA -9,U
	LDD #$7833
	STD -8,U
	LDD -76,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -76,U
	STA -77,U
	LDD #$3333
	LDX #$3333
	LDY #$9933
	PSHU D,X,Y
	LEAU -74,U

	LDY #$9833
	PSHU D,X,Y
	LDD -7,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -7,U
	LDD -70,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -70,U
	LDD -75,U
	LDA #$33
	ANDB #$0F
	ORB #$d0
	STD -75,U
	LDA -8,U
	ANDA #$F0
	ORA #$08
	STA -8,U
	LDA #$88
	STA -71,U
	LDA #$d3
	LDX #$7733
	PSHU A,X
	LEAU -72,U

	LDD #$7338
	STD -8,U
	LDD -13,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -13,U
	LDA -14,U
	ANDA #$F0
	ORA #$0b
	STA -14,U
	LDD #$8888
	STD -76,U
	LDD #$3333
	LDX #$3333
	LDY #$3338
	PSHU D,X,Y
	LEAU -72,U

	LDY #$337d
	PSHU D,X,Y
	PSHU D,X
	LEAU -3,U

	LDD -65,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -65,U
	LDA #$bb
	LDX #$8888
	PSHU A,X
	LEAU -64,U

	LDA #$33
	PSHU A,Y
	LEAU -1,U

	LDB #$33
	LDX #$3333
	LDY #$3333
	PSHU D,X,Y
	LEAU -3,U

	LDA #$88
	STA -64,U
	LDD -63,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -63,U
	LDA #$bb
	LDX #$8888
	PSHU A,X
	LEAU -64,U

	LDD -5,U
	LDA #$33
	ANDB #$0F
	ORB #$90
	STD -5,U
	LDD -7,U
	LDA #$93
	ANDB #$0F
	ORB #$30
	STD -7,U
	LDA #$33
	LDX #$337d
	PSHU A,X
	LEAU -4,U

	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	LDA -9,U
	ANDA #$0F
	ORA #$b0
	STA -9,U
	LDD #$8888
	STD -8,U
	LDD -69,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -69,U
	LDA #$88
	STA -70,U
	LDA #$33
	LDX #$3337
	PSHU A,X
	LEAU -70,U

	LDD -5,U
	LDA #$33
	ANDB #$F0
	ORB #$07
	STD -5,U
	LDD -7,U
	LDA #$93
	ANDB #$0F
	ORB #$70
	STD -7,U
	LDA #$33
	LDX #$337d
	PSHU A,X
	LEAU -4,U

	LDD #$8888
	STD -8,U
	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	LDA #$33
	LDX #$3337
	PSHU A,X
	LEAU -64,U

	LDX #$88bb
	PSHU B,X
	LEAU -3,U

	LDX #$3377
	PSHU A,X
	LEAU -1,U

	LDA #$dd
	STA -7,U
	STB -73,U
	LDD -11,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -11,U
	LDD -72,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -72,U
	LDD -77,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -77,U
	LDD #$aa33
	LDX #$3333
	LDY #$7733
	PSHU D,X,Y
	LEAU -71,U

	LDD #$3338
	LDY #$3333
	PSHU D,X,Y
	LDD -8,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -8,U
	LDD -69,U
	LDA #$88
	ANDB #$F0
	ORB #$0b
	STD -69,U
	LDD -74,U
	LDA #$a7
	ANDB #$0F
	ORB #$d0
	STD -74,U
	LDA #$88
	STA -70,U
	LDD #$ddaa
	PSHU D,X
	LEAU -70,U

	LDD #$3333
	PSHU D,X,Y
	LDA #$88
	STA -8,U
	LDB #$88
	STD -70,U
	LDA -10,U
	ANDA #$F0
	ORA #$0b
	STA -10,U
	LDD #$d7aa
	PSHU D,X
	LEAU -68,U

	LDD #$3333
	LDY #$a7dd
	PSHU D,X,Y
	LDD -11,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -11,U
	LDD -72,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -72,U
	LDA -12,U
	ANDA #$F0
	ORA #$0b
	STA -12,U
	LDD #$d7aa
	LDY #$3333
	PSHU D,X,Y
	LEAU -68,U

	LDD #$3333
	LDY #$a7dd
	PSHU D,X,Y
	LDD -11,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -11,U
	LDD -72,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -72,U
	LDA -12,U
	ANDA #$F0
	ORA #$0b
	STA -12,U
	LDD #$77aa
	LDY #$3333
	PSHU D,X,Y
	LEAU -68,U

	LDD #$3333
	LDY #$aadd
	PSHU D,X,Y
	LDA -12,U
	ANDA #$0F
	ORA #$b0
	STA -12,U
	LDD #$8888
	STD -11,U
	LDD -72,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -72,U
	LDD #$77aa
	LDY #$3333
	PSHU D,X,Y
	LEAU -68,U

	LDD #$3333
	LDY #$aa7d
	PSHU D,X,Y
	LDD #$8888
	STD -11,U
	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDA -12,U
	ANDA #$0F
	ORA #$b0
	STA -12,U
	LDA -69,U
	ANDA #$0F
	ORA #$b0
	STA -69,U
	STB -71,U
	LDD #$77a3
	LDY #$3333
	PSHU D,X,Y
	LEAU -68,U

	LDD #$3333
	LDY #$aa7d
	PSHU D,X,Y
	LDD -70,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -70,U
	LDD #$8888
	STD -11,U
	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDA -12,U
	ANDA #$0F
	ORA #$b0
	STA -12,U
	STB -71,U
	LDD #$77a3
	LDY #$3333
	PSHU D,X,Y
	LEAU -68,U

	LDA #$33
	LDY #$aa77
	PSHU A,X,Y
	LEAU -2,U

	LDD #$8888
	STD -10,U
	LDD -69,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -69,U
	LDA #$88
	STA -70,U
	LDD #$dd7a
	LDX #$a333
	LDY #$3333
	PSHU D,X,Y
	LEAU -67,U

	LDA #$33
	LDX #$3333
	LDY #$aa77
	PSHU A,X,Y
	LEAU -3,U

	LDD #$8888
	STD -9,U
	LDD -68,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$800b
	STD -68,U
	LDA #$88
	STA -69,U
	LDD -73,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -73,U
	LDA #$d7
	LDX #$7a33
	LDY #$3333
	PSHU A,X,Y
	LEAU -68,U

	LDD -9,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -9,U
	LDX #$33aa
	PSHU A,X
	LEAU -6,U

	LDA #$88
	STA -67,U
	LDD -66,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$800b
	STD -66,U
	LDD #$8888
	STD -7,U
	LDD -71,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -71,U
	LDX #$aa33
	PSHU A,X
	LEAU -68,U

	LDA #$33
	LDX #$33aa
	PSHU A,X
	LEAU -5,U

	LDA #$88
	STA -68,U
	LDD -67,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$800b
	STD -67,U
	LDD -8,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -8,U
	LDD -72,U
	LDA #$a7
	ANDB #$0F
	ORB #$70
	STD -72,U
	LDD #$333a
	STD -74,U
	LDA -75,U
	ANDA #$F0
	ORA #$03
	STA -75,U
	LDD #$77aa
	PSHU D,Y
	LEAU -76,U

	LDD -8,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -8,U
	LDD #$8888
	STD -68,U
	LDD #$77aa
	PSHU D,Y
	LEAU -66,U

	LDD #$333a
	LDX #$a777
	PSHU D,X
	LEAU -6,U

	LDD -8,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -8,U
	LDD #$bbbb
	STD -63,U
	LDD #$8888
	STD -68,U
	LDA -64,U
	ANDA #$F0
	ORA #$0b
	STA -64,U
	LDD #$77aa
	PSHU D,Y
	LEAU -66,U

	LDD -12,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -12,U
	LDD #$333a
	PSHU D,X
	LEAU -8,U

	LDD -6,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -6,U
	LDA -8,U
	ANDA #$F0
	ORA #$0b
	STA -8,U
	LDD #$bbbb
	STD -11,U
	LDA #$88
	LDX #$77aa
	PSHU A,X
	LEAU -56,U

	LDB #$88
	STD -7,U
	LDD -10,U
	LDA #$77
	ANDB #$0F
	ORB #$80
	STD -10,U
	LDD #$bbbb
	LDX #$bbbb
	PSHU D,X
	LEAU -6,U

	LDD -11,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -11,U
	LDD #$3333
	LDX #$33aa
	PSHU D,X
	LEAU -7,U

	LDD -6,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -6,U
	LDX #$77aa
	PSHU A,X
	LEAU -4,U

	LDD #$bbbb
	LDX #$bbbb
	PSHU D,X
	LEAU -48,U

	LDA #$88
	STA -7,U
	LDB #$cc
	LDY #$bbbb
	PSHU D,X,Y
	LEAU -2,U

	LDD -12,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -12,U
	LDD #$3333
	LDX #$33aa
	LDY #$7788
	PSHU D,X,Y
	LEAU -6,U

	LDD -8,U
	ANDA #$0F
	ORA #$c0
	LDB #$88
	STD -8,U
	LDD -6,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$8008
	STD -6,U
	LDD #$8877
	LDX #$aa33
	PSHU D,X
	LEAU -4,U

	LDD #$bbbb
	LDX #$bbbb
	PSHU D,X
	LEAU -50,U

	LDD -6,U
	ANDA #$0F
	ORA #$80
	LDB #$88
	STD -6,U
	LDA #$cc
	PSHU A,X
	LEAU -3,U

	LDD -12,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -12,U
	LDD #$3333
	LDX #$33aa
	PSHU D,X,Y
	LEAU -6,U

	LDD -7,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -7,U
	LDX #$887a
	LDY #$a333
	PSHU A,X,Y
	LEAU -2,U

	LDA -4,U
	ANDA #$F0
	ORA #$0b
	STA -4,U
	LDA -58,U
	ANDA #$0F
	ORA #$c0
	STA -58,U
	LDA #$bb
	LDX #$bbcc
	PSHU A,X
	LEAU -56,U

	LDD #$3333
	STD -8,U
	LDB #$aa
	LDX #$7788
	LDY #$8888
	PSHU D,X,Y
	LEAU -8,U

	LDA #$cc
	STA -8,U
	LDD #$8888
	LDX #$88aa
	LDY #$a333
	PSHU D,X,Y
	LEAU -61,U

	LDA -8,U
	ANDA #$0F
	ORA #$30
	STA -8,U
	LDA -11,U
	ANDA #$0F
	ORA #$30
	STA -11,U
	LDD #$3333
	LDX #$aaa7
	LDY #$8888
	PSHU D,X,Y
	LEAU -7,U

	LDA -9,U
	ANDA #$0F
	ORA #$90
	STA -9,U
	LDD #$8888
	LDX #$87aa
	LDY #$3333
	PSHU D,X,Y
	LEAU -61,U

	LDA #$33
	STA -8,U
	STA -11,U
	LDA -6,U
	ANDA #$F0
	ORA #$03
	STA -6,U
	LDA #$33
	LDX #$aaa7
	LDY #$8888
	PSHU A,X,Y
	LEAU -8,U

	LDB #$3a
	STD -72,U
	LDD -69,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -69,U
	LDD -78,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -78,U
	LDD -84,U
	LDA #$87
	ANDB #$F0
	ORB #$0a
	STD -84,U
	LDA -9,U
	ANDA #$0F
	ORA #$90
	STA -9,U
	LDA -73,U
	ANDA #$F0
	ORA #$03
	STA -73,U
	LDA -89,U
	ANDA #$0F
	ORA #$90
	STA -89,U
	LDA #$33
	STA -75,U
	LDD #$3333
	STD -82,U
	LDA #$88
	STA -85,U
	LDX #$87aa
	LDY #$3333
	PSHU A,X,Y
	LEAU -145,U

	LDA -5,U
	ANDA #$0F
	ORA #$30
	STA -5,U
	LDD ,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD ,U
	LDD -8,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -8,U
	LDX #$333a
	PSHU B,X
	LEAU -7,U

	LDA -9,U
	ANDA #$0F
	ORA #$90
	STA -9,U
	LDA #$88
	LDX #$8799
	PSHU A,X,Y
	LEAU -63,U

	STB -9,U
	STY -14,U
	LDD -16,U
	LDA #$37
	ANDB #$F0
	ORB #$08
	STD -16,U
	LDA -17,U
	ANDA #$F0
	ORA #$08
	STA -17,U
	LDA -21,U
	ANDA #$0F
	ORA #$90
	STA -21,U
	LDD -82,U
	ANDA #$0F
	ORA #$90
	LDB #$38
	STD -82,U
	LDA #$33
	LDX #$3333
	LDY #$7788
	PSHU A,X,Y
	LEAU -77,U

	LDA -7,U
	ANDA #$F0
	ORA #$03
	STA -7,U
	STX -12,U
	LDD -14,U
	LDA #$37
	ANDB #$F0
	ORB #$08
	STD -14,U
	LDD -80,U
	ANDA #$0F
	ORA #$90
	LDB #$33
	STD -80,U
	PSHU B,X
	LEAU -77,U

	LDD -14,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -14,U
	STX -12,U
	PSHU A,X
	LEAU -75,U

	LDY #$3333
	PSHU A,X,Y
	LEAU -7,U

	LDA -5,U
	ANDA #$F0
	ORA #$03
	STA -5,U
	PSHU X,Y
	LEAU -64,U

	LDA -5,U
	ANDA #$F0
	ORA #$03
	STA -5,U
	PSHU X,Y
	LEAU -8,U

	LDD -66,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -66,U
	LDD -69,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -69,U
	PSHU A,X,Y
	LEAU -64,U

	LDA -4,U
	ANDA #$F0
	ORA #$03
	STA -4,U
	LDA #$33
	PSHU A,X
	LEAU -8,U

	LDD -9,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -9,U
	LDA #$33
	PSHU A,X,Y
	LEAU -58,U

	LDX #$8899
	PSHU B,X
	LEAU -1,U

	LDA -6,U
	ANDA #$F0
	ORA #$03
	STA -6,U
	LDA #$33
	LDX #$3333
	PSHU A,X,Y
	LEAU -8,U

	LDD -7,U
	LDA #$88
	ANDB #$F0
	ORB #$03
	STD -7,U
	LDA #$33
	PSHU A,X,Y
	LEAU -2,U

	LDA #$99
	LDX #$8888
	PSHU A,X
	LEAU -52,U

	LDD #$3338
	LDX #$9988
	LDY #$9999
	PSHU D,X,Y
	LDB #$33
	LDX #$3333
	PSHU D,X
	LEAU -8,U

	LDY #$3333
	PSHU D,X,Y
	LDA #$99
	LDX #$9988
	LDY #$9988
	PSHU A,X,Y
	LEAU -50,U

	LDD #$3399
	LDX #$9979
	LDY #$9999
	PSHU D,X,Y
	LDX #$3333
	LDY #$3333
	PSHU A,X,Y
	LEAU -8,U

	LDB #$33
	PSHU D,X,Y
	LDD #$9999
	LDX #$9988
	LDY #$9999
	PSHU D,X,Y
	LEAU -48,U

	LDX #$8799
	PSHU D,X,Y
	LDD #$3333
	LDX #$3333
	LDY #$3338
	PSHU D,X,Y
	LEAU -8,U

	LDY #$3333
	PSHU D,X,Y
	LDD #$9999
	LDX #$9989
	LDY #$9999
	PSHU D,X,Y
	RTS
