; ---------------------------------------------------------------------------
; Object - Player
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

ply_acceleration equ $A0
ply_deceleration equ $80
ply_max_vel      equ $200
ply_max_vel_neg  equ $-200
ply_width        equ 12/2
ply_height       equ 16/2

Player
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldd   #Ani_Player1
        std   anim,u
        ldb   #3
        stb   priority,u
        ldd   #80
        std   x_pos,u
        ldd   #100
        std   y_pos,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        ldd   glb_camera_x_pos
        subd  glb_camera_x_pos_old
        beq   >
        addd  x_pos,u
        std   x_pos,u
        ldd   glb_camera_x_pos
        std   glb_camera_x_pos_old
!
        lda   Dpad_Held
        anda  #c1_button_left_mask
        beq   @testRight
        ldd   x_vel,u
        subd  #ply_acceleration
        cmpd  #ply_max_vel_neg
        ble   @testUp
        std   x_vel,u
        bra   @testUp
@testRight
        lda   Dpad_Held
        anda  #c1_button_right_mask
        beq   @testUp
        ldd   x_vel,u
        addd  #ply_acceleration
        cmpd  #ply_max_vel
        bge   @testUp
        std   x_vel,u
@testUp
        lda   Dpad_Held
        anda  #c1_button_up_mask
        beq   @testDown
        ldd   y_vel,u
        subd  #ply_acceleration*2
        cmpd  #ply_max_vel_neg*2
        ble   @testFire
        std   y_vel,u
        ldd   #Ani_Player1_up
        std   anim,u
        bra   @testFire
@testDown
        lda   Dpad_Held
        anda  #c1_button_down_mask
        beq   @testFire
        ldd   y_vel,u
        addd  #ply_acceleration*2
        cmpd  #ply_max_vel*2
        bge   @testFire
        std   y_vel,u
        ldd   #Ani_Player1_down
        std   anim,u
@testFire
        ; press fire
        lda   Fire_Press
        anda  #c1_button_A_mask
        beq   >
        jsr   LoadObject_x
        beq   >                        ; branch if no more available object slot
        lda   #ObjID_Weapon1           ; fire !
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x

        ; decelerate player on x
!       ldd   Dpad_Held
        anda  #c1_button_left_mask|c1_button_right_mask ; check if not moving left or right
        bne   >
        ldd   x_vel,u                  ; decelerate on x axis
        bmi   @neg
        subd  #ply_deceleration
        bpl   @store
        bra   @cap
@neg    addd  #ply_deceleration
        bmi   @store
@cap    ldd   #0
@store  std   x_vel,u

        ; decelerate player on y
!       ldd   Dpad_Held
        anda  #c1_button_up_mask|c1_button_down_mask ; check if not moving up or down
        bne   >
        ldd   #Ani_Player1             ; set normal image
        std   anim,u
        ldd   y_vel,u                  ; decelerate on y axis
        bmi   @neg
        subd  #ply_deceleration
        bpl   @store
        bra   @cap
@neg    addd  #ply_deceleration
        bmi   @store
@cap    ldd   #0
@store  std   y_vel,u

        ; move and animate
!       jsr   AnimateSprite
        jsr   ObjectMove
        jsr   CheckRange
        jmp   DisplaySprite

CheckRange
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #10+ply_width
        bge   >
        ldd   glb_camera_x_pos
        addd  #10+ply_width
        std   x_pos,u
        ldd   #0
        std   x_vel,u
        bra   @y
!       cmpd  #10+140-ply_width
        ble   @y
        ldd   glb_camera_x_pos
        addd  #10+140
        subd  #ply_width
        std   x_pos,u
        ldd   #0
        std   x_vel,u
@y      ldd   y_pos,u
        subd  glb_camera_y_pos
        cmpd  #ply_height
        bge   >
        ldd   glb_camera_y_pos
        addd  #ply_height
        std   y_pos,u
        ldd   #0
        std   y_vel,u
        rts
!       cmpd  #168-ply_height
        ble   >
        ldd   glb_camera_y_pos
        addd  #168
        subd  #ply_height
        std   y_pos,u
        ldd   #0
        std   y_vel,u
!       rts

glb_camera_x_pos_old fdb 0