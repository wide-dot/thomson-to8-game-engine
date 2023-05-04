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

_engine.world.updated MACRO
        jmp   engine.routines.endUpdate
 ENDM

_engine.gfx.rendered MACRO
        jmp   engine.routines.endRender
 ENDM    

_engine.main.setRoutines MACRO
        ldd #\1
        std engine.routines.update
        ldd #\2
        std engine.routines.render
        jmp engine.main.loop
 ENDM

        _engine.main.setRoutines gamemode.update,gamemode.render
        jmp engine.main.loop

gamemode.update
        jsr   VerticalScrollMoveUp
        _engine.world.updated

gamemode.render
        jsr   VerticalScroll                           
        _engine.gfx.rendered




engine.main.loop
        jmp $1234 ; wll be replaced
engine.routines.update EQU *-2
engine.routines.endUpdate
        _gfxlock.on
        jmp $1234 : will be replaced
engine.routines.render EQU *-2
engine.routines.endRender                                  
        _gfxlock.off
        _gfxlock.loop     
        bra engine.main.loop   

        
UserIRQ
        jsr   gfxlock.bufferSwap.check
        rts


* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/scrollscreen/ram-data.asm"
        
* ============================================================================== * Routines
* ==============================================================================
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/graphics/tilemap/vertical-scroll/scrolling.asm"
        INCLUDE "./global/global-trailer-includes.asm"
        