; ---------------------------------------------------------------------------
; Object - Player
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Player
        lda   routine,u
        asla
        ldx   #Player_Routines
        jmp   [a,x]

Player_Routines
        fdb   Init
        fdb   Live

Init
******** set object to use camera coord
            ldd   #Ani_Player1
            std   anim,u
*            ldd   #$807F
*            std   xy_pixel,u

        lda   #render_playfieldcoord_mask
        sta   render_flags,u

            ldd   #80
            std   x_pos,u
            ldd   #100
            std   y_pos,u

            ldd   #0  *-$400
            std   y_vel,u
            ldd   y_pos,u


        ldb   #2
        stb   priority,u
        inc   routine,u
        rts

Live
*    ldd   #-$400
*    std   y_vel,u
*    ldd   y_pos,u

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
        bra   Anim
TestDown
        bita  #c1_button_down_mask
        beq   Anim
            ldx   glb_camera_y_pos
            leax  -1,x
            stx   glb_camera_y_pos
Anim
        jsr   AnimateSprite
        jsr   ObjectMove
        jmp   DisplaySprite
