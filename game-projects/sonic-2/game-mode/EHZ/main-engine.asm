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
        INCLUDE "./objects/engine/smps/SndID.equ"	
        org   $6100

        jsr   InitGlobals

        ; init music
        lda   #$01                       ; 1: play 60hz track at 50hz, 0: do not skip frames
        sta   Smps.60HzData 
        _RunObjectRoutineA ObjID_Smps,#0 ; YM2413_DrumModeOn
        ldb   #2                         ; music id
        _RunObjectRoutineA ObjID_Smps,#2 ; PlayMusic 

	; user irq
	lda   #8
	sta   PalCyc_frames_init
	sta   PalCyc_frames
        jsr   IrqInit
        ldd   #UserIRQ_Pal_ObjSmps
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

        jsr   LoadAct    
        jsr   InitJoypads   
        jsr   ReadJoypads

LevelSizeLoad ; todo move to an object

        lda   #ObjID_Sonic
        sta   dp+id

        ldd   #$60/2 ; init
        ;ldd   #$03C2 ; cave
        ;ldd   #$0A42 ; left wall flat
        ;ldd   #$0827 ; loop
        ;ldd   #$0CDC ; loop
        std   x_pos+dp
        ldd   #$028F ; intit
        ;ldd   #$02F0 ; cave
        ;ldd   #$03AC ; left wall flat
        ;ldd   #$022B ; loop
        ;ldd   #$02BA ; loop
        std   y_pos+dp

	ldd   #camera_Y_pos_bias_default
        std   Camera_Y_pos_bias

        ldd   #12
        std   glb_camera_x_offset
        ldd   #20
        std   glb_camera_y_offset

        ldd   #136
        std   glb_camera_width
        ldd   #160
        std   glb_camera_height

        ldd   #0
        std   <glb_camera_x_pos
        ldd   y_pos+dp
        subd  Camera_Y_pos_bias
        std   <glb_camera_y_pos

        ; global speed setting, animation and movement scale
        lda   #5
        sta   Vint_Main_runcount_cap

        _RunObjectRoutineA ObjID_EHZ,#0

        ; init tile buffer based on camera pos
	jsr   InitTileBuffer

	; init Animated tiles
	ldx   #Animated_EHZ_script
        jsr   TileAnimScriptInit

        ; init collision data
        lda   Obj_Index_Page+ObjID_Collision
        sta   ColData_page
        ldd   Obj_Index_Address+2*ObjID_Collision
        std   ColCurveMap
        addd  #256
        std   ColArray
        addd  #2048
        std   ColArray2

        ; init ring manager
        _RunObjectRoutineB ObjID_RingsManager,#0

        ; init object manager
        _RunObjectRoutineB ObjID_ObjectsManager,#0

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    

        jsr   TileAnimScript
        jsr   ChangeRingFrame

        jsr   ReadJoypads  
	jsr   Col_adj_before
        _RunObject ObjID_Sonic,#MainCharacter 
	jsr   Col_adj_after
        _RunObject ObjID_Scroll,#MainCharacter   
        _RunObjectRoutineB ObjID_RingsManager,#2
        _RunObjectRoutineB ObjID_ObjectsManager,#2

        jsr   RunObjects
        jsr   ForceRefresh

 ifdef halfline
        ldb   #0                 ; sprite mask
	jsr   EHZ_Mask
 endc
	jsr   EHZ_Back
        jsr   ComputeTileBuffer
	jsr   DrawBufferedTile

        jsr   BuildSprites

        _RunObjectRoutineB ObjID_RingsManager,#4

        jsr   DrawHighPriorityBufferedTile   

        ldb   #2                ; frame mask
	jsr   EHZ_Mask

        _RunObject ObjID_HUD,#0 ; Head Up Display
        
 ifdef debug
        jsr   DBG_Display
 endc
        jmp   LevelMainLoop

* ==============================================================================
* Irq user routines
* ==============================================================================

UserIRQ_Pal_ObjSmps
        jsr   PalCycling
        jsr   IrqSecond
	jmp   IrqObjSmps

* ==============================================================================
* ECT
* ==============================================================================

; collision framerate adjustment
glb_old_x_pos fdb 0
glb_old_y_pos fdb 0
glb_col_x_range_pos fdb 0
glb_col_x_range_neg fdb 0
glb_col_y_range_pos fdb 0
glb_col_y_range_neg fdb 0

Col_adj_before
	ldd   dp+x_pos
	std   glb_old_x_pos
	ldd   dp+y_pos
	std   glb_old_y_pos
	rts

