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
        fdb   Wait
        fdb   Run
        fdb   MoveOut

Init
        ; init sprite position
        ldd   #1498
        std   x_pos,u
        ldd   #75
        std   y_pos,u

        ; display priority
        ldb   #7
        stb   priority,u

        ; display settings
        lda   #render_playfieldcoord_mask|render_xloop_mask
        sta   render_flags,u

        ; init animation
        ldd   #0
        std   anim_frame,u

        ; init image
        ldx   #Img_dobkeratops_jaw_0
        stx   image_set,u

        inc   routine,u

Wait
        ldd   anim_frame,u
        addd  gfxlock.frameDrop.count_w
        cmpd  #360                      ; manual adjustment by video
        blo   >
        inc   routine,u
        ldd   #0
!       
        std   anim_frame,u
        jmp   DisplaySprite

Run
        jmp   Animate

MoveOut
        ldd   #$-20
        std   x_vel,u
        jsr   ObjectMoveSync
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jmp   Animate
!       jmp   DeleteObject

Animate
        ldd   anim_frame,u
        addd  gfxlock.frameDrop.count_w
        cmpd  #$180                     ; up to x180 (384)
        blo   >                         ; branch if not reached
        subd  #$180                     ; or reset counter to 0
!
        std   anim_frame,u       
        ldx   #Img_dobkeratops_jaw_0    ; image : jaw wide open
        cmpd  #$c0                      ; compare to 192
        blo   >                         ; branch if inferior
        ldx   #Img_dobkeratops_jaw_1    ; image : jaw mid open
        cmpd  #$d0                      ; compare 208
        blo   >                         ; branch if inferior
        cmpd  #$170                     ; compare to 368
        bhs   >                         ; branch if superior or equal
        ldx   #Img_dobkeratops_jaw_2    ; image : jaw low open
!
        stx   image_set,u
        jmp   DisplaySprite

