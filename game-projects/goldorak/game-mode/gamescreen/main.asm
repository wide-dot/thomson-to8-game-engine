OverlayMode equ 1

        INCLUDE "./global/global-preambule-includes.asm"

        org   $6100


* ============================================================================== 
* Init
* ============================================================================== 
        _GameModeInit #GmID_gamescreen
        _MusicInit_SN76489 #Vgc_ingameSN,#MUSIC_LOOP,#0                  ; initialize the SN76489 player
        _MusicInit_YM2413 #Vgc_ingameYM,#MUSIC_LOOP,#0                   ; initialize the YM2413 player 
        _MusicInit_IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame         ; Setting IRQ for music

        _SetPalette #Palette_gamescreen
        _ShowPalette
        #_PaletteFade #Pal_black,#Palette_gamescreen,Obj_PaletteFade,#$20

* load object
        _NewManagedObject_U #ObjID_Goldorak
        _NewManagedObject_U #ObjID_Cockpit


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
        