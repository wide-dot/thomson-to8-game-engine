
; ---------------------------------------------------------------------------
; Object - Couter-air laser
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;       subtype : bit 0 => 0=going right, 1=going left
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0        equ ext_variables    ; AABB struct (9 bytes)
caFrame       equ ext_variables+9  ; 1 byte - current frame
slave         equ ext_variables+10 ; 1 byte - pos related to player one
xPosOld       equ ext_variables+11 ; 2 bytes - old player one x_pos
impactX       equ ext_variables+13 ; 2 bytes - impact x position
parent        equ ext_variables+15 ; 2 bytes - parent object pointer

stepMove      equ 6                ; number of pixels in horizontal axis 
leftOffset    equ 11               ; init position when left
rightOffset   equ 8                ; init position when left

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   GenChilds
        fdb   LiveInit
        fdb   Live
        fdb   AlreadyDeleted

GenChilds
        ldd   #0
        std   glb_d2
        jsr   InitFirstChild

        inc   glb_d0_b
        ldd   glb_d2
        addd  glb_d1
        std   glb_d2
        jsr   GenChild

        inc   glb_d0_b
        ldd   glb_d2
        addd  glb_d1
        std   glb_d2
        jsr   GenChild

        inc   glb_d0_b
        ldd   glb_d2
        addd  glb_d1
        std   glb_d2
        jsr   GenChild
        
        jmp   LiveInit

InitFirstChild                   
        lda   #1
        sta   routine,u
        ldb   #4
        stb   priority,u
        lda   #255                     ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  3,14                     ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        ldb   player1+y_pos+1
        stb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        ldb   render_flags,u
        lda   subtype,u                ; 4: pod hooked right, 5: pod hooked left
        anda  #1
        beq   @goRight
@goLeft
        orb   #render_xmirror_mask     ; use mirrored images when going left
        orb   #render_playfieldcoord_mask
        stb   render_flags,u
        ldd   #stepMove                ; sprites are prepared on the opposite side of the direction
        std   glb_d1
        _negd
        stb   x_vel,u
        ldd   player1+x_pos
        subd  #leftOffset
        bra   @end
@goRight
        orb   #render_playfieldcoord_mask
        stb   render_flags,u
        ldd   #-stepMove               ; sprites are prepared on the opposite side of the direction
        std   glb_d1
        _negd
        std   x_vel,u
        ldd   player1+x_pos
        addd  #rightOffset
@end
        ; compute wall hit destiny
        std   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        tst   x_vel,u
        bpl   >
        jsr   terrainCollision.xAxis.doLeft
        bra   @endif
!       jsr   terrainCollision.xAxis.doRight
@endif  ldd   terrainCollision.impact.x
        std   impactX,u
        
        lda   #6
        sta   slave,u
        lda   #7
        sta   glb_d0_b
        sta   caFrame,u
        ldd   player1+x_pos
        stb   AABB_0+AABB.cx,u
        std   xPosOld,u
        _Collision_AddAABB AABB_0,AABB_list_friend

        stu   parent,u                 ; set self as parent
        rts

GenChild
        jsr   LoadObject_x
        bne   >
        leas  2,s                      ; skip return to caller
        jmp   LiveInit
!       lda   id,u
        sta   id,x
        lda   subtype,u
        sta   subtype,x
        lda   render_flags,u
        sta   render_flags,x
        lda   routine,u
        sta   routine,x
        lda   priority,u
        sta   priority,x
        lda   glb_d0_b
        sta   caFrame,x   
        lda   AABB_0+AABB.p,u
        sta   AABB_0+AABB.p,x
        ldd   AABB_0+AABB.rx,u         ; set hitbox xy radius
        std   AABB_0+AABB.rx,x         ; by copying 2 bytes
        ldd   x_pos,u
        addd  glb_d2                   ; sprites are prepared on the opposite side of the direction
        std   x_pos,x
        stb   AABB_0+AABB.cx,u
        ldb   player1+y_pos+1
        stb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        ldd   x_vel,u
        std   x_vel,x
        lda   slave,u
        sta   slave,x
        ldd   xPosOld,u
        std   xPosOld,x
        ldd   impactX,u
        std   impactX,x
        stu   parent,x
        pshs  u
        leau  ,x                       ; Collision routine use u as object pointer
        _Collision_AddAABB AABB_0,AABB_list_friend
        puls  u,pc

