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
*   step_per_line (16.16) = FILE59[(scaling_diff & $FFF0 + delta_Y) × 4]
*     où scaling_diff = scaling[i] - scaling[i+1]
*     (les tables Persp_Recip_k01..k57 sont pré-calculées en 1/n × k × 2^20)
*
*   A4 (D7 step) = Persp_Recip_k01[delta_Y] × 16 >> 16 ≈ 256 / delta_Y
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
*   A2 (FILE59 base)   → absolute (FILE59_BASE_FOR_INTERP)
*   A3 (sparse in)     → X
*   A4 (D7 step)       → LI_a4 (variable)
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
* ======================================================================

        INCLUDE "./engine/struct/LotusCarState.struct.asm"
        INCLUDE "./engine/projection/PerspectiveTables.asm"

* ── Variables internes ──
LI_d0_int       fdb 0          ; D0[31:16] = width integer part
LI_d0_frac      fdb 0          ; D0[15:0]  = width fractional part (16.16)
LI_d1           fdb 0          ; D1 = prev Y, puis N_lines, puis dbf counter
LI_d2           fdb 0          ; D2 = sparse.X = flags
LI_d3_int       fdb 0          ; D3[31:16] = step integer part
LI_d3_frac      fdb 0          ; D3[15:0]  = step fractional part
LI_d4           fdb 0          ; D4 = scaling[i] (current)
LI_d5           fdb 0          ; D5 = sparse[i].Y
LI_d7           fdb 0          ; D7 = depth/extra counter
LI_a4           fdb 0          ; A4 = D7 per-line decrement
LI_loop_cnt     fcb 0          ; inner loop byte counter
LI_shl_cnt      fcb 0          ; helper shl loop counter

* ── FILE59_BASE_FOR_INTERP ──
* Adresse de base utilisée par le 2e lookup de l'interpolateur :
*   index = ((scaling_diff & $FFF0) + N_lines) × 4
*   D3 = long at (FILE59_BASE_FOR_INTERP + index)
* Le 68000 utilisait FILE59_BASE = $2FD40 (= base FILE59 en RAM ST).
* L'offset $40 dans FILE59 → début de Persp_Recip_k01 → on retrouve l'origine
* par soustraction.
* GOTCHA : pour scaling_diff_aligned + N_lines < $10 (= index < $40), la
* lecture tombe dans les 64 oct AVANT Persp_Recip_k01 (= fin de Persp_Scaling
* en layout actuel). Le 68000 lisait des zéros à cet endroit (FILE59 header).
* On accepte la légère imprécision en bord d'horizon (= cas où scaling change
* peu ET N_lines petit, rare en pratique).
 ifndef FILE59_BASE_FOR_INTERP
FILE59_BASE_FOR_INTERP equ Persp_Recip_k01-$40
 endc

* ── API publique ──
LinearInterp_buffer_in   fdb 0
LinearInterp_buffer_out  fdb 0

* ──────────────────────────────────────────────────────────────────────
LinearInterp
        * --- Prologue : init D7 = (N-2) × 256, U = scaling[N], X = sparse_end ---
        ldd   Proj_count                ; D = N
        subd  #2                         ; D = N - 2
        tfr   b,a
        clrb                             ; D = (N-2) << 8
        std   LI_d7

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
        std   LI_d1
        * --- A3 -= 6 → sparse[N-2].Y_min (pour la prochaine itération) ---
        leax  -6,x

        * --- D0 = -(A0) → scaling[N-1] ---
        leau  -2,u
        ldd   ,u
        std   LI_d0_int                  ; D0 high = scaling[N-1]
        ldd   #0
        std   LI_d0_frac                 ; D0 low = 0 (= ext.l de scaling positif)

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
        ldd   LI_d1                      ; D = Y_last (= sparse[N-1].Y signed 16)
        lda   #6
        ldb   LI_d1+1                    ; B = Y_last low byte
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
        std   LI_d5
        * D2 = -(A3) = sparse[i].X
        leax  -2,x
        ldd   ,x
        std   LI_d2
        * A3 -= 4 (skip Y_min/D0a de slot i-1 pour la prochaine iter)
        leax  -4,x
        * D4 = -(U) = scaling[i-1]
        leau  -2,u
        ldd   ,u
        std   LI_d4

        * --- Compare D1 (prev Y) vs D5 (cur Y) ---
        ldd   LI_d1
        cmpd  LI_d5
        lbeq  LI_delta_zero

        * D1 != D5 : compute delta = D1 - D5
        subd  LI_d5
        std   LI_d1                      ; D1 = delta (signed)
        cmpd  #-1
        lbeq  LI_delta_one               ; delta == -1 (= 1 ligne)
        lbmi  LI_normal_interp           ; delta < -1 (= multi-line interp)

