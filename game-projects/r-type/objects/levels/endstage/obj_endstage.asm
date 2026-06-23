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

DOUBLE_BUF set 1

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
        ldd   #$ffff
        std   main.dobkeratops.move.frame
        ldd   #0
        std   main.endstage.counter
        clr   main.endstage.phase
        clr   main.dobkeratops.halfDamage
        clr   main.dobkeratops.nervesErasing
        clr   main.dobkeratops.explode
        clr   globals.bossDefeated
        clr   erase.rectArmed
        clr   erase.rectDelay
        clr   erase.bigRect
        clr   clear.frameCnt                 ; hidden-buffer clear counter (phase 3 -> 4)
        clr   clear.buf0Done
        clr   main.endstage.scoreArmed
        clr   main.endstage.scoreDone
        rts

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
@arm
        ldd   #endstage.DURATION
        std   main.endstage.counter
@none
        ldb   #endstage.STATUS_NONE
        rts
@run
        lda   #127                          ; ship cannot die during the end sequence
        sta   player1+ext_variables+AABB.p  ; (arcade: HitPlayerOne gated by stage_unload_request)
        ldd   main.endstage.counter         ; reload: the #127 above clobbered A (high byte of D)
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
        ldd   glb_camera_x_pos
        cmpd  #map_width-viewport_width
        blo   @none                         ; not at the map exit yet -> keep gliding
        ; reached the exit: dissolve to black while the game keeps running
        inc   main.endstage.phase
        jsr   InitFadeOut
        bra   @none
@phase34
        ; phase 3: the dissolve runs in Blit; phase 4: the HUD score readout runs (driven by
        ; main, drawn by the HUD). Wait for the Blit/HUD state machine, then leave the level.
        lda   main.endstage.phase
        cmpa  #4
        blo   @none                         ; phase 3: still dissolving -> wait
        ; phase 4: until buffer 0 has been re-cleared in double-buffer mode (BlitPhase4),
        ; force a full sprite refresh from HERE. Tick runs in RunObjects, BEFORE
        ; CheckSpritesRefresh consumes the flag and BEFORE the clearscreen Blit -> the idle
        ; ship is marked dirty in time and DrawSprites repaints it onto the freshly cleared
        ; page. Setting it inside BlitPhase4 would be one frame too late -> ship flickers.
        lda   clear.buf0Done
        bne   @scoreWait
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
* erased pixels. The rect is drawn on two consecutive frames (one per buffer).
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
* phase 3 -> 4: drive the dissolve, then switch to the double-buffer score readout.
* Both video buffers are blacked so the readout restarts clean: buffer 1 (hidden
* during the fade) is cleared by @clearHidden BEFORE the switch (still single
* buffer, never shown stale); buffer 0 (the ex-single/visible page) is cleared by
* BlitPhase4 the first time it is offscreen AFTER the switch.
* ---------------------------------------------------------------------------
BlitPhase3
        lda   FadeCnt
        beq   @clearHidden                  ; fade done -> black the HIDDEN buffer, then switch
        lda   gfxlock.backBuffer.id         ; still fading: enter single buffer on a buffer-0
        bne   @fade                         ; frame only (the frozen buffer is then buffer 0)
        ifndef  DOUBLE_BUF
        lda   #1
        sta   gfxlock.singleBuffer
        sta   <glb_sprite_erase_off         ; (buffer 0) skip the screen restore: re-stamp
        endc
@fade
        lda   #1
        sta   <glb_force_sprite_refresh     ; redraw ship/pod over the point-erase each frame
        jmp   FadeOut
