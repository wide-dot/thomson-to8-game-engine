* ---------------------------------------------------------------------------
* Single object loading subroutine
* Find an empty object array
*
* input  REG : [u] pointeur sur l'objet courant  
* output REG : [x] pointeur sur l'objet libre   
* ---------------------------------------------------------------------------

                                       *; ---------------------------------------------------------------------------
                                       *; Single object loading subroutine
                                       *; Find an empty object array
                                       *; ---------------------------------------------------------------------------
                                       *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                       *
                                       *; loc_17FDA: ; allocObject:
                                       *SingleObjLoad:
                                       *    lea (Dynamic_Object_RAM).w,a1 ; a1=object
                                       *    move.w  #(Dynamic_Object_RAM_End-Dynamic_Object_RAM)/object_size-1,d0 ; search to end of table
                                       *    tst.w   (Two_player_mode).w
                                       *    beq.s   +
                                       *    move.w  #(Dynamic_Object_RAM_2P_End-Dynamic_Object_RAM)/object_size-1,d0 ; search to $BF00 exclusive
                                       *
                                       */
                                       *    tst.b   id(a1)  ; is object RAM slot empty?
                                       *    beq.s   return_17FF8    ; if yes, branch
                                       *    lea next_object(a1),a1 ; load obj address ; goto next object RAM slot
                                       *    dbf d0,-    ; repeat until end
                                       *
                                       *return_17FF8:
                                       *    rts
                                       *; ===========================================================================
                                       *; ---------------------------------------------------------------------------
                                       *; Single object loading subroutine
                                       *; Find an empty object array AFTER the current one in the table
                                       *; ---------------------------------------------------------------------------
                                       *
                                       *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                       *
                                       *; loc_17FFA: ; allocObjectAfterCurrent:
SingleObjLoad2                         *SingleObjLoad2:
        tfr   u,x                      *    movea.l a0,a1
        leax  next_object,x            *    move.w  #Dynamic_Object_RAM_End,d0  ; $D000
        cmpx  #Dynamic_Object_RAM_End  *    sub.w   a0,d0   ; subtract current object location
        beq   SingleObjLoad2_02        *    if object_size=$40
                                       *    lsr.w   #6,d0   ; divide by $40
                                       *    subq.w  #1,d0   ; keep from going over the object zone
                                       *    bcs.s   return_18014
                                       *    else
                                       *    lsr.w   #6,d0           ; divide by $40
                                       *    move.b  +(pc,d0.w),d0       ; load the right number of objects from table
                                       *    bmi.s   return_18014        ; if negative, we have failed!
                                       *    endif
                                       *
SingleObjLoad2_01                      *-
        tst   ,x                       *    tst.b   id(a1)  ; is object RAM slot empty?
        beq   SingleObjLoad2_02        *    beq.s   return_18014    ; if yes, branch
        leax  next_object,x            *    lea next_object(a1),a1 ; load obj address ; goto next object RAM slot
        cmpx  #Dynamic_Object_RAM_End
        bne   SingleObjLoad2_01        *    dbf d0,-    ; repeat until end
                                       *
SingleObjLoad2_02                      *return_18014:
        rts                            *    rts
                                       *
                                       *    if object_size<>$40
                                       *+   dc.b -1
                                       *.a :=   1       ; .a is the object slot we are currently processing
                                       *.b :=   1       ; .b is used to calculate when there will be a conversion error due to object_size being > $40
                                       *
                                       *    rept (LevelOnly_Object_RAM-Reserved_Object_RAM_End)/object_size-1
                                       *        if (object_size * (.a-1)) / $40 > .b+1  ; this line checks, if there would be a conversion error
                                       *            dc.b .a-1, .a-1         ; and if is, it generates 2 entries to correct for the error
                                       *        else
                                       *            dc.b .a-1
                                       *        endif
                                       *
                                       *.b :=       (object_size * (.a-1)) / $40        ; this line adjusts .b based on the iteration count to check
                                       *.a :=       .a+1                    ; run interation counter
                                       *    endm
                                       *    even
                                       *    endif
                                       *; ===========================================================================
                                       *; ---------------------------------------------------------------------------
                                       *; Single object loading subroutine
                                       *; Find an empty object at or within < 12 slots after a3
                                       *; ---------------------------------------------------------------------------
                                       *
                                       *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                       *
                                       *; loc_18016:
                                       *SingleObjLoad3:
                                       *    movea.l a3,a1
                                       *    move.w  #$B,d0
                                       *
                                       *-
                                       *    tst.b   id(a1)  ; is object RAM slot empty?
                                       *    beq.s   return_18028    ; if yes, branch
                                       *    lea next_object(a1),a1 ; load obj address ; goto next object RAM slot
                                       *    dbf d0,-    ; repeat until end
                                       *
                                       *return_18028:
                                       *    rts
                                       *; ===========================================================================
