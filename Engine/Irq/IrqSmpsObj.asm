* ---------------------------------------------------------------------------
* IrqSmps
* -------
* IRQ Subroutine to play sound with SN76489/YM2413
*
* input REG : [dp] with value E7 (from Monitor ROM)
* reset REG : none
*
* IrqOn
* reset REG : [a]
*
* IrqOff
* reset REG : [a]
* ---------------------------------------------------------------------------

irq_routine       equ $6027 
irq_timer_ctrl    equ $E7C5 
irq_timer         equ $E7C6
irq_one_frame     equ 312*64-1               ; one frame timer (lines*cycles_per_lines-1), timer launch at -1

SmpsVar STRUCT
SFXPriorityVal                 rmb   1        
TempoTimeout                   rmb   1        
CurrentTempo                   rmb   1                ; Stores current tempo value here
StopMusic                      rmb   1                ; Set to 7Fh to pause music, set to 80h to unpause. Otherwise 00h
FadeOutCounter                 rmb   1        
FadeOutDelay                   rmb   1        
QueueToPlay                    rmb   1                ; if NOT set to 80h, means new index was requested by 68K
SFXToPlay                      rmb   2                ; When Genesis wants to play "normal" sound, it writes it here *** moved to IrqSmpsObj.asm
VoiceTblPtr                    rmb   2                ; address of the voices
SFXVoiceTblPtr                 rmb   2                ; address of the SFX voices
FadeInFlag                     rmb   1        
FadeInDelay                    rmb   1        
FadeInCounter                  rmb   1        
1upPlaying                     rmb   1        
TempoMod                       rmb   1        
TempoTurbo                     rmb   1                ; Stores the tempo if speed shoes are acquired (or 7Bh is played anywho)
SpeedUpFlag                    rmb   1        
DACEnabled                     rmb   1                
60HzData                       rmb   1                ; 1: play 60hz track at 50hz, 0: do not skip frames
 ENDSTRUCT

SmpsStructStart
Smps          SmpsVar
        org   SmpsStructStart                
        fill  0,sizeof{SmpsVar}
       
IrqSet50Hz
        ldb   #$42
        stb   irq_timer_ctrl                     ; timer precision x8
        ldd   #IrqSmps
        std   irq_routine
        ldx   #irq_one_frame                     ; on every frame
        stx   irq_timer
        jsr   IrqOn   
        rts
       
IrqOn         
        lda   $6019                           
        ora   #$20
        sta   $6019                                   ; STATUS register
        andcc #$EF                                    ; tell 6809 to activate irq
        rts
        
IrqOff 
        lda   $6019                           
        anda  #$DF
        sta   $6019                                   ; STATUS register
        orcc  #$10                                    ; tell 6809 to activate irq
        rts
        
IrqSmps 
        sts   @a+2                                    ; backup system stack
        lds   #IRQSysStack                            ; set tmp system stack for IRQ 
        _GetCartPageA
        sta   IrqSmps_end+1                           ; backup data page
        ldd   Vint_runcount
        addd  #1
        std   Vint_runcount
        _RunObjectRoutine ObjID_Smps,#4               ; MusicFrame
IrqSmps_end        
        lda   #$00                                    ; (dynamic)
        _SetCartPageA                                 ; restore data page
@a      lds   #0                                      ; (dynamic) restore system stack   
        jmp   $E830                                   ; return to caller

; This space allow the use of system stack inside IRQ calls
; otherwise the writes in sys stack will erase data when S is in use
; (outside of IRQ) for another task than sys stack, ex: stack blast copy 
              fill  0,32
IRQSysStack