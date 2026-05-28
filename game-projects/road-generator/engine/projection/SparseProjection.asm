        opt   c
 ifndef SparseProjection_included
SparseProjection_included equ 1

* ======================================================================
* SparseProjection.asm — PORT 6809 DE FUN_78a98 (#C du pipeline route)
*
* Source 68000 : lotus-ste/gamefiles/source/CARS.REL.asm.txt offset $8698
*                (= ram:$78a98). Cf. lotus-ste/doc/extraction/40_road_v1
*                _pipeline_status.md pour le contexte.
*
* Calcule la projection sparse de la route : pour chaque "scanline" perspect-
* ive (16 par segment de circuit), écrit un slot de 4 mots dans le buffer
* de sortie :
*
*   slot.X     (uint16)  bits 2-15 = position horizontale road (D2 cumulé)
*                        bits 0-1  = flag de bord segment (segment[+0xB])
*                                    (bit 1 préservé uniquement à la 1ère
*                                    sub-step de chaque segment = marker
*                                    de transition)
*   slot.Y     (int16)   Y_screen = (D3 × scaling[i]) >> 16 + horizon[i]
*   slot.Ymin  (uint16)  min Y_screen vu (pour clipping vertical horizon)
*   slot.D0a   (int16)   delta_x cumulé (utilisé par AI car alignment)
*
* Structure (= 68000 FUN_78a98) :
*   • Prologue : extrait nibble = (track_pos+2)>>4 ; init D0..D3=0, min_y=$60
*   • Loop 1 : (15-nibble) sub-steps "step 1-7" dans le segment courant
*              (= partie du segment au-dessus de la sub-position courante)
*   • Loop 2 : 7 itérations × (1 segment_advance + 8 sub-steps)
*                                       = 7 segments × 8 sub-steps
*   • Final  : 1 segment_advance + step_first + boucle variable jusqu'à
*              horizon (Y >= $60) ou wraparound (le 8e segment, donc en
*              tout 9 segments traversés idx..idx+8 → ne déborde pas grâce
*              aux 8 segments dupliqués en fin de circuit_data)
*
* nibble = sub-position 0..15 dans le segment courant = (track_pos+2 byte) >> 4.
*
* L'astuce 68000 "A0 = base-5 puis adda #$10" est conservée en 6809 :
*   X = Current_segment_ptr - 5  ;  leax 16,x à chaque segment advance
*   (-11,x) = segment[+0] = delta_curve
*   (-10,x) = segment[+1] = delta_pitch
*   (  0,x) = segment[+0xB] = flag byte
*
* MUL 16×16 → high16 : approximation 2 × Mul9x16 par décomposition
*   scaling = scaling_hi (4b) × 256 + scaling_lo (8b)
*   (D3 × scaling) >> 16 ≈ (D3 × scaling_hi)/256 + (D3 × scaling_lo)/65536
* OK car scaling ≤ $0FFF (Persp_Scaling max 4095). Optimisable en v2 par
* une routine 4-MUL dédiée (UMul16x16Hi tunée).
*
* === CONVENTION D'APPEL ===
*   input :
*     U = LotusCarState* (lit track_pos+2 pour la sub-position
*                         et segment_idx pour le pointeur segment)
*     Proj_buffer_ptr = output buffer (variable globale — setté par caller)
*     Circuit_base + Circuit_nb_segments doivent être set (= circuit chargé)
*   output :
*     Proj_count       = slots écrits (uint16)
*     Proj_min_y       = min Y_screen (uint8)
*     Proj_first_count = (15 - nibble) — pour blitter SMC (cf. $78af6)
*     Proj_last_count  = (1 + nibble)  — pour blitter SMC (cf. $78e8c)
*     [output buffer rempli]
*   trashes : A, B, X, Y, U, flags, dp_engine[0..5] (via Mul9x16)
*
* === GOTCHAS ===
*   • DP doit pointer sur $9F00 (positionné par RAMLoader avant $6100).
*     Mul9x16 utilise dp_engine via SETDP — corrompu pendant l'appel.
*   • Labels préfixés SP_ : lwasm 4.24 casse les @-locales dans les
*     fichiers qui incluent LotusCarState.struct.asm.
*   • Le mul retourne le high word du produit signed 32 ; pour scaling
*     toujours positif (≤4095), l'approximation 2× Mul9x16 est précise
*     à 1 unité près sur Y_screen (perte = (lo × D3) mod 256 / 65536).
* ======================================================================

        INCLUDE "./engine/struct/LotusCarState.struct.asm"
        INCLUDE "./engine/projection/PerspectiveTables.asm"

* ── Variables internes (résidentes, accès extended) ─────────────────
SP_d0            fdb 0          ; delta_curve cumulé (signed 16)
SP_d1            fdb 0          ; -delta_pitch cumulé (signed 16)
SP_d2            fdb 0          ; sum_of_D0 = horizontal road pos (signed 16)
SP_d3            fdb 0          ; sum_of_D1 = vertical road slope (signed 16)
SP_d4            fdb 0          ; segment.delta_curve sign-ext (signed 16)
SP_d5            fdb 0          ; segment.delta_pitch × 2 sign-ext (signed 16)
SP_min_y         fdb $0060      ; min Y_screen vu (16-bit ; init = $60)
SP_d3_save       fdb 0          ; D3 sauvé pour passage à Mul9x16
SP_seg_save      fdb 0          ; X (segment ptr) sauvé pendant mul
SP_tmp_scale     fdb 0          ; scaling sauvé (hi byte:lo byte)
SP_tmp_hi        fdb 0          ; term_hi de la décomposition mul
SP_last_y        fdb 0          ; Y_screen ayant déclenché l'exit horizon
SP_buffer_start  fdb 0          ; buffer de sortie sauvegardé (epilogue)
SP_curve_nibble  fcb 0          ; sub-position 0..15 dans segment courant
SP_loop1_count   fcb 0          ; (= 15 - nibble)
SP_loop2_outer   fcb 0          ; (= 7)
SP_loop2_inner   fcb 0          ; (= 7)

* ── Outputs publiques ────────────────────────────────────────────────
Proj_buffer_ptr   fdb 0
Proj_count        fdb 0
Proj_min_y        fcb 0
Proj_first_count  fcb 0          ; = 15 - nibble (former $78af6 SMC value)
Proj_last_count   fcb 0          ; = 1  + nibble (former $78e8c SMC value)

* ──────────────────────────────────────────────────────────────────────
* SparseProjection — point d'entrée
* ──────────────────────────────────────────────────────────────────────
SparseProjection
        * --- Prologue : nibble = high nibble de byte (track_pos+2) ---
        lda   LotusCarState.track_pos+2,u
        lsra
        lsra
        lsra
        lsra                              ; A = nibble (0..15)
        sta   SP_curve_nibble

        * (15 - nibble) → loop1 count + blitter first count
        ldb   #15
        subb  SP_curve_nibble
        stb   Proj_first_count
        stb   SP_loop1_count

        * (1 + nibble) → blitter last count
        lda   SP_curve_nibble
        inca
        sta   Proj_last_count

        * --- Sauvegarde du buffer de sortie + init Y = buffer ---
        ldy   Proj_buffer_ptr
        sty   SP_buffer_start

        * --- X = Circuit_base + segment_idx × 16 - 5 ---
        * (= équivalent 68000 A0 = $31140 - 5 + idx×16, astuce qui permet
        *  les accès -11,x = byte +0 / -10,x = byte +1 / 0,x = byte +0xB
        *  après les leax 16,x successifs.)
        * segment_idx est cached dans LotusCarState par Lotus_PhysicsTick.
        ldd   LotusCarState.segment_idx,u
        aslb                              ; ×2
        rola
        aslb                              ; ×4
        rola
        aslb                              ; ×8
        rola
        aslb                              ; ×16
        rola                              ; D = segment_idx × 16
        addd  Circuit_base
        subd  #5                          ; D = base + idx×16 - 5
        tfr   d,x

        * --- U = Persp_Horizon[0] (Persp_Scaling[i] sera lu à +256,u) ---
        ldu   #Persp_Horizon

        * --- Reset accumulateurs (D0=D1=D2=D3=0, min_y=$0060) ---
        ldd   #0
        std   SP_d0
        std   SP_d1
        std   SP_d2
        std   SP_d3
        ldd   #$0060
        std   SP_min_y

        * --- 1er segment advance + load D4/D5 (= delta_curve, 2×delta_pitch) ---
        leax  16,x
        ldb   -11,x                       ; segment[+0] = delta_curve (signed)
        sex
        std   SP_d4
        ldb   -10,x                       ; segment[+1] = delta_pitch (signed)
        sex
        aslb
        rola                              ; D = signed_word × 2
        std   SP_d5

        * ──────────────────────────────────────────────────────────────
        * LOOP 1 : (15 - nibble) sub-steps "step 1-7" dans segment courant
        * ──────────────────────────────────────────────────────────────
        lda   SP_loop1_count
        beq   SP_skip_loop1
SP_loop1
        lbsr  SP_substep
        bcs   SP_horizon_exit
        dec   SP_loop1_count
        bne   SP_loop1
SP_skip_loop1

        * ──────────────────────────────────────────────────────────────
        * LOOP 2 : 7 itérations × (segment_advance + 8 sub-steps)
        * ──────────────────────────────────────────────────────────────
        lda   #7
        sta   SP_loop2_outer
SP_loop2_outer_lp
        leax  16,x
        ldb   -11,x
        sex
        std   SP_d4
        ldb   -10,x
        sex
        aslb
        rola
        std   SP_d5

        * 1ère sub-step du segment : pas de andi fffd (preserve flag bit 1
        * comme transition marker)
        lbsr  SP_substep_first
        bcs   SP_horizon_exit

        * 7 sub-steps restantes
        lda   #7
        sta   SP_loop2_inner
SP_loop2_inner_lp
        lbsr  SP_substep
        bcs   SP_horizon_exit
        dec   SP_loop2_inner
        bne   SP_loop2_inner_lp

        dec   SP_loop2_outer
        bne   SP_loop2_outer_lp

        * ──────────────────────────────────────────────────────────────
        * 8ème segment : advance + step_first + boucle variable
        * ──────────────────────────────────────────────────────────────
        leax  16,x
        ldb   -11,x
        sex
        std   SP_d4
        ldb   -10,x
        sex
        aslb
        rola
        std   SP_d5

        * 1ère sub-step (transition marker)
        lbsr  SP_substep_first
        bcs   SP_horizon_exit

        * Boucle variable : sub-steps jusqu'à horizon (= bcs sur Y >= $60).
        * Le 68k storait nibble+1 dans le counter puis loopait via dbra
        * (qui décrémente puis branch si counter != -1), si bien que pour
        * un counter qui démarre > 0 et descend, ça finit par wrap à $FFFF
        * et continue indéfiniment jusqu'à ce que horizon termine la loop.
        * Notre approximation : juste boucler jusqu'à bcs.
SP_loop3
        lbsr  SP_substep
        bcs   SP_horizon_exit
        bra   SP_loop3

* ──────────────────────────────────────────────────────────────────────
* SP_horizon_exit — l'epilogue commun (= LAB_$8b08 dans le 68k)
*
* Au moment où on arrive ici :
*   • Le substep a écrit slot.X et slot.Y, mais PAS slot.Ymin ni slot.D0a
*   • Y pointe APRÈS le slot.Y word (= où aurait été écrit slot.Ymin)
*   • SP_last_y = la valeur Y_screen ayant déclenché l'exit
*
* Deux cas :
*   1) SP_last_y signed positif (= D >= $60 standard horizon top)
*      → count = (Y - buffer_start) / 8 ; min_y = SP_min_y low byte
*   2) SP_last_y signed négatif (= bit 15 set, mais unsigned >= $60 → bhs trigger)
*      → road tilted au-dessus de l'écran ; zero le slot Y et le next slot X
*      → count = ((Y - buffer_start) / 8) + 1 ; min_y = 0
*
* Ensuite "horizon stamp" : la 1ère slot du buffer est réécrite avec
* X &= 1 (= preserve flag bit 0), Y = $60, Y_min = $60, D0a = 0.
* C'est le marker que le blitter utilise pour calculer le top de l'écran.
* ──────────────────────────────────────────────────────────────────────
SP_horizon_exit
        ldd   SP_last_y
        bmi   SP_horizon_underflow

        * --- Cas normal (D >= $60 signed) ---
        tfr   y,d
        subd  SP_buffer_start
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb                              ; D = bytes/8 = slots
        std   Proj_count
        ldb   SP_min_y+1
        stb   Proj_min_y
        bra   SP_write_horizon_stamp

