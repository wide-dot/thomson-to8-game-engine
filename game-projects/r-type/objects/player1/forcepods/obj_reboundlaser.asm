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
glb.slotsState     fcb 0 ; bit0=up, bit1=center, bit2=down
glb.frameDrop      fcb 0
glb.diagonalBuffer fdb 0

                       fill 0,32   ; spare bytes for alignment (cycling buffer)
glb.diagonalUpBuffer   equ (*/32)*32
                       fill 0,32*3 ; used to store up to 16 words group (x_pos, y_pos, image_set)
glb.diagonalDownBuffer equ (*/32)*32
                       fill 0,32*3 ; used to store up to 16 words group (x_pos, y_pos, image_set)
glb.horizontalBuffer   equ (*/32)*32
                       fill 0,32 ; used to store up to 16 words (x_pos)

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
@end    
        ; TODO snap on tile grid (3px)
        ; TODO add 1px to the right (center of the tile)
        std   x_pos,u
        ldd   y_pos,u
        ; TODO snap on tile grid (6px)
        ; TODO add 3px to the bottom (center of the tile)
        std   y_pos,u

        ; initiate the lasers
        lda   glb.slotsState
        anda  #SLOT_UP                ; is slot up active?
        bne   >                       ; if yes, skip
        ldd   #glb.diagonalUpBuffer
        std   glb.diagonalBuffer
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
        std   glb.diagonalBuffer        
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
        ldx   glb.diagonalBuffer 
        stx   bufferBase,u        
        jsr   initBuffer
        jsr   DiagonalLoadObject
        stx   parent,u
        clr   glb.childId
        ; laser length (2 or 8) based on forcepod power        
        lda   player1+forcepodlevel
        cmpa  #2
        beq   >
        jsr   DiagonalLoadObject
        jsr   DiagonalLoadObject
        jsr   DiagonalLoadObject
        jsr   DiagonalLoadObject
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
        jsr   HorizontalLoadObject
        jsr   HorizontalLoadObject
        jsr   HorizontalLoadObject
        jsr   HorizontalLoadObject
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
        std   parent,x
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
         ; check if the laser is born inside a wall
        ;ldd   x_pos,u
        ;std   terrainCollision.sensor.x
        ;ldd   y_pos,u
        ;std   terrainCollision.sensor.y
        ;ldb   #1 ; foreground
        ;jsr   terrainCollision.do
        ;tstb
        ;bne   Destroy

        ;lda   globals.backgroundSolid
        ;beq   >
        ;ldd   x_pos,u
        ;std   terrainCollision.sensor.x
        ;ldd   y_pos,u
        ;std   terrainCollision.sensor.y
        ;ldb   #0 ; background
        ;jsr   terrainCollision.do
        ;tstb
        ;bne   Destroy

        lda   routine_secondary,u
        sta   routine,u
        ldd   parent,u
        beq   >
        lda   childId,u
        inca
        asla
!       adda  #LASER_LIFETIME ; for parent a is implicitely 0
        sta   laserLifetime,u
        jmp   Object ; run the laser now
        
DoubleBufferingFlush
        rts

RunHorizontalChildLaser
        ; simplyfied code for childs
        lda   id,x
        cmpa  #ObjID_forcepod_reboundlaser
        lbne   Destroy
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
        ldd   b,y
        std   x_pos,u
        jmp   DisplaySprite

RunHorizontalLaser
        ; simplyfied code for childs
        ldx   parent,u
        bne   RunHorizontalChildLaser

        ; load buffer base
        ldy   bufferBase,u
        ldb   bufferIndex,u
        leay  b,y

        ldb  gfxlock.frameDrop.count
        stb   glb.frameDrop
RunHorizontalLaser.frameDropLoop

        ; update position
        ldx   #HorizontalVelocityPresets
        lda   direction,u
        ldd   a,x
        addd  x_pos,u
        std   x_pos,u
        std   ,y ; store new x position in history working buffer

        ; check if the laser is on edge of the screen (right)
        ; if so, skip wall collision
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #160-2 ; center of sprite is 2px from the right edge of sprite
        bhs   >

        ; check for collision with the walls
        ; TODO
!

        ; move to next position in the buffer
        ldb   bufferIndex,u
        addb  #2
        andb  #%00011111
        stb   bufferIndex,u
        ldy   bufferBase,u
        leay  b,y  

        dec   glb.frameDrop
        bne   RunHorizontalLaser.frameDropLoop

        ; no collision to walls
        jsr   isInVisibleScreen
        beq   Destroy
        ; check if the laser is still alive
        ldb   laserLifetime,u
        subb  gfxlock.frameDrop.count
        stb   laserLifetime,u
        lbmi  Destroy  

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
        jmp   DeleteObject

isInVisibleScreen
        ; check if the laser is in visible screen range
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

RunDiagonalChildLaser
        ; simplyfied code for childs
        lda   id,x
        cmpa  #ObjID_forcepod_reboundlaser
        lbne   Destroy        
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

        ; load buffer base
        ldy   bufferBase,u
        ldb   bufferIndex,u
        leay  b,y

        ldb  gfxlock.frameDrop.count
        stb   glb.frameDrop
RunDiagonalLaser.frameDropLoop

        ; update position
        ldx   #DiagonalVelocityPresets
        ldb   direction,u
        aslb
        abx
        ldd   ,x
        addd  x_pos,u
        std   x_pos,u
        std   ,y ; store new x position in history buffer
        ldd   2,x
        addd  y_pos,u
        std   y_pos,u
        std   32,y ; store new y position in history buffer

        ; check if the laser is on edge of the screen (right)
        ; if so, skip wall collision
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #160-2 ; center of sprite is 2px from the right edge of sprite
        bhs   >

        ; check for collision with the walls
        ; TODO

!

        ; no collision to walls
        ldx   #DiagonalImages
        lda   direction,u
        ldd   a,x
        std   image_set,u
        std   64,y ; store new image in history buffer

        ; move to next position in the buffer
        ldb   bufferIndex,u
        addb  #2
        andb  #%00011111
        stb   bufferIndex,u
        ldy   bufferBase,u
        leay  b,y          

        dec   glb.frameDrop
        bne   RunDiagonalLaser.frameDropLoop

        jsr   isInVisibleScreen
        lbeq  Destroy
        ; check if the laser is still alive
        ldb   laserLifetime,u
        subb  gfxlock.frameDrop.count
        stb   laserLifetime,u
        lbmi  Destroy  
        
        jmp   DisplaySprite

RunExplosion
        jmp   DisplaySprite

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
        fdb   -6
        fdb   0
        fdb   Img_reboundlaser_angle_1 ; >
        fdb   -6
        fdb   0
        fdb   Img_reboundlaser_angle_2 ; >
        fdb   0
        fdb   -6
        fdb   Img_reboundlaser_angle_3 ; \/
        fdb   0
        fdb   -6
        fdb   Img_reboundlaser_angle_4 ; \/
        fdb   6
        fdb   0
        fdb   Img_reboundlaser_angle_5 ; <
        fdb   6
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

HorizontalImages
        fdb   Img_reboundlaser_horizontal
        fdb   Img_reboundlaser_horizontal
