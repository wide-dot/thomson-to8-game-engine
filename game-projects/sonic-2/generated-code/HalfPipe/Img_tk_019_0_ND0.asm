	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_tk_019_0
	LEAU 3971,U

	LDD 3,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 3,U
	STA 2,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -14,U

	LDD -9,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -9,U
	LDD #$aaaa
	PSHU D,X
	LEAU -54,U

	LDA -4,U
	ANDA #$F0
	ORA #$09
	STA -4,U
	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -2,U

	LDA -16,U
	ANDA #$F0
	ORA #$0b
	STA -16,U
	LDX #$aaaa
	PSHU B,X
	LEAU -14,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDD -8,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -8,U
	LDA #$aa
	PSHU A,X
	LEAU -55,U

	LDA -4,U
	ANDA #$F0
	ORA #$09
	STA -4,U
	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -2,U

	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -14,U

	PSHU A,X
	LEAU -3,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -49,U

	LDD -7,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -7,U
	STA -8,U
	LDD #$9999
	PSHU D,X
	LEAU -18,U

	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -3,U

	LDX #$9999
	PSHU B,X
	LEAU -49,U

	LDD -7,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -7,U
	LDD -23,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -23,U
	LDD -29,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -29,U
	LDA #$aa
	STA -8,U
	STX -31,U
	LDD -25,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -25,U
	LDD #$9999
	PSHU D,X
	LEAU -76,U

	LDD #$aaaa
	STD -8,U
	LDD #$9999
	PSHU D,X
	LEAU -17,U

	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -3,U

	LDA #$99
	LDX #$9999
	PSHU D,X
	LEAU -49,U

	LDD #$aaaa
	STD -8,U
	LDA -5,U
	ANDA #$F0
	ORA #$09
	STA -5,U
	LDD #$9999
	PSHU D,X
	LEAU -17,U

	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -3,U

	LDA -5,U
	ANDA #$F0
	ORA #$09
	STA -5,U
	LDD #$9999
	LDX #$9999
	PSHU D,X
	LEAU -49,U

	LDA -5,U
	ANDA #$F0
	ORA #$09
	STA -5,U
	LDA -24,U
	ANDA #$F0
	ORA #$0a
	STA -24,U
	LDD #$aaaa
	STD -8,U
	STD -23,U
	LDD -28,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -28,U
	LDD #$9999
	PSHU D,X
	LEAU -24,U

	PSHU D,X
	LEAU -48,U

	LDD #$aaaa
	STD -23,U
	LDD -8,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -8,U
	LDA #$99
	LDY #$9999
	PSHU A,X,Y
	LEAU -21,U

	LDD #$9999
	PSHU D,X,Y
	LEAU -48,U

	LDD -8,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -8,U
	LDD -22,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -22,U
	STA -23,U
	LDA #$99
	PSHU A,X,Y
	LEAU -21,U

	LDD #$9999
	PSHU D,X,Y
	LEAU -48,U

	LDA -5,U
	ANDA #$F0
	ORA #$09
	STA -5,U
	LDA -23,U
	ANDA #$F0
	ORA #$0a
	STA -23,U
	LDD -22,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -22,U
	LDD -27,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -27,U
	LDA #$aa
	STA -8,U
	PSHU X,Y
	LEAU -23,U

	LDA #$99
	PSHU A,X,Y
	LEAU -48,U

	LDD #$aaaa
	STD -22,U
	LDD -9,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -9,U
	PSHU X,Y
	LEAU -21,U

	LDA #$99
	STA -7,U
	LDB #$99
	PSHU D,X,Y
	LEAU -49,U

	LDD #$aaaa
	STD -22,U
	LDD -9,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -9,U
	PSHU X,Y
	LEAU -21,U

	LDA #$99
	STA -7,U
	LDB #$99
	PSHU D,X,Y
	LEAU -49,U

	LDD -9,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -9,U
	STB -21,U
	LDD -27,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -27,U
	PSHU X,Y
	LEAU -23,U

	PSHU A,X,Y
	LEAU -48,U

	LDA -4,U
	ANDA #$F0
	ORA #$09
	STA -4,U
	LDD -21,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -21,U
	LDD -9,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -9,U
	LDA #$99
	PSHU A,X
	LEAU -23,U

	LDB #$99
	PSHU D,X,Y
	LEAU -48,U

	LDD -9,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0aa0
	STD -9,U
	LDD -21,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -21,U
	LDA #$99
	PSHU A,X
	LEAU -23,U

	LDB #$99
	PSHU D,X,Y
	LEAU -48,U

	LDD -28,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -28,U
	LDA #$aa
	STA -20,U
	LDD -9,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0aa0
	STD -9,U
	LDA #$99
	PSHU A,X
	LEAU -25,U

	PSHU X,Y
	LEAU -48,U

	LDA #$aa
	STA -20,U
	LDA #$99
	PSHU A,X
	LEAU -24,U

	STX -55,U
	LDA -56,U
	ANDA #$F0
	ORA #$09
	STA -56,U
	LDA -72,U
	ANDA #$F0
	ORA #$09
	STA -72,U
	LDA #$99
	PSHU A,X,Y
	LEAU -75,U

	STX -55,U
	LDD -65,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -65,U
	LDA #$99
	PSHU A,X,Y
	LEAU -60,U

	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA #$cc
	LDX #$cccc
	PSHU A,X
	LEAU -12,U

	STY -55,U
	LDA #$99
	STA -62,U
	LDX #$9999
	PSHU A,X,Y
	LEAU -58,U

	LDD -9,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -9,U
	STA -10,U
	LDD #$cccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -11,U

	LDD -62,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -62,U
	LDD #$9999
	STD -55,U
	LDX #$9999
	LDY #$9999
	PSHU A,X,Y
	LEAU -58,U

	LDD #$cccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -1,U

	LDD -12,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -12,U
	LDX #$9988
	PSHU A,X
	LEAU -9,U

	LDD -53,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -53,U
	LDD #$8899
	STD -60,U
	LDD -62,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -62,U
	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -59,U

	LDA -5,U
	ANDA #$F0
	ORA #$0c
	STA -5,U
	LDD #$cccc
	PSHU D,Y
	LEAU -2,U

	LDA #$99
	LDX #$9988
	PSHU A,X
	LEAU -8,U

	STA -53,U
	LDD -63,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -63,U
	LDD #$8899
	STD -61,U
	LDA #$99
	LDX #$9999
	PSHU D,X
	LEAU -59,U

	LDA -9,U
	ANDA #$F0
	ORA #$09
	STA -9,U
	LDD #$8888
	STD -8,U
	LDD #$cccc
	PSHU D,Y
	LEAU -13,U

	LDA #$99
	STA -53,U
	LDB #$99
	PSHU D,X
	LEAU -55,U

	LDA #$88
	STA -12,U
	LDA #$cc
	STA -8,U
	LDD -11,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -11,U
	LDA -4,U
	ANDA #$F0
	ORA #$0c
	STA -4,U
	LDA #$cc
	LDX #$8888
	PSHU A,X
	LEAU -18,U

	LDA #$99
	STA -53,U
	LDD -60,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -60,U
	LDD -62,U
	LDA #$cc
	ANDB #$F0
	ORB #$08
	STD -62,U
	STX -70,U
	LDA -71,U
	ANDA #$F0
	ORA #$08
	STA -71,U
	LDD #$9999
	LDX #$9999
	PSHU D,X
	LEAU -76,U

	STA -53,U
	LDA -61,U
	ANDA #$F0
	ORA #$08
	STA -61,U
	LDD -60,U
	ANDA #$0F
	ORA #$80
	LDB #$cc
	STD -60,U
	LDD #$8888
	STD -70,U
	LDD #$9999
	PSHU D,X
	LEAU -76,U

	LDA -53,U
	ANDA #$F0
	ORA #$09
	STA -53,U
	LDD -60,U
	ANDA #$0F
	ORA #$80
	LDB #$cc
	STD -60,U
	LDD -69,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -69,U
	LDD -82,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -82,U
	STX -84,U
	LDD -71,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$c008
	STD -71,U
	LDD #$9999
	PSHU D,X
	LEAU -213,U

	LDA 84,U
	ANDA #$F0
	ORA #$09
	STA 84,U
	STX 53,U
	LDA #$88
	STA 77,U
	STA -11,U
	LDB #$88
	STD 68,U
	LDD 65,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD 65,U
	LDD 78,U
	LDA #$cc
	ANDB #$0F
	ORB #$b0
	STD 78,U
	LDD 55,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 55,U
	LDD -14,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -14,U
	STA -15,U
	LDA #$88
	PSHU A,Y
	LEAU -21,U

	LDD -70,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -70,U
	LDA #$88
	STA -66,U
	LDA #$cc
	STA -57,U
	STA -71,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	LDD -58,U
	ANDA #$0F
	ORA #$80
	LDB #$cc
	STD -58,U
	STY -71,U
	LDA -66,U
	ANDA #$F0
	ORA #$08
	STA -66,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	LDA -72,U
	ANDA #$F0
	ORA #$0c
	STA -72,U
	STY -71,U
	LDD -57,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0cc0
	STD -57,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	LDA #$cc
	STA -56,U
	LDA #$99
	PSHU A,X
	LEAU -66,U

	LDA #$cc
	PSHU A,Y
	LEAU -8,U

	STA -56,U
	STA -72,U
	LDD -71,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -71,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	STY -72,U
	LDA #$cc
	STA -56,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	LDA -56,U
	ANDA #$F0
	ORA #$0c
	STA -56,U
	STY -72,U
	LDD -82,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -82,U
	STA -83,U
	PSHU A,X
	LEAU -254,U

	LDA 122,U
	ANDA #$0F
	ORA #$c0
	STA 122,U
	LDA 24,U
	ANDA #$F0
	ORA #$0c
	STA 24,U
	LDA -56,U
	ANDA #$F0
	ORA #$0c
	STA -56,U
	STY 105,U
	LDD 95,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 95,U
	STA 94,U
	STX 14,U
	STX -66,U
	STY 25,U
	STY -55,U
	LDA #$cb
	STA 42,U
	LDA #$cc
	STA -38,U
	STA -118,U
	LDA #$77
	STA -121,U
	LEAU -260,U

	LDD 125,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 125,U
	LDD 61,U
	LDA #$77
	ANDB #$F0
	ORB #$0c
	STD 61,U
	LDD 45,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 45,U
	LDA 124,U
	ANDA #$F0
	ORA #$0c
	STA 124,U
	LDA 60,U
	ANDA #$F0
	ORA #$07
	STA 60,U
	LDA -97,U
	ANDA #$0F
	ORA #$b0
	STA -97,U
	LDA -99,U
	ANDA #$F0
	ORA #$07
	STA -99,U
	LDA #$cc
	STA 44,U
	STX 114,U
	STX 34,U
	STX -46,U
	STX -126,U
	LDD -19,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070c
	STD -19,U
	STY -36,U
	STY -116,U
	LEAU -298,U

	LDA 121,U
	ANDA #$0F
	ORA #$c0
	STA 121,U
	LDA 119,U
	ANDA #$F0
	ORA #$07
	STA 119,U
	LDA 39,U
	ANDA #$F0
	ORA #$07
	STA 39,U
	STX 92,U
	STX 12,U
	STX -68,U
	STY 102,U
	STY 22,U
	STY -58,U
	LDA #$cb
	STA 41,U
	LDA #$cc
	STA -39,U
	STA -119,U
	LDA #$77
	STA -41,U
	STA -121,U
	LEAU -262,U

	STY 124,U
	STY 44,U
	STY -36,U
	LDA -17,U
	ANDA #$F0
	ORA #$0c
	STA -17,U
	LDA -97,U
	ANDA #$F0
	ORA #$0c
	STA -97,U
	LDA -117,U
	ANDA #$F0
	ORA #$0c
	STA -117,U
	LDA #$cc
	STA 63,U
	LDA #$77
	STA 61,U
	STA -19,U
	STA -99,U
	STX 114,U
	STX 34,U
	LDD -46,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -46,U
	LDD -126,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -126,U
	STY -116,U
	LEAU -301,U

	STY 105,U
	STY 25,U
	LDA #$77
	STA 122,U
	STA 42,U
	LDA 104,U
	ANDA #$F0
	ORA #$0c
	STA 104,U
	LDA 45,U
	ANDA #$0F
	ORA #$b0
	STA 45,U
	LDA 24,U
	ANDA #$F0
	ORA #$0c
	STA 24,U
	LDA -35,U
	ANDA #$0F
	ORA #$c0
	STA -35,U
	LDA -39,U
	ANDA #$F0
	ORA #$07
	STA -39,U
	LDA -56,U
	ANDA #$F0
	ORA #$0c
	STA -56,U
	LDA -115,U
	ANDA #$0F
	ORA #$c0
	STA -115,U
	LDA -122,U
	ANDA #$F0
	ORA #$07
	STA -122,U
	LDD 95,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 95,U
	LDD 15,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 15,U
	LDD -55,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -55,U
	LDD -65,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -65,U
	LDD #$7777
	STD -38,U
	LEAU -180,U

	LDD 45,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 45,U
	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -35,U
	LDA 44,U
	ANDA #$F0
	ORA #$0c
	STA 44,U
	LDA -36,U
	ANDA #$F0
	ORA #$0c
	STA -36,U
	LDD #$aacb
	STD -16,U
	LDA #$99
	STA 35,U
	STA -45,U
	LEAU -174,U

	STA 49,U
	STA -31,U
	LDA 77,U
	ANDA #$F0
	ORA #$03
	STA 77,U
	LDA 58,U
	ANDA #$F0
	ORA #$0c
	STA 58,U
	LDA -4,U
	ANDA #$F0
	ORA #$03
	STA -4,U
	LDA -22,U
	ANDA #$F0
	ORA #$0c
	STA -22,U
	LDD 59,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 59,U
	LDD -21,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -21,U
	LDD #$aacc
	STD 78,U
	STB -81,U
	LDA #$33
	LDX #$33cc
	PSHU A,X
	LEAU -79,U

	LDA -20,U
	ANDA #$F0
	ORA #$0c
	STA -20,U
	LDA -82,U
	ANDA #$0F
	ORA #$80
	STA -82,U
	LDA -100,U
	ANDA #$F0
	ORA #$0c
	STA -100,U
	LDD -19,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -19,U
	LDD -99,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -99,U
	LDA #$99
	STA -29,U
	STA -109,U
	LDA #$cc
	STA -79,U
	LDD -85,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -85,U
	LDX #$9333
	PSHU B,X
	LEAU -171,U

	LDA 6,U
	ANDA #$F0
	ORA #$07
	STA 6,U
	LDD 7,U
	LDA #$77
	ANDB #$0F
	ORB #$30
	STD 7,U
	LDA #$cc
	STA 15,U
	LDD -6,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0cc0
	STD -6,U
	LDA #$99
	STA -15,U
	LEAU -152,U

	LDA #$cc
	STA 87,U
	STA 7,U
	LDD 79,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 79,U
	LDD -83,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -83,U
	LDD #$7773
	STD 77,U
	LDA #$99
	STA 57,U
	STA -23,U
	STA -103,U
	LDA -5,U
	ANDA #$F0
	ORA #$0a
	STA -5,U
	LDA -84,U
	ANDA #$F0
	ORA #$03
	STA -84,U
	LDA #$aa
	STA -86,U
	LDD #$7733
	LDX #$3333
	PSHU D,X
	LEAU -246,U

	LDA #$99
	STA 67,U
	STA -13,U
	STA -93,U
	LDA 86,U
	ANDA #$F0
	ORA #$03
	STA 86,U
	LDA 16,U
	ANDA #$0F
	ORA #$30
	STA 16,U
	LDA -64,U
	ANDA #$0F
	ORA #$a0
	STA -64,U
	LDA #$aa
	STA 83,U
	STA 2,U
	LDA #$77
	STA 94,U
	LDA #$78
	STA 14,U
	STA -66,U
	LDD #$aaaa
	STD -79,U
	LEAU -237,U

	STD -84,U
	STD 78,U
	LDA 77,U
	ANDA #$F0
	ORA #$0a
	STA 77,U
	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA #$99
	STA 64,U
	STA -16,U
	LDD -82,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -82,U
	STA 93,U
	STA 13,U
	STA -67,U
	LDD #$8888
	STD -87,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -160,U

	LDA 16,U
	ANDA #$0F
	ORA #$a0
	STA 16,U
	LDD ,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD ,U
	STA -64,U
	LDD #$8888
	PSHU D,X
	LEAU -75,U

	LDD -65,U
	LDA #$aa
	ANDB #$0F
	ORB #$30
	STD -65,U
	LDA #$88
	LDY #$aaaa
	PSHU A,X,Y
	LEAU -76,U

	LDA -5,U
	ANDA #$F0
	ORA #$08
	STA -5,U
	LDA -85,U
	ANDA #$F0
	ORA #$08
	STA -85,U
	LDD -64,U
	LDA #$aa
	ANDB #$0F
	ORB #$30
	STD -64,U
	LDD -82,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -82,U
	LDD #$99aa
	STD -84,U
	LDA #$88
	PSHU D,X
	LEAU -157,U

	LDD #$aa33
	STD 17,U
	LDA -4,U
	ANDA #$F0
	ORA #$08
	STA -4,U
	LDA -83,U
	ANDA #$0F
	ORA #$90
	STA -83,U
	LDA #$73
	STA -62,U
	LDD -82,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -82,U
	LDA #$99
	PSHU A,X
	LEAU -229,U

	LDD #$9993
	STD 89,U
	LDA 68,U
	ANDA #$F0
	ORA #$07
	STA 68,U
	LDA -71,U
	ANDA #$F0
	ORA #$08
	STA -71,U
	LDD #$88aa
	STD 69,U
	LDD 9,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0890
	STD 9,U
	LDD -11,U
	ANDA #$F0
	ORA #$09
	LDB #$33
	STD -11,U
	LDD #$9933
	STD -91,U
	LEAU -228,U

	LDD 78,U
	LDA #$88
	ANDB #$0F
	ORB #$30
	STD 78,U
	LDD #$3333
	STD 57,U
	STD -82,U
	LDA #$77
	STA 77,U
	LDA -23,U
	ANDA #$F0
	ORA #$03
	STA -23,U
	LDA #$99
	LDX #$9333
	PSHU A,X
	LEAU -199,U

	LDD 40,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 40,U
	STA -40,U
	LEAU -419,U

	STA 40,U
	LDD -40,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -40,U
	LEAU -198,U

	LDA 77,U
	ANDA #$F0
	ORA #$03
	STA 77,U
	LDA -13,U
	ANDA #$0F
	ORA #$90
	STA -13,U
	LDD #$3333
	STD 78,U
	LDX #$3333
	PSHU A,X
	LEAU -77,U

	LDA -65,U
	ANDA #$F0
	ORA #$03
	STA -65,U
	LDA #$98
	STA -13,U
	PSHU B,X
	LEAU -77,U

	STX -65,U
	STA -13,U
	PSHU B,X
	LEAU -77,U

	STX -65,U
	LDA #$99
	STA -13,U
	PSHU B,X
	LEAU -77,U

	STA -13,U
	STX -65,U
	LDA -66,U
	ANDA #$F0
	ORA #$03
	STA -66,U
	PSHU B,X
	LEAU -77,U

	LDA #$89
	STA -13,U
	STX -65,U
	LDA -66,U
	ANDA #$F0
	ORA #$03
	STA -66,U
	PSHU B,X
	LEAU -77,U

	LDA #$89
	STA -13,U
	STA -93,U
	LDA -66,U
	ANDA #$F0
	ORA #$03
	STA -66,U
	LDA -83,U
	ANDA #$F0
	ORA #$03
	STA -83,U
	STX -65,U
	STX -82,U
	PSHU B,X
	LEAU -196,U

	STB -43,U
	LDA 53,U
	ANDA #$F0
	ORA #$03
	STA 53,U
	LDA -27,U
	ANDA #$F0
	ORA #$03
	STA -27,U
	LDD 37,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 37,U
	LDA #$88
	STA 26,U
	STA -54,U
	STX 54,U
	STX -26,U

	LDU <glb_screen_location_1
	LEAU 3975,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -1,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -15,U

	LDD #$9999
	STD -8,U
	LDA #$aa
	PSHU A,X
	LEAU -55,U

	LDD -8,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -8,U
	LDD -6,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -6,U
	LDD -23,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -23,U
	LDD -81,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -81,U
	STX -25,U
	LDD #$9999
	STD -30,U
	STD -83,U
	STX -87,U
	LDA -88,U
	ANDA #$F0
	ORA #$0a
	STA -88,U
	LDX #$9999
	PSHU B,X
	LEAU -98,U

	LDD -8,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -8,U
	STA -9,U
	LDD #$aaaa
	LDX #$aaaa
	PSHU D,X
	LEAU -54,U

	STD -8,U
	LDA -9,U
	ANDA #$F0
	ORA #$0a
	STA -9,U
	LDD #$9999
	LDX #$9999
	PSHU D,X
	LEAU -18,U

	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -3,U

	LDA -4,U
	ANDA #$F0
	ORA #$09
	STA -4,U
	LDX #$9999
	PSHU B,X
	LEAU -49,U

	LDA -5,U
	ANDA #$F0
	ORA #$09
	STA -5,U
	LDD #$9999
	PSHU D,X
	LEAU -2,U

	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -13,U

	PSHU A,X
	LEAU -3,U

	LDA #$99
	LDX #$9999
	PSHU D,X
	LEAU -48,U

	LDY #$9999
	PSHU A,X,Y
	LEAU -1,U

	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -13,U

	PSHU A,X
	LEAU -3,U

	LDA #$99
	PSHU D,Y
	LEAU -48,U

	LDD -8,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -8,U
	STA -9,U
	LDA -25,U
	ANDA #$F0
	ORA #$0a
	STA -25,U
	STX -24,U
	LDA #$99
	LDX #$9999
	PSHU A,X,Y
	LEAU -22,U

	PSHU A,X,Y
	LEAU -48,U

	LDD -23,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -23,U
	LDD #$aaaa
	STD -9,U
	STA -24,U
	LDA #$99
	PSHU A,X,Y
	LEAU -22,U

	PSHU A,X,Y
	LEAU -48,U

	LDA #$aa
	STD -9,U
	LDA #$99
	PSHU A,X,Y
	LEAU -16,U

	LDX #$aaaa
	PSHU B,X
	LEAU -3,U

	LDX #$9999
	PSHU A,X,Y
	LEAU -48,U

	LDA #$aa
	STD -9,U
	STD -23,U
	LDA -6,U
	ANDA #$F0
	ORA #$09
	STA -6,U
	LDA #$99
	PSHU A,X,Y
	LEAU -21,U

	LDB #$99
	PSHU D,X,Y
	LEAU -48,U

	LDA -6,U
	ANDA #$0F
	ORA #$90
	STA -6,U
	LDD #$aaaa
	STD -9,U
	STD -23,U
	LDA #$99
	PSHU A,X,Y
	LEAU -21,U

	LDB #$99
	PSHU D,X,Y
	LEAU -48,U

	LDD -9,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -9,U
	LDD -27,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -27,U
	LDD -23,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -23,U
	LDA #$99
	PSHU A,X,Y
	LEAU -22,U

	PSHU A,X,Y
	LEAU -48,U

	LDD -9,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -9,U
	LDD -22,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -22,U
	LDA -5,U
	ANDA #$F0
	ORA #$09
	STA -5,U
	PSHU X,Y
	LEAU -22,U

	LDD #$9999
	PSHU D,X,Y
	LEAU -48,U

	LDA #$aa
	STA -9,U
	LDB #$aa
	STD -22,U
	PSHU X,Y
	LEAU -22,U

	LDD #$9999
	PSHU D,X,Y
	LEAU -48,U

	LDA #$aa
	STA -9,U
	STA -21,U
	LDD -28,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -28,U
	PSHU X,Y
	LEAU -24,U

	PSHU X,Y
	LEAU -48,U

	LDA #$aa
	STA -9,U
	STA -21,U
	PSHU X,Y
	LEAU -23,U

	LDA #$99
	PSHU A,X,Y
	LEAU -48,U

	LDA #$aa
	STA -9,U
	LDA -4,U
	ANDA #$F0
	ORA #$09
	STA -4,U
	LDD -21,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0aa0
	STD -21,U
	LDA #$99
	PSHU A,X
	LEAU -24,U

	PSHU A,X,Y
	LEAU -48,U

	LDA #$aa
	STA -9,U
	STA -20,U
	LDA #$99
	PSHU A,X
	LEAU -24,U

	PSHU A,X,Y
	LEAU -48,U

	LDA #$aa
	STA -9,U
	STA -20,U
	LDD -29,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -29,U
	PSHU A,X
	LEAU -26,U

	PSHU A,X
	LEAU -48,U

	LDD -10,U
	LDA #$99
	ANDB #$0F
	ORB #$a0
	STD -10,U
	PSHU A,X
	LEAU -8,U

	STX -9,U
	LDD -18,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -18,U
	LDA #$cc
	LDX #$cccc
	LDY #$cccc
	PSHU A,X,Y
	LEAU -13,U

	LDA -54,U
	ANDA #$F0
	ORA #$09
	STA -54,U
	LDD #$9999
	STD -53,U
	LDX #$9999
	PSHU A,X
	LEAU -57,U

	STY -8,U
	LDD -11,U
	LDA #$99
	ANDB #$F0
	ORB #$09
	STD -11,U
	LDD #$cccc
	LDX #$cccc
	LDY #$cc99
	PSHU D,X,Y
	LEAU -13,U

	LDD #$9999
	STD -54,U
	LDD -62,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD -62,U
	LDD #$9999
	LDX #$9999
	PSHU D,X
	LEAU -58,U

	LDD #$cccc
	LDX #$cccc
	LDY #$cccc
	PSHU D,X,Y
	LEAU -2,U

	LDA #$99
	LDX #$9999
	PSHU A,X
	LEAU -7,U

	LDD -62,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD -62,U
	STX -54,U
	LDD #$9999
	PSHU D,X
	LEAU -58,U

	LDD -9,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -9,U
	LDD -11,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -11,U
	LDD #$cccc
	LDX #$cccc
	PSHU D,X,Y
	LEAU -12,U

	LDD -62,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -62,U
	LDD #$9999
	STD -54,U
	LDX #$9999
	PSHU D,X
	LEAU -58,U

	LDD #$cccc
	LDX #$cccc
	PSHU D,X,Y
	LEAU -1,U

	LDA #$99
	LDX #$8888
	PSHU A,X
	LEAU -8,U

	STB -63,U
	LDA #$88
	STA -61,U
	LDD #$9999
	STD -54,U
	STD -84,U
	LDA -68,U
	ANDA #$F0
	ORA #$0c
	STA -68,U
	LDA -72,U
	ANDA #$F0
	ORA #$08
	STA -72,U
	STX -71,U
	LDD -82,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -82,U
	LDD #$9999
	LDX #$9999
	PSHU D,X
	LEAU -157,U

	LDD 27,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 27,U
	LDD -61,U
	ANDA #$0F
	ORA #$c0
	LDB #$88
	STD -61,U
	LDD #$8888
	STD 10,U
	STA 20,U
	LDA #$99
	STA -52,U
	LDA -58,U
	ANDA #$0F
	ORA #$b0
	STA -58,U
	LDA -70,U
	ANDA #$F0
	ORA #$08
	STA -70,U
	LDD #$8888
	STD -69,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	STB -60,U
	LDA #$cb
	STA -58,U
	LDA #$cc
	STA -71,U
	LDA #$99
	STA -52,U
	LDA #$88
	STD -69,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	STA -52,U
	LDA #$cc
	STA -58,U
	LDA -60,U
	ANDA #$F0
	ORA #$08
	STA -60,U
	STB -68,U
	LDD -71,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -71,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	STA -52,U
	LDD -68,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -68,U
	LDA #$cc
	STA -58,U
	STY -71,U
	LDA #$99
	PSHU A,X
	LEAU -77,U

	STY -71,U
	LDD -58,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -58,U
	LDA -59,U
	ANDA #$0F
	ORA #$80
	STA -59,U
	LDA -72,U
	ANDA #$F0
	ORA #$0c
	STA -72,U
	LDA #$88
	STA -67,U
	LDA #$99
	STA -52,U
	PSHU A,X
	LEAU -77,U

	LDA -52,U
	ANDA #$F0
	ORA #$09
	STA -52,U
	LDA -66,U
	ANDA #$0F
	ORA #$80
	STA -66,U
	LDD -58,U
	ANDA #$F0
	ORA #$0c
	LDB #$cc
	STD -58,U
	LDA #$88
	STA -59,U
	LDA #$99
	PSHU A,X
	LEAU -66,U

	LDA -63,U
	ANDA #$F0
	ORA #$09
	STA -63,U
	LDA #$99
	STA -14,U
	STA -94,U
	LDD -13,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -13,U
	LDD -82,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -82,U
	LDD -93,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -93,U
	LDA #$cc
	STA -68,U
	STA -83,U
	PSHU A,Y
	LEAU -272,U

	STA 127,U
	LDA #$cb
	STA -32,U
	LDA #$cc
	STA -112,U
	STY 112,U
	STY 32,U
	LDD 47,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0cb0
	STD 47,U
	STX 101,U
	STX 21,U
	STX -59,U
	STY -48,U
	LDA -49,U
	ANDA #$F0
	ORA #$0c
	STA -49,U
	LDA -115,U
	ANDA #$0F
	ORA #$d0
	STA -115,U
	LDD -128,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -128,U
	LEAU -254,U

	STX 115,U
	STX 35,U
	STX -45,U
	STX -125,U
	STA 125,U
	STA 62,U
	STA 45,U
	LDA #$dd
	STA 60,U
	LDD 46,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 46,U
	LDD -19,U
	LDA #$dd
	ANDB #$F0
	ORB #$0c
	STD -19,U
	STY -35,U
	STY -115,U
	LDA -98,U
	ANDA #$F0
	ORA #$0c
	STA -98,U
	LDA -102,U
	ANDA #$0F
	ORA #$70
	STA -102,U
	LEAU -297,U

	LDA 120,U
	ANDA #$0F
	ORA #$c0
	STA 120,U
	LDA 117,U
	ANDA #$0F
	ORA #$70
	STA 117,U
	STY 102,U
	STY 22,U
	STY -58,U
	LDD 39,U
	ANDA #$0F
	ORA #$70
	LDB #$cb
	STD 39,U
	LDD -121,U
	ANDA #$0F
	ORA #$70
	LDB #$cc
	STD -121,U
	STX 92,U
	LDA #$77
	STA 38,U
	LDD 12,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 12,U
	LDD -68,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -68,U
	LDD #$77cc
	STD -41,U
	LEAU -263,U

	STY 125,U
	STY 45,U
	LDA #$99
	STA -45,U
	STA -125,U
	LDD 115,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 115,U
	LDD 35,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 35,U
	LDD -35,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -35,U
	LDD -115,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD -115,U
	LDD 62,U
	ANDA #$0F
	ORA #$70
	LDB #$cc
	STD 62,U
	LDD -18,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$700c
	STD -18,U
	LDA 124,U
	ANDA #$F0
	ORA #$0c
	STA 124,U
	LDA 44,U
	ANDA #$F0
	ORA #$0c
	STA 44,U
	LDA -36,U
	ANDA #$F0
	ORA #$0c
	STA -36,U
	LDA -97,U
	ANDA #$F0
	ORA #$0c
	STA -97,U
	LDA #$cc
	STA -116,U
	LEAU -296,U

	LDA 120,U
	ANDA #$0F
	ORA #$b0
	STA 120,U
	LDA 40,U
	ANDA #$0F
	ORA #$c0
	STA 40,U
	STY 20,U
	STY -60,U
	LDA #$cc
	STA 100,U
	LDA #$cb
	STA -40,U
	LDA #$cc
	STA -120,U
	LDA #$99
	STA 91,U
	STA 11,U
	STA -69,U
	LDD 101,U
	LDA #$cc
	ANDB #$0F
	ORB #$c0
	STD 101,U
	LEAU -184,U

	STY 44,U
	STY -36,U
	LDA #$99
	STA 35,U
	STA -45,U
	LDA #$cc
	STA -16,U
	LEAU -175,U

	STY 59,U
	STY -21,U
	STY -101,U
	STA 79,U
	LDA #$99
	STA 50,U
	STA -30,U
	STA -110,U
	LDA -81,U
	ANDA #$F0
	ORA #$0c
	STA -81,U
	LDA #$77
	STA -87,U
	LDD #$7777
	LDX #$77cc
	PSHU D,X
	LEAU -279,U

	LDD 121,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$080c
	STD 121,U
	STY 102,U
	STY 22,U
	STY -58,U
	LDA #$99
	STA 93,U
	STA 13,U
	STA -67,U
	LDD -121,U
	ANDA #$F0
	ORA #$08
	LDB #$33
	STD -121,U
	STB -40,U
	STB -122,U
	LDA -118,U
	ANDA #$F0
	ORA #$0c
	STA -118,U
	LDD 41,U
	LDA #$33
	ANDB #$F0
	ORB #$0c
	STD 41,U
	LDD -39,U
	LDA #$33
	ANDB #$F0
	ORB #$0c
	STD -39,U
	LEAU -182,U

	STY 44,U
	STY -36,U
	LDA #$99
	STA 35,U
	STA -45,U
	LDD -16,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0cb0
	STD -16,U
	LDD -20,U
	ANDA #$0F
	ORA #$30
	LDB #$78
	STD -20,U
	LDA #$33
	STA -21,U
	LEAU -182,U

	LDD #$7773
	STD 78,U
	LDD 86,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0cc0
	STD 86,U
	LDA #$cc
	STA 66,U
	LDA #$99
	STA 57,U
	STA -23,U
	LDA 7,U
	ANDA #$0F
	ORA #$c0
	STA 7,U
	LDA -4,U
	ANDA #$F0
	ORA #$07
	STA -4,U
	LDA -73,U
	ANDA #$0F
	ORA #$c0
	STA -73,U
	LDA #$77
	LDX #$3333
	PSHU A,X
	LEAU -78,U

	LDA #$99
	STA -22,U
	STA -102,U
	STX -83,U
	LDA -72,U
	ANDA #$0F
	ORA #$c0
	STA -72,U
	LDA #$77
	PSHU A,X
	LEAU -205,U

	LDA 55,U
	ANDA #$0F
	ORA #$a0
	STA 55,U
	LDA 53,U
	ANDA #$0F
	ORA #$70
	STA 53,U
	LDA -27,U
	ANDA #$0F
	ORA #$90
	STA -27,U
	LDA -39,U
	ANDA #$0F
	ORA #$a0
	STA -39,U
	LDA #$99
	STA 26,U
	STA -54,U
	LDA #$33
	STA 45,U
	LEAU -198,U

	LDA #$88
	STA -87,U
	LDD #$aaaa
	STD 78,U
	STD -84,U
	LDA #$99
	STA 64,U
	STA -16,U
	LDA #$3a
	STA 12,U
	LDD -68,U
	LDA #$3a
	ANDB #$F0
	ORB #$03
	STD -68,U
	LDD -82,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -82,U
	LDD 91,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$8003
	STD 91,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -158,U

	LDA #$88
	STA -6,U
	LDD #$aa33
	STD 13,U
	STD -67,U
	LDB #$aa
	PSHU D,X
	LEAU -77,U

	LDA -6,U
	ANDA #$F0
	ORA #$08
	STA -6,U
	STB -66,U
	LDD -82,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -82,U
	LDA #$88
	LDX #$8aaa
	LDY #$aaaa
	PSHU A,X,Y
	LEAU -77,U

	LDA -4,U
	ANDA #$F0
	ORA #$08
	STA -4,U
	LDD #$aaa3
	STD -64,U
	LDA #$88
	PSHU A,Y
	LEAU -76,U

	LDA -5,U
	ANDA #$F0
	ORA #$08
	STA -5,U
	LDD -85,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$090a
	STD -85,U
	STY -83,U
	LDD #$aaa3
	STD -65,U
	LDB #$aa
	PSHU D,Y
	LEAU -261,U

	STD 120,U
	LDD 102,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 102,U
	LDD -39,U
	LDA #$99
	ANDB #$0F
	ORB #$30
	STD -39,U
	LDD #$9997
	STD 100,U
	LDA #$aa
	STA 40,U
	STA 22,U
	LDA #$a7
	STA -40,U
	STA -120,U
	LDD -59,U
	ANDA #$0F
	ORA #$80
	LDB #$33
	STD -59,U
	LDA #$89
	STA 20,U
	LDA #$78
	STA -60,U
	LDD -119,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0930
	STD -119,U
	LEAU -259,U

	LDD 120,U
	ANDA #$F0
	ORA #$0a
	LDB #$33
	STD 120,U
	LDD -20,U
	ANDA #$F0
	ORA #$08
	LDB #$33
	STD -20,U
	LDD -41,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -41,U
	LDA #$97
	STA 119,U
	STB -120,U
	LDA 59,U
	ANDA #$F0
	ORA #$07
	STA 59,U
	LDA 39,U
	ANDA #$0F
	ORA #$80
	STA 39,U
	LDA -21,U
	ANDA #$F0
	ORA #$08
	STA -21,U
	LDD 40,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 40,U
	LDD #$9933
	STD -100,U
	LDA #$88
	STD 60,U
	LEAU -259,U

	LDD 79,U
	ANDA #$F0
	ORA #$09
	LDB #$33
	STD 79,U
	LDD #$3333
	STD -1,U
	LDA -80,U
	ANDA #$0F
	ORA #$30
	STA -80,U
	LEAU -540,U

	LDA 121,U
	ANDA #$0F
	ORA #$30
	STA 121,U
	LDD -119,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -119,U
	LDD #$3333
	STD 40,U
	STD -40,U
	STA -120,U
	LEAU -279,U

	LDD 80,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 80,U
	LDD ,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD ,U
	LDD -80,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -80,U
	LDD -64,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -64,U
	STB 79,U
	STB 17,U
	STB -1,U
	STB -81,U
	LEAU -221,U

	LDD 78,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 78,U
	LDD 61,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 61,U
	LDD -19,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -19,U
	STA 77,U
	STA 60,U
	STA -20,U
	LDX #$3333
	PSHU A,X
	LEAU -77,U

	STA -20,U
	LDD -19,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -19,U
	PSHU A,X
	LEAU -77,U

	STX -20,U
	PSHU A,X
	LEAU -77,U

	STX -20,U
	PSHU A,X
	LEAU -77,U

	LDA -19,U
	ANDA #$0F
	ORA #$30
	STA -19,U
	LDA #$33
	PSHU A,X
	RTS
