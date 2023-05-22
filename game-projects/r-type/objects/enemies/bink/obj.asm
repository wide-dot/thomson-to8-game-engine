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
        INCLUDE "./objects/enemies_properties.asm"

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
        fdb   FUN_0000_5e2b_RunBink_Walk
        fdb   RunBink_Fall
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
        std   y_pos,u
        ldb   ,x
        addd  glb_camera_x_pos
        std   x_pos,u

        ldb   subtype+1,u
        andb  #$01
        stb   subtype,u

        ; set subtype based on preset

        ldb   #6
        stb   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        lda   #bink_hitdamage                   ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  bink_hitbox_x,bink_hitbox_y       ; set hitbox xy radius
        std   AABB_0+AABB.rx,u

        ; test if bink is spawned airborn

        tst   subtype,u
        bne   Initright

        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #13
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   >

        ; bink is airborn

        ldd   #Ani_bink_falls_left
        std   anim,u
        lda   #2
        sta   routine,u
        jmp   Object
!
        inc   routine,u
        clr   shootnoshoot,u ; No shoot, can skip the end about shooting details
        jmp   Object

Initright

        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #13
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   >

        ; bink is airborn

        ldd   #Ani_bink_falls_right
        std   anim,u
        lda   #2
        sta   routine,u
        jmp   Object
!
        inc   routine,u
        clr   shootnoshoot,u ; No shoot, can skip the end about shooting details
        jmp   Object

FUN_0000_5e2b_RunBink_Walk
        ldb   #($c0*scale.XP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        tst   subtype,u
        bne   LAB_0000_5e40
        _negd
        addd  gfxlock.frameDrop.count_w
LAB_0000_5e40
        jsr   MoveXPos8.8
        ldx   #ImageIndex
        tst   subtype,u
        beq   LAB_0000_5e4f
        ldx   #ImageIndex+8
LAB_0000_5e4f
        ldb   gfxlock.frame.count+1
        andb  #$18
        asrb  
        asrb
        ldd   b,x
        std   image_set,u                 
        ldd   x_pos,u                   ; Disables terrain detection if in black border
        subd  glb_camera_x_pos
        subd  #8
        lbmi  LiveWalk                  ; In black border, no detection
LAB_0000_5e7d
        ldd   x_pos,u
        subd  #($10*scale.XP1PX)/256
        tst   subtype,u
        beq   LAB_0000_5e88
        addd  #(($10*scale.XP1PX)/256)*2
LAB_0000_5e88
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #($14*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   RunBink_InititiateJump
        ldd   x_pos,u
        subd  #($12*scale.XP1PX)/256                    
        tst   subtype,u
        beq   LAB_0000_5eb8
        addd  #(($12*scale.XP1PX)/256)*2
LAB_0000_5eb8
        std   terrainCollision.sensor.x
        subd  glb_camera_x_pos
        subd  #8
        lbmi  LiveWalk                 ; Test if terrain collision is in black border
        ldd   y_pos,u
        addd  #($0c*scale.XP1PX)/256
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   RunBink_ChangeDirection
        bra   LiveWalk
RunBink_InititiateJump
RunBink_ChangeDirection
        ldb   #$01
        tst   subtype,u
        beq   >
        clrb
!
        stb   subtype,u
LiveWalk
        lda   AABB_0+AABB.p,u
        beq   @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        jmp   DisplaySprite
@destroy 
        ldd   score
        addd  #bink_score
        std   score
        jsr   LoadObject_x
        beq   @delete
        lda   #ObjID_enemiesblastsmall
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
@delete 
        lda   #5
        sta   routine,u     
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
RunBink_Fall
        lda   AABB_0+AABB.p,u
        lbeq  @destroy                  ; was killed  
        jsr   ObjectMoveSync
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   gfxlock.frame.count
        cmpd  #3
        ble   >
        ldd   #3
!
        addd  y_pos,u
        std   y_pos,u
        addd  #13
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   >
        ; not on the ground yet ...
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        lbmi  @delete                  ; branch if out of screen's left
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
!
        lda   #1
        sta   routine,u
        lda   y_pos+1,u
                                        ; This is how sam divides by 6
        nega
        adda  #6
        ldb   #85
        mul
        lsra
        ldb   #6
        mul
        negb                            
                                        ; This was how sam divided by 6
        stb   y_pos+1,u
        jmp   FUN_0000_5e2b_RunBink_Walk
LiveJumpLeft
        rts
LiveJumpRight
        rts
AlreadyDeleted
        rts

ImageIndex
        fdb   Img_bink_3
        fdb   Img_bink_2
        fdb   Img_bink_3
        fdb   Img_bink_1
        fdb   Img_bink_9
        fdb   Img_bink_8
        fdb   Img_bink_9
        fdb   Img_bink_7

        INCLUDE "./global/MoveXPos8.8.asm"

PresetXYIndex
        INCLUDE "./global/preset-xy.asm"