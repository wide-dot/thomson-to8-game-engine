	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_tk_021_0
	LEAU 2086,U

	LDA 120,U
	ANDA #$0F
	ORA #$80
	STA 120,U
	LDA 40,U
	ANDA #$0F
	ORA #$80
	STA 40,U
	LDA -40,U
	ANDA #$F0
	ORA #$08
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$08
	STA -120,U
	LEAU -404,U

	LDA 120,U
	ANDA #$0F
	ORA #$c0
	STA 120,U
	LDA 45,U
	ANDA #$0F
	ORA #$80
	STA 45,U
	LDA -39,U
	ANDA #$0F
	ORA #$c0
	STA -39,U
	LDA -113,U
	ANDA #$0F
	ORA #$c0
	STA -113,U
	LDA #$cc
	STA 40,U
	STA -119,U
	LDA #$88
	STA -35,U
	STA -115,U
	LEAU -272,U

	LDD 78,U
	LDA #$88
	ANDB #$0F
	ORB #$c0
	STD 78,U
	LDD 73,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 73,U
	LDA 69,U
	ANDA #$F0
	ORA #$08
	STA 69,U
	LDA -10,U
	ANDA #$0F
	ORA #$80
	STA -10,U
	LDD #$cc88
	STD 76,U
	LDB #$cc
	LDX #$cc88
	LDY #$88cc
	PSHU D,X,Y
	LEAU -74,U

	LDD #$cddd
	STD -6,U
	LDA #$88
	STA -89,U
	STY -82,U
	LDD -84,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$d007
	STD -84,U
	LDD -86,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -86,U
	LDA #$77
	STA -87,U
	LDA -10,U
	ANDA #$F0
	ORA #$08
	STA -10,U
	LDA #$c8
	PSHU A,Y
	LEAU -236,U

	LDD 78,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 78,U
	LDD 76,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD 76,U
	LDD 70,U
	ANDA #$F0
	ORA #$08
	LDB #$87
	STD 70,U
	LDD -82,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -82,U
	LDD #$dddd
	STD 74,U
	LDD #$7777
	STD -9,U
	LDD #$dddd
	LDX #$dd77
	LDY #$cccc
	PSHU D,X,Y
	LEAU -76,U

	LDD -6,U
	LDA #$77
	ANDB #$0F
	ORB #$a0
	STD -6,U
	LDA -7,U
	ANDA #$0F
	ORA #$d0
	STA -7,U
	LDA #$cc
	STA -79,U
	LDD #$dddd
	LDX #$ddaa
	PSHU D,X
	LEAU -76,U

	LDD -5,U
	LDA #$aa
	ANDB #$0F
	ORB #$70
	STD -5,U
	LDD -79,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -79,U
	LDD -84,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -84,U
	STA -6,U
	LDA #$7a
	STA -85,U
	LDA -8,U
	ANDA #$F0
	ORA #$0d
	STA -8,U
	LDD -81,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$70d0
	STD -81,U
	LDA #$dd
	STA -88,U
	PSHU A,X
	LEAU -154,U

	LDD #$77a7
	STD -8,U
	LDA -5,U
	ANDA #$F0
	ORA #$0d
	STA -5,U
	LDA -11,U
	ANDA #$0F
	ORA #$d0
	STA -11,U
	LDA #$7d
	PSHU A,Y
	LEAU -77,U

	LDD -7,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -7,U
	STA -8,U
	LDA -12,U
	ANDA #$F0
	ORA #$0d
	STA -12,U
	LDA -83,U
	ANDA #$F0
	ORA #$0d
	STA -83,U
	LDD #$ddcc
	STD -82,U
	LDD #$7777
	STD -87,U
	LDA #$dd
	STA -92,U
	LDD -89,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0770
	STD -89,U
	LDA #$dd
	LDX #$dccc
	PSHU A,X
	LEAU -284,U

	LDD 126,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 126,U
	LDD 46,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 46,U
	LDD 42,U
	LDA #$7d
	ANDB #$F0
	ORB #$07
	STD 42,U
	LDA 125,U
	ANDA #$F0
	ORA #$0d
	STA 125,U
	LDA -38,U
	ANDA #$0F
	ORA #$70
	STA -38,U
	LDA -42,U
	ANDA #$0F
	ORA #$70
	STA -42,U
	LDA -45,U
	ANDA #$0F
	ORA #$d0
	STA -45,U
	LDA -123,U
	ANDA #$F0
	ORA #$07
	STA -123,U
	LDA -126,U
	ANDA #$F0
	ORA #$0d
	STA -126,U
	LDA #$d7
	STA 123,U
	LDA #$dd
	STA 115,U
	STA 35,U
	LDA #$77
	STA 121,U
	STA 118,U
	STA 41,U
	STA 38,U
	STY -34,U
	LDD -114,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -114,U
	LEAU -320,U

	LDD 122,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD 122,U
	LDD 126,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD 126,U
	LDA #$77
	STA 117,U
	STA 37,U
	STA -43,U
	STA -123,U
	LDA #$dd
	STA 114,U
	STA 34,U
	STA -46,U
	STA -126,U
	STB 47,U
	STB -33,U
	STB -113,U
	LDB #$77
	STD 42,U
	LDA -38,U
	ANDA #$0F
	ORA #$d0
	STA -38,U
	LDA -118,U
	ANDA #$0F
	ORA #$d0
	STA -118,U
	LEAU -277,U

	LDD 83,U
	ANDA #$F0
	ORA #$0d
	LDB #$cc
	STD 83,U
	LDD 80,U
	ANDA #$0F
	ORA #$70
	LDB #$77
	STD 80,U
	LDD 78,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0707
	STD 78,U
	LDD #$dddd
	STD 2,U
	LDA 71,U
	ANDA #$0F
	ORA #$d0
	STA 71,U
	LDA -6,U
	ANDA #$0F
	ORA #$70
	STA -6,U
	LDA -9,U
	ANDA #$0F
	ORA #$d0
	STA -9,U
	LDD 4,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 4,U
	LDD ,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD ,U
	LDD -76,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -76,U
	LDA #$77
	STA 74,U
	LDA #$dd
	STA -77,U
	LDA #$77
	LDX #$77a3
	PSHU A,X
	LEAU -75,U

	LDA #$dd
	STA -79,U
	LDD -78,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -78,U
	LDA -8,U
	ANDA #$0F
	ORA #$70
	STA -8,U
	LDA -11,U
	ANDA #$0F
	ORA #$d0
	STA -11,U
	LDD #$7777
	LDX #$7a33
	LDY #$3333
	PSHU D,X,Y
	LEAU -74,U

	LDD -6,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -6,U
	LDD -78,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -78,U
	LDD #$7777
	STD -8,U
	LDA -12,U
	ANDA #$F0
	ORA #$0d
	STA -12,U
	LDD #$3333
	PSHU D,Y
	LEAU -74,U

	LDA #$aa
	STA -7,U
	LDD -10,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -10,U
	LDD -80,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -80,U
	LDA #$77
	STA -11,U
	LDA -14,U
	ANDA #$F0
	ORA #$0d
	STA -14,U
	LDD #$3333
	LDX #$3333
	LDY #$777d
	PSHU D,X,Y
	LEAU -74,U

	STA -7,U
	LDD -12,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD -12,U
	LDA -14,U
	ANDA #$F0
	ORA #$0d
	STA -14,U
	LDD #$3333
	LDX #$3338
	LDY #$a777
	PSHU D,X,Y
	LEAU -72,U

	LDD -7,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -7,U
	LDD -5,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0730
	STD -5,U
	LDA #$77
	LDX #$8ccc
	PSHU A,X
	LEAU -4,U

	LDD -9,U
	LDA #$d7
	ANDB #$0F
	ORB #$70
	STD -9,U
	LDA #$aa
	LDX #$3333
	PSHU A,X
	LEAU -70,U

	LDD -8,U
	LDA #$33
	ANDB #$F0
	ORB #$08
	STD -8,U
	LDA -11,U
	ANDA #$F0
	ORA #$03
	STA -11,U
	STX -10,U
	LDD -17,U
	ANDA #$0F
	ORA #$80
	LDB #$77
	STD -17,U
	LDD #$3377
	LDX #$88cc
	PSHU D,X
	LEAU -76,U

	LDA -4,U
	ANDA #$0F
	ORA #$70
	STA -4,U
	LDA -12,U
	ANDA #$0F
	ORA #$90
	STA -12,U
	LDD -7,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0780
	STD -7,U
	LDD -9,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -9,U
	LDD #$3333
	STD -11,U
	LDA #$77
	STA -16,U
	LDX #$888c
	PSHU A,X
	LEAU -77,U

	LDD -9,U
	ANDA #$F0
	ORA #$07
	LDB #$33
	STD -9,U
	LDA -4,U
	ANDA #$0F
	ORA #$90
	STA -4,U
	LDA -6,U
	ANDA #$0F
	ORA #$70
	STA -6,U
	LDA #$88
	LDX #$8888
	PSHU A,X
	LEAU -6,U

	LDA #$77
	STA -7,U
	LDA -4,U
	ANDA #$F0
	ORA #$08
	STA -4,U
	LDA #$99
	LDX #$3333
	PSHU A,X
	LEAU -68,U

	LDA #$77
	STA -16,U
	LDA #$98
	STD -12,U
	LDA -4,U
	ANDA #$0F
	ORA #$80
	STA -4,U
	LDA -8,U
	ANDA #$F0
	ORA #$03
	STA -8,U
	LDA #$89
	LDX #$8888
	PSHU A,X
	LEAU -77,U

	LDA -8,U
	ANDA #$F0
	ORA #$07
	STA -8,U
	LDD -13,U
	ANDA #$0F
	ORA #$30
	LDB #$88
	STD -13,U
	LDA #$77
	STA -16,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	LDA #$78
	STA -8,U
	LDA -5,U
	ANDA #$0F
	ORA #$70
	STA -5,U
	LDA #$77
	PSHU A,X
	LEAU -8,U

	STA -5,U
	LDA #$33
	LDX #$3888
	PSHU A,X
	LEAU -66,U

	LDA -5,U
	ANDA #$0F
	ORA #$90
	STA -5,U
	LDA -85,U
	ANDA #$0F
	ORA #$80
	STA -85,U
	LDA #$78
	STA -8,U
	LDA #$77
	STA -16,U
	STA -96,U
	LDD -13,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$3090
	STD -13,U
	LDD -15,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -15,U
	LDD -82,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -82,U
	LDD -95,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -95,U
	LDA #$37
	STA -87,U
	LDA #$89
	STA -83,U
	LDA #$78
	LDX #$8888
	PSHU A,X
	LEAU -206,U

	LDA #$88
	STA 48,U
	STA -32,U
	LDA #$37
	STA 42,U
	LDA #$33
	STA -38,U
	LDD 33,U
	LDA #$73
	ANDB #$0F
	ORB #$30
	STD 33,U
	LDD -48,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -48,U
	LEAU -206,U

	LDD #$8833
	STD -84,U
	STB 88,U
	LDA #$38
	STA 14,U
	LDA 84,U
	ANDA #$0F
	ORA #$90
	STA 84,U
	LDA 77,U
	ANDA #$F0
	ORA #$08
	STA 77,U
	LDA -66,U
	ANDA #$0F
	ORA #$30
	STA -66,U
	LDD #$3333
	STD 78,U
	LDD 3,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD 3,U
	LDD -77,U
	ANDA #$F0
	ORA #$07
	LDB #$98
	STD -77,U
	LDD -82,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -82,U
	LDA #$88
	STA 94,U
	STA 11,U
	LDA #$89
	STA -69,U
	LDA #$83
	LDX #$3333
	PSHU A,X
	LEAU -158,U

	LDA #$33
	STA 15,U
	LDD 11,U
	ANDA #$0F
	ORA #$30
	LDB #$99
	STD 11,U
	LDD 4,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD 4,U
	LDD -69,U
	ANDA #$0F
	ORA #$30
	LDB #$77
	STD -69,U
	LDD -76,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -76,U
	LDA 10,U
	ANDA #$F0
	ORA #$03
	STA 10,U
	LDA -70,U
	ANDA #$F0
	ORA #$03
	STA -70,U
	LDD -65,U
	LDA #$33
	ANDB #$0F
	ORB #$80
	STD -65,U
	LDD #$8833
	PSHU D,X
	LEAU -77,U

	LDA -4,U
	ANDA #$F0
	ORA #$08
	STA -4,U
	LDA -65,U
	ANDA #$F0
	ORA #$03
	STA -65,U
	LDA -74,U
	ANDA #$0F
	ORA #$90
	STA -74,U
	LDD #$8833
	STD -84,U
	LDA #$78
	STA -67,U
	LDD -64,U
	LDA #$33
	ANDB #$0F
	ORB #$80
	STD -64,U
	LDD -82,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -82,U
	LDA #$83
	PSHU A,X
	LEAU -158,U

	LDA #$33
	STA 16,U
	STA -66,U
	LDD 17,U
	LDA #$33
	ANDB #$F0
	ORB #$08
	STD 17,U
	LDD -82,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -82,U
	LDA #$89
	STA 14,U
	LDA #$88
	STA -72,U
	STX -64,U
	LDD #$8333
	STD -84,U
	LDA -85,U
	ANDA #$F0
	ORA #$08
	STA -85,U
	LDD #$8833
	PSHU D,X
	LEAU -157,U

	LDA #$89
	STA 9,U
	LDA 17,U
	ANDA #$F0
	ORA #$03
	STA 17,U
	LDA -67,U
	ANDA #$F0
	ORA #$08
	STA -67,U
	LDA -69,U
	ANDA #$F0
	ORA #$08
	STA -69,U
	LDD 14,U
	ANDA #$0F
	ORA #$90
	LDB #$33
	STD 14,U
	LDD 18,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 18,U
	LDD -66,U
	LDA #$99
	ANDB #$F0
	ORB #$03
	STD -66,U
	STX -62,U
	STX -83,U
	STA -71,U
	LDA #$33
	PSHU A,X
	LEAU -261,U

	LDA 124,U
	ANDA #$0F
	ORA #$30
	STA 124,U
	LDA 44,U
	ANDA #$F0
	ORA #$08
	STA 44,U
	LDA -38,U
	ANDA #$F0
	ORA #$03
	STA -38,U
	LDA -118,U
	ANDA #$F0
	ORA #$03
	STA -118,U
	LDA -122,U
	ANDA #$0F
	ORA #$90
	STA -122,U
	LDA #$33
	STA 122,U
	STA 42,U
	STA 21,U
	STA -59,U
	LDD 117,U
	ANDA #$F0
	ORA #$07
	LDB #$98
	STD 117,U
	LDD 37,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD 37,U
	LDD -43,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -43,U
	LDD 115,U
	LDA #$88
	ANDB #$0F
	ORB #$90
	STD 115,U
	LDD 35,U
	LDA #$79
	ANDB #$0F
	ORB #$80
	STD 35,U
	LDD -45,U
	LDA #$77
	ANDB #$0F
	ORB #$80
	STD -45,U
	LDD -125,U
	LDA #$87
	ANDB #$0F
	ORB #$80
	STD -125,U
	STX 101,U
	LDA #$77
	STA 113,U
	LDA #$78
	STA 33,U
	LDA #$89
	STA -47,U
	LEAU -209,U

	LDA 11,U
	ANDA #$F0
	ORA #$03
	STA 11,U
	LDA 4,U
	ANDA #$F0
	ORA #$08
	STA 4,U
	LDA #$33
	STA -11,U
	LEAU -308,U

	LDA ,U
	ANDA #$0F
	ORA #$a0
	STA ,U

	LDU <glb_screen_location_1
	LEAU 1765,U

	LDA #$cc
	STA -123,U
	LDA #$88
	STA 41,U
	STA -39,U
	LDA 123,U
	ANDA #$F0
	ORA #$0c
	STA 123,U
	LDA 121,U
	ANDA #$0F
	ORA #$80
	STA 121,U
	LDA 116,U
	ANDA #$0F
	ORA #$c0
	STA 116,U
	LDA 43,U
	ANDA #$F0
	ORA #$0c
	STA 43,U
	LDA 36,U
	ANDA #$F0
	ORA #$0c
	STA 36,U
	LDA -37,U
	ANDA #$F0
	ORA #$0c
	STA -37,U
	LDA -43,U
	ANDA #$0F
	ORA #$c0
	STA -43,U
	LDA -117,U
	ANDA #$F0
	ORA #$0c
	STA -117,U
	LDA -119,U
	ANDA #$F0
	ORA #$08
	STA -119,U
	LEAU -202,U

	LDD -1,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0cc0
	STD -1,U
	LDA 3,U
	ANDA #$F0
	ORA #$08
	STA 3,U
	LDA -5,U
	ANDA #$F0
	ORA #$08
	STA -5,U
	LDD 4,U
	LDA #$88
	ANDB #$F0
	ORB #$0c
	STD 4,U
	LEAU -154,U

	LDA -10,U
	ANDA #$F0
	ORA #$08
	STA -10,U
	LDA -86,U
	ANDA #$F0
	ORA #$0c
	STA -86,U
	LDD 76,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD 76,U
	LDD -83,U
	ANDA #$F0
	ORA #$0c
	LDB #$88
	STD -83,U
	LDA #$cc
	STA 74,U
	LDD 78,U
	LDA #$88
	ANDB #$F0
	ORB #$0c
	STD 78,U
	LDD -81,U
	LDA #$8c
	ANDB #$0F
	ORB #$c0
	STD -81,U
	LDD -85,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -85,U
	LDA #$88
	STA -89,U
	LDD #$cccc
	LDX #$cccc
	LDY #$888c
	PSHU D,X,Y
	LEAU -153,U

	LDD -10,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0880
	STD -10,U
	LDD #$dddd
	STD -6,U
	LDA #$77
	LDX #$88cc
	PSHU A,X
	LEAU -77,U

	LDD -5,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -5,U
	LDD #$8877
	STD -9,U
	LDA #$dd
	STA -6,U
	PSHU B,X
	LEAU -77,U

	LDB #$dd
	STD -85,U
	LDD -9,U
	ANDA #$F0
	ORA #$0d
	LDB #$77
	STD -9,U
	LDD -81,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -81,U
	LDA #$77
	STA -82,U
	LDD -7,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$700d
	STD -7,U
	LDA #$dd
	LDX #$dd77
	LDY #$77cc
	PSHU A,X,Y
	LEAU -81,U

	LDX #$7777
	PSHU A,X
	LEAU -70,U

	LDD -5,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -5,U
	LDA #$77
	LDX #$cccc
	PSHU A,X
	LEAU -2,U

	LDD #$dccc
	STD -77,U
	LDA -5,U
	ANDA #$0F
	ORA #$d0
	STA -5,U
	LDA #$7a
	LDX #$77dd
	PSHU A,X
	LEAU -77,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDD -77,U
	ANDA #$0F
	ORA #$d0
	LDB #$cc
	STD -77,U
	LDD #$dd77
	STD -79,U
	LDA #$7a
	STD -82,U
	LDA #$dd
	STA -86,U
	LDX #$a777
	PSHU B,X
	LEAU -158,U

	LDD 5,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 5,U
	LDA #$7d
	STA 4,U
	LDA -2,U
	ANDA #$F0
	ORA #$07
	STA -2,U
	LDD #$7777
	STD -1,U
	LDA #$dd
	STA -5,U
	LEAU -157,U

	LDD #$cccc
	STD 82,U
	LDA 79,U
	ANDA #$F0
	ORA #$0d
	STA 79,U
	LDA 72,U
	ANDA #$0F
	ORA #$d0
	STA 72,U
	LDA -5,U
	ANDA #$0F
	ORA #$70
	STA -5,U
	LDA -9,U
	ANDA #$F0
	ORA #$0d
	STA -9,U
	LDD 80,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD 80,U
	LDD ,U
	LDA #$77
	ANDB #$F0
	ORB #$0d
	STD ,U
	STA 77,U
	STA 75,U
	LDD #$dccc
	STD 2,U
	LDD -78,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -78,U
	LDA #$77
	LDX #$77dd
	PSHU A,X
	LEAU -76,U

	LDA -7,U
	ANDA #$F0
	ORA #$07
	STA -7,U
	LDD -82,U
	ANDA #$0F
	ORA #$d0
	LDB #$77
	STD -82,U
	LDA #$cc
	STA -78,U
	LDA #$dd
	STA -10,U
	STA -90,U
	STB -83,U
	STB -87,U
	LDX #$dd77
	PSHU B,X
	LEAU -282,U

	LDA #$cc
	STA 127,U
	STB 118,U
	LDD 123,U
	ANDA #$0F
	ORA #$70
	LDB #$77
	STD 123,U
	LDA #$dd
	STA 115,U
	STA 35,U
	LDD 47,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 47,U
	LDD 43,U
	LDA #$77
	ANDB #$F0
	ORB #$07
	STD 43,U
	LDD -33,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -33,U
	LDA 38,U
	ANDA #$0F
	ORA #$70
	STA 38,U
	LDA -36,U
	ANDA #$F0
	ORA #$07
	STA -36,U
	LDA -38,U
	ANDA #$F0
	ORA #$0d
	STA -38,U
	LDA -42,U
	ANDA #$0F
	ORA #$70
	STA -42,U
	LDA -45,U
	ANDA #$0F
	ORA #$d0
	STA -45,U
	LDA -118,U
	ANDA #$F0
	ORA #$0d
	STA -118,U
	LDA -123,U
	ANDA #$F0
	ORA #$07
	STA -123,U
	LDA -126,U
	ANDA #$F0
	ORA #$0d
	STA -126,U
	LDD #$cccc
	STD -113,U
	LEAU -199,U

	LDD 6,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD 6,U
	LDA -4,U
	ANDA #$F0
	ORA #$07
	STA -4,U
	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDA #$dd
	STA 1,U
	LEAU -152,U

	LDA #$dc
	STD 78,U
	LDA #$77
	STA 74,U
	STA -8,U
	STA -12,U
	LDA 68,U
	ANDA #$F0
	ORA #$07
	STA 68,U
	LDA 65,U
	ANDA #$F0
	ORA #$0d
	STA 65,U
	LDD #$3333
	STD -6,U
	LDA #$dd
	STA -15,U
	LDX #$dccc
	PSHU A,X
	LEAU -77,U

	LDX #$ddcc
	PSHU A,X
	LEAU -1,U

	LDD -80,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$a00d
	STD -80,U
	LDA #$dd
	STA -11,U
	STX -78,U
	LDA #$77
	STA -8,U
	LDD #$7777
	LDX #$7733
	LDY #$3333
	PSHU D,X,Y
	LEAU -74,U

	LDD -5,U
	LDA #$77
	ANDB #$F0
	ORB #$03
	STD -5,U
	LDA #$33
	PSHU A,Y
	LEAU -2,U

	LDA #$dd
	STA -6,U
	LDA #$77
	LDX #$7777
	PSHU A,X
	LEAU -68,U

	LDD -5,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -5,U
	LDA #$77
	LDX #$ddcc
	PSHU A,X
	LEAU -2,U

	LDD #$7777
	STD -7,U
	LDA #$dd
	STA -10,U
	LDA -8,U
	ANDA #$F0
	ORA #$07
	STA -8,U
	LDA #$33
	LDX #$8333
	PSHU A,X
	LEAU -72,U

	LDA #$aa
	STA -9,U
	LDD -8,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -8,U
	STY -6,U
	LDA #$77
	LDX #$7dcc
	PSHU A,X
	LEAU -9,U

	LDA #$dd
	LDX #$7777
	PSHU A,X
	LEAU -65,U

	LDD -6,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$3030
	STD -6,U
	LDA #$77
	LDX #$77cc
	PSHU A,X
	LEAU -3,U

	LDA -4,U
	ANDA #$F0
	ORA #$08
	STA -4,U
	LDA -79,U
	ANDA #$F0
	ORA #$08
	STA -79,U
	LDA -89,U
	ANDA #$0F
	ORA #$70
	STA -89,U
	LDA -91,U
	ANDA #$F0
	ORA #$08
	STA -91,U
	LDD -78,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0307
	STD -78,U
	LDD #$778c
	STD -76,U
	STA -9,U
	LDA #$33
	STA -81,U
	STY -84,U
	PSHU A,Y
	LEAU -157,U

	LDD 5,U
	LDA #$88
	ANDB #$0F
	ORB #$c0
	STD 5,U
	LDD -75,U
	LDA #$88
	ANDB #$0F
	ORB #$c0
	STD -75,U
	LDA #$77
	STA 4,U
	LDA #$78
	STA -78,U
	LDD 1,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0707
	STD 1,U
	LDA #$97
	STA -76,U
	LDA -9,U
	ANDA #$0F
	ORA #$70
	STA -9,U
	LDA -12,U
	ANDA #$0F
	ORA #$80
	STA -12,U
	LDD #$8833
	LDX #$3333
	LDY #$8933
	PSHU D,X,Y
	LEAU -74,U

	LDA -9,U
	ANDA #$0F
	ORA #$70
	STA -9,U
	LDA -81,U
	ANDA #$0F
	ORA #$30
	STA -81,U
	LDD -75,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -75,U
	LDD -77,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD -77,U
	LDA #$78
	STA -78,U
	LDD #$8933
	LDY #$8833
	PSHU D,X,Y
	LEAU -77,U

	LDA -6,U
	ANDA #$0F
	ORA #$70
	STA -6,U
	LDA -78,U
	ANDA #$0F
	ORA #$70
	STA -78,U
	LDA -86,U
	ANDA #$0F
	ORA #$70
	STA -86,U
	LDD -72,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -72,U
	LDD -74,U
	ANDA #$F0
	ORA #$07
	LDB #$98
	STD -74,U
	LDA #$33
	STA -82,U
	STA -84,U
	LDA #$99
	PSHU A,X
	LEAU -239,U

	LDD 90,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD 90,U
	LDD 78,U
	LDA #$33
	ANDB #$F0
	ORB #$08
	STD 78,U
	LDA #$88
	STA 89,U
	LDD 8,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD 8,U
	LDD -70,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -70,U
	LDA 86,U
	ANDA #$F0
	ORA #$07
	STA 86,U
	LDA 84,U
	ANDA #$0F
	ORA #$90
	STA 84,U
	LDA 76,U
	ANDA #$0F
	ORA #$70
	STA 76,U
	LDA 11,U
	ANDA #$0F
	ORA #$80
	STA 11,U
	LDA 4,U
	ANDA #$0F
	ORA #$80
	STA 4,U
	LDA -4,U
	ANDA #$0F
	ORA #$70
	STA -4,U
	LDA -71,U
	ANDA #$0F
	ORA #$90
	STA -71,U
	LDD #$7778
	STD 5,U
	LDA #$89
	STD -75,U
	LDD #$7333
	STD -84,U
	LDX #$3389
	PSHU B,X
	LEAU -194,U

	LDD #$8888
	STD 47,U
	LDD 41,U
	ANDA #$F0
	ORA #$03
	LDB #$88
	STD 41,U
	LDD -33,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -33,U
	LDD -39,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -39,U
	LDA #$33
	STA 33,U
	STA -48,U
	LEAU -207,U

	STA -70,U
	LDA #$88
	STA 84,U
	LDA #$89
	STA 4,U
	LDD #$8333
	STD 78,U
	LDD #$3388
	STD 14,U
	STD -66,U
	LDA 12,U
	ANDA #$0F
	ORA #$90
	STA 12,U
	LDD 94,U
	ANDA #$F0
	ORA #$03
	LDB #$88
	STD 94,U
	LDD -69,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD -69,U
	STB -76,U
	LDA #$88
	LDX #$3333
	PSHU A,X
	LEAU -77,U

	LDA -4,U
	ANDA #$F0
	ORA #$08
	STA -4,U
	LDD #$3388
	STD -66,U
	LDD -69,U
	ANDA #$F0
	ORA #$07
	LDB #$98
	STD -69,U
	LDA #$33
	STA -70,U
	LDA #$77
	STA -76,U
	LDA #$33
	PSHU A,X
	LEAU -78,U

	LDD -68,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD -68,U
	LDD -65,U
	LDA #$33
	ANDB #$F0
	ORB #$08
	STD -65,U
	STA -69,U
	LDA #$78
	STA -75,U
	LDA #$88
	PSHU A,X
	LEAU -77,U

	LDD -65,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -65,U
	STA -69,U
	LDD -68,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -68,U
	LDA #$89
	STA -75,U
	LDD #$8833
	PSHU D,X
	LEAU -77,U

	STD -84,U
	LDD -64,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -64,U
	LDD -82,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -82,U
	LDD #$8833
	PSHU D,X
	LEAU -157,U

	STA -67,U
	STB 15,U
	STB -65,U
	LDA 9,U
	ANDA #$0F
	ORA #$90
	STA 9,U
	STX 17,U
	STX -63,U
	LDD -72,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD -72,U
	LDD #$8833
	PSHU D,X
	LEAU -77,U

	LDD -61,U
	LDA #$33
	ANDB #$F0
	ORB #$03
	STD -61,U
	LDA -62,U
	ANDA #$F0
	ORA #$03
	STA -62,U
	LDA -64,U
	ANDA #$0F
	ORA #$30
	STA -64,U
	LDA -83,U
	ANDA #$F0
	ORA #$03
	STA -83,U
	LDD -71,U
	ANDA #$F0
	ORA #$07
	LDB #$98
	STD -71,U
	LDA #$89
	STA -66,U
	STA -68,U
	STX -82,U
	LDA #$83
	PSHU A,X
	LEAU -262,U

	LDD 123,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 123,U
	LDD 114,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD 114,U
	LDD 102,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 102,U
	LDD 34,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD 34,U
	LDD 22,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 22,U
	STB -58,U
	LDA 44,U
	ANDA #$0F
	ORA #$30
	STA 44,U
	LDA -45,U
	ANDA #$0F
	ORA #$90
	STA -45,U
	LDA #$77
	STA 39,U
	LDA #$78
	STA -41,U
	STA -43,U
	LDA #$99
	STA 119,U
	STA 117,U
	STA 37,U
	LDA #$89
	STA -121,U
	LDA #$88
	STA -123,U
	LEAU -171,U

	STB 33,U
	LDA #$99
	STA -32,U
	LEAU -265,U

	LDA ,U
	ANDA #$F0
	ORA #$0a
	STA ,U
	RTS
