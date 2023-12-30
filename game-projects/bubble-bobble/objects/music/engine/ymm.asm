
        INCLUDE "./engine/macros.asm"

        bmi   @update
        ldx   #Snd_index
        asla
        ldx   a,x
@init
        stb   YVGM_loop
        stx   YVGM_MusicData
        sty   YVGM_callback            ; bind the callback routine
        lda   #1
        sta   YVGM_MusicStatus
        sta   YVGM_WaitFrame
        ldu   #YM2413_buffer
        stu   YVGM_MusicDataPos
        jmp   ym2413zx0_decompress
@update
        lda   YVGM_MusicStatus
        bne   @a
        rts    
@a      lda   YVGM_WaitFrame
        deca
        sta   YVGM_WaitFrame
        beq   @UpdateMusic
        rts
@UpdateMusic
        ldx   YVGM_MusicData
        bne   YVGM_do_MusicFrame
        rts

        INCLUDE "./objects/music/engine/YM2413vgm-dyn.asm"