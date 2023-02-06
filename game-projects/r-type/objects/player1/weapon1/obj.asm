
; ---------------------------------------------------------------------------
; Object - Weapon10
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0  equ ext_variables ; AABB struct (9 bytes)

Weapon10
        lda   routine,u
        asla
        ldx   #Weapon10_Routines
        jmp   [a,x]

Weapon10_Routines
        fdb   Init
        fdb   Init_Collision
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
        inc   routine,u
        jmp   DisplaySprite

Init_Collision                         ; init collision when a frame is already displayed
        leax  AABB_0,u                 ; thus xy_pixel is available
        jsr   AddPlayerAABB
        lda   #1                       ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  3,1                      ; set hitbox xy radius
        std   AABB.rx,x
        inc   routine,u

Live
        leax  AABB_0,u
        tst   AABB.p,x
        beq   @delete                  ; delete weapon if something was hit  
        ldd   xy_pixel,u
        std   AABB.cx,x
        lda   #4
        ldb   Vint_Main_runcount
        mul
        addd  x_pos,u
        std   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #160-8/2                 ; delete weapon if out of screen range
        ble   >
@delete lda   #3
        sta   routine,u   
        leax  AABB_0,u
        jsr   RemovePlayerAABB
        jmp   DeleteObject
!       jmp   DisplaySprite
AlreadyDeleted
        rts