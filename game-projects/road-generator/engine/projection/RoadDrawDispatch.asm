        opt   c
 ifndef RoadDrawDispatch_included
RoadDrawDispatch_included equ 1

* ======================================================================
* RoadDrawDispatch.asm — TABLE DISPATCH K' × J' → Road_draw_K{K'}_J{J'}
*
* Dispatch indexé par (K', J') vers les 40 routines Road_draw_K?_J? pré-
* déroulées dans la pattern bank ($48A9-$4D64).
*
* Format : 11 × 7 × 2 oct = 154 oct
* Index   : (K' × 7 + J') × 2
*   K' ∈ [0..10], J' ∈ [0..6]
*   $0000 pour les combinaisons non implémentées (= sécurité skip).
*
* Une Road_draw_K{K'}_J{J'} fait :
*   ldd #grass_d ; ldx #grass_x ; pshu d,x × K'   ; préambule herbe
*   jsr [,Y++] × F                                 ; cœur road (F = 10-K'-J')
*   ldd #grass_d ; ldx #grass_x ; pshu d,x × J'   ; postlude herbe
*   rts
*
* Caller (DrawFrameRoad) :
*   ldy   Road_lines + 8×line_idx + 2×variant       ; ptr Line_NNNN
*   lda   ,y                                         ; A = K
*   ldb   1,y                                        ; B = M
*   ; calcule K' = min(10, K), J' = max(0, 10-K-M)
*   leay  3,y                                        ; Y → cœur (entry_idx=0)
*   ; lookup dispatch[K'×7 + J'], jsr indirect
* ======================================================================

* NB : road_patterns_externs.inc est inclus depuis main.asm en amont
* (= fournit les EQU Road_draw_K{X}_J{Y}). Pas d'include local pour
* éviter "Multiply defined symbol".
*
* Les 77 entrées fdb sont AUTO-GÉNÉRÉES par compile_road_sprites_ram.py
* en fonction du variant_set utilisé. $0000 pour les (K',J') non utilisés.

Road_draw_dispatch
        INCLUDE "./game-mode/road/generated/road_draw_dispatch.asm"

 endc
