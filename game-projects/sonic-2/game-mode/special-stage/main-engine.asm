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

        lda   #GmID_SpecialStage
        sta   glb_Cur_Game_Mode
		sta   glb_Next_Game_Mode

        _RunObject ObjID_HalfPipe,#SpecialStageHalfPipe

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   UpdatePalette
        jsr   ReadJoypads
        ; jsr   LoadGameMode     
        _RunObject ObjID_HalfPipe,#SpecialStageHalfPipe
        jsr   RunObjects
        jsr   CheckSpritesRefresh                                              
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites       
        bra   LevelMainLoop
        
* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
        INCLUDE "./game-mode/special-stage/ram-data.asm"        

* ==============================================================================
* Routines
* ==============================================================================
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"	
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	
        INCLUDE "./engine/graphics/GetImgIdA.asm"
        INCLUDE "./engine/graphics/DisplaySprite.asm"	
        INCLUDE "./engine/graphics/CheckSpritesRefresh.asm"
        INCLUDE "./engine/graphics/EraseSprites.asm"
        INCLUDE "./engine/graphics/UnsetDisplayPriority.asm"
        INCLUDE "./engine/graphics/draw/DrawSprites.asm"
        INCLUDE "./engine/graphics/BgBufferAlloc.asm"	
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/DeleteObject.asm"
        INCLUDE "./engine/object-management/clear-obj-107.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"	
        INCLUDE "./engine/level-management/LoadGameMode.asm"	
        INCLUDE "./engine/graphics/ClearInterlacedDataMemory.asm"
        INCLUDE "./engine/palette/UpdatePalette.asm"
        INCLUDE "./engine/sound/Smps.asm"
        INCLUDE "./engine/irq/IrqSmps.asm"	