@clearHidden
        ; the fade blacked buffer 0 (the single-buffer visible page). Now black the HIDDEN
        ; buffer over 4 frames, STILL in single buffer, so its stale level never reaches the
        ; screen (clearing it AFTER the switch flashes one frame of the old buffer). Map the
        ; hidden page, clear a half, restore the working page (buffer 0 stays displayed).
        lda   clear.frameCnt
        cmpa  #4
        bhs   @toReadout                     ; hidden buffer fully black -> switch to dbl buffer
        lda   #1
        sta   <glb_force_sprite_refresh      ; keep re-stamping ship/pod on the visible buffer 0
        ldb   gfxlock.backBuffer.status      ; map the HIDDEN page = (2 | status&1) ^ 1
        andb  #1
        eorb  #1
        orb   #2
        stb   map.CF74021.DATA
        inc   clear.frameCnt
        lda   clear.frameCnt
        cmpa  #3
        blo   @clearTop                      ; frames 1,2 -> top half ; frames 3,4 -> bottom half
        lda   #1
        bra   @doClear
@clearTop
        clra
@doClear
        jsr   ClearPlayHalf
        ldb   gfxlock.backBuffer.status      ; restore the WORKING page (buffer 0, visible)
        andb  #1
        orb   #2
        stb   map.CF74021.DATA
        rts
@toReadout
        ; both buffers black: back to double buffer (NO glb_camera_move so the level stays
        ; off), resume normal sprite erase, force a refresh so ship/pod recapture the black bg,
        ; arm the HUD readout, advance to phase 4
        clr   gfxlock.singleBuffer
        clr   <glb_sprite_erase_off
        clr   clear.buf0Done                 ; arm the buffer-0 offscreen clear (phase 4)
        lda   #1
        sta   <glb_force_sprite_refresh
        lda   #1
        sta   main.endstage.scoreArmed      ; HUD: (re)seed the readout from the stage score
        lda   #4
        sta   main.endstage.phase
        rts

BlitPhase4
        ; @clearHidden blacked buffer 1 (the hidden page) before the switch. Buffer 0 - the
        ; ex-single/visible page - still carries the faded bg + the re-stamped ship/pod + stale
        ; sprite-backup cells. Clear it the FIRST time it is offscreen (working) again, full in
        ; one frame (so it is never shown half-cleared), so the readout restarts clean too.
        lda   clear.buf0Done
        bne   @p4done
        lda   gfxlock.backBuffer.id
        bne   @p4done                          ; wait until buffer 0 is the working/offscreen buffer
        inc   clear.buf0Done
        ; (the full-sprite-refresh flag for this clear frame is set in the Tick, before
        ;  CheckSpritesRefresh runs - setting it here would be one frame too late)
        clra
        jsr   ClearPlayHalf                    ; buffer 0, top half
        lda   #1
        jsr   ClearPlayHalf                    ; buffer 0, bottom half
@p4done rts

* ---------------------------------------------------------------------------
* ClearPlayHalf - black-fill 96 scanlines of the playfield on the working buffer.
* A = 0 : top half (scanlines 0..95) ; A != 0 : bottom half (96..191). Both banks.
* The HUD band (>= HUD_TOP) is left intact. Same pshu technique as BigBlackRect.
* Trashes a,b,d,x,y,u.
* ---------------------------------------------------------------------------
ClearPlayHalf
        ldx   #0
        ldy   #0                            ; X=Y=0 (black), preserved across every pshu
        tsta
        beq   @top
        ldd   #$A000+192*40                 ; bottom half run end (scanline 192, exclusive)
        bra   @set
@top    ldd   #$A000+96*40                  ; top half run end (scanline 96, exclusive)
@set    std   clr.ptr
        lda   #96
        sta   clr.lineCnt
@line   ldd   #0
        ldu   clr.ptr                       ; RAMB bank, run end of this scanline
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y                         ; 36 bytes
        pshu  d,x                           ; +4 = 40 bytes (full scanline width)
        ldu   clr.ptr
        leau  $2000,u                       ; RAMA bank
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        ldd   clr.ptr
        subd  #40                           ; up one scanline
        std   clr.ptr
        dec   clr.lineCnt
        bne   @line
        rts

