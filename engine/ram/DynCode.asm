;******************************************************************
; DynCode routines
; 
; 
;******************************************************************

; Write a value (from A) to a list of addresses (in X)
; end of list is -1

DynCode_ApplyAToListX
        pshs  u
@loop   ldu   ,x++
        cmpu  #-1
        beq   @end
        sta   ,u
        bra   @loop
@end    puls  u,pc