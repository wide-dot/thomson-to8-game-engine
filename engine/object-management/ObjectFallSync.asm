; ---------------------------------------------------------------------------
; Subroutine to apply gravity to object speed in sync with Frame rate
; ---------------------------------------------------------------------------

ObjectFallSync
        ldd   x_vel,u
        ldx   Vint_Main_runcount_w     ; take number of elapsed frame since last render and multiply by gravity
        bne   @loop
        ldx   #1
@loop   
        addd  x_acl,u
        leax  -1,x
        bne   @loop   
        std   x_vel,u

        ldd   y_vel,u
        ldx   Vint_Main_runcount_w     ; take number of elapsed frame since last render and multiply by gravity
        bne   @loop
        ldx   #1
@loop   
        addd  y_acl,u
        leax  -1,x
        bne   @loop
        std   y_vel,u
        rts