* ======================================================================
* Circuit_03_easy_3 — N=208 segments (format compact 8 oct/seg)
* Source       : 03_easy_3.bin (extrait de FILE30)
*
* Pays         : SPAIN
* Lieu         : adacuelera, nr madrid
* Description  : some sharp corners
* Hazards      : rocks on right side of road
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
* Taille totale : 2610 oct (nb_segments 2 + LUT 16 + segments 1728 + cache 864).
* ======================================================================

Circuit_03_easy_3_nb_segments
        fdb   208

Circuit_03_easy_3_sprite_lut
        fcb   $00,$82,$81,$83,$AA,$8A,$8B,$80,$8F,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_03_easy_3_segments
        fcb   $7B,$80,$01,$00,$00,$00,$00,$00  ; seg   0  curve=-5            flags=[START] #0:$82@+0
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg   1  curve=-5
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg   2  curve=-5
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg   3  curve=-5
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   4
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   5
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg   6                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg   7                                    #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$02,$00,$EE,$00,$00,$00  ; seg   8  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$02,$00,$EE,$00,$00,$00  ; seg   9  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg  10  curve=-5
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg  11  curve=-5
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg  12                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg  13                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg  14                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg  15                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  16                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  17                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  18                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  19                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  20                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  21                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  22                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  23                      flags=[PIT]
        fcb   $00,$00,$04,$05,$EC,$00,$D8,$00  ; seg  24                                    #0:$AA@-20 #2:$8A@-40
        fcb   $00,$00,$04,$05,$EC,$00,$C8,$00  ; seg  25                                    #0:$AA@-20 #2:$8A@-56
        fcb   $00,$00,$04,$00,$EC,$00,$00,$00  ; seg  26                                    #0:$AA@-20
        fcb   $00,$00,$64,$00,$EC,$20,$00,$00  ; seg  27                                    #0:$AA@-20 #1:$8B@+32
        fcb   $00,$00,$00,$05,$00,$00,$34,$00  ; seg  28                                    #2:$8A@+52
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  29
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  30                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$67,$07,$12,$EC,$12,$00  ; seg  31                                    #0:$80@+18 #1:$8B@-20 #2:$80@+18
        fcb   $05,$00,$67,$00,$12,$E0,$00,$00  ; seg  32  curve=+5                          #0:$80@+18 #1:$8B@-32
        fcb   $05,$00,$07,$50,$12,$00,$00,$2C  ; seg  33  curve=+5                          #0:$80@+18 #3:$8A@+44
        fcb   $05,$00,$07,$05,$12,$00,$EC,$00  ; seg  34  curve=+5                          #0:$80@+18 #2:$8A@-20
        fcb   $05,$00,$07,$50,$12,$00,$00,$EC  ; seg  35  curve=+5                          #0:$80@+18 #3:$8A@-20
        fcb   $05,$00,$07,$00,$12,$00,$00,$00  ; seg  36  curve=+5                          #0:$80@+18
        fcb   $05,$00,$67,$00,$12,$EC,$00,$00  ; seg  37  curve=+5                          #0:$80@+18 #1:$8B@-20
        fcb   $05,$00,$50,$00,$00,$14,$00,$00  ; seg  38  curve=+5                          #1:$8A@+20
        fcb   $05,$00,$50,$00,$00,$D4,$00,$00  ; seg  39  curve=+5                          #1:$8A@-44
        fcb   $00,$00,$00,$06,$00,$00,$EC,$00  ; seg  40                                    #2:$8B@-20
        fcb   $00,$00,$00,$05,$00,$00,$EC,$00  ; seg  41                                    #2:$8A@-20
        fcb   $00,$7F,$22,$22,$EE,$EE,$EE,$EE  ; seg  42            pitch=-1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$7F,$22,$22,$EE,$EE,$EE,$EE  ; seg  43            pitch=-1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$02,$02,$EE,$00,$EE,$00  ; seg  44  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$02,$52,$EE,$00,$EE,$14  ; seg  45  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8A@+20
        fcb   $7A,$00,$02,$02,$EE,$00,$EE,$00  ; seg  46  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$02,$02,$EE,$00,$EE,$00  ; seg  47  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$02,$02,$EE,$00,$EE,$00  ; seg  48  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$02,$02,$EE,$00,$EE,$00  ; seg  49  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$05,$00,$00,$2C,$00  ; seg  50  curve=-6                          #2:$8A@+44
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg  51  curve=-6
        fcb   $00,$01,$04,$50,$EC,$00,$00,$14  ; seg  52            pitch=+1                #0:$AA@-20 #3:$8A@+20
        fcb   $00,$01,$04,$06,$EC,$00,$20,$00  ; seg  53            pitch=+1                #0:$AA@-20 #2:$8B@+32
        fcb   $00,$00,$04,$06,$EC,$00,$0C,$00  ; seg  54                                    #0:$AA@-20 #2:$8B@+12
        fcb   $00,$00,$64,$06,$EC,$08,$0E,$00  ; seg  55                                    #0:$AA@-20 #1:$8B@+8 #2:$8B@+14
        fcb   $00,$00,$04,$06,$EC,$00,$10,$00  ; seg  56                                    #0:$AA@-20 #2:$8B@+16
        fcb   $00,$00,$64,$05,$EC,$0C,$0E,$00  ; seg  57                                    #0:$AA@-20 #1:$8B@+12 #2:$8A@+14
        fcb   $00,$00,$04,$06,$EC,$00,$0E,$00  ; seg  58                                    #0:$AA@-20 #2:$8B@+14
        fcb   $00,$00,$54,$05,$EC,$0E,$0C,$00  ; seg  59                                    #0:$AA@-20 #1:$8A@+14 #2:$8A@+12
        fcb   $00,$00,$00,$56,$00,$00,$10,$14  ; seg  60                                    #2:$8B@+16 #3:$8A@+20
        fcb   $00,$00,$00,$66,$00,$00,$0C,$0E  ; seg  61                                    #2:$8B@+12 #3:$8B@+14
        fcb   $00,$01,$62,$02,$EE,$10,$EE,$00  ; seg  62            pitch=+1                #0:$81@-18 #1:$8B@+16 #2:$81@-18
        fcb   $00,$01,$02,$02,$EE,$00,$EE,$00  ; seg  63            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$02,$50,$EE,$00,$00,$D4  ; seg  64  curve=-4                          #0:$81@-18 #3:$8A@-44
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  65  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$52,$02,$EE,$20,$EE,$00  ; seg  66  curve=-4                          #0:$81@-18 #1:$8A@+32 #2:$81@-18
        fcb   $7C,$00,$02,$02,$EE,$00,$EE,$00  ; seg  67  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$02,$02,$EE,$00,$EE,$00  ; seg  68  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$52,$02,$EE,$D4,$EE,$00  ; seg  69  curve=-6                          #0:$81@-18 #1:$8A@-44 #2:$81@-18
        fcb   $7A,$00,$02,$00,$EE,$00,$00,$00  ; seg  70  curve=-6                          #0:$81@-18
        fcb   $7A,$00,$62,$00,$EE,$14,$00,$00  ; seg  71  curve=-6                          #0:$81@-18 #1:$8B@+20
        fcb   $7C,$00,$02,$08,$EE,$00,$1C,$00  ; seg  72  curve=-4                          #0:$81@-18 #2:$8F@+28
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  73  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$60,$00,$00,$14,$00,$00  ; seg  74  curve=-4                          #1:$8B@+20
        fcb   $7C,$00,$05,$08,$EC,$00,$14,$00  ; seg  75  curve=-4                          #0:$8A@-20 #2:$8F@+20
        fcb   $00,$7F,$08,$00,$EE,$00,$00,$00  ; seg  76            pitch=-1                #0:$8F@-18
        fcb   $00,$7F,$08,$00,$EA,$00,$00,$00  ; seg  77            pitch=-1                #0:$8F@-22
        fcb   $00,$00,$08,$08,$EC,$00,$1C,$00  ; seg  78                                    #0:$8F@-20 #2:$8F@+28
        fcb   $00,$00,$68,$08,$EE,$14,$2C,$00  ; seg  79                                    #0:$8F@-18 #1:$8B@+20 #2:$8F@+44
        fcb   $00,$00,$08,$50,$EA,$00,$00,$E0  ; seg  80                                    #0:$8F@-22 #3:$8A@-32
        fcb   $00,$00,$08,$00,$EA,$00,$00,$00  ; seg  81                                    #0:$8F@-22
        fcb   $00,$00,$58,$00,$EE,$20,$00,$00  ; seg  82                                    #0:$8F@-18 #1:$8A@+32
        fcb   $00,$00,$08,$08,$EE,$00,$24,$00  ; seg  83                                    #0:$8F@-18 #2:$8F@+36
        fcb   $00,$01,$58,$00,$EC,$14,$00,$00  ; seg  84            pitch=+1                #0:$8F@-20 #1:$8A@+20
        fcb   $00,$01,$08,$08,$EE,$00,$28,$00  ; seg  85            pitch=+1                #0:$8F@-18 #2:$8F@+40
        fcb   $00,$7F,$58,$00,$EA,$2C,$00,$00  ; seg  86            pitch=-1                #0:$8F@-22 #1:$8A@+44
        fcb   $00,$7F,$08,$08,$EC,$00,$30,$00  ; seg  87            pitch=-1                #0:$8F@-20 #2:$8F@+48
        fcb   $00,$00,$05,$00,$14,$00,$00,$00  ; seg  88                                    #0:$8A@+20
        fcb   $00,$00,$05,$60,$14,$00,$00,$E0  ; seg  89                                    #0:$8A@+20 #3:$8B@-32
        fcb   $00,$00,$77,$77,$12,$12,$12,$12  ; seg  90                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$77,$77,$12,$12,$12,$12  ; seg  91                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  92  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  93  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$57,$07,$12,$20,$12,$00  ; seg  94  curve=+6                          #0:$80@+18 #1:$8A@+32 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  95  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$57,$07,$12,$D4,$12,$00  ; seg  96  curve=+6                          #0:$80@+18 #1:$8A@-44 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  97  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$00,$06,$00,$00,$14,$00  ; seg  98  curve=+6                          #2:$8B@+20
        fcb   $06,$00,$00,$60,$00,$00,$00,$2C  ; seg  99  curve=+6                          #3:$8B@+44
        fcb   $00,$00,$08,$58,$16,$00,$E8,$E0  ; seg 100                                    #0:$8F@+22 #2:$8F@-24 #3:$8A@-32
        fcb   $00,$00,$08,$00,$14,$00,$00,$00  ; seg 101                                    #0:$8F@+20
        fcb   $00,$00,$08,$05,$18,$00,$EC,$00  ; seg 102                                    #0:$8F@+24 #2:$8A@-20
        fcb   $00,$00,$08,$08,$12,$00,$EC,$00  ; seg 103                                    #0:$8F@+18 #2:$8F@-20
        fcb   $00,$00,$08,$08,$16,$00,$E8,$00  ; seg 104                                    #0:$8F@+22 #2:$8F@-24
        fcb   $00,$00,$05,$08,$14,$00,$EC,$00  ; seg 105                                    #0:$8A@+20 #2:$8F@-20
        fcb   $00,$00,$08,$08,$12,$00,$EE,$00  ; seg 106                                    #0:$8F@+18 #2:$8F@-18
        fcb   $00,$00,$08,$68,$18,$00,$EA,$EC  ; seg 107                                    #0:$8F@+24 #2:$8F@-22 #3:$8B@-20
        fcb   $00,$00,$50,$00,$00,$D4,$00,$00  ; seg 108                                    #1:$8A@-44
        fcb   $00,$00,$05,$60,$E0,$00,$00,$20  ; seg 109                                    #0:$8A@-32 #3:$8B@+32
        fcb   $00,$01,$02,$02,$EE,$00,$EE,$00  ; seg 110            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $00,$01,$02,$52,$EE,$00,$EE,$EC  ; seg 111            pitch=+1                #0:$81@-18 #2:$81@-18 #3:$8A@-20
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 112  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$62,$50,$EE,$20,$00,$EC  ; seg 113  curve=-4                          #0:$81@-18 #1:$8B@+32 #3:$8A@-20
        fcb   $7C,$00,$05,$08,$EC,$00,$12,$00  ; seg 114  curve=-4                          #0:$8A@-20 #2:$8F@+18
        fcb   $7C,$00,$00,$68,$00,$00,$16,$14  ; seg 115  curve=-4                          #2:$8F@+22 #3:$8B@+20
        fcb   $00,$7F,$08,$08,$EE,$00,$18,$00  ; seg 116            pitch=-1                #0:$8F@-18 #2:$8F@+24
        fcb   $00,$7F,$58,$08,$EC,$2C,$14,$00  ; seg 117            pitch=-1                #0:$8F@-20 #1:$8A@+44 #2:$8F@+20
        fcb   $00,$00,$08,$05,$EA,$00,$EC,$00  ; seg 118                                    #0:$8F@-22 #2:$8A@-20
        fcb   $00,$00,$00,$08,$00,$00,$16,$00  ; seg 119                                    #2:$8F@+22
        fcb   $00,$00,$08,$08,$EE,$00,$18,$00  ; seg 120                                    #0:$8F@-18 #2:$8F@+24
        fcb   $00,$00,$58,$00,$EA,$14,$00,$00  ; seg 121                                    #0:$8F@-22 #1:$8A@+20
        fcb   $00,$00,$08,$08,$EE,$00,$12,$00  ; seg 122                                    #0:$8F@-18 #2:$8F@+18
        fcb   $00,$00,$08,$08,$EC,$00,$14,$00  ; seg 123                                    #0:$8F@-20 #2:$8F@+20
        fcb   $00,$00,$06,$08,$20,$00,$16,$00  ; seg 124                                    #0:$8B@+32 #2:$8F@+22
        fcb   $00,$00,$00,$05,$00,$00,$EC,$00  ; seg 125                                    #2:$8A@-20
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 126                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$67,$12,$00,$12,$E0  ; seg 127                                    #0:$80@+18 #2:$80@+18 #3:$8B@-32
        fcb   $04,$00,$07,$05,$12,$00,$EC,$00  ; seg 128  curve=+4                          #0:$80@+18 #2:$8A@-20
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 129  curve=+4                          #0:$80@+18
        fcb   $04,$00,$08,$08,$EE,$00,$16,$00  ; seg 130  curve=+4                          #0:$8F@-18 #2:$8F@+22
        fcb   $04,$00,$58,$00,$EC,$14,$00,$00  ; seg 131  curve=+4                          #0:$8F@-20 #1:$8A@+20
        fcb   $00,$01,$58,$08,$EA,$20,$12,$00  ; seg 132            pitch=+1                #0:$8F@-22 #1:$8A@+32 #2:$8F@+18
        fcb   $00,$01,$08,$08,$EE,$00,$14,$00  ; seg 133            pitch=+1                #0:$8F@-18 #2:$8F@+20
        fcb   $00,$00,$68,$08,$EE,$EC,$12,$00  ; seg 134                                    #0:$8F@-18 #1:$8B@-20 #2:$8F@+18
        fcb   $00,$00,$08,$00,$EC,$00,$00,$00  ; seg 135                                    #0:$8F@-20
        fcb   $00,$7F,$58,$00,$12,$E0,$00,$00  ; seg 136            pitch=-1                #0:$8F@+18 #1:$8A@-32
        fcb   $00,$7F,$08,$08,$14,$00,$EE,$00  ; seg 137            pitch=-1                #0:$8F@+20 #2:$8F@-18
        fcb   $00,$01,$08,$60,$12,$00,$00,$2C  ; seg 138            pitch=+1                #0:$8F@+18 #3:$8B@+44
        fcb   $00,$01,$08,$08,$18,$00,$EE,$00  ; seg 139            pitch=+1                #0:$8F@+24 #2:$8F@-18
        fcb   $00,$00,$08,$08,$16,$00,$EE,$00  ; seg 140                                    #0:$8F@+22 #2:$8F@-18
        fcb   $00,$00,$58,$00,$12,$20,$00,$00  ; seg 141                                    #0:$8F@+18 #1:$8A@+32
        fcb   $00,$7F,$02,$02,$EE,$00,$EE,$00  ; seg 142            pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $00,$7F,$02,$02,$EE,$00,$EE,$00  ; seg 143            pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$02,$06,$EE,$00,$14,$00  ; seg 144  curve=-4                          #0:$81@-18 #2:$8B@+20
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 145  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$02,$EE,$00,$EE,$00  ; seg 146  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$02,$02,$EE,$00,$EE,$00  ; seg 147  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$52,$02,$EE,$E0,$EE,$00  ; seg 148  curve=-6                          #0:$81@-18 #1:$8A@-32 #2:$81@-18
        fcb   $7A,$00,$02,$02,$EE,$00,$EE,$00  ; seg 149  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$52,$00,$EE,$20,$00,$00  ; seg 150  curve=-6                          #0:$81@-18 #1:$8A@+32
        fcb   $7A,$00,$02,$00,$EE,$00,$00,$00  ; seg 151  curve=-6                          #0:$81@-18
        fcb   $7C,$00,$02,$58,$EE,$00,$14,$14  ; seg 152  curve=-4                          #0:$81@-18 #2:$8F@+20 #3:$8A@+20
        fcb   $7C,$00,$02,$60,$EE,$00,$00,$EC  ; seg 153  curve=-4                          #0:$81@-18 #3:$8B@-20
        fcb   $7C,$00,$08,$08,$14,$00,$12,$00  ; seg 154  curve=-4                          #0:$8F@+20 #2:$8F@+18
        fcb   $7C,$00,$08,$06,$16,$00,$2C,$00  ; seg 155  curve=-4                          #0:$8F@+22 #2:$8B@+44
        fcb   $00,$00,$08,$08,$12,$00,$14,$00  ; seg 156                                    #0:$8F@+18 #2:$8F@+20
        fcb   $00,$00,$08,$05,$14,$00,$E0,$00  ; seg 157                                    #0:$8F@+20 #2:$8A@-32
        fcb   $00,$7F,$00,$08,$00,$00,$16,$00  ; seg 158            pitch=-1                #2:$8F@+22
        fcb   $00,$7F,$08,$00,$12,$00,$00,$00  ; seg 159            pitch=-1                #0:$8F@+18
        fcb   $00,$00,$08,$60,$16,$00,$00,$14  ; seg 160                                    #0:$8F@+22 #3:$8B@+20
        fcb   $00,$00,$08,$08,$14,$00,$14,$00  ; seg 161                                    #0:$8F@+20 #2:$8F@+20
        fcb   $00,$01,$50,$08,$00,$EC,$12,$00  ; seg 162            pitch=+1                #1:$8A@-20 #2:$8F@+18
        fcb   $00,$01,$08,$08,$16,$00,$18,$00  ; seg 163            pitch=+1                #0:$8F@+22 #2:$8F@+24
        fcb   $00,$7F,$58,$60,$14,$20,$00,$20  ; seg 164            pitch=-1                #0:$8F@+20 #1:$8A@+32 #3:$8B@+32
        fcb   $00,$7F,$08,$58,$12,$00,$14,$E0  ; seg 165            pitch=-1                #0:$8F@+18 #2:$8F@+20 #3:$8A@-32
        fcb   $00,$00,$00,$08,$00,$00,$16,$00  ; seg 166                                    #2:$8F@+22
        fcb   $00,$00,$68,$00,$12,$14,$00,$00  ; seg 167                                    #0:$8F@+18 #1:$8B@+20
        fcb   $00,$01,$08,$00,$14,$00,$00,$00  ; seg 168            pitch=+1                #0:$8F@+20
        fcb   $00,$01,$08,$08,$10,$00,$14,$00  ; seg 169            pitch=+1                #0:$8F@+16 #2:$8F@+20
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 170                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 171                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$02,$08,$EE,$00,$12,$00  ; seg 172  curve=-4                          #0:$81@-18 #2:$8F@+18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 173  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$08,$08,$12,$00,$18,$00  ; seg 174  curve=-4                          #0:$8F@+18 #2:$8F@+24
        fcb   $7C,$00,$08,$08,$16,$00,$14,$00  ; seg 175  curve=-4                          #0:$8F@+22 #2:$8F@+20
        fcb   $00,$00,$50,$06,$00,$14,$0C,$00  ; seg 176                                    #1:$8A@+20 #2:$8B@+12
        fcb   $00,$00,$05,$00,$0C,$00,$00,$00  ; seg 177                                    #0:$8A@+12
        fcb   $00,$00,$06,$06,$0E,$00,$0E,$00  ; seg 178                                    #0:$8B@+14 #2:$8B@+14
        fcb   $00,$00,$06,$05,$0C,$00,$12,$00  ; seg 179                                    #0:$8B@+12 #2:$8A@+18
        fcb   $00,$7F,$60,$06,$00,$D4,$10,$00  ; seg 180            pitch=-1                #1:$8B@-44 #2:$8B@+16
        fcb   $00,$7F,$06,$06,$10,$00,$0C,$00  ; seg 181            pitch=-1                #0:$8B@+16 #2:$8B@+12
        fcb   $00,$00,$50,$06,$00,$EC,$0E,$00  ; seg 182                                    #1:$8A@-20 #2:$8B@+14
        fcb   $00,$00,$06,$05,$0C,$00,$0E,$00  ; seg 183                                    #0:$8B@+12 #2:$8A@+14
        fcb   $00,$02,$54,$00,$14,$20,$00,$00  ; seg 184            pitch=+2                #0:$AA@+20 #1:$8A@+32
        fcb   $00,$02,$04,$06,$14,$00,$D4,$00  ; seg 185            pitch=+2                #0:$AA@+20 #2:$8B@-44
        fcb   $00,$00,$54,$50,$14,$EC,$00,$20  ; seg 186                                    #0:$AA@+20 #1:$8A@-20 #3:$8A@+32
        fcb   $00,$00,$04,$00,$14,$00,$00,$00  ; seg 187                                    #0:$AA@+20
        fcb   $00,$00,$54,$50,$14,$EC,$00,$2C  ; seg 188                                    #0:$AA@+20 #1:$8A@-20 #3:$8A@+44
        fcb   $00,$00,$64,$00,$14,$20,$00,$00  ; seg 189                                    #0:$AA@+20 #1:$8B@+32
        fcb   $00,$7F,$04,$05,$14,$00,$E0,$00  ; seg 190            pitch=-1                #0:$AA@+20 #2:$8A@-32
        fcb   $00,$7F,$04,$50,$14,$00,$00,$14  ; seg 191            pitch=-1                #0:$AA@+20 #3:$8A@+20
        fcb   $00,$00,$04,$60,$EC,$00,$00,$14  ; seg 192                                    #0:$AA@-20 #3:$8B@+20
        fcb   $00,$00,$04,$50,$EC,$00,$00,$EC  ; seg 193                                    #0:$AA@-20 #3:$8A@-20
        fcb   $00,$00,$54,$00,$EC,$EC,$00,$00  ; seg 194                                    #0:$AA@-20 #1:$8A@-20
        fcb   $00,$00,$64,$00,$EC,$14,$00,$00  ; seg 195                                    #0:$AA@-20 #1:$8B@+20
        fcb   $00,$00,$64,$00,$EC,$14,$00,$00  ; seg 196                                    #0:$AA@-20 #1:$8B@+20
        fcb   $00,$00,$54,$00,$EC,$1C,$00,$00  ; seg 197                                    #0:$AA@-20 #1:$8A@+28
        fcb   $00,$00,$04,$60,$EC,$00,$00,$14  ; seg 198                                    #0:$AA@-20 #3:$8B@+20
        fcb   $00,$00,$54,$00,$EC,$20,$00,$00  ; seg 199                                    #0:$AA@-20 #1:$8A@+32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 200
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 201
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 202
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 203
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 204
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 205
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 206
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 207
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $7B,$00,$01,$00,$00,$00,$00,$00  ; seg 208  curve=-5                          #0:$82@+0
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg 209  curve=-5
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg 210  curve=-5
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg 211  curve=-5
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 212
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 213
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 214                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 215                                    #0:$81@-18 #2:$81@-18

