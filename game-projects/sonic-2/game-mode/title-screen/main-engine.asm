        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
;SOUND_CARD_PROTOTYPE equ 1
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./game-mode/globals.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        org   $6100

        ; init game globals
        ldd   #0
        std   Current_ZoneAndAct
        sta   Life_count
        sta   Score

        ; init engine globals
        jsr   InitGlobals	

	; game mode
        lda   #GmID_TitleScreen
        sta   glb_Cur_Game_Mode
	lda   #GmID_EHZ
	sta   glb_Next_Game_Mode		

        ; SMPS
        lda   #$01
        sta   Smps.60HzData 
        jsr   YM2413_DrumModeOn

	; IRQ
        jsr   IrqInit
        ldd   #UserIRQ_Pal
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

        jsr   LoadAct     

        ; allocate objects
        jsr   LoadObject_u
        beq   >
        _ldd  ObjID_SEGA,1
        std   id,u ; and subtype
!

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
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
* Irq user routines
* ==============================================================================
UserIRQ_Pal
	jmp   PalUpdateNow

UserIRQ_Pal_Smps
	jsr   PalUpdateNow
	jmp   MusicFrame

UserIRQ_Raster_Smps
	jsr   PalRaster_1c
	jmp   MusicFrame
        
* ==============================================================================
* Routines
* ==============================================================================
        INCLUDE "./engine/InitGlobals.asm"
	INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"	
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"

	; dac
        INCLUDE "./engine/sound/PlayDPCM16kHz.asm"

        ; gfx rendering
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"

        ; basic object management
        INCLUDE "./engine/object-management/RunObjects.asm"

	; irq
        INCLUDE "./engine/irq/Irq.asm"
        INCLUDE "./engine/sound/Smps.asm"
	INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/palette/PalRaster_1c.asm"
        INCLUDE "./engine/palette/color/Pal_black.asm"
