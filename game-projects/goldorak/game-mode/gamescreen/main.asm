OverlayMode equ 1
DEBUG EQU 1

        INCLUDE "./global/global-preambule-includes.asm"

        org   $6100

        opt cd


* ============================================================================== 
* Init
* ============================================================================== 
        _gameMode.init #GmID_gamescreen
        _music.init.SN76489 #Vgc_ingameSN,#MUSIC_LOOP,#0                 ; initialize the SN76489 player
        _music.init.YM2413 #Vgc_ingameYM,#MUSIC_LOOP,#0                  ; initialize the YM2413 player 
        _music.init.IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame         ; Setting IRQ for music
        _palette.set #Palette_gamescreen
        _palette.show
        
        #_PaletteFade #Pal_black,#Palette_gamescreen,Obj_PaletteFade,#$20

* load object
        _objectManager.new.u #ObjID_Goldorak
        _objectManager.new.u #ObjID_Cockpit


* init scroll
        lda   #ObjID_scrollA
        sta   VS_ObjIDA
        lda   #ObjID_scrollB
        sta   VS_ObjIDB

        lda   #2
        sta   VS_scroll_step

        lda   #0
        sta   VS_viewport_line_pos
        lda   #190
        sta   VS_viewport_size
        jsr   VerticalScrollUpdateViewport

* ============================================================================== * Main Loop
* ==============================================================================
LevelMainLoop
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   VerticalScrollMoveUp
        jsr   VerticalScroll                        
        jsr   BuildSprites        
        jsr   WaitVBL
        bra   LevelMainLoop

UserIRQ        
        jsr   PalUpdateNow
        jsr   YVGM_MusicFrame
        jmp   vgc_update

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/gamescreen/gamescreenRamData.asm"
        
* ============================================================================== * Routines
* ==============================================================================
        INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"
        INCLUDE "./engine/graphics/codec/DecRLE00.asm"
        INCLUDE "./engine/graphics/codec/zx0_mega.asm" 
        INCLUDE "./engine/graphics/tilemap/vertical-scroll/scrolling.asm"

        INCLUDE "./engine/palette/color/Pal_black.asm"

        INCLUDE "./global/global-trailer-includes.asm"
        