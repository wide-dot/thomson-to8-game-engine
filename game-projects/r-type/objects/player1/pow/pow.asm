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
        INCLUDE "./objects/animation/anim-data.equ"

AABB_0  equ ext_variables ; AABB struct (9 bytes)

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   init
        fdb   fall
        fdb   land
        fdb   initWalk
        fdb   walk
        fdb   takeoff
        fdb   initfly
        fdb   fly
        fdb   alreadyDeleted

initRtn             equ 0
fallRtn             equ 1
landRtn             equ 2
initWalkRtn         equ 3
walkRtn             equ 4
takeoffRtn          equ 5
initflyRtn          equ 6
flyRtn              equ 7
alreadyDeletedRtn   equ 8

; ---------------------------------------------------------------------------

init
        ldb   subtype_w+1,u            ; load x and y pos based on wave parameter
        andb  #$0F
        aslb
        ldx   #PresetXYIndex
        abx
        clra
        ldb   1,x
        std   y_pos,u
        ldb   ,x
        addd  glb_camera_x_pos
        std   x_pos,u

        ; if created left, use another animation script
        lda   status_flags,u
        ldb   ,x
        ldx   #anim_pow_0
        cmpb  #8+6                       ; 16px in arcade (position $150) 5a08 CMP word ptr [SI + 0x4],0x150
        bhs   >
        ldx   #anim_pow_1
        ora   #status_xflip_mask
!       sta   status_flags,u
        clrb
        jsr   AnimateMoveSyncInit

        ; init render_flags with status flags
        lda   status_flags,u
        anda  #status_xflip_mask|status_yflip_mask
        sta   @dyn+1
        lda   #render_playfieldcoord_mask
        anda  #^(render_xmirror_mask|render_ymirror_mask)
@dyn    ora   #0
        sta   render_flags,u

        ; display priority
        lda   #6
        sta   priority,u

        ; set subtype based on preset
        ; (the bonus to be release)
        ldb   subtype+1,u
        stb   subtype,u

        ; moves skipped frames before object creation
        ldd   #flyStep
        std   animateMoveSync.callback
        ldb   anim_frame_duration,u
        jsr   AnimateMoveStepsCallback

        ; register hit box
        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        lda   #1                                                       ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  5,10                                                     ; set hitbox xy radius
        std   AABB_0+AABB.rx,u

        ; I believe I can fly ...
        ldd   #Img_pow_fly
        std   image_set,u
        lda   #flyRtn
        sta   routine,u
        jmp   DisplaySprite

; ---------------------------------------------------------------------------

fall
        lda   gfxlock.frameDrop.count  
        deca
        sta   counter
!       inc   y_pos+1,u
        jsr   flyStep
        dec   counter
        bpl   <
        jsr   updateHitbox
        jmp   DisplaySprite
counter fcb   0

; ---------------------------------------------------------------------------

fly
        ldd   #flyStep
        std   animateMoveSync.callback
        jsr   AnimateMoveSyncCallback
        jsr   updateHitbox
        jmp   DisplaySprite

flyStep
        ; Terrain Collision - Ground
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #12
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   >

        ; Hit Ground
        lda   y_pos+1,u                ; snap sprite to top of the ground tile
        nega
        adda  #6
        ldb   #85
        mul
        lsra
        ldb   #6
        mul
        negb
        stb   y_pos+1,u
        ldd   #Ani_pow_land            ; set landing animation
        std   anim,u
        lda   #landRtn                 ; set landing routine
        sta   routine,u
        clr   counter
        rts

!       ; Terrain Collision - Wall
        ldb   render_flags,u
        andb  #render_xmirror_mask
        beq   >
        ldd   #6
        bra   @end
!       ldd   #-6
@end
        addd  x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   >

        ; Hit Wall or Ceil
        clr   counter
@fall   lda   #fallRtn
        sta   routine,u
        rts
!
        ; Terrain Collision - Ceil
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        subd  #12
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   @fall
        rts

; ---------------------------------------------------------------------------

land
        jsr   updateHitbox
        jsr   AnimateSpriteSync ; routine incremented at the end of animation
        jmp   DisplaySprite

; ---------------------------------------------------------------------------

initWalk
        ldd   #Ani_pow_walk
        std   anim,u
        lda   #walkRtn
        sta   routine,u

        ldx   #-$0060 ; speed (1px/frame * 3/4 * 1/2)
        ldb   render_flags,u
        andb  #render_xmirror_mask
        beq   >
        ldx   #$0060  ; speed (1px/frame * 3/4 * 1/2)
!       stx   x_vel,u
        ldd   #0
        std   y_vel,u
walk
        jsr   ObjectMoveSync
        jsr   updateHitbox

        ; Terrain Collision - Ground
        ldb   render_flags,u
        andb  #render_xmirror_mask
        beq   >
        ldd   #6
        bra   @end
!       ldd   #-6
@end
        addd  x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #15
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   >                        ; here branch if collision (ground continuity)

walkTakeOff
        lda   #takeoffRtn
        sta   routine,u
        ldd   #0
        std   x_vel,u
        std   y_vel,u
        jsr   AnimateSpriteSync
        ldd   #Ani_pow_takeoff
        std   anim,u
        jmp   DisplaySprite

!       ; Terrain Collision - Wall
        ldb   render_flags,u
        andb  #render_xmirror_mask
        beq   >
        ldd   #5
        bra   @end
!       ldd   #-5
@end
        addd  x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #7
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   >

        ; Wall change direction and takeoff
        ldb   status_flags,u
        eorb  #status_xflip_mask
        stb   status_flags,u
        bra   walkTakeOff

!       jsr   AnimateSpriteSync
        jmp   DisplaySprite

; ---------------------------------------------------------------------------

takeoff
        jsr   updateHitbox ; attention ici TODO !!! si delete dans l'updateHitBoxon va revenir à l'animate et au display sprite !!!!!
        jsr   AnimateSpriteSync ; routine incremented at the end of animation
        jmp   DisplaySprite

; ---------------------------------------------------------------------------

initfly
        lda   #flyRtn
        sta   routine,u
        ldd   #Img_pow_fly
        std   image_set,u

        ldx   #anim_pow_2
        ldb   render_flags,u
        andb  #render_xmirror_mask
        beq   >
        ldx   #anim_pow_1
!       clrb
        jsr   AnimateMoveSyncInit
        ldd   y_pos,u
        subd  #4
        std   y_pos,u
        jmp   fly

; ---------------------------------------------------------------------------

destroy 
        jsr   LoadObject_x
        beq   delete
        lda   #ObjID_enemiesblastsmall
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        jsr   LoadObject_x
        beq   delete
        ldb   #ObjID_pow_optionbox
        lda   subtype,u
        asra
        asra
        asra
        asra
        cmpa  #$05
        bne   >
        ldb   #ObjID_bitdevice
!
        stb   id,x
        sta   subtype,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x

delete 
        lda   #alreadyDeletedRtn
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject

alreadyDeleted
        rts

; ---------------------------------------------------------------------------

updateHitbox
        lda   AABB_0+AABB.p,u
        beq   destroy                  ; was killed  

        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        bmi   delete                   ; branch if out of screen's left
                                       ; **** TODO **** implement out of screen's top/left/bottom/right (common code)
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u
        rts

; ---------------------------------------------------------------------------

PresetXYIndex
        INCLUDE "./global/preset-xy.asm"
