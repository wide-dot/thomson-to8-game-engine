; ---------------------------------------------------------------------------
; Object - Player
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Subtype : bit 0,7 : If any is 1, player does not have control of player1
;           bit 7   : If 1, player1 does not display
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/player1/player1.equ"
        
AABB_0           equ ext_variables     ; AABB struct (9 bytes)
ply_width        equ 12/2
ply_height       equ 16/2
beam_sensitivity equ 8   

Player
        lda   player1+routine
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldx   #Ani_Player1_init
        lda   player1+subtype
        bne   >
        ldx   #Ani_Player1
!
        stx   player1+anim
        ldb   #3
        stb   player1+priority
        ldd   #20
        addd  glb_camera_x_pos
        std   player1+x_pos
        ldd   #93
        std   player1+y_pos
        lda   player1+render_flags
        ora   #render_playfieldcoord_mask
        sta   player1+render_flags
        inc   player1+routine

        _Collision_AddAABB AABB_0,AABB_list_player
        
        ldx   #player1+AABB_0
        lda   #1                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  4,4                       ; set hitbox xy radius
        std   AABB.rx,x
Live
        ldd   glb_camera_x_pos
        subd  glb_camera_x_pos_old
        beq   >
        addd  player1+x_pos
        std   player1+x_pos
!
        lda   player1+subtype
        lbne  SkipPlayer1Controls
        jsr   ApplyJoypadInput
@testFire
        ; press fire
        lda   Fire_Press
        anda  #c1_button_A_mask
        beq   @testHoldFire
        jsr   LoadObject_x
        beq   @testHoldFire            ; branch if no more available object slot
        clr   soundFxDriver.newSound
        lda   #ObjID_Weapon1           ; fire !
        sta   id,x
        ldd   player1+x_pos
        std   x_pos,x
        ldd   player1+y_pos
        std   y_pos,x
@testHoldFire       
        ; holding fire ?
        lda   Fire_Held
        anda  #c1_button_A_mask
        beq   @wasbuttonhdeld           ; Nop, but let's check if it was held
        ldd   player1+beam_value
        tstb
        bne   @incharging
        cmpa  #beam_sensitivity
        blt   @incharging
                                        ; Start charging animation
        adda  gfxlock.frameDrop.count
        sta   player1+beam_value
        sta   player1+is_charging
        jsr   LoadObject_x
        beq   @end               ; branch if no more available object slot
        lda   #ObjID_beamcharge         ; Charge anim
        sta   id,x
        bra   @end
@incharging
        lda   player1+beam_value
        adda  gfxlock.frameDrop.count
        cmpa  #60                       ; Max value ?
        ble   >
        lda   #60
!
        sta   player1+beam_value
        bra   @end
@wasbuttonhdeld
        lda   player1+beam_value
        beq   @end
        cmpa  #beam_sensitivity
        ble   @resetbeam  
        adda  #4
        lsra
        lsra
        lsra
        lsra
        adda  #ObjID_beamp0
        jsr   LoadObject_x
        beq   @resetbeam                ; branch if no more available object slot
        sta   id,x
        ldd   player1+x_pos
        std   x_pos,x
        ldd   player1+y_pos
        std   y_pos,x
@resetbeam
        ldd   #0
        std   player1+beam_value
@end

        ; move and animate
SkipPlayer1Controls
!       jsr   AnimateSpriteSync
        jsr   ObjectMove
        jsr   CheckRange

        ; terrain collision
        ldd   player1+x_pos
        std   terrainCollision.sensor.x
        ldd   player1+y_pos
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   destroy

        lda   globals.backgroundSolid
        beq   >
        ldd   player1+x_pos
        std   terrainCollision.sensor.x
        ldd   player1+y_pos
        std   terrainCollision.sensor.y
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        bne   destroy
!
        ; collision to Player
        ldx   #player1+AABB_0
        lda   AABB.p,x
        beq   destroy
        ; update hitbox position
        ldd   player1+x_pos
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        ldd   player1+y_pos
        subd  glb_camera_y_pos
        stb   AABB.cy,x

        ; black screen border
        ldb   #0
        jsr   gfxlock.screenBorder.update

