********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************

        INCLUDE "./Engine/Constants.asm"
        INCLUDE "./Engine/Macros.asm"        
        INCLUDE "./objects/smps/SndID.equ"	
        org   $6100

        jsr   InitGlobals

        ; init music
        lda   #$01                       ; 1: play 60hz track at 50hz, 0: do not skip frames
        sta   Smps.60HzData 
        _RunObjectRoutineA ObjID_Smps,#0 ; YM2413_DrumModeOn
        ;ldb   #2                         ; music id
        ;_RunObjectRoutineA ObjID_Smps,#2 ; PlayMusic 

	; start music
        jsr   IrqSet50Hz

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL
        jsr   ReadJoypads 

        lda   Ctrl_1_Press
        bita  #button_A_mask
        beq   LevelMainLoop

        lda   #SndID_Ring
        ;lda   #SndID_Jump
        sta   Smps.SFXToPlay
        jmp   LevelMainLoop
       
* ==============================================================================
* Routines
* ==============================================================================
        INCLUDE "./Engine/InitGlobals.asm"
        INCLUDE "./Engine/Ram/BankSwitch.asm"
        INCLUDE "./Engine/Graphics/WaitVBL.asm"
        INCLUDE "./Engine/ObjectManagement/RunPgSubRoutine.asm"
        INCLUDE "./Engine/Irq/IrqSmpsObj.asm"      
        INCLUDE "./Engine/Joypad/ReadJoypads2.asm"
