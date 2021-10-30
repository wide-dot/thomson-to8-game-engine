* ---------------------------------------------------------------------------
* IrqSmpsRaster/IrqSmps
* ------
* IRQ Subroutine to play sound with SN76489/YM2413 and render some Raster lines
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
*
* IrqSync
* reset REG : [d]
* ---------------------------------------------------------------------------
       
irq_routine       equ $6027 
irq_timer_ctrl    equ $E7C5 
irq_timer         equ $E7C6 
irq_one_frame     equ 312*64-1               ; one frame timer (lines*cycles_per_lines-1), timer launch at -1
Irq_Raster_Page   fdb $00 
Irq_Raster_Start  fdb $0000 
Irq_Raster_End    fdb $0000 
       
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
       
IrqSmps 
        _GetCartPageA
        sta   IrqSmps_end+1                           ; backup data page
        
        ldd   Vint_runcount
        addd  #1
        std   Vint_runcount
        
        sts   @a+2                                    ; backup system stack
        lds   #IRQSysStack                            ; set tmp system stack for IRQ 
        jsr   ReadJoypads        
        jsr   MusicFrame
@a      lds   #0                                      ; (dynamic) restore system stack   
        
IrqSmps_end        
        lda   #$00                                    ; (dynamic)
        _SetCartPageA                                 ; restore data page
        jmp   $E830                                   ; return to caller

; This space allow the use of system stack inside IRQ calls
; otherwise the writes in sys stack will erase data when S is in use
; (outside of IRQ) for another task than sys stack, ex: stack blast copy 
              fill  0,32
IRQSysStack                           
       
IrqSmpsRaster 
        _GetCartPageA
        sta   IrqSmpsRaster_end+1                      ; backup data page
        
        lda   Irq_Raster_Page
         _SetCartPageA                                ; load Raster data page
        ldx   Irq_Raster_Start
        lda   #32        
IrqSmpsRaster_1      
        bita  <$E7
        beq   IrqSmpsRaster_1                          ; while spot is not in a visible screen col
IrqSmpsRaster_2        
        bita  <$E7 
        bne   IrqSmpsRaster_2                          ; while spot is in a visible screen col
                
        mul                                           ; tempo                
        mul                                           ; tempo
        nop                
IrqSmpsRaster_render
        tfr   a,b                                     ; tempo
        tfr   a,b                                     ; tempo
        tfr   a,b                                     ; tempo        
        ldd   1,x
        std   >*+8
        lda   ,x        
        sta   <$DB
        ldd   #$0000
        stb   <$DA 
        sta   <$DA
        leax  3,x
        cmpx  Irq_Raster_End
        bne   IrqSmpsRaster_render 

        ldd   Vint_runcount
        addd  #1
        std   Vint_runcount     

        sts   @a+2                                    ; backup system stack
        lds   #IRQSysStack                            ; set tmp system stack for IRQ 
        jsr   ReadJoypads        
        jsr   MusicFrame
@a      lds   #0                                      ; (dynamic) restore system stack   

IrqSmpsRaster_end        
        lda   #$00
        _SetCartPageA                                 ; restore data page
        jmp   $E830                                   ; return to caller 
