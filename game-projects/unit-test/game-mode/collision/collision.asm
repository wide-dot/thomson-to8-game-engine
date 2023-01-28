        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        	
        org   $6100

        jsr   InitGlobals
        jsr   LoadAct       
        jsr   ReadJoypads

        jsr   LoadObject_u
        lda   #ObjID_CBox
        sta   id,u
        ldd   #$80
        std   x_pos,u
        ldd   #$7F
        std   y_pos,u
        lda   #0
        sta   subtype,u

        jsr   LoadObject_u
        lda   #ObjID_CBox
        sta   id,u
        ldd   #$80
        std   x_pos,u
        ldd   #$A0
        std   y_pos,u
        lda   #1
        sta   subtype,u

        ldd   #12 ; x border on left
        std   glb_camera_x_offset
        ldd   #20 ; y border on top
        std   glb_camera_y_offset

        ldd   #160-24 ; screen minus left and right border
        std   glb_camera_width
        ldd   #200-40 ; screen minus top and bottom border
        std   glb_camera_height

        ldd   #0
        std   glb_camera_x_pos
        ldd   #0
        std   glb_camera_y_pos

        lda   #GmID_collision
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

        lda   Fire_Press
        anda  #c1_button_A_mask
        beq   >
        lda   #GmID_multisprite
        sta   GameMode
        jsr   LoadGameModeNow
!

        jsr   DoCollision
	jsr   EHZ_Back
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
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

AABB STRUCT
p       rmb   1
rx      rmb   1
ry      rmb   1
cx      rmb   1
cy      rmb   1
 ENDSTRUCT

StructStart 
AABB_a AABB
AABB_b AABB

        org   StructStart   
        fill  0,sizeof{AABB}
        fill  0,sizeof{AABB}

DoCollision
        ldu   #AABB_a
        ldx   #AABB_b
        lda   AABB.rx,u
        adda  AABB.rx,x
        sta   @rx
        adda  AABB.cx,u
        suba  AABB.cx,x
        asra
        cmpa  #0
@rx     equ *-1 
        ble   >
        rts
!       lda   AABB.ry,u
        adda  AABB.ry,x
        sta   @ry
        adda  AABB.cy,u
        suba  AABB.cy,x
        asra
        cmpa  #0
@ry     equ *-1 
        ble   >
        rts
!       ldb   #0
        lda   AABB.p,u
        suba  AABB.p,x
        beq   @draw
        bmi   @loose
@win    sta   AABB.p,u
        stb   AABB.p,x
        rts
@loose  lda   AABB.p,x
        suba  AABB.p,u
        sta   AABB.p,x
        stb   AABB.p,u
        rts
@draw   stb   AABB.p,u
        stb   AABB.p,x
        rts
