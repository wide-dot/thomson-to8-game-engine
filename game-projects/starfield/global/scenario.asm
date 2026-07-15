* ============================================================================
* scenario.asm — the scripted intro. Owns the timeline and every gate.
* ----------------------------------------------------------------------------
* THE CENTRAL IDEA: almost nothing is created or destroyed, it is REVEALED.
* LoadAct already blits the nebula and the xenon portrait into both video pages
* at init, and the title object already draws itself every frame from frame 0.
* They are invisible only because their palette entries are black. So most of
* this file is a palette schedule.
*
* Two things a palette schedule cannot express, and why:
*   - the BALLS borrow colours 2, 9, 11, 4, 5 and 6 from other elements. They
*     own no slot, so there is no entry to keep black: their appearance has to
*     gate the drawing.
*   - the STARS are 72 independent objects. "One star" is a count, not a colour.
*
* GATE OWNERSHIP IS THE INVARIANT that keeps this decomposable: scenario.asm is
* the only writer, everyone else is a reader. No module ever writes another's
* gate.
*
* These live in MAIN ENGINE ram, not in an object page, because the objects that
* read them (title, byfx) are banked: a banked page can read a resident global,
* but the scenario could not reach into a page that may not be mounted.
* ============================================================================

* --- gates (fcb, never rmb — see the note in starfield.asm) ---
sc_music_on  fcb 0              ; UserIRQ ticks the music players
sc_byfx_on   fcb 0              ; byfx object leaves Init and starts its ramp
sc_osc_on    fcb 0              ; byfx oscillates instead of resting at x=68
sc_balls_on  fcb 0              ; balls are restored and drawn
sc_msg       fdb 0              ; caption text pointer, 0 = none
* Frames of caption-band restore still owed after sc_msg goes to 0. The band must
* be repainted on BOTH pages after the last caption, or the final one is stranded
* -- and it would surface as a black scar the moment the nebula fades in. 3 is
* two pages plus slack.
*
* WHY GATE IT AT ALL: the caption band is 36x7x2 = 504 bytes, and restoring it
* every frame forever costs ~5300 cycles/render -- 11% of the render, spent on a
* band that is blank from t=26s to the end. It is the single largest thing in the
* frame after the starfield.
sc_msg_dirty fcb 0

* --- captions ---
* Drawn by the title object (see objects/title/title.asm), which already carries
* DrawText and fnt_4x6_shd in its page. The apostrophe is glyph 07 (ASCII 39),
* which 3x5_shaded does provide -- verified, not assumed.
txt_msg1 fcc "THIS WAS THE ONE STAR STARFIELD DEMO"
         fcb 0
txt_msg2 fcc "LET'S ADD MORE STARS"
         fcb 0

* ============================================================================
* Palette fading
* ----------------------------------------------------------------------------
* A palette entry is $GR0B: byte0 = G<<4 | R, byte1 = 000M BBBB. Each nibble is
* an INDEX into the EF9369's DAC ladder, NOT a brightness -- and that ladder's
* first step jumps straight to 97/255, i.e. 38%.
*
* So a fade must scale in RGB SPACE and match the result back to the nearest
* ladder index. Scaling the index linearly would put a target of 15 at index 7
* (=194, 76% brightness) by the halfway point: the fade would arrive almost
* entirely in its first few steps and then crawl.
*
* WHY THIS IS A CONSTANT TABLE. nearest(to8RGB[idx] * L / 16) depends only on
* the DAC ladder, which is hardware -- not on the palette. So the whole fade is
* a 272-byte constant and nothing needs deriving at runtime.
*
* An earlier version built this at init from Pal_starfield instead. It produced
* byte-identical output, but the 816 nearest-match scans took ~0.4s, and
* spending that long inside the init sequence crashed the machine before the
* first frame (a plain busy-wait of the same length crashed it identically, so
* the cost was the delay, not the arithmetic). Init is not a free place to
* think.
* ============================================================================

