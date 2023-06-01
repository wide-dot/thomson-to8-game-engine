; -----------------------------------------------------------------------------
; createFoeFire
; --------------
;
; -----------------------------------------------------------------------------

createFoeFire
        jsr   LoadObject_x
        beq   LAB_0000_fa93
        lda   #ObjID_foefire
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        stx   @x
        ldx   #player1
        jsr   setDirectionTo           ; return value is y += (0-63) (16 direction presets)
        ldx   #0
@x      equ   *-2
        lda   #64
        ldb   fireVelocityPreset,u
        decb                           ; 0 is no preset, so 1-7 becomes 0-6
        mul
        addd  #createFoeFire.data
        leay  d,y
        ldd   ,y                       ; load computed direction
        std   x_vel,x
        ldd   2,y
        std   y_vel,x
        lda   #3
        sta   fireDisplayDelay,x
LAB_0000_fa93
        rts

createFoeFire.data
        INCLUDE "./global/preset/18f90_preset-fireVelocity.asm"