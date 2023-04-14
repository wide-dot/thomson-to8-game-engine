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
        ldd   glb_camera_x_pos
        addd  #144+12
        std   x_pos,u

        lda   subtype_w+1,u
        anda  #$0F
        ldx   #PresetYIndex
        ldb   a,x
        clra
        std   y_pos,u

        ; todo load fire preset
        ; ...

        ldx   #anim_patapata
        clrb
        jsr   AnimateMoveSyncInit

        ; moves skipped frames before object creation
        ldb   anim_frame_duration,u
        jsr   AnimateMoveSteps

        ldb   #6
        stb   priority,u

        lda   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        lda   #patapata_hitdamage
        sta   AABB_0+AABB.p,u
        _ldd  patapata_hitbox_x,patapata_hitbox_y
        std   AABB_0+AABB.rx,u

        inc   routine,u

Live
        jsr   AnimateMoveSync
        ldx   sub_anim,u
        beq   @delete
        jsr   ObjectMove
;
        lda   AABB_0+AABB.p,u
        beq   @destroy
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u
;
        ldx   #ImageIndex
        ldb   anim_frame,u
        addb  gfxlock.frame.count+1
        andb  #$1C
        lsrb
        ldd   b,x
        std   image_set,u
;
        jmp   DisplaySprite
@destroy 
        ldd   score
        addd  #patapata_score
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
        fdb   Img_patapata_0
        fdb   Img_patapata_1
        fdb   Img_patapata_2
        fdb   Img_patapata_3
        fdb   Img_patapata_4
        fdb   Img_patapata_5
        fdb   Img_patapata_6
        fdb   Img_patapata_7


PresetShooting
        fdb   $0000,$0000,$0000
        fdb   $00C0,$0140,$8FD0
        fdb   $0080,$0100,$9010
        fdb   $0080,$00C0,$9010
        fdb   $0040,$0080,$9050
        fdb   $0040,$0060,$9050
        fdb   $0030,$0050,$9090
        fdb   $0018,$0030,$90D0
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90

PresetYIndex
        INCLUDE "./objects/enemies/01/pata-pata/preset-y.asm"
