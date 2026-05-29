* ======================================================================
* Circuit_08_medium_1 — N=172 segments (format compact 8 oct/seg)
* Source       : 08_medium_1.bin (extrait de FILE30)
*
* Pays         : THAILAND
* Lieu         : muang khammouan
* Description  : rolling hills and
* Hazards      : sweeping bends
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000048 01:#909024 02:#6C6C24 03:#484824 04:#244824 05:#B40000 06:#242400 07:#242400
*   08:#242424 09:#D8D8D8 10:#242424 11:#FCFCFC 12:#2400FC 13:#2424FC 14:#2448FC 15:#2448FC
*   16:#246CFC 17:#246CFC 18:#2490D8 19:#4890B4 20:#6CB490 21:#90B46C 22:#B4D848 23:#B4D848
*   24:#D8FC24 25:#D8FC00 26:#FCFC48 27:#FCFC6C
* Palette base : mots [00..15]
* Sky gradient : mots [16..27]
*
* === Format segment compact 8 oct (vs 16 oct Lotus 68k original) ===
*   +0  curve_raw   bit 7 = PIT flag, bits 0-6 = delta_curve 7-bit signed
*   +1  pitch_raw   bit 7 = START flag, bits 0-6 = delta_pitch 7-bit signed
*   +2  spr01       (sprite_idx_1 << 4) | sprite_idx_0  ← index 4-bit dans LUT
*   +3  spr23       (sprite_idx_3 << 4) | sprite_idx_2
*   +4  lat_0       int8 signed (sprite 0 lateral position)
*   +5  lat_1       int8 signed
*   +6  lat_2       int8 signed
*   +7  lat_3       int8 signed
*
* PIT/START flags : extraits par SparseProjection.asm via bit 7 des
* bytes curve_raw/pitch_raw. PIT présent dans le source ; START forcé
* sur segment 0 uniquement (= équivalent FUN_40B4 race-init du 68k).
*
* Sprite_LUT : index 0 = 'pas de sprite'. Indices 1..15 = sprite_id réel
* (= FILExx.SCR à charger via add_file). Indexation 4-bit (max 16 IDs
* par circuit ; ce circuit : 9 entries utilisées).
*
* === Table parallèle Circuit_xx_segment_cache (4 oct/seg) ===
* Pré-calculée à la génération (vs Loop 1/2/3 de FUN_74dac runtime 68k).
*   +0  yaw_abs    : cumul delta_curve mod 256, signed
*                   → futur : Lotus_PhysicsTick + AI cars
*   +1  pitch_abs  : cumul delta_pitch mod 256, signed
*                   → futur : Lotus_PhysicsTick complet (suspension/pentes)
*   +2  min_lat    : rightmost negative sprite lat + 8, smoothed backward
*                   → futur : DRAW_SPRITES culling horizontal gauche
*   +3  max_lat    : leftmost positive sprite lat - 8, smoothed backward
*                   → futur : DRAW_SPRITES culling horizontal droite
* Adressage cache : Circuit_xx_segment_cache + idx × 4 (= ×4 simple).
*
* 8 segments wraparound dupliqués à la fin pour look-ahead
* projection sans wrap mod N (segments + cache).
* Taille totale : 2178 oct (nb_segments 2 + LUT 16 + segments 1440 + cache 720).
* ======================================================================

Circuit_08_medium_1_nb_segments
        fdb   172

