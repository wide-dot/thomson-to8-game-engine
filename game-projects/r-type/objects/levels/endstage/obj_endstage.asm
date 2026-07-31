; ---------------------------------------------------------------------------
; Object (mounted) - Dobkeratops end of stage sequencer
;
; Mounted from the level 01 main loop. Carries the end of stage logic
; (arcade: run_dobkeratops parent tick, run_end_stage_sequence and
; EndLevelAutoPilot) outside of the resident main code space.
; Shared state lives in resident RAM (main.* variables).
;
; input  REG : [b] command: endstage.TICK, endstage.INIT or endstage.BLIT
; output REG : [b] status (TICK only): endstage.STATUS_NONE or
;                  endstage.STATUS_JINGLE (main must start the jingle,
;                  the ymm object cannot be mounted from here)
; ---------------------------------------------------------------------------
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./engine/objects/palette/fade/fade.equ"

SCORE_HOLD_FRAMES equ 50     ; pause ecran noir entre la fin du fade-out pixel

Object
        tstb
        beq   Tick
        cmpb  #endstage.INIT
        beq   InitSequence
        jmp   Blit

* ---------------------------------------------------------------------------
* reset boss sequencing state (level start and checkpoint reload)
* ---------------------------------------------------------------------------

InitSequence
        ldd   #timestamp.ERASE_NERV_START+timestamp.MOVEALIEN_DELAY
        std   main.timestamp.moveAlienStart
        ldd   #timestamp.MOVEALIEN_DIST*256       ; distance the body owes to the butee (8.8)
        std   main.dobkeratops.move.left
        clr   terrainCollision.bgByteOff          ; boss-follow bg collision offset starts at 0
        clr   terrainCollision.bgBitShift
        ldd   #$ffff
        std   main.dobkeratops.move.frame
        ldd   #0                                  ; MUST be cleared: the body stops calling
        std   main.dobkeratops.move.step          ;   followDobkeratops once on the butee, so the
                                                  ;   last non-zero step stays latched. The tailmgr
                                                  ;   reads move.step directly -> without this the
                                                  ;   19 tails drift left from their spawn on the
                                                  ;   next try (checkpoint reload / GAME OVER
                                                  ;   restart, which do not reload this RAM).
        ldd   #0
        std   main.endstage.counter
        clr   main.endstage.phase
        clr   main.dobkeratops.halfDamage
        clr   main.dobkeratops.nervesErasing
        clr   main.dobkeratops.explode
        clr   globals.bossDefeated
        clr   terrainCollision.disabled         ; debut niveau : terrain actif (re-arme apres fin de stage)
        clr   erase.rectArmed
        clr   erase.rectDelay
        clr   erase.bigRect
        clr   main.endstage.scoreArmed
        clr   main.endstage.scoreDone
        lda   #SCORE_HOLD_FRAMES               ; arme la pause ecran noir post fade-out
        sta   scoreHold.timer
        rts

scoreHold.timer fcb 0  ; phase 3->4: ~0.5 s black-screen hold before the score readout

* ---------------------------------------------------------------------------
* end of stage sequencing (arcade: run_dobkeratops parent tick)
* ---------------------------------------------------------------------------

Tick
        ; hold the camera at the boss room until the victory scroll-out (phase >= 2):
        ; cap the scroll at bossStopX. The Scroll applies the cap per buffer, so the
        ; boss room frames at exactly the same position on both (no frame-drop
        ; overshoot, and the X0-only eraser sprites keep their even parity).
        lda   main.endstage.phase
        cmpa  #2
        bhs   @scrollFree
        ldd   #endstage.bossStopX
        std   scroll_max
@scrollFree
        ldd   main.endstage.counter
        bne   @run                          ; sequence already armed
        lda   main.dobkeratops.explode       ; boss killed AND the nerve erase is done?
        bne   @arm
        ldx   gfxlock.frame.gameCount           ; boss escapes (arcade: +0x3E timeout expires)
        cmpx  #timestamp.BOSS_ESCAPE
        blo   @none
        ; engagement timeout with the boss still alive (only reachable when the player
        ; survived the butee, e.g. blink invincibility). Route it through the NORMAL
        ; teardown instead of just arming the countdown: monster.WaitEndStage sees
        ; bossDefeated and runs MonsterKill (explosions, explode flag, room erase,
        ; delete). Without it the body would stay painted during the scroll-out.
        lda   #1
        sta   globals.bossDefeated
@arm
        ldd   #endstage.DURATION
        std   main.endstage.counter
        lda   #endstage.SHIP_INVINCIBLE     ; arm the invulnerability on the arming frame too
        sta   player1+ext_variables+AABB.p
@none
        ldb   #endstage.STATUS_NONE
        rts
@run
        ; ship cannot die during the end sequence (arcade: HitPlayerOne gated by
        ; stage_unload_request). It MUST be a negative potential (invincible box):
        ; 127 is the ship's normal "weak" value, which Collision_Do clears on the
        ; first contact - and this Tick runs AFTER the collision pass and after
        ; player1 in the main loop, so restoring 127 could never save the frame.
        ; Invincible boxes are never modified by Collision_Do nor by TM_Collide.
        lda   #endstage.SHIP_INVINCIBLE
        sta   player1+ext_variables+AABB.p
        ldd   main.endstage.counter         ; reload: the lda above clobbered A (high byte of D)
        subd  gfxlock.frameDrop.count_w
        bgt   >
        ldd   #1                            ; floor the countdown, sequence stays latched
!       std   main.endstage.counter
        tst   main.endstage.phase
        bne   @pilot
        ; phase 0: free gameplay until T-$10
        cmpd  #endstage.JINGLE
        bhi   @none
        ; T-$10: jingle + ship autopilot (arcade: end_level_sequence_flag = -1)
        inc   main.endstage.phase
        lda   #-2
        sta   player1+subtype               ; autopilot: no control, ship still displayed
        jsr   AutoPilot
        ldb   #endstage.STATUS_JINGLE       ; main starts the stage clear jingle
        rts
@pilot
        jsr   AutoPilot
        lda   main.endstage.phase
        cmpa  #2
        beq   @glide                        ; phase 2: glide until the camera reaches the exit
        bhi   @phase34                      ; phase 3 (fade) / 4 (score readout): wait, then leave
        ; phase 1: hold autopilot until the countdown expires, then resume the scroll
        ldd   main.endstage.counter
        cmpd  #1
        bhi   @none                         ; countdown still running
        ; T-0: resume the level scroll - lift the cap to the real map end so the
        ; camera glides past the boss room toward the exit corridor (arcade scroll-out)
        inc   main.endstage.phase
        ldd   #map_width-viewport_width
        std   scroll_max
        ldd   #$0030
        std   scroll_vel
        bra   @none
@glide
        ; Armer le fondu SEULEMENT quand le scroll est reellement a l'arret, c'est a
        ; dire quand les DEUX buffers ont ete rendus a la butee. Le critere naif
        ; "glb_camera_x_pos >= map_width-viewport_width" est atteint une a deux trames
        ; trop tot : Scroll n'enregistre qu'un buffer par trame (buffer_x_pos /
        ; buffer_x_pos+2) et ne s'arrete qu'une fois les deux au cap. Tant qu'il tourne,
        ; glb_camera_move reste pose et DrawTiles - appele APRES Blit dans la boucle
        ; principale - repeint la tuilerie par-dessus la cellule que FadeOut vient
        ; d'effacer. Le fondu ne repassant jamais sur une cellule deja traitee, celle-ci
        ; restait visible jusqu'a la fin. Mesure en emulation : page 3 privee de la
        ; cellule coord 0,0, page 2 intacte, et le residu epousait le decor NON VIDE,
        ; les tuiles vides etant sautees par DrawTiles.
        ; On reprend donc la condition exacte de la sortie anticipee de Scroll.
        ldx   scroll_max
        cmpx  buffer_x_pos
        bne   >
        cmpx  buffer_x_pos+2
        bne   >                             ; un buffer n'a pas encore rattrape
        ; scroll fige sur les deux pages : glb_camera_move sera nul des la trame
        ; suivante, DrawTiles ne repeindra plus rien. On peut dissoudre.
        inc   main.endstage.phase
        jsr   InitFadeOut
