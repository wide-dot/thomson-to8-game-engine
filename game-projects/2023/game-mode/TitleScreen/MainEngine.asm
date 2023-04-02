        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
SOUND_CARD_PROTOTYPE equ 1
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        org   $6100
        jsr   InitGlobals

        jsr   LoadObject_u
        lda   #ObjID_Coffee
        sta   id,u

        ; Set Key Frame
        ; --------------------------------------------

        ldb   #$02                         ; load page 2
        stb   $E7E5                        ; in data space ($A000-$DFFF)
        ldx   #Bgi_titleScreen
        jsr   DrawFullscreenImage

        lda   $E7DD                        ; set border color
        anda  #$F0  
        adda  #$08                         ; color ref
        sta   $E7DD
        anda  #$0F
        adda  #$80
        sta   gfxlock.screenBorder.color
        jsr   WaitVBL
        ldb   #$03                         ; load page 3
        stb   $E7E5                        ; data space ($A000-$DFFF)
        ldx   #Bgi_titleScreen
        jsr   DrawFullscreenImage

        ldd   #Pal_Coffee
        std   Pal_current
        clr   PalRefresh
        jsr   WaitVBL


* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh                                              
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites       
        bra   LevelMainLoop

UserIRQ_PSG
        jsr   PalUpdateNow
        jmp   PSGFrame

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
        INCLUDE "./game-mode/TitleScreen/TitleScreenRamData.asm"        

* ==============================================================================
* Routines
* ==============================================================================

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

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	

        ; sound
        INCLUDE "./engine/sound/PSGlib.asm"
        INCLUDE "./engine/irq/Irq.asm"	

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"	
