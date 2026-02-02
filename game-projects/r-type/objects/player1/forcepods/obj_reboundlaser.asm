; ---------------------------------------------------------------------------
; Object - Rebound Laser
;
; Unlike arcade :
; - only the parent object go through collisions, childs follow the parent
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
; subtype: 4=front, 5=back
; x_pos: x position of the forcepod
; y_pos: y position of the forcepod
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/player1/player1.equ"

AABB_0        equ ext_variables    ; AABB struct (9 bytes)
direction     equ ext_variables+9  ; 1 byte, diagonal: 0=upright, 2=downright, 4=downleft, 6=upleft - horizontal: 0=right, 2=left
; free slot equ ext_variables+10 ; 1 byte
laserLifetime equ ext_variables+11 ; 1 byte, number of frames the laser is active
slotMask      equ ext_variables+12 ; 1 byte, mask to set/free slot occupation
parent        equ ext_variables+13 ; 2 bytes, parent object pointer (0=no parent, head of laser)
childId       equ ext_variables+15 ; 1 byte, index of the child laser (0=first child, 1=second child, ...)
isLastChild   equ ext_variables+16 ; 1 byte, 1=last child, 0=not last child
bufferBase    equ ext_variables+17 ; 2 bytes, index of the position buffer (aligned to 16 bytes)
bufferIndex   equ ext_variables+19 ; 1 byte, index in the 16 bytes buffer (0,2,4,6,8,10,12,14)
child         equ routine_tertiary ; 2 bytes, pointer to the next child object in the laser chain

LASER_LIFETIME equ $70 ; 112 frames

LASER_RIGHT_UP   equ 0
LASER_RIGHT_DOWN equ 2
LASER_LEFT_DOWN  equ 4
LASER_LEFT_UP    equ 6

LASER_RIGHT equ 0
LASER_LEFT  equ 2

SLOT_UP     equ 1
SLOT_CENTER equ 2
SLOT_DOWN   equ 4

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Orchestrate
        fdb   StartLaser
        fdb   RunHorizontalLaser
        fdb   RunDiagonalLaser
        fdb   RunExplosion
        fdb   DoubleBufferingFlush

Rtn_Orchestrate          equ 0
Rtn_StartLaser           equ 1
Rtn_RunHorizontalLaser   equ 2
Rtn_RunDiagonalLaser     equ 3
Rtn_RunExplosion         equ 4
Rtn_DoubleBufferingFlush equ 5

glb.loopCounter    fcb 0
glb.childId        fcb 0
glb.prevSegment    fdb 0
glb.slotsState     fcb 0 ; bit0=up, bit1=center, bit2=down
glb.frameDrop      fcb 0
glb.buffer         fdb 0 ; temp for buffer address
glb.dataLocation   fdb 0

                       fill 0,32   ; spare bytes for alignment (cycling buffer)
glb.diagonalUpBuffer   equ (*/32)*32
                       fill 0,32*3 ; used to store up to 16 words group (x_pos, y_pos, image_set)
glb.diagonalDownBuffer equ (*/32)*32
                       fill 0,32*3 ; used to store up to 16 words group (x_pos, y_pos, image_set)
glb.horizontalBuffer   equ (*/32)*32
                       fill 0,32 ; used to store up to 16 words (x_pos)

DIV6u
  bsr  DIV3u
  lsra
  rorb
  lsr  2,x
  std  ,x
  rts

DIV3u
  ldb  1,x
  lda  #85
  mul
  std  1,x
  ldb  ,x
  lda  #85
  mul
  addb 1,x
  adca #0
  std  ,x
* partie optionnelle pour une vraie division par 3,
* sinon c'est division par 3.0117 (0.4% d'erreur)
  ldd  1,x
  addd #128   ; arrondi
  adda 2,x
  sta  2,x
  ldd  ,x
  adcb ,x
  adca #0
  std  ,x
* fin de la partie optionelle pour vraie division
  rts

Orchestrate
        ; a rebound laser can only be releases if the previous one was destroyed
        ; each of the 3 lasers (high, mid, low) are independent

        lda   glb.slotsState
        cmpa  #7 ; if all 3 lasers are active, do not initiate a new one
        bne   >
        jmp   DeleteObject
!

        ; adjust x position based on the position of the forcepod
        ldb   subtype,u   ; get position of the forcepod (4=front, 5=rear)
        cmpb  #4
        beq   >
        ldd   x_pos,u
        subd  #9
        bra   @end
!
        ldd   x_pos,u
        addd  #11
@end    std   x_pos,u

        ; snap on tile grid (3px)
        leax  x_pos,u        
        jsr   DIV3u
        addd  x_pos,u        
        addd  x_pos,u        
        std   x_pos,u        
        std   terrainCollision.sensor.x

        ; snap on tile grid (6px)
        leax  y_pos,u        
        jsr   DIV6u
        addd  y_pos,u        
        addd  y_pos,u        
        lslb
        rola        
        addd  #1 ; center of the tile
        std   y_pos,u
        std   terrainCollision.sensor.y

        ; check if the laser is born inside a wall
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   >
        jmp   DeleteObject
!
        lda   globals.backgroundSolid
        beq   >
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        beq   >
        jmp   DeleteObject
!
        ; initiate the lasers
        lda   glb.slotsState
        anda  #SLOT_UP                ; is slot up active?
        bne   >                       ; if yes, skip
        ldd   #glb.diagonalUpBuffer
        std   glb.buffer
        lda   #LASER_RIGHT_UP
        ldb   #SLOT_UP
        jsr   InitiateDiagonalLaser
!       lda   glb.slotsState          ; is slot center active?
        anda  #SLOT_CENTER            ; if yes, skip
        bne   >
        ldb   #SLOT_CENTER
        jsr   InitiateHorizontalLaser
!       lda   glb.slotsState          ; is slot down active?
        anda  #SLOT_DOWN              ; if yes, skip
        bne   >
        ldd   #glb.diagonalDownBuffer
        std   glb.buffer        
        lda   #LASER_RIGHT_DOWN
        ldb   #SLOT_DOWN
        jsr   InitiateDiagonalLaser
!       
        jmp   DeleteObject

InitiateDiagonalLaser
        stb   slotMask,u

        ; set direction based on the position of the forcepod
        ldb   subtype,u   ; get position of the forcepod (4=front, 5=rear)
        cmpb  #4
        beq   >
        adda  #4          ; UP and DOWN are inverted when rear mounted forcepod, it does not matter
        anda  #7
!       sta   direction,u

        ldd   #0
        std   parent,u
        sta   isLastChild,u
        stu   glb.prevSegment ; dummy value ... will set something on the orchestrate object when writing child,y        
        ldx   glb.buffer 
        stx   bufferBase,u        
        jsr   initBuffer
        jsr   DiagonalLoadObject
        stx   parent,u
        clr   glb.childId
        ; laser length (2 or 8) based on forcepod power        
        lda   player1+forcepodlevel
        cmpa  #2
        beq   >
        ;jsr   DiagonalLoadObject ; 8 sprites x 3 lasers = 24 sprites, too much left for enemies
        ;jsr   DiagonalLoadObject
        ;jsr   DiagonalLoadObject
        ;jsr   DiagonalLoadObject
        jsr   DiagonalLoadObject
        jsr   DiagonalLoadObject 
!       inc   isLastChild,u
        jsr   DiagonalLoadObject
        rts

DiagonalLoadObject
        stx   @x
        jsr   LoadObject_x
        beq   >
        ldb   glb.slotsState
        orb   slotMask,u
        stb   glb.slotsState    
        jsr   InitLaserSegment
        lda   #Rtn_RunDiagonalLaser
        sta   routine_secondary,x
        rts
!
        ldx   #0
@x      equ *-2
        inc   isLastChild,x ; assign a last child when no more slots are available
        leas  2,s ; double return to skip following object allocation (no more slots available)
        rts

initBuffer
        ;ldd   #0 already done ...
        std   ,x
        std   2,x        
        std   4,x
        std   6,x
        std   8,x
        std   10,x
        std   12,x
        std   14,x
        std   16,x
        std   18,x
        std   20,x
        std   22,x
        std   24,x
        std   26,x
        std   28,x
        std   30,x
        rts

InitiateHorizontalLaser
        stb   slotMask,u

        ; set direction based on the position of the forcepod
        ldb   #LASER_RIGHT
        lda   subtype,u   ; get position of the forcepod (4=front, 5=back)
        cmpa  #4
        beq   >
        ldb   #LASER_LEFT
