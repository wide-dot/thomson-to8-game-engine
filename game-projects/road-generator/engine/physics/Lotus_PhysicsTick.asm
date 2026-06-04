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
        * --- track_pos += 5 × speed (= conforme 68k FUN_760ae $7610A..$76112) ---
        * Le 68k fait 5 × `add.l D0, D4` où D0 = speed × gear_factor (à (0x12,A4)).
        * Notre STUB n'a pas encore le gear_factor → on utilise 5 × speed direct.
        * Quand le port physique complet (= gear/torque/RPM) sera fait, on
        * remplacera par muls(speed, gear_factor) × 5.
        *
        * Math : pour PHYS_MAX_SPEED = $1AA, 5× = $852. Fits in 16-bit.
        * Pas d'overflow possible si speed ∈ [0..$1AA] (= 5*$1AA = $852 < $FFFF).
        ldd   LotusCarState.speed,u       ; D = speed
        aslb
        rola                              ; D = speed × 2
        aslb
        rola                              ; D = speed × 4
        addd  LotusCarState.speed,u       ; D = speed × 5
        addd  LotusCarState.track_pos+2,u ; D = low_word + 5*speed
        std   LotusCarState.track_pos+2,u
        bcc   LPT_no_seg_advance          ; pas d'overflow → segment inchangé

        * --- Carry du low-word → high_word += 1 + segment_idx += 1 (wrap N) ---
        * On ne remet pas à jour le high_word pour servir d'index (segment_idx
        * sert pour ça). Mais on le maintient quand même = somme cumulative
        * pure (utile pour distance/temps si on en a besoin plus tard).
        ldd   LotusCarState.track_pos,u
        addd  #1
        std   LotusCarState.track_pos,u

        * segment_idx = (segment_idx + 1) mod NB_SEGMENTS
        * (Le cas où speed est si grand que low_word fait plusieurs overflow
        *  ne se produit pas : speed est borné à PHYS_MAX_SPEED = $1AA < $10000,
        *  donc un seul franchissement de segment par tick max.)
        ldd   LotusCarState.segment_idx,u
        addd  #1
        cmpd  Circuit_nb_segments
        blo   LPT_save_seg_idx
        ldd   #0                          ; wrap
LPT_save_seg_idx
        std   LotusCarState.segment_idx,u

LPT_no_seg_advance
        * Note : speed forward toujours >= 0 dans cette phase test.
        * Quand on portera le tick complet, le crash peut produire speed négative
        * → il faudra alors décrémenter segment_idx sur borrow (avec wrap +N).
        rts
