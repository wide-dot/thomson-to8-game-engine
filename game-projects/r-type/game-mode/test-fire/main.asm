 opt c

DEBUG   equ     1
SOUND_CARD_PROTOTYPE equ 1

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./global/macro.asm"
        INCLUDE "./global/variables.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./global/scale.asm"
        INCLUDE "./global/object.const.asm"

        org   $6100

        clr   NEXT_GAME_MODE
        jsr   InitGlobals
	jsr   InitDrawSprites

        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads
        jsr   InitRNG

; init user irq
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        jsr   IrqOn 

; load test object
        jsr   LoadObject_u
        lda   #ObjID_launcher
        sta   id,u

* ---------------------------------------------------------------------------
* MAIN GAME LOOP
* ---------------------------------------------------------------------------

LevelMainLoop
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh

        _gfxlock.on
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _gfxlock.off
        _gfxlock.loop

        jmp   LevelMainLoop

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
        jsr   gfxlock.bufferSwap.check
	jmp   PalUpdateNow

* ---------------------------------------------------------------------------
* Test Data
* ---------------------------------------------------------------------------

FoeFireTarget
        fdb   0
target  equ *-x_pos
        fdb   80  ; x_pos
        fcb   0   ; subpixel
        fdb   100 ; y_pos

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        INCLUDE "./game-mode/test-fire/ram_data.asm"

* ---------------------------------------------------------------------------
* CUSTOM routines
* ---------------------------------------------------------------------------
        INCLUDE "./global/moveXPos8.8.asm"
        INCLUDE "./global/moveYPos8.8.asm"
        INCLUDE "./global/setDirectionTo.asm"

* ---------------------------------------------------------------------------
* ENGINE routines
* ---------------------------------------------------------------------------

        ; common utilities
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/irq/Irq.asm"

        ; joystick
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"
        INCLUDE "./engine/object-management/ObjectDp.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; random numbers
        INCLUDE "./engine/math/RandomNumber.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"