!       stb   direction,u

        ldd   #0
        std   parent,u
        sta   isLastChild,u
        stu   glb.prevSegment ; dummy value ... will set something on the orchestrate object when writing child,y
        ldx   #glb.horizontalBuffer
        stx   bufferBase,u
        jsr   initBuffer   
        jsr   HorizontalLoadObject
        stx   parent,u
        clr   glb.childId
        ; laser length (2 or 8) based on forcepod power        
        lda   player1+forcepodlevel
        cmpa  #2
        beq   >
        ;jsr   HorizontalLoadObject
        ;jsr   HorizontalLoadObject
        ;jsr   HorizontalLoadObject
        ;jsr   HorizontalLoadObject
        jsr   HorizontalLoadObject
        jsr   HorizontalLoadObject
!       inc   isLastChild,u
        jsr   HorizontalLoadObject
        rts

HorizontalLoadObject
        stx   @x
        jsr   LoadObject_x
        beq   >
        ldb   glb.slotsState
        orb   slotMask,u
        stb   glb.slotsState    
        jsr   InitLaserSegment
        lda   #Rtn_RunHorizontalLaser
        sta   routine_secondary,x
        ldd   #Img_reboundlaser_horizontal
        std   image_set,x
        rts
!
        ldx   #0
@x      equ *-2
        inc   isLastChild,x ; assign a last child when no more slots are available
        leas  2,s ; double return to skip following object allocation (no more slots available)
        rts

InitLaserSegment
        lda   #ObjID_forcepod_reboundlaser
        sta   id,x
        ldb   #7
        stb   priority,x
        lda   render_flags,x
        ora   #render_playfieldcoord_mask
        sta   render_flags,x
        lda   direction,u
        sta   direction,x
        lda   slotMask,u
        sta   slotMask,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   #Rtn_StartLaser
        sta   routine,x
        ldd   parent,u
        std   parent,x ; copy head of laser chain as parent for all children
        ldy   glb.prevSegment ; get previous segment and set new segment as child
        stx   child,y
        stx   glb.prevSegment
        ldd   #0
        std   child,x
        lda   glb.childId
        sta   childId,x
        inc   glb.childId    
        lda   isLastChild,u
        sta   isLastChild,x
        ldd   bufferBase,u
        std   bufferBase,x
        clr   bufferIndex,x
        rts

StartLaser
        lda   routine_secondary,u
        sta   routine,u
        ldd   parent,u
        beq   >
        ; for children
        lda   childId,u
        inca
        asla
        adda  #LASER_LIFETIME ; for parent a is implicitely 0
        sta   laserLifetime,u
        jmp   Object ; run the laser now
!
        ; for parent
        lda   #LASER_LIFETIME ; for parent a is implicitely 0
        sta   laserLifetime,u

        ; set hitbox
        lda   #2                       ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  5,9                     ; set hitbox xy radius (arcade radius: 12x12px)
        std   AABB_0+AABB.rx,u
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u         ; fixed y position for horizontal laser   
        _Collision_AddAABB AABB_0,AABB_list_friend
        jmp   Object ; run the laser now

DoubleBufferingFlush
        rts

RunHorizontalChildLaser
        ; simplyfied code for childs
        lda   id,x
        cmpa  #ObjID_forcepod_reboundlaser
        lbne  Destroy
        ldb   routine,x
        cmpb  #Rtn_RunHorizontalLaser
        lbne  Destroy
        ldb   laserLifetime,u
        subb  gfxlock.frameDrop.count
        stb   laserLifetime,u
        lbmi  Destroy
        ldb   bufferIndex,x ; get index in the buffer
        lda   childId,u
        asla
        asla  ; *4
        adda  #6 ; start offset for child id 0
        sta   @a
        subb  #0
@a      equ *-1
        andb  #%00011111
        ldx   bufferBase,x  ; get actual position of parent in buffer
        ldd   b,x
        std   x_pos,u
        jmp   DisplaySprite

RunHorizontalLaser
        ; simplyfied code for childs
        ldx   parent,u
        bne   RunHorizontalChildLaser

        ; check collision potential
        ldb   AABB_0+AABB.p,u
        lbeq  InitExplosion

        ; load buffer base
        ldx   bufferBase,u
        ldb   bufferIndex,u
        leax  b,x
        stx   glb.buffer

        ldb   gfxlock.frameDrop.count
        stb   glb.frameDrop
RunHorizontalLaser.frameDropLoop

        ; update position
        ldx   #HorizontalVelocityPresets
        lda   direction,u
        ldd   a,x
        addd  x_pos,u
        std   x_pos,u
        ldx   glb.buffer
        std   ,x
        std   terrainCollision.sensor.x        

        ; check if the laser is on edge of the screen (right)
        ; if so, skip wall collision
        jsr   isInCollisionRange
        lbeq  RunHorizontalLaser.forward

        ; check for collision with the walls
        ldd   y_pos,u
        std   terrainCollision.sensor.y

        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   RunHorizontalLaser.rebound
        lda   globals.backgroundSolid
        lbeq  RunHorizontalLaser.forward
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        lbeq  RunHorizontalLaser.forward

RunHorizontalLaser.rebound
        ldb   direction,u
        eorb  #%00000010
        stb   direction,u

RunHorizontalLaser.forward
        ; move to next position in the buffer
        ldb   bufferIndex,u
        addb  #2
        andb  #%00011111
        stb   bufferIndex,u
        ldx   bufferBase,u
        leax  b,x          
        stx   glb.buffer

        dec   glb.frameDrop
        bne   RunHorizontalLaser.frameDropLoop

        ; no collision to walls
        jsr   isInLivingArea
        beq   Destroy
        ; check if the laser is still alive
        ldb   laserLifetime,u
        subb  gfxlock.frameDrop.count
        stb   laserLifetime,u
        lbmi  Destroy  

        ; update hitbox position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u            

        jmp   DisplaySprite

Destroy
        lda   isLastChild,u
        beq   >
        com   slotMask,u
        ldb   glb.slotsState
        andb  slotMask,u
        stb   glb.slotsState
!
        lda   #Rtn_DoubleBufferingFlush
        sta   routine,u
        ldd   parent,u
        bne   >
        lda   AABB_0+AABB.rx,u
        beq   >
        _Collision_RemoveAABB AABB_0,AABB_list_friend        
!       jmp   DeleteObject

isInLivingArea
        ; check if the laser is in living range
        ; if not, destroy the laser
        lda   player1+forcepodlevel
        cmpa  #2
        beq   >        
        ; longer laser
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #-8*8 ; 20px on arcade: 20x3.75=7.5px
        blt   @false
        cmpd  #144+8*8
        bge   @false
        ldd   y_pos,u
        subd  glb_camera_y_pos
        cmpd  #-15*8 ; 20px on arcade: 20x0.75=15px
        blt   @false
        cmpd  #180+15*8
        bge   @false
@true   lda   #1
        rts
@false  clra
        rts
!       ; shorter laser
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #-8*2 ; 20px on arcade: 20x3.75=7.5px
        blt   @false
        cmpd  #144+8*2
        bge   @false
        ldd   y_pos,u
        subd  glb_camera_y_pos
        cmpd  #-15*2 ; 20px on arcade: 20x0.75=15px
        blt   @false
        cmpd  #180+15*2
        bge   @false
        lda   #1
        rts

isInCollisionRange
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #8
        blt   @false ; not tested in arcade but we have different behavior in collision testing that make this check mandatory
        cmpd  #144+8-2 ; center of sprite is 2px from the right edge of sprite (similar to arcade)
        bge   @false
        ldd   y_pos,u
        cmpd  #8 ; value set by test ...
        blt   @false ; not tested in arcade but we have different behavior in collision testing that make this check mandatory
        cmpd  #180+18 ; value set by test ...
        bge   @false ; not tested in arcade but we have different behavior in collision testing that make this check mandatory
@true   lda   #1 ; return value
        rts
@false
        lda   AABB_0+AABB.rx,u
        beq   >
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        clr   AABB_0+AABB.rx,u ; flag hitbox as disabled
        ; implicit return value: bit zero set by previous instruction
!       rts

