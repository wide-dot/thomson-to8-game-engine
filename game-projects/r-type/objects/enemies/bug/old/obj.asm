; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Bug subtype :
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
        INCLUDE "./objects/explosion/explosion.const.asm"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
amplitude         equ ext_variables+9 ; current amplitude
shoottiming       equ ext_variables+11
shoottiming_value equ ext_variables+13
shootnoshoot      equ ext_variables+15
shootdirection    equ ext_variables+16
amplitude_max     equ 60       ; maximum amplitude before direction change

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   LiveUp
        fdb   LiveDown
        fdb   AlreadyDeleted

Init
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        leax  AABB_0,u
        lda   #1                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  5,10                      ; set hitbox xy radius
        std   AABB.rx,x

        ldd   #amplitude_max
        std   amplitude,u
        ldd   #$-A0
        std   x_vel,u
        inc   routine,u
        ldy   #Ani_bug_to_up
        ldx   #$-A0

        lda   subtype,u
        bita  #$01 ; Up or down ?
        bne   >
        ldy   #Ani_bug_to_down
        ldx   #$A0
        inc   routine,u
!
        stx   y_vel,u
        sty   anim,u

        bita  #$02 ; Shoot or no shoot
        bne   >
        clr   shootnoshoot,u ; No shoot, can skip the end about shooting details
        bra   Object
!
        ldb   #1
        stb   shootnoshoot,u

        ldx   #80
        bita  #$04 ; Starts shooting late or early ?
        beq   >
        ldx   #160  ; Starts late
!
        stx   shoottiming,u

        ; This is currently unused, hence set at "less frequently" by default (according to findings on R-Type Dimensions)
        ;ldx   #40  ; Shoots more frequently or less
        ;bita  #$08
        ;beq   >
        ldx   #80  ; Less frequently
;!
        stx   shoottiming_value,u

        asra
        asra
        asra
        asra
        anda  #7
        sta   shootdirection,u

        lbra  Object

LiveUp
        ldd   amplitude,u
        subd  gfxlock.frameDrop.count_w
        std   amplitude,u
        bpl   CheckEOL
        inc   routine,u
        ldd   #amplitude_max
        std   amplitude,u
        ldd   #Ani_bug_up_to_down
        std   anim,u
        ldd   #$A0
        std   y_vel,u

LiveDown
        ldd   amplitude,u
        subd  gfxlock.frameDrop.count_w
        std   amplitude,u
        bpl   CheckEOL
        dec   routine,u
        ldd   #amplitude_max
        std   amplitude,u
        ldd   #Ani_bug_down_to_up
        std   anim,u
        ldd   #$-A0
        std   y_vel,u
        bra   LiveUp

CheckEOL
        lda   shootnoshoot,u
        beq   @noshoot
        ldd   shoottiming,u
        subd  gfxlock.frameDrop.count_w
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
        ldd   score
        addd  #2
        std   score
        jsr   LoadObject_x
        beq   @delete
        _ldd   ObjID_explosion,explosion.subtype.smallx2
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
@delete lda   #3
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts