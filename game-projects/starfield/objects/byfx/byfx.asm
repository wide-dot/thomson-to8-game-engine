; ---------------------------------------------------------------------------
; Object - byFX : draws "by FX" in colour 1 and ping-pong fades that colour.
;
; input REG : [u] pointer to Object Status Table (OST)
;
; The fade is a pure palette effect: fnt_4x6_shd_dis hard-codes palette index 1,
; and nothing else in the mode uses colour 1 (stars are on 4/5/6), so ramping
; entry 1 from black to cyan fades this text and only this text.
;
; Palette entry format is $GR0B (byte0 = G<<4|R, byte1 = 000M BBBB), so cyan at
; level L (R=0, G=L, B=L) is byte0 = L<<4, byte1 = L. L=15 -> $F00F = $0FF cyan.
;
; PalUpdateNow is NOT called here: the mode's 50Hz UserIRQ commits the palette.
; We only clear PalRefresh to arm it.
;
; Position lives in the OST (x_pos/y_pos) so it can be moved later.
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

FADE_TICKS  equ 10             ; 50Hz frames between level steps, so a 15-step ramp lasts
                               ; 15*10/50 = 3.0s per direction. Counted in 50Hz frames via
                               ; gfxlock.frameDrop.count, NOT in RunObjects calls: the render
                               ; loop settles at ~25Hz but drops frames when a frame runs long,
                               ; and a per-call count would let the ramp speed drift with it.
                               ;
                               ; 3.0s is the scenario's "by FX fades in over 3 seconds" (see
                               ; global/scenario.asm). That fade IS the first half of this
                               ; ping-pong, not a separate feature: the object already ramps
                               ; from level 0, so the scenario only has to say when it starts.

OSC_LEN     equ 100            ; table entries = 50Hz frames per full round trip (2s)

; --- OST extension fields ---
o_level     equ ext_variables      ; current fade level 0..15
o_dir       equ ext_variables+1    ; +1 / -1 (as $01 / $FF)
o_tick      equ ext_variables+2    ; frames left before the next level step
o_osc       equ ext_variables+3    ; phase into osc_x, 0..OSC_LEN-1

Object
        nop                        ; DO NOT MODIFY / DO NOT ADD A LINE BEFORE:
                                   ; rewritten into an rts when the object is done
        pshs  u
        lda   routine,u
        asla
        ldx   #Routines
        jsr   [a,x]
        puls  u,pc

Routines
        fdb   Init
        fdb   Live

Init
; Inert until the scenario starts the music. While inert this object draws
; nothing, which is why the scenario never has to black out palette entry 1:
; the entry may sit at its authored cyan because no pixel carries it.
        lda   sc_byfx_on
        beq   @rts
        clr   o_level,u            ; start invisible, fading in
; Phase 25, not 0: osc_x[25] = 70, which is 2 px from the resting x=68 this
; object holds while sc_osc_on is clear -- invisible -- and moving RIGHT, which
; is the direction the scenario asks for. Phase 0 is x=50 and would snap the
; text 18 px left the instant the gate opens.
        lda   #25
        sta   o_osc,u
        lda   #1
        sta   o_dir,u
        lda   #FADE_TICKS
        sta   o_tick,u
        lda   #1
        sta   routine,u            ; next frame -> Live
@rts
        rts

Live
; --- fade step (every FADE_TICKS 50Hz frames) ---
        ldb   o_tick,u
        subb  gfxlock.frameDrop.count  ; burn down real elapsed time, not one per call
        bgt   @notyet
        addb  #FADE_TICKS              ; carry the overshoot so the ramp cannot drift
        stb   o_tick,u
        bra   @step
@notyet
        stb   o_tick,u
        bra   @draw
@step
        lda   o_level,u
        adda  o_dir,u              ; dir is $01 or $FF -> +1 / -1
        sta   o_level,u
        beq   @flip                ; hit 0   -> fade back in
        cmpa  #15
        bne   @setpal
@flip
        neg   o_dir,u              ; reverse direction at either end
