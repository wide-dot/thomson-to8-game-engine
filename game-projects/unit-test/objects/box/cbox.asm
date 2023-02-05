        INCLUDE "./engine/macros.asm" 
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0  equ ext_variables ; AABB struct (9 bytes)

Obj01
        lda   render_flags,u
        anda  #render_subobjects_mask
        bne   >

        lda   routine,u
        asla
        ldx   #Obj01_Index
        jmp   [a,x]

Obj01_Index
        fdb   Obj01_Init1
        fdb   Obj01_Init2
        fdb   Obj01_Main1
        fdb   Obj01_Main2

Obj01_Init1
        ldd   #Img_Box24x20
        std   image_set,u
        lda   #2
        sta   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u
        jmp   DisplaySprite

Obj01_Init2
        leax  AABB_0,u
        lda   subtype,u
        bne   >
        jsr   AddPlayerAABB
        inc   routine,u
        bra   @skip
!       jsr   AddAiAABB
@skip
        lda   #1
        sta   AABB.p,x
        _ldd  24/2,20/2
        std   AABB.rx,x
        inc   routine,u

Obj01_Main1
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
        ;bitb  #c1_button_A_mask
        ;beq   >
Obj01_Main2
        leax  AABB_0,u
        ldd   #Img_Box24x20
        tst   AABB.p,x
        bne   >
        inc   AABB.p,x
        ldd   #Img_Box24x20s
!       std   image_set,u
        ldd   xy_pixel,u
        std   AABB.cx,x
        jmp   DisplaySprite
   