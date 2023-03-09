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
        INCLUDE "./objects/animation/anim-data.equ"

AABB_0  equ ext_variables   ; AABB struct (9 bytes)

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
        ldb   subtype,u                ; load x and y pos based on wave parameter
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

        ; todo load fire preset
        ; ...

        ldx   #anim_bug
        ldb   subtype,u
        andb  #$F0
        lsrb
        lsrb
        lsrb
        jsr   AnimateMoveSyncInit

        ldb   #6
        stb   priority,u

        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        leax  AABB_0,u
        lda   #bug_hitdamage
        sta   AABB.p,x
        _ldd  bug_hitbox_x,bug_hitbox_y
        std   AABB.rx,x

        inc   routine,u

Live
        jsr   AnimateMoveSync
        ldx   sub_anim,u
        beq   @delete
        jsr   ObjectMove
;
        leax  AABB_0,u
        lda   AABB.p,x
        beq   @destroy
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
;
        ;ldx   #ImageIndex
        ;ldb   anim_frame,u
        ;lsrb
        ;ldd   b,x
        ldd   #Img_bug_0
        std   image_set,u
;
        jmp   DisplaySprite
@destroy 
        ldd   score
        addd  #bug_score
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
        lda   #2
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts

ImageIndex
        fdb   Img_bug_0
        fdb   Img_bug_1
        fdb   Img_bug_2
        fdb   Img_bug_3
        fdb   Img_bug_4
        fdb   Img_bug_5
        fdb   Img_bug_6
        fdb   Img_bug_7
        fdb   Img_bug_8
        fdb   Img_bug_9
        fdb   Img_bug_10
        fdb   Img_bug_11
        fdb   Img_bug_12
        fdb   Img_bug_13
        fdb   Img_bug_14
        fdb   Img_bug_15

PresetXYIndex
        INCLUDE "./global/preset-xy.asm"
