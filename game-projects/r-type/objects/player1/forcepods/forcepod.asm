; ---------------------------------------------------------------------------
; forcePod
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; arcade original code:
; INITIAL STATE
; -------------------
; up rotation
;
; FLOATING
; -------------------
; pod direction (up: up rotation, down: down rotation, no vertical velocity: keep last rotation)
; pod min - frameDuration: 4, rotation based on pod last vertical velocity
; pod mid - frameDuration: 4, rotation based on pod last vertical velocity, flipped rear/front
; pod max - frameDuration: 8, rotation based on pod last vertical velocity
;
; ATTACHED
; -------------------
; player direction (up: up rotation, down: down rotation, no vertical velocity: left: up rotation, right: down rotation)
; pod min - frameDuration: 4, rotation based on player direction
; pod mid - frameDuration: 4, rotation based on player direction, image flipped rear/front
; pod max - frameDuration: 8, rotation based on player direction
;
; EJECTED
; -------------------
; pod min - frameDuration: 2, down rotation
; pod mid - frameDuration: 2, down rotation, flipped rear/front
; pod max - frameDuration: 2, down rotation
; ---------------------------------------------------------------------------

        ; TODO SHOULD IMPLEMENT A WHATEVER KEYBOARD PRESS TO EJECT FORCEPOD
        ; THAT WILL not update E7C3 !!!!!!!!!!!!! UNLIKE ROM CODE !!!

        ; TODO _Collision_RemoveAABB when downgrade forcepod (player one respawns)

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/player1/player1.equ"
        INCLUDE "./objects/soundFX/soundFX.const.asm"
        INCLUDE "./engine/sound/soundFX.macro.asm"
        INCLUDE "./objects/foefire/obj_emitter-flash.equ"

AABB_0            equ ext_variables    ; AABB struct (9 bytes)
mount_side        equ ext_variables+9  ; 1 byte (0: front, 1: rear)
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
rotation          fcb   0 ; negative value for up rotation, positive value for down rotation
target_x_pos      fdb   0
impact_min        fcb   0
impact_x_f_row0   fcb   0
impact_x_f_row1   fcb   0
impact_x_b_row1   fcb   0
impact_x_f_row2   fcb   0
upper_solid_tiles fcb   0
lower_solid_tiles fcb   0
closed_path       fcb   0

Init
        ldd   #0
        sta   mount_side,u
        sta   player1+forcepod_mount_side
        sta   return_to_ship,u
        sta   last_mount_side
        sta   offset_frame
        sta   power_level,u            ; no level, force animation to be set
        std   target_x_pos

        lda   #-1
        sta   rotation                 ; default to up rotation

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
        jsr   checkForcePodUpdate                
        jsr   UpdateCollisionBox

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
        jsr   checkForcePodUpdate
        jsr   UpdateCollisionBox

        ; TODO collision to green balls of level 4

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
        ; rear side mount
        lda   #1
        sta   mount_side,u
        sta   player1+forcepod_mount_side
        sta   last_mount_side
        lda   render_flags,u
        anda  #^render_xmirror_mask
        ora   #1
        sta   render_flags,u
        ;        
        ldd   x_pos,u
        subd  player1+x_pos
        bcs   @rear
        ; front side mount
        clra
        sta   mount_side,u
        sta   player1+forcepod_mount_side
        sta   last_mount_side      
        lda   render_flags,u
        anda  #^render_xmirror_mask
        ora   #0
        sta   render_flags,u          
@rear
        lda   #RunAttached_rtn
        sta   routine,u
        lda   #1
        sta   player1+forcepod_attached
!
        lda   #255                      ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        jsr   checkForcePodUpdate        
        jsr   UpdateCollisionBox
        jsr   AnimateForcePodSync
        jsr   DisplaySprite
        jmp   ForcePodDetachedFire

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
        ; update x position
        sta   @a                       ; given the actual speed of forcepod, a is already $00 or $ff
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
        ; check terrain collision
        ; there are 3 rows of 9 sensors to check for collision
        ; middle row is centered on the forcepod vertically and is tested against background and foreground
        ; top and bottom rows are tested against foreground only
        ; sensors are positioned from the left edge of the forcepod, so offset to forcepod x positions are:
        ; -8 0 +8 +16 +24 +32 +40 +48 +56 (0 is the x center of forcepod)
        ; in arcade, test are made from left to right, by testing the column of sensors, when a collision is detected it stops
        ; and find a path vertically to avoid the collision
        ; for our code it is faster to test row by row

        ; middle row
        ldd   x_pos,u
        subd  #3
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.xAxis.doRight
        ldd   terrainCollision.impact.x
        beq   @noIpct
        subd  terrainCollision.sensor.x
        addd  #3
        cmpd  #9*3
        blo   >
