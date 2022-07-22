; search for a free object slot after the current one
; IN
; [u]: object slot
; OUT
; [x]: object slot
; [cc|z]: 1=found 0=not found  
                                                                          *;loc_6FA4:
SSSingleObjLoad2                                                          *SSSingleObjLoad2:
        leax  ,u                                                          *    movea.l a0,a1
        bra   @a                                                          *    move.w  #SS_Dynamic_Object_RAM_End,d5
                                                                          *    sub.w   a0,d5
                                                                          *
                                                                          *    if object_size=$40
                                                                          *    lsr.w   #6,d5
                                                                          *    subq.w  #1,d5
                                                                          *    bcs.s   +   ; rts
                                                                          *    else
                                                                          *    lsr.w   #6,d5           ; divide by $40
                                                                          *    move.b  ++(pc,d5.w),d5      ; load the right number of objects from table
                                                                          *    bmi.s   +           ; if negative, we have failed!
                                                                          *    endif
                                                                          *
@b      tst   id,x                                                        *-   tst.b   id(a1)
        beq   @c                                                          *    beq.s   +   ; rts
@a      leax  next_object,x                                               *    lea next_object(a1),a1
        cmpx  #Dynamic_Object_RAM_End                                     *    dbf d5,-
        bne   @b                                                          *
        lda   #$FF                                                        
@c      rts                                                               *+   rts
                                                                          *
                                                                          *
                                                                          *    if object_size<>$40
                                                                          *+   dc.b -1
                                                                          *.a :=   1       ; .a is the object slot we are currently processing
                                                                          *.b :=   1       ; .b is used to calculate when there will be a conversion error due to object_size being > $40
                                                                          *
                                                                          *    rept (SS_Dynamic_Object_RAM_End-SS_Object_RAM)/object_size-1
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