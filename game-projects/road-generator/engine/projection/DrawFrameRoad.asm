        opt   c
 ifndef DrawFrameRoad_included
DrawFrameRoad_included equ 1

* ======================================================================
* DrawFrameRoad.asm — V4 : dispatch complet K' / J' / F
*
* Pour chaque scanline (96 lignes du bas viewport vers l'horizon) et
* chaque banque (RAMB puis RAMA) :
*   1. Lit width depuis Dense_Buffer[i_road × 6 + 2]
*   2. Dispatche line_idx = width via Road_lines[width × 8 + variant × 2]
*      → ptr buffer Line_NNNN dans la cart zone road_buffers
*   3. Lit K, M, J du buffer (header 3 oct)
*   4. Calcule K' = min(10, K), J' = max(0, 10-K-M) clampé à 6
*      (= simplification entry_idx = 0, pas de sub-pixel scroll horizontal)
*   5. Pose Y sur le cœur (= buffer + 3)
*   6. jsr Road_draw_K{K'}_J{J'} via dispatch table
*      → écrit préambule K' herbe + cœur F road + postlude J' herbe = ligne
*      complète 40 octets
*
* === VIEWPORT 1-PLAYER : lignes écran 0..95 (HAUT écran) ===
*   Position U = $A000 + B × 40  (B=96 → $AF00 = fin ligne 95)
*               $C000 + B × 40 pour RAMA
*
* === SIMPLIFICATIONS V4 (TODO pour byte-perfect 68k) ===
*   - entry_idx = 0 (= pas de sub-pixel shift latéral pour l'instant)
*   - variant = s0 (= pas de sub-pixel positioning vertical)
*   - flags ignorés (= pas de centre dynamique depuis Dense_Buffer)
*
* === FIDÉLITÉ 68k FUN_765fe (= À IMPLEMENTER quand le rendu de base marche) ===
*
* Le 68k calcule par scanline :
*   1. centerX (= position horizontale road) :
*      $7665a: D7w = D1w (= horizon_y backup)
*      $7665c-$76668: A4 = Dense + Y*6, A1 = VRAM + Y*80
*      $7666a-$7666c: D4 << 3 → SMC patch à $76688 (= lateral sub-pixel)
*      $76682-$76690: D1 = (width × D3_patched) high word, négativé puis +$90
*                  → centerX = $90 - ((width × patched_D3) >> 16)
*      $7669e-$766a0: leftEdge = centerX - width/16, rightEdge = centerX + width/16
*   2. entry_idx (= sub-pixel horizontal scroll) :
*      $7664e-$76654: D5 ror 4 & $7FF → SMC patch à $7667c
*                  = (track_pos_lower rotated) & $7FF
*   3. variant (= sub-pixel vertical positioning) :
*      Sélectionne 1 des 4 variants (s0..s3) dans Road_lines table
*      basé sur le sub-segment parity de track_pos
*   4. Flag bits PIT/START (= bit 0/1 de slot.X depuis SparseProjection) :
*      $766a2: btst #0,D6 → PIT path (pit lane sprite)
*      $766ca: btst #1,D6 → START path (transition marker)
*
* Notre port 6809 hardcode :
*   - centerX = position centrée (pas de scaling perspective horizontal)
*   - leftEdge/rightEdge = symétrique autour centerX
*   - variant = s0 partout (= pas d'alternance sub-pixel vertical)
*   - flags = bypass (= toutes lignes traitées comme régulier road)
*
* === CONVENTION D'APPEL ===
*   Pré-condition : back-buffer mounté à $A000-$DFFF (= _gfxlock.on fait)
*                   road_buffers mounté en cart zone $0000-$3FFF
*                   pattern bank dark/light à $4000 (= Copy fait au boot)
*   trashes : A, B, X, Y, U, condition codes
* ======================================================================

NB_ROAD_LINES        equ   96             ; lignes écran 0..95 (= viewport haut)
ROAD_LINES_MAX_IDX   equ   254            ; idx max dans Road_lines

* ── Variables centerX (calculées par ligne avant dispatch) ──
* Port 68k FUN_765fe $76682-$76694 : compute centerX puis biaise K'/J'.
* Sans la SMC sub-pixel du 68k ($76654/$76686), on simplifie à :
*   centerX_pixel_offset = -((flags_signed × width × 2) >> 16)
*   byte_offset = centerX_pixel_offset / 8 (signed)
*   K' = clamp(0, K_header + byte_offset, 10)
*   J' = clamp(0, 10 - K_header - M_header - byte_offset, 6)
DFR_flags          fdb   0                ; triplet.flags signed 16 (= D2 cumulé)
DFR_width_x2       fdb   0                ; width × 2 (= 68k D1 input to mul)
DFR_mul_partial    fdb   0                ; mul accumulator
DFR_mul_sign       fcb   0                ; sign of result (0=pos, !=0=neg)
DFR_centerX_off    fcb   0                ; computed byte offset signed (-128..+127)
* NB: K et J du header sont déjà CENTRÉS au build (= baked) par
* compile_road_sprites_ram.py qui crop le contenu PNG à WINDOW_PX
* avant mesure_grass. Pas de DFR_crop runtime.

DrawFrameRoad
        * --- Mount road_buffers en cart zone $0000-$3FFF ---
        ldx   #Obj_Index_Page
        lda   ObjID_RoadBuffers,x
        _SetCartPageA

        * ====================================================
        * Banque RAMB : variant 2 = offset 4 dans Road_lines entry
        * ====================================================
        ldb   #NB_ROAD_LINES             ; compteur 96 → 1
DFR_loop_b
        pshs  b                          ; save compteur ligne [B_ligne]

        * Calcul U = $A000 + B × 40 (= fin de ligne_ecran (B-1))
        lda   #40
        mul                              ; D = B × 40
        addd  #$A000
        tfr   d,u                        ; U = fin ligne courante RAMB

        * Calcul X = Dense_Buffer + (Proj_min_y + B - 1) × 6
        * Convention 68k : pVar9 = $2b400 + ($7c5a0) × 6 où $7c5a0 = HAUTEUR
        * D'HORIZON dynamique calculée par la projection (= Proj_min_y chez nous).
        *   B=1 → Y_screen = Proj_min_y (1ère ligne dessinée)
        *   B=96 → Y_screen = Proj_min_y + 95 (= dernière ligne)
        ldb   ,s
        decb
        addb  Proj_min_y                 ; B = Proj_min_y + (B-1)
        lda   #6
        mul
        addd  #Dense_Buffer
        tfr   d,x

        * --- Test triplet vide (= LinearInterp n'a pas écrit cette ligne) ---
        * Si flags=0 ET width=0 ET extra=0 → scanline non projetée, skip
        ldd   ,x                         ; D = flags
        bne   DFR_have_data_b
        ldd   2,x                        ; D = width
        bne   DFR_have_data_b
        ldd   4,x                        ; D = extra
        beq   DFR_empty_b                ; tout à 0 → skip
DFR_have_data_b

        * --- Save flags + width×2 pour centerX (avant overwrite de X/D) ---
        ldd   ,x                         ; D = triplet.flags
        std   DFR_flags
        ldd   2,x                        ; D = triplet.width
        aslb                              ; ×2
        rola
        std   DFR_width_x2

        * --- Compute centerX byte offset for K'/J' bias ---
        lbsr  DFR_compute_centerX

        * Lit width et clip à 254
        ldd   2,x
        cmpd  #ROAD_LINES_MAX_IDX
        blo   DFR_idx_ok_b
        ldd   #ROAD_LINES_MAX_IDX
DFR_idx_ok_b

        * Calcul Road_lines + width × 8 + 4 (= RAMB_s0)
        aslb
        rola
        aslb
        rola
        aslb
        rola
        addd  #Road_lines+4
        tfr   d,x

        * Lit ptr Line_NNNN (= début buffer dans road_buffers)
        ldy   ,x                         ; Y = ptr Line_NNNN

        * Calcul K' et J' avec centerX bias, dispatch Road_draw, exec
        lbsr  DFR_dispatch_and_draw

DFR_empty_b
        puls  b
        decb
        bne   DFR_loop_b

        * ====================================================
        * Banque RAMA : variant 0 = offset 0 dans Road_lines entry
        * ====================================================
        ldb   #NB_ROAD_LINES
DFR_loop_a
        pshs  b

        lda   #40
        mul
        addd  #$C000
        tfr   d,u

        * X = Dense_Buffer + (Proj_min_y + B - 1) × 6 (= idem RAMB)
        ldb   ,s
        decb
        addb  Proj_min_y
        lda   #6
        mul
        addd  #Dense_Buffer
        tfr   d,x

        * --- Test triplet vide (= LinearInterp n'a pas écrit cette ligne) ---
        ldd   ,x
        bne   DFR_have_data_a
        ldd   2,x
        bne   DFR_have_data_a
        ldd   4,x
        beq   DFR_empty_a
DFR_have_data_a

        * --- Save flags + width×2 pour centerX (avant overwrite de X/D) ---
        ldd   ,x
        std   DFR_flags
        ldd   2,x
        aslb
        rola
        std   DFR_width_x2

        * --- Compute centerX byte offset for K'/J' bias ---
        lbsr  DFR_compute_centerX

        ldd   2,x
        cmpd  #ROAD_LINES_MAX_IDX
        blo   DFR_idx_ok_a
        ldd   #ROAD_LINES_MAX_IDX
DFR_idx_ok_a

        aslb
        rola
        aslb
        rola
        aslb
        rola
        addd  #Road_lines                ; +0 = RAMA_s0
        tfr   d,x

        ldy   ,x

        lbsr  DFR_dispatch_and_draw

DFR_empty_a
        puls  b
        decb
        bne   DFR_loop_a

        rts

* ======================================================================
* DFR_dispatch_and_draw — calcule K'/J' depuis le header du buffer Line_NNNN
* puis jsr la routine Road_draw_K{K'}_J{J'} appropriée.
*
* @input  : Y = ptr buffer Line_NNNN (= début header K,M,J)
*           U = position VRAM (= fin de la ligne courante dans la banque)
* @output : ligne complète 40 oct écrite à U-40..U-1
* @trashes: A, B, X, Y (Y avance dans le cœur ; U descend de 40 oct)
*
* Stack à l'entrée : [..., B_ligne] (= la routine caller pushé B_ligne).
* Stack à la sortie : idem [..., B_ligne].
* ======================================================================
DFR_dispatch_and_draw
        * K et J du header sont déjà CENTRÉS au build (= crop symétrique fait par
        * compile_road_sprites_ram.py). Au runtime, on applique uniquement le
        * centerX_off pour le bias dynamique courbures.

        * --- K' = clamp(0, K + centerX_off, 10) ---
        lda   ,y                         ; A = K (header, déjà centré)
        adda  DFR_centerX_off            ; A += byte_offset (signed, courbures)
        bmi   DFR_kclamp_neg             ; A < 0 → K' = 0
        cmpa  #10
        bls   DFR_kclamp_ok
        lda   #10                         ; A > 10 → K' = 10
        bra   DFR_kclamp_ok
DFR_kclamp_neg
        clra
DFR_kclamp_ok
        pshs  a                          ; stack: [B_ligne, K']

        * --- J' = clamp(0, J - centerX_off, 6) ---
        lda   2,y                        ; A = J (header, déjà centré)
        suba  DFR_centerX_off            ; A -= byte_offset (= bias inverse de K')
        bmi   DFR_jclamp_neg
        cmpa  #6
        bls   DFR_jmax_ok
        lda   #6                          ; clamp à 6 (J max table)
        bra   DFR_jmax_ok
DFR_jclamp_neg
        clra
DFR_jmax_ok
        pshs  a                          ; stack: [B_ligne, K', J']

        * --- Index dispatch = (K' × 7 + J') × 2 ---
        ldb   1,s                        ; B = K' (offset +1 dans stack)
        lda   #7
        mul                              ; D = K' × 7
        addb  ,s                         ; B += J'
        adca  #0
        aslb                              ; D ×= 2 (offset oct)
        rola
        addd  #Road_draw_dispatch
        tfr   d,x
        ldx   ,x                         ; X = ptr Road_draw_K{K'}_J{J'}

        * --- Cleanup stack (pop K' et J') ---
        leas  2,s                        ; stack: [B_ligne]

        * --- Si X = 0 → combinaison non implémentée, skip silencieusement ---
        cmpx  #0
        beq   DFR_dispatch_skip

        * --- Pose Y sur le cœur (= buffer + 3, entry_idx = 0) ---
        leay  3,y                        ; Y → début cœur (fdb ptrs Road_R*)

        * --- jsr vers la routine déroulée ---
        jsr   ,x                         ; → écrit ligne complète, ret après rts

DFR_dispatch_skip
        rts

* ======================================================================
* DFR_compute_centerX — calcule byte_offset pour bias K'/J'
*
* Port partiel 68k FUN_765fe $76682-$76694 (sans la SMC sub-pixel patches
* à $76654 et $7666c qui ajoutent les fractions track_pos / lateral_pos).
*
* 68k :
*   D1 = (width × 2) muls.w (flags + sub_pixel_patched)
*   D1 = swap → high 16 of 32-bit product
*   D1 = -D1
*   centerX = $90 + D1 = $90 - high16
*
* Notre version simplifiée :
*   high16 = ((flags signed) × (width × 2)) >> 16
*   centerX_pixel_offset = -high16
*   byte_offset = centerX_pixel_offset / 8 signed (= shift right 3 with sign preserved)
*
* @input  : DFR_flags = signed 16
*           DFR_width_x2 = unsigned 16 (= width × 2)
* @output : DFR_centerX_off = signed byte (-128..+127)
* @trashes: A, B, DFR_flags (= mutated to |flags|), DFR_mul_partial, DFR_mul_sign
* ======================================================================
DFR_compute_centerX
        * --- Prends |flags|, garde sign séparément ---
        ldd   DFR_flags
        bpl   DFR_cx_flags_pos
        coma                              ; négate D
        comb
        addd  #1
        std   DFR_flags                   ; |flags|
        lda   #1
        sta   DFR_mul_sign
        bra   DFR_cx_do_mul
DFR_cx_flags_pos
        clr   DFR_mul_sign
DFR_cx_do_mul
        * --- Unsigned 16x16 → high16 ---
        * partial = a_hi × b_hi + (a_hi × b_lo) >> 8 + (a_lo × b_hi) >> 8
        * (= ignore carry de low16 vers high16, erreur ±1 acceptable)
        lda   DFR_flags                   ; a_hi
        ldb   DFR_width_x2                ; b_hi
        mul                               ; D = a_hi × b_hi (= high16 contribution)
        std   DFR_mul_partial

        lda   DFR_flags                   ; a_hi
        ldb   DFR_width_x2+1              ; b_lo
        mul                               ; D = a_hi × b_lo
        clrb                              ; want high byte of D shifted right 8 = A in low byte
                                          ; → D = 0:A is wrong, want A:0 → no, we want high8 added to low8 of partial
        ; Correction : on veut (a_hi × b_lo) >> 8 ajouté à partial.
        ; D après mul = (a_hi × b_lo) sur 16 bits = A:B = high:low de produit 8x8 (max 255×255=65025=$FE01)
        ; (a_hi × b_lo) >> 8 = A (= high byte du produit).
        ; Ajouter A comme low byte de partial : on shift D droite 8 :
        ; D >> 8 : la routine `clrb` ci-dessus a CLR B → D = A:0 (= A décalé à gauche par 8 !).
        ; CORRECTION : on doit faire `tfr a,b` puis `clra` → D = 0:A
        tfr   a,b
        clra
        addd  DFR_mul_partial
        std   DFR_mul_partial

        lda   DFR_flags+1                 ; a_lo
        ldb   DFR_width_x2                ; b_hi
        mul                               ; D = a_lo × b_hi
        tfr   a,b
        clra                              ; D = 0:A = (a_lo × b_hi) >> 8
        addd  DFR_mul_partial
        * D = unsigned high16 of (|flags| × width × 2)

        * --- Apply sign ---
        tst   DFR_mul_sign
        beq   DFR_cx_no_neg
        coma
        comb
        addd  #1
DFR_cx_no_neg
        * D = signed high16 = ((flags) × width × 2) >> 16

        * --- centerX_pixel_offset = -D (= 68k $7668e) ---
        coma
        comb
        addd  #1

        * --- byte_offset = D / 8 signed (= ASR + ROR × 3) ---
        asra
        rorb
        asra
        rorb
        asra
        rorb
        * B = signed byte offset (low byte = result, A = sign extension)
        stb   DFR_centerX_off
        rts

 endc