@noIpct ldb   #-1
!       stb   impact_x_f_row1

        lda   globals.backgroundSolid
        beq   @noIpct
        clrb  ; background
        jsr   terrainCollision.xAxis.doRight
        ldd   terrainCollision.impact.x
        beq   @noIpct
        subd  terrainCollision.sensor.x
        addd  #3
        cmpd  #9*3
        blo   >
@noIpct ldb   #-1
!       stb   impact_x_b_row1

        ; bottom row
        ldd   y_pos,u
        addd  #6
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.xAxis.doRight
        ldd   terrainCollision.impact.x
        beq   @noIpct
        subd  terrainCollision.sensor.x
        addd  #3        
        cmpd  #9*3
        blo   >
@noIpct ldb   #-1
!       stb   impact_x_f_row2

        ; top row
        ldd   y_pos,u
        subd  #6
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.xAxis.doRight
        ldd   terrainCollision.impact.x
        beq   @noIpct
        subd  terrainCollision.sensor.x
        addd  #3        
        cmpd  #9*3
        blo   >
@noIpct ldb   #-1
!       stb   impact_x_f_row0

        ; resolution ...
        ; testing for background collision first
        ldb   impact_x_b_row1
        bmi   >                                    ; skip if no background collision
        ldb   impact_x_f_row1                      ; if a background collision is detected, should check if foreground collision is closer
        lbmi  VerticalTracking.backgroundCollision ; if no foreground collision, use background collision
        cmpb  impact_x_b_row1                      ; compare foreground and background collision
        ble   >                                    ; if foreground collision is closer, skip background collision and continue with foreground collision
        jmp   VerticalTracking.backgroundCollision
!
        ; testing for foreground collision
        ; keep lowest value that is > 0
        lda   #-1
        sta   impact_min        ; row 0 test
        ldb   impact_x_f_row0
        bmi   >
        stb   impact_min
!       
        ldb   impact_x_f_row1 ; row 1 test
        bmi   >
        lda   impact_min
        bmi   @store1
        cmpb  impact_min
        bge   >
@store1 stb   impact_min
!
        ldb   impact_x_f_row2 ; row 2 test
        bmi   >
        lda   impact_min
        bmi   @store2
        cmpb  impact_min
        bge   >
@store2 stb   impact_min
!
        clra
        ldb   impact_min
        bmi   >
        jmp   VerticalTracking.foregroundCollision
!
        ; no collision detected, continue
        ; I choosed to not implement arcade code here, for simplicity sake.
        ; Instead of making a "pause" one frame on two in vertical velocity,
        ; I simply divided the speed by two
        ; vertical tracking
        lda   return_to_ship,u
        bne   >
        ldd   x_pos,u
        addd  #2
        subd  target_x_pos
        bcs   VerticalTracking.clampPosition
        subd  #4
        bcc   VerticalTracking.clampPosition
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
        bge   VerticalTracking.clampPosition
        ldd   #$ff40
        bra   VerticalTracking.updatePosition
!               
        cmpd  #2
        ble   VerticalTracking.clampPosition
        ldd   #$00c0
VerticalTracking.updatePosition
        std   y_vel,u
        ; update y position
        sta   @a                       ; given the actual speed of forcepod, a is already $00 or $ff
        ldd   y_pos+1,u                ; y_pos must be followed by y_sub in memory
        addd  y_vel,u
        std   y_pos+1,u                ; update low byte of y_pos and y_sub byte
        lda   y_pos,u
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
@a      equ   *-1
        sta   y_pos,u                  ; update high byte of y_pos
        leax  -1,x
        bne   @loop
VerticalTracking.clampPosition
        ; clamp vertical position to screen bounds
        ldd   y_pos,u
        cmpd  #11+7
        bhs   >
        ldd   #11+7
        std   y_pos,u
        rts
!
        cmpd  #11+viewport_height-7
        bls   >
        ldd   #11+viewport_height-7
        std   y_pos,u
!
        rts

VerticalTracking.foregroundCollision
        ; offset in pixels to detected wall is already in d
        addd  x_pos,u
        subd  #3
        std   terrainCollision.sensor.x

        ldd   #0
        std   upper_solid_tiles ; and lower_solid_tiles
        sta   closed_path

        ldd   y_pos,u