display
        ldb   player1+subtype            ; If bit 7 is 1, don't show player1
        bmi   >
        jmp   DisplaySprite
!       rts

destroy
        ; reset damage potential
        ldx   #player1+AABB_0
        lda   #1
        sta   AABB.p,x

        ; white screen border
        ldb   #1
        jsr   gfxlock.screenBorder.update
        bra   display

CheckRange
        ldd   player1+x_pos
        subd  glb_camera_x_pos
        cmpd  #10+ply_width
        bge   >
        ldd   glb_camera_x_pos
        addd  #10+ply_width
        std   player1+x_pos
        ldd   #0
        std   player1+x_vel
        bra   @y
!       cmpd  #10+140-ply_width
        ble   @y
        ldd   glb_camera_x_pos
        addd  #10+140
        subd  #ply_width
        std   player1+x_pos
        ldd   #0
        std   player1+x_vel
@y      ldd   player1+y_pos
        subd  glb_camera_y_pos
        cmpd  #8+ply_height
        bge   >
        ldd   glb_camera_y_pos
        addd  #8+ply_height
        std   player1+y_pos
        ldd   #0
        std   player1+y_vel
        rts
!       cmpd  #188-ply_height
        ble   >
        ldd   glb_camera_y_pos
        addd  #188
        subd  #ply_height
        std   player1+y_pos
        ldd   #0
        std   player1+y_vel
!       rts

testval fcb 0

; Apply joypad input to player velocity and position
; Uses the speed.preset table to determine velocities based on direction
; Table is organized by valid joypad combinations (8 entries per config)
; Each entry is 4 bytes: 2 bytes X velocity, 2 bytes Y velocity
ApplyJoypadInput
        ldd   #0                ; reset velocities to 0
        std   player1+x_vel
        std   player1+y_vel

@loop   jsr   joypad.buffer.getDirection
        cmpa  #$FF
        bne   >
        ; Set animation Ani_Player1, Ani_Player1_up or Ani_Player1_down based on velocity
        ldd   player1+y_vel              ; load y velocity
        bgt   @moveDown                  ; if positive, moving down
        blt   @moveUp                    ; if negative, moving up
        ldx   #Ani_Player1               ; neutral position
        bra   @setAnim
@moveDown
        ldx   #Ani_Player1_down         ; downward animation
        bra   @setAnim
@moveUp
        ldx   #Ani_Player1_up           ; upward animation
@setAnim
        stx   player1+anim              ; store animation pointer
        rts
!
        anda  #c1_dpad                               ; mask only direction bits for joypad 1
        beq   @loop
        ; Convert joypad bits to table offset using binary logic
        ; Input bits: RLDU (Right Left Down Up)
        ; First calculates 1-based index (1-8), then converts to 0-based (0-7):
        ; %0001 (Up)        -> 1 -> 0
        ; %0010 (Down)      -> 2 -> 1
        ; %0100 (Left)      -> 3 -> 2
        ; %0101 (Up+Left)   -> 4 -> 3
        ; %0110 (Down+Left) -> 5 -> 4
        ; %1000 (Right)     -> 6 -> 5
        ; %1001 (Up+Right)  -> 7 -> 6
        ; %1010 (Down+Right)-> 8 -> 7
        ; Convert RLDU to index using binary logic:
        ; 1. Check vertical (U+D): gives base 1 or 2
        ; 2. Check horizontal (R or L): adds offset +6 or +3
        ; 3. Subtract 1 to convert to 0-based index
        tfr   a,b                                    ; copy input to B
        andb  #c1_button_up_mask|c1_button_down_mask ; keep only U+D in B
        ; Convert vertical bits to base index:
        ; %01 (Up) -> 1
        ; %10 (Down) -> 2
        ; %00 (None) -> 0 (will be adjusted by horizontal)
        cmpb  #c1_button_up_mask                     ; test for UP
        bne   @notUp
        ldb   #1                                     ; UP = index 1
        bra   @testHoriz
