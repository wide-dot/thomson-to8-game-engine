; ============================================================================
; Object — AiCar (MOCK, pas activé pour l'instant)
;
; Voiture concurrente IA, mock préservant l'analyse Lotus pour la suite.
; PAS référencée dans main.properties — fichier présent pour future activation.
;
; Pattern :
;   - 1 OST par AI car (= dans Dynamic_Object_RAM)
;   - ext_variables[ai_car_state_ptr] pointe sur sa slot dans AI_States[]
;   - Le tick AI lit ext_variables, charge U avec le state_ptr, et appelle
;     Lotus_PhysicsTick (= même code que Player1, juste U différent)
;   - Spacing : car lit AI_States[i-1] (= state_ptr - sizeof{LotusCarState})
;
; Cross-deps documentées (reverse Lotus FUN_00075c36, FUN_000795f2) :
;   - Player1 collision-scan LIT toutes les AI cars (lateral, track_pos)
;   - Player collision peut ÉCRIRE sur AI car (lateral, velocity)
;   - AI update LIT car précédente pour spacing
;
; input REG : [u] pointer to Object Status Table (OST)
; ============================================================================

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/struct/LotusCarState.struct.asm"
        INCLUDE "./engine/physics/PhysicsTables.asm"
        INCLUDE "./objects/ai-car/ai-car.equ"

AiCar
        lda   routine,u
        asla
        ldx   #AiCar_Routines
        jmp   [a,x]

AiCar_Routines
        fdb   AiCar_Init
        fdb   AiCar_Main

* ============================================================================
* Init — initialise une AI car
* ============================================================================
* À appeler avec subtype = index 0..AI_NB_CARS-1 (configuré au LoadObject).
* Calcule state_ptr = AI_States + (index × sizeof{LotusCarState}) et stocke.
AiCar_Init
        * --- Récupère index depuis subtype et stocke dans ai_car_index ---
        lda   subtype,u
        sta   ai_car_index,u

        * --- Calcule state_ptr = AI_States + index × sizeof{LotusCarState} ---
        ldb   #sizeof{LotusCarState}
        mul                                  ; D = index × size
        addd  #AI_States                     ; D = &AI_States[index]
        std   ai_car_state_ptr,u

        * --- Init state dans AI_States[index] ---
        pshs  u                              ; save OST u
        ldu   ai_car_state_ptr,u             ; u = AI_States[index]

        ldd   #0
        std   LotusCarState.speed,u
        std   LotusCarState.steering,u
        std   LotusCarState.gear,u
        std   LotusCarState.lat_impulse,u
        std   LotusCarState.lat_impulse_dir,u
        std   LotusCarState.event_flag,u
        std   LotusCarState.recovery_timer,u
        std   LotusCarState.lateral_pos,u
        std   LotusCarState.lateral_pos+2,u
        std   LotusCarState.track_pos,u
        std   LotusCarState.track_pos+2,u

        ldd   #PHYS_RPM_MIN
        std   LotusCarState.rpm,u

        ldd   #PHYS_MAX_SPEED
        std   LotusCarState.max_speed,u

        clra
        sta   LotusCarState.input_held,u
        sta   LotusCarState.input_last,u
        sta   LotusCarState.input_edges,u
        sta   LotusCarState.off_road,u
        clr   LotusCarState.gearbox_b0,u

        puls  u                              ; restore OST u
        inc   routine,u
        rts

* ============================================================================
* Main — un tick AI (= équivalent FUN_000795f2 simplifié pour ce mock)
* ============================================================================
* Pour cette phase mock : NE FAIT RIEN. Préservation de la structure pour
* implémenter plus tard la physique AI réelle (avec spacing previous-car,
* target speed depuis circuit, etc.).
AiCar_Main
        * Mock : charge U avec ma state, appellerait Lotus_PhysicsTick.
        * Désactivé volontairement pour cette phase.
        ; ldu   ai_car_state_ptr,u
        ; jsr   Lotus_PhysicsTick
        ; jsr   Circuit_step           ; sa propre progression circuit
        rts
