        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************

SOUND_CARD_PROTOTYPE equ 1
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./global/globals.equ"

        org   $6100
        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads
        clr   menu_sel_port

* load object   

        jsr   LoadObject_u
        lda   #ObjID_menu
        sta   id,u   

* user irq
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   ReadJoypads 
        jsr   ReadKeyboard 
        jsr   MapKeyboardToJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites

        jmp   LevelMainLoop

* ==============================================================================
* Irq user routines
* ==============================================================================

UserIRQ
	jsr   PalUpdateNow
        rts

* ==============================================================================
* Game Mode
* ==============================================================================

DoChangeGameMode
        jsr   IrqOff
        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
	jsr   PalUpdateNow
        lda   GameMode
        ldb   #GmID_menu
        stb   glb_Cur_Game_Mode
        jsr   LoadGameModeNow 
        rts

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/menu/ram-data.asm"       
        
* ==============================================================================
* Routines
* ==============================================================================
        INCLUDE "./engine/level-management/LoadGameMode.asm"       

        ; basic object management
        INCLUDE "./engine/object-management/RunObjects.asm"

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/keyboard/ReadKeyboard.asm"
        INCLUDE "./engine/keyboard/MapKeyboardToJoypads.asm"

        ; gfx rendering
        INCLUDE "./engine/graphics/codec/zx0_mega.asm"
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"

        ; music and palette
	; irq
        INCLUDE "./engine/irq/Irq.asm"
	INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/palette/color/Pal_white.asm"
        INCLUDE "./engine/palette/color/Pal_black.asm"
