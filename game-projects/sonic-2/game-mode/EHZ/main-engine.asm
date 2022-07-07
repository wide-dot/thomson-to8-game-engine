        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************

        INCLUDE "./Engine/Constants.asm"
        INCLUDE "./Engine/Macros.asm"        
        INCLUDE "./objects/engine/smps/SndID.equ"	
        org   $6100

        jsr   InitGlobals
        jsr   LoadAct       
        jsr   ReadJoypads

LevelSizeLoad ; todo move to an object

        lda   #ObjID_Sonic
        sta   id+dp

        ldd   #$60/2 ; init
        ;ldd   #$03C2 ; cave
        ;ldd   #$0A42 ; left wall flat
        ;ldd   #$0827 ; loop
        std   x_pos+dp
        ldd   #$028F ; intit
        ;ldd   #$02F0 ; cave
        ;ldd   #$03AC ; left wall flat
        ;ldd   #$022B ; loop
        std   y_pos+dp

	ldd   #camera_Y_pos_bias_default
        std   Camera_Y_pos_bias

        lda   #12+screen_left
        sta   glb_camera_x_offset
        lda   #20+screen_top
        sta   glb_camera_y_offset

        ldd   #0
        std   <glb_camera_x_pos
        ldd   y_pos+dp
        subd  Camera_Y_pos_bias
        std   <glb_camera_y_pos

        ; global speed setting, animation and movement scale
        lda   #5
        sta   Vint_Main_runcount_cap

        _RunObjectRoutine ObjID_EHZ,#0

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
        _RunObjectRoutine ObjID_RingsManager,#0

        ; init music
        lda   #$01                     ; 1: play 60hz track at 50hz, 0: do not skip frames
        sta   Smps.60HzData 
        _RunObjectRoutine ObjID_Smps,#0 ; YM2413_DrumModeOn
        ldb   #2                        ; music id
        _RunObjectRoutine ObjID_Smps,#2 ; PlayMusic 

	; start music
        jsr   IrqSet50Hz

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   TileAnimScript
        jsr   ChangeRingFrame

        jsr   ReadJoypads  
        _RunObject ObjID_Sonic,#MainCharacter 
        _RunObject ObjID_Scroll,#MainCharacter   
        _RunObjectRoutine ObjID_RingsManager,#2

        jsr   RunObjects
	jsr   ForceRefresh
        jsr   CheckSpritesRefresh

        ldb   #0 ; sprite mask
	jsr   EHZ_Mask

        jsr   EraseSprites
        jsr   UnsetDisplayPriority
	jsr   EHZ_Back
        jsr   ComputeTileBuffer
	jsr   DrawBufferedTile
        _RunObjectRoutine ObjID_RingsManager,#4
        jsr   DrawSprites
        jsr   DrawHighPriorityBufferedTile   

        ldb   #2 ; frame mask
	jsr   EHZ_Mask

        bra   LevelMainLoop

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

        INCLUDE "./Engine/Graphics/Tilemap/TileAnimScript.asm"  

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
        INCLUDE "./Engine/InitGlobals.asm"
        INCLUDE "./Engine/Ram/BankSwitch.asm"
        INCLUDE "./Engine/Graphics/WaitVBL.asm"
        INCLUDE "./Engine/Graphics/AnimateSpriteSync.asm"	
        INCLUDE "./objects/main-characters/sonic/sonic-animate.asm"
        INCLUDE "./Engine/Graphics/DisplaySprite.asm"	
        INCLUDE "./Engine/Graphics/CheckSpritesRefresh.asm"
        INCLUDE "./Engine/Graphics/EraseSprites.asm"
        INCLUDE "./Engine/Graphics/UnsetDisplayPriority.asm"
        INCLUDE "./Engine/Graphics/DrawSprites.asm"
        INCLUDE "./Engine/Graphics/BgBufferAlloc.asm"	
        INCLUDE "./Engine/Joypad/ReadJoypads2.asm"
        INCLUDE "./Engine/ObjectManagement/RunObjects.asm"
        INCLUDE "./Engine/ObjectManagement/SingleObjLoad.asm"
        INCLUDE "./Engine/ObjectManagement/DeleteObject.asm"
        INCLUDE "./engine/object-management/clear-obj-107.asm"	
        INCLUDE "./Engine/Ram/ClearDataMemory.asm"
        INCLUDE "./Engine/Irq/IrqSmpsObj.asm"      
        INCLUDE "./objects/levels/collision/collision.asm"
        INCLUDE "./Engine/Graphics/Tilemap/TilemapBuffer.asm"
