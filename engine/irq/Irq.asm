
* ---------------------------------------------------------------------------
* IRQ Manager
* ---------------------------------------------------------------------------
*
* IrqSet50Hz
* -----------------------------------
* input REG : [none]
* reset REG : [d]
*
* IrqOn
* -----------------------------------
* reset REG : [a]
*
* IrqOff
* -----------------------------------
* reset REG : [a]
*
* IrqSync
* -----------------------------------
* This routine sync irq timer with a desired screen line refresh
* The timer (irq duration) is an input parameter (usually Irq_one_frame)
* input REG : [a] screen line (0-255)
*             [x] timer value
* reset REG : [d]
* feature request - implement a screen line range of 0-311
*
* IrqManager (irq call)
* -----------------------------------
* This routine run all requested engine code before and after the user irq
* routine (in Irq_user_routine)
* input REG : [dp] $E7 (set by the monitor)
* reset REG : [none]
*
* Special mode (glb_Page==0) is when page switching does not need to test
* if RAM or ROM is in use. In this case RAM is always expected as page type.
* This allows the use of <$E6 register without calling engine macro for
* page switch, thus it reduces the cycles cost. Used in tile rendering.
*
* Example of user routines (may be grouped in a subroutine) :
* - PalUpdateNow
* - PalCycling
* - PalRaster_1c
* - MusicFrame
* - PSGFrame
* - IrqObjSmps
* - IrqTimer
*
* ---------------------------------------------------------------------------

Irq_user_routine fdb 0                 ; user irq routine called by IrqManager 
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

IrqPause
        pshs  a
        lda   $6019
        anda  #$20
        bne   @irqoff
        lda   #0
        sta   @irqst
        bra   >
@irqoff lda   #1
        sta   @irqst
        jsr   IrqOff
!       puls  a,pc
IrqUnpause
        pshs  a
        lda   #0
@irqst  equ   *-1
        beq   >
        jsr   IrqOn
!       clr   @irqst
        puls  a,pc

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

        setdp $E7
IrqManager
        sts   @stack                   ; backup system stack
        lds   #Irq_sys_stack           ; set tmp system stack for IRQ 
        ldd   gfxlock.frame.count
        addd  #1
        std   gfxlock.frame.count
        tst   glb_Page                 ; test special mode (glb_Page==0)
        beq   @smode                   ; branch if rendering tiles - force RAM use instead of testing ROM or RAM
        _GetCartPageB
        stb   @page                    ; backup data page normally
        jsr   [Irq_user_routine]
        lda   #0                       ; (dynamic)
@page   equ   *-1
        _SetCartPageA                  ; restore data page
@end    lds   #0                       ; (dynamic) restore system stack   
@stack  equ   *-2
        jmp   $E830                    ; return to caller
@smode
        ldb   <$E6
        stb   @page2                   ; backup data page
        jsr   [Irq_user_routine]
        anda  #0
        sta   glb_Page                 ; restore special page mode
        lda   #0                       ; (dynamic)
@page2  equ   *-1
        sta   <$E6                     ; restore data page
        bra   @end

; This space allow the use of system stack inside IRQ calls
; otherwise the writes in sys stack will erase data when S is in use
; (outside of IRQ) for another task than sys stack, ex: stack blast copy 
        fill  0,32
Irq_sys_stack

        setdp dp/256