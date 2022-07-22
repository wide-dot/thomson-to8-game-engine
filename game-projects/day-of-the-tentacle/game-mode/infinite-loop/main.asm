        INCLUDE "./engine/constants.asm"
	INCLUDE "./engine/macros.asm"   

ext_variables_size equ 6

        org   $6100
        jsr   InitGlobals
        jsr   LoadAct

        jsr   ResetMidi
        jsr   IrqSet50Hz
        ldx   #Smid_intro
        jsr   PlayMusic 

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

Object_RAM 
        fcb   ObjID_background1
        fill  0,object_size-1
        fcb   ObjID_background2
        fill  0,object_size-1	
Object_RAM_End

nb_graphical_objects   equ 2

* ==============================================================================
* Routines
* ==============================================================================

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/palette/UpdatePalette.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ClearObj.asm"

        ; sound
        INCLUDE "./engine/irq/IrqSmidi.asm"        
        INCLUDE "./engine/sound/Smidi.asm"	

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	
        INCLUDE "./engine/graphics/Codec/zx0_mega.asm"	

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"
	    