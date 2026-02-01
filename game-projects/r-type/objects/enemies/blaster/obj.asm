; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Blaster subtype :
;       
;       Bit 0, 1, 2, 3 => Y pos (29, 41, 53, 147, 159, 171)
;       Bit 4, 5, 6, 7 => Shoot timing (0 = no shoot, 1 = every 2s, 2 = every 1.5s, 3 = every 1s)
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/enemies_properties.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./global/projectile.macro.asm"
        INCLUDE "./objects/explosion/explosion.const.asm"

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
        ldb   subtype_w+1,u
        _loadFirePreset

        ldb   subtype_w+1,u
        andb  #$0F
        ldx   #PresetYIndex
        clra
        ldb   b,x
        bmi   >
        ldx   #UpperBlasterSpriteTable
        std   y_pos,u
        bra   @end
!       ldx   #LowerBlasterSpriteTable
        std   y_pos,u
@end    stx   anim,u

        ldb   #6
        stb   priority,u

        ldd   glb_camera_x_pos
        addd  #144+10
        std   x_pos,u

        lda   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        lda   #blaster_hitdamage
        sta   AABB_0+AABB.p,u
        _ldd  blaster_hitbox_x,blaster_hitbox_y
        std   AABB_0+AABB.rx,u

        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u

        inc   routine,u

Live
        lda   AABB_0+AABB.p,u
        beq   @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #4                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
;
        ldx   #player1
        jsr   setDirectionTo
        tfr   y,d
        asrb
        ldx   anim,u
        ldd   b,x
        std   image_set,u
        jsr   tryFoeFire
;
        jmp   DisplaySprite
@destroy
        ldd   score
        addd  #blaster_score
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
        inc   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts

LowerBlasterSpriteTable
        fdb   Img_blaster_l3 ; 0x00
        fdb   Img_blaster_l4 ; 0x04
        fdb   Img_blaster_l4 ; 0x08
        fdb   Img_blaster_l4 ; 0x0c
        fdb   Img_blaster_l5 ; 0x10
        fdb   Img_blaster_l5 ; 0x14
        fdb   Img_blaster_l5 ; 0x18
        fdb   Img_blaster_l5 ; 0x1c
        fdb   Img_blaster_l5 ; 0x20
        fdb   Img_blaster_l1 ; 0x24
        fdb   Img_blaster_l1 ; 0x28
        fdb   Img_blaster_l1 ; 0x2c
        fdb   Img_blaster_l1 ; 0x30
        fdb   Img_blaster_l2 ; 0x34
        fdb   Img_blaster_l2 ; 0x38
        fdb   Img_blaster_l2 ; 0x3c

UpperBlasterSpriteTable
        fdb   Img_blaster_u5 ; 0x00
        fdb   Img_blaster_u1 ; 0x04
        fdb   Img_blaster_u1 ; 0x08
        fdb   Img_blaster_u1 ; 0x0c
        fdb   Img_blaster_u1 ; 0x10
        fdb   Img_blaster_u2 ; 0x14
        fdb   Img_blaster_u2 ; 0x18
        fdb   Img_blaster_u2 ; 0x1c
        fdb   Img_blaster_u3 ; 0x20
        fdb   Img_blaster_u4 ; 0x24
        fdb   Img_blaster_u4 ; 0x28
        fdb   Img_blaster_u4 ; 0x2c
        fdb   Img_blaster_u5 ; 0x30
        fdb   Img_blaster_u5 ; 0x34
        fdb   Img_blaster_u5 ; 0x38
        fdb   Img_blaster_u5 ; 0x3c

PresetYIndex ; 0x1930c
        INCLUDE "./global/preset/1930c_preset-y.asm"
