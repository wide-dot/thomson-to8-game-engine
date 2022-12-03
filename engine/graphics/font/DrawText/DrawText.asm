; Usage :
;        position in DrawText_pos
;        ldx   #fnt_4x6_shd
;        ldy   #Text_Data
;        jsr   DrawText

DrawText
        pshs  d,u,y
@loop   ldb   ,y+
        beq   @rts
        cmpb  #32
        bge   @r_char
        cmpb  #$A
        bne   >
        jsr   [DrawText_0A]
        bra   @loop
!       cmpb  #$C
        bne   >
        jsr   [DrawText_0C]
        bra   @loop
!       cmpb  #$D
        bne   @loop
        jsr   [DrawText_0D]
        bra   @loop
@r_char clra
        subb  #32
        aslb
        ldu   #0
DrawText_pos equ   *-2
        jsr   [d,x]
        inc   DrawText_pos+1
        bne   @loop
        inc   DrawText_pos
        bra   @loop
@rts    puls  d,u,y,pc

DrawText_start_pos fdb 0
DrawText_0A fdb @rts
DrawText_0C fdb @rts
DrawText_0D fdb @rts
@rts    rts

; Value to convert is in register A
; Writes 2 ascii values at register y location

HexToText
        tfr   a,b
        lsra
        lsra
        lsra
        lsra
        jsr   @htt
        tfr   b,a
@htt       
        anda  #$0F
        cmpa  #$0A
	blo   >
	adda  #7
!
	adda  #48
	sta   ,y+
	rts