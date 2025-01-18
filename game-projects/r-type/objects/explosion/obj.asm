; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldb   subtype,u
        ldx   #exp.animations
        ldx   b,x
        stx   anim,u
        ldb   ,x
        stb   anim_frame_duration,u
        ldd   1,x
        std   image_set,u

        ldb   #1
        stb   priority,u

        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        bgt   >
        jmp   DeleteObject            ; object is out of range
!
        ldx   anim,u
        ldb   anim_frame_duration,u
        subb  gfxlock.frameDrop.count
        stb   anim_frame_duration,u
        bpl   @continue
@loop   leax  3,x                     ; move to next anim
        ldb   ,x
        bne   >
        jmp   DeleteObject            ; script is over
!
        addb  anim_frame_duration,u
        stb   anim_frame_duration,u
        bmi   @loop
        stx   anim,u
        ldd   1,x
        std   image_set,u
@continue
        jmp   DisplaySprite

# Animations
; smallx3 : (2) 4h, 85F4h, 4h, 85EEh, 4h, 85F4h, 4h, 85EEh, 4h, 85F4h, 4h, 85EEh, 2h, 85E8h, 2h, 85E2h, 2h, 85DCh, 2h, 85D6h, 0h
; smallx2 : (2) 2h, 85F4h, 3h, 85EEh, 2h, 85F4h, 3h, 85EEh, 4h, 85E8h, 4h, 85E2h, 5h, 85DCh, 8h, 85D6h, 0h
; fwk     : (2) 1h, 85B2h, 1h, 85B8h, 2h, 85B2h, 2h, 85B8h, 3h, 85BEh, 4h, 85C4h, 4h, 85CAh, 6h, 85D0h, 0h
; unknown : (2) 2h, 858Eh, 3h, 8594h, 3h, 859Ah, 4h, 85A0h, 6h, 85A6h, 8h, 85ACh, 0h
; big     : (1) 2h, 8654h, 4h, 8660h, 4h, 8654h, 4h, 8660h, 4h, 866Ch, 4h, 8678h, 4h, 8684h, 4h, 8690h, 4h, 869Ch, 4h, 86A8h, 4h, 8684h, 4h, 8690h, 4h, 869Ch, 4h, 86A8h, 0h
; delay for first frame is overwritten in code, so the real values are indicated in parenthesis

exp.animations
        fdb   exp.animation.smallx3
        fdb   exp.animation.smallx2
        fdb   exp.animation.fwk
        fdb   exp.animation.fwk ; reserved for unknown, to be implemented
        fdb   exp.animation.big

exp.animation.smallx3
        fcb   2
        fdb   Img_expSmall_0
        fcb   4
        fdb   Img_expSmall_1
        fcb   4
        fdb   Img_expSmall_0
        fcb   4
        fdb   Img_expSmall_1
        fcb   4
        fdb   Img_expSmall_0
        fcb   4
        fdb   Img_expSmall_1
        fcb   4
        fdb   Img_expSmall_2
        fcb   2
        fdb   Img_expSmall_3
        fcb   2
        fdb   Img_expSmall_4
        fcb   2
        fdb   Img_expSmall_5
        fcb   0

exp.animation.smallx2
        fcb   2
        fdb   Img_expSmall_0
        fcb   3
        fdb   Img_expSmall_1
        fcb   2
        fdb   Img_expSmall_0
        fcb   3
        fdb   Img_expSmall_1
        fcb   4
        fdb   Img_expSmall_2
        fcb   4
        fdb   Img_expSmall_3
        fcb   5
        fdb   Img_expSmall_4
        fcb   8
        fdb   Img_expSmall_5
        fcb   0

exp.animation.fwk
        fcb   2
        fdb   Img_expFwk_0
        fcb   1
        fdb   Img_expFwk_1
        fcb   2
        fdb   Img_expFwk_0
        fcb   2
        fdb   Img_expFwk_1
        fcb   3
        fdb   Img_expFwk_2
        fcb   4
        fdb   Img_expFwk_3
        fcb   4
        fdb   Img_expFwk_4
        fcb   6
        fdb   Img_expFwk_5
        fcb   0

exp.animation.big
        fcb   1
        fdb   Img_expBig_0
        fcb   4
        fdb   Img_expBig_1
        fcb   4
        fdb   Img_expBig_0
        fcb   4
        fdb   Img_expBig_1
        fcb   4
        fdb   Img_expBig_2
        fcb   4
        fdb   Img_expBig_3
        fcb   4
        fdb   Img_expBig_4
        fcb   4
        fdb   Img_expBig_5
        fcb   4
        fdb   Img_expBig_6
        fcb   4
        fdb   Img_expBig_7
        fcb   4
        fdb   Img_expBig_4
        fcb   4
        fdb   Img_expBig_5
        fcb   4
        fdb   Img_expBig_6
        fcb   4
        fdb   Img_expBig_7
        fcb   0