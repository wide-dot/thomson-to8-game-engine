* ============================================================================
* starfield.asm — multi-plane horizontal parallax starfield (BM16 160x200),
* drawn as CLUSTERS: one real star plus CL_MEMBERS-1 derived satellites.
* ----------------------------------------------------------------------------
* BM16 VRAM (data space): 2 px/byte, high nibble=left px, low nibble=right px.
* byte offset = y*40 + (x>>2). nibble high if x even, low if x odd.
*
* PLANES ARE INVERTED IN DATA SPACE: RAM B is mapped at $A000 and RAM A at
* $C000. The asset encoder (PngToBottomUpB16Bin) builds RAM A as its FIRST
* 8000 bytes, holding pixel columns 0,1 of each 4-pixel group, and RAM B as
* the second 8000, holding columns 2,3. So columns 0,1 live at $C000 (RAM A)
* and columns 2,3 at $A000 (RAM B) — NOT the other way round.
* Getting this backwards renders every star +/-2 px off depending on the
* parity of (x>>1); as x scrolls that parity flips each pixel, so stars jitter
* back and forth instead of drifting smoothly.
*
* ----------------------------------------------------------------------------
* WHY CLUSTERS. Only NUM_MASTERS stars have a position. Every other star is a
* fixed offset from one of them, and BECAUSE EVERY dx IS A MULTIPLE OF 4 that
* offset is a constant delta on the master's VRAM address, sharing its plane and
* its nibble:
*     (x+dx)>>2   == (x>>2) + dx/4     exact — no carry out of the low 2 bits
*     (x+dx) AND 2 == x AND 2          same plane
*     (x+dx) AND 1 == x AND 1          same nibble
* So the expensive part of a plot — plane select, x>>2, abx, nibble select —
* happens ONCE PER CLUSTER instead of once per star, and each member costs one
* `leax d,x`. tools/gen-clusters.py enforces the dx constraint; violate it and
* the saving disappears entirely, because plane and nibble would then depend on
* the master's live x and change every frame.
* ============================================================================

        INCLUDE "./global/clusters.asm"   ; CL_* equates + cluster_pat

SF_BANK01   equ  $C000      ; RAM A — pixel columns 0,1  ((x AND 2) = 0)
SF_BANK23   equ  $A000      ; RAM B — pixel columns 2,3  ((x AND 2) = 2)

; NOTE: never use RMB for module data — this file is assembled into a RAW
; binary loaded contiguously at $6100. RMB advances the location counter but
; emits NO bytes, so every byte after it lands one address early at runtime
; (which silently skips the first opcode of later routines). Always reserve
; loaded data with fcb / fdb / fill, exactly like the engine does.

MASTERS_PER_LAYER equ 6
NUM_LAYERS        equ 3
NUM_MASTERS       equ MASTERS_PER_LAYER*NUM_LAYERS   ; 18
NUM_STARS         equ NUM_MASTERS*CL_MEMBERS         ; 72 drawn

* --- cluster record (array-of-structs, walked with a single U pointer) ---
* Only NUM_MASTERS of these exist, against one per star before: 180 bytes, not 648.
cl_x    equ 0                   ; word, 8.8 fixed x of the MASTER, [0, 160*256)
cl_y    equ 2                   ; byte, master y (the loop reads cl_row instead)
* Colour, pre-shifted for both nibble positions. The plot is a read-modify-write
* of one nibble, so it needs the colour either in the high nibble or the low one.
* The whole cluster shares one nibble, so the render picks ONE of these per
* cluster and patches it into the member loop.
cl_colhi equ 3                  ; byte, colour<<4  (engine colour 4..6)
cl_collo equ 4                  ; byte, colour
cl_spd  equ 5                   ; word, 8.8 speed
* y*40, cached. Masters only ever move horizontally, so y — and therefore this
* row offset — changes only on respawn at the right edge.
cl_row  equ 7                   ; word, y*40
cl_pat  equ 9                   ; byte, PRE-MULTIPLIED offset into cluster_pat,
                                ;   so the render needs no multiply