!       bra   @none
@phase34
        ; phase 3: the dissolve runs in Blit; phase 4: the HUD score readout runs (driven by
        ; main, drawn by the HUD). Wait for the Blit/HUD state machine, then leave the level.
        lda   main.endstage.phase
        cmpa  #4
        blo   @none                         ; phase 3: still dissolving -> wait
        ; phase 4 (double-buffer readout): force a full sprite refresh every frame so the
        ; static ship/pod stay painted on BOTH pages (the dissolve blacked both; a static
        ; sprite would otherwise live on only one). Tick runs in RunObjects, BEFORE
        ; CheckSpritesRefresh consumes the flag, so they are marked dirty in time.
        lda   #1
        sta   <glb_force_sprite_refresh
@scoreWait
        lda   main.endstage.scoreDone        ; phase 4: wait for readout + 3 s hold to finish
        beq   @none                          ; (main loop keeps running -> the pod animates)
        ; readout + hold done: black the palette FIRST so the cut to the loading screen is
        ; hidden -> clean fade-to-black return to the title (same idiom as Level01_Start /
        ; the message black-out). PalUpdateNow writes the hardware registers synchronously,
        ; so it takes effect before we stop the IRQ just below.
        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow
        ; leave the level (LoadGameModeNow is resident and never returns)
        jsr   IrqOff
        ; silence the sound chips before the loading screen
        ; (arcade: quiet during the load - same as game-mode 00 LaunchGame)
        jsr   ResetSN
        jsr   ResetYM
        lda   #GmID_title                   ; TODO: tunnel game mode once registered (arcade: stage 2)
        sta   globals.nextGameMode
        lda   #GmID_loading
        sta   GameMode
        ldb   #GmID_level01
        stb   glb_Cur_Game_Mode
        jmp   LoadGameModeNow

* ---------------------------------------------------------------------------
* end-level autopilot (arcade: EndLevelAutoPilot in run_player_one)
* rally the ship toward the center point at 1 arcade-px/frame, scaled to the
* Thomson playfield: scale.X*1PX = 0.375 px/frame, scale.Y*1PX = 0.75 px/frame
* (the canonical arcade->TO8 ratio). One axis-aligned step per frame, dead band.
* ---------------------------------------------------------------------------

AutoPilot
        ldd   #0
        std   player1+x_vel
        std   player1+y_vel
        ldd   player1+x_pos
        subd  glb_camera_x_pos
        subd  #endstage.RALLY_X
        bmi   @shipLeft
        cmpd  #endstage.DEADBAND
        blo   @yAxis
        ldd   #scale.XN1PX                  ; ship right of rally point: fly left (0.375 px/frame)
        bsr   VelScale
        std   player1+x_vel
        bra   @yAxis
@shipLeft
        cmpd  #-endstage.DEADBAND
        bgt   @yAxis
        ldd   #scale.XP1PX                  ; ship left of rally point: fly right (0.375 px/frame)
        bsr   VelScale
        std   player1+x_vel
@yAxis
        ldd   player1+y_pos
        subd  glb_camera_y_pos
        subd  #endstage.RALLY_Y
        bmi   @shipAbove
        cmpd  #endstage.DEADBAND
        blo   @done
        ldd   #scale.YN1PX                  ; ship below rally point: fly up toward it (0.75 px/frame)
        bsr   VelScale
        std   player1+y_vel
        rts
@shipAbove
        cmpd  #-endstage.DEADBAND
        bgt   @done
        ldd   #scale.YP1PX                  ; ship above rally point: fly down toward it (0.75 px/frame)
        bsr   VelScale
        std   player1+y_vel
@done   rts

* D = D * gfxlock.frameDrop.count - the autopilot velocity is applied once
* per rendered frame by ObjectMove, so it must absorb the dropped frames
* (same compensation as everywhere else)
VelScale
        std   vel.base
        ldb   gfxlock.frameDrop.count
        bne   >
        ldb   #1
!       stb   vel.cnt
        ldd   #0
@l      addd  vel.base
        dec   vel.cnt
        bne   @l
        rts
