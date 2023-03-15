; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/player1/player1.equ"
AABB_0            equ ext_variables   ; AABB struct (9 bytes)

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   InitOptionBox
        fdb   LiveOptionBox
        fdb   AlreadyDeletedOptionBox
        fdb   Live

InitOptionBox
        ldd   #Ani_bitdevice
        std   anim,u
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

        _Collision_AddAABB AABB_0,AABB_list_bonus
        
        leax  AABB_0,u
        lda   #1                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  4,7                       ; set hitbox xy radius
        std   AABB.rx,x

LiveOptionBox
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        leax  AABB_0,u
        lda   AABB.p,x
        beq   Init                     ; was touched  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        ldb   y_pos+1,u
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
!       
        _Collision_RemoveAABB AABB_0,AABB_list_bonus
        inc   routine,u
        jmp   DeleteObject
AlreadyDeletedOptionBox
        rts
Init
        _Collision_RemoveAABB AABB_0,AABB_list_bonus
        _Collision_AddAABB AABB_0,AABB_list_friend
        
        leax  AABB_0,u
        lda   #255                      ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  3,6                       ; set hitbox xy radius
        std   AABB.rx,x
        ldd   y_pos,u
        stb   AABB.cy,x

        lda   #3
        sta   routine,u
Live
        ldd   player1+x_pos
        std   x_pos,u
        ldd   player1+y_pos
        subd  #16
        std   y_pos,u
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

