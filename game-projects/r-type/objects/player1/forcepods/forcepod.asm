; ---------------------------------------------------------------------------
; forcePod
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
        INCLUDE "./objects/foefire/obj_emitter-flash.equ"

AABB_0            equ ext_variables    ; AABB struct (9 bytes)
mount_side        equ ext_variables+9  ; 1 byte
return_to_ship    equ ext_variables+10 ; 1 byte
power_level       equ ext_variables+11 ; 1 byte

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   RunFloating
        fdb   RunEjected
        fdb   RunAttached

Init_rtn        equ 0
RunFloating_rtn equ 1
RunEjected_rtn  equ 2
RunAttached_rtn equ 3

; internal variables
last_mount_side   fcb   0
offset_frame      fcb   0
rotation          fcb   0
target_x_pos      fdb   0

Init
        ldd   #0
        sta   mount_side,u
        sta   player1+forcepod_mount_side
        sta   return_to_ship,u
        sta   power_level,u
        sta   last_mount_side
        sta   offset_frame
        sta   rotation
        std   target_x_pos

        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        ldd   glb_camera_x_pos
        subd  #9-6
        std   x_pos,u  
        ldd   #96+5
        std   y_pos,u

        _Collision_AddAABB AABB_0,AABB_list_forcepod
        
        lda   #255                      ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        jsr   UpdateCollisionBox

        ; temporary TODO replace with proper animation
        ldd   #Ani_forcepod_0
        std   anim,u

        inc   routine,u                      
        rts

RunFloating
        clr   mount_side,u
        clr   player1+forcepod_mount_side

        ldd   y_vel,u
        beq   >
        sta   rotation                 ; rotation is the sign of the vertical velocity
!
        ldb   Fire_Press
        andb  #c1_button_B_mask
        beq   >
        lda   #1
        sta   return_to_ship,u         ; flag forcepod as returning to ship
!
        lda   return_to_ship,u
        beq   >

        ; if forcepod is returning to player1
        ; horizontal tracking is delayed by 30 frames
        ldx   player_pos_ring_buffer_ptr
        leax  4,x
        cmpx  #player_pos_ring_buffer+4*32
        bne   @skip_cycling
        ldx   #player_pos_ring_buffer
@skip_cycling
        ldd   ,x
        addd  glb_camera_x_pos
        bra   @continue
!
        ; if forcepod is not returning to player1
        ; horizontal tracking targets 2 preset positions
        ldd   player1+x_pos
        subd  glb_camera_x_pos
        tfr   d,x
        ldd   #36+6                    ; left target position
        cmpx  #69+6                    ; pivot point
        bge   >
        ldd   #93+6                    ; right target position
!
        addd  glb_camera_x_pos
@continue
        std   target_x_pos
        jsr   HorizontalTracking
        jsr   VerticalTracking
        jsr   AnimateFloating
        jsr   UpdateCollisionBox

        ; collision to green balls of level 4
        ; TODO

        ; collision to player1
        lda   #6                       ; player one x radius
        adda  AABB_0+AABB.rx,u
        asla
        sta   @rx
        asra
        adda  player1+p1_AABB_0+AABB.cx
        suba  AABB_0+AABB.cx,u
        cmpa  #0
@rx     equ   *-1 
        bhi   >
        lda   #6                       ; player one y radius
        adda  AABB_0+AABB.ry,u
        asla
        sta   @ry
        asra
        adda  player1+p1_AABB_0+AABB.cy
        suba  AABB_0+AABB.cy,u
        cmpa  #0
@ry     equ   *-1 
        bhi   >
        lda   #1
        sta   mount_side,u
        sta   player1+forcepod_mount_side
        sta   last_mount_side
        ldd   x_pos,u
        subd  player1+x_pos
        bcs   @mount
        clra
        sta   mount_side,u
        sta   player1+forcepod_mount_side
        sta   last_mount_side        
@mount
        lda   #RunAttached_rtn
        sta   routine,u
        lda   #1
        sta   player1+forcepod_attached
!
        lda   #255                      ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        jsr   UpdateCollisionBox

        ; upgrade forcepod
        ; TODO

        jsr   AnimateSpriteSync
        jmp   DisplaySprite

HorizontalTracking
        ; reinit forcepod to initial position if out of screen on left
        ldd   glb_camera_x_pos
        subd  #12-6
        cmpd  x_pos,u
        ble   >
        addd  #3+6
        std   x_pos,u  
        ldd   #96+5
        std   y_pos,u
!
        ; check if the forcepod hits a wall
        ldd   x_pos,u        
        addd  #3
        std   terrainCollision.sensor.x
        ldd   y_pos,u        
        std   terrainCollision.sensor.y    

        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   @rts
        lda   globals.backgroundSolid
        beq   >
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        bne   @rts
!
        ;
        ; if no wall hit, continue horizontal tracking
        ldd   glb_camera_x_pos
        subd  glb_camera_x_pos_old        
        addd  x_pos,u
        std   x_pos,u        
        ldx   gfxlock.frameDrop.count_w ; take number of elapsed frame since last render and multiply by velocity
@loop
        ldd   target_x_pos
        subd  x_pos,u
        beq   @rts
        ; compute velocity
        bcc   >
        ldd   #$ff70
        bra   @move
