ObjectDp_Clear
        ldx   #dp
        lda   #0
!       sta   ,x+
        cmpx  #dp_extreg
        bne   <
        rts