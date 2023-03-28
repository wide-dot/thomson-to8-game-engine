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

        ldd   #12 ; x border on left
        std   glb_camera_x_offset
        ldd   #20 ; y border on top
        std   glb_camera_y_offset

        ldd   #160-24 ; screen minus left and right border
        std   glb_camera_width
        ldd   #200-40 ; screen minus top and bottom border
        std   glb_camera_height

        jsr   LoadObject_u
        lda   #ObjID_Target
        sta   id,u
        ldd   #$80-12
        std   x_pos,u
        ldd   #$7F-20
        std   y_pos,u

        ldd   #0
        std   glb_camera_x_pos
        ldd   #0
        std   glb_camera_y_pos

        lda   #GmID_atan2
        sta   glb_Cur_Game_Mode

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   PalUpdateNow
        jsr   ReadJoypads

        lda   #1
        sta   glb_force_sprite_refresh

        jsr   KTST
        bcc   >
        jsr   GETC
        cmpb  #$41 ; touche A
        bne   >
        lda   #GmID_multisprite
        sta   GameMode
        jsr   LoadGameModeNow
!

	jsr   EHZ_Back
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _RunObject ObjID_Hud,#0 ; Head Up Display
        jmp   LevelMainLoop

EHZ_Back
        _RunObjectRoutineA ObjID_Frame,#0 ; set image location on screen and get image metadata
        _SetCartPageA                        ; set metadata page

	; get image location, this code works for a ND0 only image
	; please adapt metadata decoding if you want another image
	lda   13,x
	ldx   14,x
        _SetCartPageA                        ; set image routine memory page
        ldu   <glb_screen_location_2
        jmp   ,x                             ; call draw routine

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
        INCLUDE "./game-mode/multisprite/ram-data.asm"       
glb_angle fdb 0
        
* ==============================================================================
* Routines
* ==============================================================================


        ldd   #$2222
        ldx   #$4444
        ldy   #$2222
        ldu   #$4444

Draw_StackBlast
        sts   @s+2
        lds   #$DF40
DFI_a
        pshs  d,x,y,u
        pshs  d,x,y,u
        cmps  #$C014
        bne   DFI_a
;
        lds   #$BF40
DFI_b
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        cmps  #$A014
        bne   DFI_b
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  b,dp,x,y
        pshs  y,x,dp,b
@s
        lds   #$0000
        rts

* ==============================================================================
* External routines
* ==============================================================================

        ; gfx rendering
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"
        
        ; basic object management
        INCLUDE "./engine/object-management/RunObjects.asm"

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
	INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"
        INCLUDE "./engine/object-management/ObjectMove.asm"
        INCLUDE "./engine/math/CalcAngle.asm"
        INCLUDE "./engine/math/CalcSine.asm"
        INCLUDE "./engine/math/Mul9x16.asm"