LiveInit
        inc   routine,u
        ldb   #0
        bra   @save
Live
        ; compute framedrop
        ldb   gfxlock.frameDrop.count
        asrb                           ; adjust speed
        bne   >
        incb                           ; min speed is 1 image segment
!       cmpb  #4                       ; maximum speed is 4 image segments
        blt   @save
        ldb   #4
@save   stb   counterAirLaser.frameDrop
;
        ; compute position and hitbox
        lda   #stepMove                ; image width
        mul                            ; process horizontal speed
        tst   x_vel,u
        bpl   >                        ; branch going right
        _negd
!       addd  x_pos,u   
        addd  glb_camera_x_pos         ; adjust scroll
        subd  glb_camera_x_pos_old
        std   x_pos,u
!
        ; check if laser is always attached to player one
        lda   caFrame,u
        suba  counterAirLaser.frameDrop
        bpl   >
        anda  #%00000011               ; loop thru 4 images
!       sta   caFrame,u
;
        ; track player's y_pos
        lda   slave,u 
        suba  counterAirLaser.frameDrop
        bmi   @updateCommon
        sta   slave,u
        ldd   player1+x_pos
        subd  xPosOld,u
        addd  x_pos,u
        std   x_pos,u
        ldd   player1+x_pos
        std   xPosOld,u
        ldb   player1+y_pos+1
        cmpb  y_pos+1,u
        beq   @updateCommon
        stb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        cmpu  parent,u  
        bne   @updateChild
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        tst   x_vel,u
        bpl   >
        jsr   terrainCollision.xAxis.doLeft
        bra   @endif
!       jsr   terrainCollision.xAxis.doRight
@endif  ldd   terrainCollision.impact.x
        std   impactX,u
        bra   @updateEnd
@updateChild      
        ldx   parent,u
        lda   id,x
        cmpa  #ObjID_forcepod_counterairlaser
        bne   @updateCommon
        ldd   impactX,x
        std   impactX,u
@updateCommon
        lda   #-1
        sta   slave,u  
@updateEnd
        ;
        ; check out of screen range
        ldd   x_pos,u
        subd  glb_camera_x_pos
        bmi   @delete                  ; out of range on left
        stb   AABB_0+AABB.cx,u
        cmpd  #160-8/2                 ; out of screen range on right
        bgt   @delete
;
        ; check wall collision
        ldd   impactX,u
        beq   > ; no wall collision
        tst   x_vel,u
        bmi   @goingLeft
        subd  #3 ; half width of the weapon, to check collision on the right side of sprite
        cmpd  x_pos,u
        bls   @delete
        bra   >
@goingLeft
        addd  #3 ; half width of the weapon, to check collision on the left side of sprite
        cmpd  x_pos,u
        bhs   @delete
!
        ; compute current frame
        lda   caFrame,u
        ldx   #counterAirImages
        asla
        ldx   a,x
        stx   image_set,u
        bne   >
        rts
!       jmp   DisplaySprite
@delete
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        lda   #3
        sta   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts

counterAirImages
        fdb   Img_counterairlaser_7
        fdb   Img_counterairlaser_6
        fdb   Img_counterairlaser_5
        fdb   Img_counterairlaser_4
        fdb   Img_counterairlaser_3
        fdb   Img_counterairlaser_2
        fdb   Img_counterairlaser_1
        fdb   Img_counterairlaser_0
        fdb   0
        fdb   0
        fdb   0

counterAirHitboxes
        fcb   3,14
        fcb   3,14
        fcb   3,14
        fcb   3,14
        fcb   3,19
        fcb   3,22
        fcb   3,22
        fcb   3,19
        fcb   0,0
        fcb   0,0
        fcb   0,0

counterAirLaser.frameDrop
        fcb   0