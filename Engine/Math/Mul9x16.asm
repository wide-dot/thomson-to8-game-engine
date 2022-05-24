; Multiply signed 9 bit (multiplier) by signed 16 bit (multiplicand)
; ------------------------------------------------------------------
; result = (product/256)
;
; input :
; d = signed 9 bit
; x = signed 16 bit
;
; output :
; d = signed 16 bit
;
; (a)    01 }
; (@m)   00 } multiplier (9 bit)
; (@m_h) 20 } 
; (@m_l) 00 } multiplicand (16 bit)
;
; Result:
; (@r0)  20 }
; (@r1)  00 } 2000 is product

        SETDP   direct_page/256

@m      equ direct_page+116
@m_h    equ direct_page+117
@m_l    equ direct_page+118
@r_h    equ direct_page+119
@r_l    equ direct_page+120
;
Mul9x16
        tsta
        beq   @pos  ; $0000 <= d <= $00FF
        bpl   @p256 ; d = $0100
        tstb
        bne   @neg  ; $FF01 >= d >= $FFFF    
@n256   tfr   x,d   ; d = $FF00
        nega
        negb
        sbca  #0
        rts
@p256
        tfr   x,d
        rts
@pos    
        stx   @m_h
        bmi   @neg2 ; multiplicand is negative
        bra   @mul
@neg    
        stx   @m_h
        bmi   @mul  ; multiplicand is negative
@neg2   negb        ; get multiplier in b
        jsr   @mul
        nega
        negb
        sbca  #0
        rts
@mul    
        lda   @m_l  ; get lsb's of multiplicand
        mul         ; multiply lsb's
        sta   @r_l  ; save partial product
        lda   @m    ; get multiplier
        ldb   @m_h  ; get msb's of multiplicand
        mul         ; multiply msb's
        addb  @r_l  ; add lsb's to msb's of previous partial product
        adca  #0    ; add carry to msb's
        stb   @r_h  ; save sum of partial products 
        ldd   @r_h
        rts