cl_size equ 10

* --- erase entry layout — one per DRAWN STAR, not per cluster ---
* er_save is what makes the nebula survive: erasing used to AND the star's
* nibble to 0, which was invisible on a black screen but punches a black hole
* in a picture. Instead the plot pass saves the background nibble it is about
* to cover, and the erase pass ORs it back.
*
* Entry index is the GLOBAL DRAWN INDEX (cluster*CL_MEMBERS + member). That is
* stable across frames because drawing always starts at cluster 0 member 0 and
* proceeds in order, and sf_active only ever grows.
er_addr equ 0                   ; word, plotted VRAM byte address (0 = nothing)
er_mask equ 2                   ; byte, AND-mask clearing its nibble ($0F/$F0)
er_save equ 3                   ; byte, background nibble that was under the star
er_size equ 4

* --- per-layer constants (0=slow, 1=mid, 2=fast) ---
* Speeds are 8.8 pixels per 50Hz FRAME, and StarfieldUpdate multiplies them by
* gfxlock.frameDrop.count. So the field is wall-clock stable: it does not change
* speed when the render rate does.
*
* THIS USED TO BE PER RENDER, at a whole 1/2/3 px, with a comment forbidding
* fractional speeds because "0.5 px/frame renders steps of 1,0,1,0 px — visible
* stutter". That reasoning does not survive compensation. x is an 8.8
* accumulator: subtracting speed*frameDrop keeps the POSITION exact and only the
* plot quantises, so the fraction is carried rather than lost. The 1,0,1,0
* stutter came from advancing by a fraction ONCE PER RENDER, not from the
* fraction itself.
*
* Compensation also fixed a real bug: speeds per render meant the field silently
* sped up 50% when the loop went 16.6 -> 25Hz, and would slow down again the
* moment anything pushed the render back over two frames.
*
* WHY THE FAST LAYER IS 1.0 AND NOT 1.5. The render is 25Hz (frameDrop 2), so a
* layer at 1.5 px/frame holds still for 40ms and then jumps 3 px. The eye
* integrates the two positions and reads ONE star as TWO -- and only on the fast
* layer, because the slow one jumps 1 px. It is a sampling artefact, not a
* drawing bug: the erase and the double buffer were both verified innocent (each
* page is displayed for exactly 2 frames, and the field holds 60 star pixels of a
* possible 72 -- fewer than exist, so nothing is stale).
*
* At 25Hz the tiers are pinned from both ends. The per-render step cannot go
* BELOW 1 px or the integer plot plays the old 1,0,1,0 stutter, and it should not
* go above 2 or it doubles. 1/1.5/2 px per render is the only three-tier set left,
* which is 0.5/0.75/1.0 per frame. The mid layer's 1.5 alternates 1,2,1,2 px per
* render -- the accumulator keeps the average exact, and a 2:1 step ratio is far
* less visible than the 1,0 one the floor protects against.
*
* The honest fix is 50Hz (frameDrop 1), where these same speeds would step
* 0.5/0.75/1 px per displayed image and nothing would judder at all. That needs
* the render inside 19968 cycles; it currently takes ~39000.
sf_layer_speed  fdb  $0080,$00C0,$0100   ; 8.8 px per 50Hz frame: 0.5, 0.75, 1.0
* Stars live on colours 4/5/6 because every compiled font glyph hard-codes its
* palette index (shd=3, dis=1, sel=15). Keeping stars off those indices lets the
* "by FX" colour fade without touching the starfield.
* These three are ALSO the only colours the nebula may not use: StarfieldRender
* tells "a star is here" from "the nebula is here" by testing a nibble against
* 4..6, so the two sets must stay disjoint. tools/img2to8.py enforces it from
* the other side by only quantising into slots 0, 2 and 7..15.
sf_layer_color  fcb  4,5,6               ; engine colour: $444, $AAA, $FFF

* --- RAM (fill, never rmb — see note above) ---
cluster_data fill 0,NUM_MASTERS*cl_size
erase_0      fill 0,NUM_STARS*er_size
erase_1      fill 0,NUM_STARS*er_size   ; MUST stay contiguous after erase_0

