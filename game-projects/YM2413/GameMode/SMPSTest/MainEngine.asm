        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
* Simple Test for YM2413 and SN76489 sound cards
*
********************************************************************************

        INCLUDE "./Engine/Constants.asm"
        INCLUDE "./Engine/Macros.asm"        
        org   $6100

        ;lda   #$01                     ; 1: play 60hz track at 50hz, 0: do not skip frames
        ;sta   Smps.60HzData 
        jsr   YM2413_DrumModeOn
        jsr   IrqSet50Hz
        ldx   #Smps_EHZ
        jsr   PlayMusic 
                        
        ;jsr   PSGInit
        ;jsr   IrqSet50Hz
        ;ldx   #Psg_Test
        ;jsr   PSGPlay

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL    

        lda   Fire_Press
        bita  #c1_button_A_mask
        beq   LevelMainLoop
        ldx   #Smps_SlowSmash
        jsr   PlaySound
             
        bra   LevelMainLoop
        
* ==============================================================================
* Routines
* ==============================================================================
        INCLUDE "./Engine/Ram/BankSwitch.asm"
        INCLUDE "./Engine/Graphics/WaitVBL.asm"
        INCLUDE "./Engine/Joypad/ReadJoypads.asm"
        INCLUDE "./Engine/Irq/IrqSmpsJoypad.asm"        
        INCLUDE "./Engine/Sound/Smps.asm"
        ;INCLUDE "./Engine/Irq/IrqPsg.asm"                
        ;INCLUDE "./Engine/Sound/PSGlib.asm"
	