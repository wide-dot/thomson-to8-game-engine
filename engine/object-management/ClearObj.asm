* ---------------------------------------------------------------------------
* ClearObj
* --------
* Subroutine to clear an object data in OST
*
* input REG : [u] pointer on objet (OST)
* clear REG : none
* ---------------------------------------------------------------------------

ClearObj 
        pshs  d,x,y

        leau  object_size,u ; move to end of data object structure
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

        puls  d,x,y,pc