* Layer assignment order, cycled per master: master i takes sf_order[i mod 3].
* NOT three contiguous blocks, and NOT 0,1,2. Both details are load-bearing for
* the scenario (see global/scenario.asm):
*   - ROUND-ROBIN rather than blocks, because sf_active gates the field by
*     COUNT. With contiguous blocks the count would fill the field
*     slow-layer-first and show no parallax at all until its last third; cycled,
*     every value of sf_active is balanced across the three speeds.
*   - STARTING ON THE FAST LAYER, because cluster 0's MASTER is the lone star of
*     the scenario's t=6s phase. Layer 2 is 3 px/frame and colour 6 ($FFF white)
*     -- the only star colour legible alone on black, since layer 0 is $444.
* NUM_MASTERS is divisible by 3, so cycling yields exactly MASTERS_PER_LAYER per layer.
sf_order  fcb 2,0,1

* ---------------------------------------------------------------------------
* StarfieldInit — seed the masters (layers cycled per sf_order, one of the
* CL_PATS patterns each), clear the erase lists, seed the RNG. Leaves sf_active
* at 0: the scenario opens on a black screen and asks for stars later.
* Clobbers A,B,D,X,U.
* ---------------------------------------------------------------------------
StarfieldInit
        jsr   InitRNG                  ; without this RandomNumber returns 0 forever
        ldu   #cluster_data
        clr   @ord                     ; index into sf_order, cycles 0,1,2
        lda   #NUM_MASTERS
        sta   @cnt
@master
        ldb   @ord
        ldx   #sf_order
        lda   b,x                      ; A = layer for this master
        pshs  a                        ; [S] = layer
        incb
        cmpb  #NUM_LAYERS
        blo   @ord_ok
        clrb                           ; wrap the cycle
@ord_ok
        stb   @ord
        ldb   ,s                       ; layer
        lslb                           ; word index into the speed table
        ldx   #sf_layer_speed
        ldd   b,x
        std   @spd                     ; stash this layer's speed
        puls  b                        ; layer
        ldx   #sf_layer_color
        lda   b,x
        sta   @col                     ; stash this layer's colour
        _rnda 0,159                    ; A = pixel x 0..159
        sta   cl_x,u                   ; hi byte = pixel x
        clr   cl_x+1,u                 ; lo byte (fraction) = 0
        bsr   SeedClusterY             ; random y, clamped so the cluster fits
        lda   @col
        sta   cl_collo,u               ; colour in the low nibble
        lsla
        lsla
        lsla
        lsla
        sta   cl_colhi,u               ; and pre-shifted into the high nibble
        ldd   @spd
        std   cl_spd,u
        bsr   SeedClusterPat
        leau  cl_size,u
        dec   @cnt
        bne   @master
; clear both erase lists (er_addr=0 => the first erase pass skips every entry)
        ldx   #erase_0
@clr
        clr   ,x+
        cmpx  #erase_1+NUM_STARS*er_size
        blo   @clr
        clra
        jsr   SetActiveStars           ; the scenario opens on an empty sky
        rts
@spd    fdb   0
@col    fcb   0
@ord    fcb   0
@cnt    fcb   0

* ---------------------------------------------------------------------------
* SeedClusterY — give the master at U a fresh random y and cache y*40.
*
* y is NOT clamped: masters spawn uniformly over all 200 rows and the render
* clips members vertically instead. Clamping y to [CL_DY_MAX, 199-CL_DY_MAX]
* would make vertical clipping impossible and save the test, but it starves the
* screen edges as CL_DY_MAX grows -- at |dy|<=20 row 0 would be reachable only by
* a master at exactly y=20 with dy=-20, leaving rows 0..40 ramping from ~4%
* density to full. See tools/gen-clusters.py.
* Clobbers A,B,D.
* ---------------------------------------------------------------------------
SeedClusterY
        _rnda 0,199
        sta   cl_y,u
        ldb   #40
        mul                            ; D = y*40
        std   cl_row,u                 ; the only place y ever changes
        rts

