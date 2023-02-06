; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0                  equ ext_variables   ; AABB struct (9 bytes)
Scant_isshooting        equ ext_variables+9
Scant_backfire          equ $80
Scant_sensitivity       equ 5
Scant_move_left         equ $-70
Scant_move_right        equ $70
Scant_move_up           equ $-50
Scant_move_down         equ $50
Scant_keep_distance     equ $30
Scant_keep_distance_buf equ $10


Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Scant_init
        fdb   Scant_live
        fdb   Scant_shoot
        fdb   Scant_stopshooting
        fdb   AlreadyDeleted

Scant_init
        ldb   #6    
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        leax  AABB_0,u
        jsr   AddAiAABB
        lda   #24                      ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  12,25                    ; set hitbox xy radius
        std   AABB.rx,x

Scant_stopshooting
        clr   Scant_isshooting,u
        lda   #1
        sta   routine,u
        ldd   #Ani_scant
        std   anim,u   
        clr   anim_frame,u

Scant_live
        jsr   Scant_whattodo
        ldd   x_pos,u
        jsr   ObjectMoveSync
        leax  AABB_0,u
        tst   AABB.p,x
        beq   @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        addd  #5                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
@destroy 
        jsr   LoadObject_x ; make then die early ... to be removed
        beq   @delete
        lda   #ObjID_enemiesblastbig
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        ldd   x_vel,u
        std   x_vel,x
        clr   y_vel,x
@delete lda   #4
        sta   routine,u      
        leax  AABB_0,u
        jsr   RemoveAiAABB
        jmp   DeleteObject
AlreadyDeleted
        rts
Scant_shoot 
        jsr   Scant_shooting
        ldd   x_pos,u
        jsr   ObjectMoveSync
        leax  AABB_0,u
        tst   AABB.p,x
        beq   @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        addd  #5                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

Scant_whattodo

        ldd   player1+x_pos             ; Let's check is Scant is on the left of player1
        cmpd  x_pos,u
        blt   >          
        ldd   #Scant_move_left          ; Yes Scant is, let's move it to the left to exit
        jmp   Scant_whattodonext
!
        ldd   x_pos,u                   ; Lets check how far Scant is from player 1
        subd  #Scant_keep_distance
        cmpd  player1+x_pos
        blt   >
        ldd   #Scant_move_left          ; Still far, can move left
        jmp   Scant_whattodonext
!
        addd  #Scant_keep_distance_buf
        cmpd  player1+x_pos
        blt   >
        ldd   #0
        jmp   Scant_whattodonext
!
        ldd   glb_camera_x_pos          ; Scant is too close to player1, let's check if Scant is too far right
        addd  #130
        cmpd  x_pos,u
        bgt   >
        ldd   #0                        ; Scant is too far on the right, let's cancel its x_vel
        jmp   Scant_whattodonext        

!
        ldd   #Scant_move_right         ; Ok, we can move Scant back
Scant_whattodonext
        std   x_vel,u

        ldd   player1+y_pos
        addd  #Scant_sensitivity
        cmpd  y_pos,u
        blt   Scant_keepup
        subd  #Scant_sensitivity*2
        cmpd  y_pos,U
        bgt   Scant_keepdown
        ldd   player1+x_pos
        cmpd  x_pos,u
        blt   >
        ldd   #Scant_move_left          ; past the r-rtype (on its left), don't shoot, move it left to exit
        std   x_vel,u
        clr   y_vel,u
        
        rts
!       
        ldd   glb_camera_x_pos
        addd  #130
        cmpd  x_pos,u
        bgt   >
        ldd   #00                       ; too far on the right of the screen, don't shoot
        std   y_vel,u
        rts     
!                               ; time to initiate the shoot
        ldd   #00
        std   y_vel,u
        std   x_vel,u
        ldd   #Ani_scant_shoot
        std   anim,u
        inc   routine,u
        rts
Scant_keepdown
        ldd   #Scant_move_down
        std   y_vel,u
        rts
Scant_keepup
        ldd   #Scant_move_up
        std   y_vel,u
        rts
Scant_shooting

        lda   anim_frame,u 
        cmpa  #5
        bgt   Scant_shootdown
        cmpa  #3
        bgt   Scant_initiateshoot
        rts
Scant_shootdown
        clr   x_vel,u
        rts
Scant_initiateshoot
        lda   Scant_isshooting,u
        beq   >
        cmpa  #1
        beq   @scantfireball
        rts
!
        ldd   player1+y_pos             ; Let's re-evaluate the shooting
        addd  #Scant_sensitivity
        cmpd  y_pos,u
        blt   Scant_keepup
        subd  #Scant_sensitivity*2
        cmpd  y_pos,U
        bgt   Scant_keepdown
        ldd   player1+x_pos
        cmpd  x_pos,u
        blt   >        
        clr   Scant_isshooting,u        ; No longer good to shoot, reset
        lda   #1
        sta   routine,u
        ldd   #Ani_scant
        std   anim,u   
        clr   anim_frame,u 
        ldd   #Scant_move_left
        std   x_vel,u
        rts                   
!
        jsr   LoadObject_x              ; Alright, this time, we're good ! Shoot !
        beq   >
        lda   #ObjID_scantfire
        sta   id,x
        ldd   x_pos,u
        subd  #16
        std   x_pos,x
        ldd   y_pos,u
        subd  #7
        std   y_pos,x
        ldd   #$-160
        std   x_vel,x
        ldd   #0
        std   y_vel,x
        ldd   #Scant_backfire
        std   x_vel,u
        lda   #1
        sta   Scant_isshooting,u
!
        rts
@scantfireball
        jsr   LoadObject_x ; Scant shoot
        beq   >
        lda   #ObjID_scantfireball
        sta   id,x
        ldd   x_pos,u
        subd  #16
        std   x_pos,x
        ldd   y_pos,u
        subd  #7
        std   y_pos,x
        ldd   #Scant_backfire
        std   x_vel,x
        ldd   #0
        std   y_vel,x
        lda   #2
        sta   Scant_isshooting,u
!
        rts

