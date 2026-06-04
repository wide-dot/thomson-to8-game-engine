; ============================================================================
; Object — PlayerOne
;
; Le pilote contrôlé par le joueur. L'état physique Lotus est dans
; PlayerOne_State (= zone résidente, struct LotusCarState 32 oct). L'OST
; player1 (= en DP $9F00) ne contient que le lifecycle standard ; le tick
; physique opère sur PlayerOne_State via U.
;
; Input : lu directement depuis Dpad_Held (= mis à jour par ReadJoypads
; 1×/frame dans MainLoop). N ticks PhysicsTick sont appelés par main
; iter avec N = gfxlock.frameDrop.count (= rattrapage frame drop).
;
; input REG : [u] pointer to Object Status Table (OST) — = player1 = dp
; ============================================================================

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/struct/LotusCarState.struct.asm"
        INCLUDE "./engine/physics/PhysicsTables.asm"
        INCLUDE "./objects/player-one/player-one.equ"

* ════════════════════════════════════════════════════════════════════════
* TEST FREEZE (= validation rendu sur image fixe)
* ----------------------------------------------------------------------
* Quand P1M_TEST_FREEZE = 1 :
*   - PlayerOne_Init force segment_idx = P1M_TEST_SEG_IDX et
*     track_pos+2 = P1M_TEST_NIBBLE << 4 (= position sub-segment).
*   - PlayerOne_Main skip tout (= pas de PhysicsTick, pas d'input).
*   - speed = 0 (= scroll arrêté).
*
* Pour comparer avec le rendu attendu, utiliser :
*   tools/extract_test_state.py <SEG_IDX> <NIBBLE>
* ════════════════════════════════════════════════════════════════════════
P1M_TEST_FREEZE  equ 0                   ; 1 = freeze pour test rendu statique
P1M_TEST_SEG_IDX equ 126                 ; (utilisé seulement si freeze = 1)
P1M_TEST_NIBBLE  equ 0                   ; (utilisé seulement si freeze = 1)

* ════════════════════════════════════════════════════════════════════════
* Mécanique véhicule : accélération + steering + lateral_pos
* ----------------------------------------------------------------------
* Per-tick (= 50 Hz physique, N ticks par main iter via frameDrop comp) :
*   1. SPEED : UP → +ACCEL, DOWN → -BRAKE, neither → -COAST. Clamp [0, MAX].
*   2. STEERING : LEFT → -RATE, RIGHT → +RATE, neither → toward 0 (= self-center).
*      Clamp ±STEER_MAX.
*   3. LATERAL_POS : += steering × (speed >> 8) (= petit delta proportionnel
*      à la vitesse). Couplage speed = pas de steering quand voiture arrêtée.
*      Clamp ±LATERAL_MAX.
*
* Après les N ticks (= 1× par main iter), décompose lateral_pos en
* DFR_lateral_chunks_shift (= signed chunks) + DFR_sub_pix (= 0..15 px).
* ════════════════════════════════════════════════════════════════════════
* Valeurs ★ confirmées Lotus 68k (doc 21_TICK_PHYSIQUE_JOUEUR.md) :
P1M_SPEED_BRAKE   equ $30         ; -48 par tick (= conforme 68k BRAKE_DECEL)
P1M_STEER_MAX     equ $20         ; ±32 (= 68k STEERING_MAX)
P1M_STEER_RATE    equ 2           ; +/-2 par tick (= 68k STEERING_DELTA)
P1M_STEER_DECAY   equ 1           ; -1 par tick vers 0 (= 68k STEERING_DECAY)

* Valeurs approximées (= 68k utilise engine_table[rpm>>7] complexe avec gear) :
P1M_SPEED_ACCEL   equ 6           ; +6 par tick (≈ gear 0 torque). ~1.4 sec full accel.
P1M_SPEED_COAST   equ 2           ; -2 par tick friction (approximation).

* LATERAL_MAX : valeur ★ Lotus conforme via PHYS_LATERAL_HI = $C0 = 192
* (= ST $0180 /2 pour TO8 half resolution). Cf engine/physics/PhysicsTables.asm.
* Le DFR dispatch clamp ensuite per-scanline selon M, donc on peut autoriser
* la valeur full Lotus sans crainte.
P1M_LATERAL_MAX   equ PHYS_LATERAL_HI   ; ±192 (= conforme Lotus 68k)

* ============================================================================
* Entry point — dispatch par routine ID
* ============================================================================
PlayerOne
        lda   <player1+routine
        asla
        ldx   #PlayerOne_Routines
        jmp   [a,x]

PlayerOne_Routines
        fdb   PlayerOne_Init
        fdb   PlayerOne_Main

* ============================================================================
* Init — appelé une fois au démarrage du game mode
* ============================================================================
PlayerOne_Init
        * --- Lifecycle OST : sprite voiture en mode overlay (= screen direct) ---
        * Pattern goldorak : image_set + xy_pixel + priority + render_overlay_mask.
        * Pas d'animation (= image statique), pas de x_pos/y_pos (= mode playfield).
        * Mode overlay = render coords direct écran via xy_pixel (= byte X, byte Y).
        * xy_pixel = $5058 → X=$50=80, Y=$58=88 (= centre bas viewport route).
        ldd   #Img_Player                   ; init = frame centre (steering=0)
        std   <player1+image_set
        * xy_pixel = $7862 : X=120 ($78), Y=98 ($62).
        * Conforme Lotus : la voiture reste FIXE au centre-bas de l'écran,
        * c'est la road qui shift sous elle quand on steere (= via DFR_lateral_*).
        ldd   #$7867
        std   <player1+xy_pixel
        lda   #2                            ; priority 2 = front
        sta   <player1+priority
        lda   <player1+render_flags
        ora   #render_overlay_mask          ; active le rendu sprite overlay
        sta   <player1+render_flags

        * --- Init état Lotus (= valeurs de départ post-FUN_74eac) ---
        ldu   #PlayerOne_State

        * ============================================================
        * track_pos initial : reverse-engineered depuis 68k Ghidra
        * ------------------------------------------------------------
        * Formule confirmee via Ghidra (CARS.REL, base $70400):
        *
        *   segment_idx_init = (A2[grid].upper_word + NB_SEGMENTS) mod NB_SEGMENTS
        *
        * Avec:
        *   - A2 = Grid_TrackPos_Table a $7ada0 (20 longwords)
        *   - NB_SEGMENTS = Circuit_NbSegments ($7ca9a, lu du fichier
        *     circuit par Circuit_Load_Header FUN_744b4 au boot)
        *   - grid = grid_position du joueur (0..19)
        *
        * Setup de grid_pos a $74fc0 (3 branches):
        *   - Mode tutorial ($7cd5a==3): D1=0 (= pole position)
        *   - Race continuation: D1=20-prev_grid
        *   - DEFAULT first race: D1=19 (= last grid)
        *
        * Pour notre cas:
        *   - Circuit_23_hard_6 -> NB_SEGMENTS = 256
        *   - default race init -> grid 19 -> A2[19]=$FFFAC000
        *   - segment_idx_init = ($FFFA + $0100) & $FFFF = $00FA = 250
        *
        * Note: track_pos.lower_word = $C000 (= 0.75 sub-segment offset)
        * mais nous utilisons format compact 8oct/segment donc on ne stocke
        * que l'entier. Le sub-offset n'a pas d'impact sur le rendu initial.
        * ============================================================
 ifne P1M_TEST_FREEZE
        * --- TEST FREEZE : hardcode segment + nibble pour image statique ---
        ldd   #0
        std   LotusCarState.track_pos,u
        lda   #P1M_TEST_NIBBLE*16        ; high nibble = sub-position
        sta   LotusCarState.track_pos+2,u
        clr   LotusCarState.track_pos+3,u
        ldd   #P1M_TEST_SEG_IDX
        std   LotusCarState.segment_idx,u
        ldd   #0                          ; speed = 0 (scroll arrêté)
        std   LotusCarState.speed,u
 else
        * BUG FIX (init garbage segments) :
        * Avant : hardcode `ldd #250` (= valeur 68k pour NB_SEG=256). Sur
        * notre circuit 22_hard_5 (N=176), seg 250 lit GARBAGE mémoire
        * passé les segments + cache → SP produit D3 explosif → Y_min=-90
        * (= horizon hors-écran haut) pendant ~12 frames jusqu'à ce que
        * PhysicsTick avance segment_idx dans la zone valide [0..N-1].
        *
        * Fix : init dynamique segment_idx_init = NB_SEGMENTS - 6 (= grille
        * 19 = dernière position de la ligne de départ, 6 segments avant le
        * point de départ du circuit). Circuit_nb_segments est set par
        * game-mode/road/main.asm avant PlayerOne_Init via :
        *     ldd ACTIVE_CIRCUIT_NB ; std Circuit_nb_segments
        ldd   Circuit_nb_segments        ; D = N (= e.g., 176 pour 22_hard_5)
        subd  #6                         ; D = N - 6 (= grille 19, conforme 68k)
        std   LotusCarState.track_pos,u  ; track_pos.upper = N - 6 (segment idx)
        std   LotusCarState.segment_idx,u
        ldd   #0
        std   LotusCarState.track_pos+2,u ; track_pos.lower = 0 (sub-segment 0)

        * speed = 0 au boot : voiture arrêtée, doit accélérer via UP.
        ldd   #0
        std   LotusCarState.speed,u
 endc

        * gear = 0 (1ère vitesse)
        std   LotusCarState.gear,u

        * lateral_pos = 0 (centre route)
        std   LotusCarState.lateral_pos,u
        std   LotusCarState.lateral_pos+2,u

        * steering = 0
        std   LotusCarState.steering,u
        std   LotusCarState.lat_impulse,u
        std   LotusCarState.lat_impulse_dir,u
        std   LotusCarState.event_flag,u
        std   LotusCarState.recovery_timer,u

        * Inputs et flags = 0
        sta   LotusCarState.input_held,u
        sta   LotusCarState.input_last,u
        sta   LotusCarState.input_edges,u
        sta   LotusCarState.off_road,u
        sta   LotusCarState.gearbox_b0,u

        * rpm = PHYS_RPM_MIN (1000)
        ldd   #PHYS_RPM_MIN
        std   LotusCarState.rpm,u

        * max_speed = PHYS_MAX_SPEED (= $1AA = forward max)
        ldd   #PHYS_MAX_SPEED
        std   LotusCarState.max_speed,u

        * Passe en routine Main
        lda   #PlayerOne_Main_routine
        sta   <player1+routine
        rts

* ============================================================================
* Main — read Dpad_Held + N ticks PhysicsTick par main loop iter
* ============================================================================
* gfxlock.frameDrop.count = nb de VBL écoulés depuis la dernière main iter
* (= 1 si main loop = 50Hz, 2 si 25Hz, etc.). On appelle PhysicsTick autant
* de fois pour conserver une horloge physique 50Hz indépendante du frame
* rate du render.
* ============================================================================
* NOTE lwasm 4.24 : la directive `struct` (LotusCarState) casse le scope
* des @-labels. Workaround : labels globaux préfixés `P1M_xxx`.
PlayerOne_Main
 ifne P1M_TEST_FREEZE
        rts                              ; freeze : aucun tick, pas d'input
 endc
        * --- Force sprite refresh chaque frame ---
        * Le background route change à chaque frame (= scrolling). Sans ce flag,
        * CheckSpritesRefresh skip le redraw si le sprite n'a pas bougé →
        * sprite "fantôme" sur l'ancien background. EraseSprites consomme et
        * clear le flag chaque frame, donc on doit le re-set.
        lda   #1                          ; non-zero = force full refresh
        sta   <glb_force_sprite_refresh

        * --- Input held → PhysicsTick (= 1 tick par main loop iter) ---
        * Simplification : on lit Dpad_Held (= mis à jour par ReadJoypads 1×/frame
        * dans MainLoop AVANT PlayerOne_Main, format TO8 natif post-coma, bit
        * 1=pressed). Ça reflète l'état RÉEL des touches au moment du tick.
        *
        * Si frame drop (= main tourne à 25Hz au lieu de 50Hz),
        * gfxlock.frameDrop.count = 2 (au lieu de 1) → on rattrape en
        * appelant PhysicsTick N fois pour conserver l'horloge physique 50Hz
        * indépendante du frame rate du render.
        *
        * Format Dpad_Held bits :
        *   bit 0 = UP, bit 1 = DOWN, bit 2 = LEFT, bit 3 = RIGHT
        *
        * Effet UP held → speed += $30/tick → scrolling continu.
        *      DOWN held → speed -= $30/tick → freinage.
        ldu   #PlayerOne_State
        lda   Dpad_Held
        sta   LotusCarState.input_held,u

        * Frame compensation : run gfxlock.frameDrop.count ticks par main iter.
        * Lotus 68k vise une physique strictement 50Hz (= 1 tick par VBL). Notre
        * main loop peut tourner à 25Hz ou plus lent selon la charge render →
        * on rattrape en faisant N ticks where N = nb de VBLs écoulés depuis
        * le dernier main iter (= gfxlock.frameDrop.count).
        *
        * BUG FIX HISTORIQUE (#123) : PhysicsTick clobbe D (= A:B) via ldd/addd.
        * Le compteur B doit être SAUVÉ autour du jsr.
        ldb   gfxlock.frameDrop.count
        beq   P1M_skip_tick               ; si 0 frame écoulée, skip (= boot)
P1M_tick_loop
        pshs  b                           ; save tick counter
        lbsr  P1M_one_tick                ; speed + steering + lateral_pos update
        jsr   Lotus_PhysicsTick           ; track_pos += 5 × speed (= nouveau speed)
        puls  b
        decb
        bne   P1M_tick_loop
P1M_skip_tick

        * --- Décompose lateral_pos → DFR_lateral_chunks_shift + DFR_sub_pix ---
        * Une fois par main iter (= pas dans le tick loop), donne la position
        * lateral en chunks/sub_pix attendus par DrawFrameRoad.
        lbsr  P1M_apply_lateral

        * --- Sprite voiture : sélection frame selon steering (table 9 entries) ---
        * Mapping : steering ∈ [-32, +32] → index ∈ [0, 8] (= center à 4).
        * index = (steering >> 3) + 4. ASR (signed shift) ×3 = /8 signed.
        ldu   #PlayerOne_State
        lda   LotusCarState.steering,u    ; A = signed steering (-32..+32)
        asra
        asra
        asra                              ; A = steering >> 3 (signed, -4..+4)
        adda  #4                          ; A = index 0..8
        asla                              ; × 2 (entries de 2 oct)
        ldx   #P1M_Frame_Table
        ldd   a,x                         ; D = ptr Img_Player_xxx
        std   <player1+image_set

        * --- Affichage explicite du sprite (= pattern goldorak) ---
        ldu   #player1                    ; U = OST player1
        jmp   DisplaySprite

* ============================================================================
* P1M_Frame_Table — 9 pointeurs Img_xxx indexés par steering bucket
* ----------------------------------------------------------------------
* index = (steering >> 3) + 4 :
*   0 → steering ≈ -32 (= max gauche) → playerL-4
*   ...
*   4 → steering = 0   (= centre)     → player
*   ...
*   8 → steering ≈ +32 (= max droite) → playerR-4
* ============================================================================
P1M_Frame_Table
        fdb   Img_Player_L4
        fdb   Img_Player_L3
        fdb   Img_Player_L2
        fdb   Img_Player_L1
        fdb   Img_Player
        fdb   Img_Player_R1
        fdb   Img_Player_R2
        fdb   Img_Player_R3
        fdb   Img_Player_R4


* ============================================================================
* P1M_one_tick — 1 tick physique (= 1 VBL @ 50 Hz)
* Modifie speed, steering, lateral_pos selon input.
* Clobbers : A, B, X, condition codes.
* ============================================================================
P1M_one_tick
        * --- (1) SPEED : UP → accel, DOWN → brake, neither → coast ---
        lda   LotusCarState.input_held,u
        bita  #c1_button_up_mask
        beq   P1OT_no_up
        * UP held → accel
        ldd   LotusCarState.speed,u
        addd  #P1M_SPEED_ACCEL
        cmpd  #PHYS_MAX_SPEED
        bls   P1OT_speed_store
        ldd   #PHYS_MAX_SPEED
        bra   P1OT_speed_store
P1OT_no_up
        bita  #c1_button_down_mask
        beq   P1OT_coast
        * DOWN held → brake
        ldd   LotusCarState.speed,u
        subd  #P1M_SPEED_BRAKE
        bcc   P1OT_speed_store
        clra
        clrb                              ; speed = 0 (= clamp à 0)
        bra   P1OT_speed_store
P1OT_coast
        * neither → friction
        ldd   LotusCarState.speed,u
        beq   P1OT_speed_store            ; déjà à 0, skip
        subd  #P1M_SPEED_COAST
        bcc   P1OT_speed_store
        clra
        clrb
P1OT_speed_store
        std   LotusCarState.speed,u

        * --- (2) STEERING : LEFT → -, RIGHT → +, neither → toward 0 ---
        lda   LotusCarState.input_held,u
        ldb   LotusCarState.steering,u   ; B = current steering (signed 8)
        bita  #c1_button_left_mask
        beq   P1OT_no_steer_left
        * LEFT held → decrease (clamp à -MAX)
        subb  #P1M_STEER_RATE
        cmpb  #-P1M_STEER_MAX
        bge   P1OT_steer_store
        ldb   #-P1M_STEER_MAX
        bra   P1OT_steer_store
P1OT_no_steer_left
        bita  #c1_button_right_mask
        beq   P1OT_steer_center
        * RIGHT held → increase (clamp à +MAX)
        addb  #P1M_STEER_RATE
        cmpb  #P1M_STEER_MAX
        ble   P1OT_steer_store
        ldb   #P1M_STEER_MAX
        bra   P1OT_steer_store
P1OT_steer_center
        * No input → décay toward 0
        tstb
        beq   P1OT_steer_store
        bmi   P1OT_steer_c_neg
        * positive : descendre vers 0
        subb  #P1M_STEER_DECAY
        bpl   P1OT_steer_store
        clrb
        bra   P1OT_steer_store
P1OT_steer_c_neg
        * negative : remonter vers 0
        addb  #P1M_STEER_DECAY
        bmi   P1OT_steer_store
        clrb
P1OT_steer_store
        stb   LotusCarState.steering,u

        * --- (3) LATERAL_POS : += (steering × 12 × speed) >> 16 ---
        * Formule ★ conforme 68k FUN_75e30 : lateral_pos += steering × 12 × speed.
        * Le 68k fait l'accumulation en 32-bit fixed-point, on prend high word
        * pour delta integer (= range ±2 max par tick à full speed × full steer).
        *
        * Compute steering × 12 (signed 16-bit, range ±384) :
        ldb   LotusCarState.steering,u
        sex                               ; D = sign-extend B (= signed 16-bit)
        pshs  d                           ; save D (= steering × 1)
        aslb
        rola
        aslb
        rola                              ; D = steering × 4
        pshs  d                           ; save D × 4
        aslb
        rola                              ; D = steering × 8
        addd  ,s++                        ; D = D×8 + D×4 = D×12
        leas  2,s                         ; discard saved D × 1

        * D = steering × 12 (signed). Setup pour Mul16x16HiSigned :
        *   u = D (signed steering × 12)
        *   v = speed (unsigned, stocké à DFR_width_x2)
        * DFR_width_x2 sera réécrit per-scanline par DrawFrameRoad, safe ici.
        ldx   LotusCarState.speed,u
        stx   <DFR_width_x2               ; v = speed
        lbsr  Mul16x16HiSigned            ; D = (steering × 12 × speed) >> 16 signed

        * D = delta integer (= ±2 max à full).
        * Add to lateral_pos (= 16-bit signed à offset +2).
        addd  LotusCarState.lateral_pos+2,u

        * Clamp à ±P1M_LATERAL_MAX
        cmpd  #P1M_LATERAL_MAX
        ble   P1OT_lat_check_min
        ldd   #P1M_LATERAL_MAX
        bra   P1OT_lat_save
P1OT_lat_check_min
        cmpd  #-P1M_LATERAL_MAX
        bge   P1OT_lat_save
        ldd   #-P1M_LATERAL_MAX
P1OT_lat_save
        std   LotusCarState.lateral_pos+2,u
        rts


* ============================================================================
* P1M_apply_lateral — décompose lateral_pos (signed 16) en chunks + sub_pix
* lateral_pos ∈ [-95, +95] (= P1M_LATERAL_MAX).
* DFR_lateral_chunks_shift = lateral_pos >> 4 (= signed shift, range -5..+5).
* DFR_sub_pix = lateral_pos & 15 (= unsigned mod, 0..15).
* Décomposition cohérente : chunks × 16 + sub_pix = lateral_pos.
* ============================================================================
P1M_apply_lateral
        ldd   LotusCarState.lateral_pos+2,u   ; D = lateral_pos signed
        * Sub_pix = low nibble (= mod 16 en floor sense pour signed)
        pshs  b
        andb  #$0F
        stb   DFR_sub_pix
        puls  b
        * Chunks_shift = signed shift right 4
        asra
        rorb
        asra
        rorb
        asra
        rorb
        asra
        rorb
        stb   DFR_lateral_chunks_shift
        rts
