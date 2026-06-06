* ======================================================================
* Circuit_24_hard_7 — N=210 segments (format compact 8 oct/seg)
* Source       : 24_hard_7.bin (extrait de FILE30)
*
* Pays         : BRAZIL
* Lieu         : belo horizonte
* Description  : nighttime race
* Hazards      : no hazards
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#00006C 01:#909090 02:#000000 03:#484848 04:#000000 05:#480000 06:#000000 07:#000000
*   08:#000000 09:#909090 10:#000000 11:#909090 12:#000000 13:#000000 14:#000000 15:#000000
*   16:#000024 17:#000024 18:#000048 19:#000048 20:#00006C 21:#00006C 22:#000090 23:#000090
*   24:#0000B4 25:#0000B4 26:#0000D8 27:#0000D8
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
* par circuit ; ce circuit : 8 entries utilisées).
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
* Taille totale : 2634 oct (nb_segments 2 + LUT 16 + segments 1744 + cache 872).
* ======================================================================

Circuit_24_hard_7_nb_segments
        fdb   210

Circuit_24_hard_7_sprite_lut
        fcb   $00,$82,$81,$83,$80,$85,$84,$86,$00,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_24_hard_7_segments
        fcb   $7C,$80,$01,$00,$00,$00,$00,$00  ; seg   0  curve=-4            flags=[START] #0:$82@+0
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg   1  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg   2  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg   3  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$03,$03,$12,$00,$12,$00  ; seg   4  curve=-4                          #0:$83@+18 #2:$83@+18
        fcb   $7C,$00,$03,$03,$12,$00,$12,$00  ; seg   5  curve=-4                          #0:$83@+18 #2:$83@+18
        fcb   $7C,$00,$03,$03,$12,$00,$12,$00  ; seg   6  curve=-4                          #0:$83@+18 #2:$83@+18
        fcb   $7C,$00,$03,$03,$12,$00,$12,$00  ; seg   7  curve=-4                          #0:$83@+18 #2:$83@+18
        fcb   $FC,$00,$04,$00,$18,$00,$00,$00  ; seg   8  curve=-4            flags=[PIT]   #0:$80@+24
        fcb   $FC,$00,$04,$00,$18,$00,$00,$00  ; seg   9  curve=-4            flags=[PIT]   #0:$80@+24
        fcb   $FC,$00,$04,$00,$18,$00,$00,$00  ; seg  10  curve=-4            flags=[PIT]   #0:$80@+24
        fcb   $FC,$00,$04,$00,$18,$00,$00,$00  ; seg  11  curve=-4            flags=[PIT]   #0:$80@+24
        fcb   $FC,$00,$04,$00,$18,$00,$00,$00  ; seg  12  curve=-4            flags=[PIT]   #0:$80@+24
        fcb   $FC,$00,$04,$00,$18,$00,$00,$00  ; seg  13  curve=-4            flags=[PIT]   #0:$80@+24
        fcb   $FC,$00,$00,$00,$00,$00,$00,$00  ; seg  14  curve=-4            flags=[PIT]
        fcb   $FC,$00,$00,$00,$00,$00,$00,$00  ; seg  15  curve=-4            flags=[PIT]
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg  16                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg  17                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$01,$05,$05,$EC,$00,$EC,$00  ; seg  18            pitch=+1                #0:$85@-20 #2:$85@-20
        fcb   $00,$01,$05,$05,$EC,$00,$EC,$00  ; seg  19            pitch=+1                #0:$85@-20 #2:$85@-20
        fcb   $00,$7F,$05,$05,$EC,$00,$EC,$00  ; seg  20            pitch=-1                #0:$85@-20 #2:$85@-20
        fcb   $00,$7F,$05,$05,$EC,$00,$EC,$00  ; seg  21            pitch=-1                #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg  22                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg  23                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg  24                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg  25                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg  26            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg  27            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  28            pitch=-1
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  29            pitch=-1
        fcb   $00,$00,$44,$44,$12,$12,$12,$12  ; seg  30                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$44,$44,$12,$12,$12,$12  ; seg  31                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  32  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  33  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  34  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  35  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  36  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  37  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  38  curve=+4
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  39  curve=+4
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg  40                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg  41                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg  42            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg  43            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg  44            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg  45            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$02,$05,$05,$EC,$00,$EC,$00  ; seg  46            pitch=+2                #0:$85@-20 #2:$85@-20
        fcb   $00,$02,$05,$05,$EC,$00,$EC,$00  ; seg  47            pitch=+2                #0:$85@-20 #2:$85@-20
        fcb   $00,$02,$05,$05,$EC,$00,$EC,$00  ; seg  48            pitch=+2                #0:$85@-20 #2:$85@-20
        fcb   $00,$02,$05,$05,$EC,$00,$EC,$00  ; seg  49            pitch=+2                #0:$85@-20 #2:$85@-20
        fcb   $00,$7F,$05,$05,$EC,$00,$EC,$00  ; seg  50            pitch=-1                #0:$85@-20 #2:$85@-20
        fcb   $00,$7F,$05,$05,$EC,$00,$EC,$00  ; seg  51            pitch=-1                #0:$85@-20 #2:$85@-20
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  52            pitch=-1
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  53            pitch=-1
        fcb   $00,$00,$04,$04,$12,$00,$12,$00  ; seg  54                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$04,$04,$12,$00,$12,$00  ; seg  55                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  56  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  57  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  58  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  59  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  60  curve=+4                          #0:$80@+18
        fcb   $04,$00,$04,$00,$12,$00,$00,$00  ; seg  61  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  62  curve=+4
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  63  curve=+4
        fcb   $00,$00,$06,$00,$14,$00,$00,$00  ; seg  64                                    #0:$84@+20
        fcb   $00,$00,$06,$00,$14,$00,$00,$00  ; seg  65                                    #0:$84@+20
        fcb   $00,$7F,$06,$00,$14,$00,$00,$00  ; seg  66            pitch=-1                #0:$84@+20
        fcb   $00,$7F,$06,$00,$14,$00,$00,$00  ; seg  67            pitch=-1                #0:$84@+20
        fcb   $00,$01,$06,$00,$14,$00,$00,$00  ; seg  68            pitch=+1                #0:$84@+20
        fcb   $00,$01,$06,$00,$14,$00,$00,$00  ; seg  69            pitch=+1                #0:$84@+20
        fcb   $00,$00,$06,$00,$EC,$00,$00,$00  ; seg  70                                    #0:$84@-20
        fcb   $00,$00,$06,$00,$EC,$00,$00,$00  ; seg  71                                    #0:$84@-20
        fcb   $00,$00,$06,$00,$EC,$00,$00,$00  ; seg  72                                    #0:$84@-20
        fcb   $00,$00,$06,$00,$EC,$00,$00,$00  ; seg  73                                    #0:$84@-20
        fcb   $00,$7F,$06,$00,$EC,$00,$00,$00  ; seg  74            pitch=-1                #0:$84@-20
        fcb   $00,$7F,$06,$00,$EC,$00,$00,$00  ; seg  75            pitch=-1                #0:$84@-20
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg  76            pitch=+1
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg  77            pitch=+1
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg  78                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg  79                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  80  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  81  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  82  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  83  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  84  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  85  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  86  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  87  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  88  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  89  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  90  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  91  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  92  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  93  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  94  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  95  curve=-4
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg  96                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg  97                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg  98                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg  99                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 100                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 101                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 102                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 103                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$EC,$00,$EC,$00  ; seg 104            pitch=-1                #0:$85@-20 #2:$85@-20
        fcb   $00,$7F,$05,$05,$EC,$00,$EC,$00  ; seg 105            pitch=-1                #0:$85@-20 #2:$85@-20
        fcb   $00,$01,$05,$05,$EC,$00,$EC,$00  ; seg 106            pitch=+1                #0:$85@-20 #2:$85@-20
        fcb   $00,$01,$05,$05,$EC,$00,$EC,$00  ; seg 107            pitch=+1                #0:$85@-20 #2:$85@-20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg 108            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg 109            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg 110            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg 111            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$EC,$00,$EC,$00  ; seg 112            pitch=-1                #0:$85@-20 #2:$85@-20
        fcb   $00,$7F,$05,$05,$EC,$00,$EC,$00  ; seg 113            pitch=-1                #0:$85@-20 #2:$85@-20
        fcb   $00,$01,$05,$05,$EC,$00,$EC,$00  ; seg 114            pitch=+1                #0:$85@-20 #2:$85@-20
        fcb   $00,$01,$05,$05,$EC,$00,$EC,$00  ; seg 115            pitch=+1                #0:$85@-20 #2:$85@-20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg 116            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg 117            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg 118            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg 119            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg 120                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg 121                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg 122                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg 123                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 124
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 125
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 126                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 127                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 128  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 129  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 130  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 131  curve=-4
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg 132                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg 133                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg 134                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$05,$05,$EC,$00,$EC,$00  ; seg 135                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 136
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 137
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 138                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 139                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 140  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 141  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 142  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 143  curve=-4
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 144                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 145                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 146                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 147                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$14,$00,$14,$00  ; seg 148                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$07,$07,$14,$00,$14,$00  ; seg 149                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$07,$07,$14,$00,$14,$00  ; seg 150                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$07,$07,$14,$00,$14,$00  ; seg 151                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 152                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 153                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 154                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 155                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 156
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 157
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 158                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 159                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 160  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 161  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 162  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 163  curve=-4
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 164                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 165                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 166                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 167                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 168
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 169
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 170                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 171                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 172  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 173  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 174  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 175  curve=-4
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 176                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 177                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 178                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 179                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 180                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 181                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 182                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$05,$05,$14,$00,$14,$00  ; seg 183                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$06,$00,$EC,$00,$00,$00  ; seg 184            pitch=-1                #0:$84@-20
        fcb   $00,$7F,$06,$00,$EC,$00,$00,$00  ; seg 185            pitch=-1                #0:$84@-20
        fcb   $00,$01,$06,$00,$EC,$00,$00,$00  ; seg 186            pitch=+1                #0:$84@-20
        fcb   $00,$01,$06,$00,$EC,$00,$00,$00  ; seg 187            pitch=+1                #0:$84@-20
        fcb   $00,$01,$06,$00,$EC,$00,$00,$00  ; seg 188            pitch=+1                #0:$84@-20
        fcb   $00,$01,$06,$00,$EC,$00,$00,$00  ; seg 189            pitch=+1                #0:$84@-20
        fcb   $00,$7F,$06,$00,$EC,$00,$00,$00  ; seg 190            pitch=-1                #0:$84@-20
        fcb   $00,$7F,$06,$00,$EC,$00,$00,$00  ; seg 191            pitch=-1                #0:$84@-20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg 192            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg 193            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg 194            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg 195            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg 196            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$01,$05,$05,$14,$00,$14,$00  ; seg 197            pitch=+1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg 198            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$7F,$05,$05,$14,$00,$14,$00  ; seg 199            pitch=-1                #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 200                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 201                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 202                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 203                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 204                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$07,$07,$EC,$00,$EC,$00  ; seg 205                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 206
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 207
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 208                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 209                                    #0:$81@-18 #2:$81@-18
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $7C,$00,$01,$00,$00,$00,$00,$00  ; seg 210  curve=-4                          #0:$82@+0
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 211  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 212  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 213  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$03,$03,$12,$00,$12,$00  ; seg 214  curve=-4                          #0:$83@+18 #2:$83@+18
        fcb   $7C,$00,$03,$03,$12,$00,$12,$00  ; seg 215  curve=-4                          #0:$83@+18 #2:$83@+18
        fcb   $7C,$00,$03,$03,$12,$00,$12,$00  ; seg 216  curve=-4                          #0:$83@+18 #2:$83@+18
        fcb   $7C,$00,$03,$03,$12,$00,$12,$00  ; seg 217  curve=-4                          #0:$83@+18 #2:$83@+18