vel.base fdb 0
vel.cnt  fcb 0

* ---------------------------------------------------------------------------
* Sound chip silence (verbatim from game-mode 00 LaunchGame)
* ---------------------------------------------------------------------------

ResetSN
        lda   #$9F
        sta   SN76489.D
        nop
        nop
        lda   #$BF
        sta   SN76489.D
        nop
        nop
        lda   #$DF
        sta   SN76489.D
        nop
        nop
        lda   #$FF
        sta   SN76489.D
        rts

ResetYM
        ldd   #$200E
        stb   YM2413.A
        nop                                 ; (wait of 2 cycles)
        ldb   #0                            ; (wait of 2 cycles)
        sta   YM2413.D                      ; note off for all drums
        lda   #$20                          ; (wait of 2 cycles)
        brn   *                             ; (wait of 3 cycles)
@a      exg   a,b                           ; (wait of 8 cycles)
        exg   a,b                           ; (wait of 8 cycles)
        sta   YM2413.A
        nop
        inca
        stb   YM2413.D
        cmpa  #$29                          ; (wait of 2 cycles)
        bne   @a                            ; (wait of 3 cycles)
        rts

* ---------------------------------------------------------------------------
* Boss erase (arcade: run_boss_erase_tile_background)
*
* The arcade wipes the boss body tile by tile; here the body is an overlay
* paint, so once the death is released we slam a single big black rectangle
* over the boss room - much cheaper than a per-tile sweep and visually fine.
*
* Called every frame from the main loop INSIDE the gfx lock, right after
* EraseSprites and before DrawSprites: the rect lands under the sprites and is
* captured into their background backups, so backup/restore never resurrects
* erased pixels. The rect is drawn on erase.bigRect consecutive frames (4 = two
* full passes over the two video buffers).
* ---------------------------------------------------------------------------

Blit
        ; phase 3: pixel-dissolve to black (here, in-lock, before DrawSprites - so the sprite
        ; background backups capture the dissolved pixels). phase 4: playfield clear for the
        ; double-buffer score readout. phases 0-2: boss-room rectangle wipe (@notFade).
        lda   main.endstage.phase
        cmpa  #3
        lbeq  BlitPhase3
        cmpa  #4
        lbeq  BlitPhase4
@notFade
        lda   main.dobkeratops.explode       ; erase only after the death is released
        lbeq  @rts                          ; (boss alive or still frozen): nothing to do
        ; arm, then draw the boss-room black rectangle on 2 consecutive frames
        ; (one per video buffer), delayed a few frames so the explosions read first
        lda   erase.rectArmed
        beq   @arm
        lda   erase.rectDelay               ; push the rectangle back
        beq   @drawRect
        dec   erase.rectDelay
        rts
@drawRect
        lda   erase.bigRect
        beq   @rts
        lda   #1                            ; the rect rewrites a large bg area: force a
        sta   <glb_force_sprite_refresh     ; full sprite refresh so the new backups go black
        jsr   BigBlackRect
        dec   erase.bigRect
@rts    rts
@arm
        lda   #1
        sta   erase.rectArmed
        lda   #8
        sta   erase.rectDelay
        lda   #4
        sta   erase.bigRect
        rts

* ---------------------------------------------------------------------------
* phase 3 -> 4: drive the dissolve, then arm the score readout.
* The pixel fade-out now runs in double buffering, so it blacks BOTH video pages on
* its own - no explicit buffer clear is needed before the readout (it used to be
* single-buffered, hence the old @clearHidden / BlitPhase4 page wipes, now dropped).
* ---------------------------------------------------------------------------
BlitPhase3
        lda   FadeCnt
        beq   @scoreHold                    ; fade done (both pages, double-buffered) -> hold, then score
        lda   #1
        sta   <glb_force_sprite_refresh     ; redraw ship/pod over the point-erase each frame
        jmp   FadeOut