@setpal
        lda   o_level,u
        ldb   o_level,u
        lsla
        lsla
        lsla
        lsla                       ; A = L<<4 = (G=L, R=0)
        sta   Pal_starfield+2      ; palette entry 1, byte0
        stb   Pal_starfield+3      ; palette entry 1, byte1 = (M=0, B=L)
        clr   PalRefresh           ; arm the commit; MainLoop calls PalUpdateNow
@draw
; --- horizontal oscillation -------------------------------------------------
; Held at the resting x until the scenario opens the gate. That x must match the
; seed main.asm gives this object, or the text would jump on the first frame.
        lda   sc_osc_on
        bne   @osc
        ldd   #68                  ; resting x — KEEP IN SYNC with main.asm's seed
        std   x_pos,u
        bra   @drawpos
@osc
; Advance by the number of 50Hz frames actually elapsed, NOT by 1 per call:
; this object is ticked from the render loop, which settles at ~25Hz, so a
; per-call step would make the period depend on how long a frame takes to draw.
; Stepping by frameDrop.count keeps the round trip at a wall-clock OSC_LEN/50 s.
        ldb   o_osc,u
        addb  gfxlock.frameDrop.count
        cmpb  #OSC_LEN
        blo   @osc_ok
        subb  #OSC_LEN             ; frameDrop is small, so one wrap is enough
@osc_ok
        stb   o_osc,u
        ldx   #osc_x
; Index with D, NOT with A/B alone: the accumulator-offset modes (`lda b,x`) take
; the accumulator as a SIGNED offset, so any phase >= 128 would read backwards
; from osc_x and hand back garbage x positions. That scattered "by FX" across the
; whole screen, outside the band that erases it, so the smear was permanent.
; clra keeps D positive. (OSC_LEN is 100 now, but keep this: it is one edit away
; from being >= 128 again.)
        clra
        lda   d,x                  ; A = x for this phase
        tfr   a,b
        clra
        std   x_pos,u              ; the draw below reads it back as usual
@drawpos
        lda   y_pos+1,u            ; A = y
        ldb   #40
        mul                        ; D = y*40
        tfr   d,x
        leax  $C000,x              ; RAM A plane: glyphs reach RAM B via -$2000
        ldb   x_pos+1,u            ; B = x
        lsrb
        lsrb                       ; byte column (4 px per glyph)
        abx
        tfr   x,d
        std   DrawText_pos
        ldx   #fnt_4x6_shd_dis     ; colour 1 = the faded cyan
        ldy   #txt_byfx
        jsr   DrawText
        rts

* Precomputed cosine sweep for x_pos, generated by tools/gen-osc.py.
* x = 70 - 20*cos(2*pi*i/100), i.e. 50..90, which puts the CENTRE of the
* 20px-wide "by FX" on the alien's left edge (x=60) at one end and its right
* edge (x=99) at the other. Cosine, so it eases to a stop at both extremes
* instead of bouncing.
* The draw does x>>2 (one BM16 byte column = 4 px), so these 100 entries land on
* only 11 distinct columns (12..22) -- the text steps 4 px at a time. That is
* the font renderer's resolution, not a rounding choice here.
* KEEP IN SYNC with the band_text descriptor in global/band.asm: the band that
* repaints the nebula behind this text must cover every x it can reach.
osc_x
        fcb   50,50,50,50,51,51,51,52,52,53
        fcb   54,55,55,56,57,58,59,60,61,63
        fcb   64,65,66,67,69,70,71,73,74,75
        fcb   76,77,79,80,81,82,83,84,85,85
        fcb   86,87,88,88,89,89,89,90,90,90
        fcb   90,90,90,90,89,89,89,88,88,87
        fcb   86,85,85,84,83,82,81,80,79,77
        fcb   76,75,74,73,71,70,69,67,66,65
        fcb   64,63,61,60,59,58,57,56,55,55
        fcb   54,53,52,52,51,51,51,50,50,50

txt_byfx
        fcc   "by FX"
        fcb   0

; DrawText + the font live in THIS object's own banked 16Kb page: a font is ~96
; compiled glyphs (~5.7Kb) and two of them do not fit in the main engine's 16Kb.
        INCLUDE "./engine/graphics/font/DrawText/DrawText.asm"
        INCLUDE "./engine/graphics/font/DrawText/3x5_shaded_disabled/asm/font_upper.asm"
