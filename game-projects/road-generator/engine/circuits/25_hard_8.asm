* ======================================================================
* Circuit_25_hard_8 — N=142 segments (format compact 8 oct/seg)
* Source       : 25_hard_8.bin (extrait de FILE30)
*
* Pays         : SCOTLAND
* Lieu         : rannoch moor, nr crianlarich
* Description  : landslides onto track
* Hazards      : beware
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000090 01:#6C246C 02:#484848 03:#909090 04:#482448 05:#B40000 06:#240000 07:#240000
*   08:#482448 09:#D8D8D8 10:#240000 11:#FCFCFC 12:#FC006C 13:#FC006C 14:#FC2490 15:#FC2490
*   16:#FC48B4 17:#FC48B4 18:#FC6CD8 19:#FC6CD8 20:#FC90FC 21:#FC90FC 22:#FCB4FC 23:#FCB4FC
*   24:#FCD8FC 25:#FCD8FC 26:#FCFCFC 27:#FCFCFC
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
* par circuit ; ce circuit : 10 entries utilisées).
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
* Taille totale : 1818 oct (nb_segments 2 + LUT 16 + segments 1200 + cache 600).
* ======================================================================

Circuit_25_hard_8_nb_segments
        fdb   142

Circuit_25_hard_8_sprite_lut
        fcb   $00,$82,$83,$8F,$A7,$81,$AB,$80,$8B,$8A,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_25_hard_8_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$03,$00,$00,$E0,$00  ; seg   8                      flags=[PIT]   #2:$8F@-32
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg   9                      flags=[PIT]
        fcb   $80,$00,$00,$04,$00,$00,$CC,$00  ; seg  10                      flags=[PIT]   #2:$A7@-52
        fcb   $80,$00,$00,$04,$00,$00,$D8,$00  ; seg  11                      flags=[PIT]   #2:$A7@-40
        fcb   $80,$00,$00,$03,$00,$00,$EC,$00  ; seg  12                      flags=[PIT]   #2:$8F@-20
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  13                      flags=[PIT]
        fcb   $80,$00,$05,$05,$EE,$00,$EE,$00  ; seg  14                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $80,$00,$05,$05,$EE,$00,$EE,$00  ; seg  15                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$05,$03,$EE,$00,$18,$00  ; seg  16  curve=-4                          #0:$81@-18 #2:$8F@+24
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg  17  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$03,$EC,$00,$20,$00  ; seg  18  curve=-4                          #0:$AB@-20 #2:$8F@+32
        fcb   $7C,$00,$06,$00,$EC,$00,$00,$00  ; seg  19  curve=-4                          #0:$AB@-20
        fcb   $00,$01,$06,$04,$EC,$00,$20,$00  ; seg  20            pitch=+1                #0:$AB@-20 #2:$A7@+32
        fcb   $00,$01,$06,$03,$EC,$00,$14,$00  ; seg  21            pitch=+1                #0:$AB@-20 #2:$8F@+20
        fcb   $00,$00,$06,$03,$EC,$00,$E8,$00  ; seg  22                                    #0:$AB@-20 #2:$8F@-24
        fcb   $00,$00,$06,$00,$EC,$00,$00,$00  ; seg  23                                    #0:$AB@-20
        fcb   $00,$00,$00,$04,$00,$00,$E0,$00  ; seg  24                                    #2:$A7@-32
        fcb   $00,$00,$00,$03,$00,$00,$EC,$00  ; seg  25                                    #2:$8F@-20
        fcb   $00,$7F,$07,$07,$12,$00,$12,$00  ; seg  26            pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $00,$7F,$07,$07,$12,$00,$12,$00  ; seg  27            pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg  28  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$03,$12,$00,$20,$00  ; seg  29  curve=+4                          #0:$80@+18 #2:$8F@+32
        fcb   $04,$00,$00,$03,$00,$00,$E0,$00  ; seg  30  curve=+4                          #2:$8F@-32
        fcb   $04,$00,$00,$04,$00,$00,$EC,$00  ; seg  31  curve=+4                          #2:$A7@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  33
        fcb   $00,$7F,$98,$03,$F3,$F6,$20,$00  ; seg  34            pitch=-1                #0:$8B@-13 #1:$8A@-10 #2:$8F@+32
        fcb   $00,$7F,$89,$80,$F9,$FB,$00,$F5  ; seg  35            pitch=-1                #0:$8A@-7 #1:$8B@-5 #3:$8B@-11
        fcb   $00,$00,$98,$04,$FA,$F2,$1C,$00  ; seg  36                                    #0:$8B@-6 #1:$8A@-14 #2:$A7@+28
        fcb   $00,$00,$88,$04,$F9,$F5,$20,$00  ; seg  37                                    #0:$8B@-7 #1:$8B@-11 #2:$A7@+32
        fcb   $00,$01,$99,$90,$F6,$F7,$00,$F5  ; seg  38            pitch=+1                #0:$8A@-10 #1:$8A@-9 #3:$8A@-11
        fcb   $00,$01,$09,$94,$F2,$00,$28,$F2  ; seg  39            pitch=+1                #0:$8A@-14 #2:$A7@+40 #3:$8A@-14
        fcb   $00,$7F,$88,$03,$F3,$FF,$2C,$00  ; seg  40            pitch=-1                #0:$8B@-13 #1:$8B@-1 #2:$8F@+44
        fcb   $00,$7F,$09,$93,$F7,$00,$30,$F4  ; seg  41            pitch=-1                #0:$8A@-9 #2:$8F@+48 #3:$8A@-12
        fcb   $00,$01,$98,$80,$F5,$F8,$00,$F8  ; seg  42            pitch=+1                #0:$8B@-11 #1:$8A@-8 #3:$8B@-8
        fcb   $00,$01,$09,$94,$FE,$00,$20,$F9  ; seg  43            pitch=+1                #0:$8A@-2 #2:$A7@+32 #3:$8A@-7
        fcb   $00,$00,$00,$04,$00,$00,$14,$00  ; seg  44                                    #2:$A7@+20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  45
        fcb   $00,$7F,$55,$55,$EE,$EE,$EE,$EE  ; seg  46            pitch=-1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$7F,$55,$55,$EE,$EE,$EE,$EE  ; seg  47            pitch=-1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  48  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  49  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$00,$EE,$00,$00,$00  ; seg  50  curve=-6                          #0:$81@-18
        fcb   $7A,$00,$05,$03,$EE,$00,$14,$00  ; seg  51  curve=-6                          #0:$81@-18 #2:$8F@+20
        fcb   $7C,$00,$05,$03,$EE,$00,$18,$00  ; seg  52  curve=-4                          #0:$81@-18 #2:$8F@+24
        fcb   $7C,$00,$05,$04,$EE,$00,$D0,$00  ; seg  53  curve=-4                          #0:$81@-18 #2:$A7@-48
        fcb   $7C,$02,$05,$05,$EE,$00,$EE,$00  ; seg  54  curve=-4  pitch=+2                #0:$81@-18 #2:$81@-18
        fcb   $7C,$02,$05,$05,$EE,$00,$EE,$00  ; seg  55  curve=-4  pitch=+2                #0:$81@-18 #2:$81@-18
        fcb   $7A,$7F,$05,$05,$EE,$00,$EE,$00  ; seg  56  curve=-6  pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7A,$7F,$05,$05,$EE,$00,$EE,$00  ; seg  57  curve=-6  pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$00,$EC,$00,$00,$00  ; seg  58  curve=-6                          #0:$AB@-20
        fcb   $7A,$00,$06,$03,$EC,$00,$20,$00  ; seg  59  curve=-6                          #0:$AB@-20 #2:$8F@+32
        fcb   $00,$00,$06,$03,$EC,$00,$30,$00  ; seg  60                                    #0:$AB@-20 #2:$8F@+48
        fcb   $00,$00,$06,$04,$EC,$00,$14,$00  ; seg  61                                    #0:$AB@-20 #2:$A7@+20
        fcb   $00,$7F,$06,$03,$EC,$00,$18,$00  ; seg  62            pitch=-1                #0:$AB@-20 #2:$8F@+24
        fcb   $00,$7F,$06,$00,$EC,$00,$00,$00  ; seg  63            pitch=-1                #0:$AB@-20
        fcb   $00,$7F,$06,$03,$14,$00,$30,$00  ; seg  64            pitch=-1                #0:$AB@+20 #2:$8F@+48
        fcb   $00,$7F,$06,$04,$14,$00,$E0,$00  ; seg  65            pitch=-1                #0:$AB@+20 #2:$A7@-32
        fcb   $00,$7F,$06,$00,$14,$00,$00,$00  ; seg  66            pitch=-1                #0:$AB@+20
        fcb   $00,$7F,$06,$04,$14,$00,$E8,$00  ; seg  67            pitch=-1                #0:$AB@+20 #2:$A7@-24
        fcb   $00,$00,$06,$03,$14,$00,$D8,$00  ; seg  68                                    #0:$AB@+20 #2:$8F@-40
        fcb   $00,$00,$06,$03,$14,$00,$CC,$00  ; seg  69                                    #0:$AB@+20 #2:$8F@-52
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  70                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  71                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$01,$07,$04,$12,$00,$E0,$00  ; seg  72  curve=+4  pitch=+1                #0:$80@+18 #2:$A7@-32
        fcb   $04,$01,$07,$03,$12,$00,$D0,$00  ; seg  73  curve=+4  pitch=+1                #0:$80@+18 #2:$8F@-48
        fcb   $04,$01,$07,$00,$12,$00,$00,$00  ; seg  74  curve=+4  pitch=+1                #0:$80@+18
        fcb   $04,$01,$07,$03,$12,$00,$20,$00  ; seg  75  curve=+4  pitch=+1                #0:$80@+18 #2:$8F@+32
        fcb   $04,$01,$07,$04,$12,$00,$38,$00  ; seg  76  curve=+4  pitch=+1                #0:$80@+18 #2:$A7@+56
        fcb   $04,$01,$07,$00,$12,$00,$00,$00  ; seg  77  curve=+4  pitch=+1                #0:$80@+18
        fcb   $04,$00,$05,$05,$EE,$00,$EE,$00  ; seg  78  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $04,$00,$05,$05,$EE,$00,$EE,$00  ; seg  79  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$05,$00,$EE,$00,$00,$00  ; seg  80  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$05,$03,$EE,$00,$30,$00  ; seg  81  curve=-5                          #0:$81@-18 #2:$8F@+48
        fcb   $7B,$00,$05,$03,$EE,$00,$14,$00  ; seg  82  curve=-5                          #0:$81@-18 #2:$8F@+20
        fcb   $7B,$00,$05,$04,$EE,$00,$14,$00  ; seg  83  curve=-5                          #0:$81@-18 #2:$A7@+20
        fcb   $7B,$00,$05,$00,$EE,$00,$00,$00  ; seg  84  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$05,$03,$EE,$00,$20,$00  ; seg  85  curve=-5                          #0:$81@-18 #2:$8F@+32
        fcb   $7B,$00,$00,$03,$00,$00,$1C,$00  ; seg  86  curve=-5                          #2:$8F@+28
        fcb   $7B,$00,$00,$04,$00,$00,$20,$00  ; seg  87  curve=-5                          #2:$A7@+32
        fcb   $00,$00,$00,$03,$00,$00,$1C,$00  ; seg  88                                    #2:$8F@+28
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  89
        fcb   $00,$02,$88,$03,$0E,$0C,$14,$00  ; seg  90            pitch=+2                #0:$8B@+14 #1:$8B@+12 #2:$8F@+20
        fcb   $00,$02,$09,$84,$08,$00,$20,$05  ; seg  91            pitch=+2                #0:$8A@+8 #2:$A7@+32 #3:$8B@+5
        fcb   $00,$7E,$88,$90,$08,$0D,$00,$06  ; seg  92            pitch=-2                #0:$8B@+8 #1:$8B@+13 #3:$8A@+6
        fcb   $00,$7E,$08,$83,$05,$00,$D8,$01  ; seg  93            pitch=-2                #0:$8B@+5 #2:$8F@-40 #3:$8B@+1
        fcb   $00,$7D,$99,$83,$0A,$0C,$E0,$07  ; seg  94            pitch=-3                #0:$8A@+10 #1:$8A@+12 #2:$8F@-32 #3:$8B@+7
        fcb   $00,$7D,$88,$90,$06,$03,$00,$0E  ; seg  95            pitch=-3                #0:$8B@+6 #1:$8B@+3 #3:$8A@+14
        fcb   $00,$03,$08,$04,$02,$00,$20,$00  ; seg  96            pitch=+3                #0:$8B@+2 #2:$A7@+32
        fcb   $00,$03,$09,$03,$0A,$00,$24,$00  ; seg  97            pitch=+3                #0:$8A@+10 #2:$8F@+36
        fcb   $00,$03,$98,$90,$0E,$0A,$00,$02  ; seg  98            pitch=+3                #0:$8B@+14 #1:$8A@+10 #3:$8A@+2
        fcb   $00,$03,$88,$03,$0F,$07,$20,$00  ; seg  99            pitch=+3                #0:$8B@+15 #1:$8B@+7 #2:$8F@+32
        fcb   $00,$00,$00,$04,$00,$00,$1C,$00  ; seg 100                                    #2:$A7@+28
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 101
        fcb   $00,$7D,$05,$05,$EE,$00,$EE,$00  ; seg 102            pitch=-3                #0:$81@-18 #2:$81@-18
        fcb   $00,$7D,$05,$05,$EE,$00,$EE,$00  ; seg 103            pitch=-3                #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$05,$03,$EE,$00,$20,$00  ; seg 104  curve=-5                          #0:$81@-18 #2:$8F@+32
        fcb   $7B,$00,$05,$03,$EE,$00,$14,$00  ; seg 105  curve=-5                          #0:$81@-18 #2:$8F@+20
        fcb   $7B,$00,$05,$00,$EE,$00,$00,$00  ; seg 106  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$05,$04,$EE,$00,$1C,$00  ; seg 107  curve=-5                          #0:$81@-18 #2:$A7@+28
        fcb   $7B,$00,$05,$03,$EE,$00,$20,$00  ; seg 108  curve=-5                          #0:$81@-18 #2:$8F@+32
        fcb   $7B,$00,$05,$00,$EE,$00,$00,$00  ; seg 109  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$06,$03,$EC,$00,$20,$00  ; seg 110  curve=-5                          #0:$AB@-20 #2:$8F@+32
        fcb   $7B,$00,$06,$00,$EC,$00,$00,$00  ; seg 111  curve=-5                          #0:$AB@-20
        fcb   $00,$00,$06,$04,$EC,$00,$14,$00  ; seg 112                                    #0:$AB@-20 #2:$A7@+20
        fcb   $00,$00,$06,$00,$EC,$00,$00,$00  ; seg 113                                    #0:$AB@-20
        fcb   $00,$00,$05,$05,$EE,$00,$EE,$00  ; seg 114                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$05,$05,$EE,$00,$EE,$00  ; seg 115                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$01,$05,$00,$EE,$00,$00,$00  ; seg 116  curve=-4  pitch=+1                #0:$81@-18
        fcb   $7C,$01,$05,$03,$EE,$00,$1C,$00  ; seg 117  curve=-4  pitch=+1                #0:$81@-18 #2:$8F@+28
        fcb   $7C,$7F,$06,$03,$EC,$00,$20,$00  ; seg 118  curve=-4  pitch=-1                #0:$AB@-20 #2:$8F@+32
        fcb   $7C,$7F,$06,$00,$EC,$00,$00,$00  ; seg 119  curve=-4  pitch=-1                #0:$AB@-20
        fcb   $00,$00,$06,$03,$EC,$00,$18,$00  ; seg 120                                    #0:$AB@-20 #2:$8F@+24
        fcb   $00,$00,$06,$04,$EC,$00,$20,$00  ; seg 121                                    #0:$AB@-20 #2:$A7@+32
        fcb   $00,$02,$06,$00,$14,$00,$00,$00  ; seg 122            pitch=+2                #0:$AB@+20
        fcb   $00,$02,$06,$03,$14,$00,$E0,$00  ; seg 123            pitch=+2                #0:$AB@+20 #2:$8F@-32
        fcb   $00,$00,$06,$03,$14,$00,$D0,$00  ; seg 124                                    #0:$AB@+20 #2:$8F@-48
        fcb   $00,$00,$06,$00,$14,$00,$00,$00  ; seg 125                                    #0:$AB@+20
        fcb   $00,$7E,$06,$04,$EC,$00,$28,$00  ; seg 126            pitch=-2                #0:$AB@-20 #2:$A7@+40
        fcb   $00,$7E,$06,$03,$EC,$00,$1C,$00  ; seg 127            pitch=-2                #0:$AB@-20 #2:$8F@+28
        fcb   $00,$00,$06,$03,$EC,$00,$20,$00  ; seg 128                                    #0:$AB@-20 #2:$8F@+32
        fcb   $00,$00,$06,$00,$EC,$00,$00,$00  ; seg 129                                    #0:$AB@-20
        fcb   $00,$01,$06,$04,$14,$00,$D8,$00  ; seg 130            pitch=+1                #0:$AB@+20 #2:$A7@-40
        fcb   $00,$01,$06,$03,$14,$00,$E0,$00  ; seg 131            pitch=+1                #0:$AB@+20 #2:$8F@-32
        fcb   $00,$7F,$06,$00,$14,$00,$00,$00  ; seg 132            pitch=-1                #0:$AB@+20
        fcb   $00,$7F,$06,$03,$14,$00,$EC,$00  ; seg 133            pitch=-1                #0:$AB@+20 #2:$8F@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 134
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 135
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 136
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 137
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 138
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 139
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 140
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 141
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 142                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 143
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 144
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 145
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 146                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 147                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 148                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 149                                    #0:$83@+18 #2:$83@+18

