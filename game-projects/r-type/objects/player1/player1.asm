; ---------------------------------------------------------------------------
; Object - Player
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        
beam_value       equ ext_variables
is_charging      equ ext_variables+1
ply_acceleration equ $20
ply_deceleration equ $100
ply_max_vel      equ $100
ply_max_vel_neg  equ $-100
ply_width        equ 12/2
ply_height       equ 16/2

Player
        lda   player1+routine
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldd   #Ani_Player1
        std   player1+anim
        ldb   #3
        stb   player1+priority
        ldd   #35
        addd  glb_camera_x_pos
        std   player1+x_pos
        ldd   #100
        std   player1+y_pos
        lda   player1+render_flags
        ora   #render_playfieldcoord_mask
        sta   player1+render_flags
        ldd   glb_camera_x_pos
        std   glb_camera_x_pos_old
        inc   player1+routine

Live
        ldd   glb_camera_x_pos
        subd  glb_camera_x_pos_old
        beq   >
        addd  player1+x_pos
        std   player1+x_pos
        ldd   glb_camera_x_pos
        std   glb_camera_x_pos_old
!
        lda   Dpad_Held
        anda  #c1_button_left_mask
        beq   @testRight
        ldd   player1+x_vel
        subd  #ply_acceleration
        cmpd  #ply_max_vel_neg
        ble   @testUp
        std   player1+x_vel
        bra   @testUp
@testRight
        lda   Dpad_Held
        anda  #c1_button_right_mask
        beq   @testUp
        ldd   player1+x_vel
        addd  #ply_acceleration
        cmpd  #ply_max_vel
        bge   @testUp
        std   player1+x_vel
@testUp
        lda   Dpad_Held
        anda  #c1_button_up_mask
        beq   @testDown
        ldd   player1+y_vel
        subd  #ply_acceleration*2
        cmpd  #ply_max_vel_neg*2
        ble   @testFire
        std   player1+y_vel
        ldd   #Ani_Player1_up
        std   player1+anim
        bra   @testFire
@testDown
        lda   Dpad_Held
        anda  #c1_button_down_mask
        beq   @testFire
        ldd   player1+y_vel
        addd  #ply_acceleration*2
        cmpd  #ply_max_vel*2
        bge   @testFire
        std   player1+y_vel
        ldd   #Ani_Player1_down
        std   player1+anim
@testFire
        ; press fire
        lda   Fire_Press
        anda  #c1_button_A_mask
        beq   @testHoldFire
        jsr   LoadObject_x
        beq   @testHoldFire            ; branch if no more available object slot
        lda   #ObjID_Weapon1           ; fire !
        sta   id,x
        ldd   player1+x_pos
        std   x_pos,x
        ldd   player1+y_pos
        std   y_pos,x
@testHoldFire       
        ; holding fire ?
        lda   Fire_Held
        anda  #c1_button_A_mask
        beq   @wasbuttonhdeld           ; Nop, but let's check if it was held
        ldd   player1+beam_value
        tstb
        bne   @incharging
        cmpa  #4
        blt   @incharging
                                        ; Start charging animation
        adda  Vint_Main_runcount
        sta   player1+beam_value
        sta   player1+is_charging
        jsr   LoadObject_x
        beq   @testmoving               ; branch if no more available object slot
        lda   #ObjID_beamcharge         ; Charge anim
        sta   id,x
        bra   @testmoving
@incharging
        lda   player1+beam_value
        adda  Vint_Main_runcount
        cmpa  #60                       ; Max value ?
        ble   >
        lda   #60
!
        sta   player1+beam_value
        tfr   a,b
        clra
        std   score
        bra   @testmoving
@wasbuttonhdeld
        lda   player1+beam_value
        beq   @testmoving
                                        ; button was held, let's shoot and reset
        jsr   LoadObject_x
        beq   >                         ; branch if no more available object slot
        lda   #ObjID_beamp0             ; fire !
        sta   id,x
        ldd   player1+x_pos
        std   x_pos,x
        ldd   player1+y_pos
        std   y_pos,x
!
        ldd   #0
        std   player1+beam_value
        std   score
@testmoving
        ; decelerate player on x
        ldd   Dpad_Held
        anda  #c1_button_left_mask|c1_button_right_mask ; check if not moving left or right
        bne   >
        ldd   player1+x_vel            ; decelerate on x axis
        bmi   @neg
        subd  #ply_deceleration
        bpl   @store
        bra   @cap
@neg    addd  #ply_deceleration
        bmi   @store
@cap    ldd   #0
@store  std   player1+x_vel

        ; decelerate player on y
!       ldd   Dpad_Held
        anda  #c1_button_up_mask|c1_button_down_mask ; check if not moving up or down
        bne   >
        ldd   #Ani_Player1             ; set normal image
        std   player1+anim
        ldd   player1+y_vel            ; decelerate on y axis
        bmi   @neg
        subd  #ply_deceleration
        bpl   @store
        bra   @cap
@neg    addd  #ply_deceleration
        bmi   @store
@cap    ldd   #0
@store  std   player1+y_vel

        ; move and animate
!       jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jsr   CheckRange
        jmp   DisplaySprite

CheckRange
        ldd   player1+x_pos
        subd  glb_camera_x_pos
        cmpd  #10+ply_width
        bge   >
        ldd   glb_camera_x_pos
        addd  #10+ply_width
        std   player1+x_pos
        ldd   #0
        std   player1+x_vel
        bra   @y
!       cmpd  #10+140-ply_width
        ble   @y
        ldd   glb_camera_x_pos
        addd  #10+140
        subd  #ply_width
        std   player1+x_pos
        ldd   #0
        std   player1+x_vel
@y      ldd   player1+y_pos
        subd  glb_camera_y_pos
        cmpd  #ply_height
        bge   >
        ldd   glb_camera_y_pos
        addd  #ply_height
        std   player1+y_pos
        ldd   #0
        std   player1+y_vel
        rts
!       cmpd  #168-ply_height
        ble   >
        ldd   glb_camera_y_pos
        addd  #168
        subd  #ply_height
        std   player1+y_pos
        ldd   #0
        std   player1+y_vel
!       rts

glb_camera_x_pos_old fdb 0