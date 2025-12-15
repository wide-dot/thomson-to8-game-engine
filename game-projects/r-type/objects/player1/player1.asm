 opt c
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
        INCLUDE "./objects/soundFX/soundFX.const.asm"
        INCLUDE "./engine/sound/soundFX.macro.asm"
        INCLUDE "./engine/objects/sound/ymm/ymm.macro.asm"
        
AABB_0           equ ext_variables     ; AABB struct (9 bytes)

ply_width        equ 12/2
ply_height       equ 16/2

Init_routine       equ 0
LiveBlink_routine  equ 1
Live_routine       equ 2
Dead_routine       equ 3
End_routine        equ 4

Player
        lda   player1+routine
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   LiveBlink
        fdb   Live
        fdb   Dead
        fdb   End        

Init
        ldx   #Ani_Player1_init
        lda   player1+subtype
        bne   >
        ldx   #Ani_Player1
!
        stx   player1+anim
        ldb   #3
        stb   player1+priority
        ldd   #60
        addd  glb_camera_x_pos
        std   player1+x_pos
        ldd   #93
        std   player1+y_pos
        lda   player1+render_flags
        ora   #render_playfieldcoord_mask
        sta   player1+render_flags
        lda   #Live_routine
        sta   player1+routine

        _Collision_AddAABB AABB_0,AABB_list_player
        
        lda   #127                      ; set weak hitbox type
        sta   player1+AABB_0+AABB.p
        _ldd  4,4                       ; set hitbox xy radius
        std   player1+AABB_0+AABB.rx

        ldd   #$F
        std   player1+flashemitteroffset

        ldx   AnimationSet
        cmpx  #Player1_AnimationSet_Normal
        beq   Live
        ldx   #Player1_AnimationSet_Blink
        stx   AnimationSet
        lda   #LiveBlink_routine
        sta   player1+routine

LiveBlink
        ; player is invincible during fade in
        ldx   #palettefade
        lda   routine,x
        cmpa  #o_fade_routine_idle
        bne   Live
        lda   #Live_routine
        sta   player1+routine
        ldx   #Player1_AnimationSet_Normal
        stx   AnimationSet
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
        lda   #ObjID_Weapon            ; fire !
        sta   id,x
        ldd   player1+x_pos
        std   x_pos,x
        ldd   player1+y_pos
        std   y_pos,x
@testHoldFire       
        ; holding fire ?
        lda   Fire_Held
        anda  #c1_button_A_mask
        beq   @wasbuttonhdeld           ; branch if button not held, so released ?
        ldd   player1+beam_value        : beam_value / is_charging
        tstb
        bne   @incharging
        ; Start charging animation
        adda  gfxlock.frameDrop.count
        sta   player1+beam_value
        cmpa  #15                       ; arcade value (0xf)
        blo   @end                      ; branch if threshold not reached
        sta   player1+is_charging
        jsr   LoadObject_x
        beq   @end                      ; branch if no more available object slot
        lda   #ObjID_beamcharge         ; Charge anim
        sta   id,x
        bra   @end
@incharging
        lda   player1+beam_value
        adda  gfxlock.frameDrop.count
        cmpa  #60                       ; Max value ?
        ble   >
        lda   #60
!       sta   player1+beam_value
        bra   @end
@wasbuttonhdeld
        ; original arcade values (at speed of 2 per frame):
        ; no beam: <24 => <12
        ; beam 0: <48 => <23
        ; beam 1: <72 => <34
        ; beam 2: <80 => <38
        ; beam 3: <104 => <49
        ; beam 4: <=128 => <=60
        lda   player1+beam_value
        ldb   #-1
        cmpa  #12
        blo   @resetbeam
        incb
        cmpa  #23
        blo   @createBeam
        incb
        cmpa  #34
        blo   @createBeam
        incb
        cmpa  #38
        blo   @createBeam
        incb
        cmpa  #49
        blo   @createBeam
        incb
@createBeam
        lda   #ObjID_beamp
        jsr   LoadObject_x
        beq   @resetbeam                ; branch if no more available object slot
        sta   id,x
        stb   subtype,x
        ldd   player1+x_pos
        addd  player1+flashemitteroffset
        subd  #$F
        std   x_pos,x
        ldd   player1+y_pos
        subd  #2
        std   y_pos,x
        lda   #ObjID_emitter_flash
        jsr   LoadObject_x
        beq   @resetbeam 
        sta   id,x
        lda   #$1
        sta   subtype,x
        ldd   #player1
        std   ext_variables,x
@resetbeam
        ldd   #0
        std   player1+beam_value
@end

        ; move and animate
SkipPlayer1Controls
!       jsr   AnimateSpriteSync
        jsr   ObjectMove
        jsr   CheckRange

        ; update hitbox position
        ldd   player1+x_pos
        subd  glb_camera_x_pos
        stb   player1+AABB_0+AABB.cx
        ldd   player1+y_pos
        subd  glb_camera_y_pos
        stb   player1+AABB_0+AABB.cy

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
        lda   player1+AABB_0+AABB.p
        beq   destroy

        ; black screen border
        ldb   #0
        jsr   gfxlock.screenBorder.update

display
        ldb   player1+subtype            ; If bit 7 is 1, don't show player1
        bmi   >
        jmp   DisplaySprite
!       rts

destroy
        ; reset damage potential and beam charging value
        lda   #127                      ; set weak hitbox type
        sta   player1+AABB_0+AABB.p

        ; player is invincible during blink / fade in
        ldx   AnimationSet
        cmpx  #Player1_AnimationSet_Blink
        beq   display

 IFDEF invincible
        ; white screen border
        ldb   #1
        jsr   gfxlock.screenBorder.update
 ELSE
        ldd   #0
        std   player1+beam_value
        _ymm.stop
        _soundFX.play soundFX.PlayerHitSound,$85
        ldd   #Ani_Player1_explode
        std   anim,u
        lda   #Dead_routine
        sta   player1+routine
        ldd   #$0000
        std   scroll_vel
 ENDC
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
        ldy   AnimationSet

@loop   jsr   joypad.buffer.getDirection
        cmpa  #$FF
        bne   >
        ; Set animation Ani_Player1, Ani_Player1_up or Ani_Player1_down based on velocity
        ldd   player1+y_vel              ; load y velocity
        bgt   @moveDown                  ; if positive, moving down
        blt   @moveUp                    ; if negative, moving up
        ldx   ,y                         ; neutral position
        bra   @setAnim
@moveDown
        ldx   4,y                        ; downward animation
        bra   @setAnim
@moveUp
        ldx   2,y                        ; upward animation
@setAnim
        stx   player1+anim               ; store animation pointer
        rts
!
        anda  #c1_dpad                   ; mask only direction bits for joypad 1
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

Dead
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

End
        ldx   #Player1_AnimationSet_Blink
        stx   AnimationSet
        lda   #mainloop.state.DEAD
        sta   mainloop.state
        jmp   DisplaySprite

AnimationSet
        fdb   Player1_AnimationSet_Normal

Player1_AnimationSet_Normal
        fdb   Ani_Player1
        fdb   Ani_Player1_up
        fdb   Ani_Player1_down

Player1_AnimationSet_Blink        
        fdb   Ani_Player1_blink
        fdb   Ani_Player1_blink_up
        fdb   Ani_Player1_blink_down

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