Circuit_08_medium_1_sprite_lut
        fcb   $00,$82,$A2,$83,$A5,$80,$AB,$81,$85,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_08_medium_1_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$20,$00,$00,$28,$00,$00  ; seg   1                                    #1:$A2@+40
        fcb   $00,$00,$20,$00,$00,$30,$00,$00  ; seg   2                                    #1:$A2@+48
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$23,$03,$12,$DC,$12,$00  ; seg   5                                    #0:$83@+18 #1:$A2@-36 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$20,$00,$00,$CC,$00,$00  ; seg   8                      flags=[PIT]   #1:$A2@-52
        fcb   $80,$00,$20,$00,$00,$D4,$00,$00  ; seg   9                      flags=[PIT]   #1:$A2@-44
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  10                      flags=[PIT]
        fcb   $80,$00,$20,$00,$00,$E4,$00,$00  ; seg  11                      flags=[PIT]   #1:$A2@-28
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  12                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  13                      flags=[PIT]
        fcb   $80,$00,$20,$00,$00,$E8,$00,$00  ; seg  14                      flags=[PIT]   #1:$A2@-24
        fcb   $80,$00,$20,$00,$00,$30,$00,$00  ; seg  15                      flags=[PIT]   #1:$A2@+48
        fcb   $00,$00,$00,$40,$00,$00,$00,$D0  ; seg  16                                    #3:$A5@-48
        fcb   $00,$00,$00,$40,$00,$00,$00,$C8  ; seg  17                                    #3:$A5@-56
        fcb   $00,$01,$05,$45,$12,$00,$12,$E0  ; seg  18            pitch=+1                #0:$80@+18 #2:$80@+18 #3:$A5@-32
        fcb   $00,$01,$05,$05,$12,$00,$12,$00  ; seg  19            pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $05,$01,$05,$40,$12,$00,$00,$E4  ; seg  20  curve=+5  pitch=+1                #0:$80@+18 #3:$A5@-28
        fcb   $05,$01,$05,$40,$12,$00,$00,$D8  ; seg  21  curve=+5  pitch=+1                #0:$80@+18 #3:$A5@-40
        fcb   $05,$00,$25,$00,$12,$DC,$00,$00  ; seg  22  curve=+5                          #0:$80@+18 #1:$A2@-36
        fcb   $05,$00,$05,$40,$12,$00,$00,$EC  ; seg  23  curve=+5                          #0:$80@+18 #3:$A5@-20
        fcb   $05,$00,$05,$40,$12,$00,$00,$E4  ; seg  24  curve=+5                          #0:$80@+18 #3:$A5@-28
        fcb   $05,$00,$05,$40,$12,$00,$00,$E8  ; seg  25  curve=+5                          #0:$80@+18 #3:$A5@-24
        fcb   $05,$00,$05,$40,$12,$00,$00,$28  ; seg  26  curve=+5                          #0:$80@+18 #3:$A5@+40
        fcb   $05,$00,$25,$00,$12,$E8,$00,$00  ; seg  27  curve=+5                          #0:$80@+18 #1:$A2@-24
        fcb   $05,$00,$05,$40,$12,$00,$00,$30  ; seg  28  curve=+5                          #0:$80@+18 #3:$A5@+48
        fcb   $05,$00,$05,$40,$12,$00,$00,$D8  ; seg  29  curve=+5                          #0:$80@+18 #3:$A5@-40
        fcb   $05,$00,$25,$00,$12,$DC,$00,$00  ; seg  30  curve=+5                          #0:$80@+18 #1:$A2@-36
        fcb   $05,$00,$05,$40,$12,$00,$00,$CC  ; seg  31  curve=+5                          #0:$80@+18 #3:$A5@-52
        fcb   $05,$7F,$05,$40,$12,$00,$00,$E0  ; seg  32  curve=+5  pitch=-1                #0:$80@+18 #3:$A5@-32
        fcb   $05,$7F,$05,$40,$12,$00,$00,$E4  ; seg  33  curve=+5  pitch=-1                #0:$80@+18 #3:$A5@-28
        fcb   $05,$7F,$00,$40,$00,$00,$00,$D8  ; seg  34  curve=+5  pitch=-1                #3:$A5@-40
        fcb   $05,$7F,$00,$40,$00,$00,$00,$E4  ; seg  35  curve=+5  pitch=-1                #3:$A5@-28
        fcb   $00,$7E,$26,$00,$12,$EC,$00,$00  ; seg  36            pitch=-2                #0:$AB@+18 #1:$A2@-20
        fcb   $00,$7E,$06,$40,$12,$00,$00,$EC  ; seg  37            pitch=-2                #0:$AB@+18 #3:$A5@-20
        fcb   $00,$7E,$06,$40,$12,$00,$00,$E0  ; seg  38            pitch=-2                #0:$AB@+18 #3:$A5@-32
        fcb   $00,$7E,$26,$00,$12,$30,$00,$00  ; seg  39            pitch=-2                #0:$AB@+18 #1:$A2@+48
        fcb   $00,$02,$06,$40,$12,$00,$00,$30  ; seg  40            pitch=+2                #0:$AB@+18 #3:$A5@+48
        fcb   $00,$02,$26,$00,$12,$D8,$00,$00  ; seg  41            pitch=+2                #0:$AB@+18 #1:$A2@-40
        fcb   $00,$02,$06,$40,$12,$00,$00,$D8  ; seg  42            pitch=+2                #0:$AB@+18 #3:$A5@-40
        fcb   $00,$02,$06,$40,$12,$00,$00,$E0  ; seg  43            pitch=+2                #0:$AB@+18 #3:$A5@-32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  44
        fcb   $00,$00,$00,$40,$00,$00,$00,$20  ; seg  45                                    #3:$A5@+32
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  46                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  47                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$07,$47,$EE,$00,$EE,$14  ; seg  48  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A5@+20
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  49  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$40,$00,$00,$00,$1C  ; seg  50  curve=-6                          #3:$A5@+28
        fcb   $7A,$00,$00,$40,$00,$00,$00,$18  ; seg  51  curve=-6                          #3:$A5@+24
        fcb   $00,$00,$00,$40,$00,$00,$00,$28  ; seg  52                                    #3:$A5@+40
        fcb   $00,$00,$20,$00,$00,$20,$00,$00  ; seg  53                                    #1:$A2@+32
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  54                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  55                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  56  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$47,$EE,$00,$EE,$14  ; seg  57  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A5@+20
        fcb   $7A,$00,$20,$40,$00,$20,$00,$E0  ; seg  58  curve=-6                          #1:$A2@+32 #3:$A5@-32
        fcb   $7A,$00,$00,$40,$00,$00,$00,$CC  ; seg  59  curve=-6                          #3:$A5@-52
        fcb   $00,$01,$06,$40,$12,$00,$00,$E4  ; seg  60            pitch=+1                #0:$AB@+18 #3:$A5@-28
        fcb   $00,$01,$06,$40,$12,$00,$00,$28  ; seg  61            pitch=+1                #0:$AB@+18 #3:$A5@+40
        fcb   $00,$01,$26,$00,$12,$D0,$00,$00  ; seg  62            pitch=+1                #0:$AB@+18 #1:$A2@-48
        fcb   $00,$01,$06,$40,$12,$00,$00,$30  ; seg  63            pitch=+1                #0:$AB@+18 #3:$A5@+48
        fcb   $00,$01,$06,$40,$12,$00,$00,$D0  ; seg  64            pitch=+1                #0:$AB@+18 #3:$A5@-48
        fcb   $00,$01,$06,$40,$12,$00,$00,$E4  ; seg  65            pitch=+1                #0:$AB@+18 #3:$A5@-28
        fcb   $00,$01,$06,$40,$EE,$00,$00,$20  ; seg  66            pitch=+1                #0:$AB@-18 #3:$A5@+32
        fcb   $00,$01,$06,$40,$EE,$00,$00,$1C  ; seg  67            pitch=+1                #0:$AB@-18 #3:$A5@+28
        fcb   $00,$7E,$26,$00,$EE,$20,$00,$00  ; seg  68            pitch=-2                #0:$AB@-18 #1:$A2@+32
        fcb   $00,$7E,$06,$40,$EE,$00,$00,$30  ; seg  69            pitch=-2                #0:$AB@-18 #3:$A5@+48
        fcb   $00,$7E,$06,$40,$EE,$00,$00,$DC  ; seg  70            pitch=-2                #0:$AB@-18 #3:$A5@-36
        fcb   $00,$7E,$26,$00,$EE,$18,$00,$00  ; seg  71            pitch=-2                #0:$AB@-18 #1:$A2@+24
        fcb   $00,$00,$00,$40,$00,$00,$00,$E0  ; seg  72                                    #3:$A5@-32
        fcb   $00,$00,$00,$40,$00,$00,$00,$D0  ; seg  73                                    #3:$A5@-48
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  74                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$45,$12,$00,$12,$CC  ; seg  75                                    #0:$80@+18 #2:$80@+18 #3:$A5@-52
        fcb   $06,$00,$05,$40,$12,$00,$00,$E4  ; seg  76  curve=+6                          #0:$80@+18 #3:$A5@-28
        fcb   $06,$00,$25,$00,$12,$E0,$00,$00  ; seg  77  curve=+6                          #0:$80@+18 #1:$A2@-32
        fcb   $06,$00,$05,$40,$12,$00,$00,$EC  ; seg  78  curve=+6                          #0:$80@+18 #3:$A5@-20
        fcb   $06,$00,$05,$00,$12,$00,$00,$00  ; seg  79  curve=+6                          #0:$80@+18
        fcb   $06,$00,$05,$40,$12,$00,$00,$E0  ; seg  80  curve=+6                          #0:$80@+18 #3:$A5@-32
        fcb   $06,$00,$05,$40,$12,$00,$00,$DC  ; seg  81  curve=+6                          #0:$80@+18 #3:$A5@-36
        fcb   $06,$00,$00,$40,$00,$00,$00,$E8  ; seg  82  curve=+6                          #3:$A5@-24
        fcb   $06,$00,$20,$00,$00,$EC,$00,$00  ; seg  83  curve=+6                          #1:$A2@-20
        fcb   $00,$00,$06,$40,$EE,$00,$00,$CC  ; seg  84                                    #0:$AB@-18 #3:$A5@-52
        fcb   $00,$00,$06,$40,$EE,$00,$00,$E4  ; seg  85                                    #0:$AB@-18 #3:$A5@-28
        fcb   $00,$00,$06,$40,$EE,$00,$00,$D8  ; seg  86                                    #0:$AB@-18 #3:$A5@-40
        fcb   $00,$00,$06,$40,$EE,$00,$00,$E8  ; seg  87                                    #0:$AB@-18 #3:$A5@-24
        fcb   $00,$7F,$06,$40,$EE,$00,$00,$2C  ; seg  88            pitch=-1                #0:$AB@-18 #3:$A5@+44
        fcb   $00,$7F,$06,$40,$EE,$00,$00,$18  ; seg  89            pitch=-1                #0:$AB@-18 #3:$A5@+24
        fcb   $00,$7F,$06,$40,$EE,$00,$00,$D0  ; seg  90            pitch=-1                #0:$AB@-18 #3:$A5@-48
        fcb   $00,$7F,$26,$00,$EE,$20,$00,$00  ; seg  91            pitch=-1                #0:$AB@-18 #1:$A2@+32
        fcb   $00,$00,$06,$40,$12,$00,$00,$C8  ; seg  92                                    #0:$AB@+18 #3:$A5@-56
        fcb   $00,$00,$06,$40,$12,$00,$00,$E8  ; seg  93                                    #0:$AB@+18 #3:$A5@-24
        fcb   $00,$00,$06,$40,$12,$00,$00,$E4  ; seg  94                                    #0:$AB@+18 #3:$A5@-28
        fcb   $00,$00,$06,$40,$12,$00,$00,$30  ; seg  95                                    #0:$AB@+18 #3:$A5@+48
        fcb   $00,$00,$06,$40,$12,$00,$00,$E0  ; seg  96                                    #0:$AB@+18 #3:$A5@-32
        fcb   $00,$00,$06,$40,$12,$00,$00,$EC  ; seg  97                                    #0:$AB@+18 #3:$A5@-20
        fcb   $00,$00,$06,$40,$12,$00,$00,$E0  ; seg  98                                    #0:$AB@+18 #3:$A5@-32
        fcb   $00,$00,$06,$40,$12,$00,$00,$28  ; seg  99                                    #0:$AB@+18 #3:$A5@+40
        fcb   $00,$00,$26,$00,$EE,$18,$00,$00  ; seg 100                                    #0:$AB@-18 #1:$A2@+24
        fcb   $00,$00,$06,$40,$EE,$00,$00,$1C  ; seg 101                                    #0:$AB@-18 #3:$A5@+28
        fcb   $00,$00,$26,$00,$EE,$20,$00,$00  ; seg 102                                    #0:$AB@-18 #1:$A2@+32
        fcb   $00,$00,$06,$40,$EE,$00,$00,$20  ; seg 103                                    #0:$AB@-18 #3:$A5@+32
        fcb   $00,$01,$06,$40,$EE,$00,$00,$30  ; seg 104            pitch=+1                #0:$AB@-18 #3:$A5@+48
        fcb   $00,$01,$06,$40,$EE,$00,$00,$20  ; seg 105            pitch=+1                #0:$AB@-18 #3:$A5@+32
        fcb   $00,$01,$06,$00,$EE,$00,$00,$00  ; seg 106            pitch=+1                #0:$AB@-18
        fcb   $00,$01,$06,$40,$EE,$00,$00,$1C  ; seg 107            pitch=+1                #0:$AB@-18 #3:$A5@+28
        fcb   $00,$00,$20,$40,$00,$20,$00,$14  ; seg 108                                    #1:$A2@+32 #3:$A5@+20
        fcb   $00,$00,$20,$00,$00,$E0,$00,$00  ; seg 109                                    #1:$A2@-32
        fcb   $00,$00,$05,$45,$12,$00,$12,$E0  ; seg 110                                    #0:$80@+18 #2:$80@+18 #3:$A5@-32
        fcb   $00,$00,$05,$45,$12,$00,$12,$DC  ; seg 111                                    #0:$80@+18 #2:$80@+18 #3:$A5@-36
        fcb   $04,$00,$05,$40,$12,$00,$00,$24  ; seg 112  curve=+4                          #0:$80@+18 #3:$A5@+36
        fcb   $04,$00,$25,$00,$12,$E0,$00,$00  ; seg 113  curve=+4                          #0:$80@+18 #1:$A2@-32
        fcb   $04,$00,$05,$40,$12,$00,$00,$30  ; seg 114  curve=+4                          #0:$80@+18 #3:$A5@+48
        fcb   $04,$00,$05,$40,$12,$00,$00,$1C  ; seg 115  curve=+4                          #0:$80@+18 #3:$A5@+28
        fcb   $04,$00,$05,$40,$12,$00,$00,$E0  ; seg 116  curve=+4                          #0:$80@+18 #3:$A5@-32
        fcb   $04,$00,$25,$00,$12,$D4,$00,$00  ; seg 117  curve=+4                          #0:$80@+18 #1:$A2@-44
        fcb   $04,$00,$05,$40,$12,$00,$00,$DC  ; seg 118  curve=+4                          #0:$80@+18 #3:$A5@-36
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg 119  curve=+4                          #0:$80@+18
        fcb   $04,$00,$25,$00,$12,$E0,$00,$00  ; seg 120  curve=+4                          #0:$80@+18 #1:$A2@-32
        fcb   $04,$00,$25,$00,$12,$DC,$00,$00  ; seg 121  curve=+4                          #0:$80@+18 #1:$A2@-36
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg 122  curve=+4                          #0:$80@+18
        fcb   $04,$00,$25,$00,$12,$38,$00,$00  ; seg 123  curve=+4                          #0:$80@+18 #1:$A2@+56
        fcb   $04,$00,$25,$00,$12,$E8,$00,$00  ; seg 124  curve=+4                          #0:$80@+18 #1:$A2@-24
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg 125  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 126  curve=+4
        fcb   $04,$00,$20,$00,$00,$30,$00,$00  ; seg 127  curve=+4                          #1:$A2@+48
        fcb   $00,$00,$28,$08,$14,$E0,$EC,$00  ; seg 128                                    #0:$85@+20 #1:$A2@-32 #2:$85@-20
        fcb   $00,$00,$08,$08,$14,$00,$EC,$00  ; seg 129                                    #0:$85@+20 #2:$85@-20
        fcb   $00,$00,$08,$08,$14,$00,$EC,$00  ; seg 130                                    #0:$85@+20 #2:$85@-20
        fcb   $00,$00,$08,$08,$14,$00,$EC,$00  ; seg 131                                    #0:$85@+20 #2:$85@-20
        fcb   $00,$7F,$20,$00,$00,$D8,$00,$00  ; seg 132            pitch=-1                #1:$A2@-40
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg 133            pitch=-1
        fcb   $00,$7F,$77,$77,$EE,$EE,$EE,$EE  ; seg 134            pitch=-1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$7F,$77,$77,$EE,$EE,$EE,$EE  ; seg 135            pitch=-1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$27,$07,$EE,$18,$EE,$00  ; seg 136  curve=-6                          #0:$81@-18 #1:$A2@+24 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg 137  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$27,$07,$EE,$20,$EE,$00  ; seg 138  curve=-6                          #0:$81@-18 #1:$A2@+32 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg 139  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg 140  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg 141  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$20,$00,$00,$20,$00,$00  ; seg 142  curve=-6                          #1:$A2@+32
        fcb   $7A,$00,$20,$00,$00,$1C,$00,$00  ; seg 143  curve=-6                          #1:$A2@+28
        fcb   $00,$01,$28,$08,$14,$30,$EC,$00  ; seg 144            pitch=+1                #0:$85@+20 #1:$A2@+48 #2:$85@-20
        fcb   $00,$01,$08,$08,$14,$00,$EC,$00  ; seg 145            pitch=+1                #0:$85@+20 #2:$85@-20
        fcb   $00,$01,$28,$08,$14,$28,$EC,$00  ; seg 146            pitch=+1                #0:$85@+20 #1:$A2@+40 #2:$85@-20
        fcb   $00,$01,$08,$08,$14,$00,$EC,$00  ; seg 147            pitch=+1                #0:$85@+20 #2:$85@-20
        fcb   $00,$7F,$20,$00,$00,$18,$00,$00  ; seg 148            pitch=-1                #1:$A2@+24
        fcb   $00,$7F,$20,$00,$00,$E0,$00,$00  ; seg 149            pitch=-1                #1:$A2@-32
        fcb   $00,$7F,$05,$05,$12,$00,$12,$00  ; seg 150            pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $00,$7F,$05,$05,$12,$00,$12,$00  ; seg 151            pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$25,$00,$12,$E4,$00,$00  ; seg 152  curve=+4                          #0:$80@+18 #1:$A2@-28
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg 153  curve=+4                          #0:$80@+18
        fcb   $04,$00,$25,$00,$12,$D4,$00,$00  ; seg 154  curve=+4                          #0:$80@+18 #1:$A2@-44
        fcb   $04,$00,$25,$00,$12,$D0,$00,$00  ; seg 155  curve=+4                          #0:$80@+18 #1:$A2@-48
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg 156  curve=+4                          #0:$80@+18
        fcb   $04,$00,$25,$00,$12,$E0,$00,$00  ; seg 157  curve=+4                          #0:$80@+18 #1:$A2@-32
        fcb   $04,$00,$20,$00,$00,$C8,$00,$00  ; seg 158  curve=+4                          #1:$A2@-56
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 159  curve=+4
        fcb   $00,$01,$08,$08,$14,$00,$EC,$00  ; seg 160            pitch=+1                #0:$85@+20 #2:$85@-20
        fcb   $00,$01,$28,$08,$14,$28,$EC,$00  ; seg 161            pitch=+1                #0:$85@+20 #1:$A2@+40 #2:$85@-20
        fcb   $00,$01,$08,$08,$14,$00,$EC,$00  ; seg 162            pitch=+1                #0:$85@+20 #2:$85@-20
        fcb   $00,$01,$08,$08,$14,$00,$EC,$00  ; seg 163            pitch=+1                #0:$85@+20 #2:$85@-20
        fcb   $00,$00,$20,$00,$00,$24,$00,$00  ; seg 164                                    #1:$A2@+36
        fcb   $00,$00,$20,$00,$00,$D8,$00,$00  ; seg 165                                    #1:$A2@-40
        fcb   $00,$00,$20,$00,$00,$18,$00,$00  ; seg 166                                    #1:$A2@+24
        fcb   $00,$00,$20,$00,$00,$1C,$00,$00  ; seg 167                                    #1:$A2@+28
        fcb   $00,$00,$20,$00,$00,$20,$00,$00  ; seg 168                                    #1:$A2@+32
        fcb   $00,$00,$20,$00,$00,$E0,$00,$00  ; seg 169                                    #1:$A2@-32
        fcb   $00,$00,$20,$00,$00,$D4,$00,$00  ; seg 170                                    #1:$A2@-44
        fcb   $00,$00,$20,$00,$00,$1C,$00,$00  ; seg 171                                    #1:$A2@+28
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 172                                    #0:$82@+0
        fcb   $00,$00,$20,$00,$00,$28,$00,$00  ; seg 173                                    #1:$A2@+40
        fcb   $00,$00,$20,$00,$00,$30,$00,$00  ; seg 174                                    #1:$A2@+48
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 175
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg 176                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$23,$03,$12,$DC,$12,$00  ; seg 177                                    #0:$83@+18 #1:$A2@-36 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg 178                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg 179                                    #0:$83@+18 #2:$83@+18

