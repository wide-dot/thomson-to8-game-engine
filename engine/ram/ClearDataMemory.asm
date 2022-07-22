********************************************************************************
* Clear memory in data area (16Ko)
* [X] : word that will be copied in the whole page
********************************************************************************

ClearDataMem 
        pshs  u,dp
        sts   ClearDataMem_3+2
        lds   #$E000
        leau  ,x
        leay  ,x
        tfr   x,d
        tfr   a,dp
ClearDataMem_2
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
        cmps  #$A010                        
        bne   ClearDataMem_2
        leau  ,s        
ClearDataMem_3        
        lds   #$0000        ; start of memory should not be written with S as an index because of IRQ        
        pshu  d,x,y         ; saving 12 bytes + (2 bytes * _sr calls) inside IRQ routine
        pshu  d,x,y         ; DEPENDENCY on nb of _sr calls inside IRQ routine (here 16 bytes of margin)
        pshu  d,x
        puls  dp,u,pc
