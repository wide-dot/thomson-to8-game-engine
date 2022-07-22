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
; (a)  20 }
; (b)  00 } 2000 is product/256

        SETDP   dp/256

@m      equ dp_engine+25
@m_h    equ dp_engine+26
@m_l    equ dp_engine+27
@r_h    equ dp_engine+28
@r_l    equ dp_engine+29
@r      equ dp_engine+30
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
        sbca  #0    ; *-1
        rts
@p256
        tfr   x,d   ; *1
        rts
@pos                
        stb   @m    ; positive multiplier
        stx   @m_h
        bpl   @mul  ; positive result
        ldd   @m_h  ; negative multiplicand
        nega
        negb
        sbca  #0
        std   @m_h
        ldb   @m
@neg1   bsr   @mul
        coma        ; negative result
        comb
        neg   @r
        bne   >
        addd  #1
!       rts
@neg    
        negb        ; negative multiplier
        stb   @m
        stx   @m_h
        bpl   @neg1 ; positive multiplicand
        ldd   @m_h  ; negative multiplicand and positive result
        nega
        negb
        sbca  #0
        std   @m_h
        ldb   @m
@mul 
        lda   @m_l  ; get lsb's of multiplicand
        mul         ; multiply lsb's
        std   @r_l  ; save partial product
        lda   @m    ; get multiplier
        ldb   @m_h  ; get msb's of multiplicand
        mul         ; multiply msb's
        addb  @r_l  ; add lsb's to msb's of previous partial product
        adca  #0    ; add carry to msb's
        ;std   @r_h  ; save sum of partial products 
        rts
