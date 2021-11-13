        INCLUDE "./Engine/Constants.asm"
	INCLUDE "./Engine/Macros.asm"   
        org   $6100
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
        INCLUDE "./Engine/Ram/BankSwitch.asm"
        INCLUDE "./Engine/Graphics/WaitVBL.asm"
        INCLUDE "./Engine/Graphics/AnimateSprite.asm"	
        INCLUDE "./Engine/Graphics/DisplaySprite.asm"	
        INCLUDE "./Engine/Graphics/CheckSpritesRefresh.asm"
        INCLUDE "./Engine/Graphics/EraseSprites.asm"
        INCLUDE "./Engine/Graphics/UnsetDisplayPriority.asm"	
        INCLUDE "./Engine/Graphics/DrawSpritesExtEnc.asm"
        INCLUDE "./Engine/Graphics/BgBufferAlloc.asm"		
        INCLUDE "./Engine/Palette/UpdatePalette.asm"
        INCLUDE "./Engine/Ram/ClearDataMemory.asm"
        INCLUDE "./Engine/ObjectManagement/RunObjects.asm"
        INCLUDE "./Engine/ObjectManagement/ClearObj.asm"	
        INCLUDE "./Engine/Irq/IrqSmidi.asm"        
        INCLUDE "./Engine/Sound/Smidi.asm"	
        INCLUDE "./Engine/Graphics/Codec/zx0_mega.asm"	
        INCLUDE "./Engine/Graphics/Codec/DecRLE00.asm"		

	    