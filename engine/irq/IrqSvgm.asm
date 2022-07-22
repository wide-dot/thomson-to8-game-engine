* ---------------------------------------------------------------------------
* IrqSvgm
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
irq_one_frame     equ 312*64-1         ; one frame timer (lines*cycles_per_lines-1), timer launch at -1
       
IrqSet50Hz
        ldb   #$42
        stb   irq_timer_ctrl           ; timer precision x8
        ldd   #IrqSvgm
        std   irq_routine
        ldx   #irq_one_frame           ; on every frame
        stx   irq_timer
        jsr   IrqOn   
        rts
       
IrqOn         
        lda   $6019                           
        ora   #$20
        sta   $6019                    ; STATUS register
        andcc #$EF                     ; tell 6809 to activate irq
        rts
        
IrqOff 
        lda   $6019                           
        anda  #$DF
        sta   $6019                    ; STATUS register
        orcc  #$10                     ; tell 6809 to activate irq
        rts
        
IrqSvgm 
        _GetCartPageA
        sta   IrqSvgm_end+1            ; backup data page
        
        ldd   Vint_runcount
        addd  #1
        std   Vint_runcount
        
        sts   @a+2                     ; backup system stack
        lds   #IRQSysStack             ; set tmp system stack for IRQ 
        jsr   MusicFrame
@a      lds   #0                       ; (dynamic) restore system stack   
        
IrqSvgm_end        
        lda   #$00                     ; (dynamic)
        _SetCartPageA                  ; restore data page
        jmp   $E830                    ; return to caller
        
; This space allow the use of system stack inside IRQ calls
; otherwise the writes in sys stack will erase data when S is in use
; (outside of IRQ) for another task than sys stack, ex: stack blast copy 
        fill  0,32
IRQSysStack