Col_adj_after
	ldd   glb_old_x_pos
	subd  dp+x_pos
	bpl   >
	_negd
!	anda  #0
	andb  #$F0
	addb  #$10
	std   glb_col_x_range_pos
	_negd
	std   glb_col_x_range_neg

	ldd   glb_old_y_pos
	subd  dp+y_pos
	bpl   >
	_negd
!	anda  #0
	andb  #$F0
	addb  #$10
	std   glb_col_y_range_pos
	_negd
	std   glb_col_y_range_neg
	rts

ChangeRingFrame                                       *ChangeRingFrame:
                                                      *        subq.b  #1,(Logspike_anim_counter).w
                                                      *        bpl.s   +
                                                      *        move.b  #$B,(Logspike_anim_counter).w
                                                      *        subq.b  #1,(Logspike_anim_frame).w ; animate unused log spikes
                                                      *        andi.b  #7,(Logspike_anim_frame).w
                                                      *+
        lda   Rings_anim_counter
        suba  Vint_Main_runcount
        sta   Rings_anim_counter                      *        subq.b  #1,(Rings_anim_counter).w
        bpl   >                                       *        bpl.s   +
        adda  #7
        sta   Rings_anim_counter                      *        move.b  #7,(Rings_anim_counter).w
        lda   Rings_anim_frame
        inca                                          *        addq.b  #1,(Rings_anim_frame).w ; animate rings in the level (obj25)
        anda  #%00000011                              *        andi.b  #3,(Rings_anim_frame).w
        sta   Rings_anim_frame
!                                                     *+
                                                      *        subq.b  #1,(Unknown_anim_counter).w
                                                      *        bpl.s   +
                                                      *        move.b  #7,(Unknown_anim_counter).w
                                                      *        addq.b  #1,(Unknown_anim_frame).w ; animate nothing (deleted special stage object is my best guess)
                                                      *        cmpi.b  #6,(Unknown_anim_frame).w
                                                      *        blo.s   +
                                                      *        move.b  #0,(Unknown_anim_frame).w
                                                      *+
                                                      *        tst.b   (Ring_spill_anim_counter).w
                                                      *        beq.s   +       ; rts
                                                      *        moveq   #0,d0
                                                      *        move.b  (Ring_spill_anim_counter).w,d0
                                                      *        add.w   (Ring_spill_anim_accum).w,d0
                                                      *        move.w  d0,(Ring_spill_anim_accum).w
                                                      *        rol.w   #7,d0
                                                      *        andi.w  #3,d0
                                                      *        move.b  d0,(Ring_spill_anim_frame).w ; animate scattered rings (obj37)
                                                      *        subq.b  #1,(Ring_spill_anim_counter).w
                                                      *+
        rts                                           *        rts
                                                      *; End of function ChangeRingFrame

ForceRefresh
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

        ; this is not perfect as it will cause a tiny glitch (nearly unoticable)
        ; will not refresh background if last frame was made 
        ; will only non alpha tiles, not the new one ...
	lda   glb_alphaTiles
	bne   @a
	rts
@a
        lda   #0
        sta   glb_alphaTiles

        _RunObjectRoutineA ObjID_EHZ_Back,#0 ; set image location on screen and get image metadata
        _SetCartPageA                        ; set metadata page

	; get image location, this code works for a ND0 only image
	; please adapt metadata decoding if you want another image
	lda   13,x
	ldx   14,x
        _SetCartPageA                        ; set image routine memory page
        ldu   <glb_screen_location_2
        jmp   ,x                             ; call draw routine

EHZ_Mask
        _MountObject ObjID_Mask
        jsr   ,x
        _SetCartPageA        

	; get image location, this code works for a ND0 only image
	; please adapt metadata decoding if you want another image
	lda   13,x
	ldx   14,x
        _SetCartPageA        
        ldu   <glb_screen_location_2
        jmp   ,x

        INCLUDE "./engine/graphics/Tilemap/TileAnimScript.asm"  

; ===========================================================================
; for each script :
;	- Global frame duration. If -1, then each frame will use its own duration, instead
;	- Number of frames
;	- Tile ID
;	- Frame duration. Only here if global duration is -1

Animated_EHZ_script
        fdb   Animated_EHZ_1
        fdb   Animated_EHZ_2
        fdb   Animated_EHZ_3
        fdb   Animated_EHZ_4
        fdb   Animated_EHZ_5
	fdb   0

Animated_EHZ_1
	; Flowers 1
	fcb   -1,6
	fcb   0,127
	fcb   3,19
	fcb   0,7
	fcb   3,7
	fcb   0,7
	fcb   3,7
