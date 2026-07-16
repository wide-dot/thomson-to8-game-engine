# R-Type Starfield — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a 3-plane, 30-star parallax starfield over the open sky that opens R-Type level 1, as a single engine object costing ~2.7% of a rendered image and 360 bytes of RAM.

**Architecture:** One code-only engine object living on a cartridge page (zero resident RAM for code), modelled on `objects/enemies/shell/eraser.asm`. It is called from the level 1 main loop between `DrawTiles` and `DrawSprites`. Each star is one pixel = one VRAM nibble. A star draws only where the pixel is **black**, **saving the byte it covers**, and erases by **restoring that saved nibble** if its colour is still there — so it only ever touches pixels it read and saved, and can never corrupt anything regardless of what fills the background. Erase addresses and saved bytes are kept **per VRAM buffer**, indexed by `gfxlock.backBuffer.id`.

**Tech Stack:** Motorola 6809 assembly, LWASM, the wide-dot TO8 game engine, BuildDisk (Java generator), TOJE emulator via MCP for verification.

**Design spec:** `docs/superpowers/specs/2026-07-15-rtype-starfield-design.md`

## Global Constraints

- **Branch:** `wip-rtype-starfield`.
- **Build:** `cd game-projects/r-type && ./build-linux.sh` (~21 s) → `dist/r-type.rom`.
- **Never run `rm -rf generated-code`** — it discards the compiled-sprite cache (`builder.compilatedSprite.maxTries=500000`) and makes rebuilds very slow. The build is incremental.
- **Colours are palette nibbles: white = `1`, grey = `2`, dark blue = `5`.** Measured from the emitted table in `generated-code/level01/BuilderMainGenCode.asm`. `PaletteTO8.getPaletteData()` loops `colorIndex = 1..16`, dropping the PNG's index 0 (the magenta transparency key), so **hw nibble N = PNG index N+1**. Do **not** read the palette from RAM: `Pal_game` is preceded by `Pal_black`, which ends in two `fdb $0000`, and starting two bytes early invents a phantom black that shifts the whole table (this is exactly how the colours were got wrong the first time).
- **There are TWO black nibbles: `0` and `$F`** (both emit `$0000`). Terrain paints its black as `0`; the untouched sky is uniformly **`$FF`** (verified: an in-object scan probe AND+OR'ing every byte of x 8..151 / y 11..154 on both planes returned `$FF`). A `$00` sky and an `$FF` sky are **pixel-identical on screen** — black-on-black bugs here are invisible, so never infer a VRAM value from a screenshot.
- **The design does not trust the sky's value.** Draw where the pixel is **black** (`nibble == 0` OR `nibble == $F` — a palette-derived test), **saving the covered byte**; erase by **restoring the saved nibble** if our colour is still there. Restore only *our* nibble from the saved byte, so a neighbouring star in the same byte's other nibble is not trampled. The starfield can then never corrupt anything, whatever the background turns out to be.
- **`read_memory` at a stop does NOT read VRAM.** The `$A000-$DFFF` window maps whatever the pager last put there and returns a convincing `$FF`. To read what the rendering code sees, probe from **inside the object** into resident RAM (`$6000-$9FFF`, always mapped) and read that.
- **Star zone:** x = 8..151, y = 11..154 (tile rows 0..11). Never below y=154: tile rows 12..14 are terrain.
- **Speeds (px per 50 Hz frame, 8.8 fixed):** plane 0 white = 1.0 (`$0100`), plane 1 grey = 0.5 (`$0080`), plane 2 dark blue = 0.25 (`$0040`). Stars move **left** (x decreasing).
- **All motion must be scaled by `gfxlock.frameDrop.count`**, mirroring `Scroll` in `engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered-even.asm`. Without it the starfield speeds up whenever a frame is dropped.
- **Measured render rate: 4.44 frames per rendered image (~11 img/s).** Measured with `gfxlock.bufferSwap.count` (`$819E`, **16-bit**, incremented once per buffer swap): 517 → 562 = **45 renders over 200 frames**. A rendered image therefore costs ~88 700 cycles (4.44 × 19968), so the starfield's ~2400 cycles is **~2.7%**.
  This is the number that makes the speeds legal: the per-image step is 4.4 / 2.2 / 1.1 px, so **every plane clears the 1-px-per-image quantisation floor** (Global Constraints, sub-pixel rule). The white plane's 4.4 px/image is the one to judge by eye in Task 3 — it is above the ~3 px threshold for motion that reads as continuous. If it strobes, lower `$0100`; do not raise the other two.
- **Double buffer:** 2 VRAM pages. Every erase address is per-buffer, selected by `gfxlock.backBuffer.id` (`$81A0`). Getting this wrong produces ghost/doubled stars — a bug already paid for once on the `starfield` project.
- **`_Obj_Run` does not restore the cartridge page.** Only call it from resident code (the main loop), which is what we do.
- **Dev-only build settings already on this branch, to be reverted before merge:** `gameModeBoot=level01` and `invincible` in `config-linux.properties`.

### Silent-failure rules (each of these already cost hours on the `starfield` project — see `to8-game-mode-gotchas`)

These all **assemble cleanly** and fail bizarrely at runtime. Respect them without needing to rediscover them.

- **Never use `RMB` to reserve data.** The module is assembled to a RAW binary loaded contiguously; `RMB` advances the location counter but emits **no bytes**, so everything after it lands one address early and routines get entered one byte in (first opcode skipped). Use **`fcb` / `fdb` / `fill 0,n`** — as the engine always does. Symptom: a symbol's address in `main.glb`/`.lst` is exactly 1 higher than where the opcode really sits.
- **No `:` statement separator in lwasm.** `fdb 1 : fcb 2` emits **only the first directive**; `:` and the rest is silently taken as a comment. One directive per line.
- **`fcb 1, 3` (space after the comma) is a hard `Bad expression`.** Write `fcb 1,3`.
- **`ldd st_x,u` loads D = A:B and destroys anything kept in B** — including a loop counter. Bound pointer loops with `cmpu #end`.
- **`beq`/`bne` only reach ±127 bytes.** A zero-guard branching to an `rts` at the far end of a long routine overflows; invert the test and inline the `rts`.
- **`@local` labels are scoped to the enclosing global label**, and lwasm quietly stops resolving them in a routine with ~29+ locals (the budget is per translation unit, so it can assemble standalone and fail in the full build). If `@local`s start reporting undefined for no reason, give the data global names (`sf_*`) rather than bisecting.
- **Assert emitted spans.** For any table, check in `main.lwmap` / `main.glb` that `next_symbol - table_symbol` equals `entries * entry_size`. This is the defence against the whole silent-truncation family above.

## TOJE boot recipe (used by every verification step)

```
load_cartridge  path=game-projects/r-type/dist/r-type.rom
run_frames      n=150
type_keys       scancodes=["1E"]   hold_frames=4     # 1E = "0" on the NUMERIC KEYPAD, not the "0" key (0x49)
run_frames      n=900                                # ~10 s of decompression, screen stays black
screenshot      path=/tmp/<name>.png
```

Gotchas that cost time before (from `~/.claude/.../memory/toje-boot-recipe.md`):
- `run_frames` parameter is **`n`**, not `frames`.
- `read_memory` needs hex as `"0xNNNN"`; a bare `"6587"` parses as decimal.
- **PC alone never means "crashed"** — landing in `$FAxx`/`$FBxx` is the ROM IRQ handler. Use `dump_trace_ring` or a screenshot.
- **Do not diagnose from `step` / long `run_until_pc`** — they desync this machine and produce false negatives.

## Addressing model (CONFIRMED on screen in Task 1 — do not re-derive)

For a pixel at (x, y), x ∈ 0..159, y ∈ 0..199:

```
offset = (x >> 2) + 40 * y
base   = $C000 if (x AND 2) = 0 else $A000      ; NOTE THE ORDER - see below
addr   = base + offset
nibble = high if x even, low if x odd
```

**The BM16 planes are inverted in data space: RAM B sits at `$A000` and RAM A at `$C000`.** The asset encoder (`PngToBottomUpB16Bin`) writes RAM A as its *first* 8000 bytes = pixel columns 0,1 of each 4-pixel group, and RAM B as the second 8000 = columns 2,3. The intuitive reading of `scroll-map-buffered-even.asm` (`$A000` first) is therefore **backwards**.

This is not a hypothesis: it was diagnosed and fixed on the `starfield` project (commit `77c558e4`). Getting it backwards puts every pixel ±2 px off depending on the parity of `x>>1`, which makes a scrolling star jitter back and forth — it looks like it moves *backwards*, not like it is misplaced. Task 1 exists to confirm this mapping on screen before anything is built on it.

**Verify plane order positionally** (left-to-right pixel order). Counting distinct colours does not catch this bug — it hid it once on the previous project.

**Task 1 confirmed this model exactly as written**: four probe pixels at x=40..43 landed adjacent and in order. Screenshot geometry (the earlier note in this plan was wrong): the 704×624 PNG is 2× a 352×312 PAL frame, active area 320×200 at 2× = 640×400, centred — so **`screen_x = 32 + bm16_x*4`** and **`screen_y = 112 + bm16_y*2`**. Check: bm16 (40,40) → screen (192,192).

lwasm has **no `>>` operator** (`Bad operand`); write `(x/4)`.

**Do not call `DRS_XYToAddress` for a single pixel.** Its odd-column branch returns `location_1 = $C000 + (x>>2) + 40y + 1`; the `+1` is correct for a pre-shifted sprite blit but is one byte off for an isolated pixel. Computing the address inline is also cheaper (~33 cycles vs ~50).

## File Structure

| File | Responsibility |
|---|---|
| `game-projects/r-type/objects/levels/01/starfield/obj.asm` | Create. The whole starfield: init, move, erase, draw. Lives on a cartridge page. |
| `game-projects/r-type/objects/levels/01/starfield/obj.d7.properties` | Create. `code=` declaration (disk build). |
| `game-projects/r-type/objects/levels/01/starfield/obj.t2.properties` | Create. Same, cartridge build. Code-only objects have identical d7/t2 files (cf. `shell/eraser.*.properties`). |
| `game-projects/r-type/game-mode/01/main.d7.properties` | Modify. Declare `object.starfield` → generates `ObjID_starfield`. |
| `game-projects/r-type/game-mode/01/main.t2.properties` | Modify. Same, for d7/t2 parity. |
| `game-projects/r-type/game-mode/01/ram_data.asm` | Modify. The 30-star table (resident RAM), next to `shellEraseTable`. |
| `game-projects/r-type/game-mode/01/main.asm` | Modify. Call `StarfieldInit` at level start; `_Obj_Run ObjID_starfield` between `DrawTiles` and `DrawSprites`. |
| `docs/superpowers/specs/2026-07-15-rtype-starfield-design.md` | Modify (Task 5). Correct the `DRS_XYToAddress` recommendation and the RAM figure. |

## Data model

Star record, **12 bytes**, 30 stars = **360 bytes**:

| offset | field | size | note |
|---|---|---|---|
| 0 | `st_x` | 2 | x in 8.8 fixed; high byte = pixel 0..159 |
| 2 | `st_ybase` | 2 | 40 × y, precomputed at spawn (saves a `mul` per star per frame) |
| 4 | `st_e0` | 2 | erase address for buffer 0; **0 = nothing to erase** |
| 6 | `st_e1` | 2 | erase address for buffer 1 |
| 8 | `st_s0` | 1 | **saved byte** covered in buffer 0 |
| 9 | `st_s1` | 1 | **saved byte** covered in buffer 1 |
| 10 | `st_m0` | 1 | nibble written in buffer 0: `$F0` = high, `$0F` = low |
| 11 | `st_m1` | 1 | nibble written in buffer 1 |

`st_s0`/`st_s1` are what buy independence from the background's value: +2 bytes per star (60 total) for a starfield that only ever touches pixels it read and saved, and gives them back unchanged.

Three planes × 10 stars, stored as three contiguous arrays. Plane speed and colour are constants of the plane loop, not per-star fields.

---

### Task 1: Calibration — one hardcoded star, prove bank + nibble mapping

Everything downstream depends on the addressing model, which is currently an assumption. This task puts four pixels at known coordinates and reads the answer off the screen.

**Files:**
- Create: `game-projects/r-type/objects/levels/01/starfield/obj.asm`
- Create: `game-projects/r-type/objects/levels/01/starfield/obj.d7.properties`
- Create: `game-projects/r-type/objects/levels/01/starfield/obj.t2.properties`
- Modify: `game-projects/r-type/game-mode/01/main.d7.properties:22` (after `object.messages`)
- Modify: `game-projects/r-type/game-mode/01/main.t2.properties` (same line)
- Modify: `game-projects/r-type/game-mode/01/main.asm:215` (after `jsr DrawTiles`)

**Interfaces:**
- Consumes: `gfxlock.backBuffer.id` (`$81A0`), the `Object` entry-point convention, `_Obj_Run`.
- Produces: `ObjID_starfield`; object entry label `Object`; a **confirmed** addressing formula recorded as a comment at the top of `obj.asm`, which every later task uses.

- [ ] **Step 1: Create the object properties files**

`objects/levels/01/starfield/obj.d7.properties`:
```properties
code=./objects/levels/01/starfield/obj.asm
```

`objects/levels/01/starfield/obj.t2.properties`:
```properties
code=./objects/levels/01/starfield/obj.asm
```

- [ ] **Step 2: Write the calibration object**

`objects/levels/01/starfield/obj.asm`. Four white pixels at x = 40, 41, 42, 43 on y = 40, using the assumed model. x=40 and x=41 share a byte; x=42/43 share the next byte, in the other bank.

```asm
; ===========================================================================
; Starfield - CALIBRATION BUILD (tache 1, temporaire)
; Trace 4 pixels blancs en (40,40) (41,40) (42,40) (43,40) pour prouver la
; correspondance banque + nibble. Modele attendu (plans BM16 INVERSES) :
;   offset = (x >> 2) + 40*y
;   base   = $C000 si (x AND 2)=0, sinon $A000
;   nibble = haut si x pair, bas si x impair
; ===========================================================================
        INCLUDE "./engine/macros.asm"

Object
        ; --- x=40 : (40 AND 2)=0 -> $C000 ; pair -> nibble haut
        ldx   #$C000+(40>>2)+40*40
        lda   ,x
        ora   #$20
        sta   ,x
        ; --- x=41 : (41 AND 2)=0 -> $C000 ; impair -> nibble bas (meme octet)
        ldx   #$C000+(41>>2)+40*40
        lda   ,x
        ora   #$02
        sta   ,x
        ; --- x=42 : (42 AND 2)=2 -> $A000 ; pair -> nibble haut
        ldx   #$A000+(42>>2)+40*40
        lda   ,x
        ora   #$20
        sta   ,x
        ; --- x=43 : (43 AND 2)=2 -> $A000 ; impair -> nibble bas
        ldx   #$A000+(43>>2)+40*40
        lda   ,x
        ora   #$02
        sta   ,x
        rts
```

- [ ] **Step 3: Declare the object**

In `game-mode/01/main.d7.properties`, after the `object.messages` line:
```properties
object.starfield=./objects/levels/01/starfield/obj.d7.properties
```

In `game-mode/01/main.t2.properties`, same position:
```properties
object.starfield=./objects/levels/01/starfield/obj.t2.properties
```

- [ ] **Step 4: Call it from the render chain**

In `game-mode/01/main.asm`, in `mainloop.routine.running`, between `jsr DrawTiles` and `jsr DrawSprites`:

```asm
        jsr   DrawTiles
        _Obj_Run ObjID_starfield        ; starfield: after terrain, before sprites
        _Obj_Run ObjID_shellEraser      ; efface la rotonde (objet hors-pool sur page cartouche)
        jsr   DrawSprites
```

- [ ] **Step 5: Build**

Run: `cd game-projects/r-type && ./build-linux.sh`
Expected: `Build done !` three times, no `Exception`. `ObjID_starfield` now exists — verify:
Run: `grep -n "ObjID_starfield" generated-code/level01/FD/main.glb`
Expected: one line, `ObjID_starfield EQU $00xx`.

- [ ] **Step 6: Boot in TOJE and screenshot**

Use the boot recipe above. Then read the PNG.

Expected: **4 white pixels in a horizontal run** in the sky, at screen pixel x=40..43, y=40. The screenshot is 704×624 for a 160×200 BM16 image, so each BM16 pixel is ~4.4 screen px horizontally — the run appears near screen-x ≈ 176..193, screen-y ≈ 125.

- [ ] **Step 7: Interpret the result and lock the model**

Compare against what you see. The four pixels are a 2-bit probe:

| Observation | Meaning |
|---|---|
| 4 adjacent pixels, in order, at x=40..43 | Model correct as written. Record it as confirmed. |
| Pixels appear in pairs but the pairs are swapped (42,43 then 40,41) | Bank mapping is the other way round: `(x AND 2)=0` → `$A000`, else `$C000`. |
| Within each pair the two pixels are swapped | Nibble order is inverted: x even → low nibble, x odd → high. |
| Pixels land at a wrong x entirely, or a gap appears | The offset formula is wrong — re-derive from `scroll-map-buffered-even.asm`, do not guess. |

**Judge position, not colour.** All four probes are white on purpose: the failure mode here is *placement*, and counting colours cannot see it. Read the pixels left-to-right and check the order.

Fix the constants in the header comment of `obj.asm` so it states the **confirmed** model, then rebuild and re-screenshot until the 4 pixels are exactly at x=40..43 in order.

- [ ] **Step 8: Commit**

```bash
git add game-projects/r-type/objects/levels/01/starfield/ \
        game-projects/r-type/game-mode/01/main.d7.properties \
        game-projects/r-type/game-mode/01/main.t2.properties \
        game-projects/r-type/game-mode/01/main.asm
git commit -m "feat(r-type): starfield object skeleton, VRAM addressing calibrated

Four probe pixels at known coordinates confirm the BM16 bank and nibble
mapping on screen rather than by derivation. DRS_XYToAddress is not used:
its odd-column branch adds 1 byte, which is right for a pre-shifted sprite
blit and wrong for an isolated pixel."
```

---

### Task 2: 30 static stars, three colours, guarded by the nibble==0 test

**Files:**
- Modify: `game-projects/r-type/game-mode/01/ram_data.asm` (after `shellEraseTable_end`, line ~73)
- Modify: `game-projects/r-type/objects/levels/01/starfield/obj.asm` (replace the calibration body)
- Modify: `game-projects/r-type/game-mode/01/main.asm` (call `StarfieldInit` at level start)

**Interfaces:**
- Consumes: the confirmed addressing model from Task 1; `RandomNumber` (returns a pseudo-random value in **D**, `engine/math/RandomNumber.asm`, already INCLUDEd resident at `main.asm:581`); `InitRNG`.
- Produces:
  - `starTable` — 30 records of 10 bytes, resident RAM (see Data model).
  - `starTable_end`.
  - `StarfieldInit` — resident routine, no parameters, clobbers A/B/X/U. Seeds all 30 stars with random x/y and zeroed erase slots.
  - `st_x`/`st_ybase`/`st_e0`/`st_e1`/`st_m0`/`st_m1` — record field offset EQUs.
  - `star_record_size` = 10, `star_per_plane` = 10.

- [ ] **Step 1: Add the star table to resident RAM**

In `game-mode/01/ram_data.asm`, after `shellEraseTable_end`:

```asm
* ===========================================================================
* Starfield - 3 plans x 10 etoiles, 10 octets par etoile (cf.
* docs/superpowers/specs/2026-07-15-rtype-starfield-design.md)
* ===========================================================================
star_record_size            equ   12
star_per_plane              equ   10
st_x                        equ   0    ; 2 o : x en 8.8 (octet haut = pixel 0..159)
st_ybase                    equ   2    ; 2 o : 40*y precalcule au spawn
st_e0                       equ   4    ; 2 o : adresse d'effacement buffer 0 (0 = rien)
st_e1                       equ   6    ; 2 o : adresse d'effacement buffer 1 (0 = rien)
st_s0                       equ   8    ; 1 o : octet SAUVEGARDE recouvert, buffer 0
st_s1                       equ   9    ; 1 o : octet SAUVEGARDE recouvert, buffer 1
st_m0                       equ   10   ; 1 o : nibble ecrit buffer 0 ($F0 haut / $0F bas)
st_m1                       equ   11   ; 1 o : nibble ecrit buffer 1
starTable                   fill  0,3*star_per_plane*star_record_size
starTable_end
; Scratch RESIDENT de l'objet starfield. L'objet vit sur une PAGE CARTOUCHE
; (lecture seule dans le build T2) : il ne peut ni s'auto-modifier ni stocker
; d'etat chez lui. Meme raison que shellEraseTable pour eraser.asm.
starEraseOff                fcb   0    ; st_e0 ou st_e1 selon le buffer courant
starSaveOff                 fcb   0    ; st_s0 ou st_s1 selon le buffer courant
starMaskOff                 fcb   0    ; st_m0 ou st_m1
starFrameCnt                fcb   0    ; compteur de la boucle frame-drop
starXTmp                    fcb   0    ; x de l'etoile courante (D sert a l'offset)
```

- [ ] **Step 2: Write StarfieldInit**

Add to `objects/levels/01/starfield/obj.asm`. **`StarfieldInit` must be reachable from the main loop's resident code**, so it is part of the object and called via a dedicated command — but for simplicity it is called once at level start through `_Obj_RunB` with a command byte. Use the two-entry-point pattern: `Object` dispatches on B.

Replace the whole file body with:

```asm
; ===========================================================================
; Starfield - 3 plans x 10 etoiles sur le ciel ouvert du niveau 1.
;
; Modele d'adressage BM16 (CONFIRME en tache 1 - ne pas re-deriver) :
;   offset = (x >> 2) + 40*y ; bank = bit1(x) (0 -> $A000, 1 -> $C000)
;   nibble = bit0(x)         (0 -> haut, 1 -> bas)
;
; Invariant central : index 0 et 1 sont tous deux noirs a l'ecran mais
; distincts en memoire. Le decor peint son noir en index 1 ; le ciel jamais
; dessine (empty_tile) reste a 0 depuis le ClearDataMem. Donc :
;   tracer  : si notre nibble == 0     -> ecrire la couleur, sinon rien
;   effacer : si notre nibble == notre couleur -> ecrire 0, sinon rien
; -> le starfield ne peut pas abimer le decor.
;
; Appele entre DrawTiles et DrawSprites (cf. main.asm) :
;   EraseSprites a deja restaure le fond -> pas de remanence a l'effacement
;   DrawSprites sauvegarde le fond AVEC nos etoiles -> le vaisseau passe devant
; ===========================================================================
        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/levels/01/starfield/starfield.const.asm"

Object                                  ; B = commande (starfield.INIT / .FRAME)
        leax  @rtn,pcr
        jmp   [b,x]                     ; meme idiome que main.asm:180 (jmp [a,x])
@rtn    fdb   StarfieldInit
        fdb   StarfieldFrame

; ---------------------------------------------------------------------------
; StarfieldInit - seed les 30 etoiles (x/y aleatoires, rien a effacer)
; ---------------------------------------------------------------------------
StarfieldInit
        jsr   InitRNG
        ldu   #starTable
@loop
        jsr   RandomNumber              ; D = aleatoire
        ; x = 8 + (rand & 127)  -> 8..135  (dans 8..151)
        andb  #127
        addb  #8
        stb   st_x,u                    ; octet haut = pixel
        clr   st_x+1,u                  ; sous-pixel = 0
        jsr   RandomNumber
        ; y = 11 + (rand % 144) -> 11..154 ; on prend & 127 puis +11 -> 11..138
        andb  #127
        addb  #11
        ; ybase = 40 * y
        lda   #40
        mul                             ; D = 40*y
        std   st_ybase,u
        ldd   #0
        std   st_e0,u                   ; rien a effacer
        std   st_e1,u
        leau  star_record_size,u
        cmpu  #starTable_end
        blo   @loop
        rts
```

Note on the y range: `& 127` gives 0..127 → y = 11..138, inside the 11..154 zone. Stars never reach the bottom 16 px of the zone; that is acceptable and keeps the code branch-free. Do **not** widen it with a modulo — 154 is a hard limit (terrain below).

- [ ] **Step 3: Write StarfieldFrame — draw only, no motion, no erase yet**

Append to `obj.asm`. Three plane loops via a descriptor table:

```asm
; ---------------------------------------------------------------------------
; StarfieldFrame - efface puis retrace les 30 etoiles
; ---------------------------------------------------------------------------
; descripteur de plan = 6 octets : ptr(2), vitesse 8.8(2), couleur nibble haut(1),
; couleur nibble bas(1). Lus par StarDraw/StarErase en 2,y / 4,y / 5,y.
planeTable
        fdb   starTable+0*star_per_plane*star_record_size
        fdb   $0100                     ; 1.0 px/frame
        fcb   $10,$01                   ; blanc = nibble 1
        fdb   starTable+1*star_per_plane*star_record_size
        fdb   $0080                     ; 0.5 px/frame
        fcb   $20,$02                   ; gris = nibble 2
        fdb   starTable+2*star_per_plane*star_record_size
        fdb   $0040                     ; 0.25 px/frame
        fcb   $50,$05                   ; bleu fonce = nibble 5
planeTable_end

StarfieldFrame
        ldy   #planeTable
@plane
        ldu   ,y                        ; U = premiere etoile du plan
        ldx   #star_per_plane
@star
        pshs  x,y
        bsr   StarDraw
        puls  x,y
        leau  star_record_size,u
        leax  -1,x
        bne   @star
        leay  6,y                       ; descripteur suivant (6 octets, pas 8)
        cmpy  #planeTable_end
        blo   @plane
        rts

; ---------------------------------------------------------------------------
; StarDraw - trace l'etoile en U si son nibble vaut 0
;   entree : U = etoile, Y = descripteur de plan
; ---------------------------------------------------------------------------
StarDraw
        lda   st_x,u                    ; A = x pixel
        cmpa  #8
        blo   @out                      ; garee / hors zone -> ne rien tracer
        sta   starXTmp                  ; x est relu 2x : D sera occupe par l'offset
        lsra
        lsra                            ; A = x>>2
        tfr   a,b
        clra                            ; D = x>>2
        addd  st_ybase,u                ; D = (x>>2) + 40*y  -- D est pris a partir d'ici
        ldx   #$C000                    ; plans INVERSES : (x AND 2)=0 -> $C000
        lda   starXTmp
        bita  #2
        beq   >
        ldx   #$A000
!       leax  d,x                       ; X = base + offset
        lda   starXTmp
        bita  #1
        bne   @low                      ; x impair -> nibble bas

; --- nibble haut -----------------------------------------------------------
@high   lda   ,x                        ; A = octet du fond
        tfr   a,b
        andb  #$F0                      ; B = notre nibble
        beq   @hok                      ; nibble 0 = noir -> on peut tracer
        cmpb  #$F0                      ; nibble F = noir aussi (ciel vierge)
        bne   @skip                     ; ni l'un ni l'autre -> occupe, ne rien faire
@hok    ldb   starEraseOff
        stx   b,u                       ; retenir l'adresse, pour CE buffer
        ldb   starSaveOff
        sta   b,u                       ; SAUVEGARDER l'octet recouvert
        ldb   starMaskOff
        pshs  a
        lda   #$F0
        sta   b,u                       ; retenir le nibble ecrit
        puls  a
        anda  #$0F                      ; vider notre nibble
        ora   4,y                       ; couleur nibble haut
        sta   ,x
        rts

; --- nibble bas ------------------------------------------------------------
@low    lda   ,x
        tfr   a,b
        andb  #$0F
        beq   @lok
        cmpb  #$0F
        bne   @skip
@lok    ldb   starEraseOff
        stx   b,u
        ldb   starSaveOff
        sta   b,u
        ldb   starMaskOff
        pshs  a
        lda   #$0F
        sta   b,u
        puls  a
        anda  #$F0
        ora   5,y                       ; couleur nibble bas
        sta   ,x
        rts

@skip   ldb   starEraseOff              ; rien de trace -> rien a effacer
        leax  b,u
        clr   ,x
        clr   1,x
@out    rts
```

The draw test is **"is this pixel black?"** — nibble `0` or `$F`, the palette's two black entries — not "is it the sky". That keeps it independent of whatever fills the sky. `4,y` / `5,y` hold the plane's colour already positioned in the high / low nibble (e.g. white = `$10` / `$01`).

Note the register discipline: `x` is read from `st_x,u` into `starXTmp` **before** `addd` takes over `D`. Reloading it with `ldb st_x,u` after the `addd` would destroy the low byte of the offset — the `ldd`/`ldb` B-clobber trap from the Global Constraints.

`starXTmp` is another resident scratch byte; add it next to `starEraseOff` in `ram_data.asm`.

- [ ] **Step 4: Wire init and per-frame calls**

In `game-mode/01/main.asm`, at level start — right after `_Obj_Run ObjID_LevelWave` and before `jsr InitScroll` (so the table is seeded before the first render):

```asm
        _Obj_RunB ObjID_starfield,#starfield.INIT
```

And change the render-chain call added in Task 1 to pass the frame command:

```asm
        jsr   DrawTiles
        _Obj_RunB ObjID_starfield,#starfield.FRAME
        _Obj_Run ObjID_shellEraser
        jsr   DrawSprites
```

`main.asm` cannot see the object's EQUs — the object is assembled separately onto its own page. Follow the existing `hud.NORMAL` / `endstage.TICK` precedent: put the two command constants in a shared const file included by both sides.

Create `objects/levels/01/starfield/starfield.const.asm`:
```asm
starfield.INIT   equ   0
starfield.FRAME  equ   2
```

INCLUDE it from `obj.asm` (replacing the two inline EQUs shown in Step 2) and from `main.asm`, next to the other const includes around `main.asm:23`:
```asm
        INCLUDE "./objects/levels/01/starfield/starfield.const.asm"
```

- [ ] **Step 5: Build**

Run: `cd game-projects/r-type && ./build-linux.sh`
Expected: `Build done !`, no `Exception`.

- [ ] **Step 6: Verify on screen**

Boot with the TOJE recipe, screenshot, read the PNG.

Expected:
- **30 single pixels** scattered over the sky: 10 white, 10 grey, 10 dark blue.
- **None on the terrain** at the bottom, none in the HUD band.
- They do not move (no motion yet) but the terrain scrolls behind/below them.
- The ship draws **over** any star it crosses, with no star left inside the ship sprite.

If stars are missing, do not assume a crash from the PC — check `dump_trace_ring`, and `read_memory 0x<starTable> 32` to confirm the table was seeded (non-zero `st_x`/`st_ybase`).

- [ ] **Step 7: Commit**

```bash
git add game-projects/r-type/game-mode/01/ram_data.asm \
        game-projects/r-type/game-mode/01/main.asm \
        game-projects/r-type/objects/levels/01/starfield/
git commit -m "feat(r-type): seed and draw 30 static stars over the level 1 sky

Three planes of 10, drawn only where the VRAM nibble reads 0 (virgin sky),
so a star can never overwrite terrain or a sprite. No motion or erase yet."
```

---

### Task 3: Motion, per-buffer erase, frame-drop compensation

The task that makes it a starfield, and the one with the known trap: erase addresses are per VRAM buffer.

**Files:**
- Modify: `game-projects/r-type/objects/levels/01/starfield/obj.asm`

**Interfaces:**
- Consumes: `gfxlock.backBuffer.id` (`$81A0`, 0 or non-0), `gfxlock.frameDrop.count` (`$81A3`), the star record fields from Task 2.
- Produces: `StarErase`, `StarMove` (internal to `obj.asm`); `StarfieldFrame` gains its final shape: **erase → move → draw**, per star.

- [ ] **Step 1: Select the buffer's erase slot once per frame**

**Do not use the engine's `equ *-1` self-modifying-operand idiom here.** It is legitimate in `scroll-map-buffered-even.asm` and `Obj_Run.asm` because that code is *resident in RAM*. This object runs from a **cartridge page**, which is read-only in the T2 build (`dist/r-type.rom` — the very image we test) — the write would fail silently. `eraser.asm` sets the precedent: it keeps all state in resident RAM and branches instead.

Resolve the per-buffer offsets once per frame into the resident scratch bytes added in Task 2, then index with `B`:

```asm
StarfieldFrame
        ; slot d'effacement du buffer courant (cf. eraser.asm)
        lda   #st_e0
        ldb   #st_m0
        tst   gfxlock.backBuffer.id
        beq   >
        lda   #st_e1
        ldb   #st_m1
!       sta   starEraseOff
        stb   starMaskOff
        lda   #st_s0
        tst   gfxlock.backBuffer.id
        beq   >
        lda   #st_s1
!       sta   starSaveOff
```

`StarErase` / `StarDraw` then reach the right slot with `ldb starEraseOff ; ldx b,u` (and `stx b,u` to write it back). Indexed-with-B addressing costs ~2 cycles more than a patched operand and works identically on disk and cartridge.

- [ ] **Step 2: Write StarErase**

```asm
; ---------------------------------------------------------------------------
; StarErase - efface l'etoile de CE buffer si elle y est encore
;   entree : U = etoile, Y = descripteur de plan
; ---------------------------------------------------------------------------
StarErase
        ldb   starEraseOff              ; st_e0 ou st_e1 selon le buffer
        ldx   b,u
        beq   @out                      ; 0 = rien a effacer dans ce buffer
        ldb   starMaskOff
        lda   b,u                       ; masque du nibble ecrit ($F0 / $0F)
        bmi   @high                     ; $F0 -> bit7 = 1

; --- nibble bas ------------------------------------------------------------
@low    lda   ,x
        anda  #$0F
        cmpa  5,y                       ; toujours NOTRE couleur ?
        bne   @out                      ; non -> le decor a repris la place
        ldb   starSaveOff
        lda   b,u                       ; A = octet sauvegarde
        anda  #$0F                      ; ne garder QUE notre nibble d'origine
        ldb   ,x
        andb  #$F0                      ; garder le nibble voisin tel quel
        pshs  a
        orb   ,s+
        stb   ,x
        rts

; --- nibble haut -----------------------------------------------------------
@high   lda   ,x
        anda  #$F0
        cmpa  4,y
        bne   @out
        ldb   starSaveOff
        lda   b,u
        anda  #$F0
        ldb   ,x
        andb  #$0F
        pshs  a
        orb   ,s+
        stb   ,x
@out    rts
```

Restore **only our nibble** from the saved byte, keeping the neighbouring nibble as it currently stands: two stars can share a byte, and blindly writing back the whole saved byte would erase the other one.

- [ ] **Step 3: Write StarMove with frame-drop compensation**

Mirrors `Scroll`'s repeated-subtraction loop. `frameDrop.count` is 4–5 in practice, capped at 8 by `main.asm:139`.

The counter lives in `starFrameCnt` (resident RAM, added in Task 2), **not** in the object — the object's page is read-only on the cartridge.

```asm
; ---------------------------------------------------------------------------
; StarMove - x -= vitesse * frameDrop.count
;   entree : U = etoile, Y = descripteur de plan
; ---------------------------------------------------------------------------
StarMove
        lda   gfxlock.frameDrop.count
        bne   >
        inca                            ; 0 -> compter 1 trame
!       sta   starFrameCnt
@loop   ldd   st_x,u
        subd  2,y                       ; vitesse 8.8 du plan
        std   st_x,u
        dec   starFrameCnt
        bne   @loop
        rts
```

- [ ] **Step 4: Record the erase address when drawing**

`StarDraw` (Task 2) must now store where it drew, into this buffer's slot, and store 0 when it skipped:

Note: `st_e0`/`st_e1` are **words**, so the "nothing drawn" case must clear both bytes — there is no `clr` on a 16-bit indexed operand.

```asm
@high   lda   ,x
        bita  #$F0                      ; notre nibble occupe ?
        bne   @skip                     ; oui -> ne rien tracer
        ora   4,y                       ; couleur nibble haut
        sta   ,x
        ldb   starEraseOff
        stx   b,u                       ; retenir ou on a trace, pour CE buffer
        ldb   starMaskOff
        lda   #$F0
        sta   b,u
        rts
@skip   ldb   starEraseOff              ; rien de trace -> rien a effacer
        leax  b,u
        clr   ,x
        clr   1,x
        rts
```

Apply the symmetric change to the `@low` path, using `5,y` for the colour and `$0F` for the mask.

- [ ] **Step 5: Sequence the frame as erase → move → draw**

In the per-star body of `StarfieldFrame`:

```asm
@star
        pshs  x,y
        bsr   StarErase
        bsr   StarMove
        bsr   StarDraw
        puls  x,y
```

Erase must read the **old** address before `StarMove` changes x — that ordering is the whole point.

- [ ] **Step 6: Build and verify motion**

Run: `cd game-projects/r-type && ./build-linux.sh`

Boot with the TOJE recipe. Then screenshot twice, 25 frames apart:
```
screenshot path=/tmp/sf_a.png
run_frames n=25
screenshot path=/tmp/sf_b.png
```

Expected:
- Stars have **moved left** between the two shots; white fastest, dark blue slowest.
- **No trails** — a star leaves no lit pixel behind it.
- **No doubling** — each star is a single pixel, not a pair 1–2 px apart. Doubling means the per-buffer erase slot is wrong (the classic bug); re-check Step 1.
- Terrain and HUD are **pixel-identical** to the Task 2 screenshots apart from the scroll.

- [ ] **Step 7: Verify no ghost after the ship passes**

Let the ship sit still ~100 frames, screenshot, and confirm no star is stuck inside or around the ship sprite, and no black notch appears in the ship.

- [ ] **Step 8: Commit**

```bash
git add game-projects/r-type/objects/levels/01/starfield/obj.asm \
        game-projects/r-type/game-mode/01/ram_data.asm
git commit -m "feat(r-type): starfield motion with per-buffer erase

Erase addresses are stored per VRAM page and selected by
gfxlock.backBuffer.id, as in shell/eraser.asm; a single shared slot
produces ghost and doubled stars. Motion is scaled by frameDrop.count so
the field does not speed up when a frame is dropped."
```

---

### Task 4: Respawn, and stop respawning past the sky

**Files:**
- Modify: `game-projects/r-type/objects/levels/01/starfield/obj.asm`

**Interfaces:**
- Consumes: `glb_camera_x_pos` (`$9FE6`, 16-bit), `RandomNumber`.
- Produces: `StarRespawn`; constant `starfield.camMax equ 530`.

- [ ] **Step 1: Add respawn on left-edge exit**

In `StarMove`, after updating x, test the high byte against the left edge:

```asm
        lda   st_x,u
        cmpa  #8
        bhi   @done                     ; encore a l'ecran
        bsr   StarRespawn
@done   rts
```

- [ ] **Step 2: Write StarRespawn**

```asm
; ---------------------------------------------------------------------------
; StarRespawn - reinjecte l'etoile a droite, y aleatoire
;   entree : U = etoile
; ---------------------------------------------------------------------------
StarRespawn
        ldd   glb_camera_x_pos
        cmpd  #starfield.camMax
        bhs   @park                     ; plus de ciel -> ne pas reinjecter
        lda   #151                      ; bord droit de la zone
        sta   st_x,u
        clr   st_x+1,u
        jsr   RandomNumber
        andb  #127
        addb  #11                       ; y = 11..138
        lda   #40
        mul
        std   st_ybase,u
        rts
@park   ldd   #0                        ; gare l'etoile hors zone : x=0 -> jamais tracee
        std   st_x,u
        rts
```

`@park` sets x=0, which is left of the 8..151 zone. `StarDraw` would still compute an address for x=0, so **add an early-out at the top of `StarDraw`**: `lda st_x,u ; cmpa #8 ; blo @out`. Without it, parked stars would draw at x=0, inside the left mask band.

- [ ] **Step 3: Add the constant**

At the top of `obj.asm`:
```asm
starfield.camMax  equ   530             ; colonne ~44 ; le mur est colonne 48 (x=576)
```

- [ ] **Step 4: Build and verify the wrap**

Run: `cd game-projects/r-type && ./build-linux.sh`, boot, then screenshot every ~50 frames for ~300 frames.

Expected:
- Stars leaving the left edge **reappear on the right** at a new height; the field stays populated.
- Star count stays at ~30 (count the lit sky pixels; each BM16 pixel ≈ 4.4×3.1 screen px).
- **No star ever appears on the terrain.**

- [ ] **Step 5: Verify the extinction and the terrain is undamaged**

The camera reaches `starfield.camMax` ≈ 530 after ~2800 frames at 0.1875 px/frame — too slow to wait for naively. Force it: after booting, `write_memory` `glb_camera_x_pos` (`$9FE6`) to `0x0210` (528) and run ~200 frames.

Expected:
- Stars still on screen finish their run left and vanish; none respawn.
- The sky empties before the wall arrives.
- **Critical regression:** run on to the tunnel and screenshot. There must be **no stray black pixel inside the terrain**. If one appears, the erase guard ("still my colour") is broken.

- [ ] **Step 6: Commit**

```bash
git add game-projects/r-type/objects/levels/01/starfield/obj.asm
git commit -m "feat(r-type): star respawn, and extinction at the end of the sky

Stars leaving the left edge re-enter on the right at a random height until
the camera reaches the wall that closes the open sky, then park off-zone.
The nibble guard already makes the field safe in the tunnel; this only
avoids stars popping in the tunnel's empty pockets."
```

---

### Task 5: Measure the cost, then correct the spec

**Files:**
- Modify: `docs/superpowers/specs/2026-07-15-rtype-starfield-design.md`

**Interfaces:**
- Consumes: the finished starfield.
- Produces: a measured cost figure, and a spec that matches the code.

- [ ] **Step 1: Measure the render rate with the starfield on**

Do **not** use `profile_loops` iteration counts to infer the render rate — that is how the pre-implementation estimate got this wrong by a factor of 1.6 (a `$621A`-rooted loop at 109 iterations/300 frames looked like the render loop and was not). Use the engine's own render counter.

Boot, let the level run to a steady state (past the opening wave), then:
```
read_memory addr=0x819E len=2      # gfxlock.bufferSwap.count, 16-bit  -> before
run_frames  n=200
read_memory addr=0x819E len=2      # -> after
```
Renders = after − before. **Read 2 bytes** — reading 1 byte gets the high byte and tells you nothing.

**Baseline to compare against: 45 renders / 200 frames** (measured on this branch without the starfield). ≥43 means the starfield costs ≤5% and is within budget.

- [ ] **Step 2: If it costs more than ~5%, apply the levers in order**

1. Drop to 20 stars: change `star_per_plane` from 10 to 7 in `ram_data.asm` (21 stars) — one constant, no code change.
2. Only then micro-optimise `StarDraw`'s address computation.

Do not optimise before measuring.

- [ ] **Step 3: Correct the spec**

In `docs/superpowers/specs/2026-07-15-rtype-starfield-design.md`:
- In "Modèle de données", correct 9 bytes/star → 10, and ~270 → 300 bytes. Add the four resident scratch bytes (`starEraseOff`, `starMaskOff`, `starFrameCnt`, `starXTmp`).
- Confirm that "Adressage VRAM" (already rewritten with the inverted-plane model before implementation started) matches what Task 1 actually measured. If Task 1 found a different mapping, the spec is the thing that is wrong — fix it here and say so.
- In "Contraintes mesurées", the render rate is **4.44 frames/image (~11 img/s), 45 renders per 200 frames** measured via `gfxlock.bufferSwap.count` — not the "109 iterations / 300 trames ≈ 18 img/s" the spec currently claims, which came from a `profile_loops` back-edge that was not the render loop. Correct the table and the ~55 000-cycles-per-image figure (it is ~88 700).
- In "Budget", replace the ~2400-cycle estimate with the measured figure from Step 1, and the "~4% of an image" with the recomputed share (~2.7% against 88 700 cycles).
- Resolve the "À vérifier à l'implémentation" note on nibble order with the answer Task 1 found.

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/specs/2026-07-15-rtype-starfield-design.md
git commit -m "docs(r-type): correct the starfield spec against the implementation

DRS_XYToAddress is not reusable for a single pixel; records are 10 bytes,
not 9; cycle cost replaced with the measured figure and the nibble order
with the one calibration proved."
```

---

## Before merge

Not a task — a checklist for whoever finishes the branch.

- [ ] Revert `gameModeBoot=level01` → `gameModeBoot=title` in `config-linux.properties`.
- [ ] Revert `builder.lwasm.define=invincible,...` → `builder.lwasm.define=boot_color_gr=$00,boot_color_b=$00`.
- [ ] **Keep** the `gameMode.level01=./game-mode/01/main.d7.properties` fix — the Linux config was broken and pointed at a non-existent file.
- [ ] **Keep** `build-linux.sh`.
- [ ] Rebuild and verify the normal path still works: title screen → loading → level 1 with the starfield.
