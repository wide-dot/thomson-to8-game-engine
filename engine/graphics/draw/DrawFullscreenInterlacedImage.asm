********************************************************************************  
* Draw an interlaced image to data area
* If IRQ is anabled while using this routine, you may expect 12 bytes to be
* written ahead of S stack
*
*
* input  REG : [x] image data address
********************************************************************************

DrawFullscreenInterlacedEvenImage
        ldb   #$18
        stb   DFII_a_start+3
        stb   DFII_b_start+3
        ldb   #0
        stb   DFII_a_end+3
        stb   DFII_b_end+3        
        bra   DrawFullscreenInterlacedImage
    
DrawFullscreenInterlacedOddImage
        ldb   #$40
        stb   DFII_a_start+3
        stb   DFII_b_start+3        
        ldb   #$28
        stb   DFII_a_end+3
        stb   DFII_b_end+3
    
DrawFullscreenInterlacedImage
        pshs  u,y,dp,a
        sts   DFII_a_rts+2

        _GetCartPageA
        sta   DFII_rts+1                ; backup cart page     

        lda   ,x
        _SetCartPageA
        
        ldu   1,x        
        
DFII_a_start         
        lds   #$DF40                   ; (dynamic)
DFII_a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  dp,x,y
        pshs  y,x,dp
        
DFII_a_end        
        cmps  #$C000                   ; (dynamic)
        leas  -40,s
        leau  40,u        
        bne   DFII_a

DFII_b_start        
        lds   #$BF40                   ; (dynamic)
DFII_b
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  dp,x,y
        pshs  y,x,dp
        
DFII_b_end        
        cmps  #$A000                   ; (dynamic)
        leas  -40,s
        leau  40,u           
        bne   DFII_b
DFII_a_rts
        lds   #$0000                   ; (dynamic)
        
DFII_rts
        lda   #$00
        _SetCartPageA
        puls  a,dp,y,u,pc