* ======================================================================
* Circuit_20_hard_3 — N=120 segments (format compact 8 oct/seg)
* Source       : 20_hard_3.bin (extrait de FILE30)
*
* Pays         : ALASKA
* Lieu         : prudhoe bay
* Description  : road markings covered by snow
* Hazards      : no pitstops
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000048 01:#90B4FC 02:#4890D8 03:#244890 04:#4890D8 05:#4890D8 06:#4890B4 07:#4890B4
*   08:#486CD8 09:#486CD8 10:#486CB4 11:#486CB4 12:#24486C 13:#244890 14:#244890 15:#2448B4
*   16:#2448B4 17:#2448D8 18:#2448D8 19:#2448FC 20:#2448FC 21:#0048FC 22:#006CFC 23:#006CFC
*   24:#0090FC 25:#0090FC 26:#00B4FC 27:#00B4FC
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
* Taille totale : 1554 oct (nb_segments 2 + LUT 16 + segments 1024 + cache 512).
* ======================================================================

Circuit_20_hard_3_nb_segments
        fdb   120

Circuit_20_hard_3_sprite_lut
        fcb   $00,$82,$84,$92,$88,$8A,$93,$81,$00,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_20_hard_3_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg   1                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg   2                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg   3                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg   4                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg   5                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg   6                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg   7                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$03,$54,$EE,$00,$12,$20  ; seg   8                                    #0:$92@-18 #2:$88@+18 #3:$8A@+32
        fcb   $00,$00,$04,$04,$EE,$00,$18,$00  ; seg   9                                    #0:$88@-18 #2:$88@+24
        fcb   $00,$00,$06,$53,$DC,$00,$12,$DC  ; seg  10                                    #0:$93@-36 #2:$92@+18 #3:$8A@-36
        fcb   $00,$00,$04,$06,$EE,$00,$12,$00  ; seg  11                                    #0:$88@-18 #2:$93@+18
        fcb   $00,$00,$06,$03,$E8,$00,$24,$00  ; seg  12                                    #0:$93@-24 #2:$92@+36
        fcb   $00,$00,$04,$50,$EE,$00,$00,$E0  ; seg  13                                    #0:$88@-18 #3:$8A@-32
        fcb   $00,$00,$06,$03,$EE,$00,$12,$00  ; seg  14                                    #0:$93@-18 #2:$92@+18
        fcb   $00,$00,$04,$06,$E8,$00,$24,$00  ; seg  15                                    #0:$88@-24 #2:$93@+36
        fcb   $7C,$00,$07,$50,$EE,$00,$00,$34  ; seg  16  curve=-4                          #0:$81@-18 #3:$8A@+52
        fcb   $7C,$00,$07,$04,$EE,$00,$12,$00  ; seg  17  curve=-4                          #0:$81@-18 #2:$88@+18
        fcb   $7C,$00,$04,$33,$E8,$00,$12,$E0  ; seg  18  curve=-4                          #0:$88@-24 #2:$92@+18 #3:$92@-32
        fcb   $7C,$00,$06,$06,$EE,$00,$24,$00  ; seg  19  curve=-4                          #0:$93@-18 #2:$93@+36
        fcb   $00,$01,$04,$03,$DC,$00,$12,$00  ; seg  20            pitch=+1                #0:$88@-36 #2:$92@+18
        fcb   $00,$01,$00,$04,$00,$00,$12,$00  ; seg  21            pitch=+1                #2:$88@+18
        fcb   $00,$01,$04,$50,$EE,$00,$00,$30  ; seg  22            pitch=+1                #0:$88@-18 #3:$8A@+48
        fcb   $00,$01,$06,$03,$EE,$00,$18,$00  ; seg  23            pitch=+1                #0:$93@-18 #2:$92@+24
        fcb   $00,$7F,$04,$54,$EE,$00,$12,$30  ; seg  24            pitch=-1                #0:$88@-18 #2:$88@+18 #3:$8A@+48
        fcb   $00,$7F,$04,$03,$E8,$00,$12,$00  ; seg  25            pitch=-1                #0:$88@-24 #2:$92@+18
        fcb   $00,$7F,$07,$07,$EE,$00,$EE,$00  ; seg  26            pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $00,$7F,$07,$57,$EE,$00,$EE,$1C  ; seg  27            pitch=-1                #0:$81@-18 #2:$81@-18 #3:$8A@+28
        fcb   $7C,$00,$07,$04,$EE,$00,$24,$00  ; seg  28  curve=-4                          #0:$81@-18 #2:$88@+36
        fcb   $7C,$00,$07,$03,$EE,$00,$12,$00  ; seg  29  curve=-4                          #0:$81@-18 #2:$92@+18
        fcb   $7C,$00,$00,$50,$00,$00,$00,$D0  ; seg  30  curve=-4                          #3:$8A@-48
        fcb   $7C,$00,$04,$36,$EE,$00,$12,$30  ; seg  31  curve=-4                          #0:$88@-18 #2:$93@+18 #3:$92@+48
        fcb   $00,$7F,$03,$03,$EE,$00,$12,$00  ; seg  32            pitch=-1                #0:$92@-18 #2:$92@+18
        fcb   $00,$7F,$04,$53,$EE,$00,$18,$28  ; seg  33            pitch=-1                #0:$88@-18 #2:$92@+24 #3:$8A@+40
        fcb   $00,$7F,$04,$04,$E8,$00,$12,$00  ; seg  34            pitch=-1                #0:$88@-24 #2:$88@+18
        fcb   $00,$7F,$00,$53,$00,$00,$24,$D8  ; seg  35            pitch=-1                #2:$92@+36 #3:$8A@-40
        fcb   $00,$00,$04,$50,$DC,$00,$00,$30  ; seg  36                                    #0:$88@-36 #3:$8A@+48
        fcb   $00,$00,$03,$03,$EE,$00,$12,$00  ; seg  37                                    #0:$92@-18 #2:$92@+18
        fcb   $00,$00,$00,$04,$00,$00,$12,$00  ; seg  38                                    #2:$88@+18
        fcb   $00,$00,$06,$33,$EE,$00,$12,$E0  ; seg  39                                    #0:$93@-18 #2:$92@+18 #3:$92@-32
        fcb   $00,$02,$04,$03,$E8,$00,$18,$00  ; seg  40            pitch=+2                #0:$88@-24 #2:$92@+24
        fcb   $00,$02,$04,$53,$EE,$00,$12,$30  ; seg  41            pitch=+2                #0:$88@-18 #2:$92@+18 #3:$8A@+48
        fcb   $00,$02,$04,$04,$EE,$00,$12,$00  ; seg  42            pitch=+2                #0:$88@-18 #2:$88@+18
        fcb   $00,$02,$03,$03,$EE,$00,$12,$00  ; seg  43            pitch=+2                #0:$92@-18 #2:$92@+18
        fcb   $00,$7F,$06,$50,$E8,$00,$00,$1C  ; seg  44            pitch=-1                #0:$93@-24 #3:$8A@+28
        fcb   $00,$7F,$00,$33,$00,$00,$24,$D0  ; seg  45            pitch=-1                #2:$92@+36 #3:$92@-48
        fcb   $00,$7F,$04,$04,$EE,$00,$12,$00  ; seg  46            pitch=-1                #0:$88@-18 #2:$88@+18
        fcb   $00,$7F,$04,$03,$EE,$00,$12,$00  ; seg  47            pitch=-1                #0:$88@-18 #2:$92@+18
        fcb   $00,$00,$06,$53,$DC,$00,$18,$1C  ; seg  48                                    #0:$93@-36 #2:$92@+24 #3:$8A@+28
        fcb   $00,$00,$04,$00,$EE,$00,$00,$00  ; seg  49                                    #0:$88@-18
        fcb   $00,$01,$04,$03,$E8,$00,$12,$00  ; seg  50            pitch=+1                #0:$88@-24 #2:$92@+18
        fcb   $00,$01,$00,$53,$00,$00,$12,$20  ; seg  51            pitch=+1                #2:$92@+18 #3:$8A@+32
        fcb   $00,$7F,$04,$03,$EE,$00,$24,$00  ; seg  52            pitch=-1                #0:$88@-18 #2:$92@+36
        fcb   $00,$7F,$04,$03,$EE,$00,$18,$00  ; seg  53            pitch=-1                #0:$88@-18 #2:$92@+24
        fcb   $00,$00,$06,$57,$EE,$00,$EE,$30  ; seg  54                                    #0:$93@-18 #2:$81@-18 #3:$8A@+48
        fcb   $00,$00,$07,$07,$EE,$00,$EE,$00  ; seg  55                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$07,$54,$EE,$00,$12,$D0  ; seg  56  curve=-4                          #0:$81@-18 #2:$88@+18 #3:$8A@-48
        fcb   $7C,$00,$07,$04,$EE,$00,$12,$00  ; seg  57  curve=-4                          #0:$81@-18 #2:$88@+18
        fcb   $7C,$00,$07,$30,$EE,$00,$00,$30  ; seg  58  curve=-4                          #0:$81@-18 #3:$92@+48
        fcb   $7C,$00,$07,$04,$EE,$00,$12,$00  ; seg  59  curve=-4                          #0:$81@-18 #2:$88@+18
        fcb   $7C,$00,$07,$53,$EE,$00,$12,$1C  ; seg  60  curve=-4                          #0:$81@-18 #2:$92@+18 #3:$8A@+28
        fcb   $7C,$00,$07,$50,$EE,$00,$00,$20  ; seg  61  curve=-4                          #0:$81@-18 #3:$8A@+32
        fcb   $7C,$00,$07,$04,$EE,$00,$24,$00  ; seg  62  curve=-4                          #0:$81@-18 #2:$88@+36
        fcb   $7C,$00,$07,$06,$EE,$00,$18,$00  ; seg  63  curve=-4                          #0:$81@-18 #2:$93@+24
        fcb   $7C,$00,$07,$03,$EE,$00,$12,$00  ; seg  64  curve=-4                          #0:$81@-18 #2:$92@+18
        fcb   $7C,$00,$07,$03,$EE,$00,$12,$00  ; seg  65  curve=-4                          #0:$81@-18 #2:$92@+18
        fcb   $7C,$00,$00,$53,$00,$00,$12,$E0  ; seg  66  curve=-4                          #2:$92@+18 #3:$8A@-32
        fcb   $7C,$00,$04,$03,$EE,$00,$12,$00  ; seg  67  curve=-4                          #0:$88@-18 #2:$92@+18
        fcb   $00,$00,$04,$04,$E8,$00,$12,$00  ; seg  68                                    #0:$88@-24 #2:$88@+18
        fcb   $00,$00,$03,$30,$E8,$00,$00,$1C  ; seg  69                                    #0:$92@-24 #3:$92@+28
        fcb   $00,$00,$06,$53,$EE,$00,$18,$30  ; seg  70                                    #0:$93@-18 #2:$92@+24 #3:$8A@+48
        fcb   $00,$00,$04,$04,$DC,$00,$12,$00  ; seg  71                                    #0:$88@-36 #2:$88@+18
        fcb   $00,$7F,$03,$03,$EE,$00,$24,$00  ; seg  72            pitch=-1                #0:$92@-18 #2:$92@+36
        fcb   $00,$7F,$00,$04,$00,$00,$12,$00  ; seg  73            pitch=-1                #2:$88@+18
        fcb   $00,$01,$06,$53,$EE,$00,$12,$D0  ; seg  74            pitch=+1                #0:$93@-18 #2:$92@+18 #3:$8A@-48
        fcb   $00,$01,$04,$50,$E8,$00,$00,$28  ; seg  75            pitch=+1                #0:$88@-24 #3:$8A@+40
        fcb   $00,$01,$04,$03,$EE,$00,$12,$00  ; seg  76            pitch=+1                #0:$88@-18 #2:$92@+18
        fcb   $00,$01,$04,$06,$EE,$00,$12,$00  ; seg  77            pitch=+1                #0:$88@-18 #2:$93@+18
        fcb   $00,$7F,$04,$04,$EE,$00,$18,$00  ; seg  78            pitch=-1                #0:$88@-18 #2:$88@+24
        fcb   $00,$7F,$04,$03,$EE,$00,$12,$00  ; seg  79            pitch=-1                #0:$88@-18 #2:$92@+18
        fcb   $00,$7E,$06,$54,$E8,$00,$24,$CC  ; seg  80            pitch=-2                #0:$93@-24 #2:$88@+36 #3:$8A@-52
        fcb   $00,$7E,$00,$30,$00,$00,$00,$30  ; seg  81            pitch=-2                #3:$92@+48
        fcb   $00,$02,$04,$04,$DC,$00,$12,$00  ; seg  82            pitch=+2                #0:$88@-36 #2:$88@+18
        fcb   $00,$02,$04,$06,$EE,$00,$12,$00  ; seg  83            pitch=+2                #0:$88@-18 #2:$93@+18
        fcb   $00,$02,$04,$53,$EE,$00,$12,$20  ; seg  84            pitch=+2                #0:$88@-18 #2:$92@+18 #3:$8A@+32
        fcb   $00,$02,$04,$50,$EE,$00,$00,$D0  ; seg  85            pitch=+2                #0:$88@-18 #3:$8A@-48
        fcb   $00,$7E,$00,$04,$00,$00,$12,$00  ; seg  86            pitch=-2                #2:$88@+18
        fcb   $00,$7E,$03,$04,$E8,$00,$18,$00  ; seg  87            pitch=-2                #0:$92@-24 #2:$88@+24
        fcb   $00,$7F,$06,$03,$EE,$00,$12,$00  ; seg  88            pitch=-1                #0:$93@-18 #2:$92@+18
        fcb   $00,$7F,$04,$04,$EE,$00,$24,$00  ; seg  89            pitch=-1                #0:$88@-18 #2:$88@+36
        fcb   $00,$01,$04,$04,$EE,$00,$12,$00  ; seg  90            pitch=+1                #0:$88@-18 #2:$88@+18
        fcb   $00,$01,$06,$53,$E8,$00,$12,$E0  ; seg  91            pitch=+1                #0:$93@-24 #2:$92@+18 #3:$8A@-32
        fcb   $00,$01,$00,$04,$00,$00,$12,$00  ; seg  92            pitch=+1                #2:$88@+18
        fcb   $00,$01,$04,$54,$DC,$00,$12,$20  ; seg  93            pitch=+1                #0:$88@-36 #2:$88@+18 #3:$8A@+32
        fcb   $00,$7F,$03,$30,$EE,$00,$00,$18  ; seg  94            pitch=-1                #0:$92@-18 #3:$92@+24
        fcb   $00,$7F,$06,$04,$EE,$00,$18,$00  ; seg  95            pitch=-1                #0:$93@-18 #2:$88@+24
        fcb   $00,$00,$04,$03,$E8,$00,$12,$00  ; seg  96                                    #0:$88@-24 #2:$92@+18
        fcb   $00,$00,$06,$04,$E8,$00,$24,$00  ; seg  97                                    #0:$93@-24 #2:$88@+36
        fcb   $00,$00,$07,$57,$EE,$00,$EE,$20  ; seg  98                                    #0:$81@-18 #2:$81@-18 #3:$8A@+32
        fcb   $00,$00,$07,$57,$EE,$00,$EE,$CC  ; seg  99                                    #0:$81@-18 #2:$81@-18 #3:$8A@-52
        fcb   $7C,$01,$07,$04,$EE,$00,$12,$00  ; seg 100  curve=-4  pitch=+1                #0:$81@-18 #2:$88@+18
        fcb   $7C,$01,$07,$56,$EE,$00,$12,$D8  ; seg 101  curve=-4  pitch=+1                #0:$81@-18 #2:$93@+18 #3:$8A@-40
        fcb   $7C,$7F,$07,$30,$EE,$00,$00,$34  ; seg 102  curve=-4  pitch=-1                #0:$81@-18 #3:$92@+52
        fcb   $7C,$7F,$07,$03,$EE,$00,$12,$00  ; seg 103  curve=-4  pitch=-1                #0:$81@-18 #2:$92@+18
        fcb   $7C,$00,$07,$03,$EE,$00,$12,$00  ; seg 104  curve=-4                          #0:$81@-18 #2:$92@+18
        fcb   $7C,$00,$07,$04,$EE,$00,$18,$00  ; seg 105  curve=-4                          #0:$81@-18 #2:$88@+24
        fcb   $7C,$7F,$07,$06,$EE,$00,$24,$00  ; seg 106  curve=-4  pitch=-1                #0:$81@-18 #2:$93@+36
        fcb   $7C,$7F,$07,$04,$EE,$00,$12,$00  ; seg 107  curve=-4  pitch=-1                #0:$81@-18 #2:$88@+18
        fcb   $7C,$00,$07,$56,$EE,$00,$12,$20  ; seg 108  curve=-4                          #0:$81@-18 #2:$93@+18 #3:$8A@+32
        fcb   $7C,$00,$07,$50,$EE,$00,$00,$DC  ; seg 109  curve=-4                          #0:$81@-18 #3:$8A@-36
        fcb   $7C,$01,$00,$03,$00,$00,$12,$00  ; seg 110  curve=-4  pitch=+1                #2:$92@+18
        fcb   $7C,$01,$00,$50,$00,$00,$00,$E0  ; seg 111  curve=-4  pitch=+1                #3:$8A@-32
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 112                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 113                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 114                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 115                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 116                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 117                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 118                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 119                                    #0:$84@-18 #2:$84@+18
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 120                                    #0:$82@+0
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 121                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 122                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 123                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 124                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 125                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 126                                    #0:$84@-18 #2:$84@+18
        fcb   $00,$00,$02,$02,$EE,$00,$12,$00  ; seg 127                                    #0:$84@-18 #2:$84@+18