SP_horizon_underflow
        * --- Cas underflow (D < 0 signed, mais bhs sur $60 = D bit15 set) ---
        * Y pointe APRÈS le slot.Y → -2,y = slot.Y (qu'on zero)
        *                          → +0,y = slot.Ymin du suivant (qu'on zero)
        ldd   #0
        std   ,y
        std   -2,y
        * count = bytes/8 + 1
        tfr   y,d
        subd  SP_buffer_start
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb
        addd  #1
        std   Proj_count
        clr   Proj_min_y
        * fall through

SP_write_horizon_stamp
        * --- Modifie 1ère slot du buffer : X &= 1, Y=$60, Y_min=$60, D0=0 ---
        ldx   SP_buffer_start
        clra
        ldb   1,x
        andb  #1                          ; X.low &= 1 ; X.high = 0 (clra)
        std   ,x++
        ldd   #$0060
        std   ,x++                        ; Y = $60
        std   ,x++                        ; Y_min = $60
        ldd   #0
        std   ,x                          ; D0_accum = 0
        rts

* ──────────────────────────────────────────────────────────────────────
* SP_substep_first — 1ère sub-step d'un segment (preserve bits 0+1 du flag)
* SP_substep       — sub-step normale (clear bit 1 du flag)
*
* @input :  X = segment ptr (segment - 5 + (n+1)×16, donc 0,x = flag byte)
*           Y = output buffer ptr (avancé de 8/itération si pas d'exit)
*           U = Persp_Horizon[i*2] (Persp_Scaling = +256)
*           SP_d0..SP_d5 = état cumulé
* @output : Y avancé de 8 (slot complet écrit) si pas d'horizon ;
*           Y avancé de 4 (X+Y seulement) si horizon (carry=1)
*           U avancé de 2 (toujours)
*           Carry = 1 si Y_screen >= $60 (unsigned) → exit
*           SP_last_y = Y_screen (si exit)
* ──────────────────────────────────────────────────────────────────────
SP_substep_first
        lbsr  SP_advance_state
        ldd   SP_d2
        andb  #$FC                        ; clear bits 0-1 de low byte
        orb   ,x                          ; OR avec segment.flag (low byte)
        std   ,y++                        ; write slot.X
        bra   SP_compute_y_screen

SP_substep
        lbsr  SP_advance_state
        ldd   SP_d2
        andb  #$FC
        orb   ,x
        andb  #$FD                        ; clear bit 1 (= NOT transition)
        std   ,y++

SP_compute_y_screen
        * Y_screen = (D3 × Persp_Scaling[i]) >> 16 + Persp_Horizon[i]
        ldd   SP_d3
        std   SP_d3_save
        stx   SP_seg_save                 ; preserve segment ptr (X réutilisé)
        ldx   256,u                       ; X = Persp_Scaling[i]
        lbsr  SP_mul_d3_by_scaling        ; D = (D3 × scaling) >> 16
        ldx   SP_seg_save                 ; restore segment ptr
        addd  ,u++                        ; D += Persp_Horizon[i] ; U += 2
        std   ,y++                        ; write slot.Y (TOUJOURS, même si horizon)

        cmpd  #$0060
        bhs   SP_substep_horizon

        * Continue : update min_y, write slot.Ymin + slot.D0a
        cmpd  SP_min_y
        bge   SP_no_update_min
        std   SP_min_y
SP_no_update_min
        ldd   SP_min_y
        std   ,y++                        ; write slot.Ymin
        ldd   SP_d0
        std   ,y++                        ; write slot.D0a
        andcc #$FE                        ; clear carry = continue
        rts

SP_substep_horizon
        std   SP_last_y                   ; save pour l'epilogue (under/overflow check)
        orcc  #$01                        ; set carry = exit
        rts

* ──────────────────────────────────────────────────────────────────────
* SP_advance_state — applique 1 perspective step :
*   D0 += D4   (delta_curve cumulé)
*   D1 -= D5   (delta_pitch cumulé négatif)
*   D2 += D0   (horizontal road pos)
*   D3 += D1   (vertical road slope)
* ──────────────────────────────────────────────────────────────────────
SP_advance_state
        ldd   SP_d0
        addd  SP_d4
        std   SP_d0
        ldd   SP_d1
        subd  SP_d5
        std   SP_d1
        ldd   SP_d2
        addd  SP_d0
        std   SP_d2
        ldd   SP_d3
        addd  SP_d1
        std   SP_d3
        rts

* ──────────────────────────────────────────────────────────────────────
* SP_mul_d3_by_scaling — (signed_16 × unsigned_12) >> 16 via 2× Mul9x16
*
* Décomposition exploitant Mul9x16 (= product/256 signed) :
*   scaling = scaling_hi × 256 + scaling_lo  (avec scaling ≤ $0FFF)
*   D3 × scaling = D3 × scaling_hi × 256 + D3 × scaling_lo
*   (D3 × scaling) >> 16 = (D3 × scaling_hi) >> 8 + (D3 × scaling_lo) >> 16
*                        = Mul9x16(scaling_hi, D3) + (Mul9x16(scaling_lo, D3) >> 8)
*
* scaling_hi tient sur 4 bits (max 15) → fits 9-bit signed positif
* scaling_lo tient sur 8 bits (max 255) → fits 9-bit signed positif
*
* @input :  X = scaling (uint16, 0..$0FFF)
*           SP_d3_save = signed 16 (= D3)
* @output : D = (D3 × scaling) >> 16, signed 16
* @trashes : X, dp_engine[0..5] (via Mul9x16)
* ──────────────────────────────────────────────────────────────────────
SP_mul_d3_by_scaling
        stx   SP_tmp_scale                ; sauvegarde scaling (byte hi:byte lo)

        * --- term_hi = Mul9x16(scaling_hi, D3) ---
        clra                              ; multiplier high byte = 0 (positif)
        ldb   SP_tmp_scale                ; B = scaling_hi byte (0..15)
        ldx   SP_d3_save                  ; X = D3 signed 16
        lbsr  Mul9x16                     ; D = (scaling_hi × D3) / 256
        std   SP_tmp_hi

        * --- term_lo_x256 = Mul9x16(scaling_lo, D3) ---
        clra
        ldb   SP_tmp_scale+1              ; B = scaling_lo (0..255)
        ldx   SP_d3_save
        lbsr  Mul9x16                     ; D = (scaling_lo × D3) / 256

        * Take signed high byte (= /256 supplémentaire = (scaling_lo × D3) / 65536)
        tfr   a,b
        sex                               ; sign-extend B → A
        addd  SP_tmp_hi                   ; D = total = (D3 × scaling) >> 16
        rts

 endc                                     ; SparseProjection_included
