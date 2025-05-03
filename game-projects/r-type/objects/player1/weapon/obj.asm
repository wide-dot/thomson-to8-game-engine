
; ---------------------------------------------------------------------------
; Object - Weapon
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
impactX equ ext_variables+9 ; impact x position

Weapon
        lda   routine,u
        asla
        ldx   #Weapon_Routines
        jmp   [a,x]

Weapon_Routines
        fdb   Init
        fdb   Live
        fdb   Impact
        fdb   Delete
        fdb   AlreadyDeleted

Init
        _soundFX.play soundFX.FireSound,0
        ldd   x_pos,u
        addd  #8+3
        std   x_pos,u
        ldd   y_pos,u
        addd  #2
        std   y_pos,u
        ldd   #Img_weapon
        std   image_set,u
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        lda   #1                       ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  15,1                     ; set hitbox xy radius (x should be 3, but 15 for framerate compensation)
        std   AABB_0+AABB.rx,u

        ldd   y_pos,u
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
        ; delete weapon if no more damage potential
        lda   AABB_0+AABB.p,u
        beq   Delete

        ; update weapon position
        lda   #6
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
        subd  #3 ; half width of the weapon, to check collision on the right side
        cmpd  x_pos,u
        bhi   >
        jsr   RandomNumber
        clra
        andb  #%00000011
        _negd
        subd  #3 ; half width of the weapon
        addd  impactX,u
        std   x_pos,u
        ldd   #Ani_weapon_impact
        std   anim,u
        inc   routine,u
        bra   Impact
!
        ; update hitbox position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u

        ; delete weapon if out of screen range
        cmpd  #160-8/2                 ; delete weapon if out of screen range
        bhs   Delete
        jmp   DisplaySprite

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

