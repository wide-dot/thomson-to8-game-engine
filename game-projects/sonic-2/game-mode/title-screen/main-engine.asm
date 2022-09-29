        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************

        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        org   $6100
        jsr   InitGlobals		
        lda   #GmID_TitleScreen
        sta   glb_Cur_Game_Mode
	lda   #GmID_EHZ
	sta   glb_Next_Game_Mode		

        jsr   LoadAct       

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   UpdatePalette
        jsr   ReadJoypads
        jsr   LoadGameMode                
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites        
        bra   LevelMainLoop

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
        INCLUDE "./game-mode/title-screen/ram-data.asm"       
        
* ==============================================================================
* Routines
* ==============================================================================
        INCLUDE "./engine/InitGlobals.asm"
	INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	

        ; gfx rendering
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"

        ; basic object management
        INCLUDE "./engine/object-management/ClearObj.asm"
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/SingleObjLoad.asm"

        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"	
        INCLUDE "./engine/ram/ClearDataMemory.asm"
	INCLUDE "./engine/palette/UpdatePalette.asm"
        INCLUDE "./engine/sound/PlayDPCM16kHz.asm"
        INCLUDE "./engine/sound/Smps.asm"
        INCLUDE "./engine/irq/IrqSmpsRaster.asm"
