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
*
* IrqSync
* input REG : [a] screen line (0-199)
*             [x] timer value
* reset REG : [d]
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
SFXToPlay                      rmb   1                ; When Genesis wants to play "normal" sound, it writes it here
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

        lda   #199                               ; screen line to sync
        ldx   #irq_one_frame                     ; on every frame
        jsr   IrqSync
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
        
IrqSync 
        ldb   #$42
        stb   irq_timer_ctrl
        
        ldb   #8                                      ; ligne * 64 (cycles par ligne) / 8 (nb cycles boucle tempo)
        mul
        tfr   d,y
        leay  -32,y                                   ; manual adjustment

IrqSync_1
        tst   $E7E7                                   ;
        bmi   IrqSync_1                               ; while spot is in a visible screen line        
IrqSync_2
        tst   $E7E7                                   ;
        bpl   IrqSync_2                               ; while spot is not in a visible screen line
IrqSync_3
        leay  -1,y                                    ;
        bne   IrqSync_3                               ; wait until desired line
       
        stx   irq_timer                               ; spot is at the end of desired line
        rts     

        SETDP   $E7

IrqSmps 
        INCLUDE "./Engine/Irq/timer/timer.asm"

        ldd   Vint_runcount                           ; global continuous frame timer
        addd  #1
	std   Vint_runcount

        sts   @bcks                                   ; backup system stack
        lds   #IRQSysStack                            ; set tmp system stack for IRQ 
 	lda   glb_pal_elapsed_frames                  ; PaletteCycling
        inca
	sta   glb_pal_elapsed_frames
	cmpa  #8
	ble   @a	
	lda   #0
	sta   glb_pal_elapsed_frames
	sta   Refresh_palette
	ldx   Cur_palette
	ldu   4,x
	ldd   2,x
	std   4,x
	ldd   ,x
	std   2,x
	stu   ,x
@a      jsr   UpdatePaletteNow
        lda   Obj_Index_Page+ObjID_Smps
        ldx   Obj_Index_Address+2*ObjID_Smps          ; load page and addr of sound routine
        tst   glb_Page                                ; test special mode (glb_Page==0)
        beq   @part2                                  ; branch if rendering tiles - force RAM use instead of testing ROM or RAM
        _GetCartPageB
        stb   @page                                   ; backup data page normally
        sta   $E7E6                                   ; mount Smps page in RAM
        lda   #4                                      ; Smps MusicFrame routine id
        jsr   ,x                                      ; Call Smps sound driver
        lda   #0                                      ; (dynamic)
@page   equ   *-1
        _SetCartPageA                                 ; restore data page
@end    lds   #0                                      ; (dynamic) restore system stack   
@bcks   equ   *-2
        jmp   $E830                                   ; return to caller
@part2
        ldb   $E7E6
        stb   @page2                                  ; backup data page
        sta   $E7E6                                   ; mount Smps page in RAM
        lda   #4                                      ; Smps MusicFrame routine id
        jsr   ,x                                      ; Call Smps sound driver
        anda  #0
        sta   glb_Page                                ; restore special mode
        lda   #0                                      ; (dynamic)
@page2  equ   *-1
        sta   $E7E6                                   ; restore data page
        bra   @end                                    ; branch to restore system stack
 
; This space allow the use of system stack inside IRQ calls
; otherwise the writes in sys stack will erase data when S is in use
; (outside of IRQ) for another task than sys stack, ex: stack blast copy 
              fill  0,32
IRQSysStack

glb_pal_elapsed_frames fcb 0
	INCLUDE "./Engine/Palette/UpdatePaletteNow.asm"

        SETDP   dp/256