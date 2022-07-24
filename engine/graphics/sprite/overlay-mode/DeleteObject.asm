* ---------------------------------------------------------------------------
* DeleteObject
* ------------
* Subroutine to remove an object from display priority list
* and to delete object data in OST
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
        bra   @start
DeleteObject
        pshs  d,x,u
@start
        ldd   rsv_priority_prev_obj,u
        bne   @chainPrev
        lda   rsv_priority,u
        lsla
        ldy   #Tbl_Priority_First_Entry
        leay  a,y
        ldd   rsv_priority_next_obj,u
        std   ,y
        bra   @checkPrioNext
@chainPrev
        ldd   rsv_priority_next_obj,u
        ldy   rsv_priority_prev_obj,u        
        std   rsv_priority_next_obj,y        
@checkPrioNext       
        ldd   rsv_priority_next_obj,u
        bne   @chainNext
        lda   rsv_priority,u
        lsla
        ldy   #Tbl_Priority_Last_Entry
        leay  a,y
        ldd   rsv_priority_prev_obj,u
        std   ,y
        jsr   ClearObj
        puls  d,x,u,pc
@chainNext
        ldd   rsv_priority_prev_obj,u
        ldy   rsv_priority_next_obj,u        
        std   rsv_priority_prev_obj,y
        jsr   ClearObj
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