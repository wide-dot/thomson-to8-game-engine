* ---------------------------------------------------------------------------
* RunPgSubRoutine
* ------------
* Subroutine to run a another Sub Routine in a different Memory Page
*
* input REG : [A] Memory Page of Sub Routine
* ---------------------------------------------------------------------------

RunPgSubRoutine 
        _GetCartPageA
        sta   PSR_RetPage
        
        lda   #0
PSR_Page equ *-1
        _SetCartPageA                  ; set data page for sub routine to call
        jsr   >0
PSR_Address equ *-2

RunPgSubRoutine_return        
        lda   #0
PSR_RetPage equ *-1
        _SetCartPageA                  ; restore data page
        rts
