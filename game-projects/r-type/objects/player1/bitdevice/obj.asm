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
        INCLUDE "./objects/player1/player1.equ"
AABB_0            equ ext_variables    ; AABB struct (9 bytes)
old_xpos1         equ ext_variables+9  ; word
old_ypos1         equ ext_variables+11 ; word
old_xpos2         equ ext_variables+13 ; word
old_ypos2         equ ext_variables+15 ; word
offsety           equ ext_variables+17 ; word

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   InitOptionBox
        fdb   LiveOptionBox
        fdb   AlreadyDeletedOptionBox
        fdb   Live

InitOptionBox
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ldx   #25
        ldy   #Ani_bitdevice1
        lda   player1+bitdevice
        stx   offsety,u
        sty   anim,u

        inc   routine,u                 ; Set routine to LiveOptionBox
        _Collision_AddAABB AABB_0,AABB_list_bonus
        
        leax  AABB_0,u
        lda   #1                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  4,7                       ; set hitbox xy radius
        std   AABB.rx,x
LiveOptionBox
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   @delete
        leax  AABB_0,u
        lda   player1+bitdevice
        bita  #2
        bne   >                        ; ignore contact if player1 has already the 2 device bits
        lda   AABB.p,x
        beq   Init                     ; was touched  
!
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        ldb   y_pos+1,u
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
@delete       
        _Collision_RemoveAABB AABB_0,AABB_list_bonus
        inc   routine,u
        jmp   DeleteObject
AlreadyDeletedOptionBox
        rts
Init
        _Collision_RemoveAABB AABB_0,AABB_list_bonus
        _Collision_AddAABB AABB_0,AABB_list_friend
        
        leax  AABB_0,u
        lda   #255                      ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  3,6                       ; set hitbox xy radius
        std   AABB.rx,x
        ldd   y_pos,u
        stb   AABB.cy,x

        lda   #3
        sta   routine,u

        ldd   player1+x_pos
        std   old_xpos1,u
        std   old_xpos2,u
        ldd   player1+y_pos
        std   old_ypos1,u
        std   old_ypos2,u

        lda   player1+bitdevice
        beq   >
        ldx   #-25
        ldy   #Ani_bitdevice2
        stx   offsety,u
        sty   anim,u
!
        inca   
        sta   player1+bitdevice
Live
        leax  AABB_0,u
        ldd   old_xpos2,u
        std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        ldd   old_ypos2,u
        subd  offsety,u
        std   y_pos,u
        stb   AABB.cy,x

        ldd   old_xpos1,u
        std   old_xpos2,u
        ldd   old_ypos1,u
        std   old_ypos2,u

        ldd   player1+x_pos
        std   old_xpos1,u
        ldd   player1+y_pos
        std   old_ypos1,u

        jsr   AnimateSpriteSync
        jmp   DisplaySprite

