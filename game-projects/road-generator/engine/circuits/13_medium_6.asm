* ======================================================================
* Circuit_13_medium_6 — N=150 segments (format compact 8 oct/seg)
* Source       : 13_medium_6.bin (extrait de FILE30)
*
* Pays         : ECUADOR
* Lieu         : riobamba
* Description  : fast course - no obstacles and
* Hazards      : few steep hills
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000024 01:#B4B4B4 02:#909090 03:#484848 04:#484824 05:#B40000 06:#242424 07:#242424
*   08:#484824 09:#D8D8D8 10:#242400 11:#FCFCFC 12:#6C6C6C 13:#6C6C6C 14:#906C6C 15:#906C6C
*   16:#B46C6C 17:#B46C6C 18:#D86C6C 19:#D86C6C 20:#FC6C6C 21:#FC6C6C 22:#FC6C6C 23:#FC9090
*   24:#FC9090 25:#FCB4B4 26:#FCB4B4 27:#FCD8D8
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
* Taille totale : 1914 oct (nb_segments 2 + LUT 16 + segments 1264 + cache 632).
* ======================================================================

Circuit_13_medium_6_nb_segments
        fdb   150

Circuit_13_medium_6_sprite_lut
        fcb   $00,$82,$83,$9B,$9E,$9D,$81,$80,$8F,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_13_medium_6_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg   8                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg   9                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  10                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  11                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  12                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  13                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  14                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  15                      flags=[PIT]
        fcb   $00,$00,$03,$40,$14,$00,$00,$E0  ; seg  16                                    #0:$9B@+20 #3:$9E@-32
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  17                                    #0:$9B@+20
        fcb   $00,$00,$03,$50,$14,$00,$00,$E4  ; seg  18                                    #0:$9B@+20 #3:$9D@-28
        fcb   $00,$00,$03,$50,$14,$00,$00,$20  ; seg  19                                    #0:$9B@+20 #3:$9D@+32
        fcb   $00,$00,$00,$50,$00,$00,$00,$E0  ; seg  20                                    #3:$9D@-32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  21
        fcb   $00,$00,$06,$46,$EE,$00,$EE,$20  ; seg  22                                    #0:$81@-18 #2:$81@-18 #3:$9E@+32
        fcb   $00,$00,$06,$56,$EE,$00,$EE,$18  ; seg  23                                    #0:$81@-18 #2:$81@-18 #3:$9D@+24
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  24  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$50,$EE,$00,$00,$1C  ; seg  25  curve=-4                          #0:$81@-18 #3:$9D@+28
        fcb   $7C,$00,$05,$45,$1C,$00,$14,$14  ; seg  26  curve=-4                          #0:$9D@+28 #2:$9D@+20 #3:$9E@+20
        fcb   $7C,$00,$54,$05,$20,$14,$1C,$00  ; seg  27  curve=-4                          #0:$9E@+32 #1:$9D@+20 #2:$9D@+28
        fcb   $00,$00,$55,$54,$24,$20,$20,$20  ; seg  28                                    #0:$9D@+36 #1:$9D@+32 #2:$9E@+32 #3:$9D@+32
        fcb   $00,$00,$45,$55,$1C,$18,$14,$E0  ; seg  29                                    #0:$9D@+28 #1:$9E@+24 #2:$9D@+20 #3:$9D@-32
        fcb   $00,$00,$06,$56,$EE,$00,$EE,$18  ; seg  30                                    #0:$81@-18 #2:$81@-18 #3:$9D@+24
        fcb   $00,$00,$06,$46,$EE,$00,$EE,$14  ; seg  31                                    #0:$81@-18 #2:$81@-18 #3:$9E@+20
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  32  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$50,$EE,$00,$00,$1C  ; seg  33  curve=-4                          #0:$81@-18 #3:$9D@+28
        fcb   $7C,$00,$00,$50,$00,$00,$00,$20  ; seg  34  curve=-4                          #3:$9D@+32
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  35  curve=-4
        fcb   $00,$00,$00,$40,$00,$00,$00,$E0  ; seg  36                                    #3:$9E@-32
        fcb   $00,$00,$00,$50,$00,$00,$00,$E8  ; seg  37                                    #3:$9D@-24
        fcb   $00,$00,$06,$56,$EE,$00,$EE,$14  ; seg  38                                    #0:$81@-18 #2:$81@-18 #3:$9D@+20
        fcb   $00,$00,$06,$46,$EE,$00,$EE,$20  ; seg  39                                    #0:$81@-18 #2:$81@-18 #3:$9E@+32
        fcb   $7C,$00,$06,$50,$EE,$00,$00,$D8  ; seg  40  curve=-4                          #0:$81@-18 #3:$9D@-40
        fcb   $7C,$00,$06,$50,$EE,$00,$00,$CC  ; seg  41  curve=-4                          #0:$81@-18 #3:$9D@-52
        fcb   $7C,$00,$07,$57,$12,$00,$12,$20  ; seg  42  curve=-4                          #0:$80@+18 #2:$80@+18 #3:$9D@+32
        fcb   $7C,$00,$07,$07,$12,$00,$12,$00  ; seg  43  curve=-4                          #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$40,$12,$00,$00,$30  ; seg  44  curve=+4                          #0:$80@+18 #3:$9E@+48
        fcb   $04,$00,$07,$50,$12,$00,$00,$EC  ; seg  45  curve=+4                          #0:$80@+18 #3:$9D@-20
        fcb   $04,$00,$00,$50,$00,$00,$00,$E8  ; seg  46  curve=+4                          #3:$9D@-24
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  47  curve=+4
        fcb   $00,$00,$03,$40,$EC,$00,$00,$14  ; seg  48                                    #0:$9B@-20 #3:$9E@+20
        fcb   $00,$00,$03,$50,$EC,$00,$00,$20  ; seg  49                                    #0:$9B@-20 #3:$9D@+32
        fcb   $00,$7F,$03,$50,$EC,$00,$00,$1C  ; seg  50            pitch=-1                #0:$9B@-20 #3:$9D@+28
        fcb   $00,$7F,$03,$00,$EC,$00,$00,$00  ; seg  51            pitch=-1                #0:$9B@-20
        fcb   $00,$01,$03,$40,$EC,$00,$00,$20  ; seg  52            pitch=+1                #0:$9B@-20 #3:$9E@+32
        fcb   $00,$01,$03,$50,$EC,$00,$00,$18  ; seg  53            pitch=+1                #0:$9B@-20 #3:$9D@+24
        fcb   $00,$00,$03,$50,$EC,$00,$00,$1C  ; seg  54                                    #0:$9B@-20 #3:$9D@+28
        fcb   $00,$00,$03,$40,$EC,$00,$00,$20  ; seg  55                                    #0:$9B@-20 #3:$9E@+32
        fcb   $00,$00,$03,$50,$14,$00,$00,$EC  ; seg  56                                    #0:$9B@+20 #3:$9D@-20
        fcb   $00,$00,$03,$50,$14,$00,$00,$E8  ; seg  57                                    #0:$9B@+20 #3:$9D@-24
        fcb   $00,$7F,$03,$00,$14,$00,$00,$00  ; seg  58            pitch=-1                #0:$9B@+20
        fcb   $00,$7F,$03,$40,$14,$00,$00,$24  ; seg  59            pitch=-1                #0:$9B@+20 #3:$9E@+36
        fcb   $00,$01,$00,$50,$00,$00,$00,$E0  ; seg  60            pitch=+1                #3:$9D@-32
        fcb   $00,$01,$00,$50,$00,$00,$00,$EC  ; seg  61            pitch=+1                #3:$9D@-20
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  62                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$47,$12,$00,$12,$D8  ; seg  63                                    #0:$80@+18 #2:$80@+18 #3:$9E@-40
        fcb   $04,$00,$07,$50,$12,$00,$00,$CC  ; seg  64  curve=+4                          #0:$80@+18 #3:$9D@-52
        fcb   $04,$00,$07,$50,$12,$00,$00,$E0  ; seg  65  curve=+4                          #0:$80@+18 #3:$9D@-32
        fcb   $04,$00,$06,$46,$EE,$00,$EE,$14  ; seg  66  curve=+4                          #0:$81@-18 #2:$81@-18 #3:$9E@+20
        fcb   $04,$00,$06,$56,$EE,$00,$EE,$1C  ; seg  67  curve=+4                          #0:$81@-18 #2:$81@-18 #3:$9D@+28
        fcb   $7C,$00,$86,$50,$EE,$E0,$00,$20  ; seg  68  curve=-4                          #0:$81@-18 #1:$8F@-32 #3:$9D@+32
        fcb   $7C,$00,$86,$00,$EE,$20,$00,$00  ; seg  69  curve=-4                          #0:$81@-18 #1:$8F@+32
        fcb   $7C,$00,$06,$50,$EE,$00,$00,$18  ; seg  70  curve=-4                          #0:$81@-18 #3:$9D@+24
        fcb   $7C,$00,$86,$40,$EE,$C0,$00,$CC  ; seg  71  curve=-4                          #0:$81@-18 #1:$8F@-64 #3:$9E@-52
        fcb   $7C,$00,$80,$50,$00,$EC,$00,$20  ; seg  72  curve=-4                          #1:$8F@-20 #3:$9D@+32
        fcb   $7C,$00,$00,$50,$00,$00,$00,$14  ; seg  73  curve=-4                          #3:$9D@+20
        fcb   $7C,$00,$80,$00,$00,$E0,$00,$00  ; seg  74  curve=-4                          #1:$8F@-32
        fcb   $7C,$00,$80,$40,$00,$E4,$00,$1C  ; seg  75  curve=-4                          #1:$8F@-28 #3:$9E@+28
        fcb   $7C,$00,$00,$50,$00,$00,$00,$18  ; seg  76  curve=-4                          #3:$9D@+24
        fcb   $7C,$00,$80,$50,$00,$E8,$00,$20  ; seg  77  curve=-4                          #1:$8F@-24 #3:$9D@+32
        fcb   $7C,$00,$80,$40,$00,$EC,$00,$C0  ; seg  78  curve=-4                          #1:$8F@-20 #3:$9E@-64
        fcb   $7C,$00,$00,$50,$00,$00,$00,$24  ; seg  79  curve=-4                          #3:$9D@+36
        fcb   $7C,$00,$88,$88,$EE,$E2,$EA,$E4  ; seg  80  curve=-4                          #0:$8F@-18 #1:$8F@-30 #2:$8F@-22 #3:$8F@-28
        fcb   $7C,$00,$88,$88,$EC,$E2,$E8,$EC  ; seg  81  curve=-4                          #0:$8F@-20 #1:$8F@-30 #2:$8F@-24 #3:$8F@-20
        fcb   $7C,$00,$88,$88,$E4,$E0,$E6,$EA  ; seg  82  curve=-4                          #0:$8F@-28 #1:$8F@-32 #2:$8F@-26 #3:$8F@-22
        fcb   $7C,$00,$88,$88,$E2,$E8,$E4,$EC  ; seg  83  curve=-4                          #0:$8F@-30 #1:$8F@-24 #2:$8F@-28 #3:$8F@-20
        fcb   $7C,$00,$80,$50,$00,$2C,$00,$18  ; seg  84  curve=-4                          #1:$8F@+44 #3:$9D@+24
        fcb   $7C,$00,$80,$00,$00,$20,$00,$00  ; seg  85  curve=-4                          #1:$8F@+32
        fcb   $00,$00,$00,$40,$00,$00,$00,$E0  ; seg  86                                    #3:$9E@-32
        fcb   $00,$00,$80,$50,$00,$CC,$00,$C8  ; seg  87                                    #1:$8F@-52 #3:$9D@-56
        fcb   $00,$01,$80,$50,$00,$28,$00,$20  ; seg  88            pitch=+1                #1:$8F@+40 #3:$9D@+32
        fcb   $00,$01,$00,$40,$00,$00,$00,$28  ; seg  89            pitch=+1                #3:$9E@+40
        fcb   $00,$00,$80,$00,$00,$2C,$00,$00  ; seg  90                                    #1:$8F@+44
        fcb   $00,$00,$80,$50,$00,$18,$00,$D8  ; seg  91                                    #1:$8F@+24 #3:$9D@-40
        fcb   $00,$7F,$80,$50,$00,$EC,$00,$E0  ; seg  92            pitch=-1                #1:$8F@-20 #3:$9D@-32
        fcb   $00,$7F,$80,$00,$00,$20,$00,$00  ; seg  93            pitch=-1                #1:$8F@+32
        fcb   $00,$00,$07,$47,$12,$00,$12,$E8  ; seg  94                                    #0:$80@+18 #2:$80@+18 #3:$9E@-24
        fcb   $00,$00,$07,$57,$12,$00,$12,$EC  ; seg  95                                    #0:$80@+18 #2:$80@+18 #3:$9D@-20
        fcb   $04,$00,$07,$50,$12,$00,$00,$E0  ; seg  96  curve=+4                          #0:$80@+18 #3:$9D@-32
        fcb   $04,$00,$07,$40,$12,$00,$00,$D8  ; seg  97  curve=+4                          #0:$80@+18 #3:$9E@-40
        fcb   $04,$00,$06,$06,$EE,$00,$EE,$00  ; seg  98  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $04,$00,$06,$56,$EE,$00,$EE,$14  ; seg  99  curve=+4                          #0:$81@-18 #2:$81@-18 #3:$9D@+20
        fcb   $7C,$00,$06,$50,$EE,$00,$00,$18  ; seg 100  curve=-4                          #0:$81@-18 #3:$9D@+24
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 101  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$40,$00,$00,$00,$1C  ; seg 102  curve=-4                          #3:$9E@+28
        fcb   $7C,$00,$00,$50,$00,$00,$00,$E0  ; seg 103  curve=-4                          #3:$9D@-32
        fcb   $00,$00,$03,$45,$14,$00,$1C,$20  ; seg 104                                    #0:$9B@+20 #2:$9D@+28 #3:$9E@+32
        fcb   $00,$00,$03,$55,$14,$00,$20,$E0  ; seg 105                                    #0:$9B@+20 #2:$9D@+32 #3:$9D@-32
        fcb   $00,$01,$03,$54,$14,$00,$E4,$D8  ; seg 106            pitch=+1                #0:$9B@+20 #2:$9E@-28 #3:$9D@-40
        fcb   $00,$01,$03,$05,$14,$00,$1C,$00  ; seg 107            pitch=+1                #0:$9B@+20 #2:$9D@+28
        fcb   $00,$01,$03,$50,$14,$00,$00,$E0  ; seg 108            pitch=+1                #0:$9B@+20 #3:$9D@-32
        fcb   $00,$01,$03,$54,$14,$00,$E0,$E8  ; seg 109            pitch=+1                #0:$9B@+20 #2:$9E@-32 #3:$9D@-24
        fcb   $00,$01,$03,$05,$14,$00,$D4,$00  ; seg 110            pitch=+1                #0:$9B@+20 #2:$9D@-44
        fcb   $00,$01,$03,$40,$14,$00,$00,$30  ; seg 111            pitch=+1                #0:$9B@+20 #3:$9E@+48
        fcb   $00,$7F,$03,$55,$EC,$00,$1C,$14  ; seg 112            pitch=-1                #0:$9B@-20 #2:$9D@+28 #3:$9D@+20
        fcb   $00,$7F,$03,$54,$EC,$00,$EC,$28  ; seg 113            pitch=-1                #0:$9B@-20 #2:$9E@-20 #3:$9D@+40
        fcb   $00,$7F,$03,$04,$EC,$00,$20,$00  ; seg 114            pitch=-1                #0:$9B@-20 #2:$9E@+32
        fcb   $00,$7F,$03,$40,$EC,$00,$00,$1C  ; seg 115            pitch=-1                #0:$9B@-20 #3:$9E@+28
        fcb   $00,$7F,$03,$55,$14,$00,$E0,$34  ; seg 116            pitch=-1                #0:$9B@+20 #2:$9D@-32 #3:$9D@+52
        fcb   $00,$7F,$03,$05,$14,$00,$EC,$00  ; seg 117            pitch=-1                #0:$9B@+20 #2:$9D@-20
        fcb   $00,$00,$03,$45,$14,$00,$D0,$20  ; seg 118                                    #0:$9B@+20 #2:$9D@-48 #3:$9E@+32
        fcb   $00,$00,$03,$50,$14,$00,$00,$E8  ; seg 119                                    #0:$9B@+20 #3:$9D@-24
        fcb   $00,$00,$03,$45,$EC,$00,$20,$1C  ; seg 120                                    #0:$9B@-20 #2:$9D@+32 #3:$9E@+28
        fcb   $00,$00,$03,$55,$EC,$00,$1E,$14  ; seg 121                                    #0:$9B@-20 #2:$9D@+30 #3:$9D@+20
        fcb   $00,$7F,$03,$05,$EC,$00,$20,$00  ; seg 122            pitch=-1                #0:$9B@-20 #2:$9D@+32
        fcb   $00,$7F,$03,$54,$EC,$00,$28,$20  ; seg 123            pitch=-1                #0:$9B@-20 #2:$9E@+40 #3:$9D@+32
        fcb   $00,$01,$00,$50,$00,$00,$00,$14  ; seg 124            pitch=+1                #3:$9D@+20
        fcb   $00,$01,$00,$50,$00,$00,$00,$1C  ; seg 125            pitch=+1                #3:$9D@+28
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 126                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 127                                    #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$06,$50,$EE,$00,$00,$14  ; seg 128  curve=-5                          #0:$81@-18 #3:$9D@+20
        fcb   $7B,$00,$06,$40,$EE,$00,$00,$1C  ; seg 129  curve=-5                          #0:$81@-18 #3:$9E@+28
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg 130  curve=-5
        fcb   $7B,$00,$00,$50,$00,$00,$00,$20  ; seg 131  curve=-5                          #3:$9D@+32
        fcb   $00,$00,$80,$50,$00,$E0,$00,$24  ; seg 132                                    #1:$8F@-32 #3:$9D@+36
        fcb   $00,$00,$80,$00,$00,$14,$00,$00  ; seg 133                                    #1:$8F@+20
        fcb   $00,$00,$86,$56,$EE,$1C,$EE,$C0  ; seg 134                                    #0:$81@-18 #1:$8F@+28 #2:$81@-18 #3:$9D@-64
        fcb   $00,$00,$86,$06,$EE,$24,$EE,$00  ; seg 135                                    #0:$81@-18 #1:$8F@+36 #2:$81@-18
        fcb   $7B,$00,$86,$40,$EE,$20,$00,$1C  ; seg 136  curve=-5                          #0:$81@-18 #1:$8F@+32 #3:$9E@+28
        fcb   $7B,$00,$86,$50,$EE,$C8,$00,$20  ; seg 137  curve=-5                          #0:$81@-18 #1:$8F@-56 #3:$9D@+32
        fcb   $7B,$00,$80,$50,$00,$D0,$00,$C8  ; seg 138  curve=-5                          #1:$8F@-48 #3:$9D@-56
        fcb   $7B,$00,$80,$00,$00,$24,$00,$00  ; seg 139  curve=-5                          #1:$8F@+36
        fcb   $00,$00,$80,$50,$00,$1C,$00,$20  ; seg 140                                    #1:$8F@+28 #3:$9D@+32
        fcb   $00,$00,$80,$40,$00,$28,$00,$1C  ; seg 141                                    #1:$8F@+40 #3:$9E@+28
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 142
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 143
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 144
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 145
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 146
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 147
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 148
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 149
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 150                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 151
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 152
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 153
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 154                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 155                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 156                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 157                                    #0:$83@+18 #2:$83@+18

