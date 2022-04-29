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

	; init Animated tiles
	ldx   #Animated_EHZ_script
        jsr   ZoneAnimScriptInit

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
        jsr   ZoneAnimScript
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

; ===========================================================================
; ZONE ANIMATION SCRIPTS - TODO mettre dans une lib
;

ZACurIndex equ   0 ; current index in animation script
ZACurFrame equ   1 ; current frame in animation
ZADuration equ   2 ; remaining duration of current frame (20ms by step)
ZAMaxFrame equ   3 ; max index in animation script
ZASize     equ   4 ; size of this data structure
ZoneAnimScriptData
        fill  0,16*ZASize

ZoneAnimScriptInit
	stx   ZoneAnimScriptList
        ldu   #ZoneAnimScriptData
@loop	ldy   ,x++
        beq   @rts
        ldd   ,y                       ; load global frame duration, number of frames in animation
	bpl   @globalduration
        stb   ZAMaxFrame,u
        ldd   2,y
        incb
        std   ZACurFrame,u             ; and ZADuration
        bra   @common 
@globalduration
        inca
        std   ZADuration,u             ; and ZAMaxFrame
        lda   2,y
        sta   ZACurFrame,u
@common lda   #0
        sta   ZACurIndex,u
        leau  ZASize,u
        bra   @loop
@rts    rts


; *** suba  Vint_Main_runcount
ZoneAnimScript
        ldx   #0                       ; (dynamic)
ZoneAnimScriptList equ *-2
        beq   @rts                     ; no animation script to process
        ldu   #ZoneAnimScriptData
@loop	ldy   ,x++                     ; process a script
        beq   @rts                     ; at the end of script list ?
        lda   ZADuration,u
        suba  Vint_Main_runcount       ; tick down animation frame in sync with elapsed 50hz IRQ
        bcs   @loadScript
        sta   ZADuration,u             ; animation is not over
        leau  ZASize,u
        bra   @loop
@loadScript
        lda   ZACurIndex,u             ; animation frame is over, load next one
        inca  
        cmpa  ZAMaxFrame,u             ; at the end of script ?
        bne   @a                       ; if not continue
        lda   #0                       ; otherwise reset animation
@a      sta   ZACurIndex,u             ; save new index
        ldb   1,y
        stb   ZAMaxFrame,u
        ldb   ,y                       ; load global frame duration
	bpl   @globalduration
        asla                           ; 2 data bytes per index
        adda  #2                       ; skip header
        ldd   a,y
        bra   @b 
@globalduration
        adda  #2                       ; skip header
        lda   a,y
@b      std   ZACurFrame,u             ; and ZADuration
        leau  ZASize,u
        bra   @loop
@rts    rts

ZoneAnimRun
	ldb   a,x
        stb   $E7E6
        inca
        jmp   [a,x]

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
	fcb   0,127
	fcb   3,9
	fcb   6,11
	fcb   9,23
	fcb   6,11
	fcb   3,9

TlsAni_EHZ_flower1
        lda   ZoneAnimScriptData+0*ZASize+1
        ldx   #TlsAni_EHZ_flower1_imgs
        jmp   ZoneAnimRun
TlsAni_EHZ_flower1_imgs
        INCLUDEGEN Tls_EHZ_flower1 index

TlsAni_EHZ_flower2
        lda   ZoneAnimScriptData+1*ZASize+1
        ldx   #TlsAni_EHZ_flower2_imgs
        jmp   ZoneAnimRun
TlsAni_EHZ_flower2_imgs
        INCLUDEGEN Tls_EHZ_flower2 index

TlsAni_EHZ_flower3
        lda   ZoneAnimScriptData+2*ZASize+1
        ldx   #TlsAni_EHZ_flower3_imgs
        jmp   ZoneAnimRun
TlsAni_EHZ_flower3_imgs
        INCLUDEGEN Tls_EHZ_flower3 index

TlsAni_EHZ_flower4
        lda   ZoneAnimScriptData+3*ZASize+1
        ldx   #TlsAni_EHZ_flower4_imgs
        jmp   ZoneAnimRun
TlsAni_EHZ_flower4_imgs
        INCLUDEGEN Tls_EHZ_flower4 index

TlsAni_EHZ_pulseball1
        lda   ZoneAnimScriptData+4*ZASize+1
        ldx   #TlsAni_EHZ_pulseball1_imgs
        jmp   ZoneAnimRun
TlsAni_EHZ_pulseball1_imgs
        INCLUDEGEN Tls_EHZ_pulseball1 index

TlsAni_EHZ_pulseball2
        lda   ZoneAnimScriptData+4*ZASize+1
        ldx   #TlsAni_EHZ_pulseball2_imgs
        jmp   ZoneAnimRun
TlsAni_EHZ_pulseball2_imgs
        INCLUDEGEN Tls_EHZ_pulseball2 index

TlsAni_EHZ_pulseball3
        lda   ZoneAnimScriptData+4*ZASize+1
        ldx   #TlsAni_EHZ_pulseball3_imgs
        jmp   ZoneAnimRun
TlsAni_EHZ_pulseball3_imgs
        INCLUDEGEN Tls_EHZ_pulseball3 index

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
