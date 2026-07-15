* ============================================================================
* band.asm — makes a rectangle of the screen erasable, by remembering the
* pristine nebula that was under it before anything drew there.
* ----------------------------------------------------------------------------
* A static text needs no erase: it is redrawn over itself every frame. Once it
* MOVES -- or disappears -- it smears, because nothing repaints the nebula it
* just left.
*
* The stars' save-under trick (see starfield.asm) does NOT work here. A star
* saves one nibble and owns that pixel alone; a text would have to save under
* itself while stars, and possibly its own previous position, are already on the
* screen -- it would save those as "background" and paint them back later as
* permanent ghosts.
*
* So instead: snapshot the pristine nebula under the whole band ONCE, at init,
* before anything has been drawn over it (BandSave), then repaint that snapshot
* every frame before anything else draws (BandRestore).
*
* ORDER IS LOAD-BEARING. BandRestore must run BEFORE StarfieldRender:
*   - it wipes the stars currently sitting in the band, but StarfieldRender
*     replots them immediately after, so nothing is lost;
*   - it guarantees that a star plotting inside the band reads pristine nebula,
*     so the nibble it saves is real background and never a text pixel;
*   - a star ERASING inside the band writes its saved nibble back over freshly
*     restored nebula, i.e. background onto background -- a no-op.
* Restore it after StarfieldRender instead and the stars crossing the band are
* wiped for good.
*
* Restoring unconditionally every frame -- rather than only when the band's
* contents change -- costs one memcpy and removes the entire class of "who is
* dirty on which page" bugs. gfxlock alternates two buffers, so any dirty-flag
* scheme would need per-page state; a copy that is always correct needs none.
*
* WHY A DESCRIPTOR. There are two of these bands (the oscillating "by FX" line
* and the scenario's captions) and they differ only in geometry, so the geometry
* is data and the routine is shared.
* ============================================================================

* --- descriptor layout (X points at one of these) ---
bd_col0  equ 0                  ; byte, first byte column (0..39)
bd_ncol  equ 1                  ; byte, byte columns — MUST BE EVEN (copied as words)
bd_row0  equ 2                  ; byte, first scanline (0..199)
bd_nrow  equ 3                  ; byte, scanlines
bd_buf   equ 4                  ; word, snapshot buffer
bd_size  equ 6

* Buffer layout is row-interleaved: RAM A row 0, RAM B row 0, RAM A row 1, ...
* Not "all of RAM A then all of RAM B". Interleaving lets the buffer be walked
* by a single roving pointer, which is why the loops below never need a second
* buffer cursor.
BD_BANK  equ $2000              ; RAM B sits $2000 BELOW RAM A ($A000 vs $C000)

* ---------------------------------------------------------------------------
* Bands. Geometry lives here; the routines below own none of it.
* ---------------------------------------------------------------------------

* "by FX" oscillates over x = 50..90 (osc_x in objects/byfx) and is 5 glyphs
* * 4 px wide, so it covers x = 50..109 -> byte columns 12..27 (16, even).
* y_pos is 100 and fnt_4x6_shd spans exactly 7 rows from the draw position, i.e.
* 100..106.
*
* EXACT, not padded. This band used to be 11..28 / 98..108 "deliberately generous
* rather than exact", on the grounds that the glyphs' vertical reach was not
* obvious. It is now known: all 96 glyphs of fnt_4x6_shd were checked and every
* one writes row-aligned within 7 rows of DrawText_pos (see the scenario spec).
* The old padding was paid every frame forever to hedge a fact that had been
* measured: 16x7x2 = 224 bytes/frame against 396, a 43% cut for two numbers.
band_text       fcb 12,16,100,7
                fdb band_text_data
band_text_data  fill 0,16*7*2

* The scenario's captions. "THIS WAS THE ONE STAR STARFIELD DEMO" is 36 glyphs
* * 4 px = 144 px at x = 8 -> byte columns 2..37 (36, even). fnt_4x6_shd spans
* 7 rows from y = 140, i.e. 140..146 -- measured across all 96 glyphs, every
* write row-aligned, so this one is exact rather than padded. Clear of the title
* (88) and the "by FX" band (98..108).
band_msg        fcb 2,36,140,7
                fdb band_msg_data
band_msg_data   fill 0,36*7*2   ; 504 bytes

* ---------------------------------------------------------------------------
* Shared scratch. These are deliberately GLOBAL labels, not @locals: BandSetup
* and the two cursor helpers run in their own label scope, and an @local would
* resolve to a different symbol in each of them.
* fill/fcb, never rmb — see the note in starfield.asm.
* ---------------------------------------------------------------------------
band_ncol  fcb 0
band_row   fcb 0
band_cnt   fcb 0

* ---------------------------------------------------------------------------
* BandSave — snapshot the band. Call ONCE, right after LoadAct has blitted the
* nebula and before anything draws over it. Both video pages hold the same
* pristine picture at that point, so one snapshot serves both.
* In: X = descriptor. Clobbers A,B,D,X,U.
* ---------------------------------------------------------------------------
BandSave
        jsr   BandSetup                ; X = VRAM, U = buffer, band_ncol/row set
@rowloop
        lda   band_ncol
        lsra
        sta   band_cnt
@a      ldd   ,x++                     ; RAM A
        std   ,u++
        dec   band_cnt
        bne   @a
        jsr   BandToB                  ; X -> same row, RAM B
        lda   band_ncol
        lsra
        sta   band_cnt
@b      ldd   ,x++                     ; RAM B
        std   ,u++
        dec   band_cnt
        bne   @b
        jsr   BandToNextA              ; X -> next row, RAM A
        dec   band_row
        bne   @rowloop
        rts

* ---------------------------------------------------------------------------
* BandRestore — repaint the band into the back buffer. Must run inside the
* _gfxlock.on/off bracket and BEFORE StarfieldRender (see the header).
* In: X = descriptor. Clobbers A,B,D,X,U.
* ---------------------------------------------------------------------------
BandRestore
        jsr   BandSetup
@rowloop
        lda   band_ncol
        lsra
        sta   band_cnt
@a      ldd   ,u++
        std   ,x++                     ; RAM A
        dec   band_cnt
        bne   @a
        jsr   BandToB
        lda   band_ncol
        lsra
        sta   band_cnt
@b      ldd   ,u++
        std   ,x++                     ; RAM B
        dec   band_cnt
        bne   @b
        jsr   BandToNextA
        dec   band_row
        bne   @rowloop
        rts

* ---------------------------------------------------------------------------
* REJECTED: stack-blasting this copy with PULS/PSHU.
*
* `ldd ,u++ / std ,x++ / dec / bne` moves 2 bytes in 21 cycles = 10.5/byte, and
* `puls d,x,y` + `pshu d,x,y` moves 6 in 22 = 3.7/byte, so it looks like a free
* halving. It is not: PULS reads S ASCENDING and PSHU writes U DESCENDING, so the
* first unit reads src[0..5] and writes it to dst[ncol-6..ncol-1]. The 6-byte
* groups come out in reverse order -- byte order survives only WITHIN a group.
* On screen that is a scrambled band, which is what it produced.
*
* It is still reachable: run BandSave through the SAME reversing blast and the
* two reversals cancel, since restore(save(x)) reverses the groups twice. That
* costs nothing at runtime -- BandSave runs once at init. It was not done because
* the render loop is already at its 25.0 Hz floor (two 50Hz frames per render),
* so there is nothing left to buy with the cycles; revisit it only if the frame
* needs headroom again.
* ---------------------------------------------------------------------------

* ---------------------------------------------------------------------------
* BandSetup — unpack the descriptor. In: X = descriptor.
* Out: X = $C000 + row0*40 + col0 (RAM A of the band's top-left), U = buffer.
* Clobbers A,B,D.
* ---------------------------------------------------------------------------
BandSetup
        lda   bd_ncol,x
        sta   band_ncol
        lda   bd_nrow,x
        sta   band_row
        ldu   bd_buf,x
        ldb   bd_col0,x
        pshs  b                        ; [S] = col0
        lda   bd_row0,x
        ldb   #40
        mul                            ; D = row0*40  (max 199*40 = 7960, fits)
        addd  #$C000
        tfr   d,x
        clra
        puls  b                        ; D = col0
        leax  d,x                      ; X += col0
        rts

* ---------------------------------------------------------------------------
* BandToB — X from the end of a RAM A run to the start of the same row in RAM B.
* X has advanced by ncol, so back it out and drop a bank. Clobbers B,D.
* ---------------------------------------------------------------------------
BandToB
        ldb   band_ncol
        negb
        sex                            ; D = -ncol, sign-extended (ncol <= 40)
        leax  d,x
        leax  -BD_BANK,x
        rts

* ---------------------------------------------------------------------------
* BandToNextA — X from the end of a RAM B run to the start of the next row in
* RAM A. Clobbers B,D.
* ---------------------------------------------------------------------------
BandToNextA
        ldb   band_ncol
        negb
        sex
        leax  d,x
        leax  BD_BANK+40,x
        rts