RunDiagonalChildLaser
        ; simplyfied code for childs
        lda   id,x
        cmpa  #ObjID_forcepod_reboundlaser
        lbne   Destroy        
        ldb   routine,x
        cmpb  #Rtn_RunDiagonalLaser
        lbne  Destroy        
        ldb   laserLifetime,u
        subb  gfxlock.frameDrop.count
        stb   laserLifetime,u        
        lbmi  Destroy        
        ldb   bufferIndex,x ; get index in the buffer
        lda   childId,u
        asla
        asla  ; *4
        adda  #6 ; start offset for child id 0
        sta   @a
        subb  #0
@a      equ *-1
        andb  #%00011111
        ldy   bufferBase,x  ; get actual position of parent in buffer
        leay  b,y
        ldd   ,y
        std   x_pos,u
        ldd   32,y
        std   y_pos,u
        ldd   64,y
        std   image_set,u        
        jmp   DisplaySprite

RunDiagonalLaser
        ; simplyfied code for childs
        ldx   parent,u
        bne   RunDiagonalChildLaser

        ; check collision potential
        ldb   AABB_0+AABB.p,u
        lbeq  InitExplosion

        ; load buffer base
        ldx   bufferBase,u
        ldb   bufferIndex,u
        leax  b,x
        stx   glb.buffer

        ldb   gfxlock.frameDrop.count
        stb   glb.frameDrop
RunDiagonalLaser.frameDropLoop

        ; update position
        ldx   #DiagonalVelocityPresets
        ldb   direction,u
        aslb
        abx
        ldd   y_pos,u
        addd  2,x
        std   y_pos,u
        std   terrainCollision.sensor.y
        ldd   x_pos,u
        addd  ,x
        std   x_pos,u
        std   terrainCollision.sensor.x

        ; check if the laser is on edge of the screen (right)
        ; if so, skip wall collision
        jsr   isInCollisionRange
        lbeq  RunDiagonalLaser.forward

        ; check for collision with the walls
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y

        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   RunDiagonalLaser.rebound
        lda   globals.backgroundSolid
        lbeq  RunDiagonalLaser.forward
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        lbeq  RunDiagonalLaser.forward

RunDiagonalLaser.rebound
        ldx   #ReboundPresets
        ldb   direction,u
        aslb                    ; mult by 6
        stb   @b
        aslb
        addb  #0
@b      equ   *-1
        abx
        ldd   x_pos,u
        addd  ,x
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  2,x
        std   terrainCollision.sensor.y
        stx   glb.dataLocation

        ; second collision check
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   RunDiagonalLaser.rebound2
        lda   globals.backgroundSolid
        beq   >
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        bne   RunDiagonalLaser.rebound2
!
        ; apply based on first collision only
        ldd   terrainCollision.sensor.x
        std   x_pos,u
        ldd   terrainCollision.sensor.y
        std   y_pos,u
        ldx   glb.dataLocation
        ldd   4,x
        std   image_set,u
        lda   direction,u
        adda  #2
        anda  #%00000111
        sta   direction,u        
        jmp   RunDiagonalLaser.afterCollision

RunDiagonalLaser.rebound2    
        ldx   glb.dataLocation    
        ldd   x_pos,u
        addd  6,x
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  8,x
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   RunDiagonalLaser.reboundBack
        lda   globals.backgroundSolid
        beq   >
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        bne   RunDiagonalLaser.reboundBack
!
        ; apply based on second collision only
        ldd   terrainCollision.sensor.x
        std   x_pos,u
        ldd   terrainCollision.sensor.y
        std   y_pos,u
        ldx   glb.dataLocation
        ldd   10,x
        std   image_set,u
        lda   direction,u
        adda  #6
        anda  #%00000111
        sta   direction,u        
        jmp   RunDiagonalLaser.afterCollision

RunDiagonalLaser.reboundBack
        ldx   glb.dataLocation    
        ldd   terrainCollision.sensor.x
        addd  ,x
        std   x_pos,u
        ldd   terrainCollision.sensor.y
        addd  2,x
        std   y_pos,u
        ldb   direction,u
        addb  #4
        andb  #%00000111
        stb   direction,u

RunDiagonalLaser.forward
        ldx   #DiagonalImages
        lda   direction,u
        ldd   a,x
        std   image_set,u