Circuit_03_easy_3_segment_cache
        fcb   $00,$00,$F6,$0A  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FB,$00,$F6,$0A  ; seg   1  yaw=  -5 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F6,$00,$F6,$0A  ; seg   2  yaw= -10 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F1,$00,$F6,$0A  ; seg   3  yaw= -15 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg   4  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg   5  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg   6  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg   7  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg   8  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E7,$00,$F6,$0A  ; seg   9  yaw= -25 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  10  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DD,$00,$F6,$0A  ; seg  11  yaw= -35 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  12  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  13  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  14  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  15  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  16  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  17  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  18  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  19  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  20  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  21  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  22  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  23  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  24  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  25  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  26  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  27  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  28  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  29  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  30  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  31  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  32  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DD,$00,$F6,$0A  ; seg  33  yaw= -35 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  34  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E7,$00,$F6,$0A  ; seg  35  yaw= -25 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  36  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F1,$00,$F6,$0A  ; seg  37  yaw= -15 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F6,$00,$F6,$0A  ; seg  38  yaw= -10 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FB,$00,$F6,$0A  ; seg  39  yaw=  -5 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  40  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  41  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  42  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg  43  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  44  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $FA,$FE,$F6,$0A  ; seg  45  yaw=  -6 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $F4,$FE,$F6,$09  ; seg  46  yaw= -12 pitch=  -2 min_lat= -10 max_lat=  +9
        fcb   $EE,$FE,$F6,$08  ; seg  47  yaw= -18 pitch=  -2 min_lat= -10 max_lat=  +8
        fcb   $E8,$FE,$F6,$07  ; seg  48  yaw= -24 pitch=  -2 min_lat= -10 max_lat=  +7
        fcb   $E2,$FE,$F6,$06  ; seg  49  yaw= -30 pitch=  -2 min_lat= -10 max_lat=  +6
        fcb   $DC,$FE,$F6,$05  ; seg  50  yaw= -36 pitch=  -2 min_lat= -10 max_lat=  +5
        fcb   $D6,$FE,$F6,$04  ; seg  51  yaw= -42 pitch=  -2 min_lat= -10 max_lat=  +4
        fcb   $D0,$FE,$F6,$03  ; seg  52  yaw= -48 pitch=  -2 min_lat= -10 max_lat=  +3
        fcb   $D0,$FF,$F6,$02  ; seg  53  yaw= -48 pitch=  -1 min_lat= -10 max_lat=  +2
        fcb   $D0,$00,$F6,$01  ; seg  54  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $D0,$00,$F6,$00  ; seg  55  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $D0,$00,$F6,$05  ; seg  56  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $D0,$00,$F6,$04  ; seg  57  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $D0,$00,$F6,$05  ; seg  58  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $D0,$00,$F6,$04  ; seg  59  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $D0,$00,$F6,$05  ; seg  60  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $D0,$00,$F6,$04  ; seg  61  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $D0,$00,$F6,$08  ; seg  62  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $D0,$01,$F6,$0A  ; seg  63  yaw= -48 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $D0,$02,$F6,$0A  ; seg  64  yaw= -48 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $CC,$02,$F6,$0A  ; seg  65  yaw= -52 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg  66  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C4,$02,$F6,$0A  ; seg  67  yaw= -60 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  68  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $BA,$02,$F6,$0A  ; seg  69  yaw= -70 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B4,$02,$F6,$0A  ; seg  70  yaw= -76 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $AE,$02,$F6,$0A  ; seg  71  yaw= -82 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg  72  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A4,$02,$F6,$0A  ; seg  73  yaw= -92 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A0,$02,$F6,$0A  ; seg  74  yaw= -96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $9C,$02,$F6,$0A  ; seg  75  yaw=-100 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $98,$02,$F6,$0A  ; seg  76  yaw=-104 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $98,$01,$F6,$0A  ; seg  77  yaw=-104 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  78  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  79  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  80  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  81  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  82  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  83  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  84  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$01,$F6,$0A  ; seg  85  yaw=-104 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $98,$02,$F6,$0A  ; seg  86  yaw=-104 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $98,$01,$F6,$0A  ; seg  87  yaw=-104 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  88  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  89  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  90  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  91  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  92  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9E,$00,$F6,$0A  ; seg  93  yaw= -98 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg  94  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AA,$00,$F6,$0A  ; seg  95  yaw= -86 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  96  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg  97  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  98  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg  99  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 100  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 101  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 102  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 103  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 104  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 105  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 106  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 107  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 108  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 109  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 110  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$01,$F6,$0A  ; seg 111  yaw= -56 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg 112  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C4,$02,$F6,$0A  ; seg 113  yaw= -60 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 114  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $BC,$02,$F6,$0A  ; seg 115  yaw= -68 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B8,$02,$F6,$0A  ; seg 116  yaw= -72 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B8,$01,$F6,$0A  ; seg 117  yaw= -72 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 118  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 119  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 120  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 121  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 122  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 123  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 124  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 125  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 126  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 127  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 128  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 129  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 130  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg 131  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 132  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$01,$F6,$0A  ; seg 133  yaw= -56 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg 134  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg 135  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg 136  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C8,$01,$F6,$0A  ; seg 137  yaw= -56 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 138  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$01,$F6,$0A  ; seg 139  yaw= -56 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg 140  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg 141  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg 142  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C8,$01,$F6,$0A  ; seg 143  yaw= -56 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 144  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg 145  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 146  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 147  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 148  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B2,$00,$F6,$0A  ; seg 149  yaw= -78 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg 150  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A6,$00,$F6,$0A  ; seg 151  yaw= -90 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 152  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg 153  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 154  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 155  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 156  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 157  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 158  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$FF,$F6,$0A  ; seg 159  yaw=-112 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $90,$FE,$F6,$0A  ; seg 160  yaw=-112 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $90,$FE,$F6,$0A  ; seg 161  yaw=-112 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $90,$FE,$F6,$0A  ; seg 162  yaw=-112 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $90,$FF,$F6,$0A  ; seg 163  yaw=-112 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 164  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$FF,$F6,$0A  ; seg 165  yaw=-112 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $90,$FE,$F6,$0A  ; seg 166  yaw=-112 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $90,$FE,$F6,$0A  ; seg 167  yaw=-112 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $90,$FE,$F6,$09  ; seg 168  yaw=-112 pitch=  -2 min_lat= -10 max_lat=  +9
        fcb   $90,$FF,$F6,$08  ; seg 169  yaw=-112 pitch=  -1 min_lat= -10 max_lat=  +8
        fcb   $90,$00,$F6,$0A  ; seg 170  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$09  ; seg 171  yaw=-112 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $90,$00,$F6,$08  ; seg 172  yaw=-112 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $8C,$00,$F6,$07  ; seg 173  yaw=-116 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $88,$00,$F6,$06  ; seg 174  yaw=-120 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $84,$00,$F6,$05  ; seg 175  yaw=-124 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $80,$00,$F6,$04  ; seg 176  yaw=-128 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $80,$00,$F6,$04  ; seg 177  yaw=-128 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $80,$00,$F6,$05  ; seg 178  yaw=-128 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $80,$00,$F6,$04  ; seg 179  yaw=-128 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $80,$00,$F6,$05  ; seg 180  yaw=-128 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $80,$FF,$F6,$04  ; seg 181  yaw=-128 pitch=  -1 min_lat= -10 max_lat=  +4
        fcb   $80,$FE,$F6,$05  ; seg 182  yaw=-128 pitch=  -2 min_lat= -10 max_lat=  +5
        fcb   $80,$FE,$F6,$04  ; seg 183  yaw=-128 pitch=  -2 min_lat= -10 max_lat=  +4
        fcb   $80,$FE,$F6,$0A  ; seg 184  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 185  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 186  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 187  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 188  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 189  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 190  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 191  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 192  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 193  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 194  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 195  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 196  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 197  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 198  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 199  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 200  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 201  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 202  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 203  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 204  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 205  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 206  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 207  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 208 (wraparound de seg 0)
        fcb   $FB,$00,$F6,$0A  ; seg 209 (wraparound de seg 1)
        fcb   $F6,$00,$F6,$0A  ; seg 210 (wraparound de seg 2)
        fcb   $F1,$00,$F6,$0A  ; seg 211 (wraparound de seg 3)
        fcb   $EC,$00,$F6,$0A  ; seg 212 (wraparound de seg 4)
        fcb   $EC,$00,$F6,$0A  ; seg 213 (wraparound de seg 5)
        fcb   $EC,$00,$F6,$0A  ; seg 214 (wraparound de seg 6)
        fcb   $EC,$00,$F6,$0A  ; seg 215 (wraparound de seg 7)
