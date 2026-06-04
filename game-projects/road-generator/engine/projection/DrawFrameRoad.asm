        opt   c
 ifndef DrawFrameRoad_included
DrawFrameRoad_included equ 1

* ======================================================================
* DrawFrameRoad.asm — V5 : horizon→bas, 2 passes interleavées, PRC per-scanline
*
* Boucle UNIQUE horizon → bas (= Y croissant depuis Proj_min_y, jusqu'à
* Proj_min_y + 96). Pour chaque scanline :
*   1. Lit triplet (flags, width, extra) depuis Dense_Buffer[Y × 6]
*   2. Skip si triplet null (= scanline non projetée)
*   3. Set PRC selon bit 10 de extra (= LI_d7 dithering perspective-cohérent)
*   4. Lookup Line_NNNN depuis Road_lines[width × 8 + variant × 2]
*   5. Pass RAMB : jsr Road_draw_KX_JY avec U=U_RAMB + buffer RAMB
*   6. Pass RAMA : jsr Road_draw_KX_JY avec U=U_RAMA + buffer RAMA (= MÊME PRC
*      donc data consistent dark ou light sur les 2 banques de la scanline)
*   7. Advance cursors (U_RAMB += 40, U_RAMA += 40, dense += 6)
*
* === VIEWPORT 1-PLAYER : lignes écran 0..95 (HAUT écran) ===
*   Y_curr ∈ [Proj_min_y, Proj_min_y + 95]
*   U_RAMB = $A000 + (Y+1) × 40 + byte_offset
*   U_RAMA = U_RAMB + $2000 + rama_bank_off (= $C000 base + shift)
*
* === DARK/LIGHT DITHERING ===
*   bit 10 de LI_d7 (= dense field 2 / extra) varie selon perspective rate :
*     - close-up scanlines : A4 large → bit 10 alterne souvent
*     - distant scanlines  : A4 petit → bit 10 alterne lentement
*   → effet dithering qui s'adapte naturellement à la distance, comme Lotus 68k
*   PRC=0 → demi-page RAMA visible à $4000 = patterns dark
*   PRC=1 → demi-page RAMB visible à $4000 = patterns light
*
* === V6 = LATERAL ANIMATION via entry_idx ===
*   - K'/J' dynamiques per scanline : K' = base - shift, J' = base + shift
*   - base = (10-M)/2 (= grass chunks chaque côté pour centrage)
*   - shift = DFR_lateral_chunks_shift signed (= clamped à ±base)
*   - F = M toujours (= toute la road visible quand shift dans range)
*   - sub_pix 0..15 px en plus pour granularité fine (= mécanique 4 variants existante)
*
* === SIMPLIFICATIONS V6 (= TODO V7 byte-perfect 68k) ===
*   - lateral_shift NON modulée par perspective (= constant pour toutes scanlines)
*     → road bouge "à plat" sans rétrécissement à l'horizon
*     → 68k fait mul lateral × width / 65536 par scanline (= TODO si visuel insuffisant)
*   - flags PIT/START ignorés (= toutes lignes traitées comme régulier road)
*   - Pas de Y skip dans buffer (= si shift > base, clamping silencieux)
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

* ── Variables sub_pix 0..15 ──
* Mécanique 4 variants × byte_offset (cf. skill thomson-to8-engine-bm16-pixel-blit) :
*   sub_pix = 0..15 (= offset pixel horizontal road dans le chunk de 16 px)
*   intra   = sub_pix & 3 : sélection variant 0..3 (= 0..3 px par RAMA/RAMB-first + s0/s1)
*   byte_offset = sub_pix >> 2 : décale U cursor de 4 px (= 1 byte) à chaque pas
*
* Optim levier 2 : variant_tbl à 2 oct/entry + rama_shift calculé depuis intra&2 :
*   - Indexation par asla puis ldd a,x (= 1 instruction de lookup au lieu de mul + 2 lda)
*   - rama_shift dérivable car bit 1 de intra = 1 ssi RAMB-first (= intra >= 2)
* -- INPUTS (= set par PlayerOne avant DFR, dp_extreg clobbé entre temps) --
DFR_sub_pix        fcb   0                ; SYMBOLE EXPORTÉ : sub_pix 0..15 (= shift fin 1 px)

* -- Vars HOT scratch en DP (= dp_extreg trash, init par DFR à chaque appel) --
* "Trash" : init/écrit avant lecture à chaque appel de DrawFrameRoad.
* Layout (28 oct dispo) :
DFR_byte_offset    equ dp_extreg+0   ; = sub_pix >> 2 (0..3), recalc per scanline
DFR_rama_bank_off  equ dp_extreg+1   ; +1 byte shift RAMA cursor si RAMB-first
DFR_rama_variant_b equ dp_extreg+2   ; offset Road_lines pour RAMA pass (0,2,4,6)
DFR_ramb_variant_b equ dp_extreg+3   ; offset Road_lines pour RAMB pass

* ── Lateral animation : chunks shift (= shift coarse de 16 px chacun) ──
* Combiné avec DFR_sub_pix (= 0..15 px fin), donne lateral_total_px = chunks*16 + sub_pix.
* Signed 8-bit : positif = road shift vers la GAUCHE sur écran (= window glisse vers DROITE
* dans le buffer), négatif = road shift vers la DROITE.
* Clampé per-line à |shift| <= base = (10-M)/2 dans dispatch_and_draw.
DFR_lateral_chunks_shift fcb 0            ; SYMBOLE EXPORTÉ : signed chunks shift (-N..+N)

* ── DEBUG : pilotage de DrawFrameRoad_Debug (set par le game-mode debug) ──
* offset global leftEdge px (LEFT/RIGHT) ; prc (FIRE) = thème couleur dark/light ;
* line_base (UP/DOWN) = 1er line_idx affiché (fenêtre de 200 lignes, 0..55 pour
* rester dans 0..254).
DFR_dbg_offset     fdb 0                  ; SYMBOLE EXPORTÉ : leftEdge px global
DFR_dbg_prc        fcb 0                  ; SYMBOLE EXPORTÉ : 0=dark 1=light (bit 0 PRC)
DFR_dbg_line_base  fcb 0                  ; SYMBOLE EXPORTÉ : line_idx de la 1re ligne (0..55)

* ── Scratch dispatch_and_draw (calcul K'/J' par scanline) — DP ──
DFR_tmp_base       equ dp_extreg+4   ; right=leftEdge_chunks+M sauvé pour K'/coreOff
DFR_prc_base       equ dp_extreg+5   ; ($E7C3 & $FE) hoisté/frame (Lead-6 : bits 1-7 PRC)
*                                      (DEBUG : base 80-offset stockée dans DFR_width_x2, slot+8)

* ── Centre route = 88 (= centre écran 80 + 8 px, compense le rendu U=-2) ──
* VALIDÉ en mode debug (trace) : avec U=-2 (à cheval) + fix parité (M&~1),
* CENTER=88 pose la route centrée à l'écran (px 80). L'ancien 72 (= 68k $90/2,
* sans tenir compte du décalage -2) la décalait et n'avait jamais été validé sur
* le mode normal. Ancrage par le CENTRE : leftEdge = (88 + neg_product) - (M&~1)*8.
* NB : 88 → centre géométrique 80 ; pour le léger décentrage 68k, ajuster ici.
DFR_SCREEN_CENTER  equ 88

