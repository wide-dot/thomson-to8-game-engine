DO_NOT_WAIT_VBL equ 1
DEBUG   equ     1
SOUND_CARD_PROTOTYPE equ 1

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/objects/palette/fade/fade.equ"
        INCLUDE "./global/macro.asm"

viewport_width  equ 144
viewport_height equ 180

 ; value in animation script

        org   $6100
        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads

        jsr   WaitVBL
        ldd   #Pal_game
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow


; play music
        _MountObject ObjID_ymm
        _MusicInit_objymm #0,#MUSIC_NO_LOOP,#MusicCallbackYM  ; initialize the YM2413 player 
        _MountObject ObjID_vgc
        _MusicInit_objvgc #0,#MUSIC_NO_LOOP,#MusicCallbackSN ; initialize the SN76489 vgm player with a vgc data stream

; init user irq
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

        jsr   LoadObject_x
        lda   #ObjID_logo_r
        sta   id,x
        ldd   #70
        std   x_pos,x
        ldd   #30
        std   y_pos,x


* ---------------------------------------------------------------------------
* MAIN GAME LOOP
* ---------------------------------------------------------------------------

TitleMainLoop
        jsr   WaitVBL
        jsr   ReadJoypads

        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jmp   TitleMainLoop

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
	jsr   PalUpdateNow
        _MountObject ObjID_ymm
        _MusicFrame_objymm
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts

MusicCallbackYM
        _MountObject ObjID_ymm
        _MusicInit_objymm #1,#MUSIC_LOOP,#0
        rts

MusicCallbackSN
        _MountObject ObjID_vgc
        _MusicInit_objvgc #1,#MUSIC_LOOP,#0
        rts


* ---------------------------------------------------------------------------
* Palette_FadeIn
*
* ---------------------------------------------------------------------------

Palette_FadeIn
        ldu   #palettefade
        clr   routine,u
        ldd   Pal_current
        std   o_fade_src,u
        ldd   #Pal_game
        std   o_fade_dst,u
        lda   #6
        sta   o_fade_wait,u
        ldd   #Palette_FadeCallback
        std   o_fade_callback,u
        rts

* ---------------------------------------------------------------------------
* Palette_FadeOut
*
* ---------------------------------------------------------------------------

Palette_FadeOut
        ldu   #palettefade
        clr   routine,u
        ldd   Pal_current
        std   o_fade_src,u
        ldd   #Pal_black
        std   o_fade_dst,u
        lda   #0
        sta   o_fade_wait,u
        ldd   #Palette_FadeCallback
        std   o_fade_callback,u
        rts

* ---------------------------------------------------------------------------
* Palette_FadeCallback
*
* ---------------------------------------------------------------------------

Palette_FadeCallback
        rts

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/00/ram_data.asm"

* ---------------------------------------------------------------------------
* ENGINE routines
* ---------------------------------------------------------------------------

        ; common utilities
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/irq/Irq.asm"
        ;INCLUDE "./engine/math/CalcSine.asm"
        ;INCLUDE "./engine/math/Mul9x16.asm"

        ; joystick
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ObjectMove.asm"
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"
        INCLUDE "./engine/object-management/ObjectWave-subtype.asm"
        INCLUDE "./engine/object-management/ObjectDp.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"
        INCLUDE "./engine/graphics/animation/AnimateMoveSync.asm"

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"
