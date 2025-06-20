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
        INCLUDE "./objects/explosion/explosion.const.asm"

AABB_0                  equ ext_variables   ; AABB struct (9 bytes)

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

        jsr   LoadObject_x
        beq   Init2
	lda   #ObjID_emitter_flash
        sta   id,x
        lda   subtype,u
        sta   subtype,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
Init2
        ldd   #Ani_scantfire_left
        std   anim,u
        lda   subtype,u
        beq   >
        ldd   #Ani_scantfire_right
        std   anim,u
!
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        
        _Collision_AddAABB AABB_0,AABB_list_foefire
        
        leax  AABB_0,u
        lda   #1                                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  14,7                                      ; set hitbox xy radius
        std   AABB.rx,x
        
        inc   routine,u


Live
        ldd   x_pos,u                                   ; set visibility range
        cmpd  glb_camera_x_pos                          ; destroy if out of range
        lble  Delete
        subd  #160-8/2
        cmpd  glb_camera_x_pos
        lbge  Delete

        ldd   x_pos,u
        subd  #14
        std   terrainCollision.sensor.x
        lda   subtype,u
        beq   >
        addd  #28
        std   terrainCollision.sensor.x
!
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   Destroy

        leax  AABB_0,u
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldb   y_pos+1,u
        stb   AABB.cy,x

        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite
        
Destroy

Delete       
        lda   #$02
        sta   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_foefire
        jmp   DeleteObject

AlreadyDeleted
        rts

