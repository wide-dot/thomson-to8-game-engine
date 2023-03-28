        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
OverlayMode equ 1
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        	
        org   $6100

        jsr   InitGlobals
        jsr   InitStack        
        jsr   LoadAct       
        jsr   ReadJoypads

LevelSizeLoad ; todo move to an object

        ;ldu   #Object_RAM
        ;lda   #ObjID_Tails
        ;sta   id,u
        ;ldd   #136/2
        ;std   x_pos,u
        ;ldd   #160/2
        ;std   y_pos,u

 ; warning this test moves camera
 ; camera is unsigned value and should not be decremented below 0 on x and y

ut_x_start_pos equ 200
ut_y_start_pos equ 200

        jsr   LoadObject_u
        lda   #ObjID_Box
        sta   id,u
        ldd   #ut_x_start_pos+24/2 ; minus sprite width
        std   x_pos,u
        ldd   #ut_y_start_pos+20/2-1 ; minus sprite height
        std   y_pos,u

        ldd   #12 ; x border on left
        std   glb_camera_x_offset
        ldd   #20 ; y border on top
        std   glb_camera_y_offset

        ldd   #160-24 ; screen minus left and right border
        std   glb_camera_width
        ldd   #200-40 ; screen minus top and bottom border
        std   glb_camera_height

        ldd   #ut_x_start_pos
        std   glb_camera_x_pos
        ldd   #ut_y_start_pos
        std   glb_camera_y_pos

        lda   #GmID_multisprite
        sta   glb_Cur_Game_Mode

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   PalUpdateNow

        jsr   KTST
        bcc   >
        jsr   GETC
        cmpb  #$41 ; touche A
        bne   >
        lda   #GmID_collision
        sta   GameMode
        jsr   LoadGameModeNow
!
        jsr   ReadJoypads
	jsr   EHZ_Back
        jsr   RunObjects
        jsr   BuildSprites
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
        
* ==============================================================================
* Routines
* ==============================================================================

        ; gfx rendering
        INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"
        
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
