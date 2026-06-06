* ======================================================================
* Circuit_23_hard_6 — N=248 segments (format compact 8 oct/seg)
* Source       : 23_hard_6.bin (extrait de FILE30)
*
* Pays         : PERU
* Lieu         : paddingtonia
* Description  : barriers in road
* Hazards      : and pools of water
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
* Taille totale : 3090 oct (nb_segments 2 + LUT 16 + segments 2048 + cache 1024).
* ======================================================================

Circuit_23_hard_6_nb_segments
        fdb   248

Circuit_23_hard_6_sprite_lut
        fcb   $00,$82,$83,$9C,$81,$A3,$86,$80,$9F,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_23_hard_6_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg   8                      flags=[PIT]   #0:$9C@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg   9                      flags=[PIT]   #0:$9C@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  10                      flags=[PIT]   #0:$9C@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  11                      flags=[PIT]   #0:$9C@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  12                      flags=[PIT]   #0:$9C@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  13                      flags=[PIT]   #0:$9C@-20
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  14                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  15                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$20  ; seg  16  curve=-4                          #0:$81@-18 #3:$A3@+32
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  17  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$03,$50,$14,$00,$00,$E0  ; seg  18  curve=-4                          #0:$9C@+20 #3:$A3@-32
        fcb   $7C,$00,$03,$00,$14,$00,$00,$00  ; seg  19  curve=-4                          #0:$9C@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  20                                    #0:$9C@+20
        fcb   $00,$00,$03,$50,$14,$00,$00,$D0  ; seg  21                                    #0:$9C@+20 #3:$A3@-48
        fcb   $00,$00,$03,$50,$14,$00,$00,$30  ; seg  22                                    #0:$9C@+20 #3:$A3@+48
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  23                                    #0:$9C@+20
        fcb   $00,$00,$03,$50,$EC,$00,$00,$D0  ; seg  24                                    #0:$9C@-20 #3:$A3@-48
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  25                                    #0:$9C@-20
        fcb   $00,$00,$03,$50,$EC,$00,$00,$20  ; seg  26                                    #0:$9C@-20 #3:$A3@+32
        fcb   $00,$00,$03,$50,$EC,$00,$00,$D0  ; seg  27                                    #0:$9C@-20 #3:$A3@-48
        fcb   $00,$00,$03,$50,$EC,$00,$00,$30  ; seg  28                                    #0:$9C@-20 #3:$A3@+48
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  29                                    #0:$9C@-20
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  30                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  31                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  32  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$54,$EE,$00,$EE,$D0  ; seg  33  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A3@-48
        fcb   $7A,$00,$04,$54,$EE,$00,$EE,$30  ; seg  34  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A3@+48
        fcb   $7A,$00,$04,$54,$EE,$00,$EE,$D0  ; seg  35  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A3@-48
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  36  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$54,$EE,$00,$EE,$D0  ; seg  37  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A3@-48
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg  38  curve=-6                          #0:$86@-18 #2:$86@-18
        fcb   $7A,$00,$06,$56,$EE,$00,$EE,$20  ; seg  39  curve=-6                          #0:$86@-18 #2:$86@-18 #3:$A3@+32
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  40                                    #0:$86@-18 #2:$86@-18
        fcb   $00,$00,$06,$56,$EE,$00,$EE,$30  ; seg  41                                    #0:$86@-18 #2:$86@-18 #3:$A3@+48
        fcb   $00,$00,$07,$57,$12,$00,$12,$D0  ; seg  42                                    #0:$80@+18 #2:$80@+18 #3:$A3@-48
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  43                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$01,$07,$50,$12,$00,$00,$D0  ; seg  44  curve=+4  pitch=+1                #0:$80@+18 #3:$A3@-48
        fcb   $04,$01,$07,$50,$12,$00,$00,$20  ; seg  45  curve=+4  pitch=+1                #0:$80@+18 #3:$A3@+32
        fcb   $04,$7F,$04,$04,$EE,$00,$EE,$00  ; seg  46  curve=+4  pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $04,$7F,$04,$04,$EE,$00,$EE,$00  ; seg  47  curve=+4  pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$30  ; seg  48  curve=-4                          #0:$81@-18 #3:$A3@+48
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$D0  ; seg  49  curve=-4                          #0:$81@-18 #3:$A3@-48
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  50  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$D0  ; seg  51  curve=-4                          #0:$81@-18 #3:$A3@-48
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  52  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$E0  ; seg  53  curve=-4                          #0:$81@-18 #3:$A3@-32
        fcb   $7C,$00,$03,$00,$14,$00,$00,$00  ; seg  54  curve=-4                          #0:$9C@+20
        fcb   $7C,$00,$03,$00,$14,$00,$00,$00  ; seg  55  curve=-4                          #0:$9C@+20
        fcb   $00,$00,$03,$50,$14,$00,$00,$D0  ; seg  56                                    #0:$9C@+20 #3:$A3@-48
        fcb   $00,$00,$03,$50,$14,$00,$00,$20  ; seg  57                                    #0:$9C@+20 #3:$A3@+32
        fcb   $00,$01,$07,$07,$12,$00,$12,$00  ; seg  58            pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $00,$01,$07,$07,$12,$00,$12,$00  ; seg  59            pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg  60  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$50,$12,$00,$00,$30  ; seg  61  curve=+4                          #0:$80@+18 #3:$A3@+48
        fcb   $04,$00,$03,$00,$14,$00,$00,$00  ; seg  62  curve=+4                          #0:$9C@+20
        fcb   $04,$00,$03,$50,$14,$00,$00,$E0  ; seg  63  curve=+4                          #0:$9C@+20 #3:$A3@-32
        fcb   $00,$7F,$03,$00,$14,$00,$00,$00  ; seg  64            pitch=-1                #0:$9C@+20
        fcb   $00,$7F,$03,$50,$14,$00,$00,$E0  ; seg  65            pitch=-1                #0:$9C@+20 #3:$A3@-32
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  66                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  67                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg  68  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$50,$12,$00,$00,$20  ; seg  69  curve=+4                          #0:$80@+18 #3:$A3@+32
        fcb   $04,$00,$03,$50,$14,$00,$00,$D0  ; seg  70  curve=+4                          #0:$9C@+20 #3:$A3@-48
        fcb   $04,$00,$03,$00,$14,$00,$00,$00  ; seg  71  curve=+4                          #0:$9C@+20
        fcb   $00,$00,$03,$50,$14,$00,$00,$D0  ; seg  72                                    #0:$9C@+20 #3:$A3@-48
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  73                                    #0:$9C@+20
        fcb   $00,$02,$03,$50,$14,$00,$00,$20  ; seg  74            pitch=+2                #0:$9C@+20 #3:$A3@+32
        fcb   $00,$02,$03,$00,$14,$00,$00,$00  ; seg  75            pitch=+2                #0:$9C@+20
        fcb   $00,$7E,$03,$00,$14,$00,$00,$00  ; seg  76            pitch=-2                #0:$9C@+20
        fcb   $00,$7E,$03,$50,$14,$00,$00,$30  ; seg  77            pitch=-2                #0:$9C@+20 #3:$A3@+48
        fcb   $00,$01,$07,$07,$12,$00,$12,$00  ; seg  78            pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $00,$01,$07,$07,$12,$00,$12,$00  ; seg  79            pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg  80  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$50,$12,$00,$00,$E0  ; seg  81  curve=+4                          #0:$80@+18 #3:$A3@-32
        fcb   $04,$00,$07,$50,$12,$00,$00,$D0  ; seg  82  curve=+4                          #0:$80@+18 #3:$A3@-48
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg  83  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$50,$12,$00,$00,$20  ; seg  84  curve=+4                          #0:$80@+18 #3:$A3@+32
        fcb   $04,$00,$07,$50,$12,$00,$00,$30  ; seg  85  curve=+4                          #0:$80@+18 #3:$A3@+48
        fcb   $04,$00,$06,$06,$12,$00,$12,$00  ; seg  86  curve=+4                          #0:$86@+18 #2:$86@+18
        fcb   $04,$00,$06,$06,$12,$00,$12,$00  ; seg  87  curve=+4                          #0:$86@+18 #2:$86@+18
        fcb   $00,$7F,$06,$06,$12,$00,$12,$00  ; seg  88            pitch=-1                #0:$86@+18 #2:$86@+18
        fcb   $00,$7F,$06,$06,$12,$00,$12,$00  ; seg  89            pitch=-1                #0:$86@+18 #2:$86@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  90                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  91                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$01,$07,$50,$12,$00,$00,$D0  ; seg  92  curve=+4  pitch=+1                #0:$80@+18 #3:$A3@-48
        fcb   $04,$01,$07,$50,$12,$00,$00,$20  ; seg  93  curve=+4  pitch=+1                #0:$80@+18 #3:$A3@+32
        fcb   $04,$7F,$03,$00,$14,$00,$00,$00  ; seg  94  curve=+4  pitch=-1                #0:$9C@+20
        fcb   $04,$7F,$03,$50,$14,$00,$00,$E0  ; seg  95  curve=+4  pitch=-1                #0:$9C@+20 #3:$A3@-32
        fcb   $00,$00,$03,$08,$14,$00,$08,$00  ; seg  96                                    #0:$9C@+20 #2:$9F@+8
        fcb   $00,$00,$03,$50,$14,$00,$00,$30  ; seg  97                                    #0:$9C@+20 #3:$A3@+48
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  98                                    #0:$9C@+20
        fcb   $00,$00,$03,$50,$14,$00,$00,$D0  ; seg  99                                    #0:$9C@+20 #3:$A3@-48
        fcb   $00,$00,$03,$58,$EC,$00,$F8,$20  ; seg 100                                    #0:$9C@-20 #2:$9F@-8 #3:$A3@+32
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 101                                    #0:$9C@-20
        fcb   $00,$00,$03,$50,$EC,$00,$00,$E0  ; seg 102                                    #0:$9C@-20 #3:$A3@-32
        fcb   $00,$00,$03,$50,$EC,$00,$00,$30  ; seg 103                                    #0:$9C@-20 #3:$A3@+48
        fcb   $00,$00,$03,$08,$EC,$00,$08,$00  ; seg 104                                    #0:$9C@-20 #2:$9F@+8
        fcb   $00,$00,$03,$50,$EC,$00,$00,$D0  ; seg 105                                    #0:$9C@-20 #3:$A3@-48
        fcb   $00,$7F,$04,$04,$EE,$00,$EE,$00  ; seg 106            pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $00,$7F,$04,$04,$EE,$00,$EE,$00  ; seg 107            pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$20  ; seg 108  curve=-4                          #0:$81@-18 #3:$A3@+32
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$E0  ; seg 109  curve=-4                          #0:$81@-18 #3:$A3@-32
        fcb   $7C,$02,$06,$06,$EE,$00,$EE,$00  ; seg 110  curve=-4  pitch=+2                #0:$86@-18 #2:$86@-18
        fcb   $7C,$02,$06,$06,$EE,$00,$EE,$00  ; seg 111  curve=-4  pitch=+2                #0:$86@-18 #2:$86@-18
        fcb   $00,$7F,$06,$06,$EE,$00,$EE,$00  ; seg 112            pitch=-1                #0:$86@-18 #2:$86@-18
        fcb   $00,$7F,$06,$06,$EE,$00,$EE,$00  ; seg 113            pitch=-1                #0:$86@-18 #2:$86@-18
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg 114                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg 115                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$00,$EE,$00,$00,$00  ; seg 116  curve=-6                          #0:$81@-18
        fcb   $7A,$00,$04,$50,$EE,$00,$00,$D0  ; seg 117  curve=-6                          #0:$81@-18 #3:$A3@-48
        fcb   $7A,$00,$04,$50,$EE,$00,$00,$20  ; seg 118  curve=-6                          #0:$81@-18 #3:$A3@+32
        fcb   $7A,$00,$04,$00,$EE,$00,$00,$00  ; seg 119  curve=-6                          #0:$81@-18
        fcb   $7A,$00,$04,$50,$EE,$00,$00,$E0  ; seg 120  curve=-6                          #0:$81@-18 #3:$A3@-32
        fcb   $7A,$00,$04,$50,$EE,$00,$00,$30  ; seg 121  curve=-6                          #0:$81@-18 #3:$A3@+48
        fcb   $7A,$00,$03,$00,$EC,$00,$00,$00  ; seg 122  curve=-6                          #0:$9C@-20
        fcb   $7A,$00,$03,$50,$EC,$00,$00,$D0  ; seg 123  curve=-6                          #0:$9C@-20 #3:$A3@-48
        fcb   $00,$00,$03,$08,$EC,$00,$08,$00  ; seg 124                                    #0:$9C@-20 #2:$9F@+8
        fcb   $00,$00,$03,$50,$EC,$00,$00,$20  ; seg 125                                    #0:$9C@-20 #3:$A3@+32
        fcb   $00,$02,$03,$00,$14,$00,$00,$00  ; seg 126            pitch=+2                #0:$9C@+20
        fcb   $00,$02,$03,$00,$14,$00,$00,$00  ; seg 127            pitch=+2                #0:$9C@+20
        fcb   $00,$02,$03,$08,$14,$00,$F8,$00  ; seg 128            pitch=+2                #0:$9C@+20 #2:$9F@-8
        fcb   $00,$02,$03,$00,$14,$00,$00,$00  ; seg 129            pitch=+2                #0:$9C@+20
        fcb   $00,$7E,$03,$50,$EC,$00,$00,$E0  ; seg 130            pitch=-2                #0:$9C@-20 #3:$A3@-32
        fcb   $00,$7E,$03,$00,$EC,$00,$00,$00  ; seg 131            pitch=-2                #0:$9C@-20
        fcb   $00,$00,$03,$58,$EC,$00,$08,$30  ; seg 132                                    #0:$9C@-20 #2:$9F@+8 #3:$A3@+48
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 133                                    #0:$9C@-20
        fcb   $00,$7E,$03,$00,$14,$00,$00,$00  ; seg 134            pitch=-2                #0:$9C@+20
        fcb   $00,$7E,$03,$50,$14,$00,$00,$D0  ; seg 135            pitch=-2                #0:$9C@+20 #3:$A3@-48
        fcb   $00,$00,$03,$58,$14,$00,$F8,$20  ; seg 136                                    #0:$9C@+20 #2:$9F@-8 #3:$A3@+32
        fcb   $00,$00,$03,$50,$14,$00,$00,$E0  ; seg 137                                    #0:$9C@+20 #3:$A3@-32
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 138                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 139                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$08,$12,$00,$08,$00  ; seg 140  curve=+4                          #0:$80@+18 #2:$9F@+8
        fcb   $04,$00,$07,$50,$12,$00,$00,$D0  ; seg 141  curve=+4                          #0:$80@+18 #3:$A3@-48
        fcb   $04,$00,$03,$00,$EC,$00,$00,$00  ; seg 142  curve=+4                          #0:$9C@-20
        fcb   $04,$00,$03,$50,$EC,$00,$00,$E0  ; seg 143  curve=+4                          #0:$9C@-20 #3:$A3@-32
        fcb   $00,$00,$03,$50,$EC,$00,$00,$20  ; seg 144                                    #0:$9C@-20 #3:$A3@+32
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 145                                    #0:$9C@-20
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 146                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 147                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$01,$04,$50,$EE,$00,$00,$30  ; seg 148  curve=-4  pitch=+1                #0:$81@-18 #3:$A3@+48
        fcb   $7C,$01,$04,$00,$EE,$00,$00,$00  ; seg 149  curve=-4  pitch=+1                #0:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$E0  ; seg 150  curve=-4                          #0:$81@-18 #3:$A3@-32
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 151  curve=-4                          #0:$81@-18
        fcb   $7C,$7F,$04,$58,$EE,$00,$08,$D0  ; seg 152  curve=-4  pitch=-1                #0:$81@-18 #2:$9F@+8 #3:$A3@-48
        fcb   $7C,$7F,$04,$50,$EE,$00,$00,$20  ; seg 153  curve=-4  pitch=-1                #0:$81@-18 #3:$A3@+32
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 154  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$E0  ; seg 155  curve=-4                          #0:$81@-18 #3:$A3@-32
        fcb   $7C,$00,$04,$08,$EE,$00,$F8,$00  ; seg 156  curve=-4                          #0:$81@-18 #2:$9F@-8
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 157  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$03,$50,$EC,$00,$00,$E0  ; seg 158  curve=-4                          #0:$9C@-20 #3:$A3@-32
        fcb   $7C,$00,$03,$50,$EC,$00,$00,$30  ; seg 159  curve=-4                          #0:$9C@-20 #3:$A3@+48
        fcb   $00,$00,$03,$08,$EC,$00,$08,$00  ; seg 160                                    #0:$9C@-20 #2:$9F@+8
        fcb   $00,$00,$03,$50,$EC,$00,$00,$D0  ; seg 161                                    #0:$9C@-20 #3:$A3@-48
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 162                                    #0:$9C@-20
        fcb   $00,$00,$03,$50,$EC,$00,$00,$20  ; seg 163                                    #0:$9C@-20 #3:$A3@+32
        fcb   $00,$00,$03,$08,$14,$00,$F8,$00  ; seg 164                                    #0:$9C@+20 #2:$9F@-8
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 165                                    #0:$9C@+20
        fcb   $00,$00,$03,$50,$14,$00,$00,$D0  ; seg 166                                    #0:$9C@+20 #3:$A3@-48
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 167                                    #0:$9C@+20
        fcb   $00,$00,$03,$08,$14,$00,$08,$00  ; seg 168                                    #0:$9C@+20 #2:$9F@+8
        fcb   $00,$00,$03,$50,$14,$00,$00,$E0  ; seg 169                                    #0:$9C@+20 #3:$A3@-32
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 170                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 171                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 172  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$50,$12,$00,$00,$30  ; seg 173  curve=+4                          #0:$80@+18 #3:$A3@+48
        fcb   $04,$00,$06,$06,$12,$00,$12,$00  ; seg 174  curve=+4                          #0:$86@+18 #2:$86@+18
        fcb   $04,$00,$06,$06,$12,$00,$12,$00  ; seg 175  curve=+4                          #0:$86@+18 #2:$86@+18
        fcb   $00,$00,$06,$06,$12,$00,$12,$00  ; seg 176                                    #0:$86@+18 #2:$86@+18
        fcb   $00,$00,$06,$06,$12,$00,$12,$00  ; seg 177                                    #0:$86@+18 #2:$86@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 178                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 179                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$01,$07,$50,$12,$00,$00,$D0  ; seg 180  curve=+4  pitch=+1                #0:$80@+18 #3:$A3@-48
        fcb   $04,$01,$07,$00,$12,$00,$00,$00  ; seg 181  curve=+4  pitch=+1                #0:$80@+18
        fcb   $04,$7F,$03,$00,$14,$00,$00,$00  ; seg 182  curve=+4  pitch=-1                #0:$9C@+20
        fcb   $04,$7F,$03,$50,$14,$00,$00,$20  ; seg 183  curve=+4  pitch=-1                #0:$9C@+20 #3:$A3@+32
        fcb   $00,$00,$03,$05,$14,$00,$08,$00  ; seg 184                                    #0:$9C@+20 #2:$A3@+8
        fcb   $00,$00,$03,$55,$14,$00,$06,$E0  ; seg 185                                    #0:$9C@+20 #2:$A3@+6 #3:$A3@-32
        fcb   $00,$00,$03,$05,$EC,$00,$02,$00  ; seg 186                                    #0:$9C@-20 #2:$A3@+2
        fcb   $00,$00,$03,$05,$EC,$00,$FC,$00  ; seg 187                                    #0:$9C@-20 #2:$A3@-4
        fcb   $00,$00,$03,$55,$EC,$00,$F8,$30  ; seg 188                                    #0:$9C@-20 #2:$A3@-8 #3:$A3@+48
        fcb   $00,$00,$03,$05,$EC,$00,$F6,$00  ; seg 189                                    #0:$9C@-20 #2:$A3@-10
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg 190                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg 191                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg 192  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg 193  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$50,$EE,$00,$00,$20  ; seg 194  curve=-6                          #0:$81@-18 #3:$A3@+32
        fcb   $7A,$00,$04,$00,$EE,$00,$00,$00  ; seg 195  curve=-6                          #0:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$E0  ; seg 196  curve=-4                          #0:$81@-18 #3:$A3@-32
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$D0  ; seg 197  curve=-4                          #0:$81@-18 #3:$A3@-48
        fcb   $7C,$00,$04,$04,$EE,$00,$EE,$00  ; seg 198  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$04,$EE,$00,$EE,$00  ; seg 199  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg 200  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg 201  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$50,$EC,$00,$00,$30  ; seg 202  curve=-6                          #0:$9C@-20 #3:$A3@+48
        fcb   $7A,$00,$03,$00,$EC,$00,$00,$00  ; seg 203  curve=-6                          #0:$9C@-20
        fcb   $00,$00,$03,$55,$EC,$00,$F8,$E0  ; seg 204                                    #0:$9C@-20 #2:$A3@-8 #3:$A3@-32
        fcb   $00,$00,$03,$05,$EC,$00,$FC,$00  ; seg 205                                    #0:$9C@-20 #2:$A3@-4
        fcb   $00,$7F,$03,$05,$EC,$00,$08,$00  ; seg 206            pitch=-1                #0:$9C@-20 #2:$A3@+8
        fcb   $00,$7F,$03,$55,$EC,$00,$06,$D0  ; seg 207            pitch=-1                #0:$9C@-20 #2:$A3@+6 #3:$A3@-48
        fcb   $00,$00,$03,$05,$14,$00,$02,$00  ; seg 208                                    #0:$9C@+20 #2:$A3@+2
        fcb   $00,$00,$03,$55,$14,$00,$04,$20  ; seg 209                                    #0:$9C@+20 #2:$A3@+4 #3:$A3@+32
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 210                                    #0:$9C@+20
        fcb   $00,$00,$03,$50,$14,$00,$00,$30  ; seg 211                                    #0:$9C@+20 #3:$A3@+48
        fcb   $00,$01,$03,$00,$14,$00,$00,$00  ; seg 212            pitch=+1                #0:$9C@+20
        fcb   $00,$01,$03,$00,$14,$00,$00,$00  ; seg 213            pitch=+1                #0:$9C@+20
        fcb   $00,$7E,$03,$00,$EC,$00,$00,$00  ; seg 214            pitch=-2                #0:$9C@-20
        fcb   $00,$7E,$03,$50,$EC,$00,$00,$D0  ; seg 215            pitch=-2                #0:$9C@-20 #3:$A3@-48
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 216                                    #0:$9C@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 217                                    #0:$9C@-20
        fcb   $00,$02,$03,$50,$14,$00,$00,$E0  ; seg 218            pitch=+2                #0:$9C@+20 #3:$A3@-32
        fcb   $00,$02,$03,$00,$14,$00,$00,$00  ; seg 219            pitch=+2                #0:$9C@+20
        fcb   $00,$02,$03,$08,$14,$00,$F8,$00  ; seg 220            pitch=+2                #0:$9C@+20 #2:$9F@-8
        fcb   $00,$02,$03,$00,$14,$00,$00,$00  ; seg 221            pitch=+2                #0:$9C@+20
        fcb   $00,$00,$03,$50,$EC,$00,$00,$30  ; seg 222                                    #0:$9C@-20 #3:$A3@+48
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 223                                    #0:$9C@-20
        fcb   $00,$7E,$03,$08,$EC,$00,$08,$00  ; seg 224            pitch=-2                #0:$9C@-20 #2:$9F@+8
        fcb   $00,$7E,$03,$00,$EC,$00,$00,$00  ; seg 225            pitch=-2                #0:$9C@-20
        fcb   $00,$00,$03,$50,$14,$00,$00,$30  ; seg 226                                    #0:$9C@+20 #3:$A3@+48
        fcb   $00,$00,$03,$50,$14,$00,$00,$20  ; seg 227                                    #0:$9C@+20 #3:$A3@+32
        fcb   $00,$7E,$03,$08,$14,$00,$F8,$00  ; seg 228            pitch=-2                #0:$9C@+20 #2:$9F@-8
        fcb   $00,$7E,$03,$00,$14,$00,$00,$00  ; seg 229            pitch=-2                #0:$9C@+20
        fcb   $00,$00,$03,$50,$EC,$00,$00,$D0  ; seg 230                                    #0:$9C@-20 #3:$A3@-48
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 231                                    #0:$9C@-20
        fcb   $00,$02,$03,$08,$EC,$00,$08,$00  ; seg 232            pitch=+2                #0:$9C@-20 #2:$9F@+8
        fcb   $00,$02,$03,$00,$EC,$00,$00,$00  ; seg 233            pitch=+2                #0:$9C@-20
        fcb   $00,$00,$03,$50,$EC,$00,$00,$E0  ; seg 234                                    #0:$9C@-20 #3:$A3@-32
        fcb   $00,$00,$03,$50,$EC,$00,$00,$30  ; seg 235                                    #0:$9C@-20 #3:$A3@+48
        fcb   $00,$7F,$03,$08,$EC,$00,$F8,$00  ; seg 236            pitch=-1                #0:$9C@-20 #2:$9F@-8
        fcb   $00,$7F,$03,$00,$EC,$00,$00,$00  ; seg 237            pitch=-1                #0:$9C@-20
        fcb   $00,$01,$03,$00,$EC,$00,$00,$00  ; seg 238            pitch=+1                #0:$9C@-20
        fcb   $00,$01,$03,$50,$EC,$00,$00,$30  ; seg 239            pitch=+1                #0:$9C@-20 #3:$A3@+48
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 240                                    #0:$9C@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 241                                    #0:$9C@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 242                                    #0:$9C@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 243                                    #0:$9C@+20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 244                                    #0:$9C@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 245                                    #0:$9C@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 246                                    #0:$9C@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 247                                    #0:$9C@-20
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 248                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 249
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 250
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 251
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 252                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 253                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 254                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 255                                    #0:$83@+18 #2:$83@+18

