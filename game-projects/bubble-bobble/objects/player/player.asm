; ---------------------------------------------------------------------------
; Object - Player
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm" 

Init_routine       equ 0
Ground_routine     equ 1
Jump_routine       equ 2
Fall_routine       equ 3
FallSlowly_routine equ 4

h_top_speed      equ $A0
h_fallslow_speed equ $40
v_top_speed      equ $400
v_fallslow_acl   equ $180
gravity          equ $40
vel_jump         equ $4D0
init_y_pos       equ $B8
init_x_pos       equ $1B
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
        ; only check room limit
        lda   x_pos+1,u
        cmpa  #room_x_offset+4*2+left_sensor
        bhi   >
        lda   #room_x_offset+4*2+left_sensor
        sta   x_pos+1,u
        ldd   #0
        std   x_vel,u
        jmp   DisplaySprite
!       cmpa  #room_x_offset+4*30-right_sensor
        blo   >
        lda   #room_x_offset+4*30-right_sensor
        sta   x_pos+1,u
        ldd   #0
        std   x_vel,u
!       jmp   DisplaySprite

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
        jmp   DisplaySprite

CheckLanding
        lda   x_pos+1,u
        adda  #-left_sensor-room_x_offset+1
        ldb   y_pos+1,u
        addb  #bottom_sensor
        ldx   #Level1
        jsr   room.checkSolid
        bne   >

        lda   x_pos+1,u
        adda  #right_sensor-room_x_offset-1
        ldb   y_pos+1,u
        addb  #bottom_sensor
        ldx   #Level1
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
        lda   x_pos+1,u
        adda  #-left_sensor-room_x_offset+1
        ldb   y_pos+1,u
        addb  #bottom_sensor
        ldx   #Level1
        jsr   room.checkSolid
        bne   >

        lda   x_pos+1,u
        adda  #right_sensor-room_x_offset-1
        ldb   y_pos+1,u
        addb  #bottom_sensor
        ldx   #Level1
        jsr   room.checkSolid
        bne   >

        lda   #FallSlowly_routine
        sta   routine,u
        ldd   #Ani_Player_Fall
        std   anim,u
!       rts

CheckWallLeft
        lda   x_pos+1,u
        adda  #-left_sensor-room_x_offset
        ldb   y_pos+1,u
        ldx   #Level1
        jsr   room.checkSolid
        beq   >

        ; wall stop
        ldd   x_pos,u
        subd  #left_sensor
        andb  #%11111100
        addd  #left_sensor+4
        std   x_pos,u
        ldd   #0
        std   x_vel,u
!
        rts

CheckWallRight
        lda   x_pos+1,u
        adda  #right_sensor-room_x_offset
        ldb   y_pos+1,u
        ldx   #Level1
        jsr   room.checkSolid
        beq   >

        ; wall stop
        ldd   x_pos,u
        subd  #right_sensor
        andb  #%11111100
        addd  #right_sensor
        std   x_pos,u
        ldd   #0
        std   x_vel,u
!
        rts

;-----------------------------------------------------------------
; room.checkSolid
; input  REG : [A] x pixel position of sensor on screen
; input  REG : [B] y pixel position of sensor on screen
; input  REG : [X] room solid bitmask (32bits x 25)
; output REG : [CC Z] zero flag is set if no collision
;-----------------------------------------------------------------
; check a solid tile collision in screen coordinates
;-----------------------------------------------------------------

room.checkSolid
        lsrb            ; (y_pos * 4 bytes per row) / tile height
        andb #%11111100
        abx
        lsra
        lsra
        tfr   a,b
        anda  #%00000111
        lsrb
        lsrb
        lsrb            ; x_pos / tile width / 8 bits per byte
        abx
        ldb   ,x
        ldx   #room.mask
        andb  a,x
        rts

room.mask
        fcb   %10000000
        fcb   %01000000
        fcb   %00100000
        fcb   %00010000
        fcb   %00001000
        fcb   %00000100
        fcb   %00000010
        fcb   %00000001

Level1
        fdb   %1111111111111111,%1111111111111111
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1111000111111111,%1111111110001111
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1111000111111111,%1111111110001111
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1111000111111111,%1111111110001111
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1111111111111111,%1111111111111111
