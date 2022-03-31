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

        ldd   #0
        std   glb_camera_x_pos
        ldd   #576
        std   glb_camera_y_pos

	; register tilemap
        _RunObjectRoutine ObjID_EHZ,#0   

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   UpdatePalette
        jsr   LoadGameMode                
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
        INCLUDE "./Engine/Graphics/AnimateSprite.asm"	
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
        INCLUDE "./Engine/LevelManagement/LoadGameMode.asm"	
        INCLUDE "./Engine/Ram/ClearDataMemory.asm"
	INCLUDE "./Engine/Palette/UpdatePalette.asm"
        INCLUDE "./Engine/Sound/Smps.asm"
        INCLUDE "./Engine/Irq/IrqSmpsRaster.asm"
        INCLUDE "./Engine/Graphics/Tilemap/Tilemap16bits.asm"
