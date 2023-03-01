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

	lda   subtype,u
        asla
        ldx   #optionboxes
        ldd   a,x
        std   image_set,u
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
	inc   routine,u

        _Collision_AddAABB AABB_0,AABB_list_bonus
        
        leax  AABB_0,u
        lda   #1                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  4,7                       ; set hitbox xy radius
        std   AABB.rx,x
        ldd   y_pos,u
        stb   AABB.cy,x

Live
        jsr   ObjectMoveSync
        leax  AABB_0,u
        lda   AABB.p,x
        beq   @captured                ; was touched  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        addd  #4                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        jmp   DisplaySprite
@captured
        lda   subtype,u
        sta   player1+forcepodtype
                                        ; Do we need to spawn a force pod ?
        lda   player1+forcepodlevel
        bne   >
                                        ; Yes, let's spawn a new force pod
        jsr   LoadObject_x
        beq   >                         ; branch if no more available object slot
        lda   #ObjID_forcepod           ; Charge anim
        sta   id,x                                        
!
        lda   player1+forcepodlevel
        inca
        cmpa  #3
        ble   >
        lda   #3
!
        sta  player1+forcepodlevel
@delete
        inc   routine,u     
        _Collision_RemoveAABB AABB_0,AABB_list_bonus
        jmp   DeleteObject
AlreadyDeleted
        rts


optionboxes
        
        FDB Img_pow_optionbox_0
        FDB Img_pow_optionbox_1
        FDB Img_pow_optionbox_2