* pal_scaled[L][idx] -- row L holds the 16 ladder indices scaled to L/16
* brightness and re-quantised to the ladder. Row 16 is the identity, so a fade
* to level 16 reproduces the authored colour exactly; row 0 is all black.
* Rows are 16 bytes so indexing is (L<<4)|idx with no multiply.
* GENERATED: see the derivation in the header above (to8RGB is the EF9369
* ladder 0,97,122,143,158,171,184,194,204,212,219,227,235,242,250,255).
pal_scaled
        fcb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0        ; L=0
        fcb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0        ; L=1
        fcb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0        ; L=2
        fcb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0        ; L=3
        fcb 0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1        ; L=4
        fcb 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1        ; L=5
        fcb 0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1        ; L=6
        fcb 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,2        ; L=7
        fcb 0,0,1,1,1,1,1,1,1,1,1,2,2,2,2,2        ; L=8
        fcb 0,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3        ; L=9
        fcb 0,1,1,1,1,1,2,2,2,2,3,3,3,4,4,4        ; L=10
        fcb 0,1,1,1,1,2,2,3,3,3,3,4,4,5,5,5        ; L=11
        fcb 0,1,1,1,2,2,3,3,4,4,4,5,5,6,6,7        ; L=12
        fcb 0,1,1,2,2,3,3,4,5,5,5,6,7,7,8,8        ; L=13
        fcb 0,1,1,2,3,3,4,5,6,6,7,7,8,9,10,10      ; L=14
        fcb 0,1,2,3,3,4,5,6,7,7,8,9,10,11,12,13    ; L=15
        fcb 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15  ; L=16

* The authored palette, snapshotted before anything blacks it out. Every fade is
* computed from THIS, never from Pal_starfield, which the fades overwrite.
pal_authored fill 0,32

* Groups: count-prefixed lists of palette entry indices. Entry 0 is the
* background and entry 1 is byfx's own ping-pong, so neither appears here.
* Stars (4/5/6) are absent on purpose: sf_active=0 means no star is drawn, so
* their colours may sit at full brightness from frame 0 and cost nothing.
pal_grp_title  fcb 1,3
pal_grp_neb    fcb 10,2,7,8,9,10,11,12,13,14,15

* ---------------------------------------------------------------------------
* PalGroupSet — set every entry of a group to its level-B colour.
* In: X = group table, B = level 0..16. Clobbers A,B,D,X,Y,U.
* Arms the commit only; UserIRQ calls PalUpdateNow.
* ---------------------------------------------------------------------------
PalGroupSet
        stx   @grp
        tfr   b,a
        ldb   #16
        mul                        ; D = level*16 (max 256)
        addd  #pal_scaled
        std   @row                 ; &pal_scaled[level][0]
        ldx   @grp
        ldb   ,x+
        stb   @cnt                 ; count
@loop
        ldb   ,x+                  ; entry index 0..15
        stx   @grp                 ; save the cursor: X is about to be reused
        clra
        lslb                       ; D = entry*2, max 30
        ldx   #pal_authored
        leax  d,x                  ; X = &pal_authored[entry]
        ldu   #Pal_starfield
        leau  d,u                  ; U = &Pal_starfield[entry]
        ldy   @row
; --- byte0 = G<<4 | R ---
        lda   ,x
        lsra
        lsra
        lsra
        lsra                       ; A = G index
        ldb   a,y                  ; scaled G  (A <= 15, so the signed
        lslb                       ;   accumulator offset is safe)
        lslb
        lslb
        lslb
        stb   @tmp                 ; back into the high nibble
        lda   ,x
        anda  #$0F                 ; R index
        lda   a,y                  ; scaled R
        ora   @tmp
        sta   ,u
; --- byte1 = 000M BBBB ---
        lda   1,x
        anda  #$0F                 ; B index
        lda   a,y                  ; scaled B
        sta   @tmp
        lda   1,x
        anda  #$F0                 ; keep the M bit, whatever it is
        ora   @tmp
        sta   1,u
        ldx   @grp
        dec   @cnt
        bne   @loop
        clr   PalRefresh
        rts
@grp    fdb 0
@row    fdb 0
@tmp    fcb 0
@cnt    fcb 0

* ---------------------------------------------------------------------------
* ScenarioInit — call after _gfxlock.init and BEFORE _palette.set/_palette.show.
*
* ORDER IS LOAD-BEARING: the authored palette must be snapshotted BEFORE the
* groups are blacked out. Snapshot it after and every fade would run from black
* to black, and the title and the nebula would never appear.
* Clobbers A,B,D,X,U.
* ---------------------------------------------------------------------------
ScenarioInit
        ldx   #Pal_starfield           ; 1. snapshot the AUTHORED colours
        ldu   #pal_authored
