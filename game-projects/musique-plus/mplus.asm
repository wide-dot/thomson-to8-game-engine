
        INCLUDE "./engine/macros.asm"        
        org   $A000

        setdp $FF

        pshs d,x,y,u,dp

        ; init music
        jsr   IrqInit
        lda   #255
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

        lda   #$01
        sta   Smps.60HzData 
        jsr   YM2413_DrumModeOn
        ldx   #Smps_ARZ
        jsr   PlayMusic 

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        lda   $E7C8
        lsra
        bcs   @exit   
        bra   LevelMainLoop
@exit
        jsr   IrqOff
        jsr   InitMusicPlayback
        puls  d,x,y,u,dp,pc

Smps_ARZ
        INCLUDEBIN "./2-06 Aquatic Ruin Zone.1380.smp"
        INCLUDE "./smps.asm" 
        INCLUDE "./irq.asm"
