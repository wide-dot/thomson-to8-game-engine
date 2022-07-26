* ---------------------------------------------------------------------------
* DisplaySprite
* -------------
* Subroutine to manage sprite priority.
* Object's priority is read and object is (un)registred in display engine.
* priority: 0 - unregister
* priority: 1-8 - register sprite (2:front, ..., 8:back)  
*
* Sprite priority is stored in an open doubly linked list
* it allows to keep an exact sprite order for each screen buffer 
*
* DisplaySprite
* input REG : [u] object pointer (OST)
*
* DisplaySprite_x / DisplaySprite2
* input REG : [x] object pointer (OST)
*
* DisplaySprite_priority / DisplaySprite3
* input REG : [u] object pointer (OST)
* input REG : [a] priority
* ---------------------------------------------------------------------------

* ---------------------------------------------------------------------------
* Display Priority Structure - DPS
* ---------------------------------------------------------------------------
Tbl_Priority_First_Entry      fill  0,2+(nb_priority_levels*2) ; first address of object in linked list for each priority index (buffer 0) index 0 unused
Tbl_Priority_Last_Entry       fill  0,2+(nb_priority_levels*2) ; last address of object in linked list for each priority index (buffer 0) index 0 unused

DisplaySprite_priority
DisplaySprite3                              ; u : ptr object RAM, a : priority
        pshs  d,x,u
        sta   @prio
        bra   @Start
DisplaySprite_x                             ; x : ptr object RAM
DisplaySprite2
        pshs  d,x,u
        tfr   x,u
        bra   >
DisplaySprite                               ; u : ptr object RAM
        pshs  d,x,u
!       lda   priority,u                    ; read priority set for this object
        sta   @prio
@Start
        ldb   render_flags,u
        andb  #^render_hide_mask            ; unset hide flag
        stb   render_flags,u
        cmpa  rsv_priority,u
        beq   @rts                          ; priority and current priority are the same: nothing to do
        ldb   rsv_priority,u   
        bne   @ChangePriority
@InitPriority
        sta   rsv_priority,u                ; init priority for this screen buffer with priority from object
@CheckLastEntry
        ldy   #Tbl_Priority_Last_Entry
        asla                                ; change priority number to priority index (value x2)        
        tst   a,y                           ; test left byte only is ok, no object will be stored at $00__ address
        bne   @addToExistingNode            ; not the first object at this priority level, branch
@addFirstNode        
        stu   a,y                           ; save object as last entry in linked list
        ldy   #Tbl_Priority_First_Entry
        stu   a,y                           ; save object as first entry in linked list
        ldd   #0
        std   rsv_priority_prev_obj,u       ; clear object prev and next link, it's the only object at this priority level
        std   rsv_priority_next_obj,u
@rts
        puls  d,x,u,pc                      ; rts        
@addToExistingNode
        ldx   a,y                           ; x register now store last object at the priority level of current object
        stu   rsv_priority_next_obj,x       ; link last object with current object if active screen buffer 0
        stx   rsv_priority_prev_obj,u       ; link current object with previous object
        ldx   #0
        stx   rsv_priority_next_obj,u       ; clear object next link        
@LinkCurWithPrev        
        stu   a,y                           ; update last object in index
        puls  d,x,u,pc                      ; rts
@ChangePriority
        ldd   rsv_priority_prev_obj,u       ; unregister current priority
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
        bra   >
@chainNext
        ldd   rsv_priority_prev_obj,u
        ldy   rsv_priority_next_obj,u        
        std   rsv_priority_prev_obj,y
!
        lda   #0
@prio   equ   *-1
        bne   @CheckLastEntry               ; priority is != 0, branch to add object to display priority list
        puls  d,x,u,pc                      ; else new priority is 0, return

        
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to display a sprite/object, when a0 is the object RAM
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; sub_164F4:
                                                      *DisplaySprite:
                                                      *        lea     (Sprite_Table_Input).w,a1
                                                      *        move.w  priority(a0),d0
                                                      *        lsr.w   #1,d0
                                                      *        andi.w  #$380,d0
                                                      *        adda.w  d0,a1
                                                      *        cmpi.w  #$7E,(a1)
                                                      *        bhs.s   return_16510
                                                      *        addq.w  #2,(a1)
                                                      *        adda.w  (a1),a1
                                                      *        move.w  a0,(a1)
                                                      *
                                                      *return_16510:
                                                      *        rts
                                                      *; End of function DisplaySprite
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to display a sprite/object, when a1 is the object RAM
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; sub_16512:
                                                      *DisplaySprite2:
                                                      *        lea     (Sprite_Table_Input).w,a2
                                                      *        move.w  priority(a1),d0
                                                      *        lsr.w   #1,d0
                                                      *        andi.w  #$380,d0
                                                      *        adda.w  d0,a2
                                                      *        cmpi.w  #$7E,(a2)
                                                      *        bhs.s   return_1652E
                                                      *        addq.w  #2,(a2)
                                                      *        adda.w  (a2),a2
                                                      *        move.w  a1,(a2)
                                                      *
                                                      *return_1652E:
                                                      *        rts
                                                      *; End of function DisplaySprite2
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to display a sprite/object, when a0 is the object RAM
                                                      *; and d0 is already (priority/2)&$380
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; loc_16530:
                                                      *DisplaySprite3:
                                                      *        lea     (Sprite_Table_Input).w,a1
                                                      *        adda.w  d0,a1
                                                      *        cmpi.w  #$7E,(a1)
                                                      *        bhs.s   return_16542
                                                      *        addq.w  #2,(a1)
                                                      *        adda.w  (a1),a1
                                                      *        move.w  a0,(a1)
                                                      *
                                                      *return_16542:
                                                      *        rts   

