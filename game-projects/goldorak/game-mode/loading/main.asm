    INCLUDE "./global/global-preambule-includes.asm"

    ORG   $6100
    
* ============================================================================== 
* Init
* ============================================================================== 
    _GameModeInit #GmID_loading
    _NewManagedObject_U #ObjID_Loading    
    _SetPalette #Pal_loading
    _ShowPalette

    ldd NEXT_GAME_MODE_PRESENT
    cmpa #$00
    bne > ; Il y a dejà un game-mode qui a été lancé donc on passe l'init
    lda #$FF ; c'est le premier appel, donc on init pour ne pas y repasser
    ldb #GmID_gamescreen ; game-mode à lancer après celui-ci
    std NEXT_GAME_MODE_PRESENT ; on écrit le flag + game-mode à lancer à la bonne adresse
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


    
    

