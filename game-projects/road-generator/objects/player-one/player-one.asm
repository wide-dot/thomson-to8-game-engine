; ============================================================================
; Object — PlayerOne
;
; Le pilote contrôlé par le joueur. L'état physique Lotus est dans
; PlayerOne_State (= zone résidente, struct LotusCarState 32 oct). L'OST
; player1 (= en DP $9F00) ne contient que le lifecycle standard ; le tick
; physique opère sur PlayerOne_State via U.
;
; Le Main routine drain le buffer d'input rempli par l'IRQ (= mécanique
; rtype). Chaque entrée = 1 tick physique exact (50 Hz), avec rattrapage
; si frame drop côté rendu.
;
; input REG : [u] pointer to Object Status Table (OST) — = player1 = dp
; ============================================================================

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/struct/LotusCarState.struct.asm"
        INCLUDE "./engine/physics/PhysicsTables.asm"
        INCLUDE "./objects/player-one/player-one.equ"

* ============================================================================
* Entry point — dispatch par routine ID
* ============================================================================
PlayerOne
        lda   player1+routine
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
        * --- Lifecycle OST : aucun sprite affiché pour cette phase ---
        lda   #ObjID_PlayerOne
        sta   player1+id
        clr   player1+priority

        * --- Init état Lotus (= valeurs de départ post-FUN_74eac) ---
        ldu   #PlayerOne_State

        * track_pos = 0 (32-bit cumulatif, on commence segment 0)
        ldd   #0
        std   LotusCarState.track_pos,u
        std   LotusCarState.track_pos+2,u

        * segment_idx = 0 (cache cohérent avec track_pos=0)
        std   LotusCarState.segment_idx,u

        * speed = 0
        std   LotusCarState.speed,u

        * gear = 0 (1ère vitesse)
        std   LotusCarState.gear,u

        * rpm = PHYS_RPM_MIN (1000)
        ldd   #PHYS_RPM_MIN
        std   LotusCarState.rpm,u

        * lateral_pos = 0 (centre route)
        clra
        clrb
        std   LotusCarState.lateral_pos,u
        std   LotusCarState.lateral_pos+2,u

        * steering = 0
        std   LotusCarState.steering,u
        std   LotusCarState.lat_impulse,u
        std   LotusCarState.lat_impulse_dir,u
        std   LotusCarState.event_flag,u
        std   LotusCarState.recovery_timer,u

        * max_speed = PHYS_MAX_SPEED (= $1AA = forward max)
        ldd   #PHYS_MAX_SPEED
        std   LotusCarState.max_speed,u

        * Inputs et flags = 0
        clra
        sta   LotusCarState.input_held,u
        sta   LotusCarState.input_last,u
        sta   LotusCarState.input_edges,u
        sta   LotusCarState.off_road,u
        clr   LotusCarState.gearbox_b0,u

        * Passe en routine Main
        lda   #PlayerOne_Main_routine
        sta   player1+routine
        rts

* ============================================================================
* Main — drain buffer input + 1 tick physique par entrée
* ============================================================================
* Pattern producteur-consommateur identique rtype/ApplyJoypadInput :
*   IRQ pousse 1 entrée par VBL → ici on draine tout ce qui a été poussé.
*   En cas de frame drop, le buffer accumule plusieurs entrées et on
*   rattrape en exécutant N ticks dans la même frame de rendu.
* ============================================================================
* NOTE lwasm 4.24 : la directive `struct` (LotusCarState) casse le scope
* des @-labels. Workaround : labels globaux préfixés `P1M_xxx`.
PlayerOne_Main
        ldu   #PlayerOne_State              ; convention : U = car state
P1M_loop
        jsr   lotus_input.get               ; A = next input ou $FF si vide
        cmpa  #$FF
        beq   P1M_done

        * --- Calcul edges : current AND (current XOR last) ---
        * Le held est mis à jour AVANT le calcul edges car on en a besoin
        * dans le XOR.
        sta   LotusCarState.input_held,u    ; held = current

        eora  LotusCarState.input_last,u    ; A = current XOR last
        anda  LotusCarState.input_held,u    ; A = current AND (current XOR last)
        sta   LotusCarState.input_edges,u   ; edges = "just pressed"

        * --- Stocke current → last pour le prochain tick ---
        lda   LotusCarState.input_held,u
        sta   LotusCarState.input_last,u

        * --- Tick physique complet (= port FUN_75e30 + crash wrapper) ---
        * NB : la maintenance de segment_idx (= cache modulo NB_SEGMENTS) est
        * intégrée à Lotus_PhysicsTick — pas besoin d'appel séparé.
        jsr   Lotus_PhysicsTick

        bra   P1M_loop
P1M_done
        rts
