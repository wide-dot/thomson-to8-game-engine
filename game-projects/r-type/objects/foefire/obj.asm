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
AABB_0                  equ ext_variables   ; AABB struct (9 bytes)
Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live
        fdb   Alreadydeleted

Init
        ldd   #Img_foefire_0
        std   image_set,u
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        leax  AABB_0,u
        lda   #2                                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  2,2                                       ; set hitbox xy radius
        std   AABB.rx,x

Live
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   @destroy
        subd  #160-8/2
        cmpd  glb_camera_x_pos
        bge   @destroy
        ldd   y_pos,u
        cmpd  #0
        ble   @destroy
        cmpd  #160
        bge   @destroy
        jsr   ObjectMoveSync
        leax  AABB_0,u
        lda   AABB.p,x
        beq   @destroy                                  ; was destroyed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        jmp   DisplaySprite
@destroy
        inc   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
Alreadydeleted
        rts