@cp     ldd   ,x++
        std   ,u++
        cmpx  #Pal_starfield+32
        blo   @cp
        ldx   #pal_grp_title           ; 2. now black them out
        clrb
        jsr   PalGroupSet
        ldx   #pal_grp_neb
        clrb
        jsr   PalGroupSet
        ldx   #scenario_script         ; 3. arm the first step
        jsr   ScFire
        rts

* ============================================================================
* The script
* ----------------------------------------------------------------------------
* One table of (duration, op, operand, rate). The tick burns the duration down
* by gfxlock.frameDrop.count, so every step lasts a wall-clock time and not a
* number of render calls -- the loop settles at ~25Hz but drops frames when a
* frame runs long, which is what the framework's frameDrop indicator is for.
*
* Durations are in 50Hz frames. A duration of 0 means "fire and fall through to
* the next step in the same frame", which is how several things land on one
* instant; ScFire therefore LOOPS over zero-duration steps rather than
* consuming one per frame, or the timeline would drift by a frame per entry.
*
* Two ops are CONTINUOUS (SC_FADE, SC_RAMP): they are re-applied every frame for
* the step's duration, driven by an 8.8 accumulator. The rest are one-shots that
* fire once on entry.
* ============================================================================

SC_NOP    equ 0            ; arg unused          -- just wait
SC_FADE   equ 1            ; arg = group table   -- level 0 -> 16 over the step
SC_STARS  equ 2            ; arg = count         -- immediate
SC_RAMP   equ 3            ; arg = target count  -- sf_active 1 -> target
SC_MSG    equ 4            ; arg = text ptr      -- 0 = no caption
SC_FLAG   equ 5            ; arg = gate address  -- set it to 1
SC_END    equ 6            ; hold this state forever

SC_ENTRY  equ 6            ; dur(2) op(1) arg(2) rate(1)

* rate is the 8.8 increment per 50Hz frame: span*256/duration, where span is 16
* for a fade and NUM_STARS-1 for the star ramp. It is precomputed here rather
* than divided at runtime. Integer truncation leaves the last step a fraction
* short, so ScClamp writes the exact end value when the step expires -- without
* it the nebula would sit at 15/16 brightness forever.
scenario_script
*  0s  title fades in, 3s
        fdb   150
        fcb   SC_FADE
        fdb   pal_grp_title
        fcb   27
*  3s  music starts
        fdb   0
        fcb   SC_FLAG
        fdb   sc_music_on
        fcb   0
*       by FX fades in -- 3s, on its own ramp
        fdb   150
        fcb   SC_FLAG
        fdb   sc_byfx_on
        fcb   0
*  6s  one white fast star, 10s
        fdb   500
        fcb   SC_STARS
        fdb   1
        fcb   0
* 16s  "THIS WAS THE ONE STAR STARFIELD DEMO", 5s
        fdb   250
        fcb   SC_MSG
        fdb   txt_msg1
        fcb   0
* 21s  caption becomes "LET'S ADD MORE STARS"
        fdb   0
        fcb   SC_MSG
        fdb   txt_msg2
        fcb   0
*       ...and the field fills 1 -> NUM_STARS, 5s.
*       The rate is DERIVED, not hand-set: it must be (NUM_STARS-1)*256/duration
*       or the ramp misses its target and ScClamp snaps the remainder in as a
*       visible jump. It was hand-set once and went stale the moment NUM_STARS
*       changed, which is exactly the bug this expression removes.
        fdb   250
        fcb   SC_RAMP
        fdb   NUM_STARS
        fcb   (NUM_STARS-1)*256/250
* 26s  caption gone
        fdb   0
        fcb   SC_MSG
        fdb   0
        fcb   0
*       by FX starts oscillating rightward, 5s
        fdb   250
        fcb   SC_FLAG
        fdb   sc_osc_on
        fcb   0
* 31s  nebula + xenon fade in, 3s
        fdb   150
        fcb   SC_FADE
        fdb   pal_grp_neb
        fcb   27
* 34s  hold, 5s
        fdb   250
        fcb   SC_NOP
        fdb   0
        fcb   0
