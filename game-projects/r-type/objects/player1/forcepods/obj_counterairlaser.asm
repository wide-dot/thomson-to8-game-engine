
; ---------------------------------------------------------------------------
; Object - Couter-air laser
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

AABB_0    equ ext_variables ; AABB struct (9 bytes)
caFrame    equ ext_variables+9 ; 1 byte - current frame
oldcaFrame equ ext_variables+10 ; 1 byte - previous frame
childnum   equ ext_variables+11 ; 1 byte - child number
childaddr  equ ext_variables+12 ; 2 bytes - child address
maxnbchildren equ 4           ; Excluding 0

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   GenChilds
        fdb   LiveInitLeft
        fdb   LiveLeft
        fdb   LiveInitRight
        fdb   LiveRight
        fdb   AlreadyDeleted

GenChilds
        lda   childnum,u
        inca                                    ; Num child set at 4 to ensure last child does not get free on first run
        cmpa  #maxnbchildren
        beq   >
        jsr   LoadObject_x
        beq   >                     
        lda   #ObjID_forcepod_counterairlaser
        sta   id,x
        stx   childaddr,u
        lda   subtype,u
        sta   subtype,x
        lda   childnum,u
        inca
        sta   childnum,x
!
        _Collision_AddAABB AABB_0,AABB_list_friend
        
        lda   #255                     ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u

        ldb   #4
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        lda   #3
        sta   routine,u
        lda   subtype,u
        bita  #1
        beq   LiveInitRight
        lda   #1
        sta   routine,u
        lda   render_flags,u
        ora   #render_xmirror_mask
        sta   render_flags,u
LiveInitLeft
        lda   #maxnbchildren
        suba  caFrame,u
        suba  childnum,u
        bne   >
        inc   routine,u 
!
        ldd   player1+y_pos
        std   y_pos,u
        ldx   childaddr,u
        beq   >
        lda   oldcaFrame,u
        sta   caFrame,x
!
        lda   #6
        ldb   caFrame,u
        mul
        _negd
        addd  player1+x_pos
        subd  #11
        bra   Live1

LiveLeft
        ldd   #-6
        ;_negd
        bra   Live

LiveInitRight
        lda   #maxnbchildren
        suba  caFrame,u
        suba  childnum,u
        bne   >
        inc   routine,u 
!
        ldd   player1+y_pos
        std   y_pos,u
        ldx   childaddr,u
        beq   >
        lda   oldcaFrame,u
        sta   caFrame,x
!
        lda   #6
        ldb   caFrame,u
        mul
        addd  player1+x_pos
        addd  #8
        bra   Live1

LiveRight
        lda   #3
        ldb   gfxlock.frameDrop.count
        mul
Live
        addd  x_pos,u
Live1
        std   x_pos,u
        ;ldd   glb_camera_x_pos
        ;subd  glb_camera_x_pos_old
        ;beq   >
        ;addd  x_pos,u
        ;std   x_pos,u
!
        ldd   x_pos,u
        subd  glb_camera_x_pos
        bmi   @delete
        stb   AABB_0+AABB.cx,u
        cmpd  #160-8/2                 ; delete weapon if out of screen range
        bgt   @delete
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        lda   caFrame,u
        asla
        ldx   #counterAirImages   
        ldx   a,x
        stx   image_set,u 
        ldx   #counterAirHitboxes
        ldx   a,x
        stx   AABB_0+AABB.rx,u         ; and ry
        asra
        sta   oldcaFrame,u
        inca
        cmpa  #8
        bne   >
        lda   #4
!       sta   caFrame,u
        clra
        ldb   AABB_0+AABB.rx,u
        addd  x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   @delete
        jmp   DisplaySprite
@delete
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        lda   #5
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