clear.frameCnt fcb 0   ; @clearHidden (phase 3) hidden-buffer clear frame counter (0..4)
clear.buf0Done fcb 0   ; phase 4: set once buffer 0 has been cleared offscreen
clr.ptr        fdb 0   ; ClearPlayHalf rolling run-end pointer
clr.lineCnt    fcb 0   ; ClearPlayHalf scanline counter

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

* ; FADEOUT by sam
* ; --------------

* GIFFIES equ 15                 ; temps d'effacement (en 1/10 sec, comme dans un gif)
* FPS     equ 25                 ; nb frames/sec
* NUM     equ ((32000/FPS)*10)/GIFFIES  ; nb pixels à effacer par frame
* ;  Valeurs coprimes valides : 7, 11, 13, 31, 49, 77, 91, 127, 251, 8191
* MAGIC   equ 8191            ; pas du PRNG additif, coprime de FADE_MOD

* ; Le fondu ne dissout que le playfield (scanlines 0..HUD_TOP-1) ; la bande HUD du bas
* ; (HUD_TOP..199) est preservee -> HUD visible pendant le readout, et moins de pixels a traiter.
* HUD_TOP  equ 192       ; premiere scanline du HUD (score/vies/beam) - ajustable
* FADE_MOD equ HUD_TOP*40*4 ; modulo du PRNG additif : offset = iRnd>>2 reste < HUD_TOP*40

* iRnd     fdb 0           ; seed aleatoire
* fadeDone fcb 0           ; 0 = tous les pixels effaces (ecran noir)
*          ifdef  DOUBLE_BUF
* iAgain   fdb 0           ; copie pour rejouer
* iOdd     fcb 0           ; parité numéro de trame
*          endc

* InitFadeOut
*         ldd   #0
*         std   iRnd
*         ifdef  DOUBLE_BUF        
*         std   iAgain
*         stb   iOdd
*         endc
*         lda   #1
*         sta   fadeDone
*         rts

* Mask    macro
*         _lsrd
*         _lsrd           ; con,version  D/4
*         bcc   >
*         adda  #$20      ; adaptation RAMB
* !       adda  #$A0      ; espace ram utilisateur
*         tfr   d,y       ; y=adresse pixel à effacer

*         lda   #\1
*         anda  ,y        ; masquage
*         sta   ,y        ; effacement pixel

*         ldd   iRnd      ; recup seed complete
*         addd  #MAGIC
*         cmpd  #FADE_MOD ; modulo FADE_MOD (au lieu de 32768) : borne le fondu au-dessus du HUD
*         blo   >
*         subd  #FADE_MOD
* !       std   iRnd      ; mise à jour seed
*         endm

* ; efface NUM pixels à chaque frame
* FadeOut ldx   #NUM
*         ldd   iRnd      ; charge seed
*         ifdef  DOUBLE_BUF
*         com   iOdd      ; frame paire ?
*         beq   >
*         ldd   iAgain    ; oui => rejeu
*         std   iRnd      ; mise à jour
* !       std   iAgain    ; sauvegarde pour rejeu
*         endc
* @loop   Mask  $0F
*         Mask  $F0
*         bne   >         ; ecran vide ?
*         clr   fadeDone  ; oui => fin : destruction objet FadeOut
* !       leax   -1,x     ; non => encore des pixels à effacer ?
*         bne    @loop    ; oui. => bouclage
*         rts             ; non => retour

ACCOLAD equ     1
DIAG    equ     2
BAYER8  equ     3
PATTERN equ     BAYER8

InitFadeOut
        ifndef  DOUBLE_BUF
        ldb     #FadeLen
        else
        ldb     #FadeLen*2
        endc
        stb     FadeCnt
        rts

FadeOut ldb     #0
FadeCnt set     *-1
        bne     >
        rts
!       decb    
        stb     FadeCnt
        ldx     #FadeOutPattern
        ifdef   DOUBLE_BUF
        lsrb
        endc
        abx
        ldd     #$0FE0  ; A=mask
        andb    ,x      ; keep b7b6b5
        bitb    #32     ; b5=1 ?
        beq     >
        subd    #$1F20  ; invert mask and clear b5
