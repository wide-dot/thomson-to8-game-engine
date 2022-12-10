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
        jsr   LoadObject_u
        lda   #ObjID_player
        sta   id,u

!       jsr   LoadObject_u
        lda   #ObjID_axe
        sta   id,u
        ldd   #$0050
        std   y_pos,u
        ldb   #$4A
@x_pos  equ   *-1
        std   x_pos,u
        addb  #24
        stb   @x_pos
        cmpb  #$4A+5*24
        bne   <

!       jsr   LoadObject_u
        lda   #ObjID_bat
        sta   id,u
        ldd   #$0035
        std   y_pos,u
        ldb   #$4A
@x_pos  equ   *-1
        std   x_pos,u
        addb  #24
        stb   @x_pos
        cmpb  #$4A+5*24
        bne   <

        _RunObjectRoutineA ObjID_tilemap,glb_current_submap       

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL   
        jsr   PalUpdateNow
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
        INCLUDE "./engine/palette/PalUpdateNow.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	
        INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"	

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"	

        ; tilemap
        INCLUDE "./engine/graphics/Camera/AutoScroll.asm"
        INCLUDE "./engine/graphics/tilemap/Tilemap.asm"
	
