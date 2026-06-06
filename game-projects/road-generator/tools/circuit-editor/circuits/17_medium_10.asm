* ======================================================================
* Circuit_17_medium_10 — N=224 segments (format compact 8 oct/seg)
* Source       : 17_medium_10.bin (extrait de FILE30)
*
* Pays         : PORTUGAL
* Lieu         : viana do castelo
* Description  : fast course with no hazards
* Hazards      : except for sharp bends
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000000 01:#904824 02:#6C4824 03:#482400 04:#484824 05:#B40000 06:#242424 07:#242424
*   08:#244824 09:#D8D8D8 10:#242400 11:#FCFCFC 12:#FC0000 13:#FC0000 14:#FC2400 15:#FC2400
*   16:#FC4800 17:#FC4800 18:#FC6C00 19:#FC6C00 20:#FC9000 21:#FC9000 22:#FCB400 23:#FCB400
*   24:#FCD800 25:#FCD800 26:#FCFC00 27:#FCFC00
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

Circuit_17_medium_10_nb_segments
        fdb   224

Circuit_17_medium_10_sprite_lut
        fcb   $00,$82,$86,$8F,$83,$81,$9D,$80,$9B,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_17_medium_10_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$02,$02,$14,$00,$14,$00  ; seg   2                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$02,$02,$14,$00,$14,$00  ; seg   3                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$02,$02,$02,$14,$00,$14,$00  ; seg   4            pitch=+2                #0:$86@+20 #2:$86@+20
        fcb   $00,$02,$02,$02,$14,$00,$14,$00  ; seg   5            pitch=+2                #0:$86@+20 #2:$86@+20
        fcb   $00,$02,$02,$02,$14,$00,$14,$00  ; seg   6            pitch=+2                #0:$86@+20 #2:$86@+20
        fcb   $00,$02,$02,$02,$14,$00,$14,$00  ; seg   7            pitch=+2                #0:$86@+20 #2:$86@+20
        fcb   $00,$7E,$02,$32,$EC,$00,$EC,$24  ; seg   8            pitch=-2                #0:$86@-20 #2:$86@-20 #3:$8F@+36
        fcb   $00,$7E,$02,$32,$EC,$00,$EC,$E8  ; seg   9            pitch=-2                #0:$86@-20 #2:$86@-20 #3:$8F@-24
        fcb   $00,$7E,$02,$32,$EC,$00,$EC,$D4  ; seg  10            pitch=-2                #0:$86@-20 #2:$86@-20 #3:$8F@-44
        fcb   $00,$7E,$02,$32,$EC,$00,$EC,$38  ; seg  11            pitch=-2                #0:$86@-20 #2:$86@-20 #3:$8F@+56
        fcb   $00,$00,$02,$32,$EC,$00,$EC,$EC  ; seg  12                                    #0:$86@-20 #2:$86@-20 #3:$8F@-20
        fcb   $00,$00,$02,$32,$EC,$00,$EC,$D8  ; seg  13                                    #0:$86@-20 #2:$86@-20 #3:$8F@-40
        fcb   $00,$00,$00,$30,$00,$00,$00,$24  ; seg  14                                    #3:$8F@+36
        fcb   $00,$00,$00,$30,$00,$00,$00,$E8  ; seg  15                                    #3:$8F@-24
        fcb   $00,$00,$04,$34,$12,$00,$12,$2C  ; seg  16                                    #0:$83@+18 #2:$83@+18 #3:$8F@+44
        fcb   $00,$00,$04,$34,$12,$00,$12,$D0  ; seg  17                                    #0:$83@+18 #2:$83@+18 #3:$8F@-48
        fcb   $00,$00,$04,$34,$12,$00,$12,$E8  ; seg  18                                    #0:$83@+18 #2:$83@+18 #3:$8F@-24
        fcb   $00,$00,$04,$34,$12,$00,$12,$24  ; seg  19                                    #0:$83@+18 #2:$83@+18 #3:$8F@+36
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  20                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  21                      flags=[PIT]
        fcb   $80,$00,$05,$05,$EE,$00,$EE,$00  ; seg  22                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $80,$00,$05,$05,$EE,$00,$EE,$00  ; seg  23                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $FC,$00,$05,$00,$EE,$00,$00,$00  ; seg  24  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$05,$00,$EE,$00,$00,$00  ; seg  25  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$05,$00,$EE,$00,$00,$00  ; seg  26  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$05,$00,$EE,$00,$00,$00  ; seg  27  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$05,$60,$EE,$00,$00,$28  ; seg  28  curve=-4            flags=[PIT]   #0:$81@-18 #3:$9D@+40
        fcb   $FC,$00,$05,$60,$EE,$00,$00,$D8  ; seg  29  curve=-4            flags=[PIT]   #0:$81@-18 #3:$9D@-40
        fcb   $FC,$00,$05,$60,$EE,$00,$00,$E0  ; seg  30  curve=-4            flags=[PIT]   #0:$81@-18 #3:$9D@-32
        fcb   $FC,$00,$05,$60,$EE,$00,$00,$DC  ; seg  31  curve=-4            flags=[PIT]   #0:$81@-18 #3:$9D@-36
        fcb   $7C,$00,$05,$60,$EE,$00,$00,$24  ; seg  32  curve=-4                          #0:$81@-18 #3:$9D@+36
        fcb   $7C,$00,$05,$60,$EE,$00,$00,$E0  ; seg  33  curve=-4                          #0:$81@-18 #3:$9D@-32
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg  34  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$60,$EE,$00,$00,$EC  ; seg  35  curve=-4                          #0:$81@-18 #3:$9D@-20
        fcb   $7C,$7F,$05,$60,$EE,$00,$00,$E8  ; seg  36  curve=-4  pitch=-1                #0:$81@-18 #3:$9D@-24
        fcb   $7C,$7F,$05,$60,$EE,$00,$00,$24  ; seg  37  curve=-4  pitch=-1                #0:$81@-18 #3:$9D@+36
        fcb   $7C,$7F,$07,$07,$12,$00,$12,$00  ; seg  38  curve=-4  pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $7C,$7F,$07,$07,$12,$00,$12,$00  ; seg  39  curve=-4  pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$2C  ; seg  40  curve=+4                          #0:$80@+18 #3:$9D@+44
        fcb   $04,$00,$07,$60,$12,$00,$00,$D4  ; seg  41  curve=+4                          #0:$80@+18 #3:$9D@-44
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg  42  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$38  ; seg  43  curve=+4                          #0:$80@+18 #3:$9D@+56
        fcb   $04,$00,$07,$60,$12,$00,$00,$28  ; seg  44  curve=+4                          #0:$80@+18 #3:$9D@+40
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg  45  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$EC  ; seg  46  curve=+4                          #0:$80@+18 #3:$9D@-20
        fcb   $04,$00,$07,$60,$12,$00,$00,$D4  ; seg  47  curve=+4                          #0:$80@+18 #3:$9D@-44
        fcb   $04,$01,$07,$60,$12,$00,$00,$E8  ; seg  48  curve=+4  pitch=+1                #0:$80@+18 #3:$9D@-24
        fcb   $04,$01,$07,$00,$12,$00,$00,$00  ; seg  49  curve=+4  pitch=+1                #0:$80@+18
        fcb   $04,$01,$07,$60,$12,$00,$00,$30  ; seg  50  curve=+4  pitch=+1                #0:$80@+18 #3:$9D@+48
        fcb   $04,$01,$07,$60,$12,$00,$00,$24  ; seg  51  curve=+4  pitch=+1                #0:$80@+18 #3:$9D@+36
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg  52  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$DC  ; seg  53  curve=+4                          #0:$80@+18 #3:$9D@-36
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  54  curve=+4
        fcb   $04,$00,$00,$60,$00,$00,$00,$38  ; seg  55  curve=+4                          #3:$9D@+56
        fcb   $00,$00,$08,$60,$14,$00,$00,$E4  ; seg  56                                    #0:$9B@+20 #3:$9D@-28
        fcb   $00,$00,$08,$00,$14,$00,$00,$00  ; seg  57                                    #0:$9B@+20
        fcb   $00,$00,$08,$60,$14,$00,$00,$E8  ; seg  58                                    #0:$9B@+20 #3:$9D@-24
        fcb   $00,$00,$08,$00,$14,$00,$00,$00  ; seg  59                                    #0:$9B@+20
        fcb   $00,$7E,$08,$60,$EC,$00,$00,$34  ; seg  60            pitch=-2                #0:$9B@-20 #3:$9D@+52
        fcb   $00,$7E,$08,$00,$EC,$00,$00,$00  ; seg  61            pitch=-2                #0:$9B@-20
        fcb   $00,$7E,$08,$60,$EC,$00,$00,$14  ; seg  62            pitch=-2                #0:$9B@-20 #3:$9D@+20
        fcb   $00,$7E,$08,$60,$EC,$00,$00,$D8  ; seg  63            pitch=-2                #0:$9B@-20 #3:$9D@-40
        fcb   $00,$00,$08,$00,$14,$00,$00,$00  ; seg  64                                    #0:$9B@+20
        fcb   $00,$00,$08,$60,$14,$00,$00,$28  ; seg  65                                    #0:$9B@+20 #3:$9D@+40
        fcb   $00,$00,$08,$60,$14,$00,$00,$3C  ; seg  66                                    #0:$9B@+20 #3:$9D@+60
        fcb   $00,$00,$08,$00,$14,$00,$00,$00  ; seg  67                                    #0:$9B@+20
        fcb   $00,$02,$00,$60,$00,$00,$00,$D8  ; seg  68            pitch=+2                #3:$9D@-40
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg  69            pitch=+2
        fcb   $00,$02,$07,$67,$12,$00,$12,$D8  ; seg  70            pitch=+2                #0:$80@+18 #2:$80@+18 #3:$9D@-40
        fcb   $00,$02,$07,$67,$12,$00,$12,$24  ; seg  71            pitch=+2                #0:$80@+18 #2:$80@+18 #3:$9D@+36
        fcb   $05,$00,$07,$60,$12,$00,$00,$E8  ; seg  72  curve=+5                          #0:$80@+18 #3:$9D@-24
        fcb   $05,$00,$07,$60,$12,$00,$00,$34  ; seg  73  curve=+5                          #0:$80@+18 #3:$9D@+52
        fcb   $05,$00,$07,$60,$12,$00,$00,$E8  ; seg  74  curve=+5                          #0:$80@+18 #3:$9D@-24
        fcb   $05,$00,$07,$60,$12,$00,$00,$24  ; seg  75  curve=+5                          #0:$80@+18 #3:$9D@+36
        fcb   $05,$00,$07,$60,$12,$00,$00,$38  ; seg  76  curve=+5                          #0:$80@+18 #3:$9D@+56
        fcb   $05,$00,$07,$60,$12,$00,$00,$EC  ; seg  77  curve=+5                          #0:$80@+18 #3:$9D@-20
        fcb   $05,$00,$00,$00,$00,$00,$00,$00  ; seg  78  curve=+5
        fcb   $05,$00,$00,$60,$00,$00,$00,$D8  ; seg  79  curve=+5                          #3:$9D@-40
        fcb   $00,$00,$08,$60,$14,$00,$00,$2C  ; seg  80                                    #0:$9B@+20 #3:$9D@+44
        fcb   $00,$00,$08,$60,$14,$00,$00,$D0  ; seg  81                                    #0:$9B@+20 #3:$9D@-48
        fcb   $00,$00,$08,$60,$14,$00,$00,$34  ; seg  82                                    #0:$9B@+20 #3:$9D@+52
        fcb   $00,$00,$08,$60,$14,$00,$00,$E8  ; seg  83                                    #0:$9B@+20 #3:$9D@-24
        fcb   $00,$02,$08,$60,$14,$00,$00,$D4  ; seg  84            pitch=+2                #0:$9B@+20 #3:$9D@-44
        fcb   $00,$02,$08,$60,$14,$00,$00,$24  ; seg  85            pitch=+2                #0:$9B@+20 #3:$9D@+36
        fcb   $00,$02,$08,$60,$14,$00,$00,$38  ; seg  86            pitch=+2                #0:$9B@+20 #3:$9D@+56
        fcb   $00,$02,$08,$60,$14,$00,$00,$DC  ; seg  87            pitch=+2                #0:$9B@+20 #3:$9D@-36
        fcb   $00,$02,$08,$60,$EC,$00,$00,$2C  ; seg  88            pitch=+2                #0:$9B@-20 #3:$9D@+44
        fcb   $00,$02,$08,$00,$EC,$00,$00,$00  ; seg  89            pitch=+2                #0:$9B@-20
        fcb   $00,$02,$08,$60,$EC,$00,$00,$3C  ; seg  90            pitch=+2                #0:$9B@-20 #3:$9D@+60
        fcb   $00,$02,$08,$60,$EC,$00,$00,$24  ; seg  91            pitch=+2                #0:$9B@-20 #3:$9D@+36
        fcb   $00,$7E,$08,$60,$EC,$00,$00,$D0  ; seg  92            pitch=-2                #0:$9B@-20 #3:$9D@-48
        fcb   $00,$7E,$08,$00,$EC,$00,$00,$00  ; seg  93            pitch=-2                #0:$9B@-20
        fcb   $00,$7E,$08,$60,$14,$00,$00,$D4  ; seg  94            pitch=-2                #0:$9B@+20 #3:$9D@-44
        fcb   $00,$7E,$08,$60,$14,$00,$00,$2C  ; seg  95            pitch=-2                #0:$9B@+20 #3:$9D@+44
        fcb   $00,$7E,$08,$60,$14,$00,$00,$38  ; seg  96            pitch=-2                #0:$9B@+20 #3:$9D@+56
        fcb   $00,$7E,$08,$60,$14,$00,$00,$E0  ; seg  97            pitch=-2                #0:$9B@+20 #3:$9D@-32
        fcb   $00,$7E,$08,$00,$14,$00,$00,$00  ; seg  98            pitch=-2                #0:$9B@+20
        fcb   $00,$7E,$08,$60,$14,$00,$00,$E4  ; seg  99            pitch=-2                #0:$9B@+20 #3:$9D@-28
        fcb   $00,$00,$00,$60,$00,$00,$00,$D8  ; seg 100                                    #3:$9D@-40
        fcb   $00,$00,$00,$60,$00,$00,$00,$D4  ; seg 101                                    #3:$9D@-44
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 102                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$67,$12,$00,$12,$20  ; seg 103                                    #0:$80@+18 #2:$80@+18 #3:$9D@+32
        fcb   $05,$00,$07,$60,$12,$00,$00,$E4  ; seg 104  curve=+5                          #0:$80@+18 #3:$9D@-28
        fcb   $05,$00,$07,$60,$12,$00,$00,$30  ; seg 105  curve=+5                          #0:$80@+18 #3:$9D@+48
        fcb   $05,$00,$07,$60,$12,$00,$00,$38  ; seg 106  curve=+5                          #0:$80@+18 #3:$9D@+56
        fcb   $05,$00,$07,$00,$12,$00,$00,$00  ; seg 107  curve=+5                          #0:$80@+18
        fcb   $05,$00,$07,$60,$12,$00,$00,$E4  ; seg 108  curve=+5                          #0:$80@+18 #3:$9D@-28
        fcb   $05,$00,$07,$00,$12,$00,$00,$00  ; seg 109  curve=+5                          #0:$80@+18
        fcb   $05,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg 110  curve=+5                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $05,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg 111  curve=+5                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$65,$EE,$00,$EE,$DC  ; seg 112  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$9D@-36
        fcb   $7A,$00,$05,$65,$EE,$00,$EE,$20  ; seg 113  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$9D@+32
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg 114  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$65,$EE,$00,$EE,$34  ; seg 115  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$9D@+52
        fcb   $7A,$00,$05,$65,$EE,$00,$EE,$EC  ; seg 116  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$9D@-20
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg 117  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$60,$00,$00,$00,$E0  ; seg 118  curve=-6                          #3:$9D@-32
        fcb   $7A,$00,$00,$60,$00,$00,$00,$D8  ; seg 119  curve=-6                          #3:$9D@-40
        fcb   $00,$00,$08,$60,$14,$00,$00,$38  ; seg 120                                    #0:$9B@+20 #3:$9D@+56
        fcb   $00,$00,$08,$60,$14,$00,$00,$28  ; seg 121                                    #0:$9B@+20 #3:$9D@+40
        fcb   $00,$00,$08,$60,$14,$00,$00,$D0  ; seg 122                                    #0:$9B@+20 #3:$9D@-48
        fcb   $00,$00,$08,$60,$14,$00,$00,$24  ; seg 123                                    #0:$9B@+20 #3:$9D@+36
        fcb   $00,$00,$00,$60,$00,$00,$00,$30  ; seg 124                                    #3:$9D@+48
        fcb   $00,$00,$00,$60,$00,$00,$00,$E8  ; seg 125                                    #3:$9D@-24
        fcb   $00,$00,$07,$67,$12,$00,$12,$E4  ; seg 126                                    #0:$80@+18 #2:$80@+18 #3:$9D@-28
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 127                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$D8  ; seg 128  curve=+4                          #0:$80@+18 #3:$9D@-40
        fcb   $04,$00,$07,$60,$12,$00,$00,$E0  ; seg 129  curve=+4                          #0:$80@+18 #3:$9D@-32
        fcb   $04,$00,$00,$60,$00,$00,$00,$2C  ; seg 130  curve=+4                          #3:$9D@+44
        fcb   $04,$00,$00,$60,$00,$00,$00,$28  ; seg 131  curve=+4                          #3:$9D@+40
        fcb   $00,$7E,$08,$60,$EC,$00,$00,$D8  ; seg 132            pitch=-2                #0:$9B@-20 #3:$9D@-40
        fcb   $00,$7E,$08,$00,$EC,$00,$00,$00  ; seg 133            pitch=-2                #0:$9B@-20
        fcb   $00,$02,$08,$60,$EC,$00,$00,$24  ; seg 134            pitch=+2                #0:$9B@-20 #3:$9D@+36
        fcb   $00,$02,$08,$60,$EC,$00,$00,$28  ; seg 135            pitch=+2                #0:$9B@-20 #3:$9D@+40
        fcb   $00,$00,$08,$60,$EC,$00,$00,$D4  ; seg 136                                    #0:$9B@-20 #3:$9D@-44
        fcb   $00,$00,$08,$60,$EC,$00,$00,$20  ; seg 137                                    #0:$9B@-20 #3:$9D@+32
        fcb   $00,$00,$08,$00,$EC,$00,$00,$00  ; seg 138                                    #0:$9B@-20
        fcb   $00,$00,$08,$60,$EC,$00,$00,$3C  ; seg 139                                    #0:$9B@-20 #3:$9D@+60
        fcb   $00,$7E,$00,$60,$00,$00,$00,$E0  ; seg 140            pitch=-2                #3:$9D@-32
        fcb   $00,$7E,$00,$60,$00,$00,$00,$D8  ; seg 141            pitch=-2                #3:$9D@-40
        fcb   $00,$02,$07,$07,$12,$00,$12,$00  ; seg 142            pitch=+2                #0:$80@+18 #2:$80@+18
        fcb   $00,$02,$07,$67,$12,$00,$12,$D4  ; seg 143            pitch=+2                #0:$80@+18 #2:$80@+18 #3:$9D@-44
        fcb   $04,$00,$07,$60,$12,$00,$00,$28  ; seg 144  curve=+4                          #0:$80@+18 #3:$9D@+40
        fcb   $04,$00,$07,$60,$12,$00,$00,$28  ; seg 145  curve=+4                          #0:$80@+18 #3:$9D@+40
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 146  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$D8  ; seg 147  curve=+4                          #0:$80@+18 #3:$9D@-40
        fcb   $04,$01,$07,$60,$12,$00,$00,$D5  ; seg 148  curve=+4  pitch=+1                #0:$80@+18 #3:$9D@-43
        fcb   $04,$01,$07,$00,$12,$00,$00,$00  ; seg 149  curve=+4  pitch=+1                #0:$80@+18
        fcb   $04,$01,$00,$60,$00,$00,$00,$30  ; seg 150  curve=+4  pitch=+1                #3:$9D@+48
        fcb   $04,$01,$00,$60,$00,$00,$00,$28  ; seg 151  curve=+4  pitch=+1                #3:$9D@+40
        fcb   $00,$7F,$08,$60,$14,$00,$00,$28  ; seg 152            pitch=-1                #0:$9B@+20 #3:$9D@+40
        fcb   $00,$7F,$08,$60,$14,$00,$00,$D0  ; seg 153            pitch=-1                #0:$9B@+20 #3:$9D@-48
        fcb   $00,$7F,$08,$00,$14,$00,$00,$00  ; seg 154            pitch=-1                #0:$9B@+20
        fcb   $00,$7F,$08,$60,$14,$00,$00,$34  ; seg 155            pitch=-1                #0:$9B@+20 #3:$9D@+52
        fcb   $00,$00,$08,$60,$EC,$00,$00,$EC  ; seg 156                                    #0:$9B@-20 #3:$9D@-20
        fcb   $00,$00,$08,$60,$EC,$00,$00,$E8  ; seg 157                                    #0:$9B@-20 #3:$9D@-24
        fcb   $00,$00,$08,$00,$EC,$00,$00,$00  ; seg 158                                    #0:$9B@-20
        fcb   $00,$00,$08,$60,$EC,$00,$00,$DC  ; seg 159                                    #0:$9B@-20 #3:$9D@-36
        fcb   $00,$00,$08,$60,$14,$00,$00,$28  ; seg 160                                    #0:$9B@+20 #3:$9D@+40
        fcb   $00,$00,$08,$60,$14,$00,$00,$D0  ; seg 161                                    #0:$9B@+20 #3:$9D@-48
        fcb   $00,$00,$08,$00,$14,$00,$00,$00  ; seg 162                                    #0:$9B@+20
        fcb   $00,$00,$08,$60,$14,$00,$00,$38  ; seg 163                                    #0:$9B@+20 #3:$9D@+56
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 164
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 165
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 166                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 167                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 168  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 169  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 170  curve=+4
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 171  curve=+4
        fcb   $00,$00,$33,$33,$E8,$DC,$E4,$D0  ; seg 172                                    #0:$8F@-24 #1:$8F@-36 #2:$8F@-28 #3:$8F@-48
        fcb   $00,$00,$33,$33,$EC,$D8,$E8,$EC  ; seg 173                                    #0:$8F@-20 #1:$8F@-40 #2:$8F@-24 #3:$8F@-20
        fcb   $00,$00,$33,$00,$E4,$E0,$00,$00  ; seg 174                                    #0:$8F@-28 #1:$8F@-32
        fcb   $00,$00,$30,$33,$00,$EC,$E0,$D0  ; seg 175                                    #1:$8F@-20 #2:$8F@-32 #3:$8F@-48
        fcb   $00,$7E,$02,$32,$14,$00,$14,$2C  ; seg 176            pitch=-2                #0:$86@+20 #2:$86@+20 #3:$8F@+44
        fcb   $00,$7E,$02,$32,$14,$00,$14,$34  ; seg 177            pitch=-2                #0:$86@+20 #2:$86@+20 #3:$8F@+52
        fcb   $00,$02,$02,$02,$14,$00,$14,$00  ; seg 178            pitch=+2                #0:$86@+20 #2:$86@+20
        fcb   $00,$02,$02,$32,$14,$00,$14,$D8  ; seg 179            pitch=+2                #0:$86@+20 #2:$86@+20 #3:$8F@-40
        fcb   $00,$03,$02,$32,$EC,$00,$EC,$24  ; seg 180            pitch=+3                #0:$86@-20 #2:$86@-20 #3:$8F@+36
        fcb   $00,$03,$02,$02,$EC,$00,$EC,$00  ; seg 181            pitch=+3                #0:$86@-20 #2:$86@-20
        fcb   $00,$7D,$02,$32,$EC,$00,$EC,$E0  ; seg 182            pitch=-3                #0:$86@-20 #2:$86@-20 #3:$8F@-32
        fcb   $00,$7D,$02,$32,$EC,$00,$EC,$3C  ; seg 183            pitch=-3                #0:$86@-20 #2:$86@-20 #3:$8F@+60
        fcb   $00,$03,$03,$33,$14,$00,$E4,$D4  ; seg 184            pitch=+3                #0:$8F@+20 #2:$8F@-28 #3:$8F@-44
        fcb   $00,$03,$03,$33,$1C,$00,$24,$28  ; seg 185            pitch=+3                #0:$8F@+28 #2:$8F@+36 #3:$8F@+40
        fcb   $00,$7D,$03,$03,$1E,$00,$1C,$00  ; seg 186            pitch=-3                #0:$8F@+30 #2:$8F@+28
        fcb   $00,$7D,$03,$33,$1C,$00,$24,$D0  ; seg 187            pitch=-3                #0:$8F@+28 #2:$8F@+36 #3:$8F@-48
        fcb   $00,$7E,$03,$33,$EA,$00,$2C,$3C  ; seg 188            pitch=-2                #0:$8F@-22 #2:$8F@+44 #3:$8F@+60
        fcb   $00,$7E,$03,$33,$EC,$00,$14,$28  ; seg 189            pitch=-2                #0:$8F@-20 #2:$8F@+20 #3:$8F@+40
        fcb   $00,$02,$03,$03,$E4,$00,$EC,$00  ; seg 190            pitch=+2                #0:$8F@-28 #2:$8F@-20
        fcb   $00,$02,$03,$33,$E8,$00,$1C,$D4  ; seg 191            pitch=+2                #0:$8F@-24 #2:$8F@+28 #3:$8F@-44
        fcb   $00,$7E,$03,$60,$14,$00,$00,$34  ; seg 192            pitch=-2                #0:$8F@+20 #3:$9D@+52
        fcb   $00,$7E,$03,$60,$14,$00,$00,$2C  ; seg 193            pitch=-2                #0:$8F@+20 #3:$9D@+44
        fcb   $00,$02,$03,$00,$14,$00,$00,$00  ; seg 194            pitch=+2                #0:$8F@+20
        fcb   $00,$02,$03,$60,$14,$00,$00,$D0  ; seg 195            pitch=+2                #0:$8F@+20 #3:$9D@-48
        fcb   $00,$03,$03,$60,$14,$00,$00,$3C  ; seg 196            pitch=+3                #0:$8F@+20 #3:$9D@+60
        fcb   $00,$03,$03,$60,$14,$00,$00,$E8  ; seg 197            pitch=+3                #0:$8F@+20 #3:$9D@-24
        fcb   $00,$7D,$03,$60,$14,$00,$00,$D4  ; seg 198            pitch=-3                #0:$8F@+20 #3:$9D@-44
        fcb   $00,$7D,$03,$60,$14,$00,$00,$28  ; seg 199            pitch=-3                #0:$8F@+20 #3:$9D@+40
        fcb   $00,$00,$00,$60,$00,$00,$00,$38  ; seg 200                                    #3:$9D@+56
        fcb   $00,$00,$00,$60,$00,$00,$00,$E0  ; seg 201                                    #3:$9D@-32
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 202                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$67,$12,$00,$12,$28  ; seg 203                                    #0:$80@+18 #2:$80@+18 #3:$9D@+40
        fcb   $04,$00,$07,$60,$12,$00,$00,$34  ; seg 204  curve=+4                          #0:$80@+18 #3:$9D@+52
        fcb   $04,$00,$07,$60,$12,$00,$00,$28  ; seg 205  curve=+4                          #0:$80@+18 #3:$9D@+40
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 206  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$E8  ; seg 207  curve=+4                          #0:$80@+18 #3:$9D@-24
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 208  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 209  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 210  curve=+4
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 211  curve=+4
        fcb   $00,$00,$08,$08,$EC,$00,$EC,$00  ; seg 212                                    #0:$9B@-20 #2:$9B@-20
        fcb   $00,$00,$08,$08,$EC,$00,$EC,$00  ; seg 213                                    #0:$9B@-20 #2:$9B@-20
        fcb   $00,$00,$08,$08,$EC,$00,$EC,$00  ; seg 214                                    #0:$9B@-20 #2:$9B@-20
        fcb   $00,$00,$08,$08,$EC,$00,$EC,$00  ; seg 215                                    #0:$9B@-20 #2:$9B@-20
        fcb   $00,$00,$02,$02,$14,$00,$14,$00  ; seg 216                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$02,$02,$14,$00,$14,$00  ; seg 217                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$02,$02,$14,$00,$14,$00  ; seg 218                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$02,$02,$14,$00,$14,$00  ; seg 219                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$02,$02,$EC,$00,$EC,$00  ; seg 220                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$02,$02,$EC,$00,$EC,$00  ; seg 221                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$02,$02,$EC,$00,$EC,$00  ; seg 222                                    #0:$86@-20 #2:$86@-20
        fcb   $00,$00,$02,$02,$EC,$00,$EC,$00  ; seg 223                                    #0:$86@-20 #2:$86@-20
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 224                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 225
        fcb   $00,$00,$02,$02,$14,$00,$14,$00  ; seg 226                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$00,$02,$02,$14,$00,$14,$00  ; seg 227                                    #0:$86@+20 #2:$86@+20
        fcb   $00,$02,$02,$02,$14,$00,$14,$00  ; seg 228            pitch=+2                #0:$86@+20 #2:$86@+20
        fcb   $00,$02,$02,$02,$14,$00,$14,$00  ; seg 229            pitch=+2                #0:$86@+20 #2:$86@+20
        fcb   $00,$02,$02,$02,$14,$00,$14,$00  ; seg 230            pitch=+2                #0:$86@+20 #2:$86@+20
        fcb   $00,$02,$02,$02,$14,$00,$14,$00  ; seg 231            pitch=+2                #0:$86@+20 #2:$86@+20

