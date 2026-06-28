 opt c

DEBUG   equ     1
SOUND_CARD_PROTOTYPE equ 1
;DEBUG_START_LAST_CHECKPOINT equ 1    ; debug: start the stage at the last checkpoint (comment out to start from the beginning)

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/objects/palette/fade/fade.equ"
        INCLUDE "./global/macro.asm"
        INCLUDE "./global/variables.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./engine/objects/collision/terrainCollision.macro.asm"
        INCLUDE "./global/scale.asm"
        INCLUDE "./global/object.const.asm"
        INCLUDE "./objects/player1/forcepods/forcepod.equ"  ; rtnid.* (force pod routine ids; static slot seeding)
        INCLUDE "./objects/player1/bitdevice/bitdevice.equ"  ; bitdev.rtnid.* (bit device routine ids; static slot seeding)
        INCLUDE "./engine/objects/sound/ymm/ymm.macro.asm"
        INCLUDE "./objects/messages/messages.const.asm"

timestamp.DELETE_ALIEN_BODY equ $1D80
timestamp.ERASE_NERV_START equ $1BDF+$B80 ; nerves auto-effacees (free-life). Arcade: T0 ($1BDF,
                                     ;   spawn monstre) + intro $280 + free-life +0x3E $900 = T0+$B80.
                                     ;   Filet de securite : en jeu normal halfDamage (monstre mi-vie)
                                     ;   ou le tir du joueur tue les nerves bien avant.
timestamp.NERV_VULNERABLE  equ $1BDF+$280 ; nerves (eyes) armables. Arcade: create_dobkeratops
                                     ;   spawn monstre + nerves ENSEMBLE (T0), nerve +0x22=$280
                                     ;   d'intro -> vulnerable a T0+$280. Le portage etale les
                                     ;   spawns wave (orbites $1B7C, monstre $1BDF) : on ancre sur
                                     ;   le spawn du MONSTRE ($1BDF, = T0 arcade) + $280.
timestamp.BOSS_ESCAPE      equ $1BDF+$1000 ; boss escape / end-stage. Arcade: parent run_dobkeratops
                                     ;   +0x3E engagement timeout $1000 depuis T0 (= spawn monstre $1BDF)
timestamp.MOVEALIEN_DELAY  equ 140   ; frames between last nerve death and alien move out
timestamp.MOVEALIEN_SPEED  equ $18   ; followDobkeratops leftward speed, 8.8 fixed (=24/256 px/frame)
timestamp.MOVEALIEN_DIST   equ 60    ; px the boss travels left before it stops on the butee to explode

endstage.DURATION equ $C0            ; arcade: run_dobkeratops arms +0x22 = $C0 frames
endstage.JINGLE   equ $10            ; arcade: jingle + ship autopilot fire when the countdown reaches $10
endstage.RALLY_X  equ 80             ; arcade X $200: CoordinatesConv round((512-320)*144/384)+8 = 80
endstage.RALLY_Y  equ 130            ; arcade Y $E0: CoordinatesConv round((224-128-16)*-180/240)+190 = 130 (arcade Y axis is up, flipped)
endstage.DEADBAND equ 3              ; per axis dead band in px (arcade: 4 px)
endstage.bossStopX equ 1396          ; camera x that frames the boss room (was the old map_width-viewport_width)

; ObjID_endstage mounted-object protocol (logic lives in obj_endstage.asm)
endstage.TICK          equ 0         ; command: run the end of stage tick
endstage.INIT          equ 1         ; command: reset boss sequencing state
endstage.BLIT          equ 2         ; command: boss tile-erase black blits (call inside the gfx lock)
endstage.STATUS_NONE   equ 0         ; status: nothing to do
endstage.STATUS_JINGLE equ 1         ; status: main must start the stage clear jingle

; ObjID_hud command protocol (logic lives in objects/levels/hud/hud.asm)
hud.NORMAL  equ 0                    ; command: draw the bottom HUD (beam, lives, score)
hud.READOUT equ 1                    ; command: tick + draw the centered stage-score readout

