; Checkpoints locations

; stage 1
	fdb   $0000 ; $0600
	fdb   $0048 ; $06C0
	fdb   $01B0 ; $0A80
	fdb   $03A8 ; $0FC0

; stage 2
	fdb   $0000 ; $1500
	fdb   $01F8 ; $1A40

; stage 3
	fdb   $0000 ; $1F80

; stage 4
	fdb   $0000 ; $2A00
	fdb   $01F8 ; $2F40

; stage 5
	fdb   $0000 ; $3480
	fdb   $0358 ; $3AC0

; stage 6
	fdb   $0000 ; $3F00
	fdb   $0258 ; $4540		

; stage 7
	fdb   $0000 ; $4980
	fdb   $0210 ; $4F00

; stage 8
	fdb   $0000 ; $5400


