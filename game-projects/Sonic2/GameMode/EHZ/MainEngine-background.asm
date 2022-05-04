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
        std   <glb_camera_y_pos	; register tilemap
        _RunObjectRoutine ObjID_EHZ,#0

        ; init tile buffer based on camera pos
	jsr   InitTileBuffer

	; init Animated tiles
	ldx   #Animated_EHZ_script
        jsr   TileAnimScriptInit

        lda   #$01                     ; 1: play 60hz track at 50hz, 0: do not skip frames
        sta   Smps.60HzData 
        _RunObjectRoutine ObjID_Smps,#0 ; YM2413_DrumModeOn
        ldb   #0                        ; music id 0
        _RunObjectRoutine ObjID_Smps,#2 ; PlayMusic 

	; start music
        jsr   IrqSet50Hz 

        ldu   #MainCharacter
        ldd   #screen_left+$60/2
        std   x_pos,u
        ldd   #screen_top+20+$028F
        std   y_pos,u

        ldd   #0
        std   <glb_camera_x_pos
        ldd   #576
        std   <glb_camera_y_pos

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   TileAnimScript
        jsr   ReadJoypads  
        _RunObject ObjID_Sonic,#MainCharacter      
        jsr   RunObjects
	jsr   ForceRefresh
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
        _RunObjectRoutine ObjID_EHZ_Mask,#0
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
	fcb   0,127
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
        
        INCLUDE "./GameMode/EHZ/EHZRamData.asm"       
        
* ==============================================================================
* Routines
* ==============================================================================
	INCLUDE "./Engine/Ram/BankSwitch.asm"
        INCLUDE "./Engine/Graphics/WaitVBL.asm"
        INCLUDE "./Engine/Graphics/AnimateSpriteSync.asm"	
        INCLUDE "./Objects/MainCharacters/Sonic-EHZ/Sonic_Animate.asm"
        INCLUDE "./Engine/Graphics/DisplaySprite.asm"	
        INCLUDE "./Engine/Graphics/CheckSpritesRefresh.asm"
        INCLUDE "./Engine/Graphics/EraseSprites.asm"
        INCLUDE "./Engine/Graphics/UnsetDisplayPriority.asm"
        INCLUDE "./Engine/Graphics/DrawSprites.asm"
        INCLUDE "./Engine/Graphics/BgBufferAlloc.asm"	
        INCLUDE "./Engine/Joypad/ReadJoypads2.asm"
        INCLUDE "./Engine/ObjectManagement/RunObjects.asm"
        INCLUDE "./Engine/ObjectManagement/DeleteObject.asm"
        INCLUDE "./Engine/ObjectManagement/ClearObj107.asm"	
        INCLUDE "./Engine/ObjectManagement/ObjectMoveSync.asm"	
        INCLUDE "./Engine/ObjectManagement/ObjectFallSync.asm"	
        INCLUDE "./Engine/Ram/ClearDataMemory.asm"
        INCLUDE "./Engine/Irq/IrqSmpsObj.asm"      
        INCLUDE "./Engine/Graphics/Tilemap/TilemapBuffer.asm"
