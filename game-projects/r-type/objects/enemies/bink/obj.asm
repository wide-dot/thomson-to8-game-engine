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

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
shoottiming       equ ext_variables+9
shoottiming_value equ ext_variables+11
shootnoshoot      equ ext_variables+13
shootdirection    equ ext_variables+14

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   LiveWalkLeft
        fdb   LiveWalkRight
        fdb   LiveFallsLeft
        fdb   LiveFallsRight
        fdb   LiveJumpLeft
        fdb   LiveJumpRight
        fdb   AlreadyDeleted

Init
        ldb   subtype_w+1,u            ; load x and y pos based on wave parameter
        andb  #$0F
        aslb
        ldx   #PresetXYIndex
        abx
        clra
        ldb   1,x
        addb  #$6
        std   y_pos,u
        ldb   ,x
        addd  glb_camera_x_pos
        std   x_pos,u

        ; set subtype based on preset

        ldb   subtype+1,u
        stb   subtype,u

        ldb   #6
        stb   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        leax  AABB_0,u
        lda   #1                       ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  6,13                      ; set hitbox xy radius
        std   AABB.rx,x

        ; test if bink is spawned airborn
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #13
        std   terrainCollision.sensor.y
        jsr   terrainCollision.do
        tstb
        bne   >

        ; bink is airborn

        ldd   #Ani_bink_falls_left
        std   anim,u
        ldd   #$10
        std   y_vel,u
        lda   #3
        sta   routine,u
        jmp   Object
!

        ldd   #Ani_bink_left
        std   anim,u
        ldd   #$-40
        std   x_vel,u
        inc   routine,u
        clr   shootnoshoot,u ; No shoot, can skip the end about shooting details
        jmp   Object
LiveWalkLeft
        ldd   x_pos,u
        subd  #6
        std   terrainCollision.sensor.x
        subd  glb_camera_x_pos
        subd  #8
        bmi   LiveWalk
        ldd   y_pos,u
        addd  #12
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   LiveWalk
        ldd   #Ani_bink_right
        std   anim,u
        ldd   #$60
        std   x_vel,u
        inc   routine,u
        bra   LiveWalk
LiveWalkRight
        ldd   x_pos,u
        addd  #6
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #12
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   LiveWalk
        ldd   #Ani_bink_left
        std   anim,u
        ldd   #$-40
        std   x_vel,u
        dec   routine,u

LiveWalk
        lda   shootnoshoot,u
        beq   @noshoot
        ldd   shoottiming,u
        subd  gfxlock.frameDrop.count_w
        std   shoottiming,u
        bpl   @noshoot
        ldd   shoottiming_value,u
        std   shoottiming,u
        jsr   LoadObject_x
        beq   @noshoot
        lda   #ObjID_foefire
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   shootdirection,u
        jsr   ReturnShootDirection_X
        std   x_vel,x
        lda   shootdirection,u
        jsr   ReturnShootDirection_Y
        std   y_vel,x
@noshoot
        jsr   ObjectMoveSync
        leax  AABB_0,u
        lda   AABB.p,x
        beq   @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        addd  #5                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        ldb   y_pos+1,u
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
@destroy 
        ldd   score
        addd  #2
        std   score
        jsr   LoadObject_x
        beq   @delete
        lda   #ObjID_enemiesblastsmall
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        ldd   x_vel,u
        std   x_vel,x
        clr   y_vel,x
@delete 
        lda   #7
        sta   routine,u     
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
LiveFallsLeft
        jsr   ObjectMoveSync
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #14
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   >
        ; not on the ground yet ...
        leax  AABB_0,u
        lda   AABB.p,x
        lbeq  @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        addd  #5                       ; add x radius
        lbmi  @delete                  ; branch if out of screen's left
        ldb   y_pos+1,u
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
!
        ldd   #Ani_bink_left
        std   anim,u
        ldd   #$-40
        std   x_vel,u
        lda   #1
        sta   routine,u
        ldd   #0
        std   y_vel,u
        _breakpoint
        ldx   #PresetXYIndex+1
        ldb   y_pos+1,u
!
        cmpb  ,x
        blo   >
        leax  2,x
        bra   <
!
        ldb   -2,x
        addb  #$6
        stb   y_pos+1,u
        jmp   LiveWalkLeft
LiveFallsRight
        rts
LiveJumpLeft
        rts
LiveJumpRight
        rts
AlreadyDeleted
        rts

PresetXYIndex
        INCLUDE "./global/preset-xy.asm"
