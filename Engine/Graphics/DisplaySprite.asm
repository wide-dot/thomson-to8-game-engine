* ---------------------------------------------------------------------------
* DisplaySprite
* -------------
* Subroutine to manage sprite priority.
* Object's priority is read and object is (un)registred in display engine.
* priority: 0 - unregistred
* priority: 1 - register non moving overlay sprite
* priority; 2-8 - register moving sprite (2:front, ..., 8:back)  
*
* Unlike original S2 code, sprite priority is stored in an open doubly linked list
* it allows to keep an exact sprite order for each screen buffer 
*
* DisplaySprite
* input REG : [u] object pointer (OST)
*
* DisplaySprite_x
* input REG : [x] object pointer (OST)
* ---------------------------------------------------------------------------
                                                                           
DisplaySprite_x 
        pshs  d,x,u
        tfr   x,u
        bra   DSP_Start
        
DisplaySprite 
        pshs  d,x,u
        
DSP_Start
        lda   render_flags,u
        anda  #^render_hide_mask            ; unset hide flag
        sta   render_flags,u

        lda   glb_Cur_Wrk_Screen_Id         ; read current screen buffer for write operations
        bne   DSP_SetBuffer1
        
DSP_SetBuffer0        
        leax  rsv_buffer_0,u                ; set x pointer to object variables that belongs to screen buffer 0
        ldy   #DPS_buffer_0                 ; set y pointer to Display Priority Structure that belongs to screen buffer 0
        bra   DSP_BufferPositionned
        
DSP_SetBuffer1       
        leax  rsv_buffer_1,u                ; set x pointer to object variables that belongs to screen buffer 1
        ldy   #DPS_buffer_1                 ; set y pointer to Display Priority Structure that belongs to screen buffer 1        
        
DSP_BufferPositionned       
        lda   priority,u                    ; read priority set for this object
        cmpa  buf_priority,x
        beq   DSP_rts                       ; priority and current priority are the same: nothing to do
        ldb   buf_priority,x   
        bne   DSP_ChangePriority
        
DSP_InitPriority
        sta   buf_priority,x                ; init priority for this screen buffer with priority from object
        
DSP_CheckLastEntry
        leay  buf_Tbl_Priority_Last_Entry,y
        asla                                ; change priority number to priority index (value x2)        
        tst   a,y                           ; test left byte only is ok, no object will be stored at $00__ address
        bne   DSP_addToExistingNode         ; not the first object at this priority level, branch
        
DSP_addFirstNode        
        stu   a,y                           ; save object as last entry in linked list
        leay  buf_Tbl_Priority_First_Entry-buf_Tbl_Priority_Last_Entry,y
        stu   a,y                           ; save object as first entry in linked list
        ldd   #0
        std   buf_priority_prev_obj,x       ; clear object prev and next link, it's the only object at this priority level
        std   buf_priority_next_obj,x
        
DSP_rts
        puls  d,x,u,pc                      ; rts        
        
DSP_addToExistingNode
        ldx   a,y                           ; x register now store last object at the priority level of current object
        ldb   glb_Cur_Wrk_Screen_Id
        bne   DSP_LinkBuffer1
        stu   rsv_priority_next_obj_0,x     ; link last object with current object if active screen buffer 0
        stx   rsv_priority_prev_obj_0,u     ; link current object with previous object
        clr   rsv_priority_next_obj_0,u     ; clear object next link        
        clr   rsv_priority_next_obj_0+1,u   ; clear object next link        
        bra   DSP_LinkCurWithPrev        
DSP_LinkBuffer1        
        stu   rsv_priority_next_obj_1,x     ; link last object with current object if active screen buffer 1
        stx   rsv_priority_prev_obj_1,u     ; link current object with previous object
        clr   rsv_priority_next_obj_1,u     ; clear object next link        
        clr   rsv_priority_next_obj_1+1,u   ; clear object next link        
        
DSP_LinkCurWithPrev        
        stu   a,y                           ; update last object in index
        puls  d,x,u,pc                      ; rts
        
DSP_ChangePriority
        pshs  d,y
        leay  buf_Lst_Priority_Unset,y
        stu   [,y]                          ; add current object address to last free unset list cell
        ldd   ,y
        addd  #2
        std   ,y                            ; set unset list free index to next free cell of unset list
        puls  d,y                           ; get back DSP_buffer in y
        cmpa  #0
        bne   DSP_CheckLastEntry            ; priority is != 0, branch to add object to display priority list
        puls  d,x,u,pc                      ; rts

        
                                       *; ---------------------------------------------------------------------------
                                       *; Subroutine to display a sprite/object, when a0 is the object RAM
                                       *; ---------------------------------------------------------------------------
                                       *
                                       *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                       *
                                       *; sub_164F4:
                                       *DisplaySprite:
                                       *    lea (Sprite_Table_Input).w,a1
                                       *    move.w  priority(a0),d0
                                       *    lsr.w   #1,d0
                                       *    andi.w  #$380,d0
                                       *    adda.w  d0,a1
                                       
                                       *    cmpi.w  #$7E,(a1)
                                       *    bhs.s   return_16510
                                       *    addq.w  #2,(a1)
                                       
                                       *    adda.w  (a1),a1
                                       *    move.w  a0,(a1)
                                       *
                                       *return_16510:
                                       
                                       *    rts
                                       *; End of function DisplaySprite       

* ---------------------------------------------------------------------------
* Display Priority Structure - DPS
* ---------------------------------------------------------------------------

DPS_buffer_0
Tbl_Priority_First_Entry_0    fill  0,2+(nb_priority_levels*2) ; first address of object in linked list for each priority index (buffer 0) index 0 unused
Tbl_Priority_Last_Entry_0     fill  0,2+(nb_priority_levels*2) ; last address of object in linked list for each priority index (buffer 0) index 0 unused
Lst_Priority_Unset_0          fdb   Lst_Priority_Unset_0+2     ; pointer to end of list (initialized to its own address+2) (buffer 0)
                              fill  0,(nb_graphical_objects*2) ; objects to delete from priority list
DPS_buffer_1                              
Tbl_Priority_First_Entry_1    fill  0,2+(nb_priority_levels*2) ; first address of object in linked list for each priority index (buffer 1) index 0 unused
Tbl_Priority_Last_Entry_1     fill  0,2+(nb_priority_levels*2) ; last address of object in linked list for each priority index (buffer 1) index 0 unused
Lst_Priority_Unset_1          fdb   Lst_Priority_Unset_1+2     ; pointer to end of list (initialized to its own address+2) (buffer 1)
                              fill  0,(nb_graphical_objects*2) ; objects to delete from priority list
DPS_buffer_end                              

buf_Tbl_Priority_First_Entry  equ   0                                                            
buf_Tbl_Priority_Last_Entry   equ   Tbl_Priority_Last_Entry_0-DPS_buffer_0          
buf_Lst_Priority_Unset        equ   Lst_Priority_Unset_0-DPS_buffer_0                                       