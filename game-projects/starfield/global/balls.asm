* ============================================================================
* balls.asm — 8 chrome balls orbiting the alien portrait, drawn in front.
* ----------------------------------------------------------------------------
* WHY NO SAVE-UNDER. The balls draw LAST, so what sits under them is the live
* scene: nebula + stars + text. Save-under records those moving pixels as
* "background" and paints them back later as permanent ghosts -- the same reason
* it was rejected for the oscillating text (see band.asm).
*
* So this generalises band.asm: snapshot the pristine nebula under the whole
* annulus ONCE at init (BallsSnapshot), then each ball repaints its own 32-byte
* box from that snapshot (BallsRestore). The box goes back to pure nebula and the
* stars and text redraw themselves over it. Nothing is ever sampled at runtime.
*
* ORDER IS LOAD-BEARING (main.asm):
*     BallsRestore      <- FIRST. StarfieldRender decides "is a star already
*                          here?" by testing a nibble against 4..6, and the ball
*                          uses those very colours. Wiping the balls before that
*                          test is what keeps the test honest. Draw the balls
*                          before it and stars would refuse to plot over them.
*     BandRestore band_text  (overlaps rows 107..108; both write pristine, so
*                          the overlap is idempotent and the order between them
*                          is free)
*     StarfieldRender
*     RunObjects
*     BallsDraw         <- LAST: in front of everything.
*
* PER-PAGE STATE. gfxlock alternates two buffers, so a page still holds what was
* drawn two renders ago, not one. Every ball derives from one shared phase, so
* only that phase needs remembering -- one byte per page, plus a valid flag for
* the first frame, when nothing has been drawn yet.
* ============================================================================

        INCLUDE "./global/orbit.asm"          ; ORB_* equates + orbit_table
        INCLUDE "./global/ball-sprites.asm"   ; ball_routines + the 4 variants

NUM_BALLS  equ 8                 ; ORB_STEPS/NUM_BALLS = 8 steps = 45 degrees apart

* Orbit speed in 0.8 fixed point: steps per 50Hz frame * 256. $80 = 1/2 step.
*
* THE SPEED HAS AN ALIASING CEILING, and it is much lower than it looks. The
* balls are identical and sit 8 steps (45 deg) apart, so rotating the ring by 8
* steps maps it exactly onto itself: any per-DISPLAYED-frame step near 8 is
* indistinguishable from standing still. At 4 steps/frame the ring toggles
* between two configurations forever -- it reads as flicker, not rotation, which
* is precisely what ORB_SPEED=2 produced (25Hz render * frameDrop 2 * 2 = 4).
*
* The render loop settles at ~25Hz, i.e. 2 frames per drawn image, so the drawn
* step is 2*ORB_SPEED8/256. Keep that at or under ~1.5 steps (8 deg) to read as
* motion. $80 gives exactly 1 step (5.6 deg) per drawn image and 2.56s per turn.
*
* $80 is also chosen to divide the 2-frame render period exactly: a speed that
* lands between steps would advance 1,2,1,2 and reintroduce the same stutter
* that the sub-pixel star speeds did (see starfield.asm).
ORB_SPEED8 equ $80

* --- RAM (fill, never rmb — see the note in starfield.asm) ---
* The pristine nebula under the annulus: ORB_NCOL*ORB_NROW per bank, RAM A then
* RAM B. 2112 bytes.
balls_data  fill 0,ORB_PLANE*2
balls_phase_fx fdb 0             ; phase in 8.8 fixed point, high byte kept < ORB_STEPS
balls_phase fcb 0                ; current step 0..ORB_STEPS-1 (= high byte of the above)
balls_prev_0 fcb 0,0             ; page 0: phase last drawn, then valid flag
balls_prev_1 fcb 0,0             ; page 1: same

* ---------------------------------------------------------------------------
* BallsSnapshot — capture the pristine annulus. Call ONCE, right after LoadAct
* has blitted the nebula and before anything draws over it. Both video pages
* hold the same picture then, so one snapshot serves both.
* Clobbers A,B,D,X,U.
* ---------------------------------------------------------------------------
BallsSnapshot
        ldu   #balls_data
        ldx   #$C000+ORB_ROW0*40+ORB_COL0
        lda   #ORB_NROW
        sta   @r
@row
        lda   #ORB_NCOL/2
        sta   @c
@col
        ldd   ,x                       ; RAM A
        std   ,u
        ldd   -$2000,x                 ; RAM B, same offset
        std   ORB_NCOL,u               ; ...stored right after this row's RAM A half
        leax  2,x
        leau  2,u
        dec   @c
        bne   @col
        leau  ORB_NCOL,u               ; step over the RAM B half we just filled
        leax  40-ORB_NCOL,x            ; next scanline
        dec   @r
        bne   @row
        rts
@r      fcb   0
@c      fcb   0

