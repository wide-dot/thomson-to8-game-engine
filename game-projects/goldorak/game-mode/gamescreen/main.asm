OverlayMode equ 1
DEBUG EQU 1

        INCLUDE "./global/global-preambule-includes.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"

        org   $6100

        opt cd

* ============================================================================== 
* Init
* ============================================================================== 
        _gameMode.init #GmID_gamescreen
        _gfxlock.init
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
        _vscroll.setMap #ObjID_level1Map
        _vscroll.setTileset #ObjID_level1TileA,#ObjID_level1TileB
        _vscroll.setBuffer #ObjID_scrollA,#ObjID_scrollB
        _vscroll.setCameraPos #240*16-200
        _vscroll.setCameraSpeed #$ff80
        _vscroll.setViewport #0,#200

* ============================================================================== * Main Loop
* ==============================================================================
LevelMainLoop
        jsr   ReadJoypads
        jsr   RunObjects
        _gfxlock.on
        jsr   vscroll.do
        jsr   vscroll.move
        jsr   BuildSprites        
        _gfxlock.off
        _gfxlock.loop
        bra   LevelMainLoop

UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        jsr   YVGM_MusicFrame
        jmp   vgc_update

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/gamescreen/gamescreenRamData.asm"
        
* ============================================================================== * Routines
* ==============================================================================
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"
        INCLUDE "./engine/graphics/codec/DecRLE00.asm"
        INCLUDE "./engine/graphics/codec/zx0_mega.asm" 
        INCLUDE "./engine/palette/color/Pal_black.asm"
        INCLUDE "./global/global-trailer-includes.asm"
        INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.asm"
        