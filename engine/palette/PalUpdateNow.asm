* ---------------------------------------------------------------------------
* PalUpdateNow
* ----------------
* Subroutine to update palette right now
*
* input REG : none
* reset REG : [d] [x] [y]
* ---------------------------------------------------------------------------

PalRefresh      fcb   $FF
Pal_current     fdb   Pal_buffer
Pal_buffer      fill  0,$20          

        setdp $E7
PalUpdateNow 
        tst   PalRefresh
        bne   @rts
        pshs  dp
        ldd   #$E7
        tfr   b,dp  
        ldx   Pal_current
        sta   <$DB                     * color index 0
!       ldd   ,x                       * load color
        sta   <$DA                     * set green and red
        stb   <$DA                     * set blue
        ldd   2,x
        sta   <$DA
        stb   <$DA
        ldd   4,x
        sta   <$DA
        stb   <$DA
        ldd   6,x
        sta   <$DA
        stb   <$DA
        ldd   8,x
        sta   <$DA
        stb   <$DA
        ldd   10,x
        sta   <$DA
        stb   <$DA
        ldd   12,x
        sta   <$DA
        stb   <$DA
        ldd   14,x
        sta   <$DA
        stb   <$DA
        ldd   16,x
        sta   <$DA
        stb   <$DA
        ldd   18,x
        sta   <$DA
        stb   <$DA
        ldd   20,x
        sta   <$DA
        stb   <$DA
        ldd   22,x
        sta   <$DA
        stb   <$DA
        ldd   24,x
        sta   <$DA
        stb   <$DA
        ldd   26,x
        sta   <$DA
        stb   <$DA
        ldd   28,x
        sta   <$DA
        stb   <$DA
        ldd   30,x
        sta   <$DA
        stb   <$DA
        com   PalRefresh               * update flag, next run this routine will be ignored if no pal update is requested
        puls dp,pc
@rts    rts

        setdp dp/256