* ---------------------------------------------------------------------------
* BallsUpdate — advance the orbit phase. Steps by the 50Hz frames actually
* elapsed, not once per call, so the rotation is wall-clock stable however long
* a frame takes to render. Clobbers A,B,D.
*
* DELIBERATELY UNGATED, unlike BallsRestore/BallsDraw below. The phase is
* wall-clock and costs one mul; gating it would park the orbit at phase 0 for
* the whole intro and then pop the balls in at a stale position the moment
* sc_balls_on opens.
* ---------------------------------------------------------------------------
BallsUpdate
        lda   gfxlock.frameDrop.count
        ldb   #ORB_SPEED8
        mul                            ; D = elapsed * speed, 8.8 fixed point
        addd  balls_phase_fx           ; <= 255*128 + 63*256 -> no 16-bit overflow
        std   balls_phase_fx
        anda  #ORB_STEPS-1             ; wrap the step, keep the fraction
        sta   balls_phase_fx           ; store back so the phase stays bounded
        sta   balls_phase
        rts

* ---------------------------------------------------------------------------
* BallsRestore — repaint the nebula under every ball drawn last time this page
* was the back buffer. Must run inside the gfxlock bracket and BEFORE
* StarfieldRender (see the header). Clobbers A,B,D,X,Y,U.
* ---------------------------------------------------------------------------
BallsRestore
        lda   sc_balls_on              ; the balls own no palette slot (they borrow
        bne   @on                      ; 2/9/11/4/5/6), so there is no entry to keep
        rts                            ; black: the gate must suppress the drawing
@on
        lda   gfxlock.backBuffer.id
        bne   @page1
        ldy   #balls_prev_0
        bra   @go
@page1
        ldy   #balls_prev_1
@go
        lda   1,y                      ; valid?
        bne   @start                   ; nothing drawn on this page yet
        rts                            ; (inverted: the unrolled loop below puts
@start                                 ;  @rts out of an 8-bit branch's reach)
        lda   ,y                       ; phase this page was last drawn at
        sta   @idx                     ; Y is free from here: the unrolled copy
        lda   #NUM_BALLS               ;   below uses it as the RAM B destination
        sta   @cnt
@ball
        lda   @idx
        anda  #ORB_STEPS-1
        ldb   #ORB_ENTRY
        mul                            ; D = step * 5
        ldx   #orbit_table
        leax  d,x                      ; X = table entry
        ldu   2,x                      ; snapshot offset
* Bias U by +96 = 4 rows. The 8 rows then sit at -96..+84, so every read below is
* an 8-bit (signed) index at 5 cycles instead of a 16-bit one at 9.
        leau  balls_data+96,u
        ldx   ,x                       ; vram offset (entry ptr no longer needed)
        leay  $A000,x                  ; Y = RAM B destination  -- BEFORE X is
        leax  $C000,x                  ;   rebased, since both derive from the offset
* Unrolled: 8 rows of 2 bytes per plane. Two destination pointers rather than one,
* because `std -$2000,x` needs a 16-bit index (9 cycles) where `std off,y` needs
* none (5). X and Y advance once at the halfway point so all four row offsets
* (0,40,80,120) stay inside a signed byte.
        ldd   -96,u
        std   ,x
        ldd   -84,u
        std   ,y
        ldd   -72,u
        std   40,x
        ldd   -60,u
        std   40,y
        ldd   -48,u
        std   80,x
        ldd   -36,u
        std   80,y
        ldd   -24,u
        std   120,x
        ldd   -12,u
        std   120,y
        leax  160,x
        leay  160,y
        ldd   ,u
        std   ,x
        ldd   12,u
        std   ,y
        ldd   24,u
        std   40,x
        ldd   36,u
        std   40,y
        ldd   48,u
        std   80,x
        ldd   60,u
        std   80,y
        ldd   72,u
        std   120,x
        ldd   84,u
        std   120,y
        lda   @idx
        adda  #ORB_STEPS/NUM_BALLS     ; next ball, 45 degrees round
        sta   @idx
        dec   @cnt
        lbne  @ball                    ; long: the unrolled body is >128 bytes
        rts
@idx    fcb   0
@cnt    fcb   0

* ---------------------------------------------------------------------------
* BallsDraw — draw all 8 balls at the current phase and record it for this page.
* Must run LAST in the frame. Clobbers A,B,D,X,Y,U.
* ---------------------------------------------------------------------------
BallsDraw
        lda   sc_balls_on
        bne   @on
        rts
@on
        lda   balls_phase
        sta   @idx
        lda   #NUM_BALLS
        sta   @cnt
@ball
        lda   @idx
        anda  #ORB_STEPS-1
        ldb   #ORB_ENTRY
        mul                            ; D = step * 5
        ldx   #orbit_table
        leax  d,x
        ldu   ,x                       ; vram offset
        leau  $C000,u                  ; U = RAM A base, the sprite's contract
        ldb   4,x                      ; shift = bx AND 3
        lslb                           ; word index into ball_routines
        ldx   #ball_routines
        jsr   [b,x]                    ; pre-shifted compiled sprite
        lda   @idx
        adda  #ORB_STEPS/NUM_BALLS
        sta   @idx
        dec   @cnt
        bne   @ball
* Remember what this page now holds, so the next pass over it can wipe it.
        lda   gfxlock.backBuffer.id
        bne   @page1
        ldy   #balls_prev_0
        bra   @save
@page1
        ldy   #balls_prev_1
@save
        lda   balls_phase
        sta   ,y
        lda   #1
        sta   1,y                      ; valid
        rts
@idx    fcb   0
@cnt    fcb   0