Circuit_24_hard_7_segment_cache
        fcb   $00,$00,$F6,$0A  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg   1  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg   2  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg   3  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg   4  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg   5  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg   6  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg   7  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg   8  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg   9  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  10  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  11  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  12  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  13  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  14  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  15  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  16  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  17  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  18  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg  19  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  20  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg  21  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  22  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  23  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  24  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  25  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  26  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg  27  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  28  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg  29  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  30  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  31  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  32  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  33  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  34  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  35  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  36  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  37  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  38  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  39  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  40  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  41  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  42  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  43  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  44  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FD,$F6,$0A  ; seg  45  yaw= -32 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  46  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  47  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  48  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  49  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$04,$F6,$0A  ; seg  50  yaw= -32 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $E0,$03,$F6,$0A  ; seg  51  yaw= -32 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  52  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$01,$F6,$0A  ; seg  53  yaw= -32 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  54  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  55  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  56  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  57  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  58  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  59  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  60  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  61  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  62  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  63  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  64  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  65  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  66  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg  67  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  68  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg  69  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  70  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  71  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  72  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  73  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  74  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg  75  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  76  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg  77  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  78  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  79  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  80  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  81  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  82  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  83  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  84  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  85  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  86  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  87  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  88  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  89  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  90  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  91  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  92  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  93  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  94  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  95  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  96  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  97  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  98  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  99  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 100  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 101  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 102  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 103  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 104  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$FF,$F6,$0A  ; seg 105  yaw= -64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C0,$FE,$F6,$0A  ; seg 106  yaw= -64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C0,$FF,$F6,$0A  ; seg 107  yaw= -64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 108  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 109  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 110  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 111  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 112  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$FF,$F6,$0A  ; seg 113  yaw= -64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C0,$FE,$F6,$0A  ; seg 114  yaw= -64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C0,$FF,$F6,$0A  ; seg 115  yaw= -64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 116  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 117  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 118  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 119  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 120  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 121  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 122  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 123  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
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
        fcb   $AC,$00,$F6,$0A  ; seg 141  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 142  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 143  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 144  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 145  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 146  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 147  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 148  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 149  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 150  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 151  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 152  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 153  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 154  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 155  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 156  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 157  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 158  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 159  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 160  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg 161  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 162  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 163  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 164  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 165  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 166  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 167  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 168  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 169  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 170  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 171  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 172  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 173  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 174  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg 175  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 176  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 177  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 178  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 179  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 180  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 181  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 182  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 183  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 184  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 185  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 186  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 187  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 188  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 189  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 190  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 191  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 192  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 193  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 194  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 195  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 196  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 197  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 198  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 199  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 200  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 201  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 202  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 203  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 204  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 205  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 206  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 207  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 208  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 209  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 210 (wraparound de seg 0)
        fcb   $FC,$00,$F6,$0A  ; seg 211 (wraparound de seg 1)
        fcb   $F8,$00,$F6,$0A  ; seg 212 (wraparound de seg 2)
        fcb   $F4,$00,$F6,$0A  ; seg 213 (wraparound de seg 3)
        fcb   $F0,$00,$F6,$0A  ; seg 214 (wraparound de seg 4)
        fcb   $EC,$00,$F6,$0A  ; seg 215 (wraparound de seg 5)
        fcb   $E8,$00,$F6,$0A  ; seg 216 (wraparound de seg 6)
        fcb   $E4,$00,$F6,$0A  ; seg 217 (wraparound de seg 7)