Circuit_23_hard_6_segment_cache
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
        fcb   $F0,$00,$F6,$0A  ; seg  29  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  30  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  31  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  32  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EA,$00,$F6,$0A  ; seg  33  yaw= -22 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  34  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DE,$00,$F6,$0A  ; seg  35  yaw= -34 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  36  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D2,$00,$F6,$0A  ; seg  37  yaw= -46 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  38  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C6,$00,$F6,$0A  ; seg  39  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  40  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  41  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  42  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  43  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  44  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$01,$F6,$0A  ; seg  45  yaw= -60 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg  46  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $CC,$01,$F6,$0A  ; seg  47  yaw= -52 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  48  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  49  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  50  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  51  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  52  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  53  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  54  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  55  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  56  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  57  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  58  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$01,$F6,$0A  ; seg  59  yaw= -80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg  60  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B4,$02,$F6,$0A  ; seg  61  yaw= -76 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B8,$02,$F6,$0A  ; seg  62  yaw= -72 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $BC,$02,$F6,$0A  ; seg  63  yaw= -68 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  64  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg  65  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  66  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  67  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  68  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  69  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  70  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  71  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  72  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  73  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  74  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$02,$F6,$0A  ; seg  75  yaw= -48 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $D0,$04,$F6,$0A  ; seg  76  yaw= -48 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $D0,$02,$F6,$0A  ; seg  77  yaw= -48 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  78  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$01,$F6,$0A  ; seg  79  yaw= -48 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $D0,$02,$F6,$0A  ; seg  80  yaw= -48 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $D4,$02,$F6,$0A  ; seg  81  yaw= -44 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $D8,$02,$F6,$0A  ; seg  82  yaw= -40 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $DC,$02,$F6,$0A  ; seg  83  yaw= -36 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  84  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E4,$02,$F6,$0A  ; seg  85  yaw= -28 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E8,$02,$F6,$0A  ; seg  86  yaw= -24 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $EC,$02,$F6,$09  ; seg  87  yaw= -20 pitch=  +2 min_lat= -10 max_lat=  +9
        fcb   $F0,$02,$F6,$08  ; seg  88  yaw= -16 pitch=  +2 min_lat= -10 max_lat=  +8
        fcb   $F0,$01,$F6,$07  ; seg  89  yaw= -16 pitch=  +1 min_lat= -10 max_lat=  +7
        fcb   $F0,$00,$F6,$06  ; seg  90  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $F0,$00,$F7,$05  ; seg  91  yaw= -16 pitch=  +0 min_lat=  -9 max_lat=  +5
        fcb   $F0,$00,$F8,$04  ; seg  92  yaw= -16 pitch=  +0 min_lat=  -8 max_lat=  +4
        fcb   $F4,$01,$F9,$03  ; seg  93  yaw= -12 pitch=  +1 min_lat=  -7 max_lat=  +3
        fcb   $F8,$02,$FA,$02  ; seg  94  yaw=  -8 pitch=  +2 min_lat=  -6 max_lat=  +2
        fcb   $FC,$01,$FB,$01  ; seg  95  yaw=  -4 pitch=  +1 min_lat=  -5 max_lat=  +1
        fcb   $00,$00,$FC,$00  ; seg  96  yaw=  +0 pitch=  +0 min_lat=  -4 max_lat=  +0
        fcb   $00,$00,$FD,$07  ; seg  97  yaw=  +0 pitch=  +0 min_lat=  -3 max_lat=  +7
        fcb   $00,$00,$FE,$06  ; seg  98  yaw=  +0 pitch=  +0 min_lat=  -2 max_lat=  +6
        fcb   $00,$00,$FF,$05  ; seg  99  yaw=  +0 pitch=  +0 min_lat=  -1 max_lat=  +5
        fcb   $00,$00,$00,$04  ; seg 100  yaw=  +0 pitch=  +0 min_lat=  +0 max_lat=  +4
        fcb   $00,$00,$F6,$03  ; seg 101  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $00,$00,$F6,$02  ; seg 102  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $00,$00,$F6,$01  ; seg 103  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $00,$00,$F6,$00  ; seg 104  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $00,$00,$F6,$0A  ; seg 105  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg 106  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg 107  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg 108  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $FC,$FE,$F6,$0A  ; seg 109  yaw=  -4 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $F8,$FE,$F6,$0A  ; seg 110  yaw=  -8 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg 111  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$02,$F6,$0A  ; seg 112  yaw= -16 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $F0,$01,$F6,$0A  ; seg 113  yaw= -16 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg 114  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$09  ; seg 115  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $F0,$00,$F6,$08  ; seg 116  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $EA,$00,$F6,$07  ; seg 117  yaw= -22 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $E4,$00,$F6,$06  ; seg 118  yaw= -28 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $DE,$00,$F7,$05  ; seg 119  yaw= -34 pitch=  +0 min_lat=  -9 max_lat=  +5
        fcb   $D8,$00,$F8,$04  ; seg 120  yaw= -40 pitch=  +0 min_lat=  -8 max_lat=  +4
        fcb   $D2,$00,$F9,$03  ; seg 121  yaw= -46 pitch=  +0 min_lat=  -7 max_lat=  +3
        fcb   $CC,$00,$FA,$02  ; seg 122  yaw= -52 pitch=  +0 min_lat=  -6 max_lat=  +2
        fcb   $C6,$00,$FB,$01  ; seg 123  yaw= -58 pitch=  +0 min_lat=  -5 max_lat=  +1
        fcb   $C0,$00,$FC,$00  ; seg 124  yaw= -64 pitch=  +0 min_lat=  -4 max_lat=  +0
        fcb   $C0,$00,$FD,$07  ; seg 125  yaw= -64 pitch=  +0 min_lat=  -3 max_lat=  +7
        fcb   $C0,$00,$FE,$06  ; seg 126  yaw= -64 pitch=  +0 min_lat=  -2 max_lat=  +6
        fcb   $C0,$02,$FF,$05  ; seg 127  yaw= -64 pitch=  +2 min_lat=  -1 max_lat=  +5
        fcb   $C0,$04,$00,$04  ; seg 128  yaw= -64 pitch=  +4 min_lat=  +0 max_lat=  +4
        fcb   $C0,$06,$F9,$03  ; seg 129  yaw= -64 pitch=  +6 min_lat=  -7 max_lat=  +3
        fcb   $C0,$08,$FA,$02  ; seg 130  yaw= -64 pitch=  +8 min_lat=  -6 max_lat=  +2
        fcb   $C0,$06,$FB,$01  ; seg 131  yaw= -64 pitch=  +6 min_lat=  -5 max_lat=  +1
        fcb   $C0,$04,$FC,$00  ; seg 132  yaw= -64 pitch=  +4 min_lat=  -4 max_lat=  +0
        fcb   $C0,$04,$FD,$07  ; seg 133  yaw= -64 pitch=  +4 min_lat=  -3 max_lat=  +7
        fcb   $C0,$04,$FE,$06  ; seg 134  yaw= -64 pitch=  +4 min_lat=  -2 max_lat=  +6
        fcb   $C0,$02,$FF,$05  ; seg 135  yaw= -64 pitch=  +2 min_lat=  -1 max_lat=  +5
        fcb   $C0,$00,$00,$04  ; seg 136  yaw= -64 pitch=  +0 min_lat=  +0 max_lat=  +4
        fcb   $C0,$00,$F6,$03  ; seg 137  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $C0,$00,$F6,$02  ; seg 138  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $C0,$00,$F6,$01  ; seg 139  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $C0,$00,$F6,$00  ; seg 140  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $C4,$00,$F6,$0A  ; seg 141  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 142  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$09  ; seg 143  yaw= -52 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $D0,$00,$F6,$08  ; seg 144  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $D0,$00,$F6,$07  ; seg 145  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $D0,$00,$F6,$06  ; seg 146  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $D0,$00,$F7,$05  ; seg 147  yaw= -48 pitch=  +0 min_lat=  -9 max_lat=  +5
        fcb   $D0,$00,$F8,$04  ; seg 148  yaw= -48 pitch=  +0 min_lat=  -8 max_lat=  +4
        fcb   $CC,$01,$F9,$03  ; seg 149  yaw= -52 pitch=  +1 min_lat=  -7 max_lat=  +3
        fcb   $C8,$02,$FA,$02  ; seg 150  yaw= -56 pitch=  +2 min_lat=  -6 max_lat=  +2
        fcb   $C4,$02,$FB,$01  ; seg 151  yaw= -60 pitch=  +2 min_lat=  -5 max_lat=  +1
        fcb   $C0,$02,$FC,$00  ; seg 152  yaw= -64 pitch=  +2 min_lat=  -4 max_lat=  +0
        fcb   $BC,$01,$FD,$07  ; seg 153  yaw= -68 pitch=  +1 min_lat=  -3 max_lat=  +7
        fcb   $B8,$00,$FE,$06  ; seg 154  yaw= -72 pitch=  +0 min_lat=  -2 max_lat=  +6
        fcb   $B4,$00,$FF,$05  ; seg 155  yaw= -76 pitch=  +0 min_lat=  -1 max_lat=  +5
        fcb   $B0,$00,$00,$04  ; seg 156  yaw= -80 pitch=  +0 min_lat=  +0 max_lat=  +4
        fcb   $AC,$00,$F9,$03  ; seg 157  yaw= -84 pitch=  +0 min_lat=  -7 max_lat=  +3
        fcb   $A8,$00,$FA,$02  ; seg 158  yaw= -88 pitch=  +0 min_lat=  -6 max_lat=  +2
        fcb   $A4,$00,$FB,$01  ; seg 159  yaw= -92 pitch=  +0 min_lat=  -5 max_lat=  +1
        fcb   $A0,$00,$FC,$00  ; seg 160  yaw= -96 pitch=  +0 min_lat=  -4 max_lat=  +0
        fcb   $A0,$00,$FD,$07  ; seg 161  yaw= -96 pitch=  +0 min_lat=  -3 max_lat=  +7
        fcb   $A0,$00,$FE,$06  ; seg 162  yaw= -96 pitch=  +0 min_lat=  -2 max_lat=  +6
        fcb   $A0,$00,$FF,$05  ; seg 163  yaw= -96 pitch=  +0 min_lat=  -1 max_lat=  +5
        fcb   $A0,$00,$00,$04  ; seg 164  yaw= -96 pitch=  +0 min_lat=  +0 max_lat=  +4
        fcb   $A0,$00,$F6,$03  ; seg 165  yaw= -96 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $A0,$00,$F6,$02  ; seg 166  yaw= -96 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $A0,$00,$F6,$01  ; seg 167  yaw= -96 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $A0,$00,$F6,$00  ; seg 168  yaw= -96 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $A0,$00,$F6,$0A  ; seg 169  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 170  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$09  ; seg 171  yaw= -96 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $A0,$00,$F6,$08  ; seg 172  yaw= -96 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $A4,$00,$F6,$07  ; seg 173  yaw= -92 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $A8,$00,$F7,$06  ; seg 174  yaw= -88 pitch=  +0 min_lat=  -9 max_lat=  +6
        fcb   $AC,$00,$F8,$05  ; seg 175  yaw= -84 pitch=  +0 min_lat=  -8 max_lat=  +5
        fcb   $B0,$00,$F9,$04  ; seg 176  yaw= -80 pitch=  +0 min_lat=  -7 max_lat=  +4
        fcb   $B0,$00,$FA,$03  ; seg 177  yaw= -80 pitch=  +0 min_lat=  -6 max_lat=  +3
        fcb   $B0,$00,$FB,$02  ; seg 178  yaw= -80 pitch=  +0 min_lat=  -5 max_lat=  +2
        fcb   $B0,$00,$FC,$01  ; seg 179  yaw= -80 pitch=  +0 min_lat=  -4 max_lat=  +1
        fcb   $B0,$00,$FD,$00  ; seg 180  yaw= -80 pitch=  +0 min_lat=  -3 max_lat=  +0
        fcb   $B4,$01,$FE,$FF  ; seg 181  yaw= -76 pitch=  +1 min_lat=  -2 max_lat=  -1
        fcb   $B8,$02,$FF,$FE  ; seg 182  yaw= -72 pitch=  +2 min_lat=  -1 max_lat=  -2
        fcb   $BC,$01,$00,$FD  ; seg 183  yaw= -68 pitch=  +1 min_lat=  +0 max_lat=  -3
        fcb   $C0,$00,$01,$FC  ; seg 184  yaw= -64 pitch=  +0 min_lat=  +1 max_lat=  -4
        fcb   $C0,$00,$02,$FB  ; seg 185  yaw= -64 pitch=  +0 min_lat=  +2 max_lat=  -5
        fcb   $C0,$00,$03,$FA  ; seg 186  yaw= -64 pitch=  +0 min_lat=  +3 max_lat=  -6
        fcb   $C0,$00,$04,$0A  ; seg 187  yaw= -64 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $C0,$00,$00,$0A  ; seg 188  yaw= -64 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $C0,$00,$FE,$0A  ; seg 189  yaw= -64 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 190  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 191  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F7,$0A  ; seg 192  yaw= -64 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $BA,$00,$F8,$09  ; seg 193  yaw= -70 pitch=  +0 min_lat=  -8 max_lat=  +9
        fcb   $B4,$00,$F9,$08  ; seg 194  yaw= -76 pitch=  +0 min_lat=  -7 max_lat=  +8
        fcb   $AE,$00,$FA,$07  ; seg 195  yaw= -82 pitch=  +0 min_lat=  -6 max_lat=  +7
        fcb   $A8,$00,$FB,$06  ; seg 196  yaw= -88 pitch=  +0 min_lat=  -5 max_lat=  +6
        fcb   $A4,$00,$FC,$05  ; seg 197  yaw= -92 pitch=  +0 min_lat=  -4 max_lat=  +5
        fcb   $A0,$00,$FD,$04  ; seg 198  yaw= -96 pitch=  +0 min_lat=  -3 max_lat=  +4
        fcb   $9C,$00,$FE,$03  ; seg 199  yaw=-100 pitch=  +0 min_lat=  -2 max_lat=  +3
        fcb   $98,$00,$FF,$02  ; seg 200  yaw=-104 pitch=  +0 min_lat=  -1 max_lat=  +2
        fcb   $92,$00,$00,$01  ; seg 201  yaw=-110 pitch=  +0 min_lat=  +0 max_lat=  +1
        fcb   $8C,$00,$01,$00  ; seg 202  yaw=-116 pitch=  +0 min_lat=  +1 max_lat=  +0
        fcb   $86,$00,$02,$FF  ; seg 203  yaw=-122 pitch=  +0 min_lat=  +2 max_lat=  -1
        fcb   $80,$00,$03,$FE  ; seg 204  yaw=-128 pitch=  +0 min_lat=  +3 max_lat=  -2
        fcb   $80,$00,$04,$FD  ; seg 205  yaw=-128 pitch=  +0 min_lat=  +4 max_lat=  -3
        fcb   $80,$00,$F6,$FC  ; seg 206  yaw=-128 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $80,$FF,$F6,$FB  ; seg 207  yaw=-128 pitch=  -1 min_lat= -10 max_lat=  -5
        fcb   $80,$FE,$F6,$FA  ; seg 208  yaw=-128 pitch=  -2 min_lat= -10 max_lat=  -6
        fcb   $80,$FE,$F6,$FC  ; seg 209  yaw=-128 pitch=  -2 min_lat= -10 max_lat=  -4
        fcb   $80,$FE,$F6,$0A  ; seg 210  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F7,$0A  ; seg 211  yaw=-128 pitch=  -2 min_lat=  -9 max_lat= +10
        fcb   $80,$FE,$F8,$0A  ; seg 212  yaw=-128 pitch=  -2 min_lat=  -8 max_lat= +10
        fcb   $80,$FF,$F9,$0A  ; seg 213  yaw=-128 pitch=  -1 min_lat=  -7 max_lat= +10
        fcb   $80,$00,$FA,$0A  ; seg 214  yaw=-128 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $80,$FE,$FB,$09  ; seg 215  yaw=-128 pitch=  -2 min_lat=  -5 max_lat=  +9
        fcb   $80,$FC,$FC,$08  ; seg 216  yaw=-128 pitch=  -4 min_lat=  -4 max_lat=  +8
        fcb   $80,$FC,$FD,$07  ; seg 217  yaw=-128 pitch=  -4 min_lat=  -3 max_lat=  +7
        fcb   $80,$FC,$FE,$06  ; seg 218  yaw=-128 pitch=  -4 min_lat=  -2 max_lat=  +6
        fcb   $80,$FE,$FF,$05  ; seg 219  yaw=-128 pitch=  -2 min_lat=  -1 max_lat=  +5
        fcb   $80,$00,$00,$04  ; seg 220  yaw=-128 pitch=  +0 min_lat=  +0 max_lat=  +4
        fcb   $80,$02,$F9,$03  ; seg 221  yaw=-128 pitch=  +2 min_lat=  -7 max_lat=  +3
        fcb   $80,$04,$FA,$02  ; seg 222  yaw=-128 pitch=  +4 min_lat=  -6 max_lat=  +2
        fcb   $80,$04,$FB,$01  ; seg 223  yaw=-128 pitch=  +4 min_lat=  -5 max_lat=  +1
        fcb   $80,$04,$FC,$00  ; seg 224  yaw=-128 pitch=  +4 min_lat=  -4 max_lat=  +0
        fcb   $80,$02,$FD,$07  ; seg 225  yaw=-128 pitch=  +2 min_lat=  -3 max_lat=  +7
        fcb   $80,$00,$FE,$06  ; seg 226  yaw=-128 pitch=  +0 min_lat=  -2 max_lat=  +6
        fcb   $80,$00,$FF,$05  ; seg 227  yaw=-128 pitch=  +0 min_lat=  -1 max_lat=  +5
        fcb   $80,$00,$00,$04  ; seg 228  yaw=-128 pitch=  +0 min_lat=  +0 max_lat=  +4
        fcb   $80,$FE,$F9,$03  ; seg 229  yaw=-128 pitch=  -2 min_lat=  -7 max_lat=  +3
        fcb   $80,$FC,$FA,$02  ; seg 230  yaw=-128 pitch=  -4 min_lat=  -6 max_lat=  +2
        fcb   $80,$FC,$FB,$01  ; seg 231  yaw=-128 pitch=  -4 min_lat=  -5 max_lat=  +1
        fcb   $80,$FC,$FC,$00  ; seg 232  yaw=-128 pitch=  -4 min_lat=  -4 max_lat=  +0
        fcb   $80,$FE,$FD,$0A  ; seg 233  yaw=-128 pitch=  -2 min_lat=  -3 max_lat= +10
        fcb   $80,$00,$FE,$0A  ; seg 234  yaw=-128 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $80,$00,$FF,$0A  ; seg 235  yaw=-128 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $80,$00,$00,$0A  ; seg 236  yaw=-128 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 237  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 238  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 239  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 240  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 241  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 242  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 243  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 244  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 245  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 246  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 247  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 248 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 249 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 250 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 251 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 252 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 253 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 254 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 255 (wraparound de seg 7)