Circuit_25_hard_8_segment_cache
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
        fcb   $F0,$02,$F7,$0A  ; seg  23  yaw= -16 pitch=  +2 min_lat=  -9 max_lat= +10
        fcb   $F0,$02,$F8,$0A  ; seg  24  yaw= -16 pitch=  +2 min_lat=  -8 max_lat= +10
        fcb   $F0,$02,$F9,$0A  ; seg  25  yaw= -16 pitch=  +2 min_lat=  -7 max_lat= +10
        fcb   $F0,$02,$FA,$0A  ; seg  26  yaw= -16 pitch=  +2 min_lat=  -6 max_lat= +10
        fcb   $F0,$01,$FB,$0A  ; seg  27  yaw= -16 pitch=  +1 min_lat=  -5 max_lat= +10
        fcb   $F0,$00,$FC,$0A  ; seg  28  yaw= -16 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $F4,$00,$FD,$0A  ; seg  29  yaw= -12 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $F8,$00,$FE,$0A  ; seg  30  yaw=  -8 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $FC,$00,$FF,$0A  ; seg  31  yaw=  -4 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $00,$00,$00,$0A  ; seg  32  yaw=  +0 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $00,$00,$01,$0A  ; seg  33  yaw=  +0 pitch=  +0 min_lat=  +1 max_lat= +10
        fcb   $00,$00,$02,$0A  ; seg  34  yaw=  +0 pitch=  +0 min_lat=  +2 max_lat= +10
        fcb   $00,$FF,$03,$0A  ; seg  35  yaw=  +0 pitch=  -1 min_lat=  +3 max_lat= +10
        fcb   $00,$FE,$03,$0A  ; seg  36  yaw=  +0 pitch=  -2 min_lat=  +3 max_lat= +10
        fcb   $00,$FE,$04,$0A  ; seg  37  yaw=  +0 pitch=  -2 min_lat=  +4 max_lat= +10
        fcb   $00,$FE,$05,$0A  ; seg  38  yaw=  +0 pitch=  -2 min_lat=  +5 max_lat= +10
        fcb   $00,$FF,$06,$0A  ; seg  39  yaw=  +0 pitch=  -1 min_lat=  +6 max_lat= +10
        fcb   $00,$00,$07,$0A  ; seg  40  yaw=  +0 pitch=  +0 min_lat=  +7 max_lat= +10
        fcb   $00,$FF,$04,$0A  ; seg  41  yaw=  +0 pitch=  -1 min_lat=  +4 max_lat= +10
        fcb   $00,$FE,$05,$0A  ; seg  42  yaw=  +0 pitch=  -2 min_lat=  +5 max_lat= +10
        fcb   $00,$FF,$06,$0A  ; seg  43  yaw=  +0 pitch=  -1 min_lat=  +6 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  44  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  45  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  46  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg  47  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  48  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $FA,$FE,$F6,$0A  ; seg  49  yaw=  -6 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $F4,$FE,$F6,$0A  ; seg  50  yaw= -12 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $EE,$FE,$F6,$0A  ; seg  51  yaw= -18 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E8,$FE,$F6,$0A  ; seg  52  yaw= -24 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E4,$FE,$F6,$0A  ; seg  53  yaw= -28 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  54  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  55  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$02,$F6,$0A  ; seg  56  yaw= -40 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $D2,$01,$F6,$0A  ; seg  57  yaw= -46 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  58  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C6,$00,$F6,$0A  ; seg  59  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  60  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  61  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  62  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$FF,$F6,$0A  ; seg  63  yaw= -64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C0,$FE,$F6,$0A  ; seg  64  yaw= -64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C0,$FD,$F6,$0A  ; seg  65  yaw= -64 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $C0,$FC,$F6,$0A  ; seg  66  yaw= -64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C0,$FB,$F6,$0A  ; seg  67  yaw= -64 pitch=  -5 min_lat= -10 max_lat= +10
        fcb   $C0,$FA,$F6,$0A  ; seg  68  yaw= -64 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $C0,$FA,$F6,$0A  ; seg  69  yaw= -64 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $C0,$FA,$F6,$0A  ; seg  70  yaw= -64 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $C0,$FA,$F6,$0A  ; seg  71  yaw= -64 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $C0,$FA,$F6,$0A  ; seg  72  yaw= -64 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $C4,$FB,$F6,$0A  ; seg  73  yaw= -60 pitch=  -5 min_lat= -10 max_lat= +10
        fcb   $C8,$FC,$F6,$0A  ; seg  74  yaw= -56 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $CC,$FD,$F6,$0A  ; seg  75  yaw= -52 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $D0,$FE,$F6,$0A  ; seg  76  yaw= -48 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $D4,$FF,$F6,$09  ; seg  77  yaw= -44 pitch=  -1 min_lat= -10 max_lat=  +9
        fcb   $D8,$00,$F6,$08  ; seg  78  yaw= -40 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $DC,$00,$F6,$07  ; seg  79  yaw= -36 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $E0,$00,$F6,$06  ; seg  80  yaw= -32 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $DB,$00,$F6,$05  ; seg  81  yaw= -37 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $D6,$00,$F6,$04  ; seg  82  yaw= -42 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $D1,$00,$F6,$03  ; seg  83  yaw= -47 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $CC,$00,$F6,$02  ; seg  84  yaw= -52 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $C7,$00,$F6,$01  ; seg  85  yaw= -57 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $C2,$00,$F6,$00  ; seg  86  yaw= -62 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $BD,$00,$F6,$FF  ; seg  87  yaw= -67 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $B8,$00,$F6,$FE  ; seg  88  yaw= -72 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $B8,$00,$F6,$FD  ; seg  89  yaw= -72 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $B8,$00,$F6,$FC  ; seg  90  yaw= -72 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $B8,$02,$F6,$FB  ; seg  91  yaw= -72 pitch=  +2 min_lat= -10 max_lat=  -5
        fcb   $B8,$04,$F6,$FA  ; seg  92  yaw= -72 pitch=  +4 min_lat= -10 max_lat=  -6
        fcb   $B8,$02,$F6,$F9  ; seg  93  yaw= -72 pitch=  +2 min_lat= -10 max_lat=  -7
        fcb   $B8,$00,$F6,$FC  ; seg  94  yaw= -72 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $B8,$FD,$F6,$FB  ; seg  95  yaw= -72 pitch=  -3 min_lat= -10 max_lat=  -5
        fcb   $B8,$FA,$F6,$FA  ; seg  96  yaw= -72 pitch=  -6 min_lat= -10 max_lat=  -6
        fcb   $B8,$FD,$F6,$FB  ; seg  97  yaw= -72 pitch=  -3 min_lat= -10 max_lat=  -5
        fcb   $B8,$00,$F6,$FA  ; seg  98  yaw= -72 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $B8,$03,$F6,$FF  ; seg  99  yaw= -72 pitch=  +3 min_lat= -10 max_lat=  -1
        fcb   $B8,$06,$F6,$0A  ; seg 100  yaw= -72 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B8,$06,$F6,$0A  ; seg 101  yaw= -72 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B8,$06,$F6,$0A  ; seg 102  yaw= -72 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B8,$03,$F6,$0A  ; seg 103  yaw= -72 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 104  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B3,$00,$F6,$0A  ; seg 105  yaw= -77 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$0A  ; seg 106  yaw= -82 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A9,$00,$F6,$0A  ; seg 107  yaw= -87 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 108  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9F,$00,$F6,$0A  ; seg 109  yaw= -97 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9A,$00,$F6,$0A  ; seg 110  yaw=-102 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $95,$00,$F6,$0A  ; seg 111  yaw=-107 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 112  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 113  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 114  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 115  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 116  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$01,$F6,$0A  ; seg 117  yaw=-116 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $88,$02,$F6,$0A  ; seg 118  yaw=-120 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $84,$01,$F6,$0A  ; seg 119  yaw=-124 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 120  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 121  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 122  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 123  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$04,$F6,$0A  ; seg 124  yaw=-128 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $80,$04,$F6,$0A  ; seg 125  yaw=-128 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $80,$04,$F6,$0A  ; seg 126  yaw=-128 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 127  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 128  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 129  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 130  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 131  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 132  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 133  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 134  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 135  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 136  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 137  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 138  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 139  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 140  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 141  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 142 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 143 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 144 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 145 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 146 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 147 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 148 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 149 (wraparound de seg 7)
