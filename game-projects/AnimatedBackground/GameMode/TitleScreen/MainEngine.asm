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

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   UpdatePalette
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
        INCLUDE "./Engine/Graphics/DrawFullscreenImage.asm"	
        INCLUDE "./Engine/Graphics/AnimateSprite.asm"	
        INCLUDE "./Engine/Graphics/GetImgIdA.asm"
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
        INCLUDE "./Engine/LevelManagement/LoadGameMode.asm"
        INCLUDE "./Engine/Palette/UpdatePalette.asm"
        INCLUDE "./Engine/Sound/PSGlib.asm"
        INCLUDE "./Engine/Irq/IrqPsgJoypad.asm"	
