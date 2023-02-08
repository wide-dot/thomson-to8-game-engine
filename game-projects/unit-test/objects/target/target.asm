        INCLUDE "./engine/macros.asm" 

Obj01
        lda   routine,u
        asla
        ldx   #Obj01_Index
        jmp   [a,x]

Obj01_Index
        fdb   Obj01_Init
        fdb   Obj01_Main

Obj01_Init
        ldd   #Img_target
        std   image_set,u
        lda   #2
        sta   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u
        jmp   DisplaySprite

Obj01_Main
        lda   Dpad_Held
@TestLeft
        bita  #c1_button_left_mask
        beq   @TestRight   
        ldx   x_pos,u
        leax  -1,x
        stx   x_pos,u
        bra   @TestUp
@TestRight        
        bita  #c1_button_right_mask
        beq   @TestUp   
        ldx   x_pos,u
        leax  1,x
        stx   x_pos,u
@TestUp
        bita  #c1_button_up_mask
        beq   @TestDown   
        ldx   y_pos,u
        leax  -1,x
        stx   y_pos,u
        bra   @TestBtn
@TestDown
        bita  #c1_button_down_mask
        beq   @TestBtn   
        ldx   y_pos,u
        leax  1,x
        stx   y_pos,u
@TestBtn

        ; display angle
        ldd   #$80-12
        subd  x_pos,u
        _asld ; mul delta x by 2
        tfr   d,x
        ldd   #$7F-20
        subd  y_pos,u
        jsr   CalcAngle
        lda   #0
        std   glb_angle

        ldb   Fire_Press
        bitb  #c1_button_A_mask
        beq   >
        jsr   LoadObject_x
        beq   >
        lda   #ObjID_Ball
        sta   id,x
        stx   @x
        ldb   glb_angle+1
        jsr   CalcSine
        stx   @d
        ldx   #0 ; get back obj ptr
@x      equ   *-2
        _asld ; mul y_vel by 2
        std   y_vel,x
        ldd   #0
@d      equ   *-2
        ;_asrd ; wide-dot factor
        std   x_vel,x
!       jmp   DisplaySprite
   