@loopUp
        subd  #6
        std   terrainCollision.sensor.y        
        cmpd  #11
        bge   >
        inc   closed_path
        bra   @continue
!
        ; count upper solid tiles from tile impact
        inc   upper_solid_tiles
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   @continue
        ldd   terrainCollision.sensor.y
        bra   @loopUp
@continue
        ldd   y_pos,u
@loopDown
        addd  #6
        std   terrainCollision.sensor.y
        cmpd  #11+viewport_height
        blt   >
        lda   closed_path
        adda  #2
        sta   closed_path
        bra   @end
!
        ; count lower solid tiles from tile impact
        inc   lower_solid_tiles
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        beq   @end
        ldd   terrainCollision.sensor.y
        bra   @loopDown
@end
        lda   closed_path
        beq   @fastestPath ; branch if both upper and lower direction have a path        
        cmpa  #3 ; solid tiles detected both up to top and bottom screen border
        bne   >
        rts ; doing more in arcade, but found it pointless, so we stop here
!       cmpa  #1
        beq   >
        ldd   #$ff40        
        bra   VerticalTracking.applyVelocity
!       ldd   #$00c0        
        bra   VerticalTracking.applyVelocity
@fastestPath
        lda   upper_solid_tiles
        cmpa  lower_solid_tiles
        bhi   <
        ldd   #$ff40

VerticalTracking.applyVelocity
        std   y_vel,u
        ldx   gfxlock.frameDrop.count_w ; take number of elapsed frame since last render and multiply by velocity
        sta   @a                       ; given the actual speed of forcepod, a is already $00 or $ff
@loop
        ldd   y_pos+1,u                ; y_pos must be followed by y_sub in memory
        addd  y_vel,u
        std   y_pos+1,u                ; update low byte of y_pos and y_sub byte
        lda   y_pos,u
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
@a      equ   *-1
        sta   y_pos,u                  ; update high byte of y_pos
        leax  -1,x
        bne   @loop
        jmp   VerticalTracking.clampPosition

VerticalTracking.backgroundCollision
        clra
        ldb   impact_x_b_row1
        addd  x_pos,u
        subd  #3
        std   terrainCollision.sensor.x

        ldd   #0
        std   upper_solid_tiles ; and lower_solid_tiles

        ldd   y_pos,u
@loopUp
        subd  #6
        std   terrainCollision.sensor.y        
        cmpd  #11
        blt   @continue
        ;
        ; count upper solid tiles from tile impact
        inc   upper_solid_tiles
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        beq   @continue
        ldd   terrainCollision.sensor.y
        bra   @loopUp
@continue
        ldd   y_pos,u
@loopDown
        addd  #6
        std   terrainCollision.sensor.y
        cmpd  #11+viewport_height
        bge   @end
        ;
        ; count lower solid tiles from tile impact
        inc   lower_solid_tiles
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        beq   @end
        ldd   terrainCollision.sensor.y
        bra   @loopDown
@end
        lda   upper_solid_tiles
        cmpa  lower_solid_tiles
        bhi   >
        ldd   #$ff40
        jmp   VerticalTracking.applyVelocity
!       ldd   #$00c0        
        jmp   VerticalTracking.applyVelocity

RunEjected
        clr   rotation

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
        sta   @a
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
        jsr   checkForcePodUpdate
        jsr   UpdateCollisionBox
        jsr   AnimateForcePodSyncEjected
        jsr   DisplaySprite
        jmp   ForcePodDetachedFire

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

        ldd   player1+y_vel
        beq   >
        sta   rotation                 ; rotation is the sign of the vertical velocity
        bra   @end
!       ldd   player1+x_vel
        beq   @end
        sta   rotation                 ; use horizontal velocity if no vertical velocity
@end
        jsr   checkForcePodUpdate
        jsr   UpdateCollisionBox

        ; TODO clear green balls of level 4

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
        ldb   #2 ; reset frame duration to fixed speed for ejected forcepod
        stb   anim_frame_duration,u
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
        jsr   AnimateForcePodSync
        jsr   DisplaySprite

ForcePodAttachedFire        
        ldb   Fire_Press
        andb  #c1_button_A_mask
        beq   @rts
        ldb   power_level,u
        subb  #2
        beq   @reboundlaser
        decb
        beq   @counterairlaser
        rts
@reboundlaser
        jsr   LoadObject_x
        beq   @rts
        lda   #ObjID_forcepod_reboundlaser
        bra   >  
@counterairlaser
        jsr   LoadObject_x
        beq   @rts
        lda   #ObjID_forcepod_counterairlaser
