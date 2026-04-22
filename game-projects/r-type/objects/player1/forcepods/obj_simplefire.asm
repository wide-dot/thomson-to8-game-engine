
; ---------------------------------------------------------------------------
; Object - Weapon
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0  equ ext_variables ; AABB struct (9 bytes)

Weapon
        lda   routine,u
        asla
        ldx   #Weapon_Routines
        jmp   [a,x]

Weapon_Routines
        fdb   Init
        fdb   Live
        fdb   Impact
        fdb   Delete
        fdb   AlreadyDeleted

Init
        lda   #6
        ldb   subtype,u
        mul
        ldx   #SimpleFirePresets
        abx
        ldd   ,x
        std   image_set,u
        ldd   2,x
        std   x_vel,u
        ldd   4,x
        std   y_vel,u

        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        leax  AABB_0,u
        lda   #1                       ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  9,6                      ; set hitbox xy radius (arcade unique size: 24,8)
        std   AABB.rx,x

        inc   routine,u

Live
        ; delete weapon if no more damage potential
        lda   AABB_0+AABB.p,u
        beq   Delete

        ; update weapon position
        jsr   ObjectMoveSync
        ldd   x_pos,u
        addd  glb_camera_x_pos
        subd  glb_camera_x_pos_old
        std   x_pos,u
        subd  glb_camera_x_pos        
        stb   AABB_0+AABB.cx,u
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u

        ; check wall collision
        ; deactivated: TODO
        bra   >
        ldd   #Img_weapon_impact0
        std   image_set,u
        inc   routine,u
        jmp   DisplaySprite
!

        ; delete weapon if out of screen range
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #-9
        blt   Delete
        cmpd  #144+9
        bge   Delete
        ldd   y_pos,u
        subd  glb_camera_y_pos
        cmpd  #-6
        blt   Delete
        cmpd  #180+6
        bge   Delete

        jmp   DisplaySprite

Impact
        inc   routine,u
        ldd   #Img_weapon_impact3
        std   image_set,u
        jmp   DisplaySprite

Delete 
        lda   #4 ; do not use inc here, it will lead to a bug.
        sta   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        jmp   DeleteObject

AlreadyDeleted
        rts ; once deleted, the object can be called again for double buffering update.

SimpleFirePresets
        ; Arcade reference speed : $0,$a00 $c00,$240 $d00,$0
        fdb   Img_shootup
        fdb   $0,-$780
        fdb   Img_shootupright
        fdb   $480,-$1b8
        fdb   Img_shootright
        fdb   $4e0,$0
        fdb   Img_shootdownright
        fdb   $480,$1b8
        fdb   Img_shootdown
        fdb   $0,$780
