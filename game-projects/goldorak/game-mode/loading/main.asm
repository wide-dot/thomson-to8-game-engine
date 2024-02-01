    INCLUDE "./global/global-preambule-includes.asm"

    ORG   $6100
    
* ============================================================================== 
* Init
* ============================================================================== 
    _gameMode.init #GmID_loading
    jsr   InitDrawSprites
    _objectManager.new.u #ObjID_Loading    
    _palette.set #Pal_loading
    _palette.show

    ldd NEXT_GAME_MODE_PRESENT
    cmpd #$C3E1
    beq > ; Il y a dejà un game-mode qui a été lancé donc on passe l'init
    ldd #$C3E1 ; c'est le premier appel, donc on init pour ne pas y repasser
    std NEXT_GAME_MODE_PRESENT
    lda #GmID_splash ; game-mode à lancer après celui-ci
    sta NEXT_GAME_MODE ; on écrit le flag + game-mode à lancer à la bonne adresse
!   lda   NEXT_GAME_MODE
    sta   GameMode

* ============================================================================== *
* MainLoop
* ==============================================================================
Main
    jsr   RunObjects
    jsr   CheckSpritesRefresh
    jsr   EraseSprites
    jsr   UnsetDisplayPriority
    jsr   DrawSprites
    jsr   WaitVBL
    jsr   LoadGameModeNow  
      
* ============================================================================== 
* INCLUDES
* ==============================================================================  
    INCLUDE "./game-mode/splash/ram-data.asm"

    ; common utilities
    INCLUDE "./engine/InitGlobals.asm"
    INCLUDE "./engine/ram/BankSwitch.asm"
    INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
    INCLUDE "./engine/palette/PalUpdateNow.asm"
    INCLUDE "./engine/ram/ClearDataMemory.asm"

    INCLUDE "./engine/joypad/InitJoypads.asm"
    INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"

    ; object management
    INCLUDE "./engine/object-management/RunObjects.asm"
    INCLUDE "./engine/object-management/ObjectMoveSync.asm"
    INCLUDE "./engine/level-management/LoadGameMode.asm"


    
    

