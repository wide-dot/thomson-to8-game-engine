        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
SOUND_CARD_PROTOTYPE equ 1
OverlayMode equ 1

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
        jsr   LoadAct    
        jsr   InitJoypads   
        jsr   ReadJoypads

        ; load objects
        jsr   LoadObject_u
        lda   #ObjID_LevelSelect
        sta   id,u

        jsr   LoadObject_u
        lda   #ObjID_Text
        sta   id,u

        jsr   LoadObject_u
        lda   #ObjID_Icon
        sta   id,u

        jsr   LoadObject_u
        lda   #ObjID_SoundTest
        sta   id,u

        ; init video buffer

!       jsr   WaitVBL
        jsr   ReadJoypads 
        jsr   RunObjects
        jsr   BuildSprites
        dec   init_frames
        bne   <

        ; show !
        ldd   #Pal_LevelSelect
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow

        ; init music
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

        lda   #$01
        sta   Smps.60HzData 
        jsr   YM2413_DrumModeOn

        ; set the DAC (percusion) to midi render
        ;jsr   ResetMidiCtrl
        ;jsr   InitMidiDrv
        ;lda   #$ff
        ;sta   midiOnFmSynth
        ;sta   midiOnFmDrums
        ;sta   midiOnPsg

        ldx   #Smps_209
        jsr   PlayMusic 

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    
        jsr   ReadJoypads  
        jsr   RunObjects
        jsr   BuildSprites
        jmp   LevelMainLoop

* ==============================================================================
* Irq user routines
* ==============================================================================

UserIRQ
        jsr   PalUpdateNow
	jmp   MusicFrame

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
init_frames fcb 5

        INCLUDE "./game-mode/level-select/ram-data.asm"       
        
* ==============================================================================
* Routines
* ==============================================================================

        ; gfx rendering
        INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"
        
        ; basic object management
        INCLUDE "./engine/object-management/RunObjects.asm"

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads2.asm"

        ; animation
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"	
        INCLUDE "./engine/graphics/image/GetImgIdA.asm"

        ; music and palette
	; irq
        INCLUDE "./engine/irq/Irq.asm"
	INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/palette/color/Pal_white.asm"
        INCLUDE "./engine/sound/Smps.asm"  
        ;INCLUDE "./engine/sound/SmpsMidi.asm"  

_end
 ifge _end-$9F00
	error "Main overflow (>=$9F00)"
 endc