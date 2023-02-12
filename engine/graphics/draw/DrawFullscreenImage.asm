********************************************************************************  
* Draw an image to data area
* If IRQ is anabled while using this routine, you may expect 12 bytes to be
* written ahead of S stack
*
* input  REG : [x] image data address  
********************************************************************************    
DrawFullscreenImage
        pshs  u,y,dp,b,a
        sts   DFI_a_rts+2

        _GetCartPageA
        sta   DFI_rts+1                ; backup cart page     

        lda   ,x
        _SetCartPageA
        
        ldu   1,x        
        
        lds   #$DF40
DFI_a
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
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        cmps  #$C014
        bne   DFI_a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  b,dp,x,y
        pshs  y,x,dp,b
        
        lds   #$BF40
DFI_b
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
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        cmps  #$A014
        bne   DFI_b
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  a,b,dp,x,y
        pshs  y,x,dp,b,a
        pulu  b,dp,x,y
        pshs  y,x,dp,b
DFI_a_rts
        lds   #$0000
DFI_rts
        lda   #$00
        _SetCartPageA
        puls  a,b,dp,y,u,pc