DEBUG EQU 1

VS_buffer_size EQU 192 

        INCLUDE "./global/global-preambule-includes.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"

        org   $6100

        opt cd


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

        lda   #1
        sta   VS_scroll_step

        lda   #10
        sta   VS_viewport_line_pos
        lda   #190
        sta   VS_viewport_size
        jsr   VerticalScrollUpdateViewport

Engine.world.updated MACRO
        jmp   Engine.routines.end_update
 ENDM

Engine.gfx.rendered MACRO
        jmp   Engine.routines.end_render
 ENDM    

Engine.MainLoop.setRoutines MACRO
        ldd \1
        std Engine.routines.update
        ldd \2
        std Engine.routines.render
        jmp Engine.MainLoop
 ENDM

        Engine.MainLoop.setRoutines #UpdateRoutine,#RenderRoutine
        jmp Engine.MainLoop

UpdateRoutine
        jsr   VerticalScrollMoveUp
        Engine.world.updated

RenderRoutine
        jsr   VerticalScroll                           
        Engine.gfx.rendered


UserIRQ
        jsr   gfxlock.bufferSwap.check
        rts


Engine.MainLoop
        jmp $1234 ; wll be replaced
Engine.routines.update EQU *-2
Engine.routines.end_update
        _gfxlock.on
        jmp $1234 : will be replaced
Engine.routines.render EQU *-2
Engine.routines.end_render                                  
        _gfxlock.off
        _gfxlock.loop     
        bra Engine.MainLoop   
     
* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/scrollscreen/ram-data.asm"
        
* ============================================================================== * Routines
* ==============================================================================
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/graphics/tilemap/vertical-scroll/scrolling.asm"
        INCLUDE "./global/global-trailer-includes.asm"
        