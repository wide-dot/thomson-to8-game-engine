; ---------------------------------------------------------------------------
; Object - Messages
; input REG : [B] message index
; ---------------------------------------------------------------------------

        ldu   #bm4.images
        aslb
        ldu   b,u
        ldy   #$C000        ; video ram
        leay  128/8+94*40,y ; position : x=128 px, y=94 px
        jsr   bm4.drawChunks

        ; draw color mask
        leax  -$2000,y ; video color ram
        ldd   ,u       ; [U] was already set before bm4.drawChunks call, [B] nb of lines to draw
        sta   @bytes   ; [A] nb of bytes per line
        ldu   #line.colors
        ; compute end of dst data cmp
@row    leay  a,x
        sty   @cmpu+1
        lda   ,u+
        ; copy color to destination
@col    sta   ,x+
@cmpu
        cmpx  #0   ; end ?
        bne   @col ; not yet ...
        ; test if end of lines
        decb
        beq   >
        ; compute next line
        lda   #40
        suba  @bytes
        leax  a,x
        lda   #0
@bytes  equ   *-1
        bra   @row
!       rts

bm4.images
        fdb   bm4.img.ready
        fdb   bm4.img.game
        fdb   bm4.img.over
bm4.endImages        

bm4.img.ready
        INCLUDEBIN "./objects/messages/images/ready.rama.bin"
bm4.img.game
        INCLUDEBIN "./objects/messages/images/game.rama.bin"
bm4.img.over
        INCLUDEBIN "./objects/messages/images/over.rama.bin"

        INCLUDE "./engine/graphics/codec/bm4.drawChunbks.asm"

line.colors
        fcb   %00001000 ; orange dark
        fcb   %00010000 ; orange light
        fcb   %00011000 ; orange very light
        fcb   %00100000 ; yellow
        fcb   %00101000 ; white
        fcb   %00101000 ; white
        fcb   %00100000 ; yellow
        fcb   %00011000 ; orange very light
        fcb   %00010000 ; orange light
        fcb   %00001000 ; orange dark