
OverlayMode equ 1
SOUND_CARD_PROTOTYPE equ 1
    INCLUDE "./engine/system/to8/memory-map.equ"
    INCLUDE "./engine/constants.asm"
    INCLUDE "./engine/macros.asm"
    org   $6100
    jsr   LoadAct
    jsr   InitJoypads

    *-----------------------------
    CLRA               ;
PALETTE_BLACK
    PSHS A             ;
    ASLA               ;
    STA $E7DB          ;
    LDD #$0000         ;* all colors same color
    STB $E7DA          ;
    STA $E7DA          ;
    PULS A             ;
    INCA               ;
    CMPA #$0           ; $F+1
    BNE PALETTE_BLACK  ;
    *-----------------------------

* init sound player NEW
* initialize the SN76489 vgm player with a vgc data stream
    ldd   #vgc_stream_buffers
    ldx   #Vgc_intro
    * andcc #$fe ; clear carry (no loop)
    orcc  #1 ; set carry (loop)
    jsr   vgc_init
    * init YM2413 music
    ldx   #Vgc_introYM
    * andcc #$fe ; clear carry (no loop)
    orcc  #1 ; set carry (loop)
    jsr   YVGM_PlayMusic

* init irq
    jsr   IrqInit
    ldd   #UserIRQ
    std   Irq_user_routine
    lda   #255                     ; set sync out of display (VBL)
    ldx   #Irq_one_frame
    jsr   IrqSync
    jsr   IrqOn

* init sound player OLD
*    ldx   #Svgm_monMorceau
*    jsr   PlayMusic


* load object
    * object IntroImages
    jsr   LoadObject_u
    lda   #ObjID_IntroImages
    sta   id,u

* ============================================================================== * Main Loop
* ==============================================================================
LevelMainLoop
    jsr   WaitVBL

    jsr   RunObjects

*    ldd   #Pal_01
*    std   Pal_current
*    clr   PalRefresh

*    jsr   PalUpdateNow

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
        jsr   sn_reset
        jsr   YVGM_SilenceAll
*    jsr   DoStopTrack
endJoyTest

    jsr   CheckSpritesRefresh
    jsr   EraseSprites
    jsr   UnsetDisplayPriority
    jsr   DrawSprites

    bra   LevelMainLoop

*UserIRQ_SVGM
*    jmp   MusicFrame
UserIRQ
        jsr   PalUpdateNow
        jsr   YVGM_MusicFrame
        jmp   vgc_update

* ============================================================================== * Routines
* ==============================================================================
    INCLUDE "./game-mode/titlescreen/titlescreenRamData.asm"

    INCLUDE "./engine/ram/ClearDataMemory.asm"

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
*    INCLUDE "./engine/sound/Svgm.asm"
    INCLUDE "./engine/irq/Irq.asm"

* bg images
    INCLUDE "./engine/graphics/Codec/zx0_mega.asm"
*sprite
    INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"

* object management
    INCLUDE "./engine/object-management/RunObjects.asm"

* vgc player
        INCLUDE "./engine/sound/vgc/lib/vgcplayer.h.asm"
        INCLUDE "./engine/sound/vgc/lib/vgcplayer.asm"
        INCLUDE "./engine/sound/YM2413vgm.asm"
* reserve space for the vgm decode buffers (8x256 = 2Kb)
        ALIGN 256
vgc_stream_buffers
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256




*
