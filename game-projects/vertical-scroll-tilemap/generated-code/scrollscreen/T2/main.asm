	INCLUDE "./generated-code/scrollscreen/ObjectId.glb"
	INCLUDE "./generated-code/Game.glb"

OverlayMode equ 1
DEBUG EQU 1

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
        lda   #120
        sta   VS_viewport_size
        jsr   VerticalScrollUpdateViewport

* ============================================================================== * Main Loop
* ==============================================================================
LevelMainLoop
        jsr   VerticalScrollMoveUp
        _gfxlock.on
        jsr   VerticalScroll                           
        _gfxlock.off
        _gfxlock.loop
        bra   LevelMainLoop


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
        
	INCLUDE "./generated-code/scrollscreen/BuilderMainGenCode.asm"
