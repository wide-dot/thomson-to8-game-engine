* ---------------------------------------------------------------------------
* UnsetDisplayPriority
* --------------------
* Subroutine to unset sprites in Display Sprite Priority structure
* Read Lst_Priority_Unset_0/1
*
* input REG : none
* ---------------------------------------------------------------------------
									   
UnsetDisplayPriority

UDP_Start
        lda   glb_Cur_Wrk_Screen_Id         ; read current screen buffer for write operations
        bne   UDP_B1
        
UDP_B0                                    
        ldx   #Lst_Priority_Unset_0+2
        
UDP_CheckEndB0        
        cmpx  Lst_Priority_Unset_0          ; end of priority unset list
        bne   UDP_CheckPrioPrevB0
        
UDP_InitListB0      
        ldx   #Lst_Priority_Unset_0+2 
        stx   Lst_Priority_Unset_0          ; set Lst_Priority_Unset_0 index
        rts
        
UDP_CheckPrioPrevB0
        ldu   ,x++
        ldd   rsv_priority_prev_obj_0,u
        bne   UDP_ChainPrevB0
        
        lda   rsv_priority_0,u
        lsla
        ldy   #Tbl_Priority_First_Entry_0
        leay  a,y
        ldd   rsv_priority_next_obj_0,u
        std   ,y
        bra   UDP_CheckPrioNextB0
                
UDP_ChainPrevB0
        ldd   rsv_priority_next_obj_0,u
        ldy   rsv_priority_prev_obj_0,u        
        std   rsv_priority_next_obj_0,y        

UDP_CheckPrioNextB0       
        ldd   rsv_priority_next_obj_0,u
        bne   UDP_ChainNextB0

        lda   rsv_priority_0,u
        lsla
        ldy   #Tbl_Priority_Last_Entry_0
        leay  a,y
        ldd   rsv_priority_prev_obj_0,u
        std   ,y
        bra   UDP_CheckDeleteB0
                
UDP_ChainNextB0
        ldd   rsv_priority_prev_obj_0,u
        ldy   rsv_priority_next_obj_0,u        
        std   rsv_priority_prev_obj_0,y
        
UDP_CheckDeleteB0
        lda   render_flags,u
        anda  #render_todelete_mask
        beq   UDP_SetNewPrioB0
        lda   rsv_prev_render_flags_0,u
        bmi   UDP_SetNewPrioB0
        lda   rsv_prev_render_flags_1,u
        bmi   UDP_SetNewPrioB0
        jsr   ClearObj
        bra   UDP_CheckEndB0
        
UDP_SetNewPrioB0
        lda   priority,u
        sta   rsv_priority_0,u
        bra   UDP_CheckEndB0        

UDP_B1                                    
        ldx   #Lst_Priority_Unset_1+2
        
UDP_CheckEndB1        
        cmpx  Lst_Priority_Unset_1          ; end of priority unset list
        bne   UDP_CheckPrioPrevB1
        
UDP_InitListB1      
        ldx   #Lst_Priority_Unset_1+2 
        stx   Lst_Priority_Unset_1          ; set Lst_Priority_Unset_0 index
        rts
        
UDP_CheckPrioPrevB1
        ldu   ,x++
        ldd   rsv_priority_prev_obj_1,u
        bne   UDP_ChainPrevB1
        
        lda   rsv_priority_1,u
        lsla
        ldy   #Tbl_Priority_First_Entry_1
        leay  a,y
        ldd   rsv_priority_next_obj_1,u
        std   ,y
        bra   UDP_CheckPrioNextB1
                
UDP_ChainPrevB1
        ldd   rsv_priority_next_obj_1,u
        ldy   rsv_priority_prev_obj_1,u        
        std   rsv_priority_next_obj_1,y        

UDP_CheckPrioNextB1       
        ldd   rsv_priority_next_obj_1,u
        bne   UDP_ChainNextB1

        lda   rsv_priority_1,u
        lsla
        ldy   #Tbl_Priority_Last_Entry_1
        leay  a,y
        ldd   rsv_priority_prev_obj_1,u
        std   ,y
        bra   UDP_CheckDeleteB1
                
UDP_ChainNextB1
        ldd   rsv_priority_prev_obj_1,u
        ldy   rsv_priority_next_obj_1,u        
        std   rsv_priority_prev_obj_1,y
        
UDP_CheckDeleteB1
        lda   render_flags,u
        anda  #render_todelete_mask
        beq   UDP_SetNewPrioB1
        lda   rsv_prev_render_flags_0,u
        bmi   UDP_SetNewPrioB1
        lda   rsv_prev_render_flags_1,u
        bmi   UDP_SetNewPrioB1
        jsr   ClearObj
        bra   UDP_CheckEndB1
        
UDP_SetNewPrioB1
        lda   priority,u
        sta   rsv_priority_1,u
        bra   UDP_CheckEndB1