moveByScript.NEGXSTEP equ scale.XN1PX
moveByScript.POSXSTEP equ scale.XP1PX
moveByScript.NEGYSTEP equ scale.YN1PX
moveByScript.POSYSTEP equ scale.YP1PX

map_width       equ 1584             ; full map (132 cols x 12px); the boss scroll-stop is endstage.bossStopX
viewport_width  equ 144
viewport_height equ 180

        org   $6100
Level01_Start
        clr   globals.nextGameMode
        jsr   InitGlobals
	jsr   InitDrawSprites
        lda   #0
        sta   globals.difficulty

        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads
        jsr   InitRNG
        _terrainCollision.init ObjID_collision
        _RunObjectRoutineB ObjID_endstage,#endstage.INIT ; reset boss sequencing state

        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
	jsr   PalUpdateNow

; register animation data object
        ldb   #ObjID_animation
        jsr   moveByScript.register

; init globals.score and globals.lives at level 1
        ldd   #0
        std   globals.score
        clr   globals.score+2           ; clear 3rd score byte (24-bit)
        std   globals.stageScoreBase    ; stage-score base = score at stage start (D=0; multistage-ready)
        clr   globals.stageScoreBase+2  ; clear 3rd base byte (24-bit)
        ldb   #2
        stb   globals.lives
        lda   #1
        sta   globals.backgroundSolid

; register map locations for scroll
        _MountObject ObjID_LevelInit
        jsr   ,x

        _MountObject ObjID_LevelWave
        jsr   ,x

        jsr   gfxlock.bufferSwap.do
        jsr   RunObjects

; init scroll
        jsr   InitScroll
 IFDEF DEBUG_START_LAST_CHECKPOINT
        lda   #254                     ; >= last checkpoint, < the -1 sentinel: checkpoint.load picks the last one
        sta   scroll_tile_pos
 ENDC
        _MountObject ObjID_checkpoint
        jsr   ,x
        
; play music
        _MountObject ObjID_ymm01
        _MusicInit_objymm #0,#MUSIC_LOOP,#0  ; initialize the YM2413 player 
        ;_MountObject ObjID_vgc01
        ;_MusicInit_objvgc #0,#MUSIC_LOOP,#0 ; initialize the SN76489 vgm player with a vgc data stream

; init user irq
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        lda   #8                       ; cap frame-drop: 4px tile-erase trail / 0.5px-per-arcade-frame
        sta   gfxlock.frameDrop.max     ; -> no scroll artifact when frames are dropped
        jsr   IrqOn

* ---------------------------------------------------------------------------
* INIT PLAYER 1 ANIMATION
* ---------------------------------------------------------------------------
        jsr   LoadObject_x
        lda   #ObjID_initlevel1
        sta   id,x

* ---------------------------------------------------------------------------
* INIT STATIC PLAYER-WEAPON SLOTS
* The force pod is a static OST (forcepodOST) run every frame after player1.
* Seed it Dormant so it idles in place from frame 1: routine 0 = its Init/spawn,
* which must NOT run until the player collects the force-pod bonus (pow_optionbox
* then sets routine=rtnid.Init). See objects/player1/forcepods/forcepod.equ.
* ---------------------------------------------------------------------------
        ldu   #forcepodOST
        lda   #rtnid.Dormant
        sta   routine,u
* The two bit-device slots (bitdevTopOST/bitdevBotOST) are static OSTs run every
* frame after the force pod. Seed them Dormant too: routine 0 = the pickup's Init
* (must never run on a static slot); each is activated by a bit-device pickup
* (bitdevice.asm Collect -> bitdev.rtnid.ActiveInit). See bitdevice.equ.
        ldu   #bitdevTopOST
        lda   #bitdev.rtnid.Dormant
        sta   routine,u
        ldu   #bitdevBotOST
        lda   #bitdev.rtnid.Dormant
        sta   routine,u

* ---------------------------------------------------------------------------
* MAIN GAME LOOP
* ---------------------------------------------------------------------------

LevelMainLoop
        lda   mainloop.state
        ldx   #mainloop.routines
        jmp   [a,x]

mainloop.state.RUNNING    equ 0
mainloop.state.DEAD       equ 2
mainloop.state.CHECKPOINT equ 4
mainloop.state
        fcb 0

mainloop.routines
        fdb   mainloop.routine.running
        fdb   mainloop.routine.dead
        fdb   mainloop.routine.checkpoint

mainloop.routine.running
        jsr   ReadJoypadsKbd
        jsr   Scroll
        jsr   ObjectWave
        _Collision_Do AABB_list_friend,AABB_list_ennemy
        _Collision_Do AABB_list_player,AABB_list_bonus
        _Collision_Do AABB_list_player,AABB_list_foefire
        _Collision_Do AABB_list_player,AABB_list_ennemy_unkillable        
        _Collision_Do AABB_list_player,AABB_list_ennemy
        _Collision_Do AABB_list_forcepod,AABB_list_foefire ; pod still blocks enemy bullets (generic)
        ; Force pod + both bit devices vs enemies: NOT generic. Arcade-faithful
        ; shared contact pass — one global 1/16-frame gate ([0x2eb6]&0x0F) for HP
        ; enemies (p>=2), instant contact for one-shot enemies (p==1); weapons
        ; never consumed. Static slots positioned their AABBs in the prev run phase.
        jsr   WeaponContactTick
        _RunObject ObjID_fade,#palettefade
        _RunObject ObjID_Player1,#player1
        _RunObject ObjID_forcepod,#forcepodOST ; static force pod: idle (Dormant) until collected
        _RunObject ObjID_bitdevice,#bitdevTopOST ; static bit device (top): Dormant until collected
        _RunObject ObjID_bitdevice,#bitdevBotOST ; static bit device (bottom): Dormant until collected
        jsr   RunObjects
        jsr   CheckSpritesRefresh

        jsr   gfxlock.on
        jsr   EraseSprites
        ; boss erase (block sweep + big rectangle): right after EraseSprites and
        ; before DrawSprites, so it overwrites the restored background and the
        ; sprite background backups then capture the blacked-out result
        _MountObject ObjID_endstage
        ldb   #endstage.BLIT
        jsr   ,x
        jsr   UnsetDisplayPriority
        jsr   DrawTiles
        jsr   DrawSprites
        ; phase 0-2: normal Mask + HUD. phase 3 (dissolve): draw nothing, it owns the screen
        ; (HUD band preserved by the capped fade). phase 4: centered stage-score readout.
        lda   main.endstage.phase
        cmpa  #3
        blo   @overlayNormal
        cmpa  #4
        beq   @overlayReadout
        bra   @overlayOff
@overlayNormal
        _MountObject ObjID_Mask
        jsr   ,x
        _MountObject ObjID_hud
        ldb   #hud.NORMAL
        jsr   ,x
        bra   @overlayOff
@overlayReadout
        _MountObject ObjID_hud
        ldb   #hud.READOUT
        jsr   ,x
@overlayOff
        jsr   gfxlock.off
        jsr   gfxlock.loop

        ; boss music
        lda  globals.nextGameMode
        beq  >
        jsr   IrqOff
        _MountObject ObjID_ymm01
        _MusicInit_objymm #1,#MUSIC_LOOP,#0
        ;_MountObject ObjID_vgc01
        ;_MusicInit_objvgc #1,#MUSIC_LOOP,#0
        jsr   IrqOn
        clr   globals.nextGameMode
!
        ; end of stage sequencing (logic in the mounted endstage object)
        _RunObjectRoutineB ObjID_endstage,#endstage.TICK
        tstb
        beq   >
        ; stage clear jingle (arcade: SFX $1A + $1C) - the ymm object cannot
        ; be mounted from inside the endstage object, so main starts it
        jsr   IrqOff
        _MountObject ObjID_ymm01
        _MusicInit_objymm #2,#MUSIC_NO_LOOP,#0
        jsr   IrqOn
!
        jmp   LevelMainLoop

mainloop.routine.dead
        _RunObject ObjID_fade,#palettefade
        _RunObject ObjID_Player1,#player1
        jsr   RunFrozenObjects
        jsr   CheckSpritesRefresh
        jsr   gfxlock.on
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _MountObject ObjID_Mask
        jsr   ,x
        _MountObject ObjID_hud
        ldb   #hud.NORMAL
        jsr   ,x
        jsr   gfxlock.off
        jsr   gfxlock.loop
        _waitFrames #83
        lda   #mainloop.state.CHECKPOINT
        sta   mainloop.state
        jmp   LevelMainLoop

mainloop.routine.checkpoint
        jsr   Palette_FadeOut
@loop   ; wait for fade out to finish
        _RunObject ObjID_fade,#palettefade
        jsr   gfxlock.on
        jsr   gfxlock.off
        jsr   gfxlock.loop
        ldu   #palettefade
        lda   routine,u
        cmpa  #o_fade_routine_idle
        bne   @loop

        _waitFrames #40
        ldx   #$0000
        jsr   ClearDataMem
        ; ClearDataMem zeroed the static weapon slot too (routine 0 = Init). Re-seed
        ; it Dormant so it idles after the checkpoint reset until the bonus is re-collected.
        ldu   #forcepodOST
        lda   #rtnid.Dormant
        sta   routine,u
        ; same for the two bit-device static slots (ClearDataMem zeroed them to
        ; routine 0 = the pickup Init): re-seed Dormant so they idle, and the bit
        ; count (player1+bitdevice, also cleared) is back to 0 -> lost on reset.
        ldu   #bitdevTopOST
        lda   #bitdev.rtnid.Dormant
        sta   routine,u
        ldu   #bitdevBotOST
        lda   #bitdev.rtnid.Dormant
        sta   routine,u
        _MountObject ObjID_messages
        dec   globals.lives
        bmi   >
        ldb   #messages.READY
        jsr   ,x
        bra   @displaymessage
!       ldb   #messages.GAME
        jsr   ,x
!       ldb   #messages.OVER
        jsr   ,x
@displaymessage
        clra                           ; switch to 320x200x16c mode
        sta   $E7DC
        ldd   #Pal_messages
        std   Pal_current
        clr   PalRefresh
	jsr   PalUpdateNow             ; message is now visible on screen
        tst   globals.lives
        bmi   @waitGameOver            ; lives < 0 -> GAME OVER : affiche 3s
        _waitFrames #50                ; READY : 1s (50 frames @ 50Hz) - inchange
        bra   @msgBlackout
@waitGameOver
        _waitFrames #150               ; GAME OVER : 3s (150 frames @ 50Hz)
@msgBlackout
        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
	jsr   PalUpdateNow             ; black out the message
        lda   #$7B                     * switch to 160x200x16c mode
        sta   $E7DC
        ldd   #$0030
        std   scroll_vel
        lda   #mainloop.state.RUNNING
        sta   mainloop.state
        tst   globals.lives
        bpl   >
        jsr   IrqOff
        jmp   Level01_Start           ; GAME OVER: restart level 1
!
        _RunObjectRoutineB ObjID_endstage,#endstage.INIT ; rearm boss sequencing for the replay
        _MountObject ObjID_checkpoint ; READY: load checkpoint
        jsr   ,x
        lda   #1
        sta   player1+subtype         ; player one blink mode / invincibility
        _ymm.restart
        jmp   LevelMainLoop

gfxlock.on
        _gfxlock.on
        rts

gfxlock.off
        _gfxlock.off
        rts

gfxlock.loop
        _gfxlock.loop
        rts

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
        jsr   gfxlock.bufferSwap.check
	jsr   PalUpdateNow
        jsr   joypad.buffer.addDirection
        _MountObject ObjID_ymm01
        _ymm.processFrame
        ;_MountObject ObjID_vgc01
        ;_MusicFrame_objvgc
        _MountObject ObjID_soundFX
        jmp   ,x ; call soundFX driver

* ---------------------------------------------------------------------------
* Collision_ClearLists
*
* ---------------------------------------------------------------------------

Collision_ClearLists
        ldd   #0
        ldy   #AABB_lists
        ldx   #AABB_lists.nb
!       std   ,y++
        leax  -1,x
        bne   <
        rts

* ---------------------------------------------------------------------------
* Palette fade routines
*
* ---------------------------------------------------------------------------

Palette_FadeIn
        ldu   #palettefade
        ldx   #Pal_game
        lda   #4
Palette_FadeCommon
        clr   routine,u
        stx   o_fade_dst,u
        sta   o_fade_wait,u
        ldd   Pal_current
        std   o_fade_src,u
        ldd   #0
        std   o_fade_sleep,u
        ldd   #Palette_FadeCallback
        std   o_fade_callback,u
Palette_FadeCallback
        rts

Palette_FadeOut
        ldu   #palettefade
        ldx   #Pal_black
        lda   #1
        bra   Palette_FadeCommon

* ---------------------------------------------------------------------------
* followDobkeratops
*
* ---------------------------------------------------------------------------

* The whole boss (face, jaw, the 19 tail parts, the alien) moves left as one
* body: every part calls this each frame and subtracts the SAME step from its
* own position, so each keeps its offset relative to the boss. The step is
* computed ONCE per frame and the last one is clamped to the distance still
* owed, so the body lands exactly on the butee whatever the frame drop - no
* per-sprite snap, the shared move.left == 0 is the pixel-exact arrival flag.
main.followDobkeratops
        ldd   gfxlock.frame.gameCount
        cmpd  main.dobkeratops.move.frame   ; step already computed this frame?
        beq   @apply
        std   main.dobkeratops.move.frame
        lda   gfxlock.frameDrop.count
        ldb   #timestamp.MOVEALIEN_SPEED    ; raw step = frameDrop * speed (8.8, =px/256)
        mul
        cmpd  main.dobkeratops.move.left
        bls   >
        ldd   main.dobkeratops.move.left    ; clamp the last step to the butee
!       std   main.dobkeratops.move.step
        ldd   main.dobkeratops.move.left
        subd  main.dobkeratops.move.step
        std   main.dobkeratops.move.left    ; 0 -> body has reached the butee
        ; background collision boss-follow offset: adv(px) = DIST - px_left ; advTiles = adv/3
        ; -> bgByteOff = advTiles/8 (24px bytes), bgBitShift = advTiles%8 (3px tiles)
        lda   #timestamp.MOVEALIEN_DIST
        suba  main.dobkeratops.move.left     ; A = adv px (move.left high byte = px left, 0..DIST)
        clrb
@bgT    suba  #3                             ; advTiles = adv / 3
        bcs   @bgS
        incb
        bra   @bgT
@bgS    tfr   b,a
        anda  #7
        sta   terrainCollision.bgBitShift    ; advTiles & 7
        lsrb
        lsrb
        lsrb
        stb   terrainCollision.bgByteOff     ; advTiles >> 3
@apply
        ldd   main.dobkeratops.move.step
        beq   @done                         ; butee reached: the whole body is frozen
        _negd
        addd  x_pos+1,u                      ; x_pos must be followed by x_sub in memory
        std   x_pos+1,u                      ; update low byte of x_pos and x_sub byte
        lda   x_pos,u
        adca  #-1
        sta   x_pos,u                        ; update high byte of x_pos
@done   rts

* ---------------------------------------------------------------------------
* Dobkeratops sequencing state (arcade: run_dobkeratops parent object)
* Shared resident state - read/written by the dobkeratops objects and by the
* mounted endstage object (which owns the end of stage logic)
* ---------------------------------------------------------------------------

main.timestamp.moveAlienStart fdb 0  ; frame stamp: alien starts to move out
main.dobkeratops.move.frame   fdb $ffff ; frame.count of the last clamped-step calc
main.dobkeratops.move.step    fdb 0  ; this frame's shared leftward step (8.8, =px/256)
main.dobkeratops.move.left    fdb 0  ; distance left to the butee (8.8, =px/256); 0 = arrived
main.endstage.counter         fdb 0  ; end of stage countdown (0: not armed)
main.endstage.phase           fcb 0  ; 0: gameplay, 1: jingle+autopilot, 2: glide, 3: fading, 4: score readout
main.endstage.scoreArmed      fcb 0  ; 1: tell the HUD readout to (re)seed from the stage score
main.endstage.scoreDone       fcb 0  ; 1: HUD readout finished -> obj_endstage leaves the level
main.dobkeratops.halfDamage   fcb 0  ; set when the monster is past half damage
main.dobkeratops.nervesErasing fcb 0 ; orbit-nerve erase animations still playing
main.dobkeratops.explode       fcb 0 ; 0: boss frozen (bossDefeated) but explosions held
                                      ;   while the nerves erase; 1: release jaw/tail/boss
                                      ;   explosions + the boss-room rectangle wipe

; called when the player has destroyed all four optical nerves
; (arcade: run_dobkeratops resumes the background scroll at once)
; stays resident: called from the dobkeratops object bank
main.dobkeratops.allEyesDead
        ldd   gfxlock.frame.gameCount
        addd  #timestamp.MOVEALIEN_DELAY
        cmpd  main.timestamp.moveAlienStart
        bhs   >
        std   main.timestamp.moveAlienStart  ; move.left already seeded by InitSequence
!       rts

* ---------------------------------------------------------------------------
*  Checkpoint positions in 24px tiles
* ---------------------------------------------------------------------------
checkpoint.positions
        fcb 0
        fcb 3
        fcb 18
        fcb 39
        fcb -1

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        INCLUDE "./game-mode/01/ram_data.asm"

* ---------------------------------------------------------------------------
* CUSTOM routines
* ---------------------------------------------------------------------------
        INCLUDE "./global/moveXPos8.8.asm"
        INCLUDE "./global/moveYPos8.8.asm"
        INCLUDE "./global/projectile.asm"
        INCLUDE "./global/setDirectionTo.asm"
        INCLUDE "./global/score.asm"
        INCLUDE "./global/weaponcollide.asm"

* ---------------------------------------------------------------------------
* ENGINE routines
* ---------------------------------------------------------------------------

        ; common utilities
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNowLean.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/irq/Irq.asm"
        ;INCLUDE "./engine/math/CalcSine.asm"
        ;INCLUDE "./engine/math/Mul9x16.asm"

        ; joystick
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypadsKbd.asm" ; variante R-Type : n'importe quelle touche -> bouton B (rappel pod, manette 1 bouton)
        INCLUDE "./engine/joypad/joypad.buffer.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"
        INCLUDE "./engine/object-management/ObjectWave-subtype.asm"
        INCLUDE "./engine/object-management/ObjectDp.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"
        INCLUDE "./engine/graphics/animation/moveByScript.asm"

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; tilemap
        INCLUDE "./engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered-even.asm"  

        ; collision
        INCLUDE "./engine/collision/collision.asm"
        INCLUDE "./engine/objects/collision/terrainCollision.main.asm"

        ; random numbers
        INCLUDE "./engine/math/RandomNumber.asm"

        ; music and sound fx
        INCLUDE "./engine/sound/soundFX.data.asm"
        INCLUDE "./engine/objects/sound/ymm/ymm.const.asm"
        INCLUDE "./engine/objects/sound/ymm/ymm.data.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"

        ; game mode transition (end of stage)
        INCLUDE "./engine/level-management/LoadGameMode.asm"