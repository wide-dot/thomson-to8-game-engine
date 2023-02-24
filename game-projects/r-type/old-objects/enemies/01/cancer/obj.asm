; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Cancer subtype :
;
;      bit 0 : 0 => Starts up, 1 => Starts down
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0                  equ ext_variables   ; AABB struct (9 bytes)
shoottiming             equ ext_variables+9
shootdirection          equ ext_variables+11
wanderdirection         equ ext_variables+12
verticalspeedpos        equ $50
verticalspeedneg        equ $-50



Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   LiveUpOrDown
        fdb   LiveLeft
        fdb   LiveRight
        fdb   AlreadyDeleted

Init
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

        inc   routine,u     

        ldy   #Ani_cancerleft
        ldx   #$-10
        ldd   x_pos,u
        cmpd  player1+x_pos
        bgt   >
        ldy   #Ani_cancerright
        ldx   #$30
!
        sty   anim,u
        stx   x_vel,u
        lda   subtype,u  
        ldx   #verticalspeedneg
        bita  #$1
        beq   >
        ldx   #verticalspeedpos
!
        stx   y_vel,u

LiveUpOrDown

        ldd   x_pos,u
        subd  #70                      
        cmpd  player1+x_pos
        bgt   >
        inc   routine,u                 ; Getting close to player1, let's enter tracking mode
        bra   Live
!
        ldd   y_pos,u
        cmpd  #28
        bge   >                         
        ldd   #$30                      ; Too high, let's bounce it
        std   y_vel,u
        jmp   @noshoot
!
        cmpd  #130
        lble  @noshoot
        ldd   #$-30                     ; Too low, let's bounce it
        std   y_vel,u
        jmp   @noshoot
LiveLeft
        ldd   x_pos,u
        cmpd  player1+x_pos
        bgt   Live
        ldy   #Ani_cancerright
        ldx   #$40        
        sty   anim,u
        stx   x_vel,u
        lda   #3
        sta   routine,u
        bra   Live
LiveRight
        ldd   x_pos,u
        cmpd  player1+x_pos
        blt   Live
        ldy   #Ani_cancerleft
        ldx   #$-10
        sty   anim,u
        stx   x_vel,u
        lda   #2
        sta   routine,u
        bra   Live
Live
        ldx   #verticalspeedneg
        ldy   y_pos,u
        cmpy  player1+y_pos
        bgt   >
        ldx   #verticalspeedpos
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
        lda   #4
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts