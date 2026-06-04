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
*   • Loop 1 : (15-nibble) sub-steps dans le segment COURANT (= conforme 68k)
*   • Loop 2 : 7 itérations × (1 segment_advance + 8 sub-steps)
*                                       = 7 segments × 8 sub-steps
*   • Final  : 1 segment_advance + step_first + boucle (subseg+1) jusqu'à
*              horizon (Y >= $60). Conservation 68k : 72 substeps = 9×8.
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

* -- Variables internes HOT mappées en DP (dp_extreg = 28 oct trash) ---
* "Trash" = contenu non garanti entre frames. SparseProjection les init au
* début de chaque appel donc safe. Accès via `<` = direct mode = 1 cyc
* de moins par instruction vs extended (= ~1100 cyc/frame économisés).
* GOTCHA : dp_extreg est partagé avec moveByScript (glb_d*), scroll-map,
* etc. → ne PAS mettre les Proj_* outputs ici (= lus par LinearInterp et
* DFR plus tard, risque de clobber par sprite routines entre temps).
SP_d0            equ dp_extreg+0     ; delta_curve cumulé (signed 16)
SP_d1            equ dp_extreg+2     ; -delta_pitch cumulé (signed 16)
SP_d2            equ dp_extreg+4     ; sum_of_D0 = horizontal road pos
SP_d3            equ dp_extreg+6     ; sum_of_D1 = vertical road slope
SP_d4            equ dp_extreg+8     ; segment.delta_curve sign-ext
SP_d5            equ dp_extreg+10    ; segment.delta_pitch x 2 sign-ext
SP_min_y         equ dp_extreg+12    ; min Y_screen vu (16-bit ; init = $0060)
SP_seg_save      equ dp_extreg+14    ; X (segment ptr) sauvé pendant mul
SP_d3_save       equ dp_extreg+16    ; D3 sauvé pour passage à Mul9x16
SP_tmp_scale     equ dp_extreg+18    ; scaling sauvé (hi byte:lo byte)
SP_tmp_hi        equ dp_extreg+20    ; term_hi de la décomposition mul
SP_curve_nibble  equ dp_extreg+22    ; sub-position 0..15 dans segment courant
SP_seg_flag      equ dp_extreg+23    ; flag byte cached pour le segment courant
*                              ;   bit 0 = PIT (extrait de curve_raw bit 7)
*                              ;   bit 1 = START (extrait de pitch_raw bit 7)
SP_loop3_count   equ dp_extreg+24    ; (= subseg + 1 - 1 = subseg)
SP_mid_acc       equ dp_extreg+25    ; M16 mid product (u_hi×v_lo) — 2 oct

* -- Variables résidentes en extended (moins critique ou large data) --
SP_last_y        fdb 0          ; Y_screen ayant déclenché l'exit horizon
SP_buffer_start  fdb 0          ; buffer de sortie sauvegardé (epilogue)
SP_loop1_count   fcb 0          ; (= 15 - subseg) - conforme 68k $78af6 SMC
SP_loop2_outer   fcb 0          ; (= 7)
SP_loop2_inner   fcb 0          ; (= 7)

* -- Outputs publiques ------------------------------------------------
Proj_buffer_ptr   fdb 0
Proj_count        fdb 0
Proj_min_y        fcb 0
Proj_first_count  fcb 0          ; = 15 - nibble (former $78af6 SMC value)
Proj_last_count   fcb 0          ; = 1  + nibble (former $78e8c SMC value)

