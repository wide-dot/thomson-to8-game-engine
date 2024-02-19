        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        	
        org   $6100

        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct       
        jsr   ReadJoypads

@loop
        jsr   LoadObject_u
        lda   #ObjID_sprite
        sta   id,u
        lda   obj_subtype
        sta   subtype,u
        inca
        sta   obj_subtype
        ldd   position_y
        std   y_pos,u
        ldd   position_x
        std   x_pos,u
        addd  #20
        cmpd  #168
        beq   >
        std   position_x
        bra   @loop
!       ldd   #8
        std   position_x
        ldd   position_y
        addd  #20
        cmpd  #88
        beq   >
        std   position_y
        bra   @loop
!

        lda   #GmID_renderb
        sta   glb_Cur_Game_Mode

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   PalUpdateNow
        jsr   ReadJoypads

        jsr   KTST
        bcc   >
        jsr   GETC
        cmpb  #$41 ; touche A
        bne   >
        lda   #GmID_atan2
        sta   GameMode
        jsr   LoadGameModeNow
!

        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jmp   LevelMainLoop

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
position_x
        fdb   8
position_y
        fdb   8
obj_subtype
        fcb   0

        INCLUDE "./game-mode/render-b/ram-data.asm"       
        
* ==============================================================================
* Routines
* ==============================================================================

        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
	INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"
