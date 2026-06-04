 ifndef PerspectiveTables_included
PerspectiveTables_included equ 1
* ======================================================================
* PerspectiveTables.asm — TABLES PERSPECTIVE PRÉCALCULÉES
* 
* Extraites de FILE59.bin (= FILE59.SCR décompressé) par
* tools/extract_perspective_tables.py.
* 
* Layout source ST :
*   FILE59 chargé à $2FD40
*   1/n × k tables : $2FD80 (8 groupes × 128 longs)
*   Y horizon      : $30D40 (128 mots signés)
*   Scaling factor : $30E40 (128 mots signés)
* 
* Conversion TO8 : aucune (= ratios + coord Y, dimensions verticales
* identiques 200 lignes ST/TO8 ; pas d'axe horizontal X à halver ici).
* 
* Référence 68000 : CARS.REL.asm.txt FUN_78a98 (= ram:$78a98, off $8698)
* ======================================================================

* ──────────────────────────────────────────────────────────────────────
* Persp_Horizon — Y horizon par ligne (128 mots, courbe 1/Z)
*   Migré dans Persp_Recip_paged.bin à $5E00 (Option A : persp packé après
*   les patterns dans la demi-page → base $5200 au lieu de $5000).
*   Lue par SparseProjection : ldu #Persp_Horizon ; 256,u = Persp_Scaling
*   Valeurs (= référence) : 95, 85, 78, 73, 69, 66, 63, 61, ...
* ──────────────────────────────────────────────────────────────────────
Persp_Horizon                   equ $5E00           ; 256 oct (128 mots)

* ──────────────────────────────────────────────────────────────────────
* Persp_Scaling — facteur scaling par ligne (128 mots, décroît 4095→160)
*   Migré dans Persp_Recip_paged.bin à $5F00.
*   Lue par SparseProjection (via 256,u).
*   Valeurs (= référence) : 4095, 3420, 2944, 2584, 2302, 2076, 1891, 1735, ...
* ──────────────────────────────────────────────────────────────────────
Persp_Scaling                   equ $5F00           ; 256 oct (128 mots)

* ──────────────────────────────────────────────────────────────────────
* FILE59 step LUT — TABLE 2-TIER COMPACTÉE (PAGÉE)
*
*   (Option A : base $5200 au lieu de $5000 — persp packé après les 4497 o de
*    patterns dans la demi-page $4000-$5FFF, padding 512 o retiré.)
*   $5200..$55FF  Plage A : entries 0..511 packed 2 oct/entry
*   $5600..$5DFF  Plage B : entries 512..1023 full 4 oct/entry
*   $5E00..$5FFF  Persp_Horizon + Persp_Scaling (= migrés du résident)
*   (fin = $5FFF = bord demi-page ; 0 padding)
*
* Génération : tools/build_persp_recip_paged.py (RUNTIME_BASE=$5200)
* Consommation : LinearInterp.asm via dispatch cmpd #LI_PLAGE_BOUNDARY
* ──────────────────────────────────────────────────────────────────────
LI_TABLE_A_BASE                 equ $5200
LI_TABLE_B_BASE                 equ $5600
LI_PLAGE_BOUNDARY               equ 512

* ──────────────────────────────────────────────────────────────────────
* A4_table — précomputed depth dither step (= floor(256/N))
*   Equivalent au calcul 68k : A4 = (1/N × 2^20 × 16) >> 16 = 256/N
*   Indexed by N = nombre de lignes interp. Valeurs ∈ [4..128] → 8 bits.
*   N=0,1 : path delta_zero/delta_one (jamais utilisé multi-line).
* ──────────────────────────────────────────────────────────────────────
A4_table
        fcb   $00,$00,$80,$55,$40,$33,$2A,$24    ; N= 0.. 7 :   0   0 128  85  64  51  42  36
        fcb   $20,$1C,$19,$17,$15,$13,$12,$11    ; N= 8..15 :  32  28  25  23  21  19  18  17
        fcb   $10,$0F,$0E,$0D,$0C,$0C,$0B,$0B    ; N=16..23 :  16  15  14  13  12  12  11  11
        fcb   $0A,$0A,$09,$09,$09,$08,$08,$08    ; N=24..31 :  10  10   9   9   9   8   8   8
        fcb   $08,$07,$07,$07,$07,$06,$06,$06    ; N=32..39 :   8   7   7   7   7   6   6   6
        fcb   $06,$06,$06,$05,$05,$05,$05,$05    ; N=40..47 :   6   6   6   5   5   5   5   5
        fcb   $05,$05,$05,$05,$04,$04,$04,$04    ; N=48..55 :   5   5   5   5   4   4   4   4
        fcb   $04,$04,$04,$04,$04,$04,$04,$04    ; N=56..63 :   4   4   4   4   4   4   4   4

 endc
