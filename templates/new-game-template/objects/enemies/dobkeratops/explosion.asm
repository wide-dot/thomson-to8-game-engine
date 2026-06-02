; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Run

Init
        ; init animation
        ldd   #data_1454E
        std   anim,u
        inc   routine,u

Run
        lda   gfxlock.frameDrop.count
        sta   anim_frame_duration,u
        ldy   anim,u
@loop
        jsr   LoadObject_x
        beq   @skip
;
        lda   #ObjID_explosion
        sta   id,x
;
        ldb   ,y
        sex
        addd  x_pos,u
        std   x_pos,x
;
        ldb   1,y
        sex
        addd  y_pos,u
        std   y_pos,x
;
        ldb   2,y
        stb   subtype,x
@skip
        leay  3,y
        ldb   ,y
        cmpb  #$80
        bne   >
        jmp   DeleteObject
!
        dec   anim_frame_duration,u
        bne   @loop
        sty   anim,u
        rts

        INCLUDE "./global/preset/1454E_preset_dobkeratops-explosions.asm"