Circuit_08_medium_1_segment_cache
        fcb   $00,$00,$F6,$0A  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   1  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   2  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   3  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   4  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   5  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   6  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   7  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   8  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   9  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  10  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  11  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  12  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  13  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  14  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  15  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  16  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  17  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  18  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$01,$F6,$0A  ; seg  19  yaw=  +0 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  20  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $05,$03,$F6,$0A  ; seg  21  yaw=  +5 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $0A,$04,$F6,$0A  ; seg  22  yaw= +10 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $0F,$04,$F6,$0A  ; seg  23  yaw= +15 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $14,$04,$F6,$0A  ; seg  24  yaw= +20 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $19,$04,$F6,$0A  ; seg  25  yaw= +25 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $1E,$04,$F6,$0A  ; seg  26  yaw= +30 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $23,$04,$F6,$0A  ; seg  27  yaw= +35 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $28,$04,$F6,$0A  ; seg  28  yaw= +40 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $2D,$04,$F6,$0A  ; seg  29  yaw= +45 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $32,$04,$F6,$0A  ; seg  30  yaw= +50 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $37,$04,$F6,$0A  ; seg  31  yaw= +55 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $3C,$04,$F6,$0A  ; seg  32  yaw= +60 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $41,$03,$F6,$0A  ; seg  33  yaw= +65 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $46,$02,$F6,$0A  ; seg  34  yaw= +70 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $4B,$01,$F6,$0A  ; seg  35  yaw= +75 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  36  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$FE,$F6,$0A  ; seg  37  yaw= +80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  38  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FA,$F6,$0A  ; seg  39  yaw= +80 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $50,$F8,$F6,$0A  ; seg  40  yaw= +80 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $50,$FA,$F6,$0A  ; seg  41  yaw= +80 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  42  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FE,$F6,$0A  ; seg  43  yaw= +80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  44  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  45  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  46  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  47  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  48  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $4A,$00,$F6,$0A  ; seg  49  yaw= +74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $44,$00,$F6,$0A  ; seg  50  yaw= +68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3E,$00,$F6,$0A  ; seg  51  yaw= +62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  52  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  53  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  54  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  55  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  56  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $32,$00,$F6,$0A  ; seg  57  yaw= +50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$00,$F6,$0A  ; seg  58  yaw= +44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $26,$00,$F6,$0A  ; seg  59  yaw= +38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  60  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$01,$F6,$0A  ; seg  61  yaw= +32 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $20,$02,$F6,$0A  ; seg  62  yaw= +32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $20,$03,$F6,$0A  ; seg  63  yaw= +32 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $20,$04,$F6,$0A  ; seg  64  yaw= +32 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $20,$05,$F6,$0A  ; seg  65  yaw= +32 pitch=  +5 min_lat= -10 max_lat= +10
        fcb   $20,$06,$F6,$0A  ; seg  66  yaw= +32 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $20,$07,$F6,$0A  ; seg  67  yaw= +32 pitch=  +7 min_lat= -10 max_lat= +10
        fcb   $20,$08,$F6,$0A  ; seg  68  yaw= +32 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $20,$06,$F6,$0A  ; seg  69  yaw= +32 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $20,$04,$F6,$0A  ; seg  70  yaw= +32 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $20,$02,$F6,$0A  ; seg  71  yaw= +32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  72  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  73  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  74  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  75  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  76  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $26,$00,$F6,$0A  ; seg  77  yaw= +38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$00,$F6,$0A  ; seg  78  yaw= +44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $32,$00,$F6,$0A  ; seg  79  yaw= +50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  80  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3E,$00,$F6,$0A  ; seg  81  yaw= +62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $44,$00,$F6,$0A  ; seg  82  yaw= +68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $4A,$00,$F6,$0A  ; seg  83  yaw= +74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  84  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  85  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  86  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  87  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  88  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$FF,$F6,$0A  ; seg  89  yaw= +80 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $50,$FE,$F6,$0A  ; seg  90  yaw= +80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $50,$FD,$F6,$0A  ; seg  91  yaw= +80 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  92  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  93  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  94  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  95  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  96  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  97  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  98  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg  99  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg 100  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg 101  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg 102  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg 103  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FC,$F6,$0A  ; seg 104  yaw= +80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $50,$FD,$F6,$0A  ; seg 105  yaw= +80 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $50,$FE,$F6,$0A  ; seg 106  yaw= +80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $50,$FF,$F6,$0A  ; seg 107  yaw= +80 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 108  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 109  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 110  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 111  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 112  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $54,$00,$F6,$0A  ; seg 113  yaw= +84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $58,$00,$F6,$0A  ; seg 114  yaw= +88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $5C,$00,$F6,$0A  ; seg 115  yaw= +92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 116  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $64,$00,$F6,$0A  ; seg 117  yaw=+100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $68,$00,$F6,$0A  ; seg 118  yaw=+104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $6C,$00,$F6,$0A  ; seg 119  yaw=+108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $70,$00,$F6,$0A  ; seg 120  yaw=+112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $74,$00,$F6,$0A  ; seg 121  yaw=+116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $78,$00,$F6,$0A  ; seg 122  yaw=+120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $7C,$00,$F6,$0A  ; seg 123  yaw=+124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 124  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg 125  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 126  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 127  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 128  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 129  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 130  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 131  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 132  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$FF,$F6,$0A  ; seg 133  yaw=-112 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $90,$FE,$F6,$0A  ; seg 134  yaw=-112 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $90,$FD,$F6,$0A  ; seg 135  yaw=-112 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $90,$FC,$F6,$0A  ; seg 136  yaw=-112 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $8A,$FC,$F6,$0A  ; seg 137  yaw=-118 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $84,$FC,$F6,$0A  ; seg 138  yaw=-124 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $7E,$FC,$F6,$0A  ; seg 139  yaw=+126 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $78,$FC,$F6,$0A  ; seg 140  yaw=+120 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $72,$FC,$F6,$0A  ; seg 141  yaw=+114 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $6C,$FC,$F6,$0A  ; seg 142  yaw=+108 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $66,$FC,$F6,$0A  ; seg 143  yaw=+102 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $60,$FC,$F6,$0A  ; seg 144  yaw= +96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $60,$FD,$F6,$0A  ; seg 145  yaw= +96 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $60,$FE,$F6,$0A  ; seg 146  yaw= +96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $60,$FF,$F6,$0A  ; seg 147  yaw= +96 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 148  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$FF,$F6,$0A  ; seg 149  yaw= +96 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $60,$FE,$F6,$0A  ; seg 150  yaw= +96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $60,$FD,$F6,$0A  ; seg 151  yaw= +96 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $60,$FC,$F6,$0A  ; seg 152  yaw= +96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $64,$FC,$F6,$0A  ; seg 153  yaw=+100 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $68,$FC,$F6,$0A  ; seg 154  yaw=+104 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $6C,$FC,$F6,$0A  ; seg 155  yaw=+108 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $70,$FC,$F6,$0A  ; seg 156  yaw=+112 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $74,$FC,$F6,$0A  ; seg 157  yaw=+116 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $78,$FC,$F6,$0A  ; seg 158  yaw=+120 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $7C,$FC,$F6,$0A  ; seg 159  yaw=+124 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $80,$FC,$F6,$0A  ; seg 160  yaw=-128 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $80,$FD,$F6,$0A  ; seg 161  yaw=-128 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 162  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 163  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 164  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 165  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 166  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 167  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 168  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 169  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 170  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 171  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 172 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 173 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 174 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 175 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 176 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 177 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 178 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 179 (wraparound de seg 7)
