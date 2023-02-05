DO_NOT_WAIT_VBL equ 1
SOUND_CARD_PROTOTYPE equ 1

    INCLUDE "./engine/system/to8/memory-map.equ"
    INCLUDE "./engine/constants.asm"
    INCLUDE "./engine/macros.asm"
    INCLUDE "./global/global-macros.asm"

    ORG   $6100
    
* ============================================================================== 
* Init
* ============================================================================== 
    _GameModeInit
    _MusicInit_SN76489 #Vgc_intro,#vgc_stream_buffers,#MUSIC_LOOP   ; initialize the SN76489 vgm player with a vgc data stream
    _MusicInit_YM2413 #Vgc_introYM,#MUSIC_LOOP                      ; initialize the YM2413 player 
    _MusicInit_IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame         ; Setting IRQ for music
    _NewManagedObjet_U #ObjID_Splash

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
    bra   MainLoop

UserIRQ
        jsr   PalUpdateNow
        jsr   YVGM_MusicFrame
        jmp   vgc_update    

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

     ; sound
    INCLUDE "./engine/irq/Irq.asm"        

    ; vgc player
    INCLUDE "./engine/sound/vgc/lib/vgcplayer.h.asm"
    INCLUDE "./engine/sound/vgc/lib/vgcplayer.asm"
    INCLUDE "./engine/sound/YM2413vgm.asm"

    ; reserve space for the vgm decode buffers (8x256 = 2Kb)
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

