
    INCLUDE "./engine/constants.asm"
    INCLUDE "./engine/macros.asm"
    org   $6100
    jsr   LoadAct
    jsr   InitJoypads

* init sound player
    jsr   IrqInit
    ldd   #UserIRQ_SVGM
    std   Irq_user_routine
    lda   #255                     ; set sync out of display (VBL)
    ldx   #Irq_one_frame
    jsr   IrqSync
    jsr   IrqOn
    ldx   #Svgm_monMorceau
    jsr   PlayMusic

* ============================================================================== * Main Loop
* ==============================================================================
LevelMainLoop
    jsr   WaitVBL
    jsr   PalUpdateNow

    jsr   LoadGameMode

startJoyTest
    jsr   ReadJoypads
    ldb   Fire_Press
    bitb  #c1_button_A_mask
    bne   >
    bra   endJoyTest
!   lda   #GmID_gamescreen
    sta   GameMode
    lda   #$FF
    sta   ChangeGameMode
    jsr   IrqOff
    jsr   DoStopTrack
endJoyTest

    bra   LevelMainLoop

UserIRQ_SVGM
    jmp   MusicFrame

* ============================================================================== * Routines
* ==============================================================================
    INCLUDE "./engine/InitGlobals.asm"

    INCLUDE "./engine/ram/BankSwitch.asm"
    INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
    INCLUDE "./engine/palette/PalUpdateNow.asm"
    INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"
* gamemode swap
    INCLUDE "./engine/level-management/LoadGameMode.asm"
* joystick
    INCLUDE "./engine/joypad/InitJoypads.asm"
    INCLUDE "./engine/joypad/ReadJoypads.asm"
* sound
    INCLUDE "./engine/sound/Svgm.asm"
    INCLUDE "./engine/irq/Irq.asm"
