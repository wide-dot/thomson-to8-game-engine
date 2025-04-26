
; ---------------------------------------------------------------------------
; Object - Beam P0
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/soundFX/soundFX.const.asm"
        INCLUDE "./engine/sound/soundFX.macro.asm"
AABB_0  equ ext_variables ; AABB struct (9 bytes)
damage  equ 14
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
        _soundFX.play soundFX.FireBlastSound,2
	ldd   #Ani_beamp4
        std   anim,u
        ldb   #4
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        leax  AABB_0,u
        lda   #damage                  ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  3,6                      ; set hitbox xy radius
        std   AABB.rx,x

        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x

        inc   routine,u

Live
        leax  AABB_0,u
        lda   AABB.p,x
        beq   @delete                  ; delete weapon if something was hit  
        lda   #2
        ldb   gfxlock.frameDrop.count
        mul
        addd  x_pos,u
        std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        cmpd  #160-8/2                 ; delete weapon if out of screen range
        ble   >
@delete inc   routine,u   
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        jmp   DeleteObject
!       
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
AlreadyDeleted
        rts