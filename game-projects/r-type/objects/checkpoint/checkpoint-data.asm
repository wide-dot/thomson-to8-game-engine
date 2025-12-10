; Checkpoints locations

; stage 1
	fdb   $0000 ; $0600
	fdb   $0048 ; $06C0 3*24px	
	fdb   $01B0 ; $0A80 18*24px
	fdb   $03A8 ; $0FC0 39*24px

; stage 2
	fdb   $0000 ; $1500
	fdb   $01F8 ; $1A40 21*24px

; stage 3
	fdb   $0000 ; $1F80

; stage 4
	fdb   $0000 ; $2A00
	fdb   $01F8 ; $2F40 21*24px

; stage 5
	fdb   $0000 ; $3480
	fdb   $0358 ; $3AC0 35*24px

; stage 6
	fdb   $0000 ; $3F00
	fdb   $0258 ; $4540 25*24px		

; stage 7
	fdb   $0000 ; $4980
	fdb   $0210 ; $4F00 22*24px

; stage 8
	fdb   $0000 ; $5400


