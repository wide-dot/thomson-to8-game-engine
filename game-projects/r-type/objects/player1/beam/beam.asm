; ---------------------------------------------------------------------------
; Object - Beam
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

AABB_0    equ ext_variables ; AABB struct (9 bytes)
halfWidth equ ext_variables+9 ; half width of the beam
impactX   equ ext_variables+11 ; impact x position
; temporary estimateddamage : 6,8,10,12,14 (TODO should get the real value from arcade)

Beam
        lda   routine,u
        asla
        ldx   #Beam_Routines
        jmp   [a,x]

Beam_Routines
        fdb   Init
        fdb   Live
        fdb   Impact
        fdb   Delete
        fdb   AlreadyDeleted

Init
        _soundFX.play soundFX.FireBlastSound,2
	ldx   #Ani_Beams
	ldb   subtype,u
	aslb
	ldd   b,x
        std   anim,u
        ldb   #4
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        lda   subtype,u                ; set damage potential for this hitbox
	asla
	adda  #6                       ; not the real values here just estimates
        sta   AABB_0+AABB.p,u
        ;lda   subtype,u                ; set damage potential for this hitbox
	;asla
	;adda  subtype,u                ; mult by 3
	;adda  #3                       ; set hitbox x radius (3 6 9 12 15)
        ;ldb   #6                       ; set hitbox y radius
        _ldd  15,6                      ; set hitbox xy radius (x should be dynamic, but deactivatedfor framerate compensation)
        std   AABB_0+AABB.rx,u
	clr   halfWidth,u
	sta   halfWidth+1,u
	adda  #8                       ; starship width/2
	adda  x_pos+1,u
	bcc   >
	inc   x_pos,u
!	sta   x_pos+1,u
        ldd   y_pos,u
        addd  #2
        std   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u

        ; compute wall hit destiny
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.xAxis.do
        ldd   terrainCollision.impact.x
        std   impactX,u
        inc   routine,u
        bra   >

Live
        ; delete beam if no more damage potential
        lda   AABB_0+AABB.p,u
        beq   Delete

        ; update beam position
        lda   #3
        ldb   gfxlock.frameDrop.count
        mul
        addd  x_pos,u
        addd  glb_camera_x_pos
        subd  glb_camera_x_pos_old
        std   x_pos,u
!
        ; check wall collision
        ldd   impactX,u
        beq   >
        subd  halfWidth,u ; check collision on the right side
        cmpd  x_pos,u
        bhi   >
        jsr   RandomNumber
        clra
        andb  #%00000011
        _negd
        subd  #3 ; half width of the beam
        addd  impactX,u
        std   x_pos,u
        ldd   #Ani_beam_impact
        std   anim,u
        inc   routine,u
        bra   Impact
!
        ; update hitbox position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u

        ; delete beam if out of screen range
        cmpd  #160-8/2                 ; delete beam if out of screen range
        bhs   Delete
	;jsr   AnimateSpriteSync       ; optim ... same code as Impact 
        ;jmp   DisplaySprite

Impact
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

Delete 
        lda   #4 ; do not use inc here, it will lead to a bug.
        sta   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        jmp   DeleteObject

AlreadyDeleted
        rts ; once deleted, the object can be called again for double buffering update.

Ani_Beams
        fdb   Ani_beam0
        fdb   Ani_beam1
        fdb   Ani_beam2
        fdb   Ani_beam3
        fdb   Ani_beam4