	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_tk_003_0
	LEAU 3848,U

	LDD #$9999
	STD 120,U
	STD 40,U
	STD 23,U
	STD -57,U
	LDA 102,U
	ANDA #$F0
	ORA #$09
	STA 102,U
	LDD 103,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 103,U
	LDD -40,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -40,U
	LDD -121,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -121,U
	LEAU -256,U

	LDD #$9999
	STD 119,U
	STD 55,U
	STD -25,U
	STA -40,U
	LDD 39,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 39,U
	LDD -105,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -105,U
	LDD -120,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -120,U
	LEAU -312,U

	LDD 127,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 127,U
	LDD 112,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 112,U
	LDD #$9999
	STD 32,U
	STA 47,U
	STA -33,U
	STA -127,U
	LDD -48,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -48,U
	LDD -114,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -114,U
	LEAU -320,U

	LDD 126,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD 126,U
	LDA -47,U
	ANDA #$F0
	ORA #$09
	STA -47,U
	LDA -126,U
	ANDA #$0F
	ORA #$90
	STA -126,U
	LDA #$99
	STA 113,U
	STA 46,U
	STA 33,U
	STA -34,U
	STA -114,U
	LEAU -320,U

	STA 114,U
	STA 34,U
	STA -46,U
	LDA 126,U
	ANDA #$0F
	ORA #$90
	STA 126,U
	LDA 46,U
	ANDA #$0F
	ORA #$90
	STA 46,U
	LDA -35,U
	ANDA #$F0
	ORA #$09
	STA -35,U
	LDA -115,U
	ANDA #$F0
	ORA #$09
	STA -115,U
	LDA -126,U
	ANDA #$F0
	ORA #$09
	STA -126,U
	LEAU -235,U

	LDA #$99
	STA 40,U
	LDA -40,U
	ANDA #$0F
	ORA #$90
	STA -40,U
	LEAU -1286,U

	LDA #$aa
	STA -37,U
	LDA 43,U
	ANDA #$0F
	ORA #$a0
	STA 43,U
	LDA -42,U
	ANDA #$F0
	ORA #$0a
	STA -42,U
	LEAU -198,U

	LDA #$aa
	STA 81,U
	LDD ,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$70a0
	STD ,U
	LDA 77,U
	ANDA #$0F
	ORA #$a0
	STA 77,U
	LDA -79,U
	ANDA #$0F
	ORA #$70
	STA -79,U
	LDD #$7777
	STD 78,U
	LDD -82,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -82,U
	LDA #$a7
	LDX #$7777
	PSHU A,X
	LEAU -280,U

	LDD 120,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$70d0
	STD 120,U
	LDD 44,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0770
	STD 44,U
	LDD -122,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070d
	STD -122,U
	LDA 119,U
	ANDA #$F0
	ORA #$07
	STA 119,U
	LDA -37,U
	ANDA #$F0
	ORA #$07
	STA -37,U
	LDD 39,U
	LDA #$77
	ANDB #$F0
	ORB #$07
	STD 39,U
	LDD #$dd77
	STD -36,U
	STB -41,U
	LDD -116,U
	ANDA #$F0
	ORA #$0d
	LDB #$77
	STD -116,U
	LEAU -319,U

	LDA 124,U
	ANDA #$F0
	ORA #$07
	STA 124,U
	LDA -43,U
	ANDA #$0F
	ORA #$70
	STA -43,U
	LDD #$77dd
	STD 117,U
	LDD 44,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d070
	STD 44,U
	LDD -124,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070d
	STD -124,U
	LDD 37,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD 37,U
	LDD #$dd77
	STD -36,U
	LDD -116,U
	ANDA #$F0
	ORA #$0d
	LDB #$77
	STD -116,U
	LEAU -319,U

	LDD 123,U
	ANDA #$F0
	ORA #$0d
	LDB #$77
	STD 123,U
	LDA 44,U
	ANDA #$F0
	ORA #$07
	STA 44,U
	LDA -36,U
	ANDA #$F0
	ORA #$07
	STA -36,U
	LDA -121,U
	ANDA #$0F
	ORA #$80
	STA -121,U
	LDD 115,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070d
	STD 115,U
	LDD -116,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d070
	STD -116,U
	LDD #$77dd
	STD 35,U
	STD -45,U
	LDD -125,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -125,U
	LEAU -317,U

	LDD 121,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d070
	STD 121,U
	LDD 41,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d070
	STD 41,U
	LDD 112,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD 112,U
	LDD 32,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD 32,U
	LDA -38,U
	ANDA #$0F
	ORA #$70
	STA -38,U
	LDA -45,U
	ANDA #$0F
	ORA #$80
	STA -45,U
	LDA #$77
	STA -48,U
	LDA #$38
	STA -42,U
	LDD #$3737
	STD -122,U
	LEAU -204,U

	LDA ,U
	ANDA #$F0
	ORA #$03
	STA ,U
	LEAU -154,U

	LDA #$aa
	STA 78,U
	LDA -83,U
	ANDA #$0F
	ORA #$30
	STA -83,U
	LDA -85,U
	ANDA #$0F
	ORA #$70
	STA -85,U
	LDA -87,U
	ANDA #$0F
	ORA #$30
	STA -87,U
	LDD -6,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$7080
	STD -6,U
	LDD -90,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0708
	STD -90,U
	LDD -10,U
	ANDA #$F0
	ORA #$07
	LDB #$8a
	STD -10,U
	LDD -82,U
	ANDA #$F0
	ORA #$0a
	LDB #$37
	STD -82,U
	LDD 74,U
	LDA #$83
	ANDB #$0F
	ORB #$30
	STD 74,U
	LDA #$33
	LDX #$aa77
	PSHU A,X
	LEAU -282,U

	LDD #$3388
	STD 124,U
	LDA 122,U
	ANDA #$F0
	ORA #$09
	STA 122,U
	LDA 116,U
	ANDA #$0F
	ORA #$30
	STA 116,U
	LDA 114,U
	ANDA #$F0
	ORA #$08
	STA 114,U
	LDA -121,U
	ANDA #$0F
	ORA #$30
	STA -121,U
	LDD 117,U
	LDA #$78
	ANDB #$0F
	ORB #$30
	STD 117,U
	LDD -39,U
	LDA #$33
	ANDB #$F0
	ORB #$08
	STD -39,U
	LDD -46,U
	LDA #$88
	ANDB #$0F
	ORB #$90
	STD -46,U
	LDD -115,U
	LDA #$88
	ANDB #$0F
	ORB #$70
	STD -115,U
	LDD -126,U
	LDA #$77
	ANDB #$0F
	ORB #$80
	STD -126,U
	LDD #$3399
	STD 44,U
	LDB #$98
	STD -36,U
	LDD 36,U
	ANDA #$0F
	ORA #$30
	LDB #$77
	STD 36,U
	LDA #$33
	STA 41,U
	STA -116,U
	LDD #$8893
	STD 34,U
	LDD -42,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -42,U
	LDD -44,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$3008
	STD -44,U
	LDD -120,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$3030
	STD -120,U
	LEAU -320,U

	LDD 125,U
	LDA #$77
	ANDB #$0F
	ORB #$70
	STD 125,U
	LDD 120,U
	LDA #$33
	ANDB #$F0
	ORB #$09
	STD 120,U
	LDD 45,U
	LDA #$99
	ANDB #$0F
	ORB #$70
	STD 45,U
	LDD -35,U
	LDA #$88
	ANDB #$0F
	ORB #$30
	STD -35,U
	LDD -115,U
	LDA #$88
	ANDB #$0F
	ORB #$30
	STD -115,U
	LDD -117,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -117,U
	LDA #$78
	STA 118,U
	LDA #$77
	STA 38,U
	STA -120,U
	LDD #$8789
	STD 114,U
	LDD #$7388
	STD 40,U
	LDD #$8899
	STD 34,U
	LDD -40,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0708
	STD -40,U
	LDA -37,U
	ANDA #$F0
	ORA #$03
	STA -37,U
	LDA -42,U
	ANDA #$F0
	ORA #$08
	STA -42,U
	LDA -126,U
	ANDA #$F0
	ORA #$08
	STA -126,U
	LDD -45,U
	ANDA #$0F
	ORA #$90
	LDB #$33
	STD -45,U
	LDA #$88
	STA -46,U
	STB -124,U
	LEAU -320,U

	LDD 123,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 123,U
	LDD 43,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 43,U
	LDD -37,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -37,U
	LDD -117,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0308
	STD -117,U
	LDA #$33
	STA 116,U
	STA 36,U
	STA -44,U
	LDA 120,U
	ANDA #$0F
	ORA #$80
	STA 120,U
	LDA -47,U
	ANDA #$0F
	ORA #$30
	STA -47,U
	LDA -113,U
	ANDA #$0F
	ORA #$30
	STA -113,U
	LDD #$8833
	STD -125,U
	LEAU -320,U

	LDD 124,U
	LDA #$99
	ANDB #$0F
	ORB #$80
	STD 124,U
	LDD 35,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD 35,U
	LDD -45,U
	LDA #$78
	ANDB #$0F
	ORB #$80
	STD -45,U
	LDD -125,U
	LDA #$77
	ANDB #$0F
	ORB #$90
	STD -125,U
	LDA 122,U
	ANDA #$0F
	ORA #$30
	STA 122,U
	LDA 32,U
	ANDA #$0F
	ORA #$30
	STA 32,U
	LDA -32,U
	ANDA #$0F
	ORA #$30
	STA -32,U
	LDA -112,U
	ANDA #$F0
	ORA #$03
	STA -112,U
	LDA #$33
	STA 118,U
	STA 38,U
	STA -42,U
	STA -120,U
	STA -122,U
	LDA #$89
	STA 115,U
	LDD #$9987
	STD 44,U
	LDD 41,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 41,U
	LDD -39,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -39,U
	LDD -110,U
	ANDA #$F0
	ORA #$0a
	LDB #$88
	STD -110,U
	LDD -119,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -119,U
	LDD #$8877
	STD -36,U
	LDD #$8787
	STD -116,U
	LEAU -211,U

	LDA #$aa
	STA 80,U
	STA ,U
	LDD 12,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 12,U
	LDD 10,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 10,U
	LDD -70,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -70,U
	LDD -81,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -81,U
	LDD #$9987
	STD 15,U
	LDD #$aaaa
	STD 21,U
	STD -59,U
	LDA #$33
	STA 9,U
	STA 2,U
	STA -71,U
	LDD 6,U
	LDA #$89
	ANDB #$0F
	ORB #$90
	STD 6,U
	LDD -65,U
	LDA #$98
	ANDB #$0F
	ORB #$80
	STD -65,U
	LDA -60,U
	ANDA #$0F
	ORA #$30
	STA -60,U
	LDA -67,U
	ANDA #$0F
	ORA #$30
	STA -67,U
	LDA -78,U
	ANDA #$0F
	ORA #$30
	STA -78,U
	LDA #$88
	STA -74,U
	LEAU -216,U

	LDD #$aaaa
	STD 55,U
	LDD 76,U
	ANDA #$F0
	ORA #$03
	LDB #$aa
	STD 76,U
	LDD 66,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 66,U
	LDD -14,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -14,U
	LDA 71,U
	ANDA #$F0
	ORA #$08
	STA 71,U
	LDA 69,U
	ANDA #$F0
	ORA #$08
	STA 69,U
	LDA #$88
	STA 64,U
	STA 62,U
	LDA #$89
	STA -16,U
	LDD 78,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 78,U
	LDD -11,U
	LDA #$99
	ANDB #$0F
	ORB #$80
	STD -11,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -19,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDD -59,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -59,U
	LDD -74,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -74,U
	LDD -82,U
	LDA #$aa
	ANDB #$0F
	ORB #$30
	STD -82,U
	STX -84,U
	LDD #$9987
	STD -69,U
	LDA #$33
	STA -71,U
	LDD #$3aaa
	STD -61,U
	LDX #$aa33
	PSHU B,X
	LEAU -134,U

	LDA #$88
	STA -14,U
	LDB #$77
	STD -12,U
	LDD -17,U
	LDA #$78
	ANDB #$0F
	ORB #$80
	STD -17,U
	LDD #$33aa
	LDX #$aaaa
	PSHU D,X
	LEAU -20,U

	PSHU B,X
	LEAU -53,U

	LDD #$8787
	STD -12,U
	LDD -15,U
	ANDA #$F0
	ORA #$08
	LDB #$98
	STD -15,U
	LDD -17,U
	LDA #$77
	ANDB #$0F
	ORB #$90
	STD -17,U
	LDA #$aa
	PSHU A,X
	LEAU -22,U

	PSHU A,X
	LEAU -51,U

	LDD #$9987
	STD -13,U
	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDD #$7888
	STD -16,U
	LDD -18,U
	LDA #$89
	ANDB #$0F
	ORB #$90
	STD -18,U
	LDA #$aa
	PSHU A,X
	LEAU -23,U

	PSHU A,X
	LEAU -51,U

	LDD #$7787
	STD -16,U
	LDD -13,U
	LDA #$98
	ANDB #$0F
	ORB #$80
	STD -13,U
	LDA #$88
	STA -18,U
	LDA #$aa
	PSHU A,X
	LEAU -23,U

	LDD -55,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -55,U
	LDD -82,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -82,U
	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA -67,U
	ANDA #$F0
	ORA #$08
	STA -67,U
	STX -57,U
	STX -84,U
	LDD #$7877
	STD -70,U
	LDA #$88
	STA -72,U
	LDA #$aa
	PSHU A,X
	LEAU -130,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDD #$7898
	STD -17,U
	LDA #$aa
	PSHU A,X
	LEAU -25,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA #$aa
	PSHU A,X
	LEAU -49,U

	LDD -17,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -17,U
	LDA #$aa
	PSHU A,X
	LEAU -25,U

	LDB #$aa
	PSHU D,X
	LEAU -48,U

	STD -32,U
	LDD -30,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -30,U
	LDA #$88
	STA -16,U
	STX -82,U
	LDA -83,U
	ANDA #$F0
	ORA #$0a
	STA -83,U
	LDA #$aa
	PSHU A,X
	LEAU -106,U

	STX -53,U
	PSHU A,X
	LEAU -77,U

	STX -53,U
	STA -83,U
	LDD -82,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -82,U
	PSHU A,X
	LEAU -249,U

	LDD 119,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 119,U
	STX 89,U
	STX 9,U
	LDD -71,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -71,U
	STA 40,U
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$0a
	STA -120,U
	LEAU -231,U

	LDA #$aa
	STA 80,U
	STA ,U
	LDA -80,U
	ANDA #$0F
	ORA #$a0
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 3848,U

	LDD -58,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -58,U
	LDA 119,U
	ANDA #$F0
	ORA #$09
	STA 119,U
	LDD #$9999
	STD 102,U
	STD 39,U
	STD 22,U
	STD -41,U
	STD -121,U
	LDD 120,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 120,U
	LEAU -256,U

	LDD 119,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 119,U
	LDD 55,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD 55,U
	LDD #$9999
	STD 39,U
	STD -41,U
	STA -25,U
	LDD -106,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -106,U
	LDD -121,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD -121,U
	LEAU -312,U

	LDD 126,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 126,U
	LDD 111,U
	ANDA #$F0
	ORA #$09
	LDB #$99
	STD 111,U
	LDD #$9999
	STD 46,U
	STA 32,U
	STA -48,U
	STA -114,U
	LDD -34,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -34,U
	LDD -128,U
	LDA #$99
	ANDB #$0F
	ORB #$90
	STD -128,U
	LEAU -321,U

	STA 127,U
	STA 47,U
	STA 34,U
	STA -46,U
	STA -126,U
	LDA -33,U
	ANDA #$0F
	ORA #$90
	STA -33,U
	LDA -114,U
	ANDA #$F0
	ORA #$09
	STA -114,U
	LDD 113,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0990
	STD 113,U
	LEAU -320,U

	LDA #$99
	STA 126,U
	STA 46,U
	STA -34,U
	LDA 114,U
	ANDA #$F0
	ORA #$09
	STA 114,U
	LDA 34,U
	ANDA #$F0
	ORA #$09
	STA 34,U
	LDA -45,U
	ANDA #$0F
	ORA #$90
	STA -45,U
	LDA -114,U
	ANDA #$0F
	ORA #$90
	STA -114,U
	LDA -125,U
	ANDA #$0F
	ORA #$90
	STA -125,U
	LEAU -245,U

	LDA -40,U
	ANDA #$F0
	ORA #$09
	STA -40,U
	LDA #$99
	STA 40,U
	LEAU -1277,U

	LDA 40,U
	ANDA #$F0
	ORA #$0a
	STA 40,U
	LDA -35,U
	ANDA #$0F
	ORA #$a0
	STA -35,U
	LDA #$aa
	STA -40,U
	LEAU -195,U

	LDD 78,U
	LDA #$77
	ANDB #$F0
	ORB #$0a
	STD 78,U
	LDD -83,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -83,U
	LDA #$aa
	STA 75,U
	LDA #$77
	STA 77,U
	LDD -5,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0a07
	STD -5,U
	LDA -85,U
	ANDA #$F0
	ORA #$07
	STA -85,U
	LDA #$77
	LDX #$777a
	PSHU A,X
	LEAU -280,U

	LDD 122,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0770
	STD 122,U
	LDD 37,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0770
	STD 37,U
	LDD -117,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d070
	STD -117,U
	LDA 121,U
	ANDA #$F0
	ORA #$0d
	STA 121,U
	LDD 42,U
	ANDA #$0F
	ORA #$70
	LDB #$77
	STD 42,U
	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -42,U
	LDD -123,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -123,U
	STA -37,U
	STA -43,U
	LEAU -320,U

	LDD -124,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD -124,U
	LDA 117,U
	ANDA #$0F
	ORA #$70
	STA 117,U
	LDA -36,U
	ANDA #$F0
	ORA #$07
	STA -36,U
	LDD 43,U
	ANDA #$F0
	ORA #$0d
	LDB #$77
	STD 43,U
	LDD 36,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070d
	STD 36,U
	LDD -116,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d070
	STD -116,U
	LDD #$77dd
	STD -44,U
	LDD #$dd77
	STD 123,U
	LEAU -320,U

	LDD 124,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d070
	STD 124,U
	LDD -125,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070d
	STD -125,U
	LDD 116,U
	LDA #$77
	ANDB #$0F
	ORB #$d0
	STD 116,U
	LDA 36,U
	ANDA #$0F
	ORA #$70
	STA 36,U
	LDA -44,U
	ANDA #$0F
	ORA #$70
	STA -44,U
	LDA -119,U
	ANDA #$F0
	ORA #$08
	STA -119,U
	LDD #$dd77
	STD 44,U
	STD -36,U
	LDD -116,U
	ANDA #$F0
	ORA #$0d
	LDB #$77
	STD -116,U
	LEAU -318,U

	LDD 122,U
	ANDA #$F0
	ORA #$0d
	LDB #$77
	STD 122,U
	LDD 42,U
	ANDA #$F0
	ORA #$0d
	LDB #$77
	STD 42,U
	LDD #$7373
	STD -124,U
	LDA #$77
	STA -37,U
	LDA -40,U
	ANDA #$F0
	ORA #$08
	STA -40,U
	LDA -47,U
	ANDA #$F0
	ORA #$07
	STA -47,U
	LDA #$83
	STA -43,U
	LDD 113,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070d
	STD 113,U
	LDD 33,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$070d
	STD 33,U
	LEAU -201,U

	LDA ,U
	ANDA #$0F
	ORA #$30
	STA ,U
	LEAU -162,U

	LDD 81,U
	ANDA #$F0
	ORA #$03
	LDB #$38
	STD 81,U
	LDA #$aa
	STA 78,U
	LDD 5,U
	LDA #$a8
	ANDB #$0F
	ORB #$70
	STD 5,U
	LDD 1,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0807
	STD 1,U
	LDD -75,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8070
	STD -75,U
	LDD -82,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$a003
	STD -82,U
	LDA -77,U
	ANDA #$F0
	ORA #$03
	STA -77,U
	LDA -79,U
	ANDA #$F0
	ORA #$07
	STA -79,U
	LDA #$73
	STA -83,U
	LDA #$77
	LDX #$aa33
	PSHU A,X
	LEAU -276,U

	LDD -35,U
	ANDA #$F0
	ORA #$09
	LDB #$88
	STD -35,U
	LDD -42,U
	ANDA #$0F
	ORA #$80
	LDB #$33
	STD -42,U
	LDD -115,U
	ANDA #$F0
	ORA #$08
	LDB #$77
	STD -115,U
	LDD 123,U
	LDA #$87
	ANDB #$F0
	ORB #$03
	STD 123,U
	LDD 43,U
	LDA #$77
	ANDB #$F0
	ORB #$03
	STD 43,U
	LDD #$8833
	STD 115,U
	LDD #$3988
	STD 45,U
	LDA #$33
	STA 39,U
	LDD #$9933
	STD 35,U
	LDA 126,U
	ANDA #$0F
	ORA #$80
	STA 126,U
	LDA 122,U
	ANDA #$F0
	ORA #$03
	STA 122,U
	LDA 118,U
	ANDA #$0F
	ORA #$90
	STA 118,U
	LDA -121,U
	ANDA #$F0
	ORA #$03
	STA -121,U
	LDA -126,U
	ANDA #$F0
	ORA #$07
	STA -126,U
	LDD -37,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$8003
	STD -37,U
	LDD -39,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0330
	STD -39,U
	LDD -120,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0303
	STD -120,U
	LDD #$8933
	STD -45,U
	LDA #$88
	STD -125,U
	LEAU -320,U

	STB -36,U
	STB -116,U
	LDA #$87
	STA 122,U
	LDD 119,U
	ANDA #$0F
	ORA #$90
	LDB #$33
	STD 119,U
	LDD 114,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD 114,U
	LDD 34,U
	ANDA #$F0
	ORA #$07
	LDB #$99
	STD 34,U
	LDD -35,U
	ANDA #$F0
	ORA #$09
	LDB #$88
	STD -35,U
	LDD -46,U
	ANDA #$F0
	ORA #$03
	LDB #$88
	STD -46,U
	LDD -124,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -124,U
	LDD -126,U
	ANDA #$F0
	ORA #$03
	LDB #$88
	STD -126,U
	LDD #$9988
	STD 45,U
	LDA #$77
	STA 42,U
	STA -120,U
	LDD #$8837
	STD 39,U
	LDD #$9878
	STD 125,U
	LDA -38,U
	ANDA #$0F
	ORA #$80
	STA -38,U
	LDA -43,U
	ANDA #$0F
	ORA #$30
	STA -43,U
	LDA -114,U
	ANDA #$0F
	ORA #$80
	STA -114,U
	LDD -41,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8070
	STD -41,U
	LEAU -322,U

	LDA #$33
	STA 126,U
	STA 46,U
	STA -34,U
	LDA 122,U
	ANDA #$F0
	ORA #$08
	STA 122,U
	LDA -31,U
	ANDA #$F0
	ORA #$03
	STA -31,U
	LDA -125,U
	ANDA #$F0
	ORA #$03
	STA -125,U
	LDD -122,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8030
	STD -122,U
	LDD #$3388
	STD -114,U
	LDD 118,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 118,U
	LDD 38,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD 38,U
	LDD -42,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -42,U
	LEAU -321,U

	LDA #$98
	STA 128,U
	LDD 41,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 41,U
	LDD -39,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -39,U
	LDD -128,U
	LDA #$88
	ANDB #$0F
	ORB #$a0
	STD -128,U
	LDA 121,U
	ANDA #$F0
	ORA #$03
	STA 121,U
	LDA 51,U
	ANDA #$F0
	ORA #$03
	STA 51,U
	LDA -45,U
	ANDA #$F0
	ORA #$03
	STA -45,U
	LDA -125,U
	ANDA #$0F
	ORA #$30
	STA -125,U
	LDD 118,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD 118,U
	LDD 47,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD 47,U
	LDD -33,U
	ANDA #$F0
	ORA #$08
	LDB #$87
	STD -33,U
	LDD -113,U
	ANDA #$F0
	ORA #$09
	LDB #$77
	STD -113,U
	LDD -118,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -118,U
	STB 125,U
	STB 45,U
	STB -35,U
	STB -115,U
	STB -119,U
	LDD #$7899
	STD 38,U
	LDD #$7788
	STD -42,U
	LDA #$aa
	STA -106,U
	LDD #$7878
	STD -122,U
	LEAU -237,U

	LDA #$aa
	STA 51,U
	STA -51,U
	LDA #$33
	STA 49,U
	STA 38,U
	STA -40,U
	LDD 44,U
	ANDA #$F0
	ORA #$09
	LDB #$98
	STD 44,U
	LDD 41,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD 41,U
	LDD 39,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD 39,U
	LDD -39,U
	ANDA #$0F
	ORA #$30
	LDB #$33
	STD -39,U
	LDD -45,U
	ANDA #$F0
	ORA #$08
	LDB #$89
	STD -45,U
	LDA -31,U
	ANDA #$F0
	ORA #$03
	STA -31,U
	LDA -42,U
	ANDA #$F0
	ORA #$03
	STA -42,U
	LDD #$aaaa
	STD 29,U
	LDD -29,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -29,U
	LDD -50,U
	LDA #$aa
	ANDB #$F0
	ORB #$03
	STD -50,U
	LDD #$7899
	STD 35,U
	LDA #$88
	STA -35,U
	LEAU -209,U

	LDD #$aaaa
	STD 100,U
	LDA #$33
	STD 19,U
	LDD 89,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 89,U
	LDD 79,U
	LDA #$aa
	ANDB #$0F
	ORB #$30
	STD 79,U
	LDD 21,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 21,U
	LDD 9,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD 9,U
	LDA 87,U
	ANDA #$0F
	ORA #$80
	STA 87,U
	LDA 85,U
	ANDA #$0F
	ORA #$80
	STA 85,U
	LDD 77,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD 77,U
	LDD 6,U
	ANDA #$F0
	ORA #$08
	LDB #$99
	STD 6,U
	LDA #$88
	STA 94,U
	STA 92,U
	LDA #$98
	STA 12,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -54,U

	LDD -12,U
	ANDA #$F0
	ORA #$08
	LDB #$88
	STD -12,U
	LDA -4,U
	ANDA #$F0
	ORA #$03
	STA -4,U
	LDA #$33
	STA -14,U
	LDD #$7899
	STD -17,U
	LDA #$aa
	PSHU A,X
	LEAU -20,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA #$aa
	LDX #$aaa3
	PSHU A,X
	LEAU -54,U

	LDA #$88
	STA -14,U
	LDD -12,U
	ANDA #$F0
	ORA #$08
	LDB #$87
	STD -12,U
	LDD #$7788
	STD -17,U
	LDA #$aa
	LDX #$aaaa
	PSHU A,X
	LEAU -20,U

	LDY #$aa33
	PSHU X,Y
	LEAU -52,U

	LDD -13,U
	ANDA #$F0
	ORA #$09
	LDB #$77
	STD -13,U
	LDD #$7878
	STD -18,U
	LDD -15,U
	LDA #$89
	ANDB #$0F
	ORB #$80
	STD -15,U
	LDA #$aa
	PSHU A,X
	LEAU -22,U

	PSHU A,X
	LEAU -52,U

	STX -29,U
	STX -83,U
	LDD #$8887
	STD -15,U
	LDD #$7899
	STD -18,U
	LDD -27,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -27,U
	LDD -81,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -81,U
	LDD -13,U
	ANDA #$F0
	ORA #$09
	LDB #$98
	STD -13,U
	LDD -98,U
	ANDA #$F0
	ORA #$08
	LDB #$89
	STD -98,U
	LDA #$88
	STA -92,U
	LDD #$7877
	STD -95,U
	LDA #$aa
	PSHU A,X
	LEAU -103,U

	PSHU A,X
	LEAU -50,U

	LDA #$88
	STA -13,U
	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA -18,U
	ANDA #$0F
	ORA #$80
	STA -18,U
	LDD #$7787
	STD -16,U
	LDA #$aa
	PSHU A,X
	LEAU -24,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDD -54,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -54,U
	LDD -82,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -82,U
	STX -56,U
	STX -84,U
	LDD #$8987
	STD -69,U
	LDA #$aa
	PSHU A,X
	LEAU -129,U

	LDD -17,U
	LDA #$88
	ANDB #$0F
	ORB #$80
	STD -17,U
	LDD #$aaaa
	PSHU D,X
	LEAU -25,U

	PSHU A,X
	LEAU -48,U

	LDA -4,U
	ANDA #$F0
	ORA #$0a
	STA -4,U
	LDA #$88
	STA -17,U
	PSHU B,X
	LEAU -26,U

	PSHU B,X
	LEAU -48,U

	STB -32,U
	LDD -31,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD -31,U
	PSHU A,X
	LEAU -77,U

	STX -32,U
	STX -112,U
	STX -82,U
	LDA -83,U
	ANDA #$F0
	ORA #$0a
	STA -83,U
	LDA #$aa
	PSHU A,X
	LEAU -278,U

	STA 9,U
	STA -71,U
	STA -120,U
	LDD 89,U
	LDA #$aa
	ANDB #$0F
	ORB #$a0
	STD 89,U
	STX 119,U
	STX 39,U
	LDD -41,U
	ANDA #$F0
	ORA #$0a
	LDB #$aa
	STD -41,U
	LEAU -216,U

	LDA 65,U
	ANDA #$0F
	ORA #$a0
	STA 65,U
	LDA -64,U
	ANDA #$F0
	ORA #$0a
	STA -64,U
	STB 16,U
	RTS
