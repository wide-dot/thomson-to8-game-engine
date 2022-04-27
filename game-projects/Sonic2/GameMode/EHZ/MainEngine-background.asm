        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************

        INCLUDE "./Engine/Constants.asm"
        INCLUDE "./Engine/Macros.asm"        
        org   $6100
	INCLUDE "./Engine/InitGlobals.asm"		

        jsr   LoadAct       

        ldd   #0
        std   <glb_camera_x_pos
        ldd   #576
        std   <glb_camera_y_pos

	; register tilemap
        _RunObjectRoutine ObjID_EHZ,#0

        ; init tile buffer based on camera pos
	jsr   InitTileBuffer
	;ldd   #0
	;std   glb_tmb_x      ;(0-32767)                  
	;ldd   #576
	;std   glb_tmb_y      ;(0-32767)
	;_ldd  18,11
	;sta   glb_tmb_width  ;(1-20)       
	;stb   glb_tmb_height ;(1-13)  
	;jsr   FeedTileBuffer

        lda   #$01                     ; 1: play 60hz track at 50hz, 0: do not skip frames
        sta   Smps.60HzData 
        _RunObjectRoutine ObjID_Smps,#0 ; YM2413_DrumModeOn
        jsr   IrqSet50Hz
        ldb   #0                        ; music id 0
        _RunObjectRoutine ObjID_Smps,#2 ; PlayMusic 

	; start music
        jsr   IrqSet50Hz

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
	jsr   PaletteCycling
        jsr   UpdatePalette
        jsr   ReadJoypads           
        jsr   RunObjects
	jsr   CheckCameraMove
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
	jsr   EHZ_Back
        jsr   ComputeTileBuffer
	jsr   DrawBufferedTile
        jsr   DrawSprites
        jsr   DrawHighPriorityBufferedTile    
	jsr   EHZ_Mask
        bra   LevelMainLoop

glb_pal_elapsed_frames fcb 0

PaletteCycling
	lda   Vint_Main_runcount
	adda  glb_pal_elapsed_frames
	cmpa  #8
	bhi   @a
	sta   glb_pal_elapsed_frames
	rts
@a	
	lda   #0
	sta   glb_pal_elapsed_frames
	sta   Refresh_palette
	ldx   Cur_palette
	ldu   4,x
	ldd   2,x
	std   4,x
	ldd   ,x
	std   2,x
	stu   ,x
	rts

glb_old_camera_x_pos0 fdb   -1
glb_old_camera_x_pos1 fdb   -1
glb_old_camera_y_pos0 fdb   -1
glb_old_camera_y_pos1 fdb   -1

CheckCameraMove
	; check if camera has moved
	; and if tiles need an update
	lda   #0
	sta   glb_camera_move
        tst   glb_Cur_Wrk_Screen_Id
        bne   @b1
@b0     ldx   <glb_camera_x_pos
	cmpx  glb_old_camera_x_pos0
	bne   @endx0
	ldd   <glb_camera_y_pos
	cmpd  glb_old_camera_y_pos0
	bne   @endy0
        rts
@b1     ldx   <glb_camera_x_pos
	cmpx  glb_old_camera_x_pos1
	bne   @endx1
	ldd   <glb_camera_y_pos
	cmpd  glb_old_camera_y_pos1
	bne   @endy1
        rts
@endx0 	ldd   <glb_camera_y_pos
@endy0	std   glb_old_camera_y_pos0
	stx   glb_old_camera_x_pos0
	bra   @end
@endx1 	ldd   <glb_camera_y_pos
@endy1	std   glb_old_camera_y_pos1
	stx   glb_old_camera_x_pos1
@end

	; Force sprite to be refreshed when background changes
	; ----------------------------------------------------
	lda   #1
	sta   <glb_force_sprite_refresh
	sta   glb_camera_move
	rts

EHZ_Back
	lda   glb_camera_move
	bne   @a
	rts
@a
        _RunObjectRoutine ObjID_EHZ_Back,#0
        _SetCartPageA        

	; get image location, this code works for a ND0 only image
	; please adapt metadata decoding if you want another image
	lda   13,x
	ldx   14,x
        _SetCartPageA        
        ldu   <glb_screen_location_2
        jmp   ,x

EHZ_Mask
        _RunObjectRoutine ObjID_EHZ_Mask,#0
        _SetCartPageA        

	; get image location, this code works for a ND0 only image
	; please adapt metadata decoding if you want another image
	lda   13,x
	ldx   14,x
        _SetCartPageA        
        ldu   <glb_screen_location_2
        jmp   ,x

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
        INCLUDE "./GameMode/EHZ/EHZRamData.asm"       
        
* ==============================================================================
* Routines
* ==============================================================================
	INCLUDE "./Engine/Ram/BankSwitch.asm"
        INCLUDE "./Engine/Graphics/WaitVBL.asm"
        INCLUDE "./Engine/Graphics/AnimateSpriteSync.asm"	
        INCLUDE "./Engine/Graphics/DisplaySprite.asm"	
        INCLUDE "./Engine/Graphics/CheckSpritesRefresh.asm"
        INCLUDE "./Engine/Graphics/EraseSprites.asm"
        INCLUDE "./Engine/Graphics/UnsetDisplayPriority.asm"
        INCLUDE "./Engine/Graphics/DrawSprites.asm"
        INCLUDE "./Engine/Graphics/BgBufferAlloc.asm"	
        INCLUDE "./Engine/Joypad/ReadJoypads.asm"
        INCLUDE "./Engine/ObjectManagement/RunObjects.asm"
        INCLUDE "./Engine/ObjectManagement/DeleteObject.asm"
        INCLUDE "./Engine/ObjectManagement/ClearObj107.asm"	
        INCLUDE "./Engine/Ram/ClearDataMemory.asm"
	INCLUDE "./Engine/Palette/UpdatePalette.asm"
        INCLUDE "./Engine/Irq/IrqSmpsObj.asm"        
        INCLUDE "./Engine/Graphics/Tilemap/TilemapBuffer.asm"