* ---------------------------------------------------------------------------
* SeedClusterPat — give the master at U one of the CL_PATS patterns at random,
* stored PRE-MULTIPLIED so the render can index cluster_pat with no multiply.
* Re-drawn on every respawn, so a cluster does not keep the same shape forever.
* Clobbers A,B,D.
* ---------------------------------------------------------------------------
SeedClusterPat
        _rnda 0,CL_PATS-1
        ldb   #CL_PATSIZE
        mul                            ; D = pattern * 28 (max 84, fits in B)
        stb   cl_pat,u
        rts

* ---------------------------------------------------------------------------
* How many stars are DRAWN right now — in stars, NOT clusters. The scenario
* ramps this 1 -> NUM_STARS (see global/scenario.asm), and its t=6s phase shows
* exactly ONE star and captions it as such. Counting clusters here would draw 7
* and make that caption a lie.
*
* The render turns this into "min(CL_MEMBERS, remaining) members of each
* cluster, stop at zero", so no division is needed anywhere and the ramp fills
* clusters progressively — they visibly grow as the field builds.
* ---------------------------------------------------------------------------
sf_active     fcb 0

* ---------------------------------------------------------------------------
* SetActiveStars — A = drawn star count (0..NUM_STARS). Clobbers nothing else.
* ---------------------------------------------------------------------------
SetActiveStars
        sta   sf_active
        rts

* ---------------------------------------------------------------------------
* StarfieldUpdate — advance each MASTER left by its speed (8.8 fixed). On borrow
* past the left edge, wrap to the right edge with a fresh y and a fresh pattern.
* Clobbers A,B,D,X,U.
* ----------------------------------------------------------------------------
* All NUM_MASTERS are updated unconditionally, even the ones sf_active does not
* draw yet: it is only 12, and it means a cluster is already in motion when the
* ramp reveals it rather than popping in at a stale spawn position.
*
* NOTE: the loop is bounded by the U pointer, NOT by a counter in B — `ldd
* cl_x,u` loads D=A:B and would destroy any counter held in B (that bug walked
* U far past the array and crashed the machine).
* ---------------------------------------------------------------------------
StarfieldUpdate
        ldu   #cluster_data
@loop
* step = cl_spd * frameDrop.count, in 8.8. Two muls because cl_spd is a word:
* (hi*N)<<8 + (lo*N). hi is 0..1 here and N is a handful of frames, so hi*N can
* never leave B -- it would take a frameDrop of 128+ to overflow, which would
* mean the render took 2.5 seconds.
        lda   cl_spd,u
        ldb   gfxlock.frameDrop.count
        mul
        tfr   b,a
        clrb                           ; D = (hi*N) << 8
        std   @step
        lda   cl_spd+1,u
        ldb   gfxlock.frameDrop.count
        mul                            ; D = lo*N
        addd  @step
        std   @step
        ldd   cl_x,u
        subd  @step                    ; x -= speed*elapsed; carry = borrowed past 0
        bcc   @store
; wrapped off the left edge: x += 160.0, respawn with a new y and shape
        addd  #160*256
        std   cl_x,u
        bsr   SeedClusterY
        bsr   SeedClusterPat
        bra   @next
@store
        std   cl_x,u
@next
        leau  cl_size,u
        cmpu  #cluster_data+NUM_MASTERS*cl_size
        blo   @loop
        rts
@step   fdb 0

