
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
        ldd   x_pos,u
        addd  #6
        std   x_pos,u
        ldd   y_pos,u
        addd  #2
        std   y_pos,u
        ldd   #Img_shootdown
        std   image_set,u
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        leax  AABB_0,u
        lda   #1                       ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  1,3                      ; set hitbox xy radius
        std   AABB.rx,x

        inc   routine,u

Live
        leax  AABB_0,u        
        lda   AABB.p,x
        beq   @delete                  ; delete weapon if something was hit  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        lda   #8
        ldb   Vint_Main_runcount
        mul
        addd  y_pos,u
        std   y_pos,u
        stb   AABB.cy,x
        cmpd  #180                    ; delete weapon if out of screen range
        blt   >
@delete lda   #2
        sta   routine,u   
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        jmp   DeleteObject
!       
        jmp   DisplaySprite
AlreadyDeleted
        rts