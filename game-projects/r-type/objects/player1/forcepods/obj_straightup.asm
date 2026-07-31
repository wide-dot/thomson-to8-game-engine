
; ---------------------------------------------------------------------------
; Object - Weapon - OBSOLETE / PLUS COMPILE
;
; Declare dans aucun game-mode/*/main.*.properties : ni ce fichier ni ses images
; ne sont assembles, et aucun ObjID_forcepod_straightup n'existe. Remplace par
; obj_simplefire.asm, qui couvre les 5 directions de tir du pod detache via son
; subtype (haut / haut-droite / droite / bas-droite / bas).
; ATTENTION si reactivation : le "forcepodaddr equ ext_variables+9" ci-dessous
; est perime, forcepod.asm utilise desormais ext_variables+9 pour mount_side.
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0  equ ext_variables ; AABB struct (9 bytes)
forcepodaddr equ ext_variables+9 ; 2 bytes (MUST START AT 9, DEPENDENCY WITH FORCEPOD OBJ ASM)

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
        ldx   forcepodaddr,u
        ldd   x_pos,x
        std   x_pos,u
        ldd   y_pos,x
        std   y_pos,u
        ldd   #Img_shootup
        std   image_set,u
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        leax  AABB_0,u
        lda   #1                       ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  1,3                      ; set hitbox xy radius
        std   AABB.rx,x

        inc   routine,u

Live
        leax  AABB_0,u        
        lda   AABB.p,x
        beq   @delete                  ; delete weapon if something was hit  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        lda   #8
        ldb   gfxlock.frameDrop.count
        mul
        std   @d
        ldd   y_pos,u
        subd  @d
        std   y_pos,u
        stb   AABB.cy,x
        cmpd  #0                       ; delete weapon if out of screen range
        bge   >
@delete lda   #2
        sta   routine,u   
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        jmp   DeleteObject
!       
        jmp   DisplaySprite
AlreadyDeleted
        rts
@d      fdb   0