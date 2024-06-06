
        INCLUDE "./engine/macros.asm"

        bmi   @update
        pshs  u
        ldx   #Snd_index
        asla
        ldx   a,x
@init
        stb   YVGM_loop
        stx   YVGM_MusicData
        sty   YVGM_callback            ; bind the callback routine
        _GetCartPageA
        sta   YVGM_MusicPage
        lda   #1
        sta   YVGM_MusicStatus
        sta   YVGM_WaitFrame
        ldu   #YM2413_buffer
        stu   YVGM_MusicDataPos
        leax  2,x                      ; skip first two bytes (offset for looping)
        jsr   ym2413zx0_decompress
        puls  u,pc
@update
        pshs  u
        lda   YVGM_MusicStatus
        beq   @rts
        dec   YVGM_WaitFrame
        bne   @rts
        ldx   YVGM_MusicData
        beq   @rts
        jsr   YVGM_do_MusicFrame
@rts    puls  u,pc

        INCLUDE "./engine/sound/YM2413vgm.asm"