Animated_EHZ_2
	; Flowers 2
	fcb  -1,8
	fcb   3,127
	fcb   0,11
	fcb   3,11
	fcb   0,11
	fcb   3,5
	fcb   0,5
	fcb   3,5
	fcb   0,5
Animated_EHZ_3
	; Flowers 3
	fcb   7,2
	fcb   0
	fcb   3
Animated_EHZ_4
	; Flowers 4
	fcb   -1,8
	fcb   0,127
	fcb   3,7
	fcb   0,7
	fcb   3,7
	fcb   0,7
	fcb   3,11
	fcb   0,11
	fcb   3,11
Animated_EHZ_5
	; Pulsing thing against checkered background
	fcb   -1,6
	fcb   0,23
	fcb   3,9
	fcb   6,11
	fcb   9,23
	fcb   6,11
	fcb   3,9

TlsAni_EHZ_flower1
        lda   TileAnimScriptData+0*ZASize+1
        ldx   #TlsAni_EHZ_flower1_imgs
        jmp   TileAnimRun
TlsAni_EHZ_flower1_imgs
        INCLUDEGEN Tls_EHZ_flower1 index

TlsAni_EHZ_flower2
        lda   TileAnimScriptData+1*ZASize+1
        ldx   #TlsAni_EHZ_flower2_imgs
        jmp   TileAnimRun
TlsAni_EHZ_flower2_imgs
        INCLUDEGEN Tls_EHZ_flower2 index

TlsAni_EHZ_flower3
        lda   TileAnimScriptData+2*ZASize+1
        ldx   #TlsAni_EHZ_flower3_imgs
        jmp   TileAnimRun
TlsAni_EHZ_flower3_imgs
        INCLUDEGEN Tls_EHZ_flower3 index

TlsAni_EHZ_flower4
        lda   TileAnimScriptData+3*ZASize+1
        ldx   #TlsAni_EHZ_flower4_imgs
        jmp   TileAnimRun
TlsAni_EHZ_flower4_imgs
        INCLUDEGEN Tls_EHZ_flower4 index

TlsAni_EHZ_pulseball1
        lda   TileAnimScriptData+4*ZASize+1
        ldx   #TlsAni_EHZ_pulseball1_imgs
        jmp   TileAnimRun
TlsAni_EHZ_pulseball1_imgs
        INCLUDEGEN Tls_EHZ_pulseball1 index

TlsAni_EHZ_pulseball2
        lda   TileAnimScriptData+4*ZASize+1
        ldx   #TlsAni_EHZ_pulseball2_imgs
        jmp   TileAnimRun
TlsAni_EHZ_pulseball2_imgs
        INCLUDEGEN Tls_EHZ_pulseball2 index

TlsAni_EHZ_pulseball3
        lda   TileAnimScriptData+4*ZASize+1
        ldx   #TlsAni_EHZ_pulseball3_imgs
        jmp   TileAnimRun
TlsAni_EHZ_pulseball3_imgs
        INCLUDEGEN Tls_EHZ_pulseball3 index

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
        INCLUDE "./game-mode/EHZ/ram-data.asm"       
        
* ==============================================================================
* Routines
* ==============================================================================

        ; gfx rendering
        INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"
        
        ; basic object management
        INCLUDE "./engine/object-management/ClearObj.asm"
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/SingleObjLoad.asm"
        INCLUDE "./engine/object-management/MarkObjGone.asm"

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads2.asm"
        INCLUDE "./engine/math/CalcSine.asm"
        INCLUDE "./engine/math/Mul9x16.asm"

        ; animation
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"	
        INCLUDE "./objects/main-character/sonic/sonic-animate.asm"
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"   

        ; tilemap
        INCLUDE "./objects/level/stage/_common/collision/collision.asm"
        INCLUDE "./engine/graphics/Tilemap/TilemapBuffer.asm"

        ; music and palette
	; irq
        INCLUDE "./engine/irq/Irq.asm"
	INCLUDE "./engine/palette/PalUpdateNow.asm"
	INCLUDE "./engine/palette/PalCycling.asm"
        INCLUDE "./engine/irq/IrqSecond.asm" 
        INCLUDE "./engine/irq/IrqObjSmps.asm"  

 ifdef debug
        ; debug
        INCLUDE "./objects/level/stage/_common/collision/collision-debug.asm"
 endc

_end
 ifge _end-$9F00
	error "Main overflow (>=$9F00)"
 endc