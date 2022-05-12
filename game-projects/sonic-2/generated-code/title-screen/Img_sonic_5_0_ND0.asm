	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_sonic_5_0
	LEAU 3251,U

	LDD 38,U
	LDA #$dd
	ANDB #$0F
	ORB #$40
	STD 38,U
	LDA 79,U
	ANDA #$0F
	ORA #$40
	STA 79,U
	LDA -5,U
	ANDA #$F0
	ORA #$04
	STA -5,U
	LDD #$4445
	LDX #$dd44
	PSHU D,X
	LEAU -36,U

	LDD #$5344
	LDX #$4445
	LDY #$d344
	PSHU D,X,Y
	LEAU -34,U

	LDX #$4444
	LDY #$1544
	PSHU D,X,Y
	LEAU -34,U

	LDD -42,U
	LDA #$54
	ANDB #$0F
	ORB #$40
	STD -42,U
	LDD #$5344
	LDY #$3445
	PSHU D,X,Y
	LEAU -36,U

	LDD -40,U
	LDA #$44
	ANDB #$0F
	ORB #$50
	STD -40,U
	LDD #$3344
	PSHU D,X
	LEAU -36,U

	LDA -4,U
	ANDA #$F0
	ORA #$05
	STA -4,U
	PSHU B,X
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$03
	STA -5,U
	LDA -39,U
	ANDA #$F0
	ORA #$01
	STA -39,U
	LDD #$4444
	PSHU D,X
	LEAU -36,U

	LDA #$1d
	STA -39,U
	LDY #$0444
	PSHU X,Y
	LEAU -36,U

	LDA #$54
	LDX #$0544
	PSHU D,X
	LEAU -34,U

	LDX #$4544
	LDY #$11dd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$55
	LDX #$4d04
	PSHU D,X,Y
	LEAU -34,U

	LDX #$5d45
	LDY #$1ddd
	PSHU D,X,Y
	LEAU -34,U

	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD #$1344
	LDX #$dd41
	LDY #$dddd
	PSHU D,X,Y
	LEAU -36,U

	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDD #$1155
	LDX #$dd51
	PSHU D,X
	LEAU -36,U

	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDD #$553d
	LDX #$dd1d
	PSHU D,X
	LEAU -36,U

	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDD #$4433
	PSHU D,Y
	LEAU -36,U

	LDA #$55
	LDX #$4453
	PSHU A,X,Y
	LEAU -34,U

	LDD #$4444
	LDX #$44dd
	PSHU D,X,Y
	LEAU -34,U

	LDX #$441d
	PSHU D,X,Y
	LEAU -34,U

	LDA #$cb
	STA -7,U
	LDA #$44
	LDX #$44dd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$11
	STA -7,U
	LDA #$44
	PSHU D,X,Y
	LEAU -34,U

	LDA #$11
	STA -7,U
	LDA #$44
	LDX #$445d
	PSHU D,X,Y
	LEAU -34,U

	LDA #$01
	STA -7,U
	LDA #$44
	LDX #$444d
	PSHU D,X,Y
	LEAU -34,U

	LDA #$11
	STA -7,U
	LDD #$4404
	LDX #$454d
	PSHU D,X,Y
	LEAU -34,U

	LDA #$d0
	STA -7,U
	LDD #$4000
	LDX #$4445
	PSHU D,X,Y
	LEAU -34,U

	LDA #$b0
	STA -7,U
	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD #$0000
	LDX #$4444
	PSHU D,X,Y
	LEAU -36,U

	LDX #$0000
	LDY #$4444
	PSHU A,X,Y
	LEAU -33,U

	STA -7,U
	LDX #$4444
	LDY #$ddd1
	PSHU D,X,Y
	LEAU -34,U

	LDA #$0b
	STA -7,U
	LDA #$00
	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$01
	STA -7,U
	LDD #$000b
	LDX #$0444
	PSHU D,X,Y
	LEAU -34,U

	LDA #$01
	STA -7,U
	LDD -41,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDD #$0001
	PSHU D,X,Y
	LEAU -35,U

	LDD #$bd00
	LDX #$010b
	LDY #$45dd
	PSHU D,X,Y
	LEAU -32,U

	LDA -9,U
	ANDA #$F0
	ORA #$0d
	STA -9,U
	LDD #$bdb0
	STD -8,U
	LDD #$010b
	LDX #$5ddd
	LDY #$ddd1
	PSHU D,X,Y
	LEAU -34,U

	LDA -9,U
	ANDA #$F0
	ORA #$0d
	STA -9,U
	LDD #$ddb0
	STD -8,U
	LDD #$010b
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	LDD #$ddd0
	STD -8,U
	LDA -9,U
	ANDA #$F0
	ORA #$0c
	STA -9,U
	LDD #$0c0b
	PSHU D,X,Y
	LEAU -34,U

	LDD #$ddd0
	STD -8,U
	LDA -9,U
	ANDA #$F0
	ORA #$0c
	STA -9,U
	LDD #$bb0b
	PSHU D,X,Y
	LEAU -34,U

	LDA #$bc
	PSHU D,X,Y
	LDA #$dc
	LDX #$dddb
	PSHU A,X
	LEAU -31,U

	LDA #$b1
	LDX #$dddd
	PSHU D,X,Y
	LDA #$dc
	LDX #$dddb
	PSHU A,X
	LEAU -31,U

	LDA #$c1
	LDX #$dddd
	PSHU D,X,Y
	LDA #$dc
	PSHU A,X
	LEAU -31,U

	LDA #$bc
	PSHU D,X,Y
	LDD -36,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -36,U
	LDA #$dc
	PSHU A,X
	LEAU -33,U

	LDA #$dd
	STA -7,U
	LDD #$dddd
	LDX #$000c
	PSHU D,X,Y
	LEAU -33,U

	STD -8,U
	LDB #$00
	LDX #$0ddd
	PSHU D,X,Y
	LEAU -34,U

	STY -8,U
	LDX #$bddd
	PSHU D,X,Y
	LEAU -34,U

	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	STY -8,U
	LDD #$dd00
	LDX #$cddc
	PSHU D,X,Y
	LEAU -36,U

	LDB #$dd
	LDX #$ddb0
	LDY #$dddc
	PSHU D,X,Y
	LEAU -33,U

	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD #$dddd
	LDX #$bbdd
	LDY #$dbdd
	PSHU D,X,Y
	LEAU -34,U

	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD #$dddd
	LDX #$dcdd
	LDY #$dbd1
	PSHU D,X,Y
	LEAU -34,U

	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD #$dddd
	LDX #$dddd
	LDY #$dc11
	PSHU D,X,Y
	LEAU -34,U

	STA -7,U
	LDY #$dd11
	PSHU D,X,Y
	LEAU -34,U

	STA -7,U
	PSHU D,X,Y
	LEAU -34,U

	STA -7,U
	PSHU D,X,Y
	LEAU -34,U

	STA -7,U
	PSHU D,X,Y
	LEAU -34,U

	STA -7,U
	LDY #$ddd1
	PSHU D,X,Y
	LEAU -34,U

	STA -7,U
	LDD -41,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDD #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -35,U

	LDB #$cd
	PSHU D,X,Y
	LEAU -32,U

	STX -8,U
	LDB #$dd
	LDY #$dd11
	PSHU D,X,Y
	LEAU -34,U

	LDD -8,U
	ANDA #$F0
	ORA #$01
	LDB #$dc
	STD -8,U
	LDD #$dddd
	LDX #$d4dd
	LDY #$ddd1
	PSHU D,X,Y
	LEAU -34,U

	STA -7,U
	LDX #$441d
	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD -41,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDX #$dd44
	LDY #$1ddd
	PSHU B,X,Y
	LEAU -33,U

	STB -7,U
	LDD #$dd44
	LDX #$dddd
	LDY #$ddd1
	PSHU D,X,Y
	LEAU -34,U

	LDA #$cd
	STA -7,U
	LDA #$dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$dc
	STA -7,U
	LDA #$dd
	PSHU D,X,Y
	LEAU -34,U

	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDA #$dc
	STA -7,U
	LDD #$dd54
	PSHU D,X,Y
	LEAU -36,U

	LDA -5,U
	ANDA #$F0
	ORA #$0d
	STA -5,U
	LDD #$dd55
	PSHU D,X
	LEAU -35,U

	LDX #$d5dd
	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -35,U

	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDA -45,U
	ANDA #$F0
	ORA #$0d
	STA -45,U
	LDD #$dbdd
	STD -44,U
	LDX #$cddd
	PSHU B,X,Y
	LEAU -76,U

	LDA #$d1
	PSHU A,Y
	LEAU -37,U

	STB -42,U
	PSHU B,Y

	LDU <glb_screen_location_1
	LEAU 3250,U

	LDA 79,U
	ANDA #$F0
	ORA #$05
	STA 79,U
	LDD 38,U
	ANDA #$F0
	ORA #$0d
	LDB #$14
	STD 38,U
	LDD #$4444
	LDX #$dd54
	PSHU D,X
	LEAU -36,U

	LDA -6,U
	ANDA #$F0
	ORA #$03
	STA -6,U
	LDX #$4444
	LDY #$dd44
	PSHU B,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$03
	STA -6,U
	PSHU B,X,Y
	LEAU -35,U

	LDA #$54
	PSHU A,X,Y
	LEAU -35,U

	LDY #$d144
	PSHU A,X,Y
	LEAU -35,U

	LDA -39,U
	ANDA #$0F
	ORA #$10
	STA -39,U
	LDA #$54
	LDY #$1344
	PSHU A,X,Y
	LEAU -35,U

	LDA -39,U
	ANDA #$0F
	ORA #$d0
	STA -39,U
	LDA #$55
	LDX #$4440
	LDY #$1544
	PSHU A,X,Y
	LEAU -35,U

	LDD -40,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$01d0
	STD -40,U
	LDA #$35
	LDX #$4400
	LDY #$3445
	PSHU A,X,Y
	LEAU -35,U

	LDY #$3441
	PSHU A,X,Y
	LEAU -34,U

	LDA -6,U
	ANDA #$F0
	ORA #$05
	STA -6,U
	LDA #$44
	LDX #$4054
	LDY #$511d
	PSHU A,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$03
	STA -6,U
	LDA #$44
	LDX #$4444
	LDY #$11dd
	PSHU A,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$03
	STA -6,U
	LDA #$54
	LDX #$4440
	PSHU A,X,Y
	LEAU -35,U

	LDA #$55
	LDX #$4540
	PSHU A,X,Y
	LEAU -35,U

	LDA #$33
	LDX #$5d54
	LDY #$dddd
	PSHU A,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$05
	STA -6,U
	LDA #$31
	LDX #$ddd5
	PSHU A,X,Y
	LEAU -35,U

	LDD #$5445
	LDX #$1dd1
	PSHU D,X,Y
	LEAU -34,U

	LDD #$4444
	PSHU D,X,Y
	LEAU -34,U

	LDX #$31dd
	PSHU D,X,Y
	LEAU -34,U

	LDA -7,U
	ANDA #$F0
	ORA #$03
	STA -7,U
	LDD #$4444
	LDX #$5ddd
	PSHU D,X,Y
	LEAU -34,U

	LDD -8,U
	ANDA #$F0
	ORA #$0b
	LDB #$34
	STD -8,U
	LDD #$4444
	LDX #$45dd
	PSHU D,X,Y
	LEAU -34,U

	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD -8,U
	ANDA #$F0
	ORA #$01
	LDB #$c4
	STD -8,U
	LDD #$4444
	LDX #$44dd
	PSHU D,X,Y
	LEAU -36,U

	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDD #$1114
	LDX #$4444
	LDY #$44dd
	PSHU D,X,Y
	LEAU -34,U

	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDD #$1014
	PSHU D,X,Y
	LEAU -34,U

	LDA #$c1
	LDX #$b044
	PSHU D,X,Y
	LEAU -33,U

	LDD #$bc00
	LDX #$4454
	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$14
	LDX #$0444
	PSHU D,X,Y
	LEAU -34,U

	LDA -7,U
	ANDA #$F0
	ORA #$0d
	STA -7,U
	LDD #$1000
	LDX #$0044
	PSHU D,X,Y
	LEAU -34,U

	LDA -7,U
	ANDA #$F0
	ORA #$0c
	STA -7,U
	LDD -41,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDD #$1000
	LDX #$0045
	PSHU D,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$00
	STA -6,U
	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -40,U
	LDA #$10
	LDX #$00c0
	LDY #$44dd
	PSHU A,X,Y
	LEAU -35,U

	LDD #$d0bb
	LDX #$0010
	PSHU D,X,Y
	LEAU -32,U

	LDB #$dd
	STD -8,U
	LDD #$0010
	LDX #$40dd
	LDY #$ddd1
	PSHU D,X,Y
	LEAU -34,U

	LDD #$c0dd
	STD -8,U
	LDD #$0010
	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	LDD #$b0dd
	STD -8,U
	LDD #$0010
	LDX #$44dd
	PSHU D,X,Y
	LEAU -33,U

	LDD #$10dd
	LDX #$dddd
	LDY #$dd1d
	PSHU D,X,Y
	LDA #$0b
	LDX #$dd00
	PSHU A,X
	LEAU -31,U

	LDA #$10
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LDD -36,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -36,U
	LDA #$0b
	LDX #$dd00
	PSHU A,X
	LEAU -33,U

	LDA #$bd
	STA -7,U
	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDD #$dd00
	LDX #$10dd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$bd
	STA -7,U
	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDD #$dd00
	LDX #$c0dd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$bd
	STA -7,U
	LDA #$dd
	PSHU D,X,Y
	LEAU -33,U

	STY -8,U
	LDA #$00
	LDX #$dddd
	PSHU D,X,Y
	LEAU -34,U

	STX -8,U
	PSHU D,X,Y
	LEAU -34,U

	STX -8,U
	LDA #$b0
	PSHU D,X,Y
	LEAU -34,U

	STX -8,U
	LDA #$d0
	PSHU D,X,Y
	LEAU -34,U

	STX -8,U
	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD #$db00
	PSHU D,X,Y
	LEAU -36,U

	LDD #$dddd
	LDX #$db00
	LDY #$ddcd
	PSHU D,X,Y
	LEAU -33,U

	LDD -42,U
	LDA #$bd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDA #$dd
	STA -7,U
	LDD #$dddd
	LDX #$0bdd
	LDY #$cddd
	PSHU D,X,Y
	LEAU -36,U

	LDX #$dddd
	LDY #$bcdd
	PSHU A,X,Y
	LEAU -34,U

	LDX #$ddcd
	LDY #$ddbd
	PSHU D,X,Y
	LEAU -34,U

	LDX #$dddd
	LDY #$ddcd
	PSHU D,X,Y
	LEAU -34,U

	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	LDD -41,U
	LDA #$d1
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -35,U

	LDD -40,U
	LDA #$d1
	ANDB #$0F
	ORB #$10
	STD -40,U
	LDA #$dd
	PSHU A,X,Y
	LEAU -35,U

	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -40,U
	PSHU A,X,Y
	LEAU -35,U

	PSHU A,X,Y
	LEAU -33,U

	STA -7,U
	LDD #$dddd
	LDY #$ddd1
	PSHU D,X,Y
	LEAU -34,U

	LDA #$1d
	STA -7,U
	LDA #$dd
	LDX #$dd4d
	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$11
	STA -7,U
	LDA #$dd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$11
	STA -7,U
	LDD -41,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDD #$dddd
	PSHU D,X,Y
	LEAU -35,U

	LDX #$dddd
	LDY #$4ddd
	PSHU A,X,Y
	LEAU -33,U

	LDA #$cd
	STA -7,U
	LDD #$dd44
	LDX #$4ddd
	LDY #$ddd1
	PSHU D,X,Y
	LEAU -34,U

	LDA #$dc
	STA -7,U
	LDD #$dd54
	LDY #$dddd
	PSHU D,X,Y
	LEAU -34,U

	LDD -41,U
	LDA #$dd
	ANDB #$0F
	ORB #$10
	STD -41,U
	LDA #$dc
	STA -7,U
	LDD #$dd54
	PSHU D,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LDX #$d55d
	PSHU A,X,Y
	LEAU -35,U

	LDA -6,U
	ANDA #$F0
	ORA #$0d
	STA -6,U
	LDA #$dd
	LDX #$c55d
	PSHU A,X,Y
	LEAU -34,U

	LDD #$cdcd
	LDX #$51dd
	PSHU D,X,Y
	LEAU -34,U

	LDD #$dddd
	LDX #$d1dd
	PSHU D,X,Y
	LEAU -34,U

	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD #$dddc
	PSHU D,X,Y
	LEAU -36,U

	LDA -4,U
	ANDA #$F0
	ORA #$0d
	STA -4,U
	LDA #$dd
	PSHU A,Y
	LEAU -36,U

	LDB #$dd
	PSHU D,Y
	LEAU -36,U

	STD -44,U
	STD -83,U
	STD -123,U
	LDD -42,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -42,U
	LDD #$dd1d
	PSHU D,Y
	RTS

