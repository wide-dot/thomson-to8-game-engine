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
        fdb   Live

Init
        ldd   #Img_foefire_0
        std   image_set,u
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        ;ldd   #$-100
        ;std   x_vel,u
        ;ldd   #$80
        ;std   y_vel,u
        inc   routine,u

Live
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        subd  #160-8/2
        cmpd  glb_camera_x_pos
        bge   >
        ldd   y_pos,u
        cmpd  #0
        ble   >
        cmpd  #160
        bge   >
        jsr   ObjectMoveSync
        jmp   DisplaySprite
        
!       jmp   DeleteObject