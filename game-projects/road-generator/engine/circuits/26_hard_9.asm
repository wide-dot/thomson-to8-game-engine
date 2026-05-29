* ======================================================================
* Circuit_26_hard_9 — N=224 segments (format compact 8 oct/seg)
* Source       : 26_hard_9.bin (extrait de FILE30)
*
* Pays         : WALES
* Lieu         : horseshoe pass, nr llangollen
* Description  : three lap sprint race
* Hazards      : no pitstops
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000090 01:#6C9048 02:#246C24 03:#48486C 04:#484848 05:#B40000 06:#242424 07:#242424
*   08:#244824 09:#D8D8D8 10:#242424 11:#FCFCFC 12:#900048 13:#900048 14:#90006C 15:#90006C
*   16:#900090 17:#902490 18:#9024B4 19:#9048B4 20:#9048D8 21:#906CD8 22:#906CFC 23:#9090FC
*   24:#9090FC 25:#90B4FC 26:#90B4FC 27:#90D8FC
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
* Taille totale : 2802 oct (nb_segments 2 + LUT 16 + segments 1856 + cache 928).
* ======================================================================

Circuit_26_hard_9_nb_segments
        fdb   224

Circuit_26_hard_9_sprite_lut
        fcb   $00,$82,$8B,$87,$89,$8F,$81,$80,$8A,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_26_hard_9_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   4
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   5
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   6
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   7
        fcb   $00,$00,$02,$43,$18,$00,$34,$20  ; seg   8                                    #0:$8B@+24 #2:$87@+52 #3:$89@+32
        fcb   $00,$00,$05,$03,$2C,$00,$D8,$00  ; seg   9                                    #0:$8F@+44 #2:$87@-40
        fcb   $00,$00,$03,$05,$E4,$00,$28,$00  ; seg  10                                    #0:$87@-28 #2:$8F@+40
        fcb   $00,$00,$03,$45,$20,$00,$E0,$30  ; seg  11                                    #0:$87@+32 #2:$8F@-32 #3:$89@+48
        fcb   $00,$00,$03,$03,$E4,$00,$28,$00  ; seg  12                                    #0:$87@-28 #2:$87@+40
        fcb   $00,$00,$02,$45,$2C,$00,$D8,$E0  ; seg  13                                    #0:$8B@+44 #2:$8F@-40 #3:$89@-32
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  14                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  15                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$03,$EE,$00,$18,$00  ; seg  16  curve=-4                          #0:$81@-18 #2:$87@+24
        fcb   $7C,$00,$06,$03,$EE,$00,$14,$00  ; seg  17  curve=-4                          #0:$81@-18 #2:$87@+20
        fcb   $7C,$00,$03,$05,$EC,$00,$E0,$00  ; seg  18  curve=-4                          #0:$87@-20 #2:$8F@-32
        fcb   $7C,$00,$03,$05,$E8,$00,$2C,$00  ; seg  19  curve=-4                          #0:$87@-24 #2:$8F@+44
        fcb   $00,$00,$03,$45,$18,$00,$34,$D0  ; seg  20                                    #0:$87@+24 #2:$8F@+52 #3:$89@-48
        fcb   $00,$00,$02,$03,$2C,$00,$D8,$00  ; seg  21                                    #0:$8B@+44 #2:$87@-40
        fcb   $00,$00,$03,$05,$E4,$00,$28,$00  ; seg  22                                    #0:$87@-28 #2:$8F@+40
        fcb   $00,$00,$03,$05,$20,$00,$E0,$00  ; seg  23                                    #0:$87@+32 #2:$8F@-32
        fcb   $00,$00,$02,$03,$E0,$00,$20,$00  ; seg  24                                    #0:$8B@-32 #2:$87@+32
        fcb   $00,$00,$03,$05,$EC,$00,$1C,$00  ; seg  25                                    #0:$87@-20 #2:$8F@+28
        fcb   $00,$00,$07,$47,$12,$00,$12,$D0  ; seg  26                                    #0:$80@+18 #2:$80@+18 #3:$89@-48
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  27                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$02,$12,$00,$CC,$00  ; seg  28  curve=+4                          #0:$80@+18 #2:$8B@-52
        fcb   $04,$00,$07,$03,$12,$00,$D8,$00  ; seg  29  curve=+4                          #0:$80@+18 #2:$87@-40
        fcb   $04,$00,$07,$43,$12,$00,$EC,$30  ; seg  30  curve=+4                          #0:$80@+18 #2:$87@-20 #3:$89@+48
        fcb   $04,$00,$07,$05,$12,$00,$E4,$00  ; seg  31  curve=+4                          #0:$80@+18 #2:$8F@-28
        fcb   $04,$00,$07,$02,$12,$00,$28,$00  ; seg  32  curve=+4                          #0:$80@+18 #2:$8B@+40
        fcb   $04,$00,$07,$03,$12,$00,$E4,$00  ; seg  33  curve=+4                          #0:$80@+18 #2:$87@-28
        fcb   $04,$00,$03,$05,$20,$00,$28,$00  ; seg  34  curve=+4                          #0:$87@+32 #2:$8F@+40
        fcb   $04,$00,$03,$02,$30,$00,$1C,$00  ; seg  35  curve=+4                          #0:$87@+48 #2:$8B@+28
        fcb   $00,$00,$03,$05,$1C,$00,$20,$00  ; seg  36                                    #0:$87@+28 #2:$8F@+32
        fcb   $00,$00,$03,$02,$20,$00,$24,$00  ; seg  37                                    #0:$87@+32 #2:$8B@+36
        fcb   $00,$7E,$03,$45,$14,$00,$30,$20  ; seg  38            pitch=-2                #0:$87@+20 #2:$8F@+48 #3:$89@+32
        fcb   $00,$7E,$03,$03,$EC,$00,$D0,$00  ; seg  39            pitch=-2                #0:$87@-20 #2:$87@-48
        fcb   $00,$02,$03,$05,$1C,$00,$34,$00  ; seg  40            pitch=+2                #0:$87@+28 #2:$8F@+52
        fcb   $00,$02,$02,$03,$18,$00,$20,$00  ; seg  41            pitch=+2                #0:$8B@+24 #2:$87@+32
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  42                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  43                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$43,$EE,$00,$1C,$30  ; seg  44  curve=-4                          #0:$81@-18 #2:$87@+28 #3:$89@+48
        fcb   $7C,$00,$06,$05,$EE,$00,$20,$00  ; seg  45  curve=-4                          #0:$81@-18 #2:$8F@+32
        fcb   $7C,$00,$03,$03,$D0,$00,$24,$00  ; seg  46  curve=-4                          #0:$87@-48 #2:$87@+36
        fcb   $7C,$00,$02,$05,$30,$00,$2C,$00  ; seg  47  curve=-4                          #0:$8B@+48 #2:$8F@+44
        fcb   $00,$00,$03,$03,$14,$00,$2C,$00  ; seg  48                                    #0:$87@+20 #2:$87@+44
        fcb   $00,$00,$02,$05,$20,$00,$28,$00  ; seg  49                                    #0:$8B@+32 #2:$8F@+40
        fcb   $00,$02,$03,$03,$E0,$00,$30,$00  ; seg  50            pitch=+2                #0:$87@-32 #2:$87@+48
        fcb   $00,$02,$03,$05,$E8,$00,$24,$00  ; seg  51            pitch=+2                #0:$87@-24 #2:$8F@+36
        fcb   $00,$7E,$03,$03,$E4,$00,$1C,$00  ; seg  52            pitch=-2                #0:$87@-28 #2:$87@+28
        fcb   $00,$7E,$02,$05,$DC,$00,$20,$00  ; seg  53            pitch=-2                #0:$8B@-36 #2:$8F@+32
        fcb   $00,$7E,$03,$43,$20,$00,$E0,$D0  ; seg  54            pitch=-2                #0:$87@+32 #2:$87@-32 #3:$89@-48
        fcb   $00,$7E,$03,$05,$18,$00,$D8,$00  ; seg  55            pitch=-2                #0:$87@+24 #2:$8F@-40
        fcb   $00,$01,$03,$05,$20,$00,$E8,$00  ; seg  56            pitch=+1                #0:$87@+32 #2:$8F@-24
        fcb   $00,$01,$02,$03,$EC,$00,$14,$00  ; seg  57            pitch=+1                #0:$8B@-20 #2:$87@+20
        fcb   $00,$01,$03,$03,$E0,$00,$1C,$00  ; seg  58            pitch=+1                #0:$87@-32 #2:$87@+28
        fcb   $00,$01,$05,$02,$20,$00,$18,$00  ; seg  59            pitch=+1                #0:$8F@+32 #2:$8B@+24
        fcb   $00,$00,$00,$40,$00,$00,$00,$20  ; seg  60                                    #3:$89@+32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  61
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  62                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  63                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$40,$EE,$00,$00,$30  ; seg  64  curve=-4                          #0:$81@-18 #3:$89@+48
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  65  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$03,$00,$00,$18,$00  ; seg  66  curve=-4                          #2:$87@+24
        fcb   $7C,$00,$00,$43,$00,$00,$24,$E0  ; seg  67  curve=-4                          #2:$87@+36 #3:$89@-32
        fcb   $00,$00,$05,$03,$E8,$00,$12,$00  ; seg  68                                    #0:$8F@-24 #2:$87@+18
        fcb   $00,$00,$03,$03,$EE,$00,$12,$00  ; seg  69                                    #0:$87@-18 #2:$87@+18
        fcb   $00,$00,$02,$05,$EE,$00,$18,$00  ; seg  70                                    #0:$8B@-18 #2:$8F@+24
        fcb   $00,$00,$03,$03,$E8,$00,$24,$00  ; seg  71                                    #0:$87@-24 #2:$87@+36
        fcb   $00,$00,$00,$40,$00,$00,$00,$D0  ; seg  72                                    #3:$89@-48
        fcb   $00,$00,$00,$40,$00,$00,$00,$20  ; seg  73                                    #3:$89@+32
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  74                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  75                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  76  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$40,$EE,$00,$00,$D0  ; seg  77  curve=-4                          #0:$81@-18 #3:$89@-48
        fcb   $7C,$00,$00,$03,$00,$00,$DC,$00  ; seg  78  curve=-4                          #2:$87@-36
        fcb   $7C,$00,$00,$05,$00,$00,$EE,$00  ; seg  79  curve=-4                          #2:$8F@-18
        fcb   $00,$00,$02,$03,$12,$00,$E8,$00  ; seg  80                                    #0:$8B@+18 #2:$87@-24
        fcb   $00,$00,$03,$05,$18,$00,$E8,$00  ; seg  81                                    #0:$87@+24 #2:$8F@-24
        fcb   $00,$02,$03,$02,$12,$00,$E8,$00  ; seg  82            pitch=+2                #0:$87@+18 #2:$8B@-24
        fcb   $00,$02,$03,$45,$18,$00,$EE,$E0  ; seg  83            pitch=+2                #0:$87@+24 #2:$8F@-18 #3:$89@-32
        fcb   $00,$7F,$03,$03,$12,$00,$DC,$00  ; seg  84            pitch=-1                #0:$87@+18 #2:$87@-36
        fcb   $00,$7F,$03,$02,$18,$00,$EE,$00  ; seg  85            pitch=-1                #0:$87@+24 #2:$8B@-18
        fcb   $00,$7F,$05,$03,$12,$00,$EE,$00  ; seg  86            pitch=-1                #0:$8F@+18 #2:$87@-18
        fcb   $00,$7F,$05,$05,$18,$00,$EE,$00  ; seg  87            pitch=-1                #0:$8F@+24 #2:$8F@-18
        fcb   $00,$7F,$03,$03,$24,$00,$DC,$00  ; seg  88            pitch=-1                #0:$87@+36 #2:$87@-36
        fcb   $00,$7F,$05,$03,$12,$00,$E8,$00  ; seg  89            pitch=-1                #0:$8F@+18 #2:$87@-24
        fcb   $00,$01,$05,$43,$12,$00,$DC,$E0  ; seg  90            pitch=+1                #0:$8F@+18 #2:$87@-36 #3:$89@-32
        fcb   $00,$01,$05,$02,$18,$00,$EE,$00  ; seg  91            pitch=+1                #0:$8F@+24 #2:$8B@-18
        fcb   $00,$00,$00,$40,$00,$00,$00,$30  ; seg  92                                    #3:$89@+48
        fcb   $00,$00,$00,$40,$00,$00,$00,$20  ; seg  93                                    #3:$89@+32
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  94                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  95                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  96  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$40,$EE,$00,$00,$D0  ; seg  97  curve=-4                          #0:$81@-18 #3:$89@-48
        fcb   $7C,$00,$00,$03,$00,$00,$12,$00  ; seg  98  curve=-4                          #2:$87@+18
        fcb   $7C,$00,$00,$45,$00,$00,$24,$30  ; seg  99  curve=-4                          #2:$8F@+36 #3:$89@+48
        fcb   $00,$00,$05,$03,$E8,$00,$12,$00  ; seg 100                                    #0:$8F@-24 #2:$87@+18
        fcb   $00,$00,$03,$05,$EE,$00,$18,$00  ; seg 101                                    #0:$87@-18 #2:$8F@+24
        fcb   $00,$7F,$05,$03,$EE,$00,$12,$00  ; seg 102            pitch=-1                #0:$8F@-18 #2:$87@+18
        fcb   $00,$7F,$05,$02,$E8,$00,$12,$00  ; seg 103            pitch=-1                #0:$8F@-24 #2:$8B@+18
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg 104            pitch=+1
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg 105            pitch=+1
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 106                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 107                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 108  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$40,$EE,$00,$00,$E0  ; seg 109  curve=-4                          #0:$81@-18 #3:$89@-32
        fcb   $7C,$00,$00,$05,$00,$00,$DC,$00  ; seg 110  curve=-4                          #2:$8F@-36
        fcb   $7C,$00,$00,$03,$00,$00,$EE,$00  ; seg 111  curve=-4                          #2:$87@-18
        fcb   $00,$00,$05,$03,$24,$00,$EE,$00  ; seg 112                                    #0:$8F@+36 #2:$87@-18
        fcb   $00,$00,$03,$05,$18,$00,$E8,$00  ; seg 113                                    #0:$87@+24 #2:$8F@-24
        fcb   $00,$00,$02,$03,$12,$00,$EE,$00  ; seg 114                                    #0:$8B@+18 #2:$87@-18
        fcb   $00,$00,$03,$05,$12,$00,$DC,$00  ; seg 115                                    #0:$87@+18 #2:$8F@-36
        fcb   $00,$00,$03,$05,$18,$00,$E8,$00  ; seg 116                                    #0:$87@+24 #2:$8F@-24
        fcb   $00,$00,$03,$05,$12,$00,$E8,$00  ; seg 117                                    #0:$87@+18 #2:$8F@-24
        fcb   $00,$00,$03,$43,$24,$00,$EE,$D0  ; seg 118                                    #0:$87@+36 #2:$87@-18 #3:$89@-48
        fcb   $00,$00,$02,$05,$18,$00,$EE,$00  ; seg 119                                    #0:$8B@+24 #2:$8F@-18
        fcb   $00,$01,$03,$05,$12,$00,$EE,$00  ; seg 120            pitch=+1                #0:$87@+18 #2:$8F@-18
        fcb   $00,$01,$03,$05,$18,$00,$E8,$00  ; seg 121            pitch=+1                #0:$87@+24 #2:$8F@-24
        fcb   $00,$7F,$03,$05,$12,$00,$DC,$00  ; seg 122            pitch=-1                #0:$87@+18 #2:$8F@-36
        fcb   $00,$7F,$03,$05,$18,$00,$EE,$00  ; seg 123            pitch=-1                #0:$87@+24 #2:$8F@-18
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 124
        fcb   $00,$00,$00,$40,$00,$00,$00,$30  ; seg 125                                    #3:$89@+48
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 126                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 127                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 128  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$40,$EE,$00,$00,$D0  ; seg 129  curve=-4                          #0:$81@-18 #3:$89@-48
        fcb   $7C,$00,$00,$02,$00,$00,$12,$00  ; seg 130  curve=-4                          #2:$8B@+18
        fcb   $7C,$00,$00,$45,$00,$00,$18,$E0  ; seg 131  curve=-4                          #2:$8F@+24 #3:$89@-32
        fcb   $00,$00,$03,$05,$E8,$00,$24,$00  ; seg 132                                    #0:$87@-24 #2:$8F@+36
        fcb   $00,$00,$03,$05,$EE,$00,$12,$00  ; seg 133                                    #0:$87@-18 #2:$8F@+18
        fcb   $00,$00,$02,$05,$EE,$00,$18,$00  ; seg 134                                    #0:$8B@-18 #2:$8F@+24
        fcb   $00,$00,$05,$05,$DC,$00,$12,$00  ; seg 135                                    #0:$8F@-36 #2:$8F@+18
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 136
        fcb   $00,$00,$00,$40,$00,$00,$00,$20  ; seg 137                                    #3:$89@+32
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 138                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 139                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 140  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$40,$12,$00,$00,$30  ; seg 141  curve=+4                          #0:$80@+18 #3:$89@+48
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 142  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 143  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 144  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$40,$12,$00,$00,$D0  ; seg 145  curve=+4                          #0:$80@+18 #3:$89@-48
        fcb   $04,$00,$00,$05,$00,$00,$E8,$00  ; seg 146  curve=+4                          #2:$8F@-24
        fcb   $04,$00,$00,$05,$00,$00,$EE,$00  ; seg 147  curve=+4                          #2:$8F@-18
        fcb   $00,$00,$05,$03,$12,$00,$EE,$00  ; seg 148                                    #0:$8F@+18 #2:$87@-18
        fcb   $00,$00,$02,$03,$18,$00,$E8,$00  ; seg 149                                    #0:$8B@+24 #2:$87@-24
        fcb   $00,$7F,$05,$02,$24,$00,$EE,$00  ; seg 150            pitch=-1                #0:$8F@+36 #2:$8B@-18
        fcb   $00,$7F,$03,$02,$12,$00,$DC,$00  ; seg 151            pitch=-1                #0:$87@+18 #2:$8B@-36
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg 152            pitch=+1
        fcb   $00,$01,$00,$40,$00,$00,$00,$E0  ; seg 153            pitch=+1                #3:$89@-32
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 154                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 155                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$40,$EE,$00,$00,$20  ; seg 156  curve=-4                          #0:$81@-18 #3:$89@+32
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 157  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$05,$00,$00,$E8,$00  ; seg 158  curve=-4                          #2:$8F@-24
        fcb   $7C,$00,$00,$03,$00,$00,$EE,$00  ; seg 159  curve=-4                          #2:$87@-18
        fcb   $00,$00,$02,$05,$18,$00,$EE,$00  ; seg 160                                    #0:$8B@+24 #2:$8F@-18
        fcb   $00,$00,$03,$05,$12,$00,$E8,$00  ; seg 161                                    #0:$87@+18 #2:$8F@-24
        fcb   $00,$00,$05,$05,$24,$00,$EE,$00  ; seg 162                                    #0:$8F@+36 #2:$8F@-18
        fcb   $00,$00,$05,$02,$18,$00,$DC,$00  ; seg 163                                    #0:$8F@+24 #2:$8B@-36
        fcb   $00,$01,$02,$42,$12,$00,$E8,$E0  ; seg 164            pitch=+1                #0:$8B@+18 #2:$8B@-24 #3:$89@-32
        fcb   $00,$01,$02,$05,$18,$00,$EE,$00  ; seg 165            pitch=+1                #0:$8B@+24 #2:$8F@-18
        fcb   $00,$01,$05,$05,$12,$00,$EE,$00  ; seg 166            pitch=+1                #0:$8F@+18 #2:$8F@-18
        fcb   $00,$01,$05,$03,$12,$00,$E8,$00  ; seg 167            pitch=+1                #0:$8F@+18 #2:$87@-24
        fcb   $00,$7F,$02,$05,$18,$00,$EE,$00  ; seg 168            pitch=-1                #0:$8B@+24 #2:$8F@-18
        fcb   $00,$7F,$03,$03,$12,$00,$DC,$00  ; seg 169            pitch=-1                #0:$87@+18 #2:$87@-36
        fcb   $00,$7F,$05,$05,$12,$00,$EE,$00  ; seg 170            pitch=-1                #0:$8F@+18 #2:$8F@-18
        fcb   $00,$7F,$03,$02,$18,$00,$E8,$00  ; seg 171            pitch=-1                #0:$87@+24 #2:$8B@-24
        fcb   $00,$00,$00,$40,$00,$00,$00,$D0  ; seg 172                                    #3:$89@-48
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 173
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 174                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 175                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 176  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$40,$EE,$00,$00,$D0  ; seg 177  curve=-4                          #0:$81@-18 #3:$89@-48
        fcb   $7C,$00,$00,$03,$00,$00,$EE,$00  ; seg 178  curve=-4                          #2:$87@-18
        fcb   $7C,$00,$00,$45,$00,$00,$DC,$E0  ; seg 179  curve=-4                          #2:$8F@-36 #3:$89@-32
        fcb   $00,$00,$02,$03,$12,$00,$E8,$00  ; seg 180                                    #0:$8B@+18 #2:$87@-24
        fcb   $00,$00,$05,$02,$24,$00,$EE,$00  ; seg 181                                    #0:$8F@+36 #2:$8B@-18
        fcb   $00,$00,$03,$05,$12,$00,$DC,$00  ; seg 182                                    #0:$87@+18 #2:$8F@-36
        fcb   $00,$00,$02,$03,$18,$00,$E8,$00  ; seg 183                                    #0:$8B@+24 #2:$87@-24
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 184
        fcb   $00,$00,$00,$40,$00,$00,$00,$20  ; seg 185                                    #3:$89@+32
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 186                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 187                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 188  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 189  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$40,$00,$00,$00,$30  ; seg 190  curve=-4                          #3:$89@+48
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 191  curve=-4
        fcb   $00,$00,$02,$05,$20,$00,$E0,$00  ; seg 192                                    #0:$8B@+32 #2:$8F@-32
        fcb   $00,$00,$03,$05,$14,$00,$DC,$00  ; seg 193                                    #0:$87@+20 #2:$8F@-36
        fcb   $00,$01,$03,$03,$E0,$00,$CC,$00  ; seg 194            pitch=+1                #0:$87@-32 #2:$87@-52
        fcb   $00,$01,$05,$05,$1C,$00,$14,$00  ; seg 195            pitch=+1                #0:$8F@+28 #2:$8F@+20
        fcb   $00,$01,$05,$03,$EC,$00,$E0,$00  ; seg 196            pitch=+1                #0:$8F@-20 #2:$87@-32
        fcb   $00,$01,$03,$45,$14,$00,$18,$D0  ; seg 197            pitch=+1                #0:$87@+20 #2:$8F@+24 #3:$89@-48
        fcb   $00,$00,$02,$03,$E4,$00,$EC,$00  ; seg 198                                    #0:$8B@-28 #2:$87@-20
        fcb   $00,$00,$05,$02,$20,$00,$EC,$00  ; seg 199                                    #0:$8F@+32 #2:$8B@-20
        fcb   $00,$7E,$05,$05,$1C,$00,$14,$00  ; seg 200            pitch=-2                #0:$8F@+28 #2:$8F@+20
        fcb   $00,$7E,$05,$05,$E0,$00,$E8,$00  ; seg 201            pitch=-2                #0:$8F@-32 #2:$8F@-24
        fcb   $00,$00,$03,$43,$D8,$00,$EC,$D0  ; seg 202                                    #0:$87@-40 #2:$87@-20 #3:$89@-48
        fcb   $00,$00,$03,$05,$2C,$00,$14,$00  ; seg 203                                    #0:$87@+44 #2:$8F@+20
        fcb   $00,$00,$02,$05,$14,$00,$CC,$00  ; seg 204                                    #0:$8B@+20 #2:$8F@-52
        fcb   $00,$00,$03,$05,$EC,$00,$E0,$00  ; seg 205                                    #0:$87@-20 #2:$8F@-32
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 206                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 207                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$40,$EE,$00,$00,$E0  ; seg 208  curve=-4                          #0:$81@-18 #3:$89@-32
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 209  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$40,$00,$00,$00,$20  ; seg 210  curve=-4                          #3:$89@+32
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 211  curve=-4
        fcb   $00,$00,$84,$08,$EA,$EC,$EA,$00  ; seg 212                                    #0:$89@-22 #1:$8A@-20 #2:$8A@-22
        fcb   $00,$00,$08,$44,$EE,$00,$EE,$EA  ; seg 213                                    #0:$8A@-18 #2:$89@-18 #3:$89@-22
        fcb   $00,$02,$84,$08,$E6,$EA,$EC,$00  ; seg 214            pitch=+2                #0:$89@-26 #1:$8A@-22 #2:$8A@-20
        fcb   $00,$02,$48,$80,$E8,$EE,$00,$E8  ; seg 215            pitch=+2                #0:$8A@-24 #1:$89@-18 #3:$8A@-24
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg 216            pitch=-2
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg 217            pitch=-2
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 218                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 219                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 220  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 221  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 222  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 223  curve=-4
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 224                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 225
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 226
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 227
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 228
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 229
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 230
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 231

