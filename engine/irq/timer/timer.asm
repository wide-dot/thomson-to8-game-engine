; clock timer

        lda   glb_timer_frame
        inca
        cmpa  #50
        bne   @skip
        ldd   glb_timer
        incb
        cmpb  #60
        bne   >
        ldb   #0
        inca
!       std   glb_timer
        lda   #0
@skip   sta   glb_timer_frame