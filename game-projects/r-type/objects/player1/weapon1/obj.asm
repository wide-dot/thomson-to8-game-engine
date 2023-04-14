
; ---------------------------------------------------------------------------
; Object - Weapon1
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0  equ ext_variables ; AABB struct (9 bytes)

Weapon10
        lda   routine,u
        asla
        ldx   #Weapon10_Routines
        jmp   [a,x]

Weapon10_Routines
        fdb   Init
        fdb   Live
        fdb   AlreadyDeleted

Init
        ldd   x_pos,u
        addd  #6
        std   x_pos,u
        ldd   y_pos,u
        addd  #2
        std   y_pos,u
        ldd   #Img_weapon_1
        std   image_set,u
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        lda   #1                       ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  3,1                      ; set hitbox xy radius
        std   AABB_0+AABB.rx,u

        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u

        inc   routine,u

Live
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   @delete
        lda   AABB_0+AABB.p,u
        beq   @delete                  ; delete weapon if something was hit  
        lda   #4
        ldb   gfxlock.frameDrop.count
        mul
        addd  x_pos,u
        std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        cmpd  #160-8/2                 ; delete weapon if out of screen range
        ble   >
@delete lda   #2
        sta   routine,u   
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        jmp   DeleteObject
!       
        jmp   DisplaySprite
AlreadyDeleted
        rts