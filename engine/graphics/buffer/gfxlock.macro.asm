* =============================================================================
* macros
* =============================================================================

_gfxlock.init MACRO
        lda   #-1
        sta   gfxlock.status
        lda   gfxlock.backBuffer.status  ; init backBuffer.id based on backBuffer.status
        anda  #%00000001
        sta   gfxlock.backBuffer.id      ; id is 0 or 1
 ENDM

_gfxlock.on MACRO
        lda   gfxlock.status
        bne   >
        jsr   gfxlock.bufferSwap.wait   ; wait if second gfx frame is reached
!       lda   #1
        sta   gfxlock.status
        ldb   gfxlock.backBuffer.status ; always 0 or -1 (flip/flop)
        andb  #%00000001                ; set bit 0 based on flip/flop
        orb   #%00000010                ; value should be 2 or 3
        stb   map.CF74021.DATA          ; mount working video buffer in RAM
        ldb   map.MC6846.PRC
        eorb  #%00000001                ; swap half-page in $4000 $5FFF
        stb   map.MC6846.PRC
 ENDM

_gfxlock.off MACRO
        clr   gfxlock.status
 ENDM

_gfxlock.loop MACRO
        lda   gfxlock.backBuffer.id     ; switch id at the end of gfxlock
        eora  #%00000001
        sta   gfxlock.backBuffer.id
        ldd   gfxlock.frame.count
        subd  gfxlock.frame.lastCount
        stb   gfxlock.frameDrop.count   ; store the number of elapsed 50Hz frames since last main game loop
        ldd   gfxlock.frame.count
        std   gfxlock.frame.lastCount
 ENDM

_gfxlock.backProcess.on MACRO
        ; param 1 : routine address
        ldd   #\1
        std   gfxlock.backProcess
        lda   #1
        sta   gfxlock.backProcess.status
 ENDM

_gfxlock.backProcess.off MACRO
        clr   gfxlock.backProcess.status
 ENDM