* ── Lateral_scaled = lateral_pos × 8 (signed 16-bit, CONSTANT par frame) ──
* Hoisté hors de la boucle scanline (avant : recomputé 96× par frame depuis
* DFR_lateral_chunks_shift + DFR_sub_pix). Économie ~2400 cyc/frame.
DFR_lateral_scaled fdb 0           ; ext (constant frame, accédé 96× = ok extended)

* ── Lead A : résultat dispatch hoisté 1×/scanline (partagé RAMB+RAMA) ──
* Depuis fix #5 (variants à M cohérent), M est identique sur les buffers RAMB et
* RAMA → K'/J'/index/ptr/coreOff sont identiques sur les 2 passes. On les calcule
* UNE fois par scanline (DFR_dispatch_compute) et on partage le résultat aux 2
* passes (DFR_dispatch_draw). En mémoire étendue (DP plein) : +1 cyc/accès, négligeable.
DFR_route_ptr      fdb 0           ; ext : ptr routine Road_draw_K'_J' (0 = non implémentée)
DFR_core_off       fcb 0           ; ext : 3 + max(0,right-10)*2 (offset header+cœur)

* ── Track phase per-frame pour animation bandes dark/light ──
* 68k FUN_765fe $7664E-$76654 : D5 = track_pos.lower ror 4 & $7FF, patché SMC dans
* l'addi.w #imm,D2w au $7667A. D2 = EXTRA (= LI_d7 du triplet) → bit 10 testé pour
* dithering. La modulation phase->extra fait shifter les bandes per-frame même sur
* ligne droite plate. Sans cette modulation, bit 10 dépend seulement de l'init de
* LI_d7 (= constant car Proj_count toujours = 72) → bandes statiques.
DFR_track_phase    equ dp_extreg+6   ; (track_pos.lower >> 4) & $7FF, recalc/frame

* ── Curve modulation per-scanline (= centerX shift depuis slot.X) ──
* 68k FUN_765fe $76682..$76690 : centerX = $90 - (slot.X × width × 2) >> 16
* En 6809 on calcule (slot.X × width × 2) >> 16 = pixel offset signed via
* Mul16x16HiSigned, puis on convertit en chunk shift (= /16) pour ajuster
* l'entry_idx de DFR_dispatch_compute.
*
* Variables réutilisées per scanline.
DFR_width_x2          equ dp_extreg+8   ; width × 2 (= input v pour Mul16x16HiSigned)
DFR_curve_chunk_shift equ dp_extreg+10  ; signed chunk shift (= pixel_offset / 16)
DFR_curve_sub_pix     equ dp_extreg+11  ; pixel_offset mod 16 (= 0..15, sub-chunk px)

* ── Sky erase per-buffer : mémoire de l'horizon n-2 ──
* Avec double buffering, le buffer courant a été rendu il y a 2 frames.
* Si l'horizon courant est PLUS BAS (= Y plus grand) que celui d'il y a 2
* frames, les lignes [prev_horizon, curr_horizon - 1] avaient été tracées
* en route à l'époque et doivent être restaurées en ciel maintenant.
* Init = 95 (= bas écran) pour qu'au boot rien ne soit effacé.
DFR_prev_horizon      fcb 95,95   ; [buffer 0, buffer 1]
DFR_erase_limit       fcb 0       ; scratch : curr_horizon save pour la loop d'erase
DFR_BM_count          fdb 0       ; count border mask (= 96 - Proj_min_y, 16-bit pour ldy)
DFR_SKY_COLOR         equ $8888   ; pattern grey/sky 4-px ($8888 BM16)

* ── Mul16x16HiSigned scratch (= DP, init par routine à chaque call) ──
M16_u_signed          equ dp_extreg+12  ; saved input u (signed)
M16_hi_acc            equ dp_extreg+14  ; u_hi × v_hi partial product
M16_mid_acc           equ dp_extreg+16  ; u_hi × v_lo partial product

* ── Cursors per-scanline (= DP, init au prologue de DFR) ──
DFR_U_RAMB         equ dp_extreg+18  ; U cursor pour passe RAMB (RAMA dérivé = +$2000, Lead-E)
DFR_U_RAMA         equ dp_extreg+20  ; U cursor passe RAMA — utilisé SEULEMENT par le mode debug
DFR_dense_ptr      equ dp_extreg+22  ; ptr vers triplet courant dans Dense_Buffer
DFR_lines_base     equ dp_extreg+24  ; Road_lines + width*8 (cached pour les 2 passes)
DFR_y_curr         equ dp_extreg+26  ; debug : Y up-counter / mode normal : down-counter scanlines (Lead-G)
DFR_y_limit        equ dp_extreg+27  ; (mode normal : plus utilisé depuis Lead-G ; libre)

* ── Table placement sub_pix → décodage complet (4 oct/entry, index = sub_pix×4) ──
* Fusionne en 1 lookup les 3 dérivations historiques :
*   byte_offset   = sub_pix >> 2        (0..3 ; décale U de 4 px/pas)
*   rama_bank_off = (sub_pix & 2) >> 1  (0..1 ; +1 byte RAMA si RAMB-first)
*   rama_var/ramb_var = variant s0/s1 × plane-first (offsets Road_lines 0/2/4/6)
* Entry = [byte_offset, rama_bank_off, rama_var, ramb_var].
DFR_subpix_tbl
        fcb   0,0,0,4                      ; sub_pix 0
        fcb   0,0,2,6                      ; 1
        fcb   0,1,4,0                      ; 2
        fcb   0,1,6,2                      ; 3
        fcb   1,0,0,4                      ; 4
        fcb   1,0,2,6                      ; 5
        fcb   1,1,4,0                      ; 6
        fcb   1,1,6,2                      ; 7
        fcb   2,0,0,4                      ; 8
        fcb   2,0,2,6                      ; 9
        fcb   2,1,4,0                      ; 10
        fcb   2,1,6,2                      ; 11
        fcb   3,0,0,4                      ; 12
        fcb   3,0,2,6                      ; 13
        fcb   3,1,4,0                      ; 14
        fcb   3,1,6,2                      ; 15