RunDiagonalLaser.afterCollision

        ; store new position in history buffer
        ldx   glb.buffer
        ldd   x_pos,u
        std   ,x ; store new x position
        ldd   y_pos,u
        std   32,x ; store new y position
        ldd   image_set,u
        std   64,x ; store new image

        ; move to next position in the buffer
        ldb   bufferIndex,u
        addb  #2
        andb  #%00011111
        stb   bufferIndex,u
        ldx   bufferBase,u
        leax  b,x          
        stx   glb.buffer

        dec   glb.frameDrop
        lbne  RunDiagonalLaser.frameDropLoop

        jsr   isInLivingArea
        lbeq  Destroy
        ; check if the laser is still alive
        ldb   laserLifetime,u
        subb  gfxlock.frameDrop.count
        stb   laserLifetime,u
        lbmi  Destroy  

        ; update hitbox position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u            
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u            
        
        jmp   DisplaySprite

InitExplosion
        ; split laser if needed
        ldx   child,u
        lda   isLastChild,x
        bne   >                 ; if next segment is last child, do not split
        ; split child
        inc   isLastChild,x     ; make 2nd segment last child
        ldx   child,x           ; 3rd segment will be new parent
        ldd   #0
        std   parent,x
        ldb   bufferIndex,u
        subb  #4*2
        andb  #%00011111
        stb   bufferIndex,x

        ; set hitbox of new parent
        lda   #2                ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,x
        _ldd  5,9               ; set hitbox xy radius (arcade radius: 12x12px)
        std   AABB_0+AABB.rx,x
        ldd   x_pos,x
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,x
        ldb   y_pos+1,x
        stb   AABB_0+AABB.cy,x  ; fixed y position for horizontal laser   
        _Collision_AddAABB_x AABB_0,AABB_list_friend

        ldy   child,x           ; 4th segment is now child of new parent
        stx   parent,y
        clr   childId,y
!
        ; init explosion
        ldb   #Rtn_RunExplosion ; replace head of laser chain by an explosion
        stb   routine,u
        clr   anim_frame,u
        ; please do not change priority here, there is a bug in priority change ...

RunExplosion
        ldx   #ExplosionImages
        ldb   anim_frame,u
        cmpb  #4
        bne   >
        jmp   Destroy
!
        aslb
        ldd   b,x
        std   image_set,u
        inc   anim_frame,u
        jmp   DisplaySprite

ExplosionImages
        fdb   Img_reboundlaser_explosion_0
        fdb   Img_reboundlaser_explosion_1
        fdb   Img_reboundlaser_explosion_2
        fdb   Img_reboundlaser_explosion_3

DiagonalVelocityPresets ; y values are inverted compared to arcade
        fdb   3  ; x velocity for up right
        fdb   -6 ; y velocity for up right
        fdb   3  ; x velocity for down right
        fdb   6  ; y velocity for down right
        fdb   -3 ; x velocity for down left
        fdb   6  ; y velocity for down left
        fdb   -3 ; x velocity for up left
        fdb   -6 ; y velocity for up left

HorizontalVelocityPresets
        fdb   3  ; x velocity for right
        fdb   -3 ; x velocity for left

ReboundPresets
        fdb   0
        fdb   6
        fdb   Img_reboundlaser_angle_0 ; /\
        fdb   -3
        fdb   0
        fdb   Img_reboundlaser_angle_1 ; >
        fdb   -3
        fdb   0
        fdb   Img_reboundlaser_angle_2 ; >
        fdb   0
        fdb   -6
        fdb   Img_reboundlaser_angle_3 ; \/
        fdb   0
        fdb   -6
        fdb   Img_reboundlaser_angle_4 ; \/
        fdb   3
        fdb   0
        fdb   Img_reboundlaser_angle_5 ; <
        fdb   3
        fdb   0
        fdb   Img_reboundlaser_angle_6 ; <
        fdb   0
        fdb   6
        fdb   Img_reboundlaser_angle_7 ; /\

DiagonalImages
        fdb   Img_reboundlaser_diagonal_0 ; right up
        fdb   Img_reboundlaser_diagonal_1 ; right down
        fdb   Img_reboundlaser_diagonal_2 ; left down
        fdb   Img_reboundlaser_diagonal_3 ; left up
