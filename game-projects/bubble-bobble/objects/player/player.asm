; ---------------------------------------------------------------------------
; Object - Player
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm" 
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

Init_routine       equ 0
Ground_routine     equ 1
Jump_routine       equ 2
Fall_routine       equ 3
FallSlowly_routine equ 4
Fly_routine        equ 5
Fly_End_routine    equ 6
Fly_Exit_routine   equ 7

AABB_0           equ ext_variables     ; AABB struct (9 bytes)

h_top_speed      equ $A0
h_fallslow_speed equ $40
v_top_speed      equ $400
v_fallslow_acl   equ $180
gravity          equ $40
vel_jump         equ $4D0
init_y_pos       equ $B0
init_x_pos       equ $1C
bottom_sensor    equ 9
left_sensor      equ 3
right_sensor     equ 4
room_x_offset    equ 16

Player
        lda   routine,u
        asla
        ldx   #Player_Routines
        jmp   [a,x]

Player_Routines
        fdb   Init      
        fdb   Ground
        fdb   Jump
        fdb   Fall
        fdb   FallSlowly
        fdb   Fly
        fdb   FlyEnd
        fdb   FlyExit

Init
        ldd   #Ani_Player_Wait
        std   anim,u

        ldb   #$04
        stb   priority,u

        lda   render_flags,u
        ora   #render_playfieldcoord_mask        
        sta   render_flags,u

        lda   status_flags,u
        ora   #status_xflip_mask
        sta   status_flags,u

        ldd   #init_x_pos
        std   x_pos,u
        ldd   #init_y_pos
        std   y_pos,u

        lda   #-1                      ; hitbox infinite potential
        sta   AABB_0+AABB.p,u
        _ldd  4,8                      ; hitbox xy radius
        std   AABB_0+AABB.rx,u         ; and ry

        _Collision_AddAABB AABB_0,AABB_list_player

        lda   #Ground_routine
        sta   routine,u
        
Ground
        lda   Dpad_Press
        bita  #c1_button_up_mask
        beq   >

        ldd   #-vel_jump
        std   y_vel,u
        lda   #Jump_routine
        sta   routine,u
        ldd   #Ani_Player_Jump
        std   anim,u

        jmp   Jump

!       ; init x_vel
        ldd   #0
        std   x_vel,u

        ; test left
        lda   Dpad_Held
        bita  #c1_button_left_mask
        beq   >   

        lda   status_flags,u
        anda  #^status_xflip_mask
        sta   status_flags,u
        ldd   #Ani_Player_Run
        std   anim,u
        ldd   #-h_top_speed
        std   x_vel,u
        bra   GroundAnim

        ; test right
!       bita  #c1_button_right_mask
        beq   >   

        lda   status_flags,u
        ora   #status_xflip_mask
        sta   status_flags,u
        ldd   #Ani_Player_Run
        std   anim,u
        ldd   #h_top_speed
        std   x_vel,u
        bra   GroundAnim

        ; wait status
!       ldd   #Ani_Player_Wait
        std   anim,u
        ldd   #0
        std   x_vel,u

GroundAnim
        jsr   AnimateSpriteSync   
        jsr   ObjectMoveSync
        jsr   CheckFalling
        jsr   CheckWallLeft
        jsr   CheckWallRight
        jsr   UpdateHitBox
        jmp   DisplaySprite

Jump
        ; init x_vel
        ldd   #0
        std   x_vel,u

        ; test left
        lda   Dpad_Held
        bita  #c1_button_left_mask
        beq   >   

        lda   status_flags,u
        anda  #^status_xflip_mask
        sta   status_flags,u
        ldd   #-h_top_speed
        std   x_vel,u
        bra   JumpAnim

        ; test right
!       bita  #c1_button_right_mask
        beq   JumpAnim   

        lda   status_flags,u
        ora   #status_xflip_mask
        sta   status_flags,u
        ldd   #h_top_speed
        std   x_vel,u

JumpAnim
        jsr   AnimateSpriteSync   
        ldd   #gravity
        std   y_acl,u
        jsr   ObjectFallSync
        jsr   ObjectMoveSync

        ; check falling
        ldd   y_vel,u
        bmi   >
        lda   #Fall_routine
        sta   routine,u
        ldd   #Ani_Player_Fall
        std   anim,u
!       
        jsr   CheckRoomLimit     
        jsr   UpdateHitBox
        jmp   DisplaySprite

Fall
        ; init x_vel
        ldd   #0
        std   x_vel,u

        ; test left
        lda   Dpad_Held
        bita  #c1_button_left_mask
        beq   >   

        lda   status_flags,u
        anda  #^status_xflip_mask
        sta   status_flags,u
        ldd   #-h_top_speed
        std   x_vel,u
        bra   FallAnim

        ; test right
!       bita  #c1_button_right_mask
        beq   FallAnim   

        lda   status_flags,u
        ora   #status_xflip_mask
        sta   status_flags,u
        ldd   #h_top_speed
        std   x_vel,u

FallAnim
        jsr   AnimateSpriteSync
        ldd   #v_top_speed
        cmpd  y_vel,u
        bhi   >
        lda   #FallSlowly_routine
        sta   routine,u
