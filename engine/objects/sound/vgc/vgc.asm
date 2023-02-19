
        INCLUDE "./engine/macros.asm"

        bmi   @update
        ldx   #Snd_index
        asla
        ldx   a,x
@init
        stb   vgc_loop
        stx   vgc_source               ; stash the data source addr for looping
        sty   vgc_callback             ; bind the callback routine
        lda   #vgc_stream_buffers/256  ; HI byte of a page aligned 2Kb RAM buffer address
        sta   vgc_buffers              ; stash the 2kb buffer address
        jmp   vgc_stream_mount         ; Prepare the data for streaming (passed in X)
@update
        lda   vgc_finished
        bne   @rts    
        ldx   vgc_source
        bne   vgc_do_update
@rts    rts                            ; no music to play

        INCLUDE "./engine/sound/vgc/lib/vgcplayer.h.asm"
        INCLUDE "./engine/sound/vgc/lib/vgcplayer.asm"

vgc_stream_buffers equ (*&$FF00)+$100 ; cannot align in objects due to placement optimization
        fill 0,256*9                  ; added one 256 chunk to do manual alignment