!       ldu     #@mask2+1
        sta     ,u
        sta     1,u
; plan rama/ramb
        lda     #$A0    ; rama
        lslb            ; carry = b7
        bpl     >       ; old b6=0 ?
        lda     #$C0    ; no=> ramb
!       rolb            ; put old b7 in b0, hence b=0/1
        std     @plan+1
        addd    #8000
        std     @tstend+1
        ldd     #40*256+31
        andb    ,x      ; extract line offset
        mul             ; convert to screen offset
; calcule adresse buffer video 
@plan   addd    #$CAFE  ; add screen-plane start
        tfr     d,x     ; result in X
        ldd     ,u
        std     <@mask0-@mask2,u
        std     <@mask1-@mask2,u
;       std     <@mask2-@mask2,u
        std     <@mask3-@mask2,u
        std     <@mask4-@mask2,u
        std     <@mask5-@mask2,u
        std     <@mask6-@mask2,u
        std     <@mask7-@mask2,u
        std     <@mask8-@mask2,u
        std     <@mask9-@mask2,u
@mask0  ldd   #0
        anda  ,x
        sta   ,x
        andb  2,x
        stb   2,x
@mask1  ldd   #0
        anda  4,x
        sta   4,x
        andb  6,x
        stb   6,x
@mask2  ldd   #0
        anda  8,x
        sta   8,x
        andb  10,x
        stb   10,x
@mask3  ldd   #0
        anda  12,x
        sta   12,x
        andb  14,x
        stb   14,x
@mask4  ldd   #0
        anda  16,x
        sta   16,x
        andb  18,x
        stb   18,x
@mask5  ldd   #0
        anda  20,x
        sta   20,x
        andb  22,x
        stb   22,x
@mask6  ldd   #0
        anda  24,x
        sta   24,x
        andb  26,x
        stb   26,x
@mask7  ldd   #0
        anda  28,x
        sta   28,x
        andb  30,x
        stb   30,x
@mask8  ldd   #0
        anda  32,x
        sta   32,x
        andb  34,x
        stb   34,x
@mask9  ldd   #0
        anda  36,x
        sta   36,x
        andb  38,x
        stb   38,x
        leax    40*(FadeLen/8),x ; ligne suivante
@tstend cmpx    #$DEAD  ; screen done ?
        lbcs    @mask0  ; no => process a nes line
        rts

; Accolade presents fading-out
; ----------------------------

; matrice de tramage (codée en dur)
;     0  1  2  3  4  5  6  7
; 0:  1 51 11 21 61 31 71 41        0
; 1: 18 58 28 68 38 78 48  8 
; 2: 65 35 75 45  5 55 15 25 
; 3: 42  2 52 12 22 62 32 72        1
; 4:  9 19 59 29 69 39 79 49 
; 5: 26 66 36 76 46  6 56 16 
; 6: 73 43  3 53 13 23 63 33        2
; 7: 50 10 20 60 30 70 40 80 
; 8: 17 27 67 37 77 47  7 57 
; 9: 34 74 44  4 54 14 24 64        3

; coord colonne,ligne avec 0 <= colonne <= 7 
; le framework gère des motifs de 8 pix horiz,
; et jusqu'à 32 vertical

coord   macro
        fcb     32*(\1)+(\2)
        endm

FadeOutPattern
        ifeq    PATTERN-ACCOLAD
