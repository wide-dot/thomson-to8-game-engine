
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
        
        leax  AABB_0,u
        lda   #255                     ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  12,24                    ; set hitbox xy radius
        std   AABB.rx,x
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
        leax  AABB_0,u
        ldd   player1+x_pos
	addd  #33
	std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   player1+y_pos
	std   y_pos,u
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
InitLeft

        ldd   #Ani_counterairlaser_2
        std   anim,u
        lda   #3                       ; Set routine to LiveOpeningLeft
        sta   routine,u

LiveOpeningLeft
        leax  AABB_0,u
        ldd   player1+x_pos
	subd  #33
	std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   player1+y_pos
	std   y_pos,u
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

LiveFreeInitLeft
        leax  AABB_0,u
        _ldd  12,12                    ; set hitbox xy radius
        std   AABB.rx,x
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
        leax  AABB_0,u
        _ldd  12,12                    ; set hitbox xy radius
        std   AABB.rx,x
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
        leax  AABB_0,u
        lda   #3
@livefreespeed equ *-1
        ldb   Vint_Main_runcount
        mul
        sex
        addd  x_pos,u
        bmi   @delete
        std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        cmpd  #160-8/2                 ; delete weapon if out of screen range
        bgt   @delete
	ldb   y_pos+1,u
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
@delete
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        lda   #6
        sta   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts

