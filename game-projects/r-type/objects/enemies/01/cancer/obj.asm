; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Patapata subtype :
;       
;       Bit 0,1 :
;               0 => Track on player 1
;               1 => Go up for a while then track player 1
;               2 => Go down for a while then track player 1
;       Bit 2 : 0 => Slower, 1 => Faster (horizontal speed)
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
shoottiming       equ ext_variables+9
shootdirection    equ ext_variables+11
deviation         equ ext_variables+12



Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   LiveLeft
        fdb   LiveUpOrDown
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

        ldx   #160
        stx   shoottiming,u
        lda   #5
        sta   shootdirection,u

        lda   subtype,u       

        ldx   #$-20                         
        bita  #04                       ; Horizontal speed ... fast or slow
        bne   >
        ldx   #$-10                     ; Sloooooooow
!
        stx   x_vel,u

        inc   routine,u
        anda  #03
        beq   LiveLeft

        ldb   #60
        stb   deviation,u
        inc   routine,u

        ldx   #$-30
        bita  #$2
        beq   >
        ldx   #$30
!
LiveUpOrDown
        dec   deviation,u
        bpl   >
        lda   #01
        sta   routine,u


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
@delete 
        lda   #3
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts