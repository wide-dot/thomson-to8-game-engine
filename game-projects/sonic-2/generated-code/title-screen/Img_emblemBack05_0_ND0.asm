	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_emblemBack05_0
	LEAU -1436,U

	LDD #$9999
	STD -8,U
	LDX #$9999
	LDY #$9999
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	LDA #$d9
	STD -8,U
	LDA #$99
	PSHU D,X,Y
	LEAU -34,U

	LDA #$b9
	STD -8,U
	LDA #$99
	PSHU D,X,Y
	LEAU -34,U

	LDA #$cd
	STD -8,U
	LDA #$99
	PSHU D,X,Y
	LEAU -34,U

	LDA #$cb
	STD -8,U
	LDA #$99
	PSHU D,X,Y
	LEAU -34,U

	LDA #$cc
	STD -8,U
	LDA #$99
	PSHU D,X,Y
	LEAU -34,U

	LDA #$dc
	STD -8,U
	LDA #$99
	LDY #$999d
	PSHU D,X,Y
	LEAU -34,U

	LDA #$bd
	STD -8,U
	LDA #$99
	LDY #$99db
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8bd9
	STD -8,U
	LDD #$9999
	LDY #$99bc
	PSHU D,X,Y
	LEAU -34,U

	LDD #$88bd
	STD -8,U
	LDD #$9999
	LDY #$99cd
	PSHU D,X,Y
	LEAU -34,U

	LDD #$88cb
	STD -8,U
	LDD #$9999
	LDY #$9dc0
	PSHU D,X,Y
	LEAU -34,U

	LDD #$81dc
	STD -8,U
	LDD #$d999
	LDY #$dbd8
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8b0d
	STD -8,U
	LDD #$bd99
	LDY #$bc08
	PSHU D,X,Y
	LEAU -34,U

	LDD #$1b80
	STD -8,U
	LDD #$cb99
	LDX #$99dd
	LDY #$cc88
	PSHU D,X,Y
	LEAU -34,U

	LDD #$d888
	STD -8,U
	LDD #$ccdd
	LDX #$ddbb
	LDY #$dd88
	PSHU D,X,Y
	LEAU -34,U

	LDD #$d188
	STD -8,U
	LDD #$ddbb
	LDX #$bbcc
	LDY #$0088
	PSHU D,X,Y
	LEAU -34,U

	LDD #$bb88
	STD -8,U
	LDD #$00cc
	LDX #$cccd
	LDY #$8888
	PSHU D,X,Y
	LEAU -34,U

	LDD #$d888
	STD -8,U
	LDD #$88dd
	LDX #$ddd0
	PSHU D,X,Y
	LEAU -34,U

	LDD #$b888
	STD -8,U
	LDD #$8800
	LDX #$0008
	PSHU D,X,Y
	LEAU -34,U

	STY -8,U
	LDB #$88
	LDX #$8888
	PSHU D,X,Y
	LEAU -34,U

	LDA #$68
	STD -8,U
	LDA #$88
	PSHU D,X,Y
	LEAU -34,U

	LDA #$76
	STD -8,U
	LDA #$18
	PSHU D,X,Y
	LEAU -34,U

	LDA #$77
	STD -8,U
	LDA #$b8
	LDX #$8881
	PSHU D,X,Y
	LEAU -34,U

	LDA #$77
	STD -8,U
	LDA #$b1
	LDX #$888b
	LDY #$8886
	PSHU D,X,Y
	LEAU -34,U

	LDD #$c768
	STD -8,U
	LDD #$8d88
	LDY #$8867
	PSHU D,X,Y
	LEAU -34,U

	LDD #$dc76
	STD -8,U
	LDD #$1d88
	LDX #$888d
	LDY #$8877
	PSHU D,X,Y
	LEAU -34,U

	LDD #$bd77
	STD -8,U
	LDD #$bb88
	LDX #$881b
	LDY #$1677
	PSHU D,X,Y
	LEAU -34,U

	LDD #$cb77
	STD -8,U
	LDD #$6d88
	LDX #$8888
	LDY #$677d
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU -1436,U

	LDD #$9999
	STD -8,U
	LDX #$9999
	LDY #$9999
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	LDY #$999d
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	LDY #$999b
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	LDY #$99dc
	PSHU D,X,Y
	LEAU -34,U

	LDA #$d9
	STD -8,U
	LDA #$99
	LDY #$99bc
	PSHU D,X,Y
	LEAU -34,U

	LDA #$bd
	STD -8,U
	LDA #$99
	LDY #$99cd
	PSHU D,X,Y
	LEAU -34,U

	LDA #$cb
	STD -8,U
	LDA #$99
	LDY #$99cb
	PSHU D,X,Y
	LEAU -34,U

	LDA #$cc
	STD -8,U
	LDA #$99
	LDY #$9dd8
	PSHU D,X,Y
	LEAU -34,U

	LDA #$dc
	STD -8,U
	LDA #$99
	LDY #$dbb8
	PSHU D,X,Y
	LEAU -34,U

	LDD #$0dd9
	STD -8,U
	LDD #$9999
	LDY #$bc88
	PSHU D,X,Y
	LEAU -34,U

	LDD #$80bd
	STD -8,U
	LDD #$9999
	LDY #$cc88
	PSHU D,X,Y
	LEAU -34,U

	LDD #$88cb
	STD -8,U
	LDD #$9999
	LDX #$999d
	LDY #$cd81
	PSHU D,X,Y
	LEAU -34,U

	LDD #$88dc
	STD -8,U
	LDD #$dd99
	LDX #$99db
	LDY #$d08b
	PSHU D,X,Y
	LEAU -34,U

	LDD #$880d
	STD -8,U
	LDD #$bbdd
	LDX #$ddbc
	LDY #$088b
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8880
	STD -8,U
	LDD #$ccbb
	LDX #$bbcd
	LDY #$888d
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$ddcc
	LDX #$ccd0
	LDY #$881b
	PSHU D,X,Y
	LEAU -34,U

	LDD #$8888
	STD -8,U
	LDD #$00dd
	LDX #$dd08
	LDY #$8888
	PSHU D,X,Y
	LEAU -34,U

	STY -8,U
	LDD #$8800
	LDX #$0088
	PSHU D,X,Y
	LEAU -34,U

	STY -8,U
	LDB #$88
	LDX #$8888
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	PSHU D,X,Y
	LEAU -34,U

	STD -8,U
	LDA #$81
	LDY #$8886
	PSHU D,X,Y
	LEAU -34,U

	STX -8,U
	LDA #$8b
	LDX #$8881
	LDY #$8867
	PSHU D,X,Y
	LEAU -34,U

	LDA #$68
	STD -8,U
	LDA #$1b
	LDX #$888b
	LDY #$8877
	PSHU D,X,Y
	LEAU -34,U

	LDA #$76
	STD -8,U
	LDA #$d8
	LDX #$881b
	PSHU D,X,Y
	LEAU -34,U

	LDA #$77
	STD -8,U
	LDA #$d1
	LDX #$88dd
	LDY #$867d
	PSHU D,X,Y
	LEAU -34,U

	LDD #$c768
	STD -8,U
	LDD #$bb88
	LDX #$88db
	LDY #$67db
	PSHU D,X,Y
	LEAU -34,U

	LDD #$dc76
	STD -8,U
	LDD #$d888
	LDX #$88d8
	LDY #$77bc
	PSHU D,X,Y
	RTS
