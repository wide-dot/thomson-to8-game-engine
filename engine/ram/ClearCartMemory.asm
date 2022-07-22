********************************************************************************
* Clear memory in cardtridge area
********************************************************************************

ClearCartMem 
        pshs  u,dp
        sts   ClearCartMem_3+2
        lds   #$4000
        leau  ,x
        leay  ,x
        tfr   x,d
        tfr   a,dp
ClearCartMem_2
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp
        cmps  #$0010                        
        bne   ClearCartMem_2
        leau  ,s        
ClearCartMem_3        
        lds   #$0000        ; start of memory should not be written with S as an index because of IRQ        
        pshu  d,x,y         ; saving 12 bytes + (2 bytes * _sr calls) inside IRQ routine
        pshu  d,x,y         ; DEPENDENCY on nb of _sr calls inside IRQ routine (here 16 bytes of margin)
        pshu  d,x
        puls  dp,u,pc
