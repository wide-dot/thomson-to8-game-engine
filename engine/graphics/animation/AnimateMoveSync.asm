* ---------------------------------------------------------------------------
* AnimateMoveSync
* ---------------
* Read x,y velocity and animation frame from sub-scripts
*
* ---------------------------------------------------------------------------

AnimateMoveSyncInit
        stx   anim,u
        ldd   ,x
        std   sub_anim,u
        rts

AnimateMoveSync
        ldy   sub_anim,u
        beq   @rts
;
        ldd   #0
        std   x_vel,u
        std   y_vel,u
;
        ldb   Vint_Main_runcount
        stb   glb_d0_b
        beq   >                        ; do a loop when 0
@loop   dec   glb_d0_b
!       bmi   @end
;
        ldb   ,y+                      ; read frame bitfield
@frame
        lslb
        bcc   @xvel
        lda   ,y+
        sta   anim_frame,u
@xvel        
        lslb
        bcc   @yvel
        stb   @b0
        ldd   ,y++
        addd  x_vel,u
        std   x_vel,u
        ldb   #0
@b0     equ   *-1
@yvel
        lslb
        bcc   @anim
        stb   @b1
        ldd   ,y++
        addd  y_vel,u
        std   y_vel,u
        ldb   #0
@b1     equ   *-1
@anim
        lslb
        bcc   @loop
        ldx   anim,u
        leax  2,x
        stx   anim,u
        ldy   ,x
        bne   @loop
@end    sty   sub_anim,u
@rts    rts