Circuit_13_medium_6_segment_cache
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
        fcb   $00,$00,$F6,$0A  ; seg  19  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  20  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  21  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  22  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  23  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  24  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  25  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  26  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  27  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  28  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  29  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  30  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  31  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  32  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  33  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  34  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  35  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  36  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  37  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  38  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  39  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  40  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  41  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  42  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  43  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  44  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  45  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  46  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  47  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  48  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  49  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  50  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  51  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  52  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  53  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  54  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  55  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  56  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  57  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  58  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  59  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  60  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  61  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  62  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  63  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  64  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  65  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  66  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  67  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  68  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  69  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  70  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  71  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  72  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  73  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  74  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  75  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  76  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  77  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  78  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  79  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  80  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  81  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  82  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  83  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  84  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg  85  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  86  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  87  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  88  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$01,$F6,$0A  ; seg  89  yaw= -88 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg  90  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg  91  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg  92  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A8,$01,$F6,$0A  ; seg  93  yaw= -88 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  94  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  95  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  96  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg  97  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  98  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  99  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 100  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 101  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 102  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg 103  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 104  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 105  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 106  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$01,$F6,$0A  ; seg 107  yaw= -88 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg 108  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A8,$03,$F6,$0A  ; seg 109  yaw= -88 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $A8,$04,$F6,$0A  ; seg 110  yaw= -88 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $A8,$05,$F6,$0A  ; seg 111  yaw= -88 pitch=  +5 min_lat= -10 max_lat= +10
        fcb   $A8,$06,$F6,$0A  ; seg 112  yaw= -88 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $A8,$05,$F6,$0A  ; seg 113  yaw= -88 pitch=  +5 min_lat= -10 max_lat= +10
        fcb   $A8,$04,$F6,$0A  ; seg 114  yaw= -88 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $A8,$03,$F6,$0A  ; seg 115  yaw= -88 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg 116  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A8,$01,$F6,$0A  ; seg 117  yaw= -88 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 118  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 119  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 120  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 121  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 122  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$FF,$F6,$0A  ; seg 123  yaw= -88 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $A8,$FE,$F6,$0A  ; seg 124  yaw= -88 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A8,$FF,$F6,$0A  ; seg 125  yaw= -88 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 126  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 127  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 128  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A3,$00,$F6,$0A  ; seg 129  yaw= -93 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9E,$00,$F6,$0A  ; seg 130  yaw= -98 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $99,$00,$F6,$0A  ; seg 131  yaw=-103 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 132  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 133  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 134  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 135  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 136  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8F,$00,$F6,$0A  ; seg 137  yaw=-113 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8A,$00,$F6,$0A  ; seg 138  yaw=-118 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $85,$00,$F6,$0A  ; seg 139  yaw=-123 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 140  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 141  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 142  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 143  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 144  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 145  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 146  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 147  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 148  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 149  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 150 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 151 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 152 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 153 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 154 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 155 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 156 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 157 (wraparound de seg 7)
