
; ---------------------------------------------------------------------------
; Object - Weapon1
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;       subtype : bit 6 => 0=going right, 1=going left
;                 bit 7 => 0=going up,   1=going down
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
        fdb   InitRight
        fdb   LiveOpeningRight
        fdb   LiveFreeInitRight
        fdb   LiveOpeningLeft
        fdb   LiveFreeInitLeft
        fdb   LiveFree
        fdb   AlreadyDeleted

InitRight

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        lda   #255                     ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  12,24                    ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        inc   routine,u                ; Set routine to LiveOpeningRight

        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        lda   subtype,u
        bita  #1
        bne   InitLeft

        ldd   #Ani_counterairlaser_0
        std   anim,u
LiveOpeningRight
        ldd   player1+x_pos
	addd  #33
	std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
	ldd   player1+y_pos
	std   y_pos,u
        stb   AABB_0+AABB.cy,u
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
InitLeft

        ldd   #Ani_counterairlaser_2
        std   anim,u
        lda   #3                       ; Set routine to LiveOpeningLeft
        sta   routine,u

LiveOpeningLeft
        ldd   player1+x_pos
	subd  #33
	std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
	ldd   player1+y_pos
	std   y_pos,u
        stb   AABB_0+AABB.cy,u
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

LiveFreeInitLeft
        _ldd  12,12                    ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        lda   #5                       ; Set routine to LiveFree
        sta   routine,u
        ldd   #Ani_counterairlaser_3
        std   anim,u
        clr   anim_frame,u
        ldd   x_pos,u
        subd  #12
        std   x_pos,u
        lda   #-2
        sta   @livefreespeed
        bra   LiveFree
LiveFreeInitRight
        _ldd  12,12                    ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        lda   #5                       ; Set routine to LiveFree
        sta   routine,u
        ldd   #Ani_counterairlaser_1
        std   anim,u
        clr   anim_frame,u
        ldd   #12
        addd  x_pos,u
        std   x_pos,u
        lda   #3
        sta   @livefreespeed 
LiveFree
        lda   #3
@livefreespeed equ *-1
        ldb   gfxlock.frameDrop.count
        mul
        sex
        addd  x_pos,u
        std   x_pos,u
        subd  glb_camera_x_pos
        bmi   @delete
        stb   AABB_0+AABB.cx,u
        cmpd  #160-8/2                 ; delete weapon if out of screen range
        bgt   @delete
	ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
@delete
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        lda   #6
        sta   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts

