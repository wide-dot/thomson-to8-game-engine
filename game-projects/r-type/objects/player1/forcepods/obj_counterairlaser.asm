
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
        _Collision_AddAABB AABB_0,AABB_list_friend
        ldb   render_flags,u
        lda   subtype,u
        anda  #1
        beq   @goRight
@goLeft
        orb   #render_xmirror_mask     ; use mirrored images when going left
        orb   #render_playfieldcoord_mask
        stb   render_flags,u
        ldd   #stepMove
        std   glb_d1
        ldd   player1+x_pos
        subd  #leftOffset
        bra   @end
@goRight
        orb   #render_playfieldcoord_mask
        stb   render_flags,u
        ldd   #-stepMove
        std   glb_d1
        ldd   player1+x_pos
        addd  #rightOffset
@end
        std   x_pos,u
        lda   #6
        sta   slave,u
        lda   #7
        sta   glb_d0_b
        sta   caFrame,u
        ldd   player1+x_pos
        std   xPosOld,u
        rts

GenChild
        jsr   LoadObject_x
        bne   >
        leas  2,s                      ; skip return to caller
        jmp   LiveInit                 ; skip child objects creation if no more object slots
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
        ldd   x_pos,u
        addd  glb_d2
        std   x_pos,x
        lda   slave,u
        sta   slave,x
        ldd   xPosOld,u
        std   xPosOld,x
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
        lda   render_flags,u
        anda  #render_xmirror_mask
        bne   >                        ; going left
        lda   #6                       ; image width
        mul                            ; process horizontal speed
        bra   @a
!       lda   #6                       ; image width
        mul                            ; process horizontal speed
        _negd
@a
        addd  x_pos,u   
        std   x_pos,u
;
        ldd   glb_camera_x_pos         ; adjust scroll
        subd  glb_camera_x_pos_old
        beq   >
        addd  x_pos,u
        std   x_pos,u
!
        ; check if laser is always attached to player one
        ldb   y_pos+1,u
        lda   caFrame,u
        suba  counterAirLaser.frameDrop
        bpl   >
        anda  #%00000011               ; loop thru 4 images
!       sta   caFrame,u
;
        ; track player's y_pos
        lda   slave,u 
        suba  counterAirLaser.frameDrop
        bmi   >
        sta   slave,u
        ldb   player1+y_pos+1
        stb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        ldd   player1+x_pos
        subd  xPosOld,u
        addd  x_pos,u
        std   x_pos,u
        ldd   player1+x_pos
        std   xPosOld,u
        bra   @b
!       lda   #-1
        sta   slave,u     
@b
        ; check out of screen range
        ldd   x_pos,u
        subd  glb_camera_x_pos
        bmi   @delete                  ; out of range on left
        stb   AABB_0+AABB.cx,u
        cmpd  #160-8/2                 ; delete weapon if out of screen range on right
        bgt   @delete
;
        ; compute current frame
        lda   caFrame,u
        ldx   #counterAirImages
        asla
        ldx   a,x
        stx   image_set,u 
;
        ; check terrain collision
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1                       ; foreground
        jsr   terrainCollision.do
        tstb
        bne   @delete
;
        jmp   DisplaySprite
@delete
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        lda   #3
        sta   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts

counterAirImages
        fdb   Img_counterairlaser_8
        fdb   Img_counterairlaser_7
        fdb   Img_counterairlaser_6
        fdb   Img_counterairlaser_5
        fdb   Img_counterairlaser_4
        fdb   Img_counterairlaser_3
        fdb   Img_counterairlaser_2
        fdb   Img_counterairlaser_1
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