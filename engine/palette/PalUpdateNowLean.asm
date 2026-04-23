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
        leay  32,x
        sty   @end
        sta   <$DB                     * color index 0
!       ldd   ,x++                     * load color
        sta   <$DA                     * set green and red
        stb   <$DA                     * set blue
        cmpx  #0
@end    equ   *-2
        bne   <
        com   PalRefresh               * update flag, next run this routine will be ignored if no pal update is requested
        puls  dp,pc
@rts    rts

        setdp dp/256