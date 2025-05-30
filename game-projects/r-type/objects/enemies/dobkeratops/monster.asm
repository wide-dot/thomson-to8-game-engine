; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/math/rnd.macro.asm"
        INCLUDE "./objects/explosion/explosion.const.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/enemies_properties.asm"

; temporary variables
AABB_0              equ ext_variables   ; AABB struct (9 bytes)
explosion.instances equ dp_extreg+9

rtnid.WaitEndStage equ 5

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Intro
        fdb   WaitExplosions
        fdb   MonsterOut
        fdb   MonsterMouth
        fdb   WaitEndStage

Init
        ; init sprite position
        ldd   #1516
        std   x_pos,u
        ldd   #106
        std   y_pos,u

        ; display priority
        ldb   #7
        stb   priority,u

        ; display settings
        lda   #render_playfieldcoord_mask|render_overlay_mask
        sta   render_flags,u

        ; init animation
        ldd   #360                      ; manual adjustment by video (instead of $200)
        std   anim_frame,u

        ; init image
        ldx   #0
        stx   image_set,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        lda   #dobkeratops_monster_hitdamage
        sta   AABB_0+AABB.p,u
        _ldd  dobkeratops_monster_hitbox_x,dobkeratops_monster_hitbox_y
        std   AABB_0+AABB.rx,u

        inc   routine,u

Intro
        ldd   anim_frame,u
        subd  gfxlock.frameDrop.count_w
        std   anim_frame,u
        cmpd  #$60
        bls   >
        rts
!  
        ; create explosions
        lda   #4
        sta   <explosion.instances
@loop
        jsr   LoadObject_x
        bne   >
        jmp   InstanceEnd
!
        _ldd  ObjID_explosion,explosion.subtype.smallx3
        std   id,x
        _rnda 0,12
        suba  #6
        ldy   x_pos,u
        leay  a,y
        sty   x_pos,x
        jsr   RandomNumber
        _rnda 0,24
        suba  #12
        ldy   y_pos,u
        leay  a,y
        sty   y_pos,x
        dec   <explosion.instances
        bne   @loop
InstanceEnd
        inc   routine,u
        rts

WaitExplosions
        ldb   anim_frame+1,u
        subb  gfxlock.frameDrop.count
        bhi   >
        addb  #$1f
        inc   routine,u
!       stb   anim_frame+1,u
        rts

MonsterOut
        ldb   anim_frame+1,u
        asrb
        asrb
        andb  #%00000110
        ldx   #monster.getout.images
        ldd   b,x
        std   image_set,u
        ldb   anim_frame+1,u
        subb  gfxlock.frameDrop.count
        bhi   >
        inc   routine,u
        ldb   #$c0
!       stb   anim_frame+1,u
        jmp   DisplaySprite

monster.getout.images
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_3
        fdb   Img_dobkeratops_monster_2
        fdb   Img_dobkeratops_monster_1

MonsterMouth
        ldx   gfxlock.frame.count
        cmpx  #timestamp.MOVE_ALIEN_START
        blo   >
        jsr   main.followDobkeratops
        cmpx  #timestamp.MOVE_ALIEN_END
        blo   >
        lda   #rtnid.WaitEndStage
        sta   routine,u
!
WaitEndStage
        lda   gfxlock.frameDrop.count
        ldb   anim_frame+1,u
@loop   decb
        andb  #$7f ; 111 1111
        stb   anim_frame+1,u
        cmpb  #$30 ; 011 0000
        bne   >
        jsr   CreateSawChain
!       deca
        bne   @loop
        andb  #$70 ; 111 0000
        lsrb
        lsrb
        lsrb
        ldx   #monster.fire.images
        ldd   b,x
        std   image_set,u
        jsr   UpdateHitBox
        jmp   DisplaySprite

CreateSawChain
        pshs  d
        jsr   LoadObject_x
        beq   >
        _ldd  ObjID_dobkeratops_saw,0
        sta   id,x
        stb   routine,x
        ldd   x_pos,u
        subd  #6
        std   x_pos,x
        ldd   y_pos,u
        addd  #9
        std   y_pos,x
!       puls  d,pc

monster.fire.images
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_5
        fdb   Img_dobkeratops_monster_6
        fdb   Img_dobkeratops_monster_5
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_4

UpdateHitBox
        lda   AABB_0+AABB.p,u
        beq   DeleteMonster
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u
        rts

DeleteMonster 
        ldd   score
        addd  #dobkeratops_monster_score
        std   score
        jsr   LoadObject_x
        beq   @delete
        _ldd   ObjID_explosion,explosion.subtype.smallx3
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
@delete
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
