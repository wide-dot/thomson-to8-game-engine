	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_emblemBack06_0
	LEAU -316,U

	LDA #$99
	STA 32,U
	LDA 39,U
	ANDA #$F0
	ORA #$09
	STA 39,U
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

	LDU <glb_screen_location_1
	LEAU -316,U

	LDA #$99
	STA 39,U
	STA 32,U
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
	RTS
