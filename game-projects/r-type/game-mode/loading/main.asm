
DEBUG   equ     1
SOUND_CARD_PROTOTYPE equ 1

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/objects/palette/fade/fade.equ"
        INCLUDE "./global/macro.asm"
        INCLUDE "./global/variables.asm"

viewport_width  equ 144
viewport_height equ 180

 ; value in animation script

        org   $6100

        jsr   InitGlobals
		jsr   InitDrawSprites
        jsr   InitStack
        jsr   LoadAct

        jsr   WaitVBL

; init user irq


        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

        lda   #GmID_loading
        sta   glb_Cur_Game_Mode

        jsr   LoadObject_x		; Loading
	stx   ,u
        lda   #ObjID_loading
        sta   id,x
        ldd   #80
        std   x_pos,x
        ldd   #100
        std   y_pos,x

        lda   #10
        sta   @loop
Init
        jsr   WaitVBL
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        lda   #10
@loop   equ   *-1
        beq   >
        deca
        sta   @loop
        bra   Init
!
        jsr   IrqOff                    
        lda   NEXT_GAME_MODE
        sta   GameMode
        jsr   LoadGameModeNow


* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
	jmp   PalUpdateNow



* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/loading/ram_data.asm"

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
        ;INCLUDE "./engine/joypad/InitJoypads.asm"
        ;INCLUDE "./engine/joypad/ReadJoypads.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ObjectMove.asm"
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"
        INCLUDE "./engine/object-management/ObjectDp.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"
        #INCLUDE "./engine/graphics/animation/moveByScript.asm"

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"

        INCLUDE "./engine/level-management/LoadGameMode.asm"

