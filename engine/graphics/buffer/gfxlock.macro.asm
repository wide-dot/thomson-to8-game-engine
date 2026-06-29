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
        andb  #%00000001                ; B = parite buffer (bit 0)
        pshs  b                          ; garde la parite
        orb   #%00000010                ; value should be 2 or 3
        stb   map.CF74021.DATA          ; mount working video buffer in RAM ($A000)
        ; PRC ($4000-$5FFF, demi-page des cellules de backup) : pose en ABSOLU sur la
        ; parite buffer (comme DATA) au lieu d'un toggle relatif. Le toggle derivait si le
        ; registre matériel etait stale (ex: entree titlescreen depuis un autre game-mode :
        ; les registres video ne sont pas reinit par le load RAM) -> save/restore des
        ; cellules sur des demi-pages differentes -> backup corrompu / crash. L'absolu est
        ; robuste a tout etat initial du registre.
        ldb   map.MC6846.PRC
        andb  #%11111110                ; preserve les autres bits du 6846, efface bit 0
        orb   ,s+                        ; bit 0 = parite buffer
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
