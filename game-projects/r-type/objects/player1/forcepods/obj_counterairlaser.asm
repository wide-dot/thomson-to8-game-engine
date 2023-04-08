
; ---------------------------------------------------------------------------
; Object - Weapon1
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;       subtype : bit 6 => 0=going right, 1=going left
;                 bit 7 => 0=going up,   1=going down
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0   equ ext_variables ; AABB struct (9 bytes)
caFrame  equ ext_variables+9 ; child's data
nbChilds equ ext_variables+9 ; parent's data

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   GenChilds
        fdb   Init
        fdb   LiveLeft
        fdb   LiveRight
        fdb   AlreadyDeleted

GenChilds
        lda   nbChilds,u
        inca
        cmpa  #5
        beq   @destroy
        sta   nbChilds,u
        jsr   LoadObject_x
        beq   @destroy                      
        lda   #ObjID_forcepod_counterairlaser
        sta   id,x
        lda   subtype,u
        sta   subtype,x
        ldd   glb_camera_x_pos
        subd  glb_camera_x_pos_old
        beq   >
        addd  x_pos,u
        std   x_pos,u
!
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   #1
        sta   routine,x
        rts
@destroy
        jmp   DeleteObject
Init
        _Collision_AddAABB AABB_0,AABB_list_friend
        
        lda   #255                     ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u

        ldb   #4
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        ldx   #counterAirImages   
        clr   caFrame,u
        ldd   ,x
        std   image_set,u  
        ldd   #counterAirHitboxes
        ldd   ,x
        std   AABB_0+AABB.rx,u

        lda   subtype,u
        bita  #1
        bne   InitLeft

InitRight
        lda   #3
        sta   routine,u
        ldd   x_pos,u
	addd  #8
        bra   InitEnd

InitLeft
        lda   render_flags,u
        ora   #render_xmirror_mask
        sta   render_flags,u
        lda   #2
        sta   routine,u
        ldd   x_pos,u
	subd  #9

InitEnd
	std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
	ldd   player1+y_pos
	std   y_pos,u
        stb   AABB_0+AABB.cy,u
        jmp   DisplaySprite

LiveLeft
        ldd   #-6
        bra   Live

LiveRight
        ldd   #6

Live
        addd  x_pos,u
        std   x_pos,u
        ldd   glb_camera_x_pos
        subd  glb_camera_x_pos_old
        beq   >
        addd  x_pos,u
        std   x_pos,u
!
        ldd   x_pos,u
        subd  glb_camera_x_pos
        bmi   @delete
        stb   AABB_0+AABB.cx,u
        cmpd  #160-8/2                 ; delete weapon if out of screen range
        bgt   @delete
        ldx   #counterAirImages   
        lda   caFrame,u
        inca
        cmpa  #8
        bne   >
        lda   #4
!       sta   caFrame,u
        asla
        ldx   a,x
        stx   image_set,u  
        ldx   #counterAirHitboxes
        ldx   a,x
        stx   AABB_0+AABB.rx,u
        jmp   DisplaySprite
@delete
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        lda   #4
        sta   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts

counterAirImages
        fdb   Img_counterairlaser_1
        fdb   Img_counterairlaser_2
        fdb   Img_counterairlaser_3
        fdb   Img_counterairlaser_4
        fdb   Img_counterairlaser_5
        fdb   Img_counterairlaser_6
        fdb   Img_counterairlaser_7
        fdb   Img_counterairlaser_8

counterAirHitboxes
        fcb   3,19
        fcb   3,22
        fcb   3,22
        fcb   3,19
        fcb   3,14
        fcb   3,14
        fcb   3,14
        fcb   3,14
