DEBUG EQU 1

VS_buffer_size EQU 192 

        INCLUDE "./global/global-preambule-includes.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./engine/main/main.macro.asm"

        org   $6100

        opt cd,cc


* ============================================================================== 
* Init
* ============================================================================== 
        _gameMode.init #GmID_scrollscreen
        _gfxlock.init
        _IRQ.init #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame
        _palette.set #Palette_scrollscreen
        _palette.show
        
* init scroll
        lda   #ObjID_scrollA
        sta   VS_ObjIDA
        lda   #ObjID_scrollB
        sta   VS_ObjIDB

        ldd   #$0080
        std   VS_scroll_step

        lda   #10
        sta   VS_viewport_line_pos
        lda   #190
        sta   VS_viewport_size
        jsr   VerticalScrollUpdateViewport

        _main.setUpdateRoutine gamemode.update
        _main.setRenderRoutine gamemode.render
        _main.loop.run      

gamemode.update
        jsr   VerticalScrollMoveUp
        _main.update.return

gamemode.render
        jsr   VerticalScroll                           
        _main.render.return

        
UserIRQ
        jsr   gfxlock.bufferSwap.check
        rts


* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/scrollscreen/ram-data.asm"
        
* ============================================================================== * Routines
* ==============================================================================
        INCLUDE "./engine/main/main.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/graphics/tilemap/vertical-scroll/scrolling.asm"
        INCLUDE "./global/global-trailer-includes.asm"
        