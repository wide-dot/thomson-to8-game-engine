        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
OverlayMode equ 1
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        org   $6100
        jsr   InitGlobals
        jsr   InitStack        
        jsr   LoadAct   

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   BuildSprites   
        bra   LevelMainLoop

UserIRQ
        jmp   PalUpdateNow

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
        INCLUDE "./game-mode/test/testRamData.asm"        

* ==============================================================================
* Routines
* ==============================================================================

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"	

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"	
        INCLUDE "./engine/level-management/LoadGameMode.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"	
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ClearObj.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	

        ; sound
        INCLUDE "./engine/irq/Irq.asm"	
