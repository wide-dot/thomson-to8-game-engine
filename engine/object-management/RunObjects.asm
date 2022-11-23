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
!       ldb   id,u                     ; Load an object with id=0 allows to book a empty slot
        beq   @skip                    ; that will be usable later, we need to skip in this case (no object index)
        ldx   #Obj_Index_Page
        abx
        lda   ,x              
        _SetCartPageA         
        aslb                  
        ldx   #Obj_Index_Address
        abx
        ldd   run_object_next,u        ; in case of self-deletion by current object
        std   object_list_next         ; we need to save the next object in run list
        jsr   [,x]              
        ldu   #0
object_list_next equ   *-2    
        bne   <         
@rts    rts   
@skip   ldu   run_object_next,u
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
        stu   run_object_next,x
        stu   object_list_last
        stx   run_object_prev,u
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
        stx   run_object_next,u
        stx   object_list_last
        stu   run_object_prev,x
        puls  u,pc                     ; return z=0 when found
!       stx   object_list_last
        stx   object_list_first
        puls  u,pc                     ; return z=0 when found

UnloadObject_u
        pshs  d,x,y,u
        cmpu  object_list_next         ; if current object to delete
        bne   >                        ; is the following to execute
        ldy   run_object_next,u
        sty   object_list_next         ; then update the next object in RunObjects routine
        beq   @noNext
!       ldy   run_object_next,u
        beq   @noNext
        ldx   run_object_prev,u
        stx   run_object_prev,y
        beq   @noPrev
        sty   run_object_next,x
        bra   @clearObj
@noPrev sty   object_list_first
        bra   @clearObj
@noNext ldx   run_object_prev,u
        beq   >
        sty   run_object_next,x
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
        cmpx  object_list_next         ; if current object to delete
        bne   >                        ; is the following to execute
        ldy   run_object_next,x
        sty   object_list_next         ; then update the next object in RunObjects routine
        beq   @noNext
        ldy   run_object_next,x 
        beq   @noNext
        ldu   run_object_prev,x
        stu   run_object_prev,y
        beq   @noPrev
        sty   run_object_next,u
        bra   @clearObj
@noPrev sty   object_list_first
        bra   @clearObj
@noNext ldu   run_object_prev,x
        beq   >
        sty   run_object_next,u
!       stu   object_list_last
        bne   @clearObj
        stx   object_list_first
@clearObj
        leau  object_size,x ; move to end of data object structure
        bra   UnloadObject_clear