@notUp
        cmpb  #c1_button_down_mask                   ; test for DOWN
        bne   @testHoriz
        ldb   #2                                     ; DOWN = index 2
@testHoriz
        ; Add horizontal offset:
        ; RIGHT (+6): indices 6,7,8 for Right, Up+Right, Down+Right
        ; LEFT (+3): indices 3,4,5 for Left, Up+Left, Down+Left
        bita  #c1_button_right_mask                  ; test RIGHT
        beq   @notRight
        addb  #6                                     ; RIGHT base offset
        bra   @computeOffset
@notRight
        bita  #c1_button_left_mask                   ; test LEFT
        beq   @computeOffset
        addb  #3                                     ; LEFT base offset
@computeOffset
        decb                                         ; convert 1-based to 0-based index
        lslb                                         ; multiply by 4 (each entry is 4 bytes)
        lslb
        ldx   player1+speedlevel
        abx
        leax  speed.preset,x
        ; Load velocities
        ldd   player1+x_vel
        addd  ,x                                     ; load X velocity
        std   player1+x_vel
        ldd   player1+y_vel
        addd  2,x                                    ; load Y velocity
        std   player1+y_vel
        bra   @loop

; Speed presets for player movement
; Each configuration contains only the 8 valid combinations
; Values are paired as (x velocity, y velocity) in 8.8 fixed point format
speed.preset
        ; Configuration 1
        fdb $0000,$febc         ; Up
        fdb $0000,$0144         ; Down
        fdb $ff40,$0000         ; Left
        fdb $ff7c,$ff10         ; Up+Left
        fdb $ff7c,$00f0         ; Down+Left
        fdb $00C0,$0000         ; Right
        fdb $0084,$ff10         ; Up+Right
        fdb $0084,$00f0         ; Down+Right

        ; Configuration 2
        fdb $0000,$fe08         ; Up
        fdb $0000,$01f8         ; Down
        fdb $fee0,$0000         ; Left
        fdb $ff3a,$fe98         ; Up+Left
        fdb $ff3a,$0168         ; Down+Left
        fdb $0120,$0000         ; Right
        fdb $00c6,$fe98         ; Up+Right
        fdb $00c6,$0168         ; Down+Right

        ; Configuration 3
        fdb $0000,$fd60         ; Up
        fdb $0000,$02a0         ; Down
        fdb $fe80,$0000         ; Left
        fdb $fef2,$fe20         ; Up+Left
        fdb $fef2,$01e0         ; Down+Left
        fdb $0180,$0000         ; Right
        fdb $010E,$fe20         ; Up+Right
        fdb $010E,$01e0         ; Down+Right

        ; Configuration 4
        fdb $0000,$fc28         ; Up
        fdb $0000,$03d8         ; Down
        fdb $fdc0,$0000         ; Left
        fdb $fe68,$fd48         ; Up+Left
        fdb $fe68,$02b8         ; Down+Left
        fdb $0240,$0000         ; Right
        fdb $0198,$fd48         ; Up+Right
        fdb $0198,$02b8         ; Down+Right

        ; Configuration 5
        fdb $0000,$fac0         ; Up
        fdb $0000,$0540         ; Down
        fdb $fd00,$0000         ; Left
        fdb $fde4,$fc40         ; Up+Left
        fdb $fde4,$03c0         ; Down+Left
        fdb $0300,$0000         ; Right
        fdb $021c,$fc40         ; Up+Right
        fdb $021c,$03c0         ; Down+Right

        INCLUDE "./engine/object-management/ObjectMove.asm"