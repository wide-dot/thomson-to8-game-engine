MC6846.TCR      equ $E7C5 ; irq timer ctrl
MC6846.TMSB     equ $E7C6 ; irq timer MSB
MC6846.TLSB     equ $E7C7 ; irq timer LSB
TIMERPT         equ $6027 ; routine irq timer

Irq_one_frame    equ 312*64-1          ; one frame timer (lines*cycles_per_lines-1), timer launch at -1
Irq_one_line     equ 64
       
IrqInit
        ldd   #IrqManager
        std   TIMERPT
	rts

IrqSet50Hz
        ldb   #$42
        stb   MC6846.TCR               ; timer precision x8
        ldd   #Irq_one_frame           ; on every frame
        std   MC6846.TMSB
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
        orcc  #$10                     ; tell 6809 to inactivate irq
        rts

IrqSync 
        ldb   #$42
        stb   MC6846.TCR
        
        ldb   #8                       ; ligne * 64 (cycles per line) / 8 (nb tempo loop cycles)
        mul
        tfr   d,y
        leay  -32,y                    ; manual adjustment
!
        tst   $E7E7                    ;
        bmi   <                        ; while spot is in a visible screen line        
!       tst   $E7E7                    ;
        bpl   <                        ; while spot is not in a visible screen line
!       leay  -1,y                     ;
        bne   <                        ; wait until desired line
       
        stx   MC6846.TMSB              ; spot is at the end of desired line
        rts  

IrqManager
        jsr   MusicFrame
        jmp   $E830                    ; return to caller
Irq_sys_stack