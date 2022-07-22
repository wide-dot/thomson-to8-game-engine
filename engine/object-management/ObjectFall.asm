; ---------------------------------------------------------------------------
; Subroutine to apply gravity to object speed in sync with Frame rate
; ---------------------------------------------------------------------------

ObjectFall
        ldd   x_vel,u
        addd  x_acl,u
        std   x_vel,u
        ldd   y_vel,u
        addd  y_acl,u
        std   y_vel,u
        rts