@scoreHold
        ; fade done on both pages: hold ~0.5 s on the black screen before the score readout
        ; (let the dissolve land before the digits spin up). Ship/pod stay redrawn so they hover
        ; on the black during the pause; frame-drop compensated like the other endstage timers.
        ldb   scoreHold.timer
        beq   @toReadout                     ; hold elapsed (or disabled) -> arm the readout
        subb  gfxlock.frameDrop.count
        bls   @toReadout                     ; reached 0 this frame -> arm now
        stb   scoreHold.timer
        lda   #1
        sta   <glb_force_sprite_refresh      ; keep ship/pod over the black during the hold
        rts
@toReadout
        ; both pages already black (double-buffered fade): NO glb_camera_move so the level
        ; stays off, force a refresh so ship/pod recapture the black bg, arm the HUD readout
        lda   #1
        sta   <glb_force_sprite_refresh
        lda   #1
        sta   main.endstage.scoreArmed      ; HUD: (re)seed the readout from the stage score
        lda   #4
        sta   main.endstage.phase
        rts

BlitPhase4
        ; nothing to do: the double-buffered fade already blacked both pages, so there is no
        ; buffer clear here anymore (the readout is drawn by the HUD each frame, ship/pod kept
        ; on both pages by the per-frame sprite refresh forced from the Tick).
        rts

* ---------------------------------------------------------------------------
* BigBlackRect - solid fill, top-left (28,23) to bottom-right (147,178) in
* screen px/scanline. Filled bottom-to-top.
*
* BM16: 1 byte = 2 px, two interleaved planes. group g = x>>2 ;
*   RAMA byte $C000+line*40+g = px 4g, 4g+1 ; RAMB byte $A000+line*40+g = px
*   4g+2, 4g+3. RAMA = RAMB+$2000. Both edges are group-aligned (px 28 = start
*   of group 7, px 147 = end of group 36), so the fill is pixel-exact with whole
*   bytes only: groups 7..36 = 30 bytes/plane = 5*(d,x,y). Trashes a,b,d,x,y,u.
* ---------------------------------------------------------------------------
rect.G0       equ 7                          ; x>>2 of left edge (px 28, start of group 7)
rect.G1       equ 36                         ; x>>2 of right edge (px 147, end of group 36)
rect.Y0       equ 23
rect.Y1       equ 178
rect.RAMB_END equ $A000+rect.Y1*40+rect.G1+1 ; bottom line: exclusive end of the run
rect.LINES    equ rect.Y1-rect.Y0+1          ; 156 scanlines
rect.FILL     equ $ffff                      ; index 15 (alignment check); black = $0000

BigBlackRect
        ldx   #rect.FILL
        ldy   #rect.FILL                     ; X=Y=fill for every pshu (never clobbered)
        ldd   #rect.RAMB_END
        std   rect.ptr
        lda   #rect.LINES
        sta   rect.lineCnt
@line   ldd   #rect.FILL                     ; D=fill (pointer math below clobbers it)
        ldu   rect.ptr                        ; RAMB bank ($A000), run end = base+G1+1
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y                          ; 30 RAMB bytes [G0..G1] (px 28..147)
        ldu   rect.ptr
        leau  $2000,u                        ; RAMA bank ($C000)
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y                          ; 30 RAMA bytes [G0..G1]
        ldd   rect.ptr
        subd  #40                            ; up one scanline
        std   rect.ptr
        dec   rect.lineCnt
        bne   @line
        rts

* rectangle wipe state (lives in this RAM bank, reset by InitSequence)
erase.rectArmed  fcb 0  ; set once the death is released
erase.rectDelay  fcb 0  ; frames to wait before drawing the rectangle (push-back)
erase.bigRect    fcb 0  ; remaining boss-room rectangle frames (one per buffer)
rect.ptr         fdb 0  ; BigBlackRect rolling RAMB run-end pointer
rect.lineCnt     fcb 0  ; BigBlackRect scanline counter


* ---------------------------------------------------------------------------
* Fondu au noir par tramage (phase 3). Extrait dans le moteur pour etre
* reutilisable et surtout TESTABLE hors R-Type : le game-mode fadetest exerce
* exactement ce code. Fournit InitFadeOut / FadeOut / FadeCnt / FadeLen.
* ---------------------------------------------------------------------------
        INCLUDE "./engine/graphics/fade/pixel-fade.asm"