* ---------------------------------------------------------------------------
* StarfieldRender — for every drawn star: erase where it was when this page was
* last the back buffer, plot it where it is now, and record the new erase entry.
* Must run inside the _gfxlock.on/_gfxlock.off bracket (back buffer mounted at
* $A000/$C000). Clobbers A,B,D,X,U,Y.
* ----------------------------------------------------------------------------
* This is the mode's hottest code, so it is written for cycles over elegance:
*   - the master's address is computed ONCE PER CLUSTER; each of the 7 members
*     is then one `leax d,x` off it (see the file header for why that is sound);
*   - the whole cluster shares one nibble, so the nibble-dependent operands —
*     keep-mask, pre-shifted colour, "is this a star" bounds, erase mask — are
*     PATCHED INTO THE MEMBER LOOP'S IMMEDIATES once per cluster. That keeps the
*     loop on 2-cycle immediate addressing instead of either duplicating it per
*     nibble or paying 5-cycle direct addressing six times per member. This is
*     the engine's own idiom — see `DrawText_pos equ *-2`;
*   - y*40 and both nibble-alignments of the colour are read from the record.
*
* ERASE AND PLOT SHARE ONE PASS, and that is a deliberate trade, not an
* oversight. Two passes (erase all, then plot all) are strictly correct. Merged,
* star i's erase runs after stars 0..i-1 have already been plotted, so if star
* i's OLD pixel is where star j (j<i) now sits, the erase wipes j's fresh pixel
* and j vanishes for one frame — invisible at this speed. Note the odds grow
* with star count, and the count went 72 -> 84 here.
* ---------------------------------------------------------------------------
StarfieldRender
        lda   sf_active
        bne   sfr_run
        rts                            ; nothing drawn: the loops below are
sfr_run                                   ;   do-while and would plot cluster 0
        sta   sfr_remain
        lda   gfxlock.backBuffer.id
        bne   sfr_page1
        ldy   #erase_0
        bra   sfr_go
sfr_page1
        ldy   #erase_1
sfr_go
        ldu   #cluster_data

sfr_cluster
        lda   sfr_remain
        bne   sfr_more
        rts                            ; every requested star has been drawn
sfr_more
        cmpa  #CL_MEMBERS
        blo   sfr_partial                 ; the ramp's leading cluster: draw part
        lda   #CL_MEMBERS
sfr_partial
        sta   sfr_members
        ldb   sfr_remain
        subb  sfr_members
        stb   sfr_remain

* --- the master's address: the expensive part, once for all 7 members ---
        ldb   cl_x,u                   ; B = x hi = pixel x
        ldx   cl_row,u                 ; X = y*40, cached (no mul here)
        pshs  b                        ; [S] = x
        andb  #2                       ; x & 2 -> which plane holds this pixel
        beq   sfr_b01
        leax  SF_BANK23,x              ; columns 2,3 -> RAM B @ $A000
        bra   sfr_addr
sfr_b01
        leax  SF_BANK01,x              ; columns 0,1 -> RAM A @ $C000
sfr_addr
        ldb   ,s                       ; B = x
        lsrb
        lsrb                           ; B = x>>2 (byte column)
        abx                            ; X = plane + y*40 + x>>2
        stx   sfr_maddr
        ldb   ,s+                      ; B = x, pop
        lsrb                           ; carry = x bit0 (1 => low nibble)
        bcs   sfr_lowset

* --- high nibble: patch the member loop ---
        lda   #$F0
        sta   sfr_nibmask
        lda   #4*16
        sta   sfr_lobound
        lda   #6*16
        sta   sfr_hibound
        lda   #$0F                     ; keep the low (neighbour) nibble
        sta   sfr_keep
        sta   sfr_ermask                  ; erase-mask: keep low, clear high
        lda   cl_colhi,u
        sta   sfr_col
        bra   sfr_clipchk
sfr_lowset
        lda   #$0F
        sta   sfr_nibmask
        lda   #4
        sta   sfr_lobound
        lda   #6
        sta   sfr_hibound
        lda   #$F0                     ; keep the high (neighbour) nibble
        sta   sfr_keep
        sta   sfr_ermask                  ; erase-mask: keep high, clear low
        lda   cl_collo,u
        sta   sfr_col

* --- can any member fall off an edge? ---
* The cluster is bounded by |dx| <= CL_DX_MAX and |dy| <= CL_DY_MAX, so a master
* away from all four edges cannot clip and the member loop can skip the tests
* entirely. Test the MASTER once here rather than every member there.
sfr_clipchk
        clr   sfr_clip
        ldb   cl_x,u
        cmpb  #CL_DX_MAX
        blo   sfr_needclip
        cmpb  #160-CL_DX_MAX
        bhs   sfr_needclip
        lda   cl_y,u
        cmpa  #CL_DY_MAX
        blo   sfr_needclip
        cmpa  #200-CL_DY_MAX
        blo   sfr_patset
