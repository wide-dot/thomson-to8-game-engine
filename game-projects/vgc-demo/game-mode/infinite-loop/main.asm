;SOUND_CARD_PROTOTYPE equ 1
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
	INCLUDE "./engine/macros.asm"   

ext_variables_size equ 6

        org   $6100
        jsr   InitGlobals
        jsr   InitStack        
        jsr   LoadAct

        ; initialize the SN76489 vgm player with a vgc data stream
        ldd   #vgc_stream_buffers
        ldx   #Vgc_intro
        ;andcc #$fe ; clear carry (no loop)
        orcc  #1 ; set carry (loop)
        jsr   vgc_init 

        ; init YM2413 music
        ldx   #Vgc_introYM
        ;andcc #$fe ; clear carry (no loop)
        orcc  #1 ; set carry (loop)
        jsr   YVGM_PlayMusic

        jsr   LoadObject_u
        lda   #ObjID_background1
        sta   id,u

        jsr   LoadObject_u
        lda   #ObjID_background2
        sta   id,u

        jsr   WaitVBL      
        jsr   RunObjects	
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority	
        jsr   DrawSprites   

        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL      
        jsr   RunObjects	
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority	
        jsr   DrawSprites        	
        bra   LevelMainLoop

Dynamic_Object_RAM 
        fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End

nb_dynamic_objects                 equ 2 ; dynamic allocation
nb_graphical_objects               equ 2 ; only count objects that will be rendered on screen (max 64 total)

UserIRQ
        jsr   PalUpdateNow
        jsr   YVGM_MusicFrame
        jmp   vgc_update

* ==============================================================================
* Routines
* ==============================================================================

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"

        ; sound
        INCLUDE "./engine/irq/Irq.asm"        
        INCLUDE "./engine/sound/Smidi.asm"	

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	
        INCLUDE "./engine/graphics/Codec/zx0_mega.asm"	

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"

        ; vgc player
        INCLUDE "./engine/sound/vgc/lib/vgcplayer.h.asm"
        INCLUDE "./engine/sound/vgc/lib/vgcplayer.asm"
        INCLUDE "./engine/sound/YM2413vgm.asm"

; reserve space for the vgm decode buffers (8x256 = 2Kb)
        ALIGN 256
vgc_stream_buffers
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
