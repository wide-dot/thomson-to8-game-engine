; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/enemies_properties.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/animation/index.equ"
        INCLUDE "./global/projectile.macro.asm"
        INCLUDE "./objects/explosion/explosion.const.asm"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
bink_0x22         equ ext_variables+9

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   FUN_0000_5e2b_RunBink_Walk
        fdb   FUN_0000_5fa4_RunBink_Fall
        fdb   LAB_0000_60a0_RunBink_StaticAndTrackP1
        fdb   LAB_0000_5ee9_RunBink_StartJumpSequence
        fdb   LAB_0000_5f4d_RunBink_RunJump
        fdb   AlreadyDeleted

Init
        ldb   subtype_w+1,u
        _loadFirePreset

        ldb   subtype_w+1,u
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
        ldb   subtype,u
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
        jmp   LAB_0000_5f9f_RunBink_Fall_Init
LAB_0000_5ee9_RunBink_StartJumpSequence

        jsr   tryFoeFire
        jmp   LAB_0000_5f16
        ldx   #Img_bink_3
        ldb   subtype,u                 ; Same as tst subtype,u
        bne   LAB_0000_5ef8
        ldx   #Img_bink_9
LAB_0000_5ef8
        stx   image_set,u
        lda   AABB_0+AABB.p,u
        lbeq  @destroy                  ; was killed  
        ldb   x_pos+1,u
        subb  glb_camera_x_pos+1
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        lbmi  @delete                  ; branch if out of screen's left
        lda   bink_0x22,u
        suba  gfxlock.frameDrop.count
        bmi   LAB_0000_5f16
        sta   bink_0x22,u
        jmp   DisplaySprite
LAB_0000_5f16
        lda   #4
        sta   routine,u
LAB_0000_5f2e_RunBink_InitJump
        ldx   #anim_19B0A
        lda   subtype,u                 ; Same as tst subtype,u
        bne   LAB_0000_5f3a
        ldx   #anim_19AF8
LAB_0000_5f3a
        lda   #2
        sta   anim_frame_duration,u
        jsr   moveByScript.initialize
        lda   #5
        sta   routine,u
LAB_0000_5f4d_RunBink_RunJump
        jsr   tryFoeFire
        ldd   #binkjumpendcheck
        std   moveByScript.callback
        jsr   moveByScript.runByFrameDrop
        lbcc  LAB_0000_5f9f_RunBink_Fall_Init
        ldx   #ImageIndex+16
        ldb   subtype,u                 ; Same as tst subtype,u
        bne   LAB_0000_5f67
        ldx   #ImageIndex+20
        ldd   x_pos,u
        subd  glb_camera_x_pos
        addd  glb_camera_x_pos_old
        std   x_pos,u
LAB_0000_5f67
        ldb   gfxlock.frame.count+1
        andb  #$08
        bne   LAB_0000_5f72
        leax  2,x
LAB_0000_5f72
        ldd   ,x
        std   image_set,u
        lda   AABB_0+AABB.p,u
        lbeq  @destroy                  ; was killed  
        ldb   x_pos+1,u
        subb  glb_camera_x_pos+1
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        lbmi  @delete                  ; branch if out of screen's left
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        jmp   DisplaySprite
binkjumpendcheck
        lda  moveByScript.anim.end
        beq  >
        clr  moveByScript.anim.loops
!
        rts
FUN_0000_5e2b_RunBink_Walk
        jsr   tryFoeFire
        ldb   #($c0*scale.XP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        _negd
        tst   subtype,u
        beq   LAB_0000_5e40
        _negd
        std   @d
        ldd   x_pos,u
        addd  glb_camera_x_pos
        subd  glb_camera_x_pos_old
        std   x_pos,u
        ldd   #0
@d      equ *-2
LAB_0000_5e40
        jsr   moveXPos8.8
        ldx   #ImageIndex
        ldb   subtype,u                 ; Same as tst subtype,u
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
        bne   >
        lda   #$04
        sta   bink_0x22,u
        sta   routine,u
        jmp   LAB_0000_5ee9_RunBink_StartJumpSequence
!
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
        lbeq  LiveWalk
        lda   #3
        sta   routine,u
        jmp   LAB_0000_60a0_RunBink_StaticAndTrackP1
LAB_0000_5f9f_RunBink_Fall_Init
        lda   #2
        sta   routine,u
FUN_0000_5fa4_RunBink_Fall
        jsr   tryFoeFire
        ldb   gfxlock.frameDrop.count
        cmpb  #3
        ble   >
        ldb   #3
!
        lda   #($03*scale.YP1PX)/256
        mul
        addd  y_pos,u
        std   y_pos,u
        ldx   #ImageIndex+16
        ldb   subtype,u                 ; Same as tst subtype,u
        bne   LAB_0000_5fbd
        ldx   #ImageIndex+20
LAB_0000_5fbd
        ldb   gfxlock.frame.count+1
        andb  #$08
        asrb  
        asrb
        ldd   b,x
        std   image_set,u                 
        lda   AABB_0+AABB.p,u
        lbeq  @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        lbmi  @delete                  ; branch if out of screen's left
        ldd   #($08*scale.XP1PX)/256
        tst   subtype,u
        bne   LAB_0000_6006
        _negd
LAB_0000_6006
        addd  x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        stb   AABB_0+AABB.cy,u
        addd  #($10*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   LAB_0000_601c
        jmp   DisplaySprite
LAB_0000_601c
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
        lda   #1
        sta   routine,u
        jmp   FUN_0000_5e2b_RunBink_Walk
LAB_0000_60a0_RunBink_StaticAndTrackP1
        jsr   tryFoeFire
        ldx   #Img_bink_0
        ldd   player1+x_pos
        cmpd  x_pos,u
        blt   LAB_0000_60bd
        ldx   #Img_bink_6
LAB_0000_60bd
        stx   image_set,u
        lda   AABB_0+AABB.p,u
        beq   @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        jmp   DisplaySprite
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
        _ldd   ObjID_explosion,explosion.subtype.smallx2
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
@delete 
        lda   #6
        sta   routine,u     
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts

ImageIndex
        fdb   Img_bink_0
        fdb   Img_bink_2
        fdb   Img_bink_0
        fdb   Img_bink_1
        fdb   Img_bink_6
        fdb   Img_bink_8
        fdb   Img_bink_6
        fdb   Img_bink_7
        fdb   Img_bink_10
        fdb   Img_bink_11
        fdb   Img_bink_4
        fdb   Img_bink_5

PresetXYIndex
        INCLUDE "./global/preset/18dd0_preset-xy.asm"