* ----------------------------------------------------------------------
* SparseProjection — point d'entrée
* ----------------------------------------------------------------------
SparseProjection
        * --- Prologue : nibble = high nibble de byte (track_pos+2) ---
        lda   LotusCarState.track_pos+2,u
        lsra
        lsra
        lsra
        lsra                              ; A = nibble (0..15)
        sta   <SP_curve_nibble

        * (15 - nibble) -> blitter first count (SMC pattern pour DrawFrameRoad)
        ldb   #15
        subb  <SP_curve_nibble
        stb   Proj_first_count

        * (1 + nibble) -> blitter last count
        inca
        sta   Proj_last_count

        * --- Sauvegarde du buffer de sortie + init Y = buffer ---
        ldy   Proj_buffer_ptr
        sty   SP_buffer_start

        * --- X = Circuit_base + (segment_idx - 1) x 8 ---
        * (Format compact 8 oct/seg. Le -1 compense le 1er leax 8,x ci-dessous
        *  qui amène X sur le segment courant à idx exact.)
        * segment_idx est cached dans LotusCarState par Lotus_PhysicsTick.
        ldd   LotusCarState.segment_idx,u
        subd  #1                          ; idx - 1 (le leax 8,x suivant compense)
        aslb                              ; x2
        rola
        aslb                              ; x4
        rola
        aslb                              ; x8
        rola                              ; D = (segment_idx - 1) x 8
        addd  Circuit_base
        tfr   d,x

        * --- U = Persp_Horizon[0] (Persp_Scaling[i] sera lu à +256,u) ---
        ldu   #Persp_Horizon

        * --- Reset accumulateurs (D0=D1=D2=D3=0, min_y=$0060) ---
        ldd   #0
        std   <SP_d0
        std   <SP_d1
        std   <SP_d2
        std   <SP_d3
        ldd   #$0060
        std   <SP_min_y

        * --- 1er segment advance + load D4/D5/SP_seg_flag ---
        * SP_load_segment_deltas: leax 8,x -> X = Circuit_base + segment_idx*8
        * (= segment courant). On lit ses deltas pour LOOP 1.
        lbsr  SP_load_segment_deltas

        * --------------------------------------------------------------
        * LOOP 1 : (15 - subseg) substeps dans le segment COURANT
        * CONFORME 68k $78af4-$78b3a :
        *   move.w #(15-subseg), $7c508   ; SMC patché par $78ab2
        *   beq.w  $78b3c                  ; skip si subseg == 15
        *   loop: substep + horizon check, subq $7c508, bne back
        *
        * Mathématique 68k : (15-subseg) substeps "finissent" le segment
        * courant à partir de la position sub-segment actuelle de la caméra.
        * Pour subseg=0 (= cas typique boot) -> 15 substeps dans seg courant.
        * Pour subseg=15 (= camera tout au bord) -> 0 substeps, skip direct.
        * --------------------------------------------------------------
        lda   #15
        suba  <SP_curve_nibble            ; A = 15 - subseg
        beq   SP_skip_loop1               ; subseg = 15 -> 0 iters
        sta   SP_loop1_count
SP_loop1_top
        lbsr  SP_substep                  ; substep normal (= clear bit 1)
        bcs   SP_horizon_exit
        dec   SP_loop1_count
        bne   SP_loop1_top
SP_skip_loop1

        * --------------------------------------------------------------
        * LOOP 2 : 7 itérations x (segment_advance + 8 sub-steps)
        * --------------------------------------------------------------
        lda   #7
        sta   SP_loop2_outer
SP_loop2_outer_lp
        lbsr  SP_load_segment_deltas

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

        * --------------------------------------------------------------
        * 8ème segment : advance + step_first + boucle (subseg+1)
        * --------------------------------------------------------------
        lbsr  SP_load_segment_deltas

        * 1ère sub-step (transition marker)
        lbsr  SP_substep_first
        bcs   SP_horizon_exit

        * Boucle conforme 68k $78e8a-$78f06 :
        *   move.w #(subseg+1), $7c508   ; SMC patché par $78abc
        *   substep + horizon check
        *   subq $7c508, bne loop
        *
        * Mathématique 68k : (subseg+1) substeps "complètent" le 9ème segment
        * jusqu'à la sub-position symétrique de celle de la caméra.
        * Conservation : (15-subseg) + 7x8 + (subseg+1) = 72 substeps = 9x8.
        *
        * Note : sur 68k pure, si horizon-exit ne se déclenche pas dans les
        * (subseg+1) iters, le code continue via dbra qui décrémente le counter
        * jusqu'à overflow naturel -> lecture hors tables Persp_Horizon[N]
        * -> SP_last_y = $0FFF -> horizon exit synthétique.
        * Sur notre 6809, on n'a pas cet overflow naturel "sûr" (= les tables
        * sont en cart bank, lecture hors = poubelle quelconque). On cape donc
        * à (subseg+1) strict. Si pas d'horizon, l'epilogue synthétise SP_last_y
        * depuis le dernier slot.Y écrit (= valeur dernière dans la sparse buffer).
        *
        * Le 1er substep ci-dessus (SP_substep_first) compte pour 1 iter.
        * Il reste (subseg+1 - 1) = subseg iters à faire.
        lda   <SP_curve_nibble
        beq   SP_loop3_done               ; subseg = 0 -> pas d'iter restante
        sta   <SP_loop3_count
