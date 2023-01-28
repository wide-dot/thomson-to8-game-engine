        INCLUDE "./engine/macros.asm" 

Obj01
        lda   render_flags,u
        anda  #render_subobjects_mask
        bne   >

        lda   routine,u
        asla
        ldx   #Obj01_Index
        jmp   [a,x]

Obj01_Index
        fdb   Obj01_Init
        fdb   Obj01_Main_p1
        fdb   Obj01_Main_p2

Obj01_Init
        ldd   #Img_Box24x20
        std   image_set,u
        lda   #2
        sta   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u
        lda   subtype,u
        bne   >
        lda   #1
        sta   AABB_a.p
        _ldd  24/2,20/2
        std   AABB_a.rx
        lda   #1
        sta   routine,u
        rts
!       
        lda   #1
        sta   AABB_b.p
        _ldd  24/2,20/2
        std   AABB_b.rx
        lda   #2
        sta   routine,u
        rts

Obj01_Main_p1
        lda   Dpad_Held
        ldb   Fire_Press
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
        bitb  #c1_button_A_mask
        beq   >
!       
        ldd   #Img_Box24x20
        tst   AABB_a.p
        bne   >
        inc   AABB_a.p
        ldd   #Img_Box24x20s
!       std   image_set,u
        ldd   xy_pixel,u
        std   AABB_a.cx
        jmp   DisplaySprite

Obj01_Main_p2
        lda   Dpad_Held
        ldb   Fire_Press
@TestLeft
        bita  #c2_button_left_mask
        beq   @TestRight   
        ldx   x_pos,u
        leax  -1,x
        stx   x_pos,u
        bra   @TestUp
@TestRight        
        bita  #c2_button_right_mask
        beq   @TestUp   
        ldx   x_pos,u
        leax  1,x
        stx   x_pos,u
@TestUp
        bita  #c2_button_up_mask
        beq   @TestDown   
        ldx   y_pos,u
        leax  -1,x
        stx   y_pos,u
        bra   @TestBtn
@TestDown
        bita  #c2_button_down_mask
        beq   @TestBtn   
        ldx   y_pos,u
        leax  1,x
        stx   y_pos,u
@TestBtn
        bitb  #c2_button_A_mask
        beq   >
!       
        ldd   #Img_Box24x20
        tst   AABB_b.p
        bne   >
        inc   AABB_b.p
        ldd   #Img_Box24x20s
!       std   image_set,u
        ldd   xy_pixel,u
        std   AABB_b.cx
        jmp   DisplaySprite
