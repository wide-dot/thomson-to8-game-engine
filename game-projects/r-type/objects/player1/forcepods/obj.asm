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
currentlevel      equ ext_variables+9 ; Byte

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldd   #Ani_forcepod_0
        std   anim,u
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

        lda   #1
        sta   currentlevel,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        leax  AABB_0,u
        lda   #129                      ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  7,10                       ; set hitbox xy radius
        std   AABB.rx,x
        ldd   y_pos,u
        stb   AABB.cy,x

Live
        lda   player1+forcepodlevel
        cmpa  currentlevel,u
        beq   @continue
        ldx   #Ani_forcepod_1
        cmpa  #2
        beq   >
        ldx   #Ani_forcepod_2
!
        stx   anim,u
        clr   anim_frame,u
        sta   currentlevel,u
@continue
        leax  AABB_0,u
        ldd   player1+x_pos
	addd  #9
	std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   player1+y_pos
	std   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
!       jmp   DeleteObject