* 39s  balls appear
        fdb   0
        fcb   SC_FLAG
        fdb   sc_balls_on
        fcb   0
*       and it holds there
        fdb   0
        fcb   SC_END
        fdb   0
        fcb   0

sc_step  fdb scenario_script    ; current entry
sc_left  fdb 0                  ; 50Hz frames remaining in this step
sc_op    fcb SC_NOP
sc_arg   fdb 0
sc_rate  fcb 0
sc_fx    fdb 0                  ; 8.8 progress through a continuous op

* ---------------------------------------------------------------------------
* ScenarioTick — call once per render from MainLoop. Clobbers A,B,D,X,Y,U.
* ---------------------------------------------------------------------------
ScenarioTick
        lda   sc_op
        cmpa  #SC_END
        bne   @run
        rts                            ; the end state holds; nothing left to do
@run
        cmpa  #SC_FADE
        beq   @cont
        cmpa  #SC_RAMP
        bne   @timer
@cont
        lda   gfxlock.frameDrop.count
        ldb   sc_rate
        mul                            ; D = elapsed * rate, 8.8
        addd  sc_fx
        std   sc_fx
        jsr   ScApply
@timer
        ldd   sc_left
        subb  gfxlock.frameDrop.count  ; 16-bit -= an 8-bit count
        sbca  #0
        std   sc_left
        bgt   @rts                     ; time still left in this step
        jsr   ScClamp                  ; land exactly on the end value
        ldx   sc_step
        leax  SC_ENTRY,x
        jsr   ScFire
@rts
        rts

* ---------------------------------------------------------------------------
* ScApply — re-apply a continuous op at its current progress.
* ---------------------------------------------------------------------------
ScApply
        lda   sc_op
        cmpa  #SC_FADE
        bne   @ramp
        lda   sc_fx                    ; level = integer part
        cmpa  #16
        bls   @f_ok
        lda   #16
@f_ok
        tfr   a,b
        ldx   sc_arg
        jmp   PalGroupSet
@ramp
        lda   sc_fx
        inca                           ; the ramp starts at 1 star, not 0
        cmpa  #NUM_STARS
        bls   @r_ok
        lda   #NUM_STARS
@r_ok
        jmp   SetActiveStars

* ---------------------------------------------------------------------------
* ScClamp — write a continuous op's exact end value as its step expires.
* ---------------------------------------------------------------------------
ScClamp
        lda   sc_op
        cmpa  #SC_FADE
        bne   @ramp
        ldb   #16
        ldx   sc_arg
        jmp   PalGroupSet
@ramp
        cmpa  #SC_RAMP
        bne   @rts
        lda   sc_arg+1
        jmp   SetActiveStars
@rts
        rts

* ---------------------------------------------------------------------------
* ScFire — make X the current step and fire its one-shot. Loops while the new
* step's duration is 0, so several actions can land on the same instant.
* In: X = script entry. Clobbers A,B,D,X.
* ---------------------------------------------------------------------------
ScFire
@fire
        stx   sc_step
        ldd   ,x
        std   sc_left
        lda   2,x
        sta   sc_op
        ldd   3,x
        std   sc_arg
        lda   5,x
        sta   sc_rate
        clr   sc_fx
        clr   sc_fx+1
; --- one-shots ---
        lda   sc_op
        cmpa  #SC_STARS
        bne   @n1
        lda   sc_arg+1
        jsr   SetActiveStars
        bra   @chk
@n1
        cmpa  #SC_MSG
        bne   @n2
        ldd   sc_arg
        std   sc_msg
        lda   #3                       ; owe the band a wipe on both pages
        sta   sc_msg_dirty
        bra   @chk
@n2
        cmpa  #SC_FLAG
        bne   @n3
        ldx   sc_arg
        lda   #1
        sta   ,x
        bra   @chk
@n3
        cmpa  #SC_RAMP
        bne   @chk
        lda   #1
        jsr   SetActiveStars           ; a ramp opens on its first star
@chk
        lda   sc_op
        cmpa  #SC_END
        beq   @done
        ldd   sc_left
        bne   @done                    ; a real duration: stop here for now
        ldx   sc_step                  ; zero duration: fire the next step NOW,
        leax  SC_ENTRY,x               ; rather than burning a frame on it
        bra   @fire
@done
        rts