DrawFrameRoad
        * --- Mount road_buffers en cart zone $0000-$3FFF ---
        ldx   #Obj_Index_Page
        lda   ObjID_RoadBuffers,x
        _SetCartPageA

        * --- Track phase per-frame (= modulation extra pour bands shift) ---
        * 68k équivalent à $7660A-$76654 :
        *   D5 = track_pos longword
        *   ror.w #4, D5w  → andi #$7FF → SMC patch addi sur D2 (= extra)
        * 6809 : on calcule (track_pos.lower >> 4) & $7FF dans DFR_track_phase,
        * ajouté à extra dans la boucle scanline avant le test bit 10.
        ldu   #PlayerOne_State
        ldd   LotusCarState.track_pos+2,u  ; D = track_pos low word
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb                               ; D = (low_word >> 4)
        anda  #$07                         ; D &= $07FF (= keep bits 0..10)
        std   DFR_smc_phase+1              ; C1 : patch l'immédiat `addd #phase` de la boucle

        * --- Pre-compute lateral_scaled = lateral_pos × 8 (CONSTANT par frame) ──
        * lateral_pos_px = chunks × 16 + sub_pix (signed ±192). × 8 = unités slot.X.
        * Identité : chunks × 128 + sub × 8 = (chunks × 16 + sub) × 8 = lateral_pos × 8.
        * Hoist hors boucle scanline → économie ~2400 cyc/frame (vs 96× recompute).
        ldb   DFR_lateral_chunks_shift     ; B = chunks signed
        sex                                ; D = signed 16-bit chunks
        aslb                               ; chunks × 2
        rola
        aslb                               ; × 4
        rola
        aslb                               ; × 8
        rola
        aslb                               ; × 16
        rola
        aslb                               ; × 32
        rola
        aslb                               ; × 64
        rola
        aslb                               ; × 128 (= chunks × 128, max ±640)
        rola
        pshs  d                            ; save chunks × 128
        lda   DFR_sub_pix                  ; A = sub_pix unsigned 0..15
        ldb   #8
        mul                                ; D = sub × 8 (0..120, A=0)
        addd  ,s++                         ; D = chunks×128 + sub×8 = lateral × 8
        std   DFR_smc_lateral+1            ; C1 : patch l'immédiat `addd #lateral` de la boucle

        * --- (Sub-pixel setup retiré : redondant car overridé per-scanline
        *      dans DFR_have_data depuis combined lateral+curve sub_pix.
        *      Cf. tâche #154.) ---

        * --- Setup boucle : compteur descendant de scanlines (Lead-G) ---
        * DFR_y_curr sert ici de down-counter (NB_ROAD_LINES → 0), plus de
        * cmpa/y_limit dans le corps de boucle. Proj_min_y est relu directement
        * pour les inits qui en ont besoin (U_RAMB, dense_ptr).
        lda   #NB_ROAD_LINES
        sta   <DFR_y_curr

        * --- Erase above horizon (= ciel sur les lignes qui étaient en route n-2) ---
        * Per-buffer state : on lit prev_horizon[backBuffer.id] (= horizon utilisé
        * il y a 2 frames sur ce buffer). Si nouveau > ancien (= route a reculé),
        * on remplit [ancien, nouveau-1] avec sky color. Sinon : la route grossit
        * et écrasera l'ancien → pas d'erase nécessaire.
        ldx   #DFR_prev_horizon
        lda   gfxlock.backBuffer.id
        anda  #1                          ; 0 ou 1
        leax  a,x                         ; X = &DFR_prev_horizon[buf_id]

        lda   ,x                          ; A = prev_horizon (n-2 sur ce buffer)
        ldb   Proj_min_y                  ; B = curr_horizon
        stb   ,x                          ; save curr pour next time (= dans 2 frames)
        stb   DFR_erase_limit             ; save limit en mémoire (pas de cmpa b en 6809)

        cmpa  DFR_erase_limit             ; prev vs curr
        bhs   DFR_no_erase                ; prev >= curr → road grew, no erase

        * Erase loop : A = prev (= Y courant), DFR_erase_limit = curr (exclusif)
DFR_erase_loop
        pshs  a                           ; save Y courant
        inca                              ; A = Y + 1 (= pour fin_de_ligne)
        ldb   #40
        mul                               ; D = (Y+1) × 40
        addd  #$A000-2                    ; D = U_RAMB cheval bordure
        tfr   d,u
        lbsr  DFR_line_mask               ; erase 1 scanline (RAMA + RAMB)
        puls  a                           ; restore Y
        inca                              ; next Y
        cmpa  DFR_erase_limit
        blo   DFR_erase_loop
DFR_no_erase

        * --- U_RAMB / U_RAMA initial = "pure" (= fin_de_ligne - 2, sans byte_offset) ---
        * Convention "à cheval sur la bordure" (cf. tests #94, DFR_TEST_U_BASE_*) :
        * On part de (fin_de_ligne - 2) pour que byte_offset 0..3 couvre la plage
        * [fin-2, fin+1] :
        *   - sub_pix=0 → road occupe bytes -2..37 (= 8 px overflow LEFT sous bande
        *                 noire gauche dans scanline Y-1)
        *   - sub_pix=15 → road occupe bytes 1..40 (= 4 px overflow RIGHT sous bande
        *                  noire droite dans scanline Y+1)
        * Toute l'amplitude curve+lateral reste cachée sous les overlay bands 8 px L+R.
        *
        * Les offsets sub-pixel (= byte_offset, rama_bank_off) sont AJOUTÉS per-scanline
        * au moment du dispatch car ils varient par scanline (= curve sub-pixel).
        ldb   Proj_min_y
        incb                              ; B = Y+1
        lda   #40
        mul                               ; D = (Y+1) × 40
        addd  #$A000-2                    ; -2 oct = à cheval sur la bordure
        std   <DFR_U_RAMB                  ; U_RAMB pure (= fin_ligne - 2)
        *                                   (U_RAMA dérivé per-pass = U_RAMB + $2000, Lead-E)

        * --- Dense_Buffer ptr initial = Dense_Buffer + Proj_min_y × 6 (STEP3) ---
        lda   Proj_min_y                   ; A = 1re scanline projetée
        ldb   #6
        mul
        addd  #Dense_Buffer
        std   <DFR_dense_ptr

        * --- PRC base hoistée : bits 1-7 de $E7C3 (bit 0 = PRC recalc/scanline) (Lead-6) ---
        * Seule la boucle road écrit $E7C3 → lire les bits 1-7 une fois suffit.
        * C1 : patché en immédiat `ldb #base` dans la boucle (SMC, fidèle 68k).
        ldb   $E7C3
        andb  #$FE
        stb   DFR_smc_prc+1

* ============================================================
* Boucle principale : horizon → bas (= Y_curr ascendant)
* Pour chaque scanline :
*   1. Read triplet (flags, width, extra)
*   2. Skip si triplet null
*   3. Set PRC selon bit 10 de extra (= bit 2 de high byte = dark/light)
*   4. Calc ptr Line_NNNN base
*   5. Pass RAMB : jsr Road_draw_KX_JY avec U_RAMB + buffer RAMB
*   6. Pass RAMA : jsr Road_draw_KX_JY avec U_RAMA + buffer RAMA
*   7. Advance cursors (U_RAMB += 40, U_RAMA += 40, dense += 6)
*   8. Y_curr++ ; loop si < Y_limit
* ============================================================
DFR_main_loop
        ldx   <DFR_dense_ptr               ; X = ptr triplet courant

        * === Test triplet null : skip pur (= pas d'écriture) ===
        * Si projection ne produit rien pour cette scanline, on NE TOUCHE PAS
        * la VRAM. La scanline garde sa valeur précédente (= typiquement
        * noir si buffer cleared chaque frame). Permet d'identifier
        * visuellement quelles scanlines la projection couvre.
        ldd   ,x                          ; D = flags
        bne   DFR_have_data
        ldd   2,x                         ; D = width
        bne   DFR_have_data
        ldd   4,x                         ; D = extra
        bne   DFR_have_data
        lbra  DFR_skip_scanline           ; triplet null → skip dispatch
DFR_have_data
        * --- Set PRC bit 0 selon bit 10 de (extra + DFR_track_phase) ---
        * Conforme 68k $7667A : addi.w #(track_phase),D2w (SMC slot) avant
        * btst #10,D2. La modulation par track_phase fait shifter les bandes
        * per-frame même sur ligne droite plate (= sinon bit 10 alterne
        * toujours aux mêmes scanlines → bandes statiques).
        ldd   4,x                         ; D = extra (= LI_d7 du triplet)
DFR_smc_phase
        addd  #0                          ; C1 : #imm = track_phase, patché/frame
DFR_smc_prc
        ldb   #0                          ; C1 : #imm = prc_base (bits 1-7), patché/frame
        bita  #$04                        ; test bit 10 de D = bit 2 de A
        beq   DFR_prc_done
        incb                              ; set bit 0 si bit 10 set
DFR_prc_done
        stb   $E7C3

* ── DEBUG : test direction curve_chunk_shift (= validé, sens correct) ──
* Quand DFR_DEBUG_CURVE_TEST = 1, on bypasse le calcul Mul16x16 et on
* utilise DFR_lateral_chunks_shift (= contrôlé par LEFT/RIGHT) comme
* curve_chunk_shift.
*
* TEST RUNTIME validé : positive shift = road RIGHT screen, négative =
* road LEFT screen. Cohérent avec un virage à droite (slot.X > 0) qui
* fait pencher la route à droite, et inversement.
*
* Mettre à 0 pour utiliser le calcul Mul16x16 réel.
DFR_DEBUG_CURVE_TEST equ 0

 ifne DFR_DEBUG_CURVE_TEST
        lda   DFR_lateral_chunks_shift
        sta   <DFR_curve_chunk_shift
        lbra  DFR_curve_done
 endc

        * --- Modèle leftEdge FIDÈLE 68k (FUN_0007661e $76682-$766a0) ---
        * 68k : centerX = $90 - (combined × width × 2)>>16 ; leftEdge = centerX
        * - demi-largeur. On calcule UNE valeur pixel leftEdge, puis on la
        * décompose atomiquement (chunk + sub) → byte_offset ET J'/K' dérivent de
        * la MÊME valeur → JAMAIS de désync chunk/sub (= cause du jitter ±16-28px
        * prouvé sur trace, cf. tools/extract_road_draw_position.py).
        *
        *   leftEdge_px = (CENTER + neg_product) - M*8
        *     neg_product = -((combined × width)>>16)   (= 68k $90-product, SANS
        *                   ×2 car TO8 demi-résolution 160 px)
        *     M*8         = demi-largeur route (M chunks × 16 px / 2)
        *   leftEdge_chunks = leftEdge >> 4 (signé, peut être <0 = clip gauche)
        *   sub_pix         = leftEdge & 15 → byte_offset (shift fin U)

        * --- (1) width → line_idx → lines_base (besoin de M pour leftEdge) ---
        ldd   2,x                         ; D = width (= scaling 16-bit)
        std   <DFR_width_x2               ; v pour Mul16x16 hoisté ici (Lead-H : évite re-ldd 2,x)
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb                              ; D = width >> 4 (= index 0..$FFF)
        cmpd  #ROAD_LINES_MAX_IDX
        blo   DFR_have_width
        ldd   #ROAD_LINES_MAX_IDX         ; clip à 254
DFR_have_width
        aslb
        rola
        aslb
        rola
        aslb
        rola                              ; D = index × 8
        addd  #Road_lines
        std   <DFR_lines_base

        * --- (2) M = largeur route en chunks (header buffer variant 0, offset 1) ---
        ldx   <DFR_lines_base
        ldx   ,x                          ; X = ptr Line variant 0 (Lead-2 : via X, pas tfr d,y)
        ldb   1,x                         ; B = M
        andb  #$FE                        ; FIX PARITÉ : centre sur la partie PAIRE de M.
        *                                   M impair était décalé de -8px (demi-chunk),
        *                                   car la route est centrée sur une frontière de
        *                                   chunk et un cœur de M impair se cale sur un
        *                                   centre de chunk. (M réel relu en 1,y au dispatch.)

        * --- (3) Pré-calcule (CENTER - (M&~1)*8) et l'empile (survit à Mul16x16) ---
        lda   #8
        mul                               ; D = (M&~1) × 8 (= demi-largeur paire ; A reste 0)
        coma
        comb
        addd  #DFR_SCREEN_CENTER+1        ; D = CENTER - M*8 (= -(M*8) + CENTER)
        pshs  d                           ; [CENTER - M*8]

        * --- (4) combined = slot.X_clean + lateral_scaled ; product ; négation ---
        * (DFR_width_x2 déjà stocké en (1), Lead-H — plus de re-ldd 2,x ici)
        ldx   <DFR_dense_ptr              ; X = triplet ptr
        ldd   ,x                          ; D = flags (= slot.X + bits PIT/START)
        andb  #$FC                        ; clear bits 0-1 → slot.X signed pur
DFR_smc_lateral
        addd  #0                          ; C1 : #imm = lateral_scaled, patché/frame → D = combined
        * --- Mul16x16HiSigned INLINÉ (B1 : évite lbsr/rts ; v = DFR_width_x2) ---
        * std pose déjà Z → on supprime le cmpd #0 de la version sous-routine.
        * (La version sous-routine reste pour player-one.asm.)
        std   <M16_u_signed              ; save u (combined) ; Z=1 si u=0
        beq   DFR_mul_done               ; u=0 (ligne droite) → product 0 (D déjà 0)
        lda   <M16_u_signed              ; A = u_hi
        ldb   <DFR_width_x2              ; B = v_hi
        mul                              ; D = t1 = u_hi×v_hi
        std   <M16_hi_acc
        lda   <M16_u_signed
        ldb   <DFR_width_x2+1            ; B = v_lo
        mul                              ; D = mid_a = u_hi×v_lo
        std   <M16_mid_acc
        lda   <M16_u_signed+1            ; A = u_lo
        ldb   <DFR_width_x2              ; B = v_hi
        mul                              ; D = mid_b = u_lo×v_hi
        addd  <M16_mid_acc              ; D = mid_a + mid_b, C=carry
        tfr   a,b                        ; B = high byte du sum (= >>8)
        bcc   DFR_mul_nocarry
        lda   #1
        bra   DFR_mul_shifted
DFR_mul_nocarry
        clra
DFR_mul_shifted
        addd  <M16_hi_acc               ; D = hi_unsigned = t1 + (mid_sum>>8)
        ldx   <M16_u_signed
        bpl   DFR_mul_done              ; u ≥ 0 → pas de correction de signe
        subd  <DFR_width_x2             ; hi_signed = hi_unsigned - v
DFR_mul_done
        coma
        comb
        addd  #1                          ; D = neg_product (= 68k $90-product sans le 90)

        * --- (5) leftEdge = neg_product + (CENTER - M*8) ---
        addd  ,s++                        ; D = leftEdge (px signé)

        * --- (6) Décompose : sub_pix = leftEdge & 15 ; leftEdge_chunks = >>4 signé
        pshs  b
        andb  #$0F
        stb   <DFR_curve_sub_pix          ; sub_pix 0..15
        puls  b
        asra
        rorb
        asra
        rorb
        asra
        rorb
        asra
        rorb                              ; D >>= 4 signé
        stb   <DFR_curve_chunk_shift      ; = leftEdge_chunks (signé, peut être <0)

        * --- (7) Décodage sub_pix → byte_offset/rama_bank_off/variants : 1 lookup ---
        *   index = sub_pix × 4 ; entry = [byte_offset, rama_bank_off, rama_var, ramb_var]
        *   (remplace les 3 dérivations >>2 / &2>>1 / variant_tbl par 1 abx + 3 reads)
        ldb   <DFR_curve_sub_pix          ; B = sub_pix 0..15
        aslb                              ; ×2
        aslb                              ; ×4 (= 4 oct/entry)
        ldx   #DFR_subpix_tbl
        abx                               ; X → DFR_subpix_tbl[sub_pix]
        lda   ,x
        sta   <DFR_byte_offset
        lda   1,x
        sta   <DFR_rama_bank_off
        ldd   2,x                         ; A = rama_var, B = ramb_var
        sta   <DFR_rama_variant_b
        stb   <DFR_ramb_variant_b

        * (Lead-1 : ldx <DFR_dense_ptr supprimé — DFR_curve_done écrase X via tfr d,x
        *  sans le lire ; c'était du code mort sur le chemin de production.)

DFR_curve_done

        * ===== Compute dispatch INLINÉ (B2, 1×/scanline, partagé RAMB+RAMA) =====
        * Y = buffer RAMB → M lu en 1,Y (identique au variant RAMA depuis fix #5).
        * D1 : ldy b,x. route_ptr/core_off DOIVENT passer par la mémoire : le jsr
        * pattern de la passe RAMB détruit les registres avant la passe RAMA.
        * (Sous-routines DFR_dispatch_compute/draw conservées pour le mode debug.)
        ldx   <DFR_lines_base
        ldb   <DFR_ramb_variant_b          ; B = offset RAMB variant (0/2/4/6)
        ldy   b,x                         ; Y = ptr Line_NNNN buffer pour RAMB

        * -- corps DFR_dispatch_compute inliné --
        lda   <DFR_curve_chunk_shift     ; A = LE (signé)
        adda  1,y                        ; A = LE + M = right
        sta   <DFR_tmp_base
        bpl   DFR_nc_re_pos
        clra
DFR_nc_re_pos
        cmpa  #10
        bls   DFR_nc_re_ok
        lda   #10
DFR_nc_re_ok
        nega
        adda  #10                        ; A = K'
        pshs  a
        lda   <DFR_curve_chunk_shift
        bpl   DFR_nc_jp_pos
        clra
DFR_nc_jp_pos
        cmpa  #10
        bls   DFR_nc_jp_done
        lda   #10
DFR_nc_jp_done
        pshs  a
        ldb   1,s                        ; B = K'
        lda   #11
        mul
        addb  ,s                         ; + J'
        adca  #0
        aslb
        rola
        addd  #Road_draw_dispatch
        tfr   d,x
        ldx   ,x                         ; X = ptr routine
        stx   DFR_route_ptr
        leas  2,s
        lda   <DFR_tmp_base              ; right
        suba  #10
        bpl   DFR_nc_off_pos
        clra
DFR_nc_off_pos
        asla
        adda  #3                         ; core_off = 3 + max(0,right-10)*2
        sta   DFR_core_off

        * ===== Passe RAMB (Y = buffer RAMB) — draw inliné =====
        ldd   <DFR_U_RAMB                  ; U_RAMB_eff = pure + byte_offset
        addb  <DFR_byte_offset
        adca  #0
        tfr   d,u
        ldx   DFR_route_ptr
        beq   DFR_ndb_skip
        ldb   DFR_core_off
        leay  b,y
        jsr   ,x
DFR_ndb_skip

        * ===== Passe RAMA — draw inliné =====
        ldx   <DFR_lines_base
        ldb   <DFR_rama_variant_b          ; B = offset RAMA variant (0/2/4/6)
        ldy   b,x                         ; Y = ptr Line_NNNN buffer pour RAMA (D1)
        * U_RAMA_eff = (U_RAMB_pure + $2000) + byte_offset + rama_bank_off (Lead-E)
        ldd   <DFR_U_RAMB
        addd  #$2000
        addb  <DFR_byte_offset
        adca  #0
        addb  <DFR_rama_bank_off
        adca  #0
        tfr   d,u
        ldx   DFR_route_ptr
        beq   DFR_nda_skip
        ldb   DFR_core_off
        leay  b,y
        jsr   ,x
DFR_nda_skip

DFR_skip_scanline
        * --- Advance cursors pour next scanline (U_RAMA dérivé, Lead-E : 1 seul curseur) ---
        ldd   <DFR_U_RAMB
        addd  #40
        std   <DFR_U_RAMB

        ldd   <DFR_dense_ptr
        addd  #6
        std   <DFR_dense_ptr

        * --- Down-counter : NB_ROAD_LINES → 0 (Lead-G, remplace inc/cmpa/y_limit) ---
        dec   <DFR_y_curr
        lbne  DFR_main_loop              ; long branch (boucle > 128 oct)

        rts

* ======================================================================
* DFR_dispatch_compute / DFR_dispatch_draw — split Lead A (hoist du calcul).
*
* MODÈLE leftEdge FIDÈLE 68k (FUN_0007661e $7673a). La position vient d'UNE
* valeur pixel leftEdge calculée en amont (DFR_curve_chunk_shift = leftEdge>>4 =
* chunks herbe à gauche, SIGNÉ). On ne recentre PLUS la window via N=K+M+J
* (= ancien modèle, cause du jitter ±28px : position polluée par le K/J figé du
* buffer). Seul M (= 1,Y) sert ici.
*
*   LE      = leftEdge_chunks (signé, DFR_curve_chunk_shift)
*   right   = LE + M                       (= bord droit route en chunks)
*   J'      = clamp(LE, 0, 10)             (= herbe gauche ; clip si LE<0)
*   vis_end = clamp(right, 0, 10)
*   K'      = 10 - vis_end                 (= herbe droite ; clip si right>10)
*   F       = 10 - K' - J' = vis_end - J'  (= cœur visible, dérivé par la routine)
*   coreOff = max(0, right - 10) × 2       (= skip chunks cœur tombés à droite)
*
* Clip gauche (LE<0) : J'=0 → F réduit (cœur dessiné < M). Clip droit (right>10):
* coreOff skip les premiers chunks (= rightmost). Identique à la ladder 68k qui
* garde leftEdge_chunks SIGNÉ sans clamp à 0.
*
* === SPLIT (Lead A) ===
* Le calcul K'/J'/index/ptr/coreOff dépend de LE (fixe par scanline) et M.
* Depuis fix #5, M est IDENTIQUE sur les buffers RAMB et RAMA → les 2 passes
* recalculaient exactement la même chose (dont un mul 11 cyc). On scinde :
*   - DFR_dispatch_compute : 1×/scanline → DFR_route_ptr + DFR_core_off
*   - DFR_dispatch_draw    : 1×/passe → leay core_off,Y ; jsr route
*
* ----------------------------------------------------------------------
* DFR_dispatch_compute — calcul partagé (1×/scanline).
* @input  : Y = ptr buffer Line_NNNN (M lu en 1,Y ; identique sur les 2 variants)
*           DFR_curve_chunk_shift = LE
* @output : DFR_route_ptr (ptr routine, 0 si non implémentée)
*           DFR_core_off   (= 3 + max(0,right-10)*2 = offset header+cœur)
* @trashes: A, B, X (Y et U préservés)
* ======================================================================
DFR_dispatch_compute
        * --- right = leftEdge_chunks + M (= bord droit route, chunks signé) ---
        lda   <DFR_curve_chunk_shift     ; A = leftEdge_chunks (signé)
        adda  1,y                        ; A = LE + M = right
        sta   <DFR_tmp_base              ; save right (pour coreOff)

        * --- K' = 10 - clamp(right, 0, 10) ---
        bpl   DFR_dc_re_pos
        clra                             ; right < 0 → vis_end = 0
DFR_dc_re_pos
        cmpa  #10
        bls   DFR_dc_re_ok
        lda   #10                        ; cap vis_end à 10
DFR_dc_re_ok
        nega
        adda  #10                        ; A = 10 - vis_end = K'
        pshs  a                          ; stack: [K']

        * --- J' = clamp(leftEdge_chunks, 0, 10) ---
        lda   <DFR_curve_chunk_shift     ; A = LE (signé)
        bpl   DFR_dc_jp_pos
        clra                             ; LE < 0 → J' = 0 (clip gauche)
DFR_dc_jp_pos
        cmpa  #10
        bls   DFR_dc_jp_done
        lda   #10                        ; cap J' à 10
DFR_dc_jp_done
        pshs  a                          ; stack: [K', J']

        * --- Index dispatch = (K' × 11 + J') × 2 ---
        * 11 = j_max + 1 (= nombre de colonnes dans la dispatch table)
        ldb   1,s                        ; B = K'
        lda   #11
        mul                              ; D = K' × 11
        addb  ,s                         ; B += J'
        adca  #0
        aslb                             ; D ×= 2
        rola
        addd  #Road_draw_dispatch
        tfr   d,x
        ldx   ,x                         ; X = ptr Road_draw_K{K'}_J{J'}
        stx   DFR_route_ptr              ; partagé aux 2 passes (ext)

        * --- Cleanup stack ---
        leas  2,s

        * --- core_off = 3 + max(0, right - 10) × 2 (= header skip + skip chunks droite) ---
        lda   <DFR_tmp_base               ; A = right (= leftEdge_chunks + M)
        suba  #10                        ; A = right - 10
        bpl   DFR_dc_off_pos
        clra                             ; offset = 0 si right <= 10
DFR_dc_off_pos
        asla                             ; A × 2 (= byte offset cœur)
        adda  #3                         ; + skip header K,M,J
        sta   DFR_core_off                ; partagé aux 2 passes (ext)
        rts

* ======================================================================
* DFR_dispatch_draw — dessine 1 passe avec le résultat hoisté du compute.
* @input  : Y = ptr buffer Line_NNNN du variant courant (header + cœur)
*           U = position VRAM (= fin de ligne)
*           DFR_route_ptr / DFR_core_off (= set par DFR_dispatch_compute)
* @output : 40 oct écrits à U-40..U-1
* @trashes: A, B, X, Y
* ======================================================================
DFR_dispatch_draw
        ldx   DFR_route_ptr              ; ptr routine (ext)
        beq   DFR_dispatch_skip          ; 0 → combinaison non implémentée, skip
        ldb   DFR_core_off               ; offset header+cœur (ext)
        leay  b,y                        ; Y → cœur + offset
        jsr   ,x                         ; routine déroulée
DFR_dispatch_skip
        rts

* ======================================================================
* DrawFrameRoad_TestLine — test minimal sub-pixel
*
* Dessine 96 scanlines identiques avec Line_0254 (= route très large)
* à la position pilotée par DFR_sub_pix (0..15 px).
*
* Permet de valider visuellement le mécanisme 4 variants × byte_offset
* sans dépendre de SparseProjection / LinearInterp / triplets dense.
*
* Force K'=2, J'=2 (= F=6, route bien visible) au lieu d'utiliser K/J du header
* (qui valent 5/5 sur Line_0254 → F=0 = tout en herbe = invisible).
* ======================================================================
DFR_TEST_LINE_IDX    equ   254             ; index dans Road_lines (K=5 M=6 J=5)
DFR_TEST_KPRIME      equ   2                ; force grass left (= 2 chunks = 8 px)
DFR_TEST_JPRIME      equ   2                ; force grass right (= 2 chunks = 8 px)
* (K'*11 + J')*2 = (2*11 + 2)*2 = 48 — hardcodé car lwasm 4.24 ne gère pas l'expression
DFR_TEST_DISPATCH_OFF equ   48

DrawFrameRoad_TestLine
        * --- Mount road_buffers cart bank ---
        ldx   #Obj_Index_Page
        lda   ObjID_RoadBuffers,x
        _SetCartPageA

        * --- Setup sub_pix via table (idem DrawFrameRoad : 1 lookup) ---
        ldb   DFR_sub_pix
        aslb
        aslb                              ; sub_pix × 4
        ldx   #DFR_subpix_tbl
        abx
        lda   ,x
        sta   <DFR_byte_offset
        lda   1,x
        sta   <DFR_rama_bank_off
        ldd   2,x
        sta   <DFR_rama_variant_b
        stb   <DFR_ramb_variant_b

        * ====================================================
        * UNE seule ligne au milieu du viewport (= scanline 48)
        * Permet de valider précisément le positionnement au pixel près.
        * U_base = fin scanline 48 - 2 oct (= centrage amplitude 16 px) :
        *   - sub_pix=0  → road occupe bytes -2..37 (= 8 px overflow LEFT
        *                  dans scanline 47 sous bande noire gauche)
        *   - sub_pix=15 → road occupe bytes 1..40 (= overflow RIGHT
        *                  dans scanline 49 sous bande noire droite)
        * Toute l'amplitude reste sous les overlay bands 8 px L+R.
        * ====================================================
DFR_TEST_U_BASE_B    equ   $A7A8-2           ; = $A7A6 (fin ligne 48 RAMB -2)
DFR_TEST_U_BASE_A    equ   $C7A8-2           ; = $C7A6 (fin ligne 48 RAMA -2)

        * --- Banque RAMB ---
        ldd   #DFR_TEST_U_BASE_B
        addb  <DFR_byte_offset             ; U += byte_offset (= shift right par byte)
        adca  #0
        tfr   d,u

        ldd   #(DFR_TEST_LINE_IDX*8)
        addd  #Road_lines
        addb  <DFR_ramb_variant_b
        adca  #0
        tfr   d,x
        ldy   ,x
        lbsr  DFR_TL_dispatch_fixed

        * --- Banque RAMA ---
        ldd   #DFR_TEST_U_BASE_A
        addb  <DFR_byte_offset             ; U += byte_offset
        adca  #0
        addb  <DFR_rama_bank_off            ; U += rama_bank_off (+1 si RAMB-first)
        adca  #0
        tfr   d,u

        ldd   #(DFR_TEST_LINE_IDX*8)
        addd  #Road_lines
        addb  <DFR_rama_variant_b
        adca  #0
        tfr   d,x
        ldy   ,x
        lbsr  DFR_TL_dispatch_fixed

        rts

* ======================================================================
* DFR_TL_dispatch_fixed — dispatch hardcodé K'=2, J'=2 (= F=6 road visible)
*
* @input  : Y = ptr buffer Line_NNNN (header K, M, J + 6 fdb Road_R*)
*           U = position VRAM (= fin scanline ajustée par byte_offset)
* @output : 40 oct écrits avec 2 grass left + 6 road + 2 grass right
* ======================================================================
DFR_TL_dispatch_fixed
        ldx   #Road_draw_dispatch
        leax  DFR_TEST_DISPATCH_OFF,x    ; X = &Road_draw_dispatch[K'*7+J']
        ldx   ,x                         ; X = ptr Road_draw_K2_J2
        cmpx  #0
        beq   DFR_TL_skip                ; routine non implémentée -> skip
        leay  3,y                        ; skip header K, M, J -> coeur
        jsr   ,x
DFR_TL_skip
        rts

* ======================================================================
* DrawFrameRoad_Debug — MODE DEBUG validation du placement (200 lignes)
*
* Affiche 200 lignes empilées : scanline écran Y = 0..199 → line_idx = Y
* (= la plus étroite en haut, la plus large en bas). Chaque ligne est posée à
* sa position NATURELLE = route CENTRÉE (les buffers sont centrés : J=12-M/2,
* K=5, cœur au centre). LE = (10-M)/2 par ligne ; DFR_dbg_offset (LEFT/RIGHT)
* ajoute un décalage global au pixel près (chunk = offset>>4, sub = offset&15).
*
* But : valider la couche de PLACEMENT (line_idx + offset → LE + sub_pix →
* rendu) SANS projection ni perspective. Le dispatch DFR_dispatch_compute/draw
* et la table DFR_subpix_tbl sont réutilisés TELS QUELS — AUCUNE modif du
* rendu. C'est un appelant additif, comme DrawFrameRoad_TestLine.
*
* Convention U = fin de ligne (PAS le -2 "à cheval bordure" du mode normal).
*
* Optim : sub_pix (offset&15) décodé UNE fois avant la boucle ; par scanline il
* reste M→LE centré, calcul U, et 2 jsr dispatch.
*
* @input  : DFR_dbg_offset (leftEdge px 0..159)
* @trashes: A, B, X, Y, U
* ======================================================================
DFR_DBG_NB_LINES   equ 200

DrawFrameRoad_Debug
        * --- Mount road_buffers en cart zone $0000-$3FFF ---
        ldx   #Obj_Index_Page
        lda   ObjID_RoadBuffers,x
        _SetCartPageA

        * --- PRC = DFR_dbg_prc (FIRE bascule dark/light) ---
        ldb   $E7C3
        andb  #$FE
        orb   DFR_dbg_prc                 ; 0=dark / 1=light
        stb   $E7C3

        * --- base = 88 - dbg_offset (hoist). Par ligne : leftEdge = base - M*8 ---
        *   80 = centre écran ($90/2) ; +8 px compense le décalage U=-2 (2 octets =
        *   8 px) du rendu à cheval → la route retombe centrée à l'écran (px 80).
        *   dbg_offset signé décale ensuite. DFR_width_x2 réutilisé comme base (le
        *   mode debug ne fait pas de Mul16x16 → slot libre).
        ldd   #88
        subd  DFR_dbg_offset
        std   <DFR_width_x2               ; base = 88 - offset

        * --- U bases : fin de ligne 0 - 2 (à cheval bordure, comme le mode road) ---
        *   Le -2 centre le rendu à cheval (overflow 8px L/R sous les bandes noires),
        *   masquées ensuite par DFR_border_mask_dbg. Identique au mode normal.
        ldd   #$A000+40-2
        std   <DFR_U_RAMB
        addd  #$2000
        std   <DFR_U_RAMA

        * --- lines_base init = Road_lines + DFR_dbg_line_base*8 (scroll vertical) ---
        lda   DFR_dbg_line_base           ; 1er line_idx affiché (0..55)
        ldb   #8
        mul                               ; D = line_base * 8 (octets/entrée Road_lines)
        addd  #Road_lines
        std   <DFR_lines_base

        clr   <DFR_y_curr                 ; Y = 0
DFR_dbg_loop
        * --- leftEdge = base - M*8 = 80 - offset - M*8 (px signé) ---
        *   = route centrée (à offset 0) décalée par l'offset. Décomposé en
        *   LE (chunk, signé) + sub_pix (0..15). Aux extrêmes de l'offset, le
        *   dispatch clampe J'/K' → tout herbe (= clamp grass, plus tôt pour les
        *   lignes courtes qui ont plus de course avant de sortir).
        ldx   <DFR_lines_base
        ldd   ,x                          ; D = ptr Line variant 0
        tfr   d,y
        lda   1,y                         ; A = M (cœur, chunks)
        anda  #$FE                        ; centre sur la partie PAIRE de M : compense le
        *                                   demi-chunk (8px) de parité → route centrée même
        *                                   si M impair (leftEdge += 8 pour M impair).
        ldb   #8
        mul                               ; D = (M & ~1)*8 (demi-largeur paire ; A=0)
        pshs  d
        ldd   <DFR_width_x2               ; D = base = 88 - offset
        subd  ,s++                        ; D = leftEdge = base - (M&~1)*8 (signé)

        * décompose : sub_pix = leftEdge & 15 ; LE = leftEdge >> 4 (signé)
        pshs  b
        andb  #$0F
        stb   <DFR_curve_sub_pix
        puls  b
        asra
        rorb
        asra
        rorb
        asra
        rorb
        asra
        rorb                              ; D = leftEdge >> 4 (signé)
        stb   <DFR_curve_chunk_shift      ; LE signé (peut être <0 ou >10 → clamp dispatch)

        * décode sub_pix → byte_offset/rama_bank_off/variants (par ligne, 1 lookup)
        ldb   <DFR_curve_sub_pix
        aslb
        aslb
        ldx   #DFR_subpix_tbl
        abx
        lda   ,x
        sta   <DFR_byte_offset
        lda   1,x
        sta   <DFR_rama_bank_off
        ldd   2,x
        sta   <DFR_rama_variant_b
        stb   <DFR_ramb_variant_b

        * ===== Compute dispatch (1×/scanline, partagé RAMB+RAMA) =====
        ldd   <DFR_lines_base
        addb  <DFR_ramb_variant_b
        adca  #0
        tfr   d,x
        ldy   ,x                          ; Y = ptr Line buffer RAMB
        lbsr  DFR_dispatch_compute         ; → DFR_route_ptr, DFR_core_off (Y préservé)

        * ===== Passe RAMB ===== (Y = buffer RAMB déjà posé)
        ldd   <DFR_U_RAMB
        addb  <DFR_byte_offset
        adca  #0
        tfr   d,u
        lbsr  DFR_dispatch_draw

        * ===== Passe RAMA =====
        ldd   <DFR_lines_base
        addb  <DFR_rama_variant_b
        adca  #0
        tfr   d,x
        ldy   ,x                          ; Y = ptr Line buffer RAMA
        ldd   <DFR_U_RAMA
        addb  <DFR_byte_offset
        adca  #0
        addb  <DFR_rama_bank_off
        adca  #0
        tfr   d,u
        lbsr  DFR_dispatch_draw

        * --- Advance cursors + line_idx ---
        ldd   <DFR_U_RAMB
        addd  #40
        std   <DFR_U_RAMB
        ldd   <DFR_U_RAMA
        addd  #40
        std   <DFR_U_RAMA
        ldd   <DFR_lines_base
        addd  #8                          ; line_idx++ (8 oct/entrée Road_lines)
        std   <DFR_lines_base

        inc   <DFR_y_curr
        lda   <DFR_y_curr
        cmpa  #DFR_DBG_NB_LINES
        lbcs  DFR_dbg_loop
        rts

* ======================================================================
* DFR_border_mask_dbg — masque bordure NOIRE 8px L+R, PLEINE HAUTEUR (200 lignes)
*
* Même mécanisme que DFR_border_mask du mode road (pshu d,x à chaque frontière
* de scanline = bytes 38,39 de la ligne N + bytes 0,1 de la ligne N+1, sur les
* 2 banques → 8 px L + 8 px R), mais sur les 200 lignes du viewport debug et en
* couleur DFR_DBG_BORDER_COLOR. Masque l'overflow "à cheval" du rendu -2.
*
* @trashes: D, X, Y, U
* ======================================================================
DFR_DBG_BORDER_COLOR equ $8888        ; noir = index 8 (= même couleur que le masque du mode road)

DFR_border_mask_dbg
        ldd   #DFR_DBG_BORDER_COLOR
        ldx   #DFR_DBG_BORDER_COLOR

        * --- Banque RAMB : 200 frontières depuis le bas ---
        ldu   #$A000+DFR_DBG_NB_LINES*40+2   ; byte 2 sous la dernière ligne
        ldy   #DFR_DBG_NB_LINES
DFR_BMD_loop_b
        pshu  d,x                            ; 38,39 ligne N + 0,1 ligne N+1
        leau  -36,u                          ; -40 au total = 1 ligne en arrière
        leay  -1,y
        bne   DFR_BMD_loop_b
        pshu  d,x                            ; bordure gauche ligne 0

        * --- Banque RAMA : idem $C000 ---
        ldu   #$C000+DFR_DBG_NB_LINES*40+2
        ldy   #DFR_DBG_NB_LINES
DFR_BMD_loop_a
        pshu  d,x
        leau  -36,u
        leay  -1,y
        bne   DFR_BMD_loop_a
        pshu  d,x
        rts

* ======================================================================
* Mul16x16HiSigned — signed 16x16 multiplication, returns high 16 bits
*
* @input   D                = u (signed 16-bit)
*          DFR_width_x2     = v (unsigned 16-bit, ≥ 0 dans notre usage)
* @output  D                = (u × v) >> 16, signed
* @clobbers A, B, X
*
* Algorithme : Knuth Algorithm M tronquée + Hacker's Delight 8-2 sign
* correction. v est garanti positif dans notre usage (= width × 2 ≤ 8190),
* donc 1 seule correction de signe nécessaire :
*
*   hi_signed = hi_unsigned - v × sign(u)
*
* hi_unsigned via décomposition :
*   t1 = u_hi × v_hi
*   t2 = (u_hi × v_lo + u_lo × v_hi) >> 8
*   hi_unsigned = t1 + t2
*
* (On skip u_lo × v_lo car contribue 0 au high 16 ; le carry potentiel de
*  ce term est ignoré → erreur max ±1 unité, négligeable au pixel près.)
*
* Cycles : ~80 cas standard, ~20 early-exit (u = 0).
* ======================================================================
Mul16x16HiSigned
        std   <M16_u_signed                ; save u
        cmpd  #0
        beq   M16_zero_exit               ; early-exit si u = 0 (= ligne droite)

        * --- t1 = u_hi × v_hi ---
        lda   <M16_u_signed                ; A = u_hi
        ldb   <DFR_width_x2                ; B = v_hi
        mul                               ; D = t1
        std   <M16_hi_acc

        * --- mid_a = u_hi × v_lo ---
        lda   <M16_u_signed
        ldb   <DFR_width_x2+1              ; B = v_lo
        mul                               ; D = mid_a
        std   <M16_mid_acc

        * --- mid_b = u_lo × v_hi, sum dans D ---
        lda   <M16_u_signed+1              ; A = u_lo
        ldb   <DFR_width_x2                ; B = v_hi
        mul                               ; D = mid_b
        addd  <M16_mid_acc                 ; D = mid_a + mid_b (16-bit), C=carry

        * --- Shift mid_sum >> 8 avec carry ---
        * sum_17bit = (C << 16) | D. >> 8 = (C << 8) | (D high byte).
        tfr   a,b                         ; B = A (= high byte of sum)
        bcc   M16_no_mid_carry
        lda   #1
        bra   M16_mid_shifted
M16_no_mid_carry
        clra
M16_mid_shifted
        * D = mid_sum >> 8 (= 9-bit valeur max)

        * --- hi_unsigned = t1 + mid_sum_shifted ---
        addd  <M16_hi_acc                  ; D = hi_unsigned

        * --- Sign correction : si u < 0, subtract v ---
        ldx   <M16_u_signed
        bpl   M16_done                    ; u ≥ 0 → pas de correction
        subd  <DFR_width_x2                ; hi_signed = hi_unsigned - v
M16_done
        rts

M16_zero_exit
        * D = M16_u_signed = 0 déjà.
        rts

* ======================================================================
* DFR_line_mask — efface 36 oct par bank (= 72 oct total) d'une scanline.
*
* Input  : U = fin_ligne_RAMB - 2 (= cheval bordure, même convention que
*              le rendu normal road).
* Output : - (= efface en place)
* Clobbers : D, X, Y, U
*
* Layout VRAM :
*   - Écriture pshu D,X,Y (= 6 oct par instruction).
*   - 6 × pshu = 36 oct écrits par bank (= bytes 2..37 de scanline, laisse
*     bytes 0-1 + 38-39 = 8 px L + 8 px R = bordures intactes).
*   - leau $2024,u switch RAMB→RAMA en restaurant le point de départ pour
*     la même scanline dans l'autre bank :
*       delta = ($C000 + (Y+1)×40 - 2) - ($A000 + Y×40 + 2) = $2024
*   - 6 × pshu en RAMA = idem.
* ======================================================================
DFR_line_mask
        ldd   #DFR_SKY_COLOR
        ldx   #DFR_SKY_COLOR
        ldy   #DFR_SKY_COLOR

        * --- RAMB pass : 6 × pshu = 36 oct ---
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y

        * --- Switch RAMB → RAMA même scanline ---
        leau  $2024,u

        * --- RAMA pass : 6 × pshu = 36 oct ---
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y

        rts

* ======================================================================
* DFR_border_mask — masque les bordures L (8 px) + R (8 px) sur les 96
* scanlines visibles, pour les 2 banks RAMA + RAMB.
*
* À appeler EN FIN DE FRAME après DrawSprites (= les sprites peuvent
* avoir débordé dans les zones de bordure).
*
* Pattern : pshu D,X (= 4 oct) à la frontière entre scanlines N et N+1
* écrit :
*   - bytes 38..39 de scanline N (= bordure droite de N)
*   - bytes 0..1 de scanline N+1 (= bordure gauche de N+1)
*
* leau -36,u avance U de 40 oct backward (= 4 du pshu + 36 du leau),
* soit 1 scanline en arrière, pour itérer sur les 96 frontières.
*
* U_init = $A000 + (Proj_min_y + 96) × 40 + 2 = byte 2 de scanline juste
* en-dessous du bas de la route (= sert d'amorce pour atteindre bordure
* du dernier scanline route).
*
* Optim (#137b) : on n'efface que les 96 lignes effectivement dessinées
* (Y=Proj_min_y..Proj_min_y+95), pas tout l'écran depuis Y=0. Évite de
* masquer inutilement la zone sky au-dessus du horizon.
*
* Coût : 96 × (pshu 9 + leau 5 + leay 4 + bne 3) × 2 banks ≈ 4030 cycles
* + 2 muls de calcul U_init (~30 cyc). Total < 1% frame budget.
* ======================================================================
DFR_border_mask
        * --- Calcule count = 96 - Proj_min_y (early-exit si horizon hors viewport) ---
        lda   Proj_min_y
        cmpa  #96
        bhs   DFR_BM_done                 ; Proj_min_y >= 96 → no road visible
        lda   #96
        suba  Proj_min_y
        sta   DFR_BM_count+1              ; low byte (high reste 0 via fdb 0)

        ldd   #DFR_SKY_COLOR
        ldx   #DFR_SKY_COLOR

        * --- RAMB pass : count frontières (= lignes route visibles) ---
        ldu   #$A000+96*40+2              ; $AF02 (= byte 2 scanline 96, sous viewport)
        ldy   DFR_BM_count                ; Y = count
DFR_BM_loop_b
        pshu  d,x
        leau  -36,u
        leay  -1,y
        bne   DFR_BM_loop_b
        pshu  d,x

        * --- RAMA pass : idem mais $C000 ---
        ldu   #$C000+96*40+2              ; $CF02
        ldy   DFR_BM_count
DFR_BM_loop_a
        pshu  d,x
        leau  -36,u
        leay  -1,y
        bne   DFR_BM_loop_a
        pshu  d,x

DFR_BM_done
        rts

 endc
