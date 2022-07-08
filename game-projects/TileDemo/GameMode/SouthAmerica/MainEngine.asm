        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
        INCLUDE "./GameMode/SouthAmerica/SouthAmericaRamData.equ"    
        INCLUDE "./Engine/Constants.asm"
        INCLUDE "./Engine/Macros.asm"        
        org   $6100
			
        jsr   InitGlobals
        jsr   LoadAct
        _RunObjectRoutineA ObjID_Tilemap,glb_current_submap       

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL   
        jsr   UpdatePalette
        jsr   ReadJoypads
        jsr   AutoScroll
        jsr   RunObjects
        _RunObjectRoutineA ObjID_Tilemap,glb_current_submap
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawTilemap
        jsr   DrawSprites        
        bra   LevelMainLoop

* ==============================================================================
* Game Mode RAM variables
* ==============================================================================
        
        INCLUDE "./GameMode/SouthAmerica/SouthAmericaRamData.asm"       

* ==============================================================================
* Routines
* ==============================================================================
        INCLUDE "./Engine/InitGlobals.asm"
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
        INCLUDE "./Engine/ObjectManagement/ClearObj.asm"
        INCLUDE "./Engine/ObjectManagement/RunPgSubRoutine.asm"
        INCLUDE "./Engine/Ram/ClearDataMemory.asm"
		INCLUDE "./Engine/Palette/UpdatePalette.asm"
		INCLUDE "./Engine/Graphics/Camera/AutoScroll.asm"
		INCLUDE "./Engine/Graphics/Tilemap/Tilemap.asm"
