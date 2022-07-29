        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
OverlayMode equ 1

        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        	
        org   $6100

        jsr   InitGlobals
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

        ldu   #Object_RAM
        lda   #ObjID_Box
        sta   id,u
        ldd   #0
        std   x_pos,u
        ldd   #160/2
        std   y_pos,u

        ldd   #12
        std   glb_camera_x_offset
        ldd   #20
        std   glb_camera_y_offset

        ldd   #136
        std   glb_camera_width
        ldd   #160
        std   glb_camera_height

        ldd   #0
        std   glb_camera_x_pos
        std   glb_camera_y_pos

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   UpdatePalette
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
        INCLUDE "./engine/object-management/ClearObj.asm"
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/SingleObjLoad.asm"

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
	INCLUDE "./engine/palette/UpdatePalette.asm"
