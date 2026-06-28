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
        INCLUDE "./objects/foefire/obj_emitter-flash.equ"
        
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
        stx   player1+anim         ; will be overwritten by LiveBlink or Live if not in specific level 1 initphase
        ldb   #3
        stb   player1+priority
        ; --- reset état manager missile (spawn/respawn) ---
        clr   missilePairCount
        ldd   #0
        std   missileTgtTop
        std   missileTgtBot
        clr   globals.missileUnlocked  ; verrouillé au départ ; débloqué par le bonus (pow_optionbox subtype 7),
                                       ;   et perdu à la mort (Init rejoué au respawn) — fidèle arcade
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

        _Collision_AddAABB p1_AABB_0,AABB_list_player
        
        lda   #127                      ; set weak hitbox type
        sta   player1+p1_AABB_0+AABB.p
        _ldd  4,4                       ; set hitbox xy radius
        std   player1+p1_AABB_0+AABB.rx

        ldx   #Player1_AnimationSet_Normal
        stx   AnimationSet
        lda   #bank.CENTER               ; ship starts level (neutral tilt band)
        sta   ship.bankCnt
        lda   player1+subtype  
        cmpa  #1
        bne   Live
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
        lbmi  SkipPlayer1Controls      ; negative means player is not controlled
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
        ; --- missiles : gate (débloqué par bonus) + paire pas déjà en vol ---
        lda   globals.missileUnlocked
        beq   @testHoldFire
        lda   missilePairCount
        bne   @testHoldFire            ; une paire est encore en vol
        jsr   LoadObject_x              ; TOP (subtype 2, à y)
        beq   @testHoldFire
        lda   #ObjID_commonmissile
        sta   id,x
        lda   #2
        sta   subtype,x
        ldd   player1+x_pos
        std   x_pos,x
        ldd   player1+y_pos
        std   y_pos,x
        inc   missilePairCount
        jsr   LoadObject_x              ; BOTTOM (subtype 3, à y+2)
        beq   @testHoldFire
        lda   #ObjID_commonmissile
        sta   id,x
        lda   #3
        sta   subtype,x
        ldd   player1+x_pos
        std   x_pos,x
        ldd   player1+y_pos
        addd  #2
        std   y_pos,x
        inc   missilePairCount
@testHoldFire       
        ; holding fire ?
        lda   Fire_Held
        anda  #c1_button_A_mask
        beq   @wasbuttonhdeld           ; branch if button not held, so released ?
        ldb   player1+is_charging
        bne   @incharging
        ; Start charging animation
        lda   gfxlock.frameDrop.count
        asra
        inca
        adda  player1+beam_value        ; approx.
        sta   player1+beam_value
        cmpa  #5                        ; arcade value (0xf)
        lblo  @end                      ; branch if threshold not reached
        sta   player1+is_charging
        jsr   LoadObject_x
        lbeq  @end                      ; branch if no more available object slot
        lda   #ObjID_beamcharge         ; Charge anim
        sta   id,x
        jmp   @end
@incharging
        lda   gfxlock.frameDrop.count
        asra
        inca
        adda  player1+beam_value        ; approx.
        cmpa  #40                       ; Max value ?
        ble   >
        lda   #40
!       sta   player1+beam_value
        bra   @end
@wasbuttonhdeld
        ; original arcade values (at speed of 2 per frame):
        ; no beam: <24 => <8
        ; beam 0: <48 => <15
        ; beam 1: <72 => <22
        ; beam 2: <80 => <25
        ; beam 3: <104 => <33
        ; beam 4: <=128 => <=40
        lda   player1+beam_value
        ldb   #-1
        cmpa  #8
        blo   @resetbeam
        incb
        cmpa  #15
        blo   @createBeam
        incb
        cmpa  #22
        blo   @createBeam
        incb
        cmpa  #25
        blo   @createBeam
        incb
        cmpa  #33
        blo   @createBeam
        incb
@createBeam
        lda   #ObjID_beamp
        jsr   LoadObject_x
        beq   @resetbeam                ; branch if no more available object slot
        sta   id,x
        stb   subtype,x
        ldd   player1+x_pos
        tst   player1+forcepod_attached
        beq   >
        addd  #$A        
!       std   x_pos,x
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
        std   emitterFlash.parent,x
        clr   emitterFlash.delay,x        
        ldd   #$d        
        tst   player1+forcepod_attached
        beq   >
        tst   player1+forcepod_mount_side
        bne   >
        addd  #$8
!       std   emitterFlash.x_offset,x        
@resetbeam
        ldd   #0
        std   player1+beam_value
@end

        ; move and animate
SkipPlayer1Controls
        jsr   SetVerticalAnim            ; up/down/neutral frame from y_vel (joypad or autopilot)
