; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Bink subtype :
;
;       Bit 1 : (Shooting timer) 0 => Shoots early, 1=> Shoot late
;       Bit 2 : (Unused - Shoot frequency) 0 => Shoots fast, 1=> Shoots slow
;       Bit 3-4 :
;             0 -> horizontal
;             1 -> 30% angle (from horizon)
;             2 -> 60% angle (from horizon)
;             3 -> vertical
;       Bit 5 : 0 => kill tracking OFF, 1 => kill tracking ON
;       Bit 6,7 : 
;                0 => Walks left 
;                1 => Walks right
;                2 => Falls left
;                3 => Falls right
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
shoottiming       equ ext_variables+9
shoottiming_value equ ext_variables+11
shootnoshoot      equ ext_variables+13
shootdirection    equ ext_variables+14

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   LiveWalk
        fdb   LiveFall
        fdb   AlreadyDeleted

Init
        ldd   #Ani_bink_left
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
        _ldd  6,13                      ; set hitbox xy radius
        std   AABB.rx,x
        
        ldd   #$-40
        std   x_vel,u
        inc   routine,u
        lda   subtype,u

        bita  #128                      ; Walks or falls ?
        beq   >
        inc   routine,u                 ; Falls
        ldx   #Ani_bink_falls_left
        stx   anim,u
        clr   x_vel,u
        ldx   #$100
        stx   y_vel,u
!
        bita  #$01 ; Shoot or no shoot
        bne   >
        clr   shootnoshoot,u ; No shoot, can skip the end about shooting details
        bra   Object
!
        ldb   #1
        stb   shootnoshoot,u

        ldx   #120
        bita  #$02 ; Starts shooting late or early ?
        beq   >
        ldx   #240  ; Starts late
!
        stx   shoottiming,u

        ; This is currently unused, hence set at "less frequently" by default (according to findings on R-Type Dimensions)
        ;ldx   #60  ; Shoots more frequently or less
        ;bita  #$04
        ;beq   >
        ldx   #120  ; Less frequently
;!
        stx   shoottiming_value,u

        asra
        asra
        asra
        anda  #7
        sta   shootdirection,u
        jmp   Object

LiveFall
        ldx   Vint_Main_runcount_w
        stx   x_vel,u
        ldx   y_pos,u
        cmpx  #138
        ble   >
        ldx   #138
        stx   y_pos,u
        clr   y_vel,u
        ldx   #Ani_bink_stands_left
        stx   anim,u
!
LiveWalk
        lda   shootnoshoot,u
        beq   @noshoot
        ldd   shoottiming,u
        subd  Vint_Main_runcount_w
        std   shoottiming,u
        bpl   @noshoot
        ldd   shoottiming_value,u
        std   shoottiming,u
        jsr   LoadObject_x ; PatapataShoot
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
        beq   @dstroy                  ; was killed  
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
@dstroy 
        ldd   score
        addd  #200
        std   score
        jsr   LoadObject_x
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
@delete 
        lda   #03
        sta   routine,u     
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts
