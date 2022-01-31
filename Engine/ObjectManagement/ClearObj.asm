* ---------------------------------------------------------------------------
* ClearObj
* --------
* Subroutine to clear an object data in OST
* !!! DOES NOT CLEAR ext_variables !!!
* If you want to clean ext_variables, crete a copy of this file and customize it
* you will have to keep the same routine name (called by other Engine routines)
* Best practice is to init ext_vars in object code
* Look at the Sonic2 demo for an example of cutomization (ClearObj107)
*
* input REG : [u] pointer on objet (OST)
* clear REG : [d,y]
* ---------------------------------------------------------------------------

        IFNE object_core_size-93
        WARNING "ClearObj routine must be upgraded to clean object_core_size bytes (actually 93 bytes)"
        ENDC

ClearObj 
        pshs  d,x,y,u
        sts   CLO_1+2
        leas  object_core_size,u        
        ldd   #$0000
        ldx   #$0000
        leay  ,x
        leau  ,x
        pshs  d,x,y,u
        pshs  d,x,y,u
        pshs  d,x,y,u
        pshs  d,x,y,u
        pshs  d,x,y,u
        pshs  d,x,y,u
        pshs  d,x,y,u
        pshs  d,x,y,u
        pshs  d,x,y,u
        pshs  a,x
        leau  ,s
CLO_1        
        lds   #$0000        ; start of object should not be written with S as an index because of IRQ        
        pshu  d,x,y         ; saving 12 bytes + (2 bytes * _sr calls) inside IRQ routine
        pshu  d,x,y         ; DEPENDENCY on nb of _sr calls inside IRQ routine  (here 18 bytes of margin)
        pshu  d,x,y         ; DEPENDENCY on object_size definition
CLO_2        
        puls  d,x,y,u,pc