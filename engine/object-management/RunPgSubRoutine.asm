* ---------------------------------------------------------------------------
* RunPgSubRoutine
* ------------
* Subroutine to run a another Sub Routine in a different Memory Page
*
* input : PSR_Page, PSR_Address, PSR_Param
* ---------------------------------------------------------------------------

RunPgSubRoutine 
        _GetCartPageA
        sta   @page
        lda   #0
PSR_Page equ *-1
        _SetCartPageA                  ; set data page for sub routine to call
        lda   #0
PSR_Param equ *-1
        jsr   >0
PSR_Address equ *-2
RunPgSubRoutine_return        
        lda   #0
@page   equ *-1
        _SetCartPageA                  ; restore data page
        rts
