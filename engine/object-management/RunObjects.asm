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

; Stack Structure to hold free object slot addresses
STACK_SLOT_ADDRESS FILL 0,nb_dynamic_objects*2 
STACK_SLOT_ADDRESS_END   
STACK_POINTER FDB 0 ; Stack pointer on the STACK

; loop to init the Stack
InitStack
        ldu   #STACK_SLOT_ADDRESS_END  
        ldx   #Dynamic_Object_RAM_End-object_size
@loop   pshu  x
        leax  -object_size,x
        cmpu  #STACK_SLOT_ADDRESS
        bne   @loop
        stu   STACK_POINTER    
        rts    

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
        ldu   run_object_next,u
        bne   <
        ldu   #0
object_list_next equ   *-2    
        bne   <         
@rts    rts   
@skip   ldu   run_object_next,u
        bne   <
        rts

LoadObject_u
        ldu STACK_POINTER              ; is there a free slot ?
        cmpu #STACK_SLOT_ADDRESS_END   ; 
        bne @link                      ; Yes a slot is free, let's get it and link it
        rts                            ; return z=1 when not found
@link
        pulu D                         ; get a the free slot from the slot stack
        stu STACK_POINTER              ; updating the slot stack pointer
        tfr D,U                        ; U is now pointing to the free slot address        
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
        ldx STACK_POINTER              ; is there a free slot ?
        cmpx #STACK_SLOT_ADDRESS_END   ; 
        bne @link                      ; Yes a slot is free, let's get it and link it
        rts                            ; return z=1 when not found
@link
        pshs  u                        ; let's save U
        leau 2,x                        ; X contains de address of the stack, so let's transfer it to U
        ldx ,x                         ; get a the free slot from the slot stack, X points this free slot
        stu STACK_POINTER              ; updating the slot stack pointer
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
        ; let's update the stack
        tfr U,D
        ldu STACK_POINTER
        pshu D
        stu STACK_POINTER
        tfr D,U
        ; done
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
        ; let's update the stack
        ldu STACK_POINTER
        pshu X
        stu STACK_POINTER
        ; done
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
        stu   object_list_first
@clearObj
        leau  object_size,x ; move to end of data object structure
        bra   UnloadObject_clear

ManagedObjects_ClearAll
        ldd   #0
        ldx   #0
        leay  ,x
        ldu   #Dynamic_Object_RAM_End
!       cmpu  #Dynamic_Object_RAM+6
        bls   >
        pshu  d,x,y
        bra   <
!       pshu  a
        cmpu  #Dynamic_Object_RAM
        bne   <
        std   object_list_first
        std   object_list_last
        rts