!       jsr   AnimateSpriteSync
        jsr   ObjectMove
        jsr   CheckRange

        ; update hitbox position
        ldd   player1+x_pos
        subd  glb_camera_x_pos
        stb   player1+p1_AABB_0+AABB.cx
        ldd   player1+y_pos
        subd  glb_camera_y_pos
        stb   player1+p1_AABB_0+AABB.cy

        ; end-stage autopilot : ignore TOUS les hits (terrain + AABB), ni mort ni signal de
        ; collision. Sans ce gate, terrainCollision.do (traversee de la map du boss) part vers
        ; destroy -> bordure blanche en mode invincible, ET mort reelle en build release.
        lda   player1+subtype
        cmpa  #-2
        bne   >
        ldb   #0                          ; bordure noire (aucune collision en autopilot)
        jsr   gfxlock.screenBorder.update
        jmp   display
!
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
        lda   player1+p1_AABB_0+AABB.p
        beq   destroy

        ; black screen border
        ldb   #0
        jsr   gfxlock.screenBorder.update

display
        ldb   player1+subtype            ; If -1, don't show player1
        cmpb  #-1
        beq   >
        jmp   DisplaySprite
!       rts
        
destroy
        ; reset damage potential and beam charging value
        lda   #127                      ; set weak hitbox type
        sta   player1+p1_AABB_0+AABB.p

        ; player is invincible during blink / fade in
        ldx   AnimationSet
        cmpx  #Player1_AnimationSet_Blink
        beq   display

 IFDEF invincible
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

; ---------------------------------------------------------------------------
; Ship vertical banking (arcade run_player_one @0x2027 tilt counter).
; A counter ramps toward an extreme while the ship moves vertically and springs
; back to neutral when it stops, so the 5 tilt frames are crossed GRADUALLY in
; both directions (incl. the return), exactly like the arcade. Driven by y_vel
; so it serves joypad control AND the end-stage autopilot. The ramp and the
; spring-back advance by frameDrop.count per rendered frame -> same wall-clock
; banking speed whatever the frame drop, with clamps so a big step never
; overshoots the centre or the bounds.
;   counter 0..bank.MAX, neutral at bank.CENTER; band = (counter & 0x38) >> 2
;   y_vel < 0 (up)   -> counter toward 0        (-> full up)
;   y_vel > 0 (down) -> counter toward bank.MAX (-> full down)
;   y_vel = 0        -> counter drifts to bank.CENTER (neutral)
; ---------------------------------------------------------------------------
bank.CENTER equ 20                        ; neutral counter value (arcade 0x14)
bank.MAX    equ 39                        ; max counter value     (arcade 0x27)

SetVerticalAnim
        lda   gfxlock.frameDrop.count     ; advance the banking by the dropped frames
        sta   bank.step
        ldb   ship.bankCnt
        ldx   player1+y_vel
        beq   @toCenter                   ; no vertical move -> spring back to neutral
        bmi   @up                         ; y_vel < 0 -> bank up   (counter -> 0)
@down                                      ; y_vel > 0 -> bank down (counter -> MAX)
        addb  bank.step
        cmpb  #bank.MAX
        bls   @store
        ldb   #bank.MAX
        bra   @store
@up
        subb  bank.step
        bcc   @store                       ; no borrow -> still >= 0
        clrb                               ; underflow -> clamp to 0
        bra   @store
@toCenter
        cmpb  #bank.CENTER
        beq   @select                      ; already neutral
        bhi   @driftDown
        addb  bank.step                    ; below centre -> climb toward it
        cmpb  #bank.CENTER
        bls   @store
        ldb   #bank.CENTER                 ; do not overshoot the centre
        bra   @store
@driftDown
        subb  bank.step                    ; above centre -> fall toward it
        bcs   @clampCenter
        cmpb  #bank.CENTER
        bhs   @store
@clampCenter
        ldb   #bank.CENTER
@store
        stb   ship.bankCnt
@select
        andb  #$38                         ; 5 tilt bands: 0,8,16,24,32
        lsrb
        lsrb                               ; (counter & 0x38) >> 2 -> 0,2,4,6,8 (fdb index)
        ldy   AnimationSet
        ldx   b,y
        stx   player1+anim
        rts

bank.step    fcb 0                         ; SetVerticalAnim scratch (frames this tick)
ship.bankCnt fcb bank.CENTER              ; ship tilt counter (reset to neutral in Init)

; Apply joypad input to player velocity and position
; Uses the speed.preset table to determine velocities based on direction
; Table is organized by valid joypad combinations (8 entries per config)
; Each entry is 4 bytes: 2 bytes X velocity, 2 bytes Y velocity
ApplyJoypadInput
        ldd   #0                ; reset velocities to 0
        std   player1+x_vel
        std   player1+y_vel
        ldy   player_pos_ring_buffer_ptr

@loop   jsr   joypad.buffer.getDirection
        cmpa  #$FF
        bne   >
        rts                              ; velocities set; the up/down/neutral frame is
                                         ; chosen from y_vel in the common tail
                                         ; (SetVerticalAnim), shared with the autopilot
!
        anda  #c1_dpad                   ; mask only direction bits for joypad 1
        bne   >
        ldx   #speed.null
        bra   @setSpeed
!        
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
@setSpeed
        ; Load velocities
        ldd   ,x                                     ; load X velocity        
        addd  player1+x_vel
        std   player1+x_vel
        ldb   player1+x_vel        
        sex
        addd  player1+x_pos
        subd  glb_camera_x_pos
        std   ,y++
        ldd   2,x                                    ; load Y velocity
        addd  player1+y_vel
        std   player1+y_vel
        ldb   player1+y_vel        
        sex
        addd  player1+y_pos
        std   ,y++        
        ; update ring buffer pointer
        cmpy  #player_pos_ring_buffer+64*2
        bne   >
        ldy   #player_pos_ring_buffer
!       sty   player_pos_ring_buffer_ptr
        jmp   @loop


Dead
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

End
        lda   #1
        sta   player1+subtype                        ; set blink mode
        lda   #mainloop.state.DEAD
        sta   mainloop.state
        jmp   DisplaySprite

AnimationSet
        fdb   Player1_AnimationSet_Normal

Player1_AnimationSet_Normal              ; one pose per tilt band (0..4)
        fdb   Ani_Player1_up1            ; band 0: full up
        fdb   Ani_Player1_up0            ; band 1: up
        fdb   Ani_Player1                ; band 2: neutral
        fdb   Ani_Player1_dn0            ; band 3: down
        fdb   Ani_Player1_dn1            ; band 4: full down

Player1_AnimationSet_Blink
        fdb   Ani_Player1_blink_up1
        fdb   Ani_Player1_blink_up0
        fdb   Ani_Player1_blink
        fdb   Ani_Player1_blink_dn0
        fdb   Ani_Player1_blink_dn1

; Speed presets for player movement
; Each configuration contains only the 8 valid combinations
; Values are paired as (x velocity, y velocity) in 8.8 fixed point format
speed.null
        fdb $0000,$0000
speed.preset
        ; --- Vitesses RE-ETALEES (entorse assumee au portage 1:1, pour la
        ; jouabilite sous frame-drop). Palier 0 = vitesse arcade (inchange) ;
        ; progression H lineaire (0.75 -> 1.5 px/frame) ; vitesse max finale =
        ; ancien top / 2 (3.0 -> 1.5). Chaque palier = table arcade scalee
        ; (x1.000, x0.833, x0.750, x0.583, x0.500). Rapport H/V conserve.
        ; Configuration 1   (x1.000)  H=0.750
        fdb $0000,$febc         ; Up
        fdb $0000,$0144         ; Down
        fdb $ff40,$0000         ; Left
        fdb $ff7c,$ff10         ; Up+Left
        fdb $ff7c,$00f0         ; Down+Left
        fdb $00c0,$0000         ; Right
        fdb $0084,$ff10         ; Up+Right
        fdb $0084,$00f0         ; Down+Right

        ; Configuration 2   (x0.833)  H=0.938
        fdb $0000,$fe5c         ; Up
        fdb $0000,$01a4         ; Down
        fdb $ff10,$0000         ; Left
        fdb $ff5b,$fed4         ; Up+Left
        fdb $ff5b,$012c         ; Down+Left
        fdb $00f0,$0000         ; Right
        fdb $00a5,$fed4         ; Up+Right
        fdb $00a5,$012c         ; Down+Right

        ; Configuration 3   (x0.750)  H=1.125
        fdb $0000,$fe08         ; Up
        fdb $0000,$01f8         ; Down
        fdb $fee0,$0000         ; Left
        fdb $ff36,$fe98         ; Up+Left
        fdb $ff36,$0168         ; Down+Left
        fdb $0120,$0000         ; Right
        fdb $00ca,$fe98         ; Up+Right
        fdb $00ca,$0168         ; Down+Right

        ; Configuration 4   (x0.583)  H=1.312
        fdb $0000,$fdc2         ; Up
        fdb $0000,$023e         ; Down
        fdb $feb0,$0000         ; Left
        fdb $ff12,$fe6a         ; Up+Left
        fdb $ff12,$0196         ; Down+Left
        fdb $0150,$0000         ; Right
        fdb $00ee,$fe6a         ; Up+Right
        fdb $00ee,$0196         ; Down+Right

        ; Configuration 5   (x0.500)  H=1.500
        fdb $0000,$fd60         ; Up
        fdb $0000,$02a0         ; Down
        fdb $fe80,$0000         ; Left
        fdb $fef2,$fe20         ; Up+Left
        fdb $fef2,$01e0         ; Down+Left
        fdb $0180,$0000         ; Right
        fdb $010e,$fe20         ; Up+Right
        fdb $010e,$01e0         ; Down+Right

        INCLUDE "./engine/object-management/ObjectMove.asm"
