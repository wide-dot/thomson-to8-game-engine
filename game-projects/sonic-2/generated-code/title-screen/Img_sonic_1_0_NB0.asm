	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_1_0
	STS glb_register_s

	LEAS ,Y
	LEAU 644,U

	LDX -79,U
	LDY -38,U
	PSHS Y,X
	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$cd
	STD -40,U
	LDD #$dddd
	STD -79,U
	STD -38,U
	PULU X,Y
	PSHS U,Y,X
	LDX #$dddd
	PSHU D,X
	LEAU 40,U

	LDA 37,U
	LDB 4,U
	PSHS B,A
	ANDB #$0F
	ORB #$d0
	STB 4,U
	LDA #$11
	STA 37,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$cddd
	LDX #$dddd
	PSHU D,X
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 39,U
	LDA 37,U
	STB 37,U
	PULU B,X,Y
	PSHS U,Y,X,B,A
	LDA #$dd
	LDX #$dddd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 41,U

	LDA 36,U
	PSHS A
	LDA #$dd
	STA 36,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$dddd
	LDX #$dddd
	PSHU D,X
	LEAU 38,U

	LDD 38,U
	PSHS D
	LDA #$5d
	ANDB #$0F
	ORB #$10
	STD 38,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dcdd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$cddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 38,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$5dd1
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$dd
	STD 40,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$55dd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 42,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$dd
	STD 38,U
	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$dddd
	LDY #$dddd
	PSHU B,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$dd
	STD 38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$dddd
	LDY #$dddd
	PSHU B,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$dd
	STD 38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$dddd
	LDY #$dddd
	PSHU B,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$dd
	STD 38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$dddd
	LDY #$dddd
	PSHU B,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$dddd
	LDY #$dddd
	PSHU B,X,Y
	LEAU 38,U

	LDA 6,U
	PSHS A
	LDA #$d1
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$15dd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$d1
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$15dd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$11
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$11dd
	LDX #$dddd
	LDY #$dd1d
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$11
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$11dd
	LDX #$dddd
	LDY #$ddd1
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$11
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$11dd
	LDX #$dddc
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$11
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddc
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$1ddd
	LDX #$ddcb
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$ddcb
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$ddcb
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	STB 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$ddcb
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	STB 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddc
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	STB 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddc
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 6,U
	PSHS D
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STD 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dcdd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dbdd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dbdd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dbdd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d0cd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d0bd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d00d
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	LDA 8,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 8,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d0bd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	LDA 8,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 8,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d0c1
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	LDA 8,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 8,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d0c1
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	LDA 8,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 8,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d0b1
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	LDA 8,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 8,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d0c1
	LDX #$d4dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d0c1
	LDX #$44dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 6,U

	PULU A,X
	PSHS U,X,A
	LDA #$dd
	PSHU A,Y
	LEAU 34,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d0c1
	LDX #$40dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 6,U

	PULU A,X
	PSHS U,X,A
	LDA #$dd
	PSHU A,Y
	LEAU 34,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d001
	LDX #$004d
	LDY #$dddd
	PSHU D,X,Y
	LEAU 6,U

	PULU A,X
	PSHS U,X,A
	LDA #$11
	LDX #$1111
	PSHU A,X
	LEAU 34,U

	LDA 6,U
	PSHS A
	LDA #$d1
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d001
	LDX #$444d
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$0b
	LDB #$00
	STD 40,U
	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$d001
	LDX #$444d
	LDY #$dddd
	PSHU D,X,Y
	LEAU 42,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0c
	LDB #$0c
	STD 38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$44
	LDX #$4ddd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$44
	LDX #$45dd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 39,U

	LDA 6,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$0444
	LDX #$45dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 39,U

	LDD 6,U
	PSHS D
	LDA #$dd
	ANDB #$0F
	ORB #$c0
	STD 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$1144
	LDX #$4545
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$1144
	LDX #$5445
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$1144
	LDX #$4443
	LDY #$dddd
	PSHU D,X,Y
	LEAU 41,U

	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4444
	LDX #$34dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4444
	LDX #$40dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4444
	LDX #$40dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$45
	STD 40,U
	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$5444
	LDX #$00dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 42,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$04
	LDX #$dddd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 39,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$44
	STD 40,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$5344
	LDX #$dddd
	LDY #$11dd
	PSHU D,X,Y
	LEAU 42,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$44
	STD 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$dddd
	LDX #$1111
	PSHU D,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDX #$dd11
	PSHU B,X
	LEAU 38,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$34
	LDX #$44dd
	LDY #$ddd1
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$44
	LDX #$45dd
	LDY #$ddd1
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$44
	LDX #$41dd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$44
	LDX #$51dd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 40,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$44
	LDX #$33dd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$44
	STD 39,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$35dd
	LDY #$dddd
	PSHU B,X,Y
	LEAU 41,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$44
	STD 38,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$55dd
	LDX #$dddd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDA #$54
	LDX #$dddd
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 604,U

	LDD -40,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -40,U
	LDA -38,U
	STB -38,U
	PULU B,X
	PSHS U,X,B,A
	LDA #$dc
	LDX #$dddd
	PSHU A,X
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 39,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$cddd
	LDX #$dddd
	PSHU D,X
	LEAU 41,U

	PULU A,X
	PSHS U,X,A
	LDX #$dddd
	PSHU B,X
	LEAU 38,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	LDA 38,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA 38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$dc
	LDX #$dddd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 40,U

	LDA 38,U
	PSHS A
	LDA #$d1
	STA 38,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$cddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	LDA #$dd
	ANDB #$F0
	ORB #$0d
	STD 38,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$dddd
	LDY #$dddd
	PSHU B,X,Y
	LEAU 38,U

	LDD 6,U
	PSHS D
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddc
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd1d
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	STB 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$d1
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4ddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4ddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4ddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4ddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4ddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4ddd
	LDX #$dddd
	LDY #$ddd1
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$1ddd
	LDX #$dddd
	LDY #$dd11
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dd11
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$ddcd
	LDY #$dd11
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dd0d
	LDY #$ddd1
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dd0c
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 39,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$ddbc
	LDY #$dddd
	PSHU D,X,Y
	LEAU 41,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 38,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$ddbc
	LDY #$dddd
	PSHU B,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 38,U
	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$ddcd
	LDY #$dddd
	PSHU B,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$cd
	STD 38,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$cddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$bd
	STD 38,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 38,U

	LDX 6,U
	PSHS X
	STD 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd0c
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	LDA 8,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 8,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd0b
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	LDA 8,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 8,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd00
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	LDA 8,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 8,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd00
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd00
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 6,U

	PULU A,X
	PSHS U,X,A
	LDA #$dd
	PSHU A,Y
	LEAU 34,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd00
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 6,U

	PULU A,X
	PSHS U,X,A
	LDA #$dd
	PSHU A,Y
	LEAU 34,U

	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd00
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 6,U

	LDD 34,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$00
	STD 34,U
	PULU A,X
	PSHS U,X,A
	LDA #$dd
	PSHU A,Y
	LEAU 36,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$00
	STD 38,U
	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$00
	STD 38,U
	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$00
	STD 38,U
	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dddd
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$00
	STD 38,U
	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd4d
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$0d
	LDB #$00
	STD 38,U
	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd44
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$dd44
	LDX #$dddd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 39,U

	LDX 6,U
	PSHS X
	LDD #$1111
	STD 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$00d4
	LDX #$44dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$11
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$00d4
	LDX #$44dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$11
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$0044
	LDX #$44dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$cd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$0044
	LDX #$54dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDA 6,U
	PSHS A
	LDA #$dc
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$0044
	LDX #$44dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 39,U

	LDX 6,U
	PSHS X
	LDD #$dddc
	STD 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$ccb0
	LDX #$4444
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$cbc4
	LDX #$4444
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$1154
	LDX #$4444
	LDY #$dddd
	PSHU D,X,Y
	LEAU 40,U

	LDX 6,U
	PSHS X
	STY 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$1154
	LDX #$4444
	LDY #$3ddd
	PSHU D,X,Y
	LEAU 41,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$44
	STD 40,U
	LDA 6,U
	PSHS A
	LDA #$dd
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$5444
	LDX #$445d
	LDY #$dddd
	PSHU D,X,Y
	LEAU 42,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$44
	STD 38,U
	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$45
	LDX #$43dd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$43
	LDX #$43dd
	LDY #$dddd
	PSHU A,X,Y
	LEAU 39,U

	LDA 6,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$4454
	LDX #$43dd
	LDY #$d1dd
	PSHU D,X,Y
	LEAU 40,U

	LDD 40,U
	PSHS D
	ANDA #$F0
	ORA #$05
	LDB #$44
	STD 40,U
	LDA 6,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 6,U
	PULU D,X,Y
	PSHS U,Y,X,D
	LDD #$5434
	LDX #$43dd
	LDY #$dddd
	PSHU D,X,Y
	LEAU 42,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$43dd
	LDX #$dddd
	PSHU D,X
	LEAU 39,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$44
	LDX #$4ddd
	LDY #$dd11
	PSHU A,X,Y
	LEAU 40,U

	LDA 4,U
	PSHS A
	ANDA #$0F
	ORA #$10
	STA 4,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$443d
	LDX #$dddd
	PSHU D,X
	LEAU 40,U

	PULU X,Y
	PSHS U,Y,X
	LDB #$1d
	LDX #$dddd
	PSHU D,X
	LEAU 40,U

	LDD 39,U
	PSHS D
	ANDA #$F0
	ORA #$03
	LDB #$44
	STD 39,U
	PULU X,Y
	PSHS U,Y,X
	LDD #$441d
	LDX #$dddd
	PSHU D,X
	LEAU 41,U

	LDD 38,U
	PSHS D
	ANDA #$F0
	ORA #$04
	LDB #$44
	STD 38,U
	PULU A,X
	PSHS U,X,A
	LDA #$3d
	LDX #$dddd
	PSHU A,X
	LEAU 40,U

	PULU A,X
	PSHS U,X,A
	LDA #$5d
	LDX #$dddd
	PSHU A,X
	LEAU 38,U

	PULU A,X,Y
	PSHS U,Y,X,A
	LDA #$54
	LDX #$445d
	LDY #$dddd
	PSHU A,X,Y
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$454d
	LDY #$dddd
	PSHU B,X,Y
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$434d
	LDY #$dddd
	PSHU B,X,Y
	LEAU 40,U

	LDA 5,U
	PSHS A
	ANDA #$0F
	ORA #$d0
	STA 5,U
	PULU A,X,Y
	PSHS U,Y,X,A
	LDX #$534d
	LDY #$dddd
	PSHU B,X,Y
	LEAU ,S
SSAV_Img_sonic_1_0
	LDS glb_register_s
	RTS
