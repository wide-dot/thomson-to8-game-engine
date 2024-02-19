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
        INCLUDE "./engine/system/to8/macros.asm"

        org   $6100
        jsr   InitGlobals
		jsr   InitDrawSprites
        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads

* load object   

        jsr   LoadObject_u
        lda   #ObjID_textym
        sta   id,u   

        jsr   LoadObject_u
        lda   #ObjID_playerym
        sta   id,u 

        jsr   LoadObject_u
        lda   #ObjID_imgym
        sta   id,u   

* init sound player
        lda   #0
        sta   snd_tst_sel_song
        sta   snd_tst_new_song
        lda   #0
        sta   snd_tst_sel_game
        sta   snd_tst_new_game

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
        jsr   PalUpdateNow
        jsr   ReadJoypads  
        jsr   ReadKeyboard 
        jsr   MapKeyboardToJoypads
        jsr   CheckPause
        jsr   CheckReset
        jsr   CheckReturnToMenu

        _MountObject ObjID_mask
        jsr   ,x
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
	jsr   YVGM_MusicFrame
        rts

CallbackRoutine
        dec   YVGM_loop
        beq   @nextsong
        lda   #1
        sta   YVGM_WaitFrame
        ldx   YVGM_MusicData
        ldu   #YM2413_buffer
        stu   YVGM_MusicDataPos
        jsr   ym2413zx0_decompress    
        jmp   YVGM_MusicFrame  
@nextsong 
        ldb   #c1_button_right_mask
        stb   Dpad_Press
        ldb   #c1_button_A_mask
        stb   Fire_Press
        rts   

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/soundtest-ym/ram-data.asm"       
        
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

        ; ymm player
        INCLUDE "./engine/sound/YM2413vgm.asm"

* ==============================================================================
* Key Checks
* ==============================================================================

CheckPause
        lda   Key_Press
        cmpa  #80
        beq   >
        cmpa  #112
        beq   >
        rts
!       lda   @pause_state
        bne   @unpause
        com   @pause_state
        jsr   IrqPause
        jmp   ym2413.reset
@unpause
        com   @pause_state
        jmp   IrqUnpause
@pause_state
        fcb   0

CheckReset
        lda   Key_Press
        cmpa  #81
        beq   >
        cmpa  #113
        beq   >
        rts
!       _system.reboot

CheckReturnToMenu
        lda   Key_Press
        cmpa  #30
        beq   >
        rts
!       jsr   IrqOff
        jsr   ym2413.reset
        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
	jsr   PalUpdateNow
        lda   #GmID_menu
        sta   GameMode
        ldb   #GmID_ymplayer
        stb   glb_Cur_Game_Mode
        jsr   LoadGameModeNow 
        rts