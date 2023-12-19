        opt   c,ct

;SOUND_CARD_PROTOTYPE equ 1
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"

        org   $6100
        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads

; init user irq
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        jsr   IrqOn 

        jsr   gfxlock.bufferSwap.do
        ldx   #Bgi_bonneannee
        jsr   DrawFullscreenImage

        jsr   gfxlock.bufferSwap.do
        ldx   #Bgi_bonneannee
        jsr   DrawFullscreenImage

        ldd   #Pal_bb
        std   Pal_current
        clr   PalRefresh
	    jsr   PalUpdateNow

        jsr   LoadObject_u
        lda   #ObjID_Player
        sta   id,u

* ==============================================================================
* Main Loop
* ==============================================================================
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

UserIRQ
        jsr   gfxlock.bufferSwap.check
        jmp   PalUpdateNow

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
        INCLUDE "./game-mode/bonne-annee/ram.asm"        

* ==============================================================================
* Routines
* ==============================================================================

        ; utilities
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/palette/color/Pal_black.asm"
        ;INCLUDE "./engine/ram/ClearDataMemory.asm"

        ; joystick
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ObjectFallSync.asm"
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"
        INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"

        ; sound
        INCLUDE "./engine/irq/Irq.asm"	

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"

        ; collision
        INCLUDE "./engine/collision/collision.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"
