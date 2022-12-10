        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
        INCLUDE "./game-mode/SouthAmerica/SouthAmericaRamData.equ"    
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        org   $6100
			
        jsr   InitGlobals
        jsr   LoadAct
        _RunObjectRoutineA ObjID_Tilemap,glb_current_submap     

        ; allocate objects
        jsr   LoadObject_u
        lda   #ObjID_Rick
        sta   id,u

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL   
        jsr   PalUpdateNow
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
        
        INCLUDE "./game-mode/SouthAmerica/SouthAmericaRamData.asm"       

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

        ; animation
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	    

        ; tilemap
        INCLUDE "./engine/graphics/Camera/AutoScroll.asm"
        INCLUDE "./engine/graphics/tilemap/Tilemap.asm"