; Accolade presnts
        coord   7,7     ; 80
        coord   6,4     ; 79
        coord   5,1     ; 78
        coord   4,8     ; 77
        coord   3,5     ; 76
        coord   2,2     ; 75
        coord   1,9     ; 74
        coord   0,6     ; 73
        coord   7,3     ; 72
        coord   6,0     ; 71
        
        coord   5,7     ; 70
        coord   4,4     ; 69
        coord   3,1     ; 68
        coord   2,8     ; 67
        coord   1,5     ; 66
        coord   0,2     ; 65
        coord   7,9     ; 64
        coord   6,6    ; 63
        coord   5,3     ; 62
        coord   4,0     ; 61
        
        coord   3,7     ; 60
        coord   2,4     ; 59
        coord   1,1     ; 58
        coord   7,8     ; 57
        coord   6,5     ; 56
        coord   5,2     ; 55
        coord   4,9     ; 54
        coord   3,6     ; 53
        coord   2,3     ; 52
        coord   1,0     ; 51
        
        coord   0,7     ; 50
        coord   7,4     ; 49
        coord   6,1     ; 48
        coord   5,8     ; 47
        coord   4,5     ; 46
        coord   3,2     ; 45
        coord   2,9     ; 44
        coord   1,6     ; 43
        coord   0,3     ; 42
        coord   7,0     ; 41

        coord   6,7     ; 40
        coord   5,4     ; 39
        coord   4,1     ; 38
        coord   3,8     ; 37
        coord   2,5     ; 36
        coord   1,2     ; 35
        coord   0,9     ; 34
        coord   7,6     ; 33
        coord   6,3     ; 32
        coord   5,0     ; 31

        coord   4,7     ; 30
        coord   3,4     ; 29
        coord   2,1     ; 28
        coord   1,8     ; 27
        coord   0,5     ; 26
        coord   7,2     ; 25
        coord   6,9     ; 24
        coord   5,6     ; 23
        coord   4,3     ; 22
        coord   3,0     ; 21

        coord   2,7     ; 20
        coord   1,4     ; 19
        coord   0,1     ; 18 <== irrégularité
        coord   0,8     ; 17
        coord   7,5     ; 16
        coord   6,2     ; 15
        coord   5,9     ; 14
        coord   4,6     ; 13
        coord   3,3     ; 12
        coord   2,0     ; 11

        coord   1,7     ; 10
        coord   0,4     ; 9
        coord   7,1     ; 8
        coord   6,8     ; 7
        coord   5,5     ; 6
        coord   4,2     ; 5
        coord   3,9     ; 4
        coord   2,6     ; 3
        coord   1,3     ; 2
        coord   0,0     ; 1
        endc

        ifeq    PATTERN-DIAG
        coord   7,0
        coord   6,1
        coord   5,2
        coord   4,3
        coord   3,4
        coord   2,5
        coord   1,6
        coord   0,7

        coord   7,1
        coord   6,2
        coord   5,3
        coord   4,4
        coord   3,5
        coord   2,6
        coord   1,7
        coord   0,0

        coord   7,2
        coord   6,3
        coord   5,4
        coord   4,5
        coord   3,6
        coord   2,7
        coord   1,0
        coord   0,1

        coord   7,3
        coord   6,4
        coord   5,5
        coord   4,6
        coord   3,7
        coord   2,0
        coord   1,1
        coord   0,2

        coord   7,4
        coord   6,5
        coord   5,6
        coord   4,7
        coord   3,0
        coord   2,1
        coord   1,2
        coord   0,3

        coord   7,5
        coord   6,6
        coord   5,7
        coord   4,0
        coord   3,1
        coord   2,2
        coord   1,3
        coord   0,4

        coord   7,6
        coord   6,7
        coord   5,0
        coord   4,1
        coord   3,2
        coord   2,3
        coord   1,4
        coord   0,5

        coord   7,7
        coord   6,0
        coord   5,1
        coord   4,2
        coord   3,3
        coord   2,4
        coord   1,5
        coord   0,6

        endc

        ifeq    PATTERN-BAYER8
bloc1   macro
        coord   0+\1,0+\2
        coord   4+\1,4+\2
        coord   4+\1,0+\2
        coord   0+\1,4+\2
        endm
bloc2   macro
        bloc1   0+\1,0+\2
        bloc1   2+\1,2+\2
        bloc1   2+\1,0+\2
        bloc1   0+\1,2+\2
        endm

        bloc2   0,0
        bloc2   1,1
        bloc2   1,0
        bloc2   0,1
        endc

FadeLen set (*-FadeOutPattern) 

        endc