Circuit_20_hard_3_segment_cache
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
        fcb   $F0,$01,$F6,$0A  ; seg  21  yaw= -16 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $F0,$02,$F6,$0A  ; seg  22  yaw= -16 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $F0,$03,$F6,$0A  ; seg  23  yaw= -16 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $F0,$04,$F6,$0A  ; seg  24  yaw= -16 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $F0,$03,$F6,$0A  ; seg  25  yaw= -16 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $F0,$02,$F6,$0A  ; seg  26  yaw= -16 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $F0,$01,$F6,$0A  ; seg  27  yaw= -16 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  28  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  29  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  30  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  31  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  32  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  33  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  34  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FD,$F6,$0A  ; seg  35  yaw= -32 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  36  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  37  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  38  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  39  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  40  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  41  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  42  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  43  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$04,$F6,$0A  ; seg  44  yaw= -32 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $E0,$03,$F6,$0A  ; seg  45  yaw= -32 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  46  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$01,$F6,$0A  ; seg  47  yaw= -32 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  48  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  49  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  50  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$01,$F6,$0A  ; seg  51  yaw= -32 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  52  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$01,$F6,$0A  ; seg  53  yaw= -32 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  54  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  55  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  56  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  57  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  58  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  59  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  60  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  61  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  62  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  63  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  64  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  65  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  66  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  67  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  68  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  69  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  70  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  71  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  72  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$FF,$F6,$0A  ; seg  73  yaw= -80 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg  74  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$FF,$F6,$0A  ; seg  75  yaw= -80 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  76  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$01,$F6,$0A  ; seg  77  yaw= -80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg  78  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$01,$F6,$0A  ; seg  79  yaw= -80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  80  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg  81  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$FC,$F6,$0A  ; seg  82  yaw= -80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg  83  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  84  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg  85  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg  86  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg  87  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  88  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$FF,$F6,$0A  ; seg  89  yaw= -80 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg  90  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$FF,$F6,$0A  ; seg  91  yaw= -80 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  92  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$01,$F6,$0A  ; seg  93  yaw= -80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg  94  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$01,$F6,$0A  ; seg  95  yaw= -80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  96  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  97  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  98  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  99  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 100  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$01,$F6,$0A  ; seg 101  yaw= -84 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg 102  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A4,$01,$F6,$0A  ; seg 103  yaw= -92 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 104  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg 105  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 106  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$FF,$F6,$0A  ; seg 107  yaw=-108 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $90,$FE,$F6,$0A  ; seg 108  yaw=-112 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $8C,$FE,$F6,$0A  ; seg 109  yaw=-116 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $88,$FE,$F6,$0A  ; seg 110  yaw=-120 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $84,$FF,$F6,$0A  ; seg 111  yaw=-124 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 112  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 113  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 114  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 115  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 116  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 117  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 118  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 119  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 120 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 121 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 122 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 123 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 124 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 125 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 126 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 127 (wraparound de seg 7)