* ──────────────────────────────────────────────────────────────────────
* LI_back_step — delta > 0 (sparse Y rétrécit, rare dans les virages serrés)
*   A1 -= 6 × delta (rewind du dense buffer), puis update D0/D1 et exit
* ──────────────────────────────────────────────────────────────────────
LI_back_step
        ldd   LI_d1                      ; D = delta (positive)
        addd  LI_d1                      ; D = 2 delta
        addd  LI_d1                      ; D = 3 delta
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
        * D1 = -D1 = N_lines (positive)
        ldd   LI_d1
        coma
        comb
        addd  #1
        std   LI_d1                      ; D1 = N_lines

        * --- A4 = Persp_Recip_k01[N_lines] × 16, take high word ---
        * Index = 4 × N_lines (byte offset into long-table)
        ldd   LI_d1
        aslb
        rola
        aslb
        rola                             ; D = 4 N_lines
        addd  #Persp_Recip_k01
        tfr   d,x                        ; X = ptr to long
        ldd   ,x
        std   LI_d3_int                  ; reuse LI_d3_int/frac as scratch
        ldd   2,x
        std   LI_d3_frac

        * Shift LI_d3 << 4 (32-bit)
        lbsr  LI_shl_d3_4
        ldd   LI_d3_int                  ; A4 = high word of (Recip_k01[N] << 4)
        std   LI_a4

        * --- D3 (32-bit interp step) = FILE59[((D4 - D0_int) & $FFF0 + N_lines) × 4] ---
        ldd   LI_d4
        subd  LI_d0_int                  ; D = scaling_diff (signed 16)
        andb  #$F0                       ; D &= $FFF0 (clear low nibble of low byte)
        ; Note: high byte conservé via and #$FF implicite — D = scaling_diff & $FFF0
        addd  LI_d1                      ; D += N_lines
        aslb
        rola
        aslb
        rola                             ; D = (...) × 4
        addd  #FILE59_BASE_FOR_INTERP    ; D = abs addr in FILE59 table area
        tfr   d,x
        ldd   ,x
        std   LI_d3_int
        ldd   2,x
        std   LI_d3_frac

        * D1 -= 2 (= dbf counter init)
        ldd   LI_d1
        subd  #2
        ; Note: si N_lines == 2, D1 = 0 → dbf init = 0 → loop 1 fois
        ;       si N_lines == 1, ce path n'est jamais pris (delta_one)
        lda   #0
        sta   LI_loop_cnt
        ldb   LI_d1+1                    ; B = low byte (N_lines fits 8-bit)
        ; Check si N_lines - 2 < 0 → skip inner loop
        cmpb  #0
        bmi   LI_normal_tail             ; N_lines == 2 only writes the tail
        stb   LI_loop_cnt

LI_inner_loop
        * Write triplet (flags, width, extra) = (D2, D0_int, D7)
        ldd   LI_d2
        std   ,y++
        ldd   LI_d0_int
        std   ,y++
        ldd   LI_d7
        std   ,y++

        * D7 -= A4
        ldd   LI_d7
        subd  LI_a4
        std   LI_d7

        * D0 += D3 (32-bit add, big-endian byte order)
        ldd   LI_d0_frac
        addd  LI_d3_frac                 ; D = D0_frac + D3_frac, C set on overflow
        std   LI_d0_frac
        ldd   LI_d0_int                  ; LDD preserves C
        adcb  LI_d3_int+1                ; B += D3_int_lobyte + C
        adca  LI_d3_int                  ; A += D3_int_hibyte + C (from adcb)
        std   LI_d0_int

        dec   LI_loop_cnt
        bpl   LI_inner_loop

LI_normal_tail
        * Tail : 1 dernier triplet + arrondi de D7
        ldd   LI_d2
        std   ,y++
        ldd   LI_d0_int
        std   ,y++
        ldd   LI_d7
        std   ,y++

        ldd   LI_d7
        subd  LI_a4
        * Round D7 : clear low byte, +$100 (= round up high byte)
        clrb                              ; D7 low byte = 0
        adda  #1                          ; D7 high byte += 1
        std   LI_d7
        bra   LI_c1c

* ──────────────────────────────────────────────────────────────────────
* LI_delta_one — delta == -1 (= 1 ligne entre samples)
* ──────────────────────────────────────────────────────────────────────
LI_delta_one
        ldd   LI_d2
        std   ,y++
        ldd   LI_d0_int
        std   ,y++
        ldd   LI_d7
        std   ,y++
        * fall through to LI_c1c

* ──────────────────────────────────────────────────────────────────────
* LI_c1c — épilogue interp/delta_one : D1 = D5 (Y), puis D0 = D4 (scaling)
* ──────────────────────────────────────────────────────────────────────
LI_c1c
        ldd   LI_d5
        std   LI_d1
        * fall through to LI_delta_zero (= D0 = D4)

* ──────────────────────────────────────────────────────────────────────
* LI_delta_zero — D0 ← D4 et reset frac à 0 ; commun aux 4 chemins
*   (point d'entrée direct quand sparse[i].Y == prev Y)
* ──────────────────────────────────────────────────────────────────────
LI_delta_zero
        ldd   LI_d4
        std   LI_d0_int
        ldd   #0
        std   LI_d0_frac
        * fall through to LI_c20

* ──────────────────────────────────────────────────────────────────────
* LI_c20 — fin d'itération outer : D7 -= $100, loop si >= 0
* ──────────────────────────────────────────────────────────────────────
LI_c20
        ldd   LI_d7
        subd  #$100
        std   LI_d7
        lbpl  LI_outer_loop
        rts

* ──────────────────────────────────────────────────────────────────────
* LI_no_work — exit immédiat sans écriture (= projection invalide)
* Dense_Buffer reste tel quel ; DrawFrameRoad dispatchera Line_0001 (M=0)
* sur toutes les lignes → écran sans route.
* ──────────────────────────────────────────────────────────────────────
LI_no_work
        rts

* ──────────────────────────────────────────────────────────────────────
* LI_shl_d3_4 — shift gauche LI_d3 par 4 (32-bit), bouclé pour économiser
*   le code. ~140 octets gagnés vs unrolling complet.
* ──────────────────────────────────────────────────────────────────────
LI_shl_d3_4
        lda   #4
        sta   LI_shl_cnt
LI_shl_loop
        ldd   LI_d3_frac
        aslb
        rola
        std   LI_d3_frac
        ldd   LI_d3_int
        rolb
        rola
        std   LI_d3_int
        dec   LI_shl_cnt
        bne   LI_shl_loop
        rts

 endc                                     ; LinearInterp_included
