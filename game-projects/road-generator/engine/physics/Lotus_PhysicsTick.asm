        INCLUDE "./engine/physics/PhysicsTables.asm"
        INCLUDE "./engine/struct/LotusCarState.struct.asm"

; ============================================================================
; Lotus_PhysicsTick — STUB
;
; Port à venir de FUN_00075e30 / FUN_00075dec (= corps physique central +
; wrapper crash). Voir lotus-ste/doc/extraction/21_TICK_PHYSIQUE_JOUEUR.md
; pour le pseudo-C détaillé et les constantes (PHYS_* dans PhysicsTables.asm).
;
; CONVENTION :
;   input  : U = pointer LotusCarState (player1 ou AI car)
;   uses   : tous registres ; sauvegarder via PSHS si appelant en a besoin
;   output : LotusCarState fields à u mis à jour
;
; ÉTAT actuel : STUB minimal — fait juste un track_pos += speed pour pouvoir
; tester le streaming circuit. Les sections complètes (steering, RPM, engine
; torque, brake, gear-shift) seront ajoutées section par section.
;
; NOTE lwasm 4.24 : on évite les @-locales dans cette routine car la directive
; `struct` (cf. LotusCarState.struct.asm) casse le scope des @-labels.
; Workaround : labels globaux préfixés `LPT_xxx` (= Lotus_PhysicsTick_xxx).
; ============================================================================

Lotus_PhysicsTick
        * --- STUB minimal pour valider le pipeline ---
        * track_pos += sign_extend(speed) (= portion forward de FUN_760ae)
        *
        * Pour tester sans physique input : si bit 3 (UP) pressé,
        * incrémenter speed de 1, sinon décrémenter. Permettra de voir
        * le pointeur segment avancer/reculer au debugger.

        * --- TEST : speed += 1 si UP pressé, -= 1 si DOWN, clamp à 0 ---
        lda   LotusCarState.input_held,u
        bita  #%00001000                  ; UP ?
        beq   LPT_no_up
        ldd   LotusCarState.speed,u
        addd  #1
        cmpd  #PHYS_MAX_SPEED
        ble   LPT_save_spd
        ldd   #PHYS_MAX_SPEED
LPT_save_spd
        std   LotusCarState.speed,u
        bra   LPT_do_track
LPT_no_up
        bita  #%00000100                  ; DOWN ?
        beq   LPT_do_track
        ldd   LotusCarState.speed,u
        beq   LPT_do_track
        subd  #1
        bmi   LPT_clamp_zero
        std   LotusCarState.speed,u
        bra   LPT_do_track
LPT_clamp_zero
        ldd   #0
        std   LotusCarState.speed,u

LPT_do_track
        * --- track_pos (32-bit) += sign_extend(speed) (16-bit signed) ---
        * D += speed_signed sur 32 bits :
        *   low_word += speed_low (with carry)
        *   high_word += sign_extension_of_speed + carry_from_low
        ldd   LotusCarState.speed,u       ; D = speed (signed)
        addd  LotusCarState.track_pos+2,u ; D = low_word + speed (carry set if overflow)
        std   LotusCarState.track_pos+2,u ; store low_word

        * Carry propagation au high word :
        ldd   LotusCarState.track_pos,u   ; D = high_word
        adcb  #0                          ; +carry from low add
        adca  #0                          ; (mais pas de carry d'addB→A car +0)
        * Sign extension de speed (si speed négative, retrancher 1 du high) :
        * Pour rester simple ici on assume speed >= 0 (test phase).
        std   LotusCarState.track_pos,u

        rts
