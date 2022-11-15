* ---------------------------------------------------------------------------
* RunObjects
* ------------
* Subroutines to run, load and unload objects
*
* RunObjects
* ----------
* Run all object's code
*
* LoadObject_u, LoadObject_x
* --------------------------
* Find a empty object slot and link the new object in run list
* return zero flag when no more memory avaible
* return the allocated memory in u or x
*
* UnloadObject_u, UnloadObject_x
* ------------------------------
* Unlink object (u or x) from run list and clear object's data
*
* ---------------------------------------------------------------------------

object_list_first fdb   0
object_list_last  fdb   0

RunObjects
        ldu   object_list_first
        beq   @rts
!       ldb   id,u
        beq   @skip                    ; Load an object with id=0 allows to book a empty slot
        ldx   #Obj_Index_Page
        abx
        lda   ,x              
        _SetCartPageA         
        aslb                  
        ldx   #Obj_Index_Address
        abx
        ldd   object_list_next,u       ; prevent self-deletion of objects
        std   @next
        jsr   [,x]              
        ldu   #0
@next   equ   *-2    
        bne   <         
@rts    rts   
@skip   ldu   object_list_next,u
        bne   <
        rts

LoadObject_u
        ldu   #Dynamic_Object_RAM
@loop
        tst   ,u
        beq   @link
        leau  next_object,u
        cmpu  #Dynamic_Object_RAM_End
        bne   @loop
        rts                            ; return z=1 when not found
@link
        pshs  x
        ldx   object_list_last
        beq   >
        stu   object_list_next,x
        stu   object_list_last
        stx   object_list_prev,u
        puls  x,pc                     ; return z=0 when found
!       stu   object_list_last
        stu   object_list_first
        puls  x,pc                     ; return z=0 when found

LoadObject_x
        ldx   #Dynamic_Object_RAM
@loop
        tst   ,x
        beq   @link
        leax  next_object,x
        cmpx  #Dynamic_Object_RAM_End
        bne   @loop
        rts                            ; return z=1 when not found
@link
        pshs  u
        ldu   object_list_last
        beq   >
        stx   object_list_next,u
        stx   object_list_last
        stu   object_list_prev,x
        puls  u,pc                     ; return z=0 when found
!       stx   object_list_last
        stx   object_list_first
        puls  u,pc                     ; return z=0 when found

UnloadObject_u
        pshs  d,x,y,u

        ldy   object_list_next,u
        beq   @noNext
        ldx   object_list_prev,u
        stx   object_list_prev,y
        beq   @noPrev
        sty   object_list_next,x
        bra   @clearObj
@noPrev sty   object_list_first
        bra   @clearObj
@noNext ldx   object_list_prev,u
        beq   >
        sty   object_list_next,x
!       stx   object_list_last
        bne   @clearObj
        stx   object_list_first
@clearObj
        leau  object_size,u ; move to end of data object structure
UnloadObject_clear
        ldd   #$0000        ; init regs to zero
        ldx   #$0000
        leay  ,x

        fill $36,(object_size/6)*2 ; generate object_size/6 assembly instructions $3636 (pshu  d,x,y) 

        IFEQ object_size%6-5
        pshu  a,x,y
        ENDC

        IFEQ object_size%6-4
        pshu  d,x
        ENDC

        IFEQ object_size%6-3
        pshu  a,x
        ENDC

        IFEQ object_size%6-2
        pshu  d
        ENDC

        IFEQ object_size%6-1
        pshu  a
        ENDC

        puls  d,x,y,u,pc

UnloadObject_x
        pshs  d,x,y,u

        ldy   object_list_next,x 
        beq   @noNext
        ldu   object_list_prev,x
        stu   object_list_prev,y
        beq   @noPrev
        sty   object_list_next,u
        bra   @clearObj
@noPrev sty   object_list_first
        bra   @clearObj
@noNext ldu   object_list_prev,x
        beq   >
        sty   object_list_next,u
!       stu   object_list_last
        bne   @clearObj
        stx   object_list_first
@clearObj
        leau  object_size,x ; move to end of data object structure
        bra   UnloadObject_clear