!       ldd   #gravity
        std   y_acl,u
        jsr   ObjectFallSync
        jsr   ObjectMoveSync
        jsr   CheckWallLeft
        jsr   CheckWallRight
        jsr   CheckLanding
        jsr   CheckRoomLimit
        jsr   UpdateHitBox
        jmp   DisplaySprite

FallSlowly
        ; init x_vel
        ldd   #0
        std   x_vel,u

        ; test left
        lda   Dpad_Held
        bita  #c1_button_left_mask
        beq   >   

        lda   status_flags,u
        anda  #^status_xflip_mask
        sta   status_flags,u
        ldd   #-h_fallslow_speed
        std   x_vel,u
        bra   FallSlowlyAnim

        ; test right
!       bita  #c1_button_right_mask
        beq   FallSlowlyAnim

        lda   status_flags,u
        ora   #status_xflip_mask
        sta   status_flags,u
        ldd   #h_fallslow_speed
        std   x_vel,u

FallSlowlyAnim
        jsr   AnimateSpriteSync
        ldd   #0
        std   y_vel,u
        ldd   #v_fallslow_acl
        std   y_acl,u
        jsr   ObjectFallSync
        jsr   ObjectMoveSync
        jsr   CheckWallLeft
        jsr   CheckWallRight
        jsr   CheckLanding
        jsr   CheckRoomLimit
        jsr   UpdateHitBox
        jmp   DisplaySprite

CheckLanding
        ldd   y_pos,u
        addd  #bottom_sensor
        bmi   @rts
        lda   x_pos+1,u
        adda  #-left_sensor-room_x_offset+1
        jsr   room.checkSolid
        bne   >
        ldd   y_pos,u
        addd  #bottom_sensor
        bmi   @rts
        lda   x_pos+1,u
        adda  #right_sensor-room_x_offset-1
        jsr   room.checkSolid
        beq   @rts
!
        ; landing
        ldd   y_pos,u
        addd  #bottom_sensor
        andb  #%11111000
        subd  #bottom_sensor
        std   y_pos,u
        ldd   #0
        std   y_vel,u
        lda   #Ground_routine
        sta   routine,u
@rts    rts

CheckFalling
        ldd   y_pos,u
        addd  #bottom_sensor
        bmi   @rts
        lda   x_pos+1,u
        adda  #-left_sensor-room_x_offset+1
        jsr   room.checkSolid
        bne   @rts
        ldd   y_pos,u
        addd  #bottom_sensor
        bmi   @rts
        lda   x_pos+1,u
        adda  #right_sensor-room_x_offset-1
        jsr   room.checkSolid
        bne   @rts
        lda   #FallSlowly_routine
        sta   routine,u
        ldd   #Ani_Player_Fall
        std   anim,u
@rts    rts

CheckWallLeft
        ldd   y_pos,u
        addd  #bottom_sensor-4
        bmi   @rts
        lda   x_pos+1,u
        adda  #-left_sensor-room_x_offset
        jsr   room.checkSolid
        beq   @rts
        ; wall stop
        ldd   x_pos,u
        subd  #left_sensor
        andb  #%11111100
        addd  #left_sensor+4
        std   x_pos,u
        ldd   #0
        std   x_vel,u
@rts    rts

CheckWallRight
        ldd   y_pos,u
        addd  #bottom_sensor-4
        bmi   @rts
        lda   x_pos+1,u
        adda  #right_sensor-room_x_offset
        jsr   room.checkSolid
        beq   @rts
        ; wall stop
        ldd   x_pos,u
        subd  #right_sensor
        andb  #%11111100
        addd  #right_sensor
        std   x_pos,u
        ldd   #0
        std   x_vel,u
@rts    rts

UpdateHitBox
        ; update hitbox position
        ldd   x_pos,u
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        stb   AABB_0+AABB.cy,u
        rts

CheckRoomLimit
        ; check room limit
        lda   x_pos+1,u
        cmpa  #room_x_offset+4*2+left_sensor
        bhi   >
        lda   #room_x_offset+4*2+left_sensor
        sta   x_pos+1,u
        ldd   #0
        std   x_vel,u
        rts
!       cmpa  #room_x_offset+4*30-right_sensor
        blo   >
        lda   #room_x_offset+4*30-right_sensor
        sta   x_pos+1,u
        ldd   #0
        std   x_vel,u
!       rts

Fly
        ldd   #Ani_Player_Fly
        std   anim,u

        ldd   x_pos,u
        andb  #%11111110
        cmpd  #init_x_pos
        beq   >
        bhi   @decx
@incx
        addd  #2
        bra   >
@decx   
        subd   #2
!       std   x_pos,u

        ldd   y_pos,u
        andb  #%11111110
        cmpd  #init_y_pos
        beq   >
        bhi   @decy
@incy
        addd  #2
        bra   >
@decy   
        subd   #2
!       std   y_pos,u

        jsr   AnimateSpriteSync
        jmp   DisplaySprite

FlyEnd
        ldd   #Ani_Player_Fly_End
        std   anim,u
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

FlyExit
        ldd   #Ani_Player_Wait
        std   anim,u
        lda   #Ground_routine
        sta   routine,u
        lda   status_flags,u
        ora   #status_xflip_mask
        sta   status_flags,u
        jmp   FallSlowly
