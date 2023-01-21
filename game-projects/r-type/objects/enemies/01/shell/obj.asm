; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

angle      equ  ext_variables ; 8.8
angle_step equ 18

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   CreateChilds
        fdb   Init
        fdb   Live

CreateChilds
        ; create n childs
!       jsr   LoadObject_x
        beq   >                        ; branch if no more available object slot
        lda   #ObjID_shell
        sta   id,x
        _ldd  -18*4,0 ; start pos
cur_angle equ *-2
        std   angle,x
        adda  #angle_step
        sta   cur_angle
        lda   #1
        sta   routine,x
        dec   childs
        bne   <
!       jmp   DeleteObject
        rts

Init
        ldd   #Img_shell_0
        std   image_set,u
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        lda   Vint_Main_runcount
        ldb   #$60
        mul
        addd  angle,u
        std   angle,u

        ldx   #Images
        adda  #-angle_step/2
        lsra
        lsra
        lsra
        ldb   render_flags,u
        bita  #%00010000
        bne   >
        orb   #render_xmirror_mask|render_ymirror_mask
        bra   @else
!       andb  #^(render_xmirror_mask|render_ymirror_mask)
@else   stb   render_flags,u
        anda  #%00011110
        ldx   a,x
        stx   image_set,u

        ldb   angle,u
        jsr   CalcSine
        stx   @x
        ldx   #40           ; circle radius
        jsr   Mul9x16
        addd  #916          ; x center of circle
        std   x_pos,u
        addd  #40*2+14/2
        cmpd  glb_camera_x_pos
        ble   >
        ldd   #0
@x      equ *-2
        ldx   #56           ; circle radius
        jsr   Mul9x16
        addd  #82           ; y center of circle
        std   y_pos,u

        jmp   DisplaySprite
!       jmp   DeleteObject

childs fcb 12

Images
        fdb   Img_shell_7
        fdb   Img_shell_6
        fdb   Img_shell_5
        fdb   Img_shell_4
        fdb   Img_shell_3
        fdb   Img_shell_2
        fdb   Img_shell_1
        fdb   Img_shell_0
        fdb   Img_shell_7
        fdb   Img_shell_6
        fdb   Img_shell_5
        fdb   Img_shell_4
        fdb   Img_shell_3
        fdb   Img_shell_2
        fdb   Img_shell_1
        fdb   Img_shell_0