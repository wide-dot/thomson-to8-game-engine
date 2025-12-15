        opt   c,ct

SOUND_CARD_PROTOTYPE equ 1

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./engine/objects/sound/ymm/ymm.macro.asm"
        INCLUDE "./engine/objects/sound/objects.sound.macro.asm"

        org   $6100
        jsr   InitGlobals
        jsr   InitDrawSprites
        jsr   InitStack                

        ; Allocate new background object
        ; --------------------------------------------

        jsr   LoadObject_u
        lda   #ObjID_background
        sta   id,u

        ; Set Key Frame
        ; --------------------------------------------

        ldb   #$02                         ; load page 2
        stb   $E7E5                        ; in data space ($A000-$DFFF)
        ldx   #Bgi_titleScreen
        jsr   DrawFullscreenImage

        ldb   #$03                         ; load page 3
        stb   $E7E5                        ; data space ($A000-$DFFF)
        ldx   #Bgi_titleScreen
        jsr   DrawFullscreenImage

        ; Set Palette
        ; --------------------------------------------

        ldb   #15
        jsr   gfxlock.screenBorder.update
        ldd   #Pal_Background
        std   Pal_current
        clr   PalRefresh

        ; Play music
        ; --------------------------------------------

        _MountObject ObjID_ymm
        _MusicInit_objymm #0,#MUSIC_LOOP,#0  ; initialize the YM2413 player 
        _MountObject ObjID_vgc
        _MusicInit_objvgc #0,#MUSIC_LOOP,#0 ; initialize the SN76489 vgm player with a vgc data stream

        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        jsr   IrqOn         


* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites       
        _gfxlock.off
        _gfxlock.loop
        bra   LevelMainLoop

        ; Main IRQ
        ; --------------------------------------------

UserIRQ
        jsr   gfxlock.bufferSwap.check
	jsr   PalUpdateNow
        _MountObject ObjID_ymm
        _ymm.processFrame
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts

        ; Game Mode RAM variables
        ; --------------------------------------------
        
        INCLUDE "./game-mode/TitleScreen/ram-data.asm"        

* ==============================================================================
* Routines
* ==============================================================================

        ; utilities
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"	
        INCLUDE "./engine/level-management/LoadGameMode.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"	
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/irq/Irq.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"	

        ; music and sound fx
        INCLUDE "./engine/objects/sound/ymm/ymm.const.asm"
        INCLUDE "./engine/objects/sound/ymm/ymm.data.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"