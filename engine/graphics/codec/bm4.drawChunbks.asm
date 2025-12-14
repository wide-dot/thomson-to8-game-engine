;-----------------------------------------------------------------
; bm4.drawChunks
; input  REG : [U] source
; input  REG : [Y] destination
;-----------------------------------------------------------------
; draw chunky bm4 image
;----------------------------------------------------------------- 

bm4.drawChunks
        pshs  d,x,y,u

        ldd   ,u++
        sta   @bytes ; [A] nb of bytes per line
        stb   @nbln ; [B] nb of lines to draw
@drawline
        ; compute end of src data cmp
        leax  a,u
        stx   @cmpu+2
;
        ; is nb of bytes to copy an odd value ?
        lsra
        bcc   >
        pulu  b
        stb   ,y+
!
        ; is nb of bytes to copy a multiple of 2 ?
        lsra
        bcc   >
        pulu  x
        stx   ,y++
!
        ; is nb of bytes to copy a multiple of 4 ?
        lsra
        bcc   @cmpu
        pulu  d,x
        std   ,y++
        stx   ,y++
        bra   @cmpu
;
        ; process bytes by multiple of 8
!       pulu  d,x
        std   ,y  
        stx   2,y 
        pulu  d,x 
        std   4,y
        stx   6,y
        leay  8,y
@cmpu
        cmpu  #0  ; end ?
        bne   <   ; not yet ...
;
        ldb   #0
@nbln   equ   *-1        
        dec   @nbln
        beq   >
        lda   #40
        suba  @bytes
        leay  a,y
        lda   #0
@bytes  equ   *-1
        bra   @drawline
!
        puls  d,x,y,u,pc
