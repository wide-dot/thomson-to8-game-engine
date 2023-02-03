    INCLUDE "./engine/constants.asm"
    INCLUDE "./engine/macros.asm"
    org   $6100
    jsr   LoadAct
* ============================================================================== * Main Loop
* ==============================================================================
LevelMainLoop
    jsr   WaitVBL

    lda   glb_Next_Game_Mode
    sta   GameMode
    lda   #$FF
    sta   ChangeGameMode

    jsr   LoadGameMode

*    jsr   PalUpdateNow
    bra   LevelMainLoop
* ============================================================================== * Routines
* ==============================================================================
    INCLUDE "./engine/ram/BankSwitch.asm"
    INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
*    INCLUDE "./engine/palette/PalUpdateNow.asm"
    INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"
    INCLUDE "./engine/level-management/LoadGameMode.asm"
