	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_tails_3_0
	STS glb_register_s

	LEAS ,Y
	LEAU 786,U

	LDA 100,U
	LDB -60,U
	PSHS B,A
	LDA #$cc
	STA 100,U
	LDA -20,U
	LDB 20,U
	PSHS B,A
	LDA #$63
	STA -60,U
	LDA 60,U
	LDB -100,U
	PSHS U,B,A
	ANDB #$0F
	ORB #$30
	STB -100,U
	LDA #$c6
	STA 20,U
	STA 60,U
	LDA #$65
	STA -20,U
	LEAU 260,U

	LDD -120,U
	PSHS D
	LDA #$cb
	ANDB #$0F
	ORB #$30
	STD -120,U
	LDD -80,U
	PSHS D
	LDA #$bb
	ANDB #$0F
	ORB #$50
	STD -80,U
	LDA -38,U
	PSHS A
	ANDA #$0F
	ORA #$50
	STA -38,U
	LDA -36,U
	PSHS A
	ANDA #$F0
	ORA #$05
	STA -36,U
	LDA 4,U
	LDX -40,U
	PSHS X,A
	LDD #$bb63
	STD -40,U
	LDA #$56
	STA 4,U
	PULU A,X
	PSHS U,X,A
	LDA #$ba
	LDX #$6575
	PSHU A,X
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$ba
	LDX #$6666
	LDY #$5563
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$bb
	LDX #$c666
	LDY #$773c
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$5b
	LDX #$c566
	LDY #$773c
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$5b
	LDX #$c666
	LDY #$6755
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$5b
	LDX #$5666
	LDY #$6766
	PSHU A,X,Y
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$50
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$5b
	LDX #$6666
	LDY #$6677
	PSHU A,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$6066
	LDX #$6666
	LDY #$7675
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$6066
	LDX #$6666
	LDY #$7637
	PSHU D,X,Y
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$6b
	LDX #$6666
	LDY #$6676
	PSHU A,X,Y
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$50
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$65
	LDX #$6666
	LDY #$6676
	PSHU A,X,Y
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$60
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$77
	LDX #$6666
	LDY #$6677
	PSHU A,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$7766
	LDX #$6766
	LDY #$7335
	PSHU D,X,Y
	LEAU 40,U

	LDD 4,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$7007
	STD 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7766
	LDX #$7a66
	PSHU D,X
	LEAU 40,U

	LDD 4,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$7003
	STD 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7766
	LDX #$aa66
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$70
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7766
	LDX #$0066
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$70
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7766
	LDX #$0066
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$70
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7766
	LDX #$0066
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$5766
	LDX #$0066
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 4,U
	LDA 38,U
	PSHS A
	ANDA #$F0
	ORA #$06
	STA 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$5766
	LDX #$006c
	PSHU D,X
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA 5,U
	LDA 38,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$5766
	LDX #$0061
	PSHU D,X
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$07
	LDB #$66
	STD 40,U
	LDD 75,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$ab
	STD 75,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$07
	LDB #$66
	STD 80,U
	LDD 115,U
	PSHS D
	ANDA #$0F
	ORA #$b0
	LDB #$aa
	STD 115,U
	LDA 36,U
	LDB 5,U
	PSHS B,A
	ANDB #$F0
	ORB #$06
	STB 5,U
	LDA 38,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA 38,U
	LDA 78,U
	PSHS A
	ANDA #$F0
	ORA #$00
	STA 78,U
	LDA #$bb
	STA 36,U
	LDX 42,U
	LDD #$0061
	STD 42,U
	LDY 82,U
	PSHS Y,X
	LDB #$c1
	STD 82,U
	LDD 117,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$b006
	STD 117,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$5766
	LDX #$0061
	PSHU D,X
	LEAU 120,U

	LDX 36,U
	PSHS X
	LDD #$babb
	STD 36,U
	PULU D,X
	PSHS U,X,D
	LDD #$bb76
	LDX #$00cc
	PSHU D,X
	LEAU 40,U

	LDX 36,U
	PSHS X
	LDA 4,U
	PSHS A
	ANDA #$F0
	ORA #$01
	STA 4,U
	LDD #$ba0b
	STD 36,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$bb77
	LDX #$001b
	PSHU D,X
	LEAU 40,U

	LDX 36,U
	PSHS X
	LDD #$cb00
	STD 36,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$b0
	LDX #$aa00
	LDY #$0b1c
	PSHU A,X,Y
	LEAU 40,U

	LDD 36,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$00
	STD 36,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$b0
	LDX #$0000
	LDY #$0ab1
	PSHU A,X,Y
	LEAU 40,U

	LDD 36,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$00
	STD 36,U
	LDA 38,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$bb
	LDX #$0000
	LDY #$00bb
	PSHU A,X,Y
	LEAU 40,U

	LDD 36,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$00
	STD 36,U
	LDA 38,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$cc
	LDX #$0000
	LDY #$00bb
	PSHU A,X,Y
	LEAU 40,U

	LDD 35,U
	PSHS D
	LDA #$cc
	ANDB #$F0
	ORB #$0c
	STD 35,U
	LDX 37,U
	PSHS X
	STY 37,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$bb
	LDX #$0000
	LDY #$00bb
	PSHU A,X,Y
	LEAU 40,U

	LDD 35,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0c0c
	STD 35,U
	LDX 37,U
	PSHS X
	LDD #$00ab
	STD 37,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$00
	LDX #$00b0
	LDY #$00bb
	PSHU A,X,Y
	LEAU 40,U

	LDD 36,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$00
	STD 36,U
	LDA 38,U
	PSHS A
	LDA #$ab
	STA 38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$cb
	LDX #$000c
	LDY #$00bc
	PSHU A,X,Y
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$cb00
	LDX #$0000
	PSHU D,X
	LEAU 36,U

	PULU A,X
	PSHS U,X,A
	LDA #$cc
	LDX #$000a
	PSHU A,X
	LEAU 4,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$b0a0
	LDX #$000a
	PSHU D,X
	LEAU 36,U

	PULU A,X
	PSHS U,X,A
	LDA #$bc
	LDX #$000a
	PSHU A,X
	LEAU 4,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$bbaa
	LDX #$00aa
	PSHU D,X
	LEAU 36,U

	PULU A,X
	PSHS U,X,A
	LDA #$bb
	LDX #$000a
	PSHU A,X
	LEAU 4,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$ccbb
	LDX #$00ac
	PSHU D,X
	LEAU 36,U

	LDX 5,U
	PSHS X
	LDB #$00
	STD 5,U
	LDA 7,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 7,U
	PULU A,X
	PSHS U,X,A
	LDA #$bb
	LDX #$a000
	PSHU A,X
	LEAU 40,U

	LDX 5,U
	PSHS X
	LDD #$33bb
	STD 5,U
	LDA 7,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 7,U
	PULU A,X
	PSHS U,X,A
	LDX #$a000
	PSHU B,X
	LEAU 40,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDX #$a000
	PSHU B,X
	LEAU 5,U

	PULU A,X
	PSHS U,X,A
	LDA #$57
	LDX #$cccc
	PSHU A,X
	LEAU 35,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDX #$a000
	PSHU B,X
	LEAU 5,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$76
	LDX #$bbab
	PSHU A,X
	LEAU 35,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDX #$a000
	PSHU B,X
	LEAU 5,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$66
	LDX #$bba0
	PSHU A,X
	LEAU 35,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$bbba
	LDX #$0abb
	PSHU D,X
	LEAU 5,U

	PULU A,X
	PSHS U,X,A
	LDA #$66
	LDX #$bb00
	PSHU A,X
	LEAU 35,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$bb
	LDX #$0abb
	PSHU D,X
	LEAU 5,U

	PULU A,X
	PSHS U,X,A
	LDA #$66
	LDX #$ab00
	PSHU A,X
	LEAU 35,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$bb
	LDX #$abbb
	PSHU D,X
	LEAU 5,U

	PULU A,X
	PSHS U,X,A
	LDA #$66
	LDX #$aa00
	PSHU A,X
	LEAU 35,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$bb
	LDX #$bbb5
	PSHU D,X
	LEAU 5,U

	PULU A,X
	PSHS U,X,A
	LDA #$76
	LDX #$5000
	PSHU A,X
	LEAU 35,U

	PULU X,Y
	PSHS U,Y,X
	LDD #$cbbb
	LDX #$b0b7
	PSHU D,X
	LEAU 5,U

	PULU A,X
	PSHS U,X,A
	LDA #$76
	LDX #$5a00
	PSHU A,X
	LEAU 35,U

	LDA 5,U
	LDB 82,U
	LDX 42,U
	PSHS X,B,A
	LDA #$76
	STA 5,U
	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$b7
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$b7
	STD 80,U
	LDD #$6b67
	STD 42,U
	LDA #$66
	STA 82,U
	LDD 120,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0bb0
	STD 120,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$cbbb
	LDX #$6b67
	PSHU D,X
	LEAU 160,U

	LDA ,U
	PSHS U,A
	ANDA #$F0
	ORA #$0c
	STA ,U

	LDU <glb_screen_location_1
	LEAU 805,U

	LDD ,U
	PSHS D
	ANDA #$F0
	ANDB #$0F
	ADDD #$0630
	STD ,U
	LDA -120,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA -120,U
	LDA -80,U
	PSHS A
	ANDA #$F0
	ORA #$06
	STA -80,U
	LDA -40,U
	PSHS A
	ANDA #$F0
	ORA #$06
	STA -40,U
	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$53
	STD 40,U
	LDD 80,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$65
	STD 80,U
	LDD 120,U
	PSHS U,D
	ANDA #$F0
	ORA #$06
	LDB #$66
	STD 120,U
	LEAU 282,U

	LDA -77,U
	LDB -37,U
	LDX -40,U
	PSHS X,B,A
	LDD -122,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$c6
	STD -122,U
	LDD -82,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$b6
	STD -82,U
	LDD -42,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$bc
	STD -42,U
	LDD -2,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$bc
	STD -2,U
	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$cb
	STD 38,U
	LDA #$53
	STA -77,U
	LDD #$7755
	STD -40,U
	LDA #$63
	STA -37,U
	LDA -80,U
	STB -80,U
	PULU X,Y
	PSHS U,Y,X,A
	LDD #$7667
	LDX #$5533
	PSHU D,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$bb
	STD 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6667
	LDX #$56c3
	PSHU D,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$0b
	STD 38,U
	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$60
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$66
	LDX #$6675
	PSHU A,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$06
	LDB #$0c
	STD 38,U
	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$50
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$66
	LDX #$6676
	PSHU A,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$b5
	STD 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6666
	LDX #$7765
	PSHU D,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$c6
	STD 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6666
	LDX #$7766
	PSHU D,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$56
	STD 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6666
	LDX #$7733
	PSHU D,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$76
	STD 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6666
	LDX #$6755
	PSHU D,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$76
	STD 38,U
	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$50
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6666
	LDX #$6765
	PSHU D,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$76
	STD 38,U
	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$30
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6666
	LDX #$6736
	PSHU D,X
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$76
	STD 38,U
	LDA 4,U
	PSHS A
	ANDA #$F0
	ORA #$05
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6666
	LDX #$6753
	PSHU D,X
	LEAU 40,U

	LDD 3,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$5003
	STD 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$66
	LDX #$6667
	PSHU A,X
	LEAU 39,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$60
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6666
	LDX #$7667
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$70
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6666
	LDX #$7667
	PSHU D,X
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$50
	STA 5,U
	LDA 37,U
	PSHS A
	ANDA #$0F
	ORA #$60
	STA 37,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$6766
	LDY #$7735
	PSHU B,X,Y
	LEAU 40,U

	LDA 37,U
	LDB 5,U
	PSHS B,A
	ANDB #$0F
	ORB #$30
	STB 5,U
	LDA #$06
	STA 37,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$66
	LDX #$6a66
	LDY #$0735
	PSHU A,X,Y
	LEAU 40,U

	LDA 37,U
	LDB 4,U
	PSHS B,A
	ANDB #$F0
	ORB #$05
	STB 4,U
	LDA #$06
	STA 37,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$6660
	LDX #$6607
	PSHU D,X
	LEAU 40,U

	LDD 4,U
	PSHS D
	ANDA #$F0
	ANDB #$F0
	ADDD #$0503
	STD 4,U
	LDA 37,U
	PSHS A
	ANDA #$0F
	ORA #$60
	STA 37,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7661
	LDX #$6607
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 4,U
	LDA 38,U
	PSHS A
	ANDA #$0F
	ORA #$60
	STA 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$767b
	LDX #$6607
	PSHU D,X
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$F0
	ORA #$03
	STA 4,U
	LDA 38,U
	PSHS A
	ANDA #$0F
	ORA #$00
	STA 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7670
	LDX #$66b7
	PSHU D,X
	LEAU 40,U

	LDA 35,U
	LDB 38,U
	PSHS B,A
	ANDB #$0F
	ORB #$00
	STB 38,U
	LDA #$bb
	STA 35,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7710
	LDX #$66b7
	PSHU D,X
	LEAU 40,U

	LDX 35,U
	PSHS X
	LDD #$bbbb
	STD 35,U
	LDA 38,U
	PSHS A
	ANDA #$0F
	ORA #$00
	STA 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7711
	LDX #$6673
	PSHU D,X
	LEAU 40,U

	LDA 5,U
	LDX 35,U
	PSHS X,A
	LDA #$66
	STA 5,U
	LDD #$cbab
	STD 35,U
	LDD 38,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$600b
	STD 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$7711
	LDX #$6673
	PSHU D,X
	LEAU 40,U

	LDD 35,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$a0
	STD 35,U
	LDA 5,U
	LDB 3,U
	PSHS B,A
	ANDB #$0F
	ORB #$70
	STB 3,U
	LDA #$00
	STA 5,U
	PULU A,X
	PSHS U,X,A
	LDA #$77
	LDX #$1166
	PSHU A,X
	LEAU 39,U

	LDD 4,U
	PSHS D
	ANDA #$0F
	ANDB #$0F
	ADDD #$7010
	STD 4,U
	LDA 6,U
	PSHS A
	LDA #$66
	STA 6,U
	LDD 37,U
	PSHS D
	LDA #$00
	ANDB #$0F
	ORB #$b0
	STD 37,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$bbaa
	LDX #$1c66
	PSHU D,X
	LEAU 41,U

	LDX 36,U
	PSHS X
	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA 4,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$00
	STD 39,U
	LDD #$00bb
	STD 36,U
	PULU X,Y
	PSHS U,Y,X
	LDB #$60
	LDX #$a0bb
	PSHU D,X
	LEAU 41,U

	LDX 35,U
	PSHS X
	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA 3,U
	LDD #$a0ab
	STD 35,U
	PULU A,X
	PSHS U,X,A
	LDA #$aa
	LDX #$00ab
	PSHU A,X
	LEAU 38,U

	LDX 37,U
	PSHS X
	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 5,U
	LDD #$a00a
	STD 37,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$bb
	LDX #$0000
	LDY #$000a
	PSHU A,X,Y
	LEAU 41,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$00
	STD 39,U
	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 4,U
	LDX 36,U
	PSHS X
	LDD #$a00a
	STD 36,U
	PULU D,X
	PSHS U,X,D
	LDD #$b000
	PSHU D,Y
	LEAU 41,U

	LDX 35,U
	PSHS X
	STD 35,U
	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 3,U
	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$00
	STD 38,U
	PULU A,X
	PSHS U,X,A
	PSHU B,Y
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	PSHU B,Y
	LEAU 34,U

	LDD 4,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$00
	STD 4,U
	PULU A,X
	PSHS U,X,A
	LDA #$bc
	LDX #$ba00
	PSHU A,X
	LEAU 6,U

	PULU A,X
	PSHS U,X,A
	LDX #$00ab
	PSHU B,X
	LEAU 34,U

	LDD 4,U
	PSHS D
	ANDA #$0F
	ORA #$c0
	LDB #$00
	STD 4,U
	PULU A,X
	PSHS U,X,A
	LDA #$bb
	LDX #$ba00
	PSHU A,X
	LEAU 6,U

	PULU A,X
	PSHS U,X,A
	LDX #$00ab
	PSHU B,X
	LEAU 34,U

	LDA 3,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$cb
	LDX #$ba00
	PSHU A,X
	LEAU 5,U

	LDX 121,U
	LDY 81,U
	PSHS Y,X
	LDD 117,U
	LDX 41,U
	PSHS X,D
	LDD 37,U
	PSHS D
	LDA #$00
	ANDB #$0F
	ORB #$b0
	STD 37,U
	LDD 77,U
	PSHS D
	LDA #$00
	ANDB #$0F
	ORB #$b0
	STD 77,U
	LDD #$ba0b
	STD 121,U
	LDD 35,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD 35,U
	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$bb
	STD 39,U
	LDD 75,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD 75,U
	LDD 79,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$cc
	STD 79,U
	LDD 115,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD 115,U
	LDA 43,U
	PSHS A
	ANDA #$0F
	ORA #$c0
	STA 43,U
	LDA 119,U
	PSHS A
	ANDA #$F0
	ORA #$0c
	STA 119,U
	LDD #$00ab
	STD 117,U
	LDB #$00
	STD 41,U
	STD 81,U
	PULU X,Y
	PSHS U,Y,X
	LDA #$aa
	LDX #$00bc
	PSHU D,X
	LEAU 276,U

	LDX -115,U
	LDY -34,U
	PSHS Y,X
	LDD #$bbaa
	STD -34,U
	LDD -79,U
	LDX -39,U
	LDY 6,U
	PSHS Y,X,D
	LDD -74,U
	PSHS D
	LDA #$cc
	ANDB #$0F
	ORB #$b0
	STD -74,U
	LDD -121,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$bb
	STD -121,U
	LDD -81,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$bb
	STD -81,U
	LDD -76,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -76,U
	LDD -41,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$bb
	STD -41,U
	LDD -36,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$7c
	STD -36,U
	LDD 4,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$6c
	STD 4,U
	LDX -119,U
	PSHS X
	LDD #$bb0a
	STD 6,U
	LDA #$00
	STD -39,U
	LDB #$ab
	STD -119,U
	LDB #$0b
	STD -79,U
	LDA -117,U
	PSHS A
	ANDA #$0F
	ORA #$b0
	STA -117,U
	LDA -113,U
	PSHS A
	ANDA #$F0
	ORA #$0b
	STA -113,U
	LDD #$1cbc
	STD -115,U
	PULU A,X
	PSHS U,X,A
	LDA #$bb
	LDX #$000a
	PSHU A,X
	LEAU 40,U

	LDD 4,U
	PSHS D
	ANDA #$F0
	ORA #$07
	LDB #$65
	STD 4,U
	LDX 6,U
	PSHS X
	LDD #$ba0a
	STD 6,U
	PULU A,X
	PSHS U,X,A
	LDA #$bb
	LDX #$000a
	PSHU A,X
	LEAU 40,U

	LDD 4,U
	PSHS D
	ANDA #$F0
	ORA #$07
	LDB #$66
	STD 4,U
	LDX 6,U
	PSHS X
	LDD #$aaac
	STD 6,U
	PULU A,X
	PSHS U,X,A
	LDA #$bb
	LDX #$0aa0
	PSHU A,X
	LEAU 40,U

	LDX 6,U
	PSHS X
	LDA #$a0
	STD 6,U
	LDD 4,U
	PSHS D
	ANDA #$F0
	ORA #$07
	LDB #$66
	STD 4,U
	PULU A,X
	PSHS U,X,A
	LDA #$bb
	LDX #$00bb
	PSHU A,X
	LEAU 40,U

	LDD 4,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$66
	STD 4,U
	LDX 6,U
	PSHS X
	LDD #$00ac
	STD 6,U
	PULU A,X
	PSHS U,X,A
	LDA #$cb
	LDX #$00b6
	PSHU A,X
	LEAU 40,U

	LDD 3,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$3005
	STD 3,U
	PULU A,X
	PSHS U,X,A
	LDA #$cb
	LDX #$a066
	PSHU A,X
	LEAU 5,U

	PULU A,X
	PSHS U,X,A
	LDA #$66
	LDX #$00ac
	PSHU A,X
	LEAU 35,U

	LDD 3,U
	PSHS D
	ANDA #$0F
	ANDB #$F0
	ADDD #$3003
	STD 3,U
	LDA 5,U
	PSHS A
	LDA #$66
	STA 5,U
	PULU A,X
	PSHS U,X,A
	LDA #$cb
	LDX #$a06b
	PSHU A,X
	LEAU 40,U

	LDA 80,U
	LDX 40,U
	PSHS X,A
	LDD #$bba6
	STD 40,U
	STA 80,U
	PULU A,X
	PSHS U,X,A
	LDA #$cb
	LDX #$a066
	PSHU A,X
	LEAU ,S
SSAV_Img_tails_3_0
	LDS glb_register_s
	RTS
