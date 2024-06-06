
        INCLUDE "./engine/macros.asm"

        bmi   @update
        pshs  u
        ldx   #Snd_index
        asla
        ldx   a,x
@init
        stb   vgc_loop
        stx   vgc_source               ; stash the data source addr for looping
        sty   vgc_callback             ; bind the callback routine
        _GetCartPageA
        sta   vgc_source_page
        lda   #vgc_stream_buffers/256  ; HI byte of a page aligned 2Kb RAM buffer address
        sta   vgc_buffers              ; stash the 2kb buffer address
        leax  2,x                      ; skip first two bytes (offset for looping)
        jsr   vgc_stream_mount         ; prepare the data for streaming (passed in X)
        puls  u,pc
@update
        pshs  u
        lda   vgc_finished
        bne   @rts    
        ldx   vgc_source
        beq   @rts
        jsr   vgc_do_update
@rts    puls  u,pc

        INCLUDE "./engine/sound/vgc/lib/vgcplayer.h.asm"
        INCLUDE "./engine/sound/vgc/lib/vgcplayer.asm"

vgc_stream_buffers equ (*&$FF00)+$100 ; cannot align in objects due to placement optimization
        fill 0,256*9                  ; added one 256 chunk to do manual alignment
