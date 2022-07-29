Obj11_child1   equ ext_variables ; word
glb_d1         equ dp_engine
glb_d1_b       equ dp_engine+1
glb_d2         equ dp_engine+2
glb_d2_b       equ dp_engine+3
glb_d3         equ dp_engine+4
glb_d3_b       equ dp_engine+5
glb_d4         equ dp_engine+6
glb_d4_b       equ dp_engine+7


Obj11
        lda   render_flags,u
        anda  #render_subobjects_mask
        bne   >

        lda   routine,u
        asla
        ldx   #Obj11_Index
        jsr   [a,x]

!
        lda   #3
        jmp   DisplaySprite3


Obj11_Index
        fdb   Obj11_Init
        fdb   Obj11_Main

Obj11_Init
        inc   routine,u
        ldd   #Img_Box24x20
        std   image_set,u

        lda   #2
        sta   priority,u

        lda   #render_playfieldcoord_mask
        sta   render_flags,u

        ldd   x_pos,u
        std   glb_d3
        ldd   y_pos,u
        std   glb_d2

        ldb   #4 ; make 5 boxes
        stb   glb_d1_b
        jsr   Obj11_MakeBdgSegment
        stx   Obj11_child1,u
        rts

Obj11_MakeBdgSegment
        jsr   SingleObjLoad2
        bne   Obj11_rts

        lda   id,u
        sta   id,x             ; set child id

        lda   render_flags,u
        ora   #render_subobjects_mask
        sta   render_flags,x

        ldb   glb_d1_b 
        stb   mainspr_childsprites,x ; hold number of childs

        leay  mainspr_x_pos,x  ; first pos

!       ldd   glb_d3
        addd  #24              ; move horizontally by box width
        std   ,y++
        std   glb_d3           ; set child x_pos

        ldd   glb_d2
        std   ,y++             ; set child y_pos

        ldd   #Img_Box24x20
        std   ,y++             ; set image

        dec   glb_d1_b
        bne   <
Obj11_rts
        rts

Obj11_Main
        lda   Dpad_Held
        ldb   Fire_Press
TestLeft
        bita  #c1_button_left_mask
        beq   TestRight   
        ldx   glb_camera_x_pos
        leax  1,x
        stx   glb_camera_x_pos
        bra   TestUp
TestRight        
        bita  #c1_button_right_mask
        beq   TestUp   
        ldx   glb_camera_x_pos
        leax  -1,x
        stx   glb_camera_x_pos
TestUp
        bita  #c1_button_up_mask
        beq   TestDown   
        ldx   glb_camera_y_pos
        leax  1,x
        stx   glb_camera_y_pos
        bra   TestBtn
TestDown
        bita  #c1_button_down_mask
        beq   TestBtn   
        ldx   glb_camera_y_pos
        leax  -1,x
        stx   glb_camera_y_pos
TestBtn
        bitb  #c1_button_A_mask
        beq   >
!       jmp   DisplaySprite

