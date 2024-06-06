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
        INCLUDE "./engine/system/to8/macros.asm"

        org   $6100
        jsr   InitGlobals
		jsr   InitDrawSprites
        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads

* load object   

        jsr   LoadObject_u
        lda   #ObjID_text
        sta   id,u   

        jsr   LoadObject_u
        lda   #ObjID_player
        sta   id,u 

        jsr   LoadObject_u
        lda   #ObjID_img
        sta   id,u   

* init sound player
        lda   #45
        sta   snd_tst_sel_song
        sta   snd_tst_new_song
        lda   #4
        sta   snd_tst_sel_game
        sta   snd_tst_new_game

        lda   menu_sel_port
        ldx   #vgc_registers
        jsr   DynCode_ApplyAToListX

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
	jsr   vgc_update
        rts

CallbackRoutine
        dec   vgc_loop
        beq   @nextsong
        ldx   vgc_source
        ldd   ,x
        cmpd  #2                    ; song with no loop, play only once
        bne   >
        clr   vgc_loop
        bra   @nextsong
!       leax  d,x                   ; move to loop point
        lda   vgc_loop
        lda   vgc_buffers
        jsr   vgc_stream_mount
        jmp   vgc_update
@nextsong 
        ldb   #c1_button_right_mask
        stb   Dpad_Press
        ldb   #c1_button_A_mask
        stb   Fire_Press
        rts        

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/soundtest-sn/ram-data.asm"       
        
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
        INCLUDE "./engine/ram/DynCode.asm"

        ; gfx rendering
        INCLUDE "./engine/graphics/codec/zx0_mega.asm"
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"

        ; music and palette
        ; irq
        INCLUDE "./engine/irq/Irq.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/palette/color/Pal_white.asm"
        INCLUDE "./engine/palette/color/Pal_black.asm"

        ; vgc player
        INCLUDE "./engine/sound/vgc/lib/vgcplayer.h.asm"
        INCLUDE "./engine/sound/vgc/lib/vgcplayer.asm"

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
        jmp   sn76489.reset
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
        jsr   sn76489.reset
        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow
        lda   #GmID_menu
        sta   GameMode
        ldb   #GmID_snplayer
        stb   glb_Cur_Game_Mode
        jsr   LoadGameModeNow 
        rts