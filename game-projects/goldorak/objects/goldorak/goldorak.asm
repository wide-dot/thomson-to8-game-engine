
           INCLUDE "./global/global-object-preambule-includes.asm"

ply_acceleration equ $A0
ply_deceleration equ $80
ply_max_velocityP equ $300
ply_max_velocityN equ -$300
ply_width        equ 16
ply_height       equ 32
start
        _object.routines.init #routines
routines
        fdb   Init
        fdb   Live
Init
        _image.set.u #Img_Goldorak_Normal,#XY_CENTERED_FULL_IMAGE,#3,#render_playfieldcoord_mask
        ldd   #80
        std   x_pos,u
        ldd   #100
        std   y_pos,u
        inc   routine,u
Live    
        ; testing ANY  ---------------------------------
        lda   Dpad_Held
        beq   @testFire ; aucun mouvement du joystick ... on skip tout
        ; testing LEFT ---------------------------------
        lda   Dpad_Held
        anda  #c1_button_left_mask
        beq   @testRight
        ldd   x_vel,u
        subd  #ply_acceleration
            cmpd #ply_max_velocityN                  ;max vel
            ble >
        std   x_vel,u
!       _image.update.u #Img_Goldorak_Left
        bra   @testUp ; on ne test pas le droit on va directement à up
@testRight ; testing RIGHT -----------------------------
        lda   Dpad_Held
        anda  #c1_button_right_mask
        beq   @testUp
        ldd   x_vel,u
        addd  #ply_acceleration
            cmpd #ply_max_velocityP                  ;max vel
            bge >
        std   x_vel,u
!       _image.update.u #Img_Goldorak_Right
@testUp ; testing UP -----------------------------------
        lda   Dpad_Held
        anda  #c1_button_up_mask
        beq   @testDown
        ldd   y_vel,u
        subd  #ply_acceleration*2
            cmpd #ply_max_velocityN*2                  ;max vel
            ble >
        std   y_vel,u
!       bra   @testFire
@testDown ; testing DOWN -----------------------------------
        lda   Dpad_Held
        anda  #c1_button_down_mask
        beq   @testFire
        ldd   y_vel,u
        addd  #ply_acceleration*2
            cmpd #ply_max_velocityP*2                ;max vel
            bge @testFire
        std   y_vel,u
@testFire
        ; press fire
        lda   Fire_Press
        anda  #c1_button_A_mask
        beq   >
        jsr   LoadObject_x
        beq   >                        ; branch if no more available object slot
        lda   #ObjID_Weapon10          ; fire !
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        ; decelerate player on x
!       ldd   Dpad_Held
        anda  #c1_button_left_mask|c1_button_right_mask ; check if not moving left or right
        bne   >
        _image.update.u #Img_Goldorak_Normal
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
        ldd   y_vel,u                  ; decelerate on y axis
        bmi   @neg
        subd  #ply_deceleration
        bpl   @store
        bra   @cap
@neg    addd  #ply_deceleration
        bmi   @store
@cap    ldd   #0
@store  std   y_vel,u
!       jsr   ObjectMoveSync
        jsr   CheckRange
        jmp   DisplaySprite
CheckRange
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #ply_width
        bge   >
        ldd   glb_camera_x_pos
        addd  #ply_width
        std   x_pos,u
        ldd   #0
        std   x_vel,u
        bra   @y
!       cmpd  #159-ply_width
        ble   @y
        ldd   glb_camera_x_pos
        addd  #159
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
!       cmpd  #199-ply_height
        ble   >
        ldd   glb_camera_y_pos
        addd  #199
        subd  #ply_height
        std   y_pos,u
        ldd   #0
        std   y_vel,u
!       rts