sfr_needclip
        inc   sfr_clip
sfr_patset
        ldb   cl_pat,u                 ; pre-multiplied: no mul here
        clra
        ldx   #cluster_pat
        leax  d,x
        stx   sfr_pat

sfr_member
* --- erase: undo what this member plotted last time this page was the back buffer
        ldx   er_addr,y                ; stored addr (0 => nothing plotted yet)
        beq   sfr_plot
        lda   er_mask,y                ; keep the OTHER nibble, clear this one
        anda  ,x
        ora   er_save,y                ; put the nebula's own nibble back
        sta   ,x
sfr_plot
        ldx   sfr_pat
        lda   sfr_clip
        beq   sfr_noclip
* 16-bit on purpose: x is 0..159 and $9F reads as NEGATIVE in a signed byte, so
* an 8-bit test would call a star at x=159 "off the left edge".
        ldd   2,x                      ; D = dx, sign-extended by the generator
        addb  cl_x,u                   ; D = master_x + dx
        adca  #0
        bmi   sfr_skip                 ; off the left edge
        cmpd  #160
        bhs   sfr_skip                 ; off the right edge
* Vertical is tested on the ROW OFFSET, not on y: cl_row is already y*40 and the
* generator hands us dy*40, so this costs one add and two compares and no
* multiply. It MUST NOT be skipped. A member at y<0 addresses below its plane
* base -- for RAM B that is below $A000, i.e. straight into engine RAM, and it
* silently rewrites the palette. That is what "the whole picture turned blue"
* looks like.
        ldd   4,x                      ; D = dy*40
        addd  cl_row,u                 ; D = (y+dy)*40
        bmi   sfr_skip                 ; above row 0
        cmpd  #8000
        bhs   sfr_skip                 ; below row 199
        ldx   sfr_pat
sfr_noclip
        ldd   ,x                       ; delta = dy*40 + dx/4
        ldx   sfr_maddr
        leax  d,x                      ; X = this member's VRAM byte
        lda   ,x
        tfr   a,b
        andb  #$F0                     ; B = the nibble we are about to cover
sfr_nibmask equ *-1
        cmpb  #4*16                    ; is it another star rather than nebula?
sfr_lobound equ *-1
        blo   sfr_ok
        cmpb  #6*16
sfr_hibound equ *-1
        bls   sfr_skip
sfr_ok
        stb   er_save,y                ; remember the nebula under this star
        anda  #$0F                     ; keep the neighbour's nibble
sfr_keep    equ *-1
        ora   #0                       ; colour, already in the right nibble
sfr_col     equ *-1
        sta   ,x
        stx   er_addr,y
        lda   #$0F
sfr_ermask  equ *-1
        sta   er_mask,y
        bra   sfr_nextmem
* Clipped, or another star already owns this pixel. In the latter case what we
* would save as "background" is its colour -- restoring that later would strand a
* star-coloured dot on the nebula forever. Either way, skipping costs this member
* one frame and leaves the screen exact; er_addr=0 makes next frame's erase pass
* ignore it. The star-vs-nebula test is only decidable because the star colours
* (4/5/6) and the nebula's (0, 2, 7..15) are disjoint -- see sf_layer_color and
* tools/img2to8.py.
sfr_skip
        clra
        clrb
        std   er_addr,y
sfr_nextmem
        ldx   sfr_pat
        leax  CL_MEMSIZE,x
        stx   sfr_pat
        leay  er_size,y
        dec   sfr_members
        bne   sfr_member
        leau  cl_size,u
        lbra  sfr_cluster

sfr_remain  fcb 0
sfr_members fcb 0
sfr_clip    fcb 0
sfr_maddr   fdb 0
sfr_pat     fdb 0
