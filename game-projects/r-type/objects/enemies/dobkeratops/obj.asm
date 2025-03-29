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
        INCLUDE "./objects/enemies_properties.asm"

AABB_0  equ ext_variables   ; AABB struct (9 bytes)

rtnid.DeleteEye equ 3

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Run
        fdb   RunEyes
        fdb   DeleteEye

Init
        ; init sprite position
        ldd   #1507
        std   x_pos,u
        ldd   #100
        std   y_pos,u

        ; reinit wave frame drop that share the same position as anim_frame_duration
        clr   anim_frame_duration,u

        ; display priority and setup image
        ldd   subtype,u
        stb   priority,u
        ldx   #SubImages
        asla
        ldx   a,x
        stx   image_set,u

        ; display settings
        lda   #render_playfieldcoord_mask|render_xloop_mask
        ldb   subtype,u
        cmpb  #4
        blo   @orbit
        cmpb  #8
        blo   > ; forground orbits and nerves with dedicated sprites (others are in the background)
         ; alien background
        ora   #render_overlay_mask
!       sta   render_flags,u
@end    inc   routine,u
        jmp   DisplaySprite
@orbit
        ; four orbits
        inc   routine,u
        ora   #render_overlay_mask
        sta   render_flags,u
        _Collision_AddAABB AABB_0,AABB_list_ennemy
        lda   #dobkeratops_eye_hitdamage ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  dobkeratops_eye_hitbox_x,dobkeratops_eye_hitbox_y ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        ldx   #AABBOffsets
        ldb   subtype,u
        aslb
        aslb
        abx
        ldd   x_pos,u
        subd  glb_camera_x_pos
        addd  ,x
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        subd  glb_camera_y_pos
        addd  2,x
        stb   AABB_0+AABB.cy,u
        bra   @end

SubImages
        fdb   0 ; no image at startup for eraser 0
        fdb   0 ; no image at startup for eraser 1
        fdb   0 ; no image at startup for eraser 2
        fdb   0 ; no image at startup for eraser 3

        fdb   Img_dobkeratops_eye10
        fdb   Img_dobkeratops_eye30
        fdb   Img_dobkeratops_eye31
        fdb   Img_dobkeratops_eye32

        fdb   Img_dobkeratops_alienN0
        fdb   Img_dobkeratops_alienN1
        fdb   Img_dobkeratops_alienN2
        fdb   Img_dobkeratops_alienN3
        fdb   Img_dobkeratops_alienN4

AABBOffsets
        fdb   -32,-60
        fdb     1,-12
        fdb     1,24
        fdb   -32,64

Run
        jmp   DisplaySprite

RunEyes
        lda   AABB_0+AABB.p,u
        beq   @erase
        ldx   #AABBOffsets
        ldb   subtype,u
        aslb
        aslb        
        abx
        ldd   x_pos,u
        subd  glb_camera_x_pos
        addd  ,x
        stb   AABB_0+AABB.cx,u
        jmp   DisplaySprite
@erase
        ; score update
        ldd   score
        addd  #dobkeratops_eye_score
        std   score
        ; create explosion
        jsr   LoadObject_x
        beq   > ; branch if no more free object slot
        ; init explosion properties
        _ldd   ObjID_explosion,explosion.subtype.smallx2
        std   id,x
        ldy   #AABBOffsets
        ldb   subtype,u
        aslb
        aslb
        leay  b,y
        ldd   x_pos,u
        addd  ,y
        std   x_pos,x
        ldd   y_pos,u
        addd  2,y
        std   y_pos,x
!       lda   #rtnid.DeleteEye
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        ; create a new eraser object with one frame ahead for double buffering
        jsr   LoadObject_x
        beq   > ; branch if no more free object slot
        ldd   id,u ; id and subtype
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   priority,u
        sta   priority,x
        lda   render_flags,u
        sta   render_flags,x
        lda   routine,u
        sta   routine,x
        clr   anim_frame_duration,x
!       rts
DeleteEye  
        ldb   subtype,u
        ldx   #EraserImages
        aslb
        ldx   b,x         ; get animation list for this subtype
        lda   anim_frame,u
        asla
        ldd   a,x         ; get current frame
        cmpd  #-1
        beq   @end
        std   image_set,u ; update image
        inc   anim_frame,u
        jmp   DisplaySprite
@end    jmp   DeleteObject

EraserImages
        fdb   EraserImages0
        fdb   EraserImages1
        fdb   EraserImages2
        fdb   EraserImages3

EraserImages0
        fdb   Img_dobkeratops_erase0_0
        fdb   Img_dobkeratops_erase0_1
        fdb   Img_dobkeratops_erase0_2
        fdb   Img_dobkeratops_erase0_3
        fdb   Img_dobkeratops_erase0_4
        fdb   Img_dobkeratops_erase0_5
        fdb   Img_dobkeratops_erase0_6
        fdb   Img_dobkeratops_erase0_7
        fdb   Img_dobkeratops_erase0_8
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   Img_dobkeratops_erase0_9
        fdb   Img_dobkeratops_erase0_10
        fdb   Img_dobkeratops_erase0_11
        fdb   Img_dobkeratops_erase0_12
        fdb   Img_dobkeratops_erase0_13
        fdb   Img_dobkeratops_erase0_14
        fdb   Img_dobkeratops_erase0_15
        fdb   -1 ; end of list
        
EraserImages1
        fdb   Img_dobkeratops_erase1_0
        fdb   Img_dobkeratops_erase1_1
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   Img_dobkeratops_erase1_2
        fdb   Img_dobkeratops_erase1_3
        fdb   Img_dobkeratops_erase1_4
        fdb   Img_dobkeratops_erase1_5
        fdb   Img_dobkeratops_erase1_6
        fdb   Img_dobkeratops_erase1_7
        fdb   Img_dobkeratops_erase1_8
        fdb   Img_dobkeratops_erase1_9
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   Img_dobkeratops_erase1_10
        fdb   Img_dobkeratops_erase1_11
        fdb   -1 ; end of list

EraserImages2
        fdb   -1 ; end of list
        
EraserImages3
        fdb   -1 ; end of list
