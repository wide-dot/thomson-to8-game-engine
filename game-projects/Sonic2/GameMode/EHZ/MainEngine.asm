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
		
        jsr   LoadAct       

	; locate system stack to allow compilated img to go over video memory range
	lds   #$9CDF ; free 320 bytes (40 bytes x 8 lines)

        ldd   #0
        std   glb_camera_x_pos
        ldd   #578
        std   glb_camera_y_pos

	; register tilemap
        _RunObjectRoutine ObjID_EHZ,#0   

	; start music
        lda   #$01
        sta   Smps.60HzData 
        jsr   YM2413_DrumModeOn
        jsr   IrqSet50Hz
        ldx   #Smps_EHZ
        jsr   PlayMusic 

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   UpdatePalette
        jsr   ReadJoypads           
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawTilemaps   
        jsr   DrawSprites    
        bra   LevelMainLoop

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
        INCLUDE "./Engine/Irq/IrqSmpsJoypad.asm"        
        INCLUDE "./Engine/Sound/Smps.asm"
        INCLUDE "./Engine/Graphics/Tilemap/Tilemap16bits.asm"
