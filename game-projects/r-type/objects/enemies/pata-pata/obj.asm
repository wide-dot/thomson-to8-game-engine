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
        INCLUDE "./objects/animation/index.equ"
        INCLUDE "./global/projectile.macro.asm"
        INCLUDE "./objects/explosion/explosion.const.asm"

AABB_0  equ ext_variables   ; AABB struct (9 bytes)
imgIdx  equ ext_variables+9 ; random number (1 bytes)

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
        addd  #144+8+3 ; 8: left border + 3: (8 px of arcade) see : fc7e MOV word ptr [SI + 0x4],0x2c8
        std   x_pos,u

        lda   subtype_w+1,u
        anda  #$0F
        ldx   #PresetYIndex
        ldb   a,x
        clra
        std   y_pos,u

        ; load fire preset
        ldb   subtype_w+1,u
        _loadFirePreset

        ; display priority
        ldb   #6
        stb   priority,u

        lda   #render_playfieldcoord_mask
        sta   render_flags,u

        ; register hit box
        _Collision_AddAABB AABB_0,AABB_list_ennemy

        lda   #patapata_hitdamage
        sta   AABB_0+AABB.p,u
        _ldd  patapata_hitbox_x,patapata_hitbox_y
        std   AABB_0+AABB.rx,u

        ; init animation script
        ldx   #anim_19ACE
        jsr   moveByScript.initialize

        ; moves skipped frames before object creation
        ldd   #endCheck
        std   moveByScript.callback
        ldb   anim_frame_duration,u ; b is a parameter to runByB, don't throw it before the call
        lda   #2
        sta   anim_frame_duration,u ; now use as animation speed by moveByScript
        jsr   moveByScript.runByB

        ; random init start image
        jsr   RandomNumber
        andb  #%00001110
        sta   imgIdx,u

        inc   routine,u
        bra   >
Live
        ldd   #endCheck
        std   moveByScript.callback
        jsr   moveByScript.runByFrameDrop
!       lda   moveByScript.anim.end
        bne   @delete
;
        jsr   tryFoeFire
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
        ldb   imgIdx,u
        incb
        stb   imgIdx,u
        andb  #%00001110
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
        _ldd   ObjID_explosion,explosion.subtype.smallx2
        std   id,x
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

endCheck
        lda   moveByScript.anim.end
        beq   >
        clr   moveByScript.anim.loops  ; exit parent loop
!       rts

ImageIndex
        fdb   Img_patapata_0
        fdb   Img_patapata_1
        fdb   Img_patapata_2
        fdb   Img_patapata_3
        fdb   Img_patapata_4
        fdb   Img_patapata_5
        fdb   Img_patapata_6
        fdb   Img_patapata_7

PresetYIndex ; 0x18db0
        INCLUDE "./global/preset/18db0_preset-y.asm"
