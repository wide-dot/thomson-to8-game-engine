********************************************************************************
* Clear memory in data area
* !!! IRQ should be disabled !!!
*
* input  REG : [x] color for 4 pixels
********************************************************************************

ClearInterlacedEvenDataMemory
        ldb   #$18
        stb   CIDM_a_start+3
        stb   CIDM_b_start+3
        ldb   #0
        stb   CIDM_a_end+3
        stb   CIDM_b_end+3        
        bra   ClearInterlacedDataMemory

ClearInterlacedOddDataMemory
        ldb   #$40
        stb   CIDM_a_start+3
        stb   CIDM_b_start+3        
        ldb   #$28
        stb   CIDM_a_end+3
        stb   CIDM_b_end+3        
        
ClearInterlacedDataMemory 
        pshs  u,dp
        sts   CIDM_end+2
        
CIDM_a_start
        lds   #$DF40                   ; (dynamic)
        leau  ,x
        leay  ,x
        tfr   x,d
        tfr   a,dp
CIDM_a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a        
        pshs  u,y
CIDM_a_end         
        cmps  #$C000
        leas  -40,s                                
        bne   CIDM_a  
      
CIDM_b_start
        lds   #$BF40                   ; (dynamic)
CIDM_b
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a        
        pshs  u,y
CIDM_b_end         
        cmps  #$A000
        leas  -40,s                                
        bne   CIDM_b          
             
CIDM_end        
        lds   #$0000        
        puls  dp,u,pc
