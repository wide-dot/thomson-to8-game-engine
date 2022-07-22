* ---------------------------------------------------------------------------
* DeleteObject
* ------------
* Subroutine to delete an object.
* If the object is rendered as a sprite it will be deleted by EraseSprites
* routine
*
* DeleteObject
* input REG : [u] object pointer (OST)
*
* DeleteObject_x
* input REG : [x] object pointer (OST)
* ---------------------------------------------------------------------------

DeleteObject_x
DeleteObject2
        pshs  d,x,u
        leau  ,x   
        bra   DOB_Start
DeleteObject_return
        puls  d,x,u,pc
        
DeleteObject
        pshs  d,x,u
        
        lda   render_flags,u
        anda  #render_todelete_mask
        bne   DeleteObject_return           ; branch if already registred for deletion        
        
DOB_Start
        lda   rsv_prev_render_flags_0,u
        bpl   DOB_RemoveFromDPSB0           ; branch if not onscreen on buffer 0

DOB_ToDeleteFlag0
        lda   render_flags,u
        ora   #render_todelete_mask
        sta   render_flags,u                ; set todelete flag, object will be deleted after sprite erase
        
DOB_Unset0        
        ldx   Lst_Priority_Unset_0          ; add object to unset list on buffer 0
        stu   ,x
        leax  2,x
        stx   Lst_Priority_Unset_0
        
DOB_TestOnscreen1
        lda   rsv_prev_render_flags_1,u
        bpl   DOB_RemoveFromDPSB1           ; branch if not onscreen on buffer 1
        
DOB_ToDeleteFlag1
        lda   render_flags,u
        ora   #render_todelete_mask
        sta   render_flags,u                ; set todelete flag, object will be deleted after sprite erase
        
DOB_Unset1
        ldx   Lst_Priority_Unset_1          ; add object to unset list on buffer 1                       
        stu   ,x
        leax  2,x
        stx   Lst_Priority_Unset_1
        puls  d,x,u,pc               

DOB_RemoveFromDPSB0
        ldd   rsv_priority_prev_obj_0,u     ; remove object from DSP on buffer 0
        bne   DOB_ChainPrevB0
        
        lda   rsv_priority_0,u
        lsla
        ldy   #Tbl_Priority_First_Entry_0
        leay  a,y
        ldd   rsv_priority_next_obj_0,u
        std   ,y
        bra   DOB_CheckPrioNextB0
                
DOB_ChainPrevB0
        ldd   rsv_priority_next_obj_0,u
        ldy   rsv_priority_prev_obj_0,u        
        std   rsv_priority_next_obj_0,y        

DOB_CheckPrioNextB0       
        ldd   rsv_priority_next_obj_0,u
        bne   DOB_ChainNextB0

        lda   rsv_priority_0,u
        lsla
        ldy   #Tbl_Priority_Last_Entry_0
        leay  a,y
        ldd   rsv_priority_prev_obj_0,u
        std   ,y
        bra   DOB_TestOnscreen1
                
DOB_ChainNextB0
        ldd   rsv_priority_prev_obj_0,u
        ldy   rsv_priority_next_obj_0,u        
        std   rsv_priority_prev_obj_0,y
        bra   DOB_TestOnscreen1        

DOB_RemoveFromDPSB1
        ldd   rsv_priority_prev_obj_1,u
        bne   DOB_ChainPrevB1
        
        lda   rsv_priority_1,u
        lsla
        ldy   #Tbl_Priority_First_Entry_1
        leay  a,y
        ldd   rsv_priority_next_obj_1,u
        std   ,y
        bra   DOB_CheckPrioNextB1
                
DOB_ChainPrevB1
        ldd   rsv_priority_next_obj_1,u
        ldy   rsv_priority_prev_obj_1,u        
        std   rsv_priority_next_obj_1,y        

DOB_CheckPrioNextB1       
        ldd   rsv_priority_next_obj_1,u
        bne   DOB_ChainNextB1

        lda   rsv_priority_1,u
        lsla
        ldy   #Tbl_Priority_Last_Entry_1
        leay  a,y
        ldd   rsv_priority_prev_obj_1,u
        std   ,y
        lda   rsv_prev_render_flags_0,u
        bmi   DOB_rts                       ; branch if onscreen on buffer 0 (do not erase object)        
        jsr   ClearObj                      ; this object is not onscreen anymore, clear this object now
DOB_rts                                
        puls  d,x,u,pc        
                
DOB_ChainNextB1
        ldd   rsv_priority_prev_obj_1,u
        ldy   rsv_priority_next_obj_1,u        
        std   rsv_priority_prev_obj_1,y
        lda   rsv_prev_render_flags_0,u
        bmi   DOB_rts                       ; branch if onscreen on buffer 0 (do not erase object)        
        jsr   ClearObj                      ; this object is not onscreen anymore, clear this object now
        puls  d,x,u,pc        

                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to delete an object
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; freeObject:
                                                      *DeleteObject:
                                                      *        movea.l a0,a1
                                                      *
                                                      *; sub_164E8:
                                                      *DeleteObject2:
                                                      *        moveq   #0,d1
                                                      *
                                                      *        moveq   #bytesToLcnt(next_object),d0 ; we want to clear up to the next object
                                                      *        ; delete the object by setting all of its bytes to 0
                                                      *-       move.l  d1,(a1)+
                                                      *        dbf     d0,-
                                                      *    if object_size&3
                                                      *        move.w  d1,(a1)+
                                                      *    endif
                                                      *
                                                      *        rts
                                                      *; End of function DeleteObject2                                         