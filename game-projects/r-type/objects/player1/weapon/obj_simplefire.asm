
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

        fdb   InitPod
        fdb   LivePod
        fdb   ImpactPod

Init
        lda   subtype,u
        beq   >
        jmp   InitPod
!        
        _soundFX.play soundFX.FireSound,0
        ldd   x_pos,u
        addd  #8+3
        std   x_pos,u
        ldd   y_pos,u
        addd  #2
        std   y_pos,u
        ldd   #Img_horizontal
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
        jsr   terrainCollision.xAxis.doRight
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
        ldd   #Img_weapon_impact0
        std   image_set,u
        inc   routine,u
        jmp   DisplaySprite
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
        inc   routine,u
        ldd   #Img_weapon_impact3
        std   image_set,u
        jmp   DisplaySprite

Delete 
        lda   #4 ; do not use inc here, it will lead to a bug.
        sta   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        jmp   DeleteObject

AlreadyDeleted
        rts ; once deleted, the object can be called again for double buffering update.


; Forcepod simple fire weapon
; ---------------------------

InitPod
        lda   #5
        sta   routine,u
        dec   subtype,u

        ldx   #SubtypeImages
        ldb   subtype,u
        aslb
        ldx   b,x
        stx   image_set,u

        ldx   #SubTypeVelocities
        aslb
        abx
        ldd   ,x
        std   x_vel,u
        ldd   2,x
        std   y_vel,u

        ldx   objects.forcepod
        ldd   x_pos,x
        std   x_pos,u
        ldd   y_pos,x
        std   y_pos,u

        ldb   #2
        stb   priority,u

        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        lda   #1                       ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  6,4                      ; set hitbox xy radius (with framerate compensation)
        std   AABB_0+AABB.rx,u         ; arcade is rx: x0c and ry: x04
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u

        _Collision_AddAABB AABB_0,AABB_list_friend

        inc   routine,u        

LivePod
        jsr   ObjectMoveSync

        ; compensate for camera movement
        ldd  x_pos,u
        addd  glb_camera_x_pos
        subd  glb_camera_x_pos_old
        std   x_pos,u

        ; update hitbox position
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u

        ; check wall collision
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   >
        inc   routine,u
        jmp   DisplaySprite
!

        ; delete weapon if no more damage potential
        lda   AABB_0+AABB.p,u
        beq   DeletePod ; TODO: in arcade, should display a specific impact sprite

        ; delete weapon if out of screen range
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #160-8/2                 ; delete weapon if out of screen range
        bhs   DeletePod
        ldd   y_pos,u
        bmi   DeletePod
        cmpd  #180                     ; delete weapon if out of screen range
        bhs   DeletePod
        jmp   DisplaySprite

ImpactPod
        lda   #3
        sta   routine,u
        ldd   #Img_weapon_impact3
        std   image_set,u
        jmp   DisplaySprite

DeletePod 
        lda   #4 ; do not use inc here, it will lead to a bug.
        sta   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        jmp   DeleteObject

SubtypeImages
        fdb   Img_pod_vertical_up
        fdb   Img_pod_diagonal_up
        fdb   Img_pod_horizontal
        fdb   Img_pod_diagonal_down
        fdb   Img_pod_vertical_down

SubTypeVelocities
        fdb   $0000 ; x_vel VERTICAL UP
        fdb   $FC40 ; y_vel

        fdb   $0480 ; x_vel DIAGONAL UP
        fdb   $FE50 ; y_vel

        fdb   $04E0 ; x_vel HORIZONTAL
        fdb   $0000 ; y_vel

        fdb   $0480 ; x_vel DIAGONAL DOWN
        fdb   $01B0 ; y_vel

        fdb   $0000 ; x_vel
        fdb   $03C0 ; y_vel VERTICAL DOWN