!       ldd   #$0090
@move
        std   x_vel,u
        ;tfr   a,b
        ; update x position
        ;sex                           ; velocity is positive or negative, take care of that
        sta   @a                       ; given the actual speed of forcepod, a is already $00 or $ff, we can use that directly
        ldd   x_pos+1,u                ; x_pos must be followed by x_sub in memory
        addd  x_vel,u
        std   x_pos+1,u                ; update low byte of x_pos and x_sub byte
        lda   x_pos,u
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
@a      equ   *-1
        sta   x_pos,u                  ; update high byte of x_pos
        leax  -1,x
        bne   @loop
@rts    rts

VerticalTracking
        lda   return_to_ship,u
        bne   >
        ldd   x_pos,u
        addd  #2
        subd  target_x_pos
        bcs   @clamp
        subd  #4
        bcc   @clamp
!
        ldx   player_pos_ring_buffer_ptr
        leax  4,x
        cmpx  #player_pos_ring_buffer+4*32
        bne   >
        ldx   #player_pos_ring_buffer
!
        ldd   2,x
        std   @old_player_y_pos
        ldx   gfxlock.frameDrop.count_w ; take number of elapsed frame since last render and multiply by velocity
@loop
        ldd   #0000
@old_player_y_pos equ *-2
        subd  y_pos,u
        bcc   >
        cmpd  #-2
        bge   @clamp
        ldd   #$fe00
        bra   @move
!               
        cmpd  #2
        ble   @clamp
        ldd   #$0180
@move
        std   y_vel,u
        tfr   a,b
        ; update y position
        sex                            ; velocity is positive or negative, take care of that
        sta   @a
        ldd   y_pos+1,u                ; y_pos must be followed by y_sub in memory
        addd  y_vel,u
        std   y_pos+1,u                ; update low byte of y_pos and y_sub byte
        lda   y_pos,u
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
@a      equ   *-1
        sta   y_pos,u                  ; update high byte of y_pos
        leax  -1,x
        bne   @loop
@clamp
        ; TODO
        rts

AnimateFloating
        rts        

RunEjected
        lda   Fire_Press
        anda  #c1_button_B_mask
        beq   >
        lda   #1
        sta   return_to_ship,u
!
        clr   mount_side,u
        clr   player1+forcepod_mount_side
        ldx   gfxlock.frameDrop.count_w ; take number of elapsed frame since last render and multiply by velocity
@loop
        pshs  x
        ; move forcepod based on velocity
        ldb   x_vel,u
        sex                            ; velocity is positive or negative, take care of that
        sta   @a                       ; given the actual speed of forcepod, a is already $00 or $ff, we can use that directly
        ldd   x_pos+1,u                ; x_pos must be followed by x_sub in memory
        addd  x_vel,u
        std   x_pos+1,u                ; update low byte of x_pos and x_sub byte
        lda   x_pos,u
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
@a      equ   *-1
        sta   x_pos,u                  ; update high byte of x_pos
         ; check if the forcepod hits a wall
        ldd   x_pos,u        
        std   terrainCollision.sensor.x
        ldd   y_pos,u        
        std   terrainCollision.sensor.y    
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   @floating
        lda   globals.backgroundSolid
        beq   >
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        bne   @floating
!       ; check if the forcepod hits screen edges
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #140
        bge   @floating
        cmpd  #14
        blt   @floating
        ;
        puls  x
        leax  -1,x
        bne   @loop        
        bra   >
@floating      
        puls  x
        lda   #RunFloating_rtn
        sta   routine,u
!
        ; TODO animate forcepod
        jsr   UpdateCollisionBox
        ; TODO handle upgrade of the forcepod
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

RunAttached
        ldd   #9
        tst   mount_side,u
        beq   >
        ldd   #-9
!        
        addd  player1+x_pos
        std   x_pos,u
        ldd   player1+y_pos
        std   y_pos,u

        jsr   UpdateCollisionBox
        ; TODO clear green balls of level 4
        ; TODO animate forcepod

        lda   Fire_Press
        anda  #c1_button_B_mask
        beq   @continue
        ldd   #$360
        tst   mount_side,u
        beq   >
        ldd   #$fca0
!       std   x_vel,u
        clr   return_to_ship,u
        lda   #RunEjected_rtn
        sta   routine,u
        clr   player1+forcepod_attached
        ;
        ; instanciate flame effect
        lda   #ObjID_emitter_flash
        jsr   LoadObject_x
        beq   @continue
        sta   id,x
        ldd   #$00f6                   ; a=0 front, b=-10 distance from parent object
        tst   mount_side,u
        beq   >
        inca                           ; a=1 back
        negb                           ; b=10 distance from parent object
!       sta   subtype,x
        sex                            ; sign extend b to a word
        std   emitterFlash.x_offset,x     
        lda   #1
        sta   emitterFlash.delay,x    
        stu   emitterFlash.parent,x        
@continue
        ; TODO handle upgrade of the forcepod
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

UpdateCollisionBox
        ldx   #CollisionRadius          ; load default collision x,y radius
        ldb   power_level,u
        aslb
        ldd   b,x
        std   AABB_0+AABB.rx,u
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u  
        rts

; TODO _Collision_RemoveAABB when downgrade forcepod (player one respawns)

CollisionRadius
        fcb   2,3
        fcb   3,5
        fcb   5,9                