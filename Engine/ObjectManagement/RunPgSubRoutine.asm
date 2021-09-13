* ---------------------------------------------------------------------------
* RunPgSubRoutine
* ------------
* Subroutine to run a another Sub Routine in a different Memory Page
*
* input REG : [A] Memory Page of Sub Routine
* ---------------------------------------------------------------------------

RunPgSubRoutine 
        _GetCartPageB
        stb   RunPgSubRoutine_return+1 ; backup data page
        
        _SetCartPageA                  ; set data page for sub routine to call
        jsr   [glb_Address]

RunPgSubRoutine_return        
        lda   #$00
        _SetCartPageA                  ; restore data page
        rts

glb_Address                   fdb   $0000