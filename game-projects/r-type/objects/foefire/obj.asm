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
        fdb   init
        fdb   live
        fdb   alreadyDeleted

init
        ldd   #Img_foefire_0
        std   image_set,u
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

        _Collision_AddAABB AABB_0,AABB_list_foefire
        
        leax  AABB_0,u
        lda   #2                                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  2,2                                       ; set hitbox xy radius
        std   AABB.rx,x

live
        ; apply velocity toposition
        lda   gfxlock.frameDrop.count
        sta   glb_d0_b
        ldd   #0
!       addd  x_vel,u
        dec   glb_d0_b
        bne   < 
        jsr   moveXPos8.8              ; apply X velocity in sync with framerate

        lda   gfxlock.frameDrop.count
        sta   glb_d0_b
        ldd   #0
!       addd  y_vel,u
        dec   glb_d0_b
        bne   < 
        ldd   y_vel,u
        jsr   moveYPos8.8              ; apply Y velocity in sync with framerate

        ; arcade dead code ?
        ;CMP        word ptr [BP + 0x0],0xe603 ; don't know the object that use this, bypass the timer if routine is set to 0xe603 instead of 0xe601
        ;JZ         LAB_0000_ea23

        ; make bullet visible only after the timer is over
        lda   fireDisplayDelay,u
        beq   LAB_0000_ea23
        dec   fireDisplayDelay,u
        bra   LAB_0000_ea42

LAB_0000_ea23 
        jsr   DisplaySprite

LAB_0000_ea42
        ; Collision test to player, kill player if touched, but bullet should not explode nor be deleted
        ; Collision test to forcepod, explode bullet if touched 
        ; No other collision (playerweapon does not destroy bullets)        ;

        ; Collision (Terrain) : foreground and background
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   destroy
        lda   globals.backgroundSolid
        beq   >
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        bne   destroy
!
        ; check if bullet is outside the viewport
        ; x axis
        ldd   x_pos,u                                   ; set visibility range
        cmpd  glb_camera_x_pos                          ; destroy if out of range
        ble   destroy
        subd  #160-8/2
        cmpd  glb_camera_x_pos
        bge   destroy
        ; y axis
        ldd   y_pos,u
        ble   destroy
        cmpd  #160
        bge   destroy

        ; collision
        leax  AABB_0,u
        lda   AABB.p,x
        beq   destroy

        ; update hitbox position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        rts

destroy
        ; todo : add explosion routine
foefireExplosion
        ; animation : 5 images, durée d'une image : 2 frames
        ; respecter les timings mais afficher au moins l'image de fin
        ; auto destruction à la fin de l'animation

        inc   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_foefire
        jmp   DeleteObject

alreadyDeleted
        rts
