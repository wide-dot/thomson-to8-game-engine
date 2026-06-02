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
        fdb   init
        fdb   live
        fdb   alreadyDeleted

init
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #Img_ball
        std   image_set,u
        inc   routine,u

live
        lda   gfxlock.frameDrop.count
        sta   glb_d0_b
        ldd   #0
!       addd  x_vel,u
        dec   glb_d0_b
        bne   < 
        jsr   moveXPos8.8

        lda   gfxlock.frameDrop.count
        sta   glb_d0_b
        ldd   #0
!       addd  y_vel,u
        dec   glb_d0_b
        bne   <
        jsr   moveYPos8.8

        jsr   DisplaySprite

        ; check if bullet is outside the viewport
        ; x axis
        ldd   x_pos,u
        bmi   destroy
        cmpd  #160
        bge   destroy
        ; y axis
        ldd   y_pos,u
        bmi   destroy
        cmpd  #200
        bge   destroy
        rts

destroy
        inc   routine,u
        jmp   DeleteObject

alreadyDeleted
        rts
