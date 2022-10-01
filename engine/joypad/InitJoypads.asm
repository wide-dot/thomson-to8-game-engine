
; $E7CE/$E7CF (bit 2) allow selection of a register in $E7CC/$E7CD:
; (bit2) 0: Data Direction Register A (DDRA)
; (bit2) 1: Peripherial Interface A (PIA) Register

InitJoypads
        ; configure MC6821 to be able to read joypads (1&2) direction
	lda   $E7CE  ; read Control Register A (CRA)
	anda  #$FB   ; unset bit 2 
	sta   $E7CE  ; select Data Direction Register A (DDRA)
	andb  #0     ; unset all bits
	stb   $E7CC  ; Peripherial Interface A (PIA) lines set as input
	ora   #$04   ; set b2
	sta   $E7CE  ; select Peripherial Interface A (PIA) Register

        ; configure MC6821 to be able to read joypads (1&2) buttons
	lda   $E7CF  ; read Control Register B (CRB)
	anda  #$FB   ; unset bit 2 
	sta   $E7CF  ; select Data Direction Register B (DDRB)
	;ldb   #$3F  ; set DAC bits (0-5)
	;stb   $E7CD ; DAC bits set as output
        andb  #0     ; unset all bits
        stb   $E7CD  ; Peripherial Interface B (PIB) lines set as input
	ora   #$04   ; set b2
	sta   $E7CF  ; select Peripherial Interface B (PIB) Register
        rts
