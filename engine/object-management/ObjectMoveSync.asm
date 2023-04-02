* ---------------------------------------------------------------------------
* Subroutine translating object speed to update object position
* This moves the object horizontally and vertically
* but does not apply gravity to it
* ---------------------------------------------------------------------------

ObjectMoveSync
        ldb   x_vel,u
        sex                            ; velocity is positive or negative, take care of that
        sta   @a+1
; apply X velocity in sync with framerate
; ---------------------------------------
        ldx   gfxlock.frameDrop.count_w ; take number of elapsed frame since last render and multiply by velocity
        bne   @loop1
        ldx   #1
@loop1   
        ldd   x_pos+1,u                ; x_pos must be followed by x_sub in memory
        addd  x_vel,u
        std   x_pos+1,u                ; update low byte of x_pos and x_sub byte
        lda   x_pos,u
@a
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
        sta   x_pos,u                  ; update high byte of x_pos
        leax  -1,x
        bne   @loop1 

        ldb   y_vel,u
        sex                            ; velocity is positive or negative, take care of that
        sta   @b+1
; apply Y velocity in sync with framerate
; ---------------------------------------
        ldx   gfxlock.frameDrop.count_w ; take number of elapsed frame since last render and multiply by velocity
        bne   @loop2
        ldx   #1
@loop2   
        ldd   y_pos+1,u                ; y_pos must be followed by y_sub in memory
        addd  y_vel,u
        std   y_pos+1,u                ; update low byte of y_pos and y_sub byte
        lda   y_pos,u
@b
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
        sta   y_pos,u                  ; update high byte of y_pos
        leax  -1,x
        bne   @loop2   
@c      rts