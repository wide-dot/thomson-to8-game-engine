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
		
        lda   #GmID_TitleScreen
        sta   glb_Cur_Game_Mode
	lda   #GmID_SpecialStage		
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
        
        INCLUDE "./GameMode/TitleScreen/TitleScreenRamData.asm"       
        
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
        INCLUDE "./Engine/Sound/PlayDPCM16kHz.asm"
        INCLUDE "./Engine/Sound/Smps.asm"
        INCLUDE "./Engine/Irq/IrqSmpsRaster.asm"
