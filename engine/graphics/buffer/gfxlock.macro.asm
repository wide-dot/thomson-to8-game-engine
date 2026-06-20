* =============================================================================
* macros
* =============================================================================

_gfxlock.init MACRO
        lda   #-1
        sta   gfxlock.status
        lda   gfxlock.backBuffer.status  ; init backBuffer.id based on backBuffer.status
        anda  #%00000001
        sta   gfxlock.backBuffer.id      ; id is 0 or 1
        clr   gfxlock.singleBuffer       ; always boot in double-buffer mode
        clr   <glb_sprite_erase_off      ; ... with normal sprite erasing
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
        tst   gfxlock.singleBuffer      ; single buffer: freeze the $4000-$5FFF half-page
        bne   >                         ;   too (it holds the sprite-backup BBC cells) so
        ldb   map.MC6846.PRC            ;   it stays on the same physical bank as the frozen
        eorb  #%00000001                ;   pool id. Otherwise cells are written to one bank
        stb   map.MC6846.PRC            ;   and read back from the other -> garbage restore.
!
 ENDM

_gfxlock.off MACRO
        clr   gfxlock.status
 ENDM

_gfxlock.loop MACRO
        tst   gfxlock.singleBuffer      ; single buffer: keep the same back buffer id
        bne   >                         ;   (in lockstep with the frozen page)
        lda   gfxlock.backBuffer.id     ; switch id at the end of gfxlock
        eora  #%00000001
        sta   gfxlock.backBuffer.id
!       ldd   gfxlock.frame.count
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

_gfxlock.singleBuffer.on MACRO
        ; freeze the display on the current working page (single buffering): the next
        ; render is shown directly, no swap. A full-screen effect then writes a single
        ; page (no per-buffer replay), roughly halving the cost.
        lda   #1
        sta   gfxlock.singleBuffer
 ENDM

_gfxlock.singleBuffer.off MACRO
        ; resume double buffering. The hidden page and the other buffer id still hold
        ; stale content, so force a full tile + sprite refresh to resync them. The
        ; flags are optional (a game without scrolling may not define them), hence the
        ; IFDEF guards - if absent at build, this simply does nothing extra.
        clr   gfxlock.singleBuffer
 IFDEF glb_camera_move
        lda   #1
        sta   glb_camera_move            ; redraw the whole tilemap next frame
 ENDC
 IFDEF glb_force_sprite_refresh
        lda   #1
        sta   <glb_force_sprite_refresh  ; full sprite refresh next frame
 ENDC
 ENDM
