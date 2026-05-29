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

Road_draw_dispatch
* K=0  (J 0..5 existent, J6 = $0)
        fdb   Road_draw_K0_J0,Road_draw_K0_J1,Road_draw_K0_J2,Road_draw_K0_J3
        fdb   Road_draw_K0_J4,Road_draw_K0_J5,$0000
* K=1  (J 0..5 existent)
        fdb   Road_draw_K1_J0,Road_draw_K1_J1,Road_draw_K1_J2,Road_draw_K1_J3
        fdb   Road_draw_K1_J4,Road_draw_K1_J5,$0000
* K=2  (J 0..6 existent)
        fdb   Road_draw_K2_J0,Road_draw_K2_J1,Road_draw_K2_J2,Road_draw_K2_J3
        fdb   Road_draw_K2_J4,Road_draw_K2_J5,Road_draw_K2_J6
* K=3  (J 0..6 existent)
        fdb   Road_draw_K3_J0,Road_draw_K3_J1,Road_draw_K3_J2,Road_draw_K3_J3
        fdb   Road_draw_K3_J4,Road_draw_K3_J5,Road_draw_K3_J6
* K=4  (J 0..5)
        fdb   Road_draw_K4_J0,Road_draw_K4_J1,Road_draw_K4_J2,Road_draw_K4_J3
        fdb   Road_draw_K4_J4,Road_draw_K4_J5,$0000
* K=5  (J 0..4)
        fdb   Road_draw_K5_J0,Road_draw_K5_J1,Road_draw_K5_J2,Road_draw_K5_J3
        fdb   Road_draw_K5_J4,$0000,$0000
* K=6  (J 2..3 seulement)
        fdb   $0000,$0000,Road_draw_K6_J2,Road_draw_K6_J3
        fdb   $0000,$0000,$0000
* K=7  (aucun)
        fdb   $0000,$0000,$0000,$0000,$0000,$0000,$0000
* K=8  (aucun)
        fdb   $0000,$0000,$0000,$0000,$0000,$0000,$0000
* K=9  (aucun)
        fdb   $0000,$0000,$0000,$0000,$0000,$0000,$0000
* K=10 (J0 seul)
        fdb   Road_draw_K10_J0,$0000,$0000,$0000,$0000,$0000,$0000

 endc
