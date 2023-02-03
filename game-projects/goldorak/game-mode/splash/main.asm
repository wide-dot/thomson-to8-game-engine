DO_NOT_WAIT_VBL equ 1
SOUND_CARD_PROTOTYPE equ 1

    INCLUDE "./engine/system/to8/memory-map.equ"
    INCLUDE "./engine/constants.asm"
    INCLUDE "./engine/macros.asm"

    ORG   $6100

* ============================================================================== 
* Init
* ==============================================================================
    jsr   InitGlobals
    jsr   LoadAct
    jsr   InitJoypads   
    jsr   LoadObject_u
    lda   #ObjID_Splash
    sta   id,u
    jsr   PalUpdateNow

* ============================================================================== *
* MainLoop
* ==============================================================================
MainLoop
    jsr   WaitVBL
    jsr   RunObjects
    jsr   CheckSpritesRefresh
    jsr   EraseSprites
    jsr   UnsetDisplayPriority
    jsr   DrawSprites
    bra   MainLoop

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

    ; object management
    INCLUDE "./engine/object-management/RunObjects.asm"
    INCLUDE "./engine/object-management/ObjectMoveSync.asm"

    ; joystick
    INCLUDE "./engine/joypad/InitJoypads.asm"
    INCLUDE "./engine/joypad/ReadJoypads.asm"

    ; bg images & sprites
    INCLUDE "./engine/graphics/codec/zx0_mega.asm" 
    INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"

