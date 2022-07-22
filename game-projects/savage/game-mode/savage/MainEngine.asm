        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
        INCLUDE "./game-mode/savage/savageRamData.equ"    
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        org   $6100

        jsr   InitGlobals
        jsr   LoadAct

	; objects init
	ldu   #Obj_Axe1
        ldd   #$004A-screen_left
        std   x_pos,u
        ldd   #$0050-screen_top
        std   y_pos,u
	ldu   #Obj_Axe2
        ldd   #$0062-screen_left
        std   x_pos,u
        ldd   #$0050-screen_top
        std   y_pos,u
	ldu   #Obj_Axe3
        ldd   #$007A-screen_left
        std   x_pos,u
        ldd   #$0050-screen_top
        std   y_pos,u
	ldu   #Obj_Axe4
        ldd   #$0092-screen_left
        std   x_pos,u
        ldd   #$0050-screen_top
        std   y_pos,u
	ldu   #Obj_Axe5
        ldd   #$00AA-screen_left
        std   x_pos,u
        ldd   #$0050-screen_top
        std   y_pos,u

	ldu   #Obj_Bat1
        ldd   #$004A-screen_left
        std   x_pos,u
        ldd   #$0035-screen_top
        std   y_pos,u
	ldu   #Obj_Bat2
        ldd   #$0062-screen_left
        std   x_pos,u
        ldd   #$0035-screen_top
        std   y_pos,u
	ldu   #Obj_Bat3
        ldd   #$007A-screen_left
        std   x_pos,u
        ldd   #$0035-screen_top
        std   y_pos,u
	ldu   #Obj_Bat4
        ldd   #$0092-screen_left
        std   x_pos,u
        ldd   #$0035-screen_top
        std   y_pos,u
	ldu   #Obj_Bat5
        ldd   #$00AA-screen_left
        std   x_pos,u
        ldd   #$0035-screen_top
        std   y_pos,u


        _RunObjectRoutineA ObjID_tilemap,glb_current_submap       

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL   
        jsr   UpdatePalette
        jsr   AutoScroll
        jsr   RunObjects
        _RunObjectRoutineA ObjID_tilemap,glb_current_submap
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawTilemap
        jsr   DrawSprites        
        bra   LevelMainLoop

* ==============================================================================
* Game Mode RAM variables
* ==============================================================================
        
        INCLUDE "./game-mode/savage/savageRamData.asm"       

* ==============================================================================
* Routines
* ==============================================================================

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"	
        INCLUDE "./engine/palette/UpdatePalette.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/SingleObjLoad.asm"
        INCLUDE "./engine/object-management/ClearObj.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	
        INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"	

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"	

        ; tilemap
        INCLUDE "./engine/graphics/Camera/AutoScroll.asm"
        INCLUDE "./engine/graphics/Tilemap/Tilemap.asm"
	