!
        sta   id,x
        lda   mount_side,u
        sta   subtype,x
@rts    rts

ForcePodDetachedFire
        ldb   Fire_Press
        andb  #c1_button_A_mask
        beq   @rts
        jsr   LoadObject_x
        beq   @rts                          ; branch if no more available object slot
        lda   #ObjID_forcepod_straightup    ; fire straight up !
        sta   id,x
        stu   ext_variables+9,x
        jsr   LoadObject_x
        beq   @rts                          ; branch if no more available object slot
        lda   #ObjID_forcepod_straightdown  ; fire straight up !
        sta   id,x
        stu   ext_variables+9,x
@rts    rts

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

CollisionRadius equ *-2 ; forcepod level begins at 1
        fcb   2,3
        fcb   3,5
        fcb   5,9

ForcePodAnimations equ *-2 ; forcepod level begins at 1
        fdb   Ani_forcepod_0
        fdb   Ani_forcepod_1
        fdb   Ani_forcepod_2

        fcb   6-1 ; frames
        fcb   4-1 ; anim frame duration
Ani_forcepod_0
        fdb   Img_forcepod_0_0
        fdb   Img_forcepod_0_1
        fdb   Img_forcepod_0_2
        fdb   Img_forcepod_0_3
        fdb   Img_forcepod_0_4
        fdb   Img_forcepod_0_5
        fcb   -1

        fcb   6-1 ; frames
        fcb   4-1 ; anim frame duration
Ani_forcepod_1
        fdb   Img_forcepod_1_0
        fdb   Img_forcepod_1_1
        fdb   Img_forcepod_1_2
        fdb   Img_forcepod_1_3
        fdb   Img_forcepod_1_4
        fdb   Img_forcepod_1_5
        fcb   -1

        fcb   4-1 ; frames
        fcb   8-1 ; anim frame duration
Ani_forcepod_2
        fdb   Img_forcepod_2_0
        fdb   Img_forcepod_2_1
        fdb   Img_forcepod_2_2
        fdb   Img_forcepod_2_3
        fcb   -1

checkForcePodUpdate
        ldb   player1+forcepodlevel
        cmpb  power_level,u
        beq   @rts
        stb   power_level,u
        aslb
        ldx   #ForcePodAnimations
        ldd   b,x
        std   anim,u        
@rts    rts     

AnimateForcePodSync
        lda   rotation
        bmi   AnimateForcePodSyncUp

AnimateForcePodSyncDown        
        ldx   anim,u
        cmpx  prev_anim,u
        beq   >
        stx   prev_anim,u
        bra   @resetFWD
!
        ldb   anim_frame_duration,u
        subb  gfxlock.frameDrop.count
        stb   anim_frame_duration,u
        bpl   @rts
@b      ldb   -1,x
        stb   anim_frame_duration,u
        ldb   anim_frame,u
        incb
        stb   anim_frame,u        
        aslb
        ldd   b,x
        cmpa  #-1
        beq   @resetFWD
!       std   image_set,u
@rts    rts
@resetFWD
        clr   anim_frame,u        
        ldd   ,x
        bra   <

AnimateForcePodSyncUp
        ldx   anim,u
        cmpx  prev_anim,u
        beq   >
        stx   prev_anim,u
        bra   @resetRWD
!
        ldb   anim_frame_duration,u
        subb  gfxlock.frameDrop.count
        stb   anim_frame_duration,u
        bpl   @rts
@b      ldb   -1,x
        stb   anim_frame_duration,u
        ldb   anim_frame,u
        decb
        bmi   @resetRWD
        stb   anim_frame,u        
!       aslb
        ldd   b,x
        std   image_set,u
@rts    rts
@resetRWD
        ldb   -2,x
        stb   anim_frame,u        
        bra   <

AnimateForcePodSyncEjected
        ldx   anim,u
        cmpx  prev_anim,u
        beq   >
        stx   prev_anim,u
        bra   @resetFWD
!
        ldb   anim_frame_duration,u
        subb  gfxlock.frameDrop.count
        stb   anim_frame_duration,u
        bpl   @rts
@b      ldb   #2 ; fixed speed for ejected forcepod
        stb   anim_frame_duration,u
        ldb   anim_frame,u
        incb
        stb   anim_frame,u        
        aslb
        ldd   b,x
        cmpa  #-1
        beq   @resetFWD
!       std   image_set,u
@rts    rts
@resetFWD
        clr   anim_frame,u        
        ldd   ,x
        bra   <