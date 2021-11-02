* ---------------------------------------------------------------------------
* ClearObj
* --------
* Subroutine to clear an object data in OST
*
* input REG : [u] pointer on objet (OST)
* clear REG : [d,y]
* ---------------------------------------------------------------------------

ClearObj 
        pshs  d,x,y,u
        sts   CLO_1+2
        leas  object_size,u        
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
        pshs  d,x,y,u
        pshs  d,x,y,u
	pshs  d,x,y,u
	leau  ,s
CLO_1        
        lds   #$0000        ; start of object should not be written with S as an index because of IRQ        
        pshu  d,x,y         ; saving 12 bytes + (2 bytes * _sr calls) inside IRQ routine
        pshu  d,x,y         ; DEPENDENCY on nb of _sr calls inside IRQ routine  (here 18 bytes of margin)
        pshu  d,x,y         ; DEPENDENCY on object_size definition
CLO_2        
        puls  d,x,y,u,pc