SP_loop3
        lbsr  SP_substep
        bcs   SP_horizon_exit
        dec   <SP_loop3_count
        bne   SP_loop3
SP_loop3_done
        * (subseg+1) substeps épuisés sans horizon-exit. Synthèse SP_last_y
        * depuis le dernier slot.Y écrit.
        *
        * BUG FIX (#132) : layout slot = [X(0..1), Y(2..3), Y_min(4..5), D0a(6..7)].
        * Après 4 std ,y++, Y a avancé de 8 oct. Donc :
        *   -2,y = offset 6 = D0a (= cumul curve, peut être négatif !)
        *   -6,y = offset 2 = slot.Y (= ce qu'on veut)
        *
        * Avant fix : lecture de D0a → SP_last_y négatif (e.g. -378 pour
        * 71 substeps de curve=-6) → bmi SP_horizon_underflow → clr Proj_min_y
        * → DFR démarre à Y=0 et lit le dense buffer pollué partout (mur de
        * piste au-dessus de l'horizon, route cassée par blocs).
        ldd   -6,y                       ; D = sparse[N-1].Y (= offset 2 du slot)
        std   SP_last_y
        bra   SP_horizon_exit

* ----------------------------------------------------------------------
* SP_horizon_exit — l'epilogue commun (= LAB_$8b08 dans le 68k)
* ----------------------------------------------------------------------
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
        ldb   <SP_min_y+1
        stb   Proj_min_y
        bra   SP_write_horizon_stamp

SP_horizon_underflow
        * --- Cas underflow (D < 0 signed, mais bhs sur $60 = D bit15 set) ---
        ldd   #0
        std   ,y
        std   -2,y
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

* ----------------------------------------------------------------------
* SP_substep_first — 1ère sub-step d'un segment (preserve bits 0+1 du flag)
* SP_substep       — sub-step normale (clear bit 1 du flag)
* ----------------------------------------------------------------------
SP_substep_first
        lbsr  SP_advance_state
        ldd   <SP_d2
        andb  #$FC                        ; clear bits 0-1 de low byte
        orb   <SP_seg_flag                 ; OR avec flag du segment (PIT+START)
        std   ,y++                        ; write slot.X
        bra   SP_compute_y_screen

SP_substep
        lbsr  SP_advance_state
        ldd   <SP_d2
        andb  #$FC
        orb   <SP_seg_flag                 ; OR avec flag du segment
        andb  #$FD                        ; clear bit 1 (= NOT transition)
        std   ,y++

SP_compute_y_screen
        * Y_screen = (D3 x Persp_Scaling[i]) >> 16 + Persp_Horizon[i]
        ldd   <SP_d3
        std   <SP_d3_save
        stx   <SP_seg_save                 ; preserve segment ptr (X réutilisé)
        ldx   256,u                       ; X = Persp_Scaling[i]
        lbsr  SP_mul_d3_by_scaling        ; D = (D3 x scaling) >> 16
        ldx   <SP_seg_save                 ; restore segment ptr
        addd  ,u++                        ; D += Persp_Horizon[i] ; U += 2
        std   ,y++                        ; write slot.Y (TOUJOURS, même si horizon)

        cmpd  #$0060
        * BGE (signed) au lieu de BHS (unsigned) : conforme 68k FUN_78a98.
        * Pour pitch fort faisant Y_screen négatif (= horizon haut écran), BHS
        * traiterait Y = -100 comme grand unsigned (65436) → exit prématuré.
        * BGE comprend Y signed : -100 < +96 → continue. Conserve l'amplitude
        * pitch jusqu'à clip naturel par horizon table.
        bge   SP_substep_horizon

        * Continue : update min_y, write slot.Ymin + slot.D0a
        cmpd  <SP_min_y
        bge   SP_no_update_min
        std   <SP_min_y
SP_no_update_min
        ldd   <SP_min_y
        std   ,y++                        ; write slot.Ymin
        ldd   <SP_d0
        std   ,y++                        ; write slot.D0a
        andcc #$FE                        ; clear carry = continue
        rts

SP_substep_horizon
        std   SP_last_y                   ; save pour l'epilogue (under/overflow check)
        orcc  #$01                        ; set carry = exit
        rts

* ----------------------------------------------------------------------
* SP_advance_state — applique 1 perspective step :
*   D0 += D4   (delta_curve cumulé)
*   D1 -= D5   (delta_pitch cumulé négatif)
*   D2 += D0   (horizontal road pos)
*   D3 += D1   (vertical road slope)
* ----------------------------------------------------------------------
SP_advance_state
        ldd   <SP_d0
        addd  <SP_d4
        std   <SP_d0
        ldd   <SP_d1
        subd  <SP_d5
        std   <SP_d1
        ldd   <SP_d2
        addd  <SP_d0
        std   <SP_d2
        ldd   <SP_d3
        addd  <SP_d1
        std   <SP_d3
        rts

* ----------------------------------------------------------------------
* SP_mul_d3_by_scaling — (signed_16 x unsigned_12) >> 16 ADAPTATIVE
* ----------------------------------------------------------------------
SP_mul_d3_by_scaling
        stx   <SP_tmp_scale                ; sauvegarde scaling (byte hi:byte lo)

        * --- EARLY-EXIT : D3 == 0 (60.4% des substeps) ---
        ldd   <SP_d3_save                  ; D = D3 (A=hi, B=lo)
        bne   SP_mul_nonzero
        rts                               ; D = 0, return

SP_mul_nonzero
        * --- Test si D3 in signed_8 ([-128, 127]) ---
        tsta
        beq   SP_mul_hi_zero
        cmpa  #$FF
        beq   SP_mul_hi_ff
        bra   SP_mul_full                 ; A != 0 et A != $FF

SP_mul_hi_zero
        * D3 in [1, 255] (zero éliminé). Need D3_lo < $80 pour signed_8.
        tstb
        bmi   SP_mul_full                 ; B[7]=1 -> D3 >= 128 -> fallback

        * --- FAST PATH POSITIF : D3 in [1, 127] ---
        lda   <SP_tmp_scale                ; A = sHi (0..15)
        mul                               ; D = D3 x sHi (max 127x15 = 1905)
        tfr   a,b                         ; B = high byte (= result >> 8)
        clra                              ; D = 0:result (positive 16-bit)
        rts

SP_mul_hi_ff
        * D3 in [-256, -1]. Need D3_lo >= $80 pour signed_8 négatif.
        tstb
        bpl   SP_mul_full                 ; B[7]=0 -> D3 < -128 -> fallback

        * --- FAST PATH NÉGATIF : D3 in [-128, -1] ---
        negb                              ; B = -D3_lo (= |D3| en 1..128)
        lda   <SP_tmp_scale                ; A = sHi
        mul                               ; D = |D3| x sHi
        tfr   a,b                         ; B = result byte
        clra                              ; D = 0:result (positive)
        comb                              ; négate 16-bit (2's complement)
        coma
        addd  #1                          ; D = -(|D3| x sHi >> 8) signed 16
        rts

SP_mul_full
        * --- KNUTH ALGORITHM M tronquée + sign correction (= identique à
        * DFR Mul16x16HiSigned, dupliqué inline pour éviter conflit DP).
        *
        * Reproduit la routine DFR (DrawFrameRoad.asm Mul16x16HiSigned) mais
        * avec slots DP propres : SP utilise dp_extreg+0..+20 simultanément
        * pendant la mul (SP_d3_save, SP_tmp_scale, etc.), tandis que DFR
        * M16_u_signed/hi_acc/mid_acc partagent les mêmes offsets → conflit
        * si appel direct. Solution : code inline avec SP_tmp_hi (=+20) et
        * SP_mid_acc (=+25), libres pendant la mul.
        *
        * Formule : (u_signed × v_unsigned) >> 16 = t1 + (mid >> 8) - v×sign(u)
        *   t1   = u_hi × v_hi
        *   mid  = u_hi × v_lo + u_lo × v_hi
        *   u_lo × v_lo dropped (max contribution = 1, négligeable au px près)
        *
        * GAIN PRÉCISION vs ancien 2× Mul9x16 : le `tfr a,b; sex` de l'ancien
        * tronquait le low byte du lo_contrib, perdant ~1 LSB par scaling
        * step → plateaux Y dans SP output (5 substeps à Y=27 au lieu de 1)
        * → LinearInterp générait widths non-smooth (+28/+33). Knuth M16
        * tronque moins → Y trajectory mieux étalée → widths smooth.
        *
        * Inputs DP :
        *   SP_d3_save   = u (signed 16-bit, D3 cumulé)
        *   SP_tmp_scale = v (unsigned 16-bit, scaling[i] toujours positif)
        * Output : D = (u × v) >> 16 signed
        * Clobbers : A, B, X, SP_tmp_hi, SP_mid_acc

        * --- t1 = u_hi × v_hi ---
        lda   <SP_d3_save                  ; A = u_hi
        ldb   <SP_tmp_scale                ; B = v_hi
        mul                               ; D = t1
        std   <SP_tmp_hi

        * --- mid_a = u_hi × v_lo ---
        lda   <SP_d3_save
        ldb   <SP_tmp_scale+1
        mul                               ; D = mid_a
        std   <SP_mid_acc

        * --- mid_b = u_lo × v_hi, somme avec mid_a dans D (C = carry) ---
        lda   <SP_d3_save+1
        ldb   <SP_tmp_scale
        mul                               ; D = mid_b
        addd  <SP_mid_acc                  ; D = mid_a + mid_b (16-bit), C=carry

        * --- mid_sum >> 8 avec carry préservé (= 17-bit shift right 8) ---
        * sum_17bit = (C << 16) | D. >> 8 = (C << 8) | (D high byte).
        tfr   a,b                         ; B = A (= high byte of sum)
        bcc   SP_M16_no_mid_carry
        lda   #1
        bra   SP_M16_mid_shifted
SP_M16_no_mid_carry
        clra
SP_M16_mid_shifted
        * D = mid_sum >> 8 (= 9-bit max)

        * --- hi_unsigned = t1 + mid_sum_shifted ---
        addd  <SP_tmp_hi                   ; D = hi_unsigned

        * --- Sign correction : si u < 0, subtract v ---
        * ldx ,DP set flags N/Z selon valeur chargée → bpl sur u signed.
        ldx   <SP_d3_save
        bpl   SP_M16_done                 ; u ≥ 0 → pas de correction
        subd  <SP_tmp_scale                ; hi_signed = hi_unsigned - v
SP_M16_done
        rts

* ----------------------------------------------------------------------
* SP_load_segment_deltas — décode le segment courant (format compact 8 oct)
*
* Format segment compact :
*   ,x    = curve_raw  : bit 7 = PIT, bits 0-6 = delta_curve 7-bit signed
*   1,x   = pitch_raw  : bit 7 = START, bits 0-6 = delta_pitch 7-bit signed
*   2,x..7,x = sprite indices + lat positions (= utilisé par task #B sprites)
* ----------------------------------------------------------------------
SP_load_segment_deltas
        leax  8,x                         ; avance au segment suivant (8 oct/seg)
        clr   <SP_seg_flag                 ; reset flag accumulator

        * --- Decode curve_raw : bit 7 = PIT, bits 0-6 = curve 7-bit signed ---
        ldb   ,x                          ; B = curve_raw
        bpl   SP_no_pit                   ; bit 7 clear -> no PIT
        inc   <SP_seg_flag                 ; flag bit 0 = PIT
SP_no_pit
        andb  #$7F                        ; mask out PIT bit
        bitb  #$40                        ; 7-bit sign (bit 6) set ?
        beq   SP_curve_pos
        orb   #$80                        ; sign-extend bit 6 -> bit 7
SP_curve_pos
        sex                               ; D = signed 16 curve
        std   <SP_d4

        * --- Decode pitch_raw : bit 7 = START, bits 0-6 = pitch 7-bit signed ---
        ldb   1,x                         ; B = pitch_raw
        bpl   SP_no_start
        lda   <SP_seg_flag
        ora   #$02                        ; flag bit 1 = START
        sta   <SP_seg_flag
SP_no_start
        andb  #$7F                        ; mask out START bit
        bitb  #$40
        beq   SP_pitch_pos
        orb   #$80
SP_pitch_pos
        sex                               ; D = signed 16 pitch
        aslb                              ; x2 (D5 = 2 x pitch)
        rola
        std   <SP_d5
        rts

 endc                                     ; SparseProjection_included
