    INCLUDE "./global/global-preambule-includes.asm"

    ORG   $6100
    
* ============================================================================== 
* Init
* ============================================================================== 
    _GameModeInit #GmID_loading
    _NewManagedObject_U #ObjID_Loading    

    _SetPalette #Pal_loading
    _ShowPalette

    lda NEXT_GAME_MODE
    bne MainLoop
    lda #GmID_splash
    sta NEXT_GAME_MODE

* ============================================================================== *
* MainLoop
* ==============================================================================
MainLoop
    jsr   RunObjects
    jsr   CheckSpritesRefresh
    jsr   EraseSprites
    jsr   UnsetDisplayPriority
    jsr   DrawSprites
    jsr   WaitVBL
    lda   NEXT_GAME_MODE
    sta   GameMode
    jsr   LoadGameModeNow 
      

* ============================================================================== 
* INCLUDES
* ==============================================================================  
    INCLUDE "./game-mode/splash/ram-data.asm"

     ; bg images & sprites
    INCLUDE "./engine/graphics/codec/DecRLE00.asm"
    INCLUDE "./engine/graphics/codec/zx0_mega.asm" 
    INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"
    INCLUDE "./engine/palette/color/Pal_white.asm"
    INCLUDE "./engine/palette/color/Pal_black.asm"

    INCLUDE "./global/global-trailer-includes.asm"
    
    

