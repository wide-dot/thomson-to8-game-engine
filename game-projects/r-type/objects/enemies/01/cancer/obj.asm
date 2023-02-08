; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Patapata subtype :
;       
;       Bit 0 : 0 => Starts up, 1 => Starts down
;       Bit 1 : 0 => Doies not shoot, 1 => Shoots
;       Bit 2 : (Shooting timer) 0 => Shoots early, 1=> Shoot late
;       Bit 3 : (Unused - Shoot frequency) 0 => Shoots fast, 1=> Shoots slow
;       Bit 4-5 :
;             0 -> horizontal
;             1 -> 30% angle (from horizon)
;             2 -> 60% angle (from horizon)
;             3 -> vertical
;       Bit 6 : 0 => kill tracking OFF, 1 => kill tracking ON
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
shoottiming       equ ext_variables+9
shootdirection    equ ext_variables+11



Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   LiveLeft
        fdb   AlreadyDeleted

Init
        ldd   #Ani_cancerleft
        std   anim,u
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        leax  AABB_0,u
        lda   #1                       ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  7,18                      ; set hitbox xy radius
        std   AABB.rx,x

        ldx   #$-10
        stx   x_vel,u
        ldx   #160
        stx   shoottiming,u
        lda   #5
        sta   shootdirection,u

        inc   routine,u

LiveLeft
        ldx   #$-30
        ldy   y_pos,u
        cmpy  player1+y_pos
        bgt   >
        ldx   #$30
!
        stx   y_vel,u

        ldd   shoottiming,u
        subd  Vint_Main_runcount_w
        std   shoottiming,u
        bpl   @noshoot
        ldd   #160
        std   shoottiming,u
        jsr   LoadObject_x
        beq   @noshoot
        lda   #ObjID_foefire
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   shootdirection,u
        jsr   ReturnShootDirection_X
        std   x_vel,x
        lda   shootdirection,u
        jsr   ReturnShootDirection_Y
        std   y_vel,x
@noshoot
        jsr   ObjectMoveSync
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
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
@destroy 
        jsr   LoadObject_x ; make then die early ... to be removed
        beq   @delete
        lda   #ObjID_enemiesblastsmall
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        ldd   x_vel,u
        std   x_vel,x
        clr   y_vel,x
@delete lda   #2
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts