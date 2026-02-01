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
        INCLUDE "./objects/soundFX/soundFX.const.asm"
        INCLUDE "./engine/sound/soundFX.macro.asm"

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
        ;bne   >  ; rebound laser code is unfinished
        ;lda   #4 ; replace by counter-air
        ;sta   subtype,u
!       lsla
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
        
        lda   #127                      ; set weak hitbox type
        sta   AABB_0+AABB.p,u
        _ldd  4,7                       ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        ldd   y_pos,u
        stb   AABB_0+AABB.cy,u

Live
        jsr   ObjectMoveSync
        lda   AABB_0+AABB.p,u
        beq   @captured                ; was captured  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #4                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        jmp   DisplaySprite
@captured
        lda   subtype,u                 ; Rebound laser ?
        beq   >
        cmpa  #3                        ; Speed ?
        beq   @speed
        cmpa  #7                        ; Missiles ?
        beq   @missiles
        cmpa  #1                        ; Counter-ground laser ?
        beq   >
        lda   #2                        ; Counter-air laser
!
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
        cmpa  #3
        beq   >
        inca  
        sta   player1+forcepodlevel
!
        _soundFX.play soundFX.BonusSound,4
@delete
        inc   routine,u     
        _Collision_RemoveAABB AABB_0,AABB_list_bonus
        jmp   DeleteObject
@speed
        ldd   player1+speedlevel
        addd  #32
        cmpd  #32*4
        beq   >
        std   player1+speedlevel
!
        jmp   @delete
@missiles
        jmp   @delete
AlreadyDeleted
        rts


optionboxes
        
        fdb Img_pow_optionbox_0    ; Bounce laser
        fdb Img_pow_optionbox_1    ; Counter ground laser
        fdb 0
        fdb Img_pow_optionbox_3    ; Speed up
        fdb Img_pow_optionbox_4    ; Counter air laser
        fdb 0
        fdb 0
        fdb Img_pow_optionbox_7    ; Missiles