        opt   c
 ifndef LinearInterp_included
LinearInterp_included equ 1

* ======================================================================
* LinearInterp.asm — PORT 6809 DE FUN_78f3a (#D du pipeline route)
*
* Source 68000 : lotus-ste/gamefiles/source/CARS.REL.asm.txt offset $8B3A
*                (= ram:$78f3a). Cf. lotus-ste/doc/extraction/14_renderi
*                ng_pipeline.md §2bis et /40_road_v1_pipeline_status.md.
*
* Convertit le buffer SPARSE (sortie de SparseProjection — N slots de 4
* mots) en buffer DENSE (96 lignes × 3 mots = 6 octets/ligne) consommé
* par DRAW_FRAME_ROAD (task #E).
*
* Pour chaque transition sparse[i+1] → sparse[i] (parcourue à l'envers,
* du LOIN vers le PROCHE), interpole linéairement entre les deux samples :
*
*   Slot output = (flags, width, extra)
*     flags   = sparse[i].X      (constant durant la transition)
*     width   = scaling[i+1] interpolé vers scaling[i] (fixed-point 16.16)
*     extra   = D7 décrémenté de A4 par ligne (sert au pattern stripe)
*
*   delta_Y = sparse[i].Y - sparse[i+1].Y  (= nb de lignes à remplir)
*
*   step_per_line (16.16) = FILE59[scaling_diff_aligned + delta_Y]
*     où scaling_diff_aligned = (scaling[i] - scaling[i+1]) & $FFF0
*     Table 2-tier paged à $5000 (= cf PerspectiveTables.asm) :
*       index < 512 : Plage A (= packed 2 oct/entry à $5000)
*       index ≥ 512 : Plage B (= full 4 oct/entry à $5400)
*
*   A4 (D7 step) = A4_table[delta_Y] (= précomputed 256/N truncated, 8-bit)
*     LUT résidente 64 oct (= A4_table dans PerspectiveTables.asm)
*
* === CAS PARTICULIERS ===
*   delta_Y == 0 : sparse Y identique → pas d'écriture, juste D0 ← D4
*   delta_Y == 1 : 1 ligne unique → 1 triplet écrit directement (no interp)
*   delta_Y < 0  : back-step (sparse Y rétrécit, rare) → A1 -= 6×|delta|
*   delta_Y > 1  : multi-line interp (boucle dbf)
*
* === CONVENTION D'APPEL ===
*   input :
*     LinearInterp_buffer_in  = sparse buffer (= Proj_buffer_ptr typiquement)
*     LinearInterp_buffer_out = dense buffer destination (6 oct × 96 = 576 oct)
*     Proj_count              = N slots sparse (= sortie de SparseProjection)
*   output :
*     [LinearInterp_buffer_out rempli avec triplets (flags,width,extra)]
*   trashes : A,B,X,Y,U, flags
*
* === MAPPING 68000 → 6809 ===
*   A0 (scaling ptr)   → U
*   A1 (dense out)     → Y
*   A2 (FILE59 base)   → absolute (LI_TABLE_A_BASE / LI_TABLE_B_BASE)
*   A3 (sparse in)     → X
*   A4 (D7 step)       → LI_a4 (variable, lookup via A4_table)
*   D0 (32-bit width)  → LI_d0_int (16 hi) + LI_d0_frac (16 lo)
*   D1..D5,D7          → LI_d1..LI_d5, LI_d7 (variables 16-bit)
*   D6 = -1 sentinel   → constante #-1 dans le code
*   swap+add.l         → 32-bit add via addd + adcb/adca byte propagation
*   dbf D1, lab        → dec byte counter + bpl
*
* === GOTCHAS ===
*   • DP doit pointer sur $9F00 (positionné par RAMLoader)
*   • Labels préfixés LI_ (lwasm 4.24 + LotusCarState.struct.asm)
*   • Persp_Scaling toujours positif → D0 high word init = 0 (skip ext.l)
*   • 32-bit add D0 += D3 implémenté byte-byte avec carry chain
*   • LI_d3_int/frac et LI_a4 invariants byte+0 (LI_d3_int) et byte+1
*     (LI_d3_frac, LI_a4) restent à $00 → init via `fdb 0` suffit, lookups
*     écrivent seulement les bytes "data" (= économie ~6 inst/lookup)
* ======================================================================

        INCLUDE "./engine/struct/LotusCarState.struct.asm"
        INCLUDE "./engine/projection/PerspectiveTables.asm"

* ── Variables internes ──
* GOTCHA : LI_d3_int et LI_d3_frac DOIVENT rester adjacents en mémoire dans
* cet ordre (= 4 octets consécutifs). Le lookup Plage A écrit via `std
* LI_d3_int+1` qui couvre `LI_d3_int+1` (= byte B1) et `LI_d3_int+2` (=
* `LI_d3_frac+0`, byte B2). Les bytes `LI_d3_int+0` et `LI_d3_frac+1`
* restent à $00 (= init par `fdb 0`, jamais touchés ailleurs) → reconstruit
* le long $00:B1:B2:$00 attendu pour le 32-bit add D0 += D3.
* -- Variables HOT mappées en DP (dp_extreg = 28 oct trash) -----------
* "Trash" = contenu non garanti entre frames. LinearInterp init tout au
* début de l'appel. dp_extreg réutilisé : SparseProjection finit avant
* qu'on lance LinearInterp (pipeline séquentiel main loop).
* GOTCHA : LI_d3_int + LI_d3_frac DOIVENT rester adjacents (offsets
* +8/+10) car le lookup Plage A écrit via `std <LI_d3_int+1` qui couvre
* les bytes [+9, +10] = low de LI_d3_int + high de LI_d3_frac.
* Idem LI_d0_int + LI_d0_frac (+0/+2) pour le 32-bit add D0 += D3.
* Idem LI_a4 (+18) : low byte écrit par lookup, high reste $00.
LI_d0_int       equ dp_extreg+0     ; D0[31:16] = width integer part
LI_d0_frac      equ dp_extreg+2     ; D0[15:0]  = width frac (16.16)
LI_d1           equ dp_extreg+4     ; D1 = prev Y, puis N_lines, puis dbf
LI_d2           equ dp_extreg+6     ; D2 = sparse.X = flags
LI_d3_int       equ dp_extreg+8     ; D3[31:16] = step int. byte+0 toujours $00
LI_d3_frac      equ dp_extreg+10    ; D3[15:0]  = step frac. byte+1 toujours $00
LI_d4           equ dp_extreg+12    ; D4 = scaling[i] (current)
LI_d5           equ dp_extreg+14    ; D5 = sparse[i].Y
LI_d7           equ dp_extreg+16    ; D7 = depth/extra counter
LI_a4           equ dp_extreg+18    ; A4 = D7 per-line decrement. byte+0 = $00
LI_loop_cnt     equ dp_extreg+20    ; inner loop byte counter
LI_outer_cnt    equ dp_extreg+21    ; outer loop counter (= N-1 transitions). Séparé
                               ; de <LI_d7 pour éviter exit précoce quand
                               ; inner loop décrémente <LI_d7 par <LI_a4.

* ── API publique ──
LinearInterp_buffer_in   fdb 0
LinearInterp_buffer_out  fdb 0

* ──────────────────────────────────────────────────────────────────────
LinearInterp
        * --- Init bytes "toujours $00" (avant : init par fdb 0, maintenant
        * en DP trash → reset explicite chaque appel). Le lookup Plage A
        * écrit via `std <LI_d3_int+1` qui couvre bytes [+9, +10] = low de
        * d3_int + high de d3_frac. Les bytes +8 (= d3_int high) et +11
        * (= d3_frac low) DOIVENT rester $00 pour reconstruire le long
        * $00:B1:B2:$00 attendu par le 32-bit add. Idem LI_a4 byte+0.
        clra
        clrb
        std   <LI_d3_int                  ; bytes +8, +9 = 0
        std   <LI_d3_frac                 ; bytes +10, +11 = 0
        std   <LI_a4                      ; bytes +18, +19 = 0

        * --- Prologue : init D7 = (N-2) × 256, U = scaling[N], X = sparse_end ---
        ldd   Proj_count                ; D = N
        subd  #2                         ; D = N - 2
        tfr   b,a
        clrb                             ; D = (N-2) << 8
        std   <LI_d7

        * --- Init compteur outer loop séparé = N - 1 transitions ---
        * LI_d7 ne peut pas servir de compteur fiable : il est décrémenté par
        * LI_a4 dans LI_inner_loop, ce qui dépite le budget avant N-1 iters.
        ldd   Proj_count                 ; D = N
        decb                             ; D = N - 1 (= nb transitions à processer)
        stb   <LI_outer_cnt

        ldd   Proj_count                 ; D = N
        aslb
        rola                             ; D = 2N
        addd  #Persp_Scaling
        tfr   d,u                        ; U = Persp_Scaling + 2N (= scaling[N])

        ldd   Proj_count
        aslb
        rola
        aslb
        rola
        aslb
        rola                             ; D = 8N
        addd  LinearInterp_buffer_in
        tfr   d,x                        ; X = sparse_end

        * --- A3 -= 4 → sparse[N-1].Y_min ---
        leax  -4,x
        * --- D1 = -(A3) → sparse[N-1].Y ---
        leax  -2,x
        ldd   ,x
        std   <LI_d1
        * --- A3 -= 6 → sparse[N-2].Y_min (pour la prochaine itération) ---
        leax  -6,x

        * --- D0 = -(A0) → scaling[N-1] ---
        leau  -2,u
        ldd   ,u
        std   <LI_d0_int                  ; D0 high = scaling[N-1]
        ldd   #0
        std   <LI_d0_frac                 ; D0 low = 0 (= ext.l de scaling positif)

        * --- A1 = dense + 6 × Y_last (= conforme 68k, Y_screen absolu) ---
        * Dense_Buffer indexé par Y_screen absolu 0..191 (= 1152 oct).
        *
        * Sur 68k, l'overflow naturel des tables permet Y_last grand
        * (jusqu'à $0FFF), Y init pointe hors buffer puis back_step ramène
        * dedans avant écriture. Notre port reproduit cette mécanique.
        *
        * SECURITY : ce code peut écrire jusqu'à 6 × $0FFF = 24570 oct hors
        * Dense_Buffer si back_step ne se déclenche pas. C'est PROTÉGÉ par :
        *   1. Notre SparseProjection cape loop3 à (subseg+1) substeps. Si
        *      l'horizon n'est pas atteint, SP_last_y est synthétisé depuis
        *      le dernier slot.Y écrit (= valeur dans [0..C0] typiquement).
        *   2. Le back_step de LinearInterp se déclenche dès que sparse[i].Y
        *      diminue (delta>0), ramenant Y dans le buffer.
        *   3. En BSS Y_last reste signed-16 ; mul 8x8 avec lo byte sera
        *      tronqué. Pour Y_last > 192 (= hors viewport), c'est du noise
        *      qui sera écrasé par les back_steps suivants.
        ldd   <LI_d1                      ; D = Y_last (= sparse[N-1].Y signed 16)
        lda   #6
        ldb   <LI_d1+1                    ; B = Y_last low byte
        mul                              ; D = 6 × Y_last.lo (8x8 unsigned)
        addd  LinearInterp_buffer_out
        tfr   d,y                        ; Y = dense + 6 × Y_last (modulo)

* ──────────────────────────────────────────────────────────────────────
* OUTER LOOP — itère les sparse slots backward
* ──────────────────────────────────────────────────────────────────────
LI_outer_loop
        * D5 = -(A3) = sparse[i].Y
        leax  -2,x
        ldd   ,x
        std   <LI_d5
        * D2 = -(A3) = sparse[i].X
        leax  -2,x
        ldd   ,x
        std   <LI_d2
        * A3 -= 4 (skip Y_min/D0a de slot i-1 pour la prochaine iter)
        leax  -4,x
        * D4 = -(U) = scaling[i-1]
        leau  -2,u
        ldd   ,u
        std   <LI_d4

        * --- Compare D1 (prev Y) vs D5 (cur Y) ---
        ldd   <LI_d1
        cmpd  <LI_d5
        lbeq  LI_delta_zero

        * D1 != D5 : compute delta = D1 - D5
        subd  <LI_d5
        std   <LI_d1                      ; D1 = delta (signed)
        cmpd  #-1
        lbeq  LI_delta_one               ; delta == -1 (= 1 ligne)
        lbmi  LI_normal_interp           ; delta < -1 (= multi-line interp)

* ──────────────────────────────────────────────────────────────────────
* LI_back_step — delta > 0 (sparse Y rétrécit, rare dans les virages serrés)
*   A1 -= 6 × delta (rewind du dense buffer), puis update D0/D1 et exit
* ──────────────────────────────────────────────────────────────────────
LI_back_step
        ldd   <LI_d1                      ; D = delta (positive)
        addd  <LI_d1                      ; D = 2 delta
        addd  <LI_d1                      ; D = 3 delta
        aslb
        rola                             ; D = 6 delta
        coma
        comb
        addd  #1                         ; D = -6 delta
        leay  d,y                        ; Y += D = Y - 6 delta
        lbra  LI_c1c

* ──────────────────────────────────────────────────────────────────────
* LI_normal_interp — delta < -1 (= cur_Y > prev_Y + 1, fill N_lines)
* ──────────────────────────────────────────────────────────────────────
LI_normal_interp
        * BUG FIX : X est le sparse buffer ptr (= position itération outer).
        * Les lookups FILE59 ci-dessous clobbent X. Sans save/restore,
        * l'itération suivante de LI_outer_loop lit depuis les tables au
        * lieu du Sparse_Buffer → cascade de zéros → ~16 scanlines rendues
        * au lieu de 72. Push X avant clobber, restaure avant exit.
        pshs  x

        * D1 = -D1 = N_lines (positive)
        ldd   <LI_d1
        coma
        comb
        addd  #1
        std   <LI_d1                      ; D1 = N_lines

        * --- A4 = LUT[N_lines] (= précomputed 256/N truncated, 8-bit) ---
        * GOTCHA : LI_a4+0 reste à $00 (= init fdb 0, jamais touché). Seul
        * le low byte est modifié → reconstruit le 16-bit $00:A4 attendu.
        ldb   <LI_d1+1                    ; B = N_lines low byte
        ldx   #A4_table
        abx                              ; X = ptr to A4_table[N]
        ldb   ,x                         ; B = A4 (8-bit)
        stb   <LI_a4+1                    ; <LI_a4 = $00:A4 (high byte reste $00)

        * --- D3 (32-bit interp step) = FILE59[((D4 - D0_int) & $FFF0 + N_lines)] ---
        * Index entry (= longword position dans FILE59 logique).
        * Dispatch sur la valeur :
        *   index < 512 : Plage A (= packed 2 oct/entry à LI_TABLE_A_BASE)
        *   index ≥ 512 : Plage B (= full 4 oct/entry à LI_TABLE_B_BASE)
        ldd   <LI_d4
        subd  <LI_d0_int                  ; D = scaling_diff (signed 16)
        andb  #$F0                       ; D &= $FFF0 (clear low nibble of low byte)
        addd  <LI_d1                      ; D += N_lines (= index logique)

        cmpd  #LI_PLAGE_BOUNDARY
        bhs   LI_d3_lookup_full

        * --- PLAGE A : packed 2 oct/entry ---
        * offset = index × 2, ldd lit [B1, B2], std écrit aux offsets +1, +2
        * de LI_d3_int → reconstruit le long $00:B1:B2:$00 (bytes +0 et +3
        * restent à $00 par init fdb 0).
        aslb
        rola                             ; D = index × 2
        addd  #LI_TABLE_A_BASE
        tfr   d,x
        ldd   ,x                         ; A=B1, B=B2
        std   <LI_d3_int+1                ; écrit [B1][B2] sur <LI_d3_int+1 et <LI_d3_frac+0
        bra   LI_d3_lookup_done

LI_d3_lookup_full
        * --- PLAGE B : full 4 oct/entry ---
        * offset = (index - 512) × 4 (= rebase au début de la plage B).
        subd  #LI_PLAGE_BOUNDARY
        aslb
        rola
        aslb
        rola                             ; D = (index - 512) × 4
        addd  #LI_TABLE_B_BASE
        tfr   d,x
        ldd   ,x
        std   <LI_d3_int
        ldd   2,x
        std   <LI_d3_frac

LI_d3_lookup_done
        * Lead-B : flags (LI_d2) est constant sur tout le segment → hoisté dans X,
        * écrit via `stx ,y++` dans l'inner loop + tail (−5 cyc/ligne, le `ldd LI_d2`
        * disparaît). Le ptr sparse (pshs'd en LI_normal_interp) reste sur la pile ;
        * son `puls x` est déplacé en fin de LI_normal_tail (= avant retour outer).
        ldx   <LI_d2                      ; X = flags (constant ce segment)

        * --- Inner loop counter = N_lines - 2 ---
        * Inner runs (N-1) fois (= bpl tant que counter >= 0), puis tail = 1 write.
        * Total = N_lines triplets écrits.
        *
        * BUG FIX historique : on utilisait `ldb LI_d1+1` APRÈS un `subd #2` qui
        * NE MODIFIAIT PAS LI_d1 → le compteur valait N (pas N-2) → inner_loop
        * tournait N+1 fois → overshoot total = N+2 writes au lieu de N → les
        * widths dépassaient target puis chutaient brutalement quand l'iter
        * suivante snapait D0 := D4 (= la cause du bug #111 monotonie cassée).
        ldd   <LI_d1
        subd  #2                         ; D = N - 2 (= compteur dbf)
        bmi   LI_normal_tail             ; si N < 2 (= N=1, ne devrait pas arriver) skip inner
        stb   <LI_loop_cnt                ; <LI_loop_cnt = N - 2 (= fit byte tant que N <= 257)

LI_inner_loop
        * Write triplet (flags, width, extra) = (D2, D0_int, D7)
        stx   ,y++                        ; flags (Lead-B : X = LI_d2 hoisté)
        ldd   <LI_d0_int
        std   ,y++
        ldd   <LI_d7
        std   ,y++

        * D7 -= A4
        ldd   <LI_d7
        subd  <LI_a4
        std   <LI_d7

        * D0 += D3 (32-bit add, big-endian byte order)
        ldd   <LI_d0_frac
        addd  <LI_d3_frac                 ; D = D0_frac + D3_frac, C set on overflow
        std   <LI_d0_frac
        ldd   <LI_d0_int                  ; LDD preserves C
        adcb  <LI_d3_int+1                ; B += D3_int_lobyte + C
        adca  <LI_d3_int                  ; A += D3_int_hibyte + C (from adcb)
        std   <LI_d0_int

        dec   <LI_loop_cnt
        bpl   LI_inner_loop

LI_normal_tail
        * Tail : 1 dernier triplet + arrondi de D7
        stx   ,y++                        ; flags (Lead-B : X = LI_d2 hoisté)
        ldd   <LI_d0_int
        std   ,y++
        ldd   <LI_d7
        std   ,y++

        ldd   <LI_d7
        subd  <LI_a4
        * Round D7 : clear low byte, +$100 (= round up high byte)
        clrb                              ; D7 low byte = 0
        adda  #1                          ; D7 high byte += 1
        std   <LI_d7
        puls  x                           ; Lead-B : restaure ptr sparse (déplacé de lookup_done)
        bra   LI_c1c

* ──────────────────────────────────────────────────────────────────────
* LI_delta_one — delta == -1 (= 1 ligne entre samples)
* ──────────────────────────────────────────────────────────────────────
LI_delta_one
        ldd   <LI_d2
        std   ,y++
        ldd   <LI_d0_int
        std   ,y++
        ldd   <LI_d7
        std   ,y++
        * fall through to LI_c1c

* ──────────────────────────────────────────────────────────────────────
* LI_c1c — épilogue interp/delta_one : D1 = D5 (Y), puis D0 = D4 (scaling)
* ──────────────────────────────────────────────────────────────────────
LI_c1c
        ldd   <LI_d5
        std   <LI_d1
        * fall through to LI_delta_zero (= D0 = D4)

* ──────────────────────────────────────────────────────────────────────
* LI_delta_zero — D0 ← D4 et reset frac à 0 ; commun aux 4 chemins
*   (point d'entrée direct quand sparse[i].Y == prev Y)
* ──────────────────────────────────────────────────────────────────────
LI_delta_zero
        ldd   <LI_d4
        std   <LI_d0_int
        ldd   #0
        std   <LI_d0_frac
        * fall through to LI_c20

* ──────────────────────────────────────────────────────────────────────
* LI_c20 — fin d'itération outer : D7 -= $100 (dithering gradient inter-
* transitions). Loop via LI_outer_cnt séparé (= N-1 décrémenté → 0).
* ──────────────────────────────────────────────────────────────────────
LI_c20
        ldd   <LI_d7
        subd  #$100
        std   <LI_d7
        dec   <LI_outer_cnt               ; -1 transition processée
        lbne  LI_outer_loop              ; loop tant que > 0
        rts

* ──────────────────────────────────────────────────────────────────────
* LI_no_work — exit immédiat sans écriture (= projection invalide)
* Dense_Buffer reste tel quel ; DrawFrameRoad dispatchera Line_0001 (M=0)
* sur toutes les lignes → écran sans route.
* ──────────────────────────────────────────────────────────────────────
LI_no_work
        rts

 endc                                     ; LinearInterp_included
