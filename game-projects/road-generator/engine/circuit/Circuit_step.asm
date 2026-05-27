        INCLUDE "./engine/struct/LotusCarState.struct.asm"

; ============================================================================
; Circuit_step — avance le pointeur de segment selon track_pos
;
; Équivalent du calcul de doc 11_circuit_format_CONFIRMED.md :
;
;     pbVar16 = $31140 + (yaw_high % NB_SEGMENTS) × 16
;
; où yaw_high = high word de track_pos (= struct[+0x04] >> 16).
;
; input :
;   U = pointer LotusCarState (player ou AI)
;   Circuit_base = pointeur DIRECT sur le premier segment du circuit
;                  (= jump_table[+2], résolu par main.asm au chargement)
;   Circuit_nb_segments = N segments du circuit
;
; output :
;   Current_segment_ptr = pointeur sur le segment actif
;
; Format Circuit (cf. tools/generate_circuits.py) :
;   +0..1   fdb → ptr nb_segments
;   +2..3   fdb → ptr segments       <- Circuit_base pointe ICI au runtime
;   +4..5   nb_segments
;   +6..    segments × 16 oct (8 dupliqués à la fin pour wraparound)
;   (palette ST commentée — pas chargée au runtime)
;
; NOTE lwasm 4.24 : la directive `struct` (LotusCarState) casse le scope
; des @-labels. Workaround : labels globaux préfixés `CS_xxx`.
;
; Coût : ~50 cycles (multiplication 16x16 → modulo).
; ============================================================================

CIRCUIT_SEGMENT_SIZE         equ 16

Circuit_step
        * --- D = high word de track_pos (segment idx cumulé + fraction) ---
        ldd   LotusCarState.track_pos,u    ; D = track_pos high word
        * Calcule segment_idx = D mod NB_SEGMENTS.
        * Sur 6809 pas de divu 32/16 natif → boucle de soustraction.
        * (Optimisable plus tard avec div binaire si nécessaire.)

CS_neg_check
        tsta                                ; si D < 0, ajouter NB_SEGMENTS
        bge   CS_pos_loop
        addd  Circuit_nb_segments
        bra   CS_neg_check

CS_pos_loop
        cmpd  Circuit_nb_segments
        blo   CS_done_mod
        subd  Circuit_nb_segments
        bra   CS_pos_loop

CS_done_mod
        * D = segment_idx ∈ [0, NB_SEGMENTS[
        * Calcule offset bytes = D × 16
        aslb                              ; ×2
        rola
        aslb                              ; ×4
        rola
        aslb                              ; ×8
        rola
        aslb                              ; ×16
        rola
        ; D = segment_idx × 16

        addd  Circuit_base                ; + base segments = pointeur final
        std   Current_segment_ptr
        rts
