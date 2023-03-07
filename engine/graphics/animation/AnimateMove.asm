* ---------------------------------------------------------------------------
* AnimateMove
* -----------
* Read x,y velocity and animation frame from sub-scripts
*
* ---------------------------------------------------------------------------

AnimateMoveInit
        stx   anim,u
        ldd   ,x
        std   sub_anim,u
        rts

AnimateMove
        ldy   sub_anim,u
        beq   @rts
        ldd   #0
        std   x_vel,u
        std   y_vel,u
        ldb   ,y+                      ; read frame bitfield
@frame
        lslb
        bcc   @xvel
        lda   ,y+
        sta   anim_frame,u
@xvel        
        lslb
        bcc   @yvel
        ldx   ,y++
        stx   x_vel,u
@yvel
        lslb
        bcc   @anim
        ldx   ,y++
        stx   y_vel,u
@anim
        lslb
        bcc   @end
        ldx   anim,u
        leax  2,x
        stx   anim,u
        ldd   ,x
        std   sub_anim,u
        rts
@end    sty   sub_anim,u
@rts    rts