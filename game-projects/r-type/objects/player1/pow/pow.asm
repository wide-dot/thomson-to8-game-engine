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
        INCLUDE "./objects/animation/index.equ"
        INCLUDE "./objects/explosion/explosion.const.asm"

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
        stb   subtype,u                ; saving subtype 16 bits to subtype 8 bits to leave room for render flag
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
        ldx   #anim_19A96
        cmpb  #8+6                       ; 16px in arcade (position $150) 5a08 CMP word ptr [SI + 0x4],0x150
        bhs   >
        ldx   #anim_19AA2
        ora   #status_xflip_mask
!       sta   status_flags,u
        jsr   moveByScript.initialize

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

        ; moves skipped frames before object creation
        ldd   #flyStep
        std   moveByScript.callback
        ldb   anim_frame_duration,u ; set by wave loader to give missed frames at object creation
        lda   #2
        sta   anim_frame_duration,u ; now use as animation speed by moveByScript
        jsr   moveByScript.runByB
        jsr   updateHitbox
        jmp   DisplaySprite

; ---------------------------------------------------------------------------

fall
        lda   gfxlock.frameDrop.count  
        deca
        sta   glb_d0_b
!       ldd   y_pos+1,u
        addd  #$00C0 ; 1px * 3/4
        std   y_pos+1,u
        jsr   flyStep
        dec   glb_d0_b
        bpl   <
        jsr   updateHitbox
        jmp   DisplaySprite

; ---------------------------------------------------------------------------

fly
        ldd   #flyStep
        std   moveByScript.callback
        jsr   moveByScript.runByFrameDrop
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
        ldd   #0
        std   prev_anim,u
        stb   anim_frame_duration,u
        lda   #landRtn                 ; set landing routine
        sta   routine,u
        stb   moveByScript.anim.loops  ; exit parent loop
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
@fall   lda   #fallRtn
        cmpa  routine,u
        beq   @rts                     ; not an exit point if already falling
        sta   routine,u
        clr   moveByScript.anim.loops  ; exit parent loop
@rts    rts
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
        ldd   #0
        std   prev_anim,u
        stb   anim_frame_duration,u
        lda   #walkRtn
        sta   routine,u

        ldx   #scale.XN1PX
        ldb   render_flags,u
        andb  #render_xmirror_mask
        beq   >
        ldx   #scale.XP1PX
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
        ldd   #0
        std   prev_anim,u
        stb   anim_frame_duration,u
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
        jsr   updateHitbox
        jsr   AnimateSpriteSync ; routine incremented at the end of animation
        jmp   DisplaySprite

; ---------------------------------------------------------------------------

initfly
        lda   #flyRtn
        sta   routine,u
        ldd   #Img_pow_fly
        std   image_set,u

        ldx   #anim_19AA2
        ldb   render_flags,u
        andb  #render_xmirror_mask
        beq   >
        ldx   #anim_19AB2
!       jsr   moveByScript.initialize
        ldd   y_pos,u
        subd  #4
        std   y_pos,u
        lda   #2                    ; was used by AnimateSpriteSync
        sta   anim_frame_duration,u ; now use as animation speed by moveByScript
        jmp   fly

; ---------------------------------------------------------------------------

destroy 
        jsr   LoadObject_x
        beq   delete
        _ldd   ObjID_explosion,explosion.subtype.smallx2
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        jsr   LoadObject_x
        beq   delete
        ldb   #ObjID_pow_optionbox
        lda   subtype,u
        lsra                            ; option box type is on bits 4,5,6,7 of the subtype
        lsra                            ; hence shifting everything to the right 4 times
        lsra                            
        lsra                
        cmpa  #$05                      ; $05 is a bit device, not an option box
        bne   >
        ldb   #ObjID_bitdevice          ; set the bit device object ID instead
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
        leas  2,s                      ; will exit object's code instead of just returning to updateHitbox
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
        addd  #5
        bmi   delete                   ; branch if out of screen's left
        subd  #144+5*2+10              ; +10 is a guess value
        bpl   delete                   ; branch if out of screen's right

        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u
        rts

; ---------------------------------------------------------------------------

PresetXYIndex
        INCLUDE "./global/preset/18dd0_preset-xy.asm"
