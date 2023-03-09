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
        INCLUDE "./objects/animation/anim-data.equ"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)

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

        ldx   #anim_pow
        ldb   #0
        jsr   AnimateMoveSyncInit

        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        leax  AABB_0,u
        lda   #1                                                       ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  5,10                                                     ; set hitbox xy radius
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
        beq   @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        addd  #5                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
;
        ;ldx   #ImageIndex
        ;ldb   anim_frame,u
        ;andb  #$c
        ;ldd   b,x
        ldd   #Img_pow_0
        std   image_set,u
        jmp   DisplaySprite
@destroy 
        jsr   LoadObject_x
        beq   @delete
        lda   #ObjID_enemiesblastsmall
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        jsr   LoadObject_x
        beq   @delete
        lda   #ObjID_pow_optionbox
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   subtype,u
        sta   subtype,x
@delete lda   #2
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts

ImageIndex
        fdb   Img_pow_1
        fdb   Img_pow_2
        fdb   Img_pow_3
        fdb   Img_pow_4
        fdb   Img_pow_5
        fdb   Img_pow_0
        fdb   Img_pow_0

PresetXYIndex
        INCLUDE "./global/preset-xy.asm"
