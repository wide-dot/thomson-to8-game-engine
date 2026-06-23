* =============================================================================
* macros
* =============================================================================

_gfxlock.init MACRO
        lda   #-1
        sta   gfxlock.status
        lda   gfxlock.backBuffer.status  ; init backBuffer.id based on backBuffer.status
        anda  #%00000001
        sta   gfxlock.backBuffer.id      ; id is 0 or 1
        clr   gfxlock.frameDrop.max      ; no frame-drop cap by default; a game may set it after init
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
        lda   gfxlock.backBuffer.id     ; switch back buffer id at the end of gfxlock
        eora  #%00000001
        sta   gfxlock.backBuffer.id
        ldd   gfxlock.frame.count
        subd  gfxlock.frame.lastCount   ; b = elapsed 50Hz frames since last loop (frame-drop)
        tst   gfxlock.frameDrop.max     ; 0 = no cap (default) -> behaviour strictly unchanged
        beq   >
        cmpb  gfxlock.frameDrop.max
        bls   >
        ldb   gfxlock.frameDrop.max     ; cap: never compensate more than one render step can show
!       stb   gfxlock.frameDrop.count   ; store the number of elapsed 50Hz frames since last main game loop
        ldd   gfxlock.frame.count
        std   gfxlock.frame.lastCount
        ; level-timeline clock kept in step with the rendered world (capped frame-drop).
        ; no cap (max=0) -> equals frame.count exactly, so timeline behaviour is unchanged.
        ldb   gfxlock.frameDrop.count
        clra
        addd  gfxlock.frame.gameCount
        tst   gfxlock.frameDrop.max
        bne   >
        ldd   gfxlock.frame.count
!       std   gfxlock.frame.gameCount
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