Circuit_26_hard_9_segment_cache
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
        fcb   $FC,$00,$F6,$0A  ; seg  17  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  18  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  19  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  20  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  21  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  22  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  23  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  24  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  25  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  26  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  27  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  28  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  29  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  30  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  31  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  32  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $04,$00,$F6,$0A  ; seg  33  yaw=  +4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  34  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$00,$F6,$0A  ; seg  35  yaw= +12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  36  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  37  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  38  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$FE,$F6,$0A  ; seg  39  yaw= +16 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $10,$FC,$F6,$0A  ; seg  40  yaw= +16 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $10,$FE,$F6,$0A  ; seg  41  yaw= +16 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  42  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  43  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  44  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$00,$F6,$0A  ; seg  45  yaw= +12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  46  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $04,$00,$F6,$0A  ; seg  47  yaw=  +4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  48  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  49  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  50  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  51  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $00,$04,$F6,$0A  ; seg  52  yaw=  +0 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  53  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  54  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  55  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$FC,$F6,$0A  ; seg  56  yaw=  +0 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $00,$FD,$F6,$0A  ; seg  57  yaw=  +0 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  58  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg  59  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  60  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  61  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  62  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  63  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  64  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  65  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  66  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  67  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  68  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  69  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  70  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  71  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  72  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  73  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  74  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  75  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  76  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  77  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  78  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  79  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  80  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  81  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  82  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  83  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$04,$F6,$0A  ; seg  84  yaw= -32 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $E0,$03,$F6,$0A  ; seg  85  yaw= -32 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  86  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$01,$F6,$0A  ; seg  87  yaw= -32 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  88  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  89  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  90  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  91  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  92  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  93  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  94  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  95  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  96  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  97  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  98  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  99  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 100  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 101  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 102  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$FF,$F6,$0A  ; seg 103  yaw= -48 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $D0,$FE,$F6,$0A  ; seg 104  yaw= -48 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $D0,$FF,$F6,$0A  ; seg 105  yaw= -48 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 106  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 107  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 108  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg 109  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 110  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg 111  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 112  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 113  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 114  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 115  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 116  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 117  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 118  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 119  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 120  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 121  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 122  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 123  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 124  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 125  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 126  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 127  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 128  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 129  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 130  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 131  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 132  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 133  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 134  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 135  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 136  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 137  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 138  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 139  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 140  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 141  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 142  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 143  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 144  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg 145  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 146  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg 147  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 148  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 149  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 150  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$FF,$F6,$0A  ; seg 151  yaw= -48 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $D0,$FE,$F6,$0A  ; seg 152  yaw= -48 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $D0,$FF,$F6,$0A  ; seg 153  yaw= -48 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 154  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 155  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 156  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg 157  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 158  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg 159  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 160  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 161  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 162  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 163  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 164  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 165  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 166  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 167  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 168  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 169  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 170  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 171  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 172  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 173  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 174  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 175  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 176  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 177  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 178  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 179  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 180  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 181  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 182  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 183  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 184  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 185  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 186  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 187  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 188  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg 189  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 190  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 191  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 192  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 193  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 194  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$01,$F6,$0A  ; seg 195  yaw= -96 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A0,$02,$F6,$0A  ; seg 196  yaw= -96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A0,$03,$F6,$0A  ; seg 197  yaw= -96 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $A0,$04,$F6,$0A  ; seg 198  yaw= -96 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $A0,$04,$F6,$0A  ; seg 199  yaw= -96 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $A0,$04,$F6,$0A  ; seg 200  yaw= -96 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $A0,$02,$F6,$0A  ; seg 201  yaw= -96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 202  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 203  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 204  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 205  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 206  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 207  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 208  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg 209  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 210  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 211  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 212  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 213  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 214  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$02,$F6,$0A  ; seg 215  yaw=-112 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $90,$04,$F6,$0A  ; seg 216  yaw=-112 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $90,$02,$F6,$0A  ; seg 217  yaw=-112 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 218  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 219  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 220  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 221  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 222  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg 223  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 224 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 225 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 226 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 227 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 228 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 229 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 230 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 231 (wraparound de seg 7)