Circuit_17_medium_10_segment_cache
        fcb   $00,$00,$F6,$0A  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   1  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   2  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   3  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   4  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg   5  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $00,$04,$F6,$0A  ; seg   6  yaw=  +0 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $00,$06,$F6,$0A  ; seg   7  yaw=  +0 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $00,$08,$F6,$0A  ; seg   8  yaw=  +0 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $00,$06,$F6,$0A  ; seg   9  yaw=  +0 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $00,$04,$F6,$0A  ; seg  10  yaw=  +0 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  11  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
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
        fcb   $EC,$00,$F6,$0A  ; seg  29  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  30  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  31  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  32  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  33  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  34  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  35  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  36  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$FF,$F6,$0A  ; seg  37  yaw= -52 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C8,$FE,$F6,$0A  ; seg  38  yaw= -56 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C4,$FD,$F6,$0A  ; seg  39  yaw= -60 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $C0,$FC,$F6,$0A  ; seg  40  yaw= -64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C4,$FC,$F6,$0A  ; seg  41  yaw= -60 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C8,$FC,$F6,$0A  ; seg  42  yaw= -56 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $CC,$FC,$F6,$0A  ; seg  43  yaw= -52 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $D0,$FC,$F6,$0A  ; seg  44  yaw= -48 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $D4,$FC,$F6,$0A  ; seg  45  yaw= -44 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $D8,$FC,$F6,$0A  ; seg  46  yaw= -40 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $DC,$FC,$F6,$0A  ; seg  47  yaw= -36 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  48  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E4,$FD,$F6,$0A  ; seg  49  yaw= -28 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $E8,$FE,$F6,$0A  ; seg  50  yaw= -24 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $EC,$FF,$F6,$0A  ; seg  51  yaw= -20 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  52  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  53  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  54  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  55  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  56  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  57  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  58  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  59  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  60  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  61  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$FC,$F6,$0A  ; seg  62  yaw=  +0 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $00,$FA,$F6,$0A  ; seg  63  yaw=  +0 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $00,$F8,$F6,$0A  ; seg  64  yaw=  +0 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $00,$F8,$F6,$0A  ; seg  65  yaw=  +0 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $00,$F8,$F6,$0A  ; seg  66  yaw=  +0 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $00,$F8,$F6,$0A  ; seg  67  yaw=  +0 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $00,$F8,$F6,$0A  ; seg  68  yaw=  +0 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $00,$FA,$F6,$0A  ; seg  69  yaw=  +0 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $00,$FC,$F6,$0A  ; seg  70  yaw=  +0 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  71  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  72  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $05,$00,$F6,$0A  ; seg  73  yaw=  +5 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0A,$00,$F6,$0A  ; seg  74  yaw= +10 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0F,$00,$F6,$0A  ; seg  75  yaw= +15 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg  76  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $19,$00,$F6,$0A  ; seg  77  yaw= +25 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1E,$00,$F6,$0A  ; seg  78  yaw= +30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $23,$00,$F6,$0A  ; seg  79  yaw= +35 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  80  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  81  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  82  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  83  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  84  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$02,$F6,$0A  ; seg  85  yaw= +40 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $28,$04,$F6,$0A  ; seg  86  yaw= +40 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $28,$06,$F6,$0A  ; seg  87  yaw= +40 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $28,$08,$F6,$0A  ; seg  88  yaw= +40 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $28,$0A,$F6,$0A  ; seg  89  yaw= +40 pitch= +10 min_lat= -10 max_lat= +10
        fcb   $28,$0C,$F6,$0A  ; seg  90  yaw= +40 pitch= +12 min_lat= -10 max_lat= +10
        fcb   $28,$0E,$F6,$0A  ; seg  91  yaw= +40 pitch= +14 min_lat= -10 max_lat= +10
        fcb   $28,$10,$F6,$0A  ; seg  92  yaw= +40 pitch= +16 min_lat= -10 max_lat= +10
        fcb   $28,$0E,$F6,$0A  ; seg  93  yaw= +40 pitch= +14 min_lat= -10 max_lat= +10
        fcb   $28,$0C,$F6,$0A  ; seg  94  yaw= +40 pitch= +12 min_lat= -10 max_lat= +10
        fcb   $28,$0A,$F6,$0A  ; seg  95  yaw= +40 pitch= +10 min_lat= -10 max_lat= +10
        fcb   $28,$08,$F6,$0A  ; seg  96  yaw= +40 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $28,$06,$F6,$0A  ; seg  97  yaw= +40 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $28,$04,$F6,$0A  ; seg  98  yaw= +40 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $28,$02,$F6,$0A  ; seg  99  yaw= +40 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg 100  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg 101  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg 102  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg 103  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg 104  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2D,$00,$F6,$0A  ; seg 105  yaw= +45 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $32,$00,$F6,$0A  ; seg 106  yaw= +50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $37,$00,$F6,$0A  ; seg 107  yaw= +55 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg 108  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $41,$00,$F6,$0A  ; seg 109  yaw= +65 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $46,$00,$F6,$0A  ; seg 110  yaw= +70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $4B,$00,$F6,$0A  ; seg 111  yaw= +75 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 112  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $4A,$00,$F6,$0A  ; seg 113  yaw= +74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $44,$00,$F6,$0A  ; seg 114  yaw= +68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3E,$00,$F6,$0A  ; seg 115  yaw= +62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg 116  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $32,$00,$F6,$0A  ; seg 117  yaw= +50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$00,$F6,$0A  ; seg 118  yaw= +44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $26,$00,$F6,$0A  ; seg 119  yaw= +38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 120  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 121  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 122  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 123  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 124  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 125  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 126  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 127  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 128  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $24,$00,$F6,$0A  ; seg 129  yaw= +36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg 130  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$00,$F6,$0A  ; seg 131  yaw= +44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg 132  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$FE,$F6,$0A  ; seg 133  yaw= +48 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $30,$FC,$F6,$0A  ; seg 134  yaw= +48 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $30,$FE,$F6,$0A  ; seg 135  yaw= +48 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg 136  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg 137  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg 138  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg 139  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg 140  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$FE,$F6,$0A  ; seg 141  yaw= +48 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $30,$FC,$F6,$0A  ; seg 142  yaw= +48 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $30,$FE,$F6,$0A  ; seg 143  yaw= +48 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg 144  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg 145  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg 146  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg 147  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg 148  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $44,$01,$F6,$0A  ; seg 149  yaw= +68 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $48,$02,$F6,$0A  ; seg 150  yaw= +72 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $4C,$03,$F6,$0A  ; seg 151  yaw= +76 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $50,$04,$F6,$0A  ; seg 152  yaw= +80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $50,$03,$F6,$0A  ; seg 153  yaw= +80 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $50,$02,$F6,$0A  ; seg 154  yaw= +80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $50,$01,$F6,$0A  ; seg 155  yaw= +80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 156  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 157  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 158  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 159  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 160  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 161  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 162  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 163  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 164  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 165  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 166  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 167  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 168  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $54,$00,$F6,$0A  ; seg 169  yaw= +84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $58,$00,$F6,$0A  ; seg 170  yaw= +88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $5C,$00,$F6,$0A  ; seg 171  yaw= +92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 172  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 173  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 174  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 175  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 176  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$FE,$F6,$0A  ; seg 177  yaw= +96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $60,$FC,$F6,$0A  ; seg 178  yaw= +96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $60,$FE,$F6,$0A  ; seg 179  yaw= +96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 180  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$03,$F6,$0A  ; seg 181  yaw= +96 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $60,$06,$F6,$0A  ; seg 182  yaw= +96 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $60,$03,$F6,$0A  ; seg 183  yaw= +96 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 184  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$03,$F6,$0A  ; seg 185  yaw= +96 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $60,$06,$F6,$0A  ; seg 186  yaw= +96 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $60,$03,$F6,$0A  ; seg 187  yaw= +96 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 188  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$FE,$F6,$0A  ; seg 189  yaw= +96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $60,$FC,$F6,$0A  ; seg 190  yaw= +96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $60,$FE,$F6,$0A  ; seg 191  yaw= +96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 192  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$FE,$F6,$0A  ; seg 193  yaw= +96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $60,$FC,$F6,$0A  ; seg 194  yaw= +96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $60,$FE,$F6,$0A  ; seg 195  yaw= +96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 196  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$03,$F6,$0A  ; seg 197  yaw= +96 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $60,$06,$F6,$0A  ; seg 198  yaw= +96 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $60,$03,$F6,$0A  ; seg 199  yaw= +96 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 200  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 201  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 202  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 203  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 204  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $64,$00,$F6,$0A  ; seg 205  yaw=+100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $68,$00,$F6,$0A  ; seg 206  yaw=+104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $6C,$00,$F6,$0A  ; seg 207  yaw=+108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $70,$00,$F6,$0A  ; seg 208  yaw=+112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $74,$00,$F6,$0A  ; seg 209  yaw=+116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $78,$00,$F6,$0A  ; seg 210  yaw=+120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $7C,$00,$F6,$0A  ; seg 211  yaw=+124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 212  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 213  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 214  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 215  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 216  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 217  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 218  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 219  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 220  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 221  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 222  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 223  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 224 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 225 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 226 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 227 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 228 (wraparound de seg 4)
        fcb   $00,$02,$F6,$0A  ; seg 229 (wraparound de seg 5)
        fcb   $00,$04,$F6,$0A  ; seg 230 (wraparound de seg 6)
        fcb   $00,$06,$F6,$0A  ; seg 231 (wraparound de seg 7)
