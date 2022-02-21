        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
        INCLUDE "./GameMode/savage/savageRamData.equ"    
        INCLUDE "./Engine/Constants.asm"
        INCLUDE "./Engine/Macros.asm"        
        org   $6100

        jsr   LoadAct

	; objects init
	ldu   #Obj_Axe1
        ldd   #$004A
        std   x_pos,u
        ldd   #$0050
        std   y_pos,u
	ldu   #Obj_Axe2
        ldd   #$0062
        std   x_pos,u
        ldd   #$0050
        std   y_pos,u
	ldu   #Obj_Axe3
        ldd   #$007A
        std   x_pos,u
        ldd   #$0050
        std   y_pos,u
	ldu   #Obj_Axe4
        ldd   #$0092
        std   x_pos,u
        ldd   #$0050
        std   y_pos,u
	ldu   #Obj_Axe5
        ldd   #$00AA
        std   x_pos,u
        ldd   #$0050
        std   y_pos,u

	ldu   #Obj_Bat1
        ldd   #$004A
        std   x_pos,u
        ldd   #$0035
        std   y_pos,u
	ldu   #Obj_Bat2
        ldd   #$0062
        std   x_pos,u
        ldd   #$0035
        std   y_pos,u
	ldu   #Obj_Bat3
        ldd   #$007A
        std   x_pos,u
        ldd   #$0035
        std   y_pos,u
	ldu   #Obj_Bat4
        ldd   #$0092
        std   x_pos,u
        ldd   #$0035
        std   y_pos,u
	ldu   #Obj_Bat5
        ldd   #$00AA
        std   x_pos,u
        ldd   #$0035
        std   y_pos,u


        _RunObjectRoutine ObjID_tilemap,glb_current_submap       

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL   
        jsr   UpdatePalette
        jsr   ReadJoypads
        jsr   AutoScroll
        jsr   RunObjects
        _RunObjectRoutine ObjID_tilemap,glb_current_submap
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawTilemap
        jsr   DrawSprites        
        bra   LevelMainLoop

* ==============================================================================
* Game Mode RAM variables
* ==============================================================================
        
        INCLUDE "./GameMode/savage/savageRamData.asm"       

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
        INCLUDE "./Engine/ObjectManagement/ClearObj.asm"
        INCLUDE "./Engine/ObjectManagement/RunPgSubRoutine.asm"
	INCLUDE "./Engine/ObjectManagement/SingleObjLoad.asm"
        INCLUDE "./Engine/Ram/ClearDataMemory.asm"
        INCLUDE "./Engine/Palette/UpdatePalette.asm"
        INCLUDE "./Engine/Graphics/Camera/AutoScroll.asm"
        INCLUDE "./Engine/Graphics/Tilemap/Tilemap.asm"
        INCLUDE "./Engine/Graphics/GetImgIdA.asm"
zx0_decompress rts	
