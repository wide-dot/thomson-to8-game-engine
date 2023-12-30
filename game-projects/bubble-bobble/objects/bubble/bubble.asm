; ---------------------------------------------------------------------------
; Object - Bubble
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm" 
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

Init_routine           equ 0
Live_routine           equ 1
Explode_routine        equ 2
Delete_routine         equ 3
AlreadyDeleted_routine equ 4

AABB_0            equ ext_variables   ; AABB struct (9 bytes)

Bubble
        lda   routine,u
        asla
        ldx   #Bubble_Routines
        jmp   [a,x]

Bubble_Routines
        fdb   Init      
        fdb   Live
        fdb   Explode
        fdb   Delete
        fdb   AlreadyDeleted

Init
        ldb   #$05
        stb   priority,u

        lda   render_flags,u
        ora   #render_playfieldcoord_mask        
        sta   render_flags,u

        lda   status_flags,u
        ora   #status_xflip_mask
        sta   status_flags,u

        lda   subtype,u
        cmpa  #5
        blo   >
        inca                           ; space between words
!       ldb   #10
        mul
        addd  #30
        std   x_pos,u
        ldd   #24
        std   y_pos,u

        jsr   RandomNumber
        std   y_acl,u

        ldx   #bubble.images
        lda   subtype,u
        asla
        ldd   a,x
        std   image_set,u

        lda   #1                       ; hitbox potential
        sta   AABB_0+AABB.p,u
        _ldd  4,8                     ; hitbox xy radius
        std   AABB_0+AABB.rx,u         ; and ry

        _Collision_AddAABB AABB_0,AABB_list_bubble

        lda   #Live_routine
        sta   routine,u

Live
        lda   AABB_0+AABB.p,u
        bne   >
        ldd   #Ani_Explode
        std   anim,u
        lda   #Explode_routine
        sta   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_bubble
        dec   main.object.count
        bra   Explode
!
        ldb   y_acl,u
        addb  #4
        stb   y_acl,u
        jsr   CalcSine
        _asrd
        _asrd
        addd  y_pos+1,u
        std   y_pos+1,u

        ; update hitbox position
        ldd   x_pos,u
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        stb   AABB_0+AABB.cy,u
        jmp   DisplaySprite

Explode
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

Delete
        jmp   DeleteObject

AlreadyDeleted
        rts

bubble.images
        fdb   Img_Bubble_001
        fdb   Img_Bubble_002
        fdb   Img_Bubble_003
        fdb   Img_Bubble_004
        fdb   Img_Bubble_005
        fdb   Img_Bubble_006
        fdb   Img_Bubble_007
        fdb   Img_Bubble_008
        fdb   Img_Bubble_009
        fdb   Img_Bubble_010