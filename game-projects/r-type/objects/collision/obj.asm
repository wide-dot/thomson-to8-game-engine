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

AABB_0  equ ext_variables   ; AABB struct (9 bytes)
Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live
	fdb   AlreadyDeleted

Init

	ldd   #Img_collision
        std   image_set,u
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u


	inc   routine,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        leax  AABB_0,u
        lda   #255                      ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  14,5                      ; set hitbox xy radius
        std   AABB.rx,x
        ldd   y_pos,u
        stb   AABB.cy,x


Live
        jsr   ObjectMoveSync
	leax  AABB_0,u
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        addd  #14                       ; add x radius
        bmi   @delete                   ; branch if out of screen's left
        jmp   DisplaySprite
@delete
        inc   routine,u     
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts