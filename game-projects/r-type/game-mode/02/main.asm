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

; ObjID_hud command protocol (logic lives in objects/levels/hud/hud.asm)
hud.NORMAL  equ 0                    ; command: draw the bottom HUD (beam, lives, score)
hud.READOUT equ 1                    ; command: tick + draw the centered stage-score readout

moveByScript.NEGXSTEP equ scale.XN1PX
moveByScript.POSXSTEP equ scale.XP1PX
moveByScript.NEGYSTEP equ scale.YN1PX
moveByScript.POSYSTEP equ scale.YP1PX

map_width       equ 1128
viewport_width  equ 144
viewport_height equ 180

        org   $6100
Level02_Start
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

        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
	jsr   PalUpdateNow

; register animation data object
        ldb   #ObjID_animation
        jsr   moveByScript.register

; init globals.score and globals.lives
        ldd   #0
        std   globals.score
        clr   globals.score+2           ; clear 3rd score byte (24-bit)
        std   globals.stageScoreBase    ; stage-score base = score at stage start (D=0; multistage-ready)
        clr   globals.stageScoreBase+2  ; clear 3rd base byte (24-bit)
        ldb   #2
        stb   globals.lives
        lda   #0
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
        _MountObject ObjID_ymm02
        _MusicInit_objymm #0,#MUSIC_LOOP,#0  ; initialize the YM2413 player
        ;_MountObject ObjID_vgc02
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
        lda   #ObjID_initlevel2
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
        jsr   UnsetDisplayPriority
        jsr   DrawTiles
        jsr   DrawSprites
        _MountObject ObjID_Mask
        jsr   ,x
        _MountObject ObjID_hud
        ldb   #hud.NORMAL
        jsr   ,x
        jsr   gfxlock.off
        jsr   gfxlock.loop

        ; boss music (stage 2 will have an end-boss): switch the track when the
        ; wave signals it via globals.nextGameMode (set by the boss-trigger object)
        lda  globals.nextGameMode
        beq  >
        jsr   IrqOff
        _MountObject ObjID_ymm02
        _MusicInit_objymm #1,#MUSIC_LOOP,#0
        ;_MountObject ObjID_vgc02
        ;_MusicInit_objvgc #1,#MUSIC_LOOP,#0
        jsr   IrqOn
        clr   globals.nextGameMode
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
        _waitFrames #50                ; READY : 1s (50 frames @ 50Hz)
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
        jmp   Level02_Start           ; GAME OVER: restart the stage
!
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
        _MountObject ObjID_ymm02
        _ymm.processFrame
        ;_MountObject ObjID_vgc02
        ;_MusicFrame_objvgc
        _MountObject ObjID_soundFX
        jmp   ,x ; call soundFX driver

* ---------------------------------------------------------------------------
* Collision_ClearLists
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
*  Checkpoint positions in 24px tiles
* ---------------------------------------------------------------------------
checkpoint.positions
        fcb 0
        fcb 21
        fcb -1

* ---------------------------------------------------------------------------
* Shared HUD score-readout state (referenced by objects/levels/hud/hud.asm).
* Stage 2 has no end-stage score readout yet -> inert here (the main loop only
* ever calls hud.NORMAL), but the symbols must be defined for the shared HUD to
* assemble. To be wired to the real end-boss sequence when it lands.
* ---------------------------------------------------------------------------
main.endstage.scoreArmed      fcb 0
main.endstage.scoreDone       fcb 0

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        INCLUDE "./game-mode/02/ram_data.asm"

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
