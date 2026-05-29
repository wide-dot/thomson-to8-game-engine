* ======================================================================
* Circuit_00_training — N=122 segments (format compact 8 oct/seg)
* Source       : 00_training.bin (extrait de FILE30)
*
* Pays         : ITALY
* Lieu         : verona, north italy
* Description  : flat with gentle curves
* Hazards      : no hazards
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#00006C 01:#909090 02:#000000 03:#484848 04:#244824 05:#B40000 06:#242400 07:#242400
*   08:#004824 09:#D8D8D8 10:#002400 11:#FCFCFC 12:#486C48 13:#486C48 14:#6C6C48 15:#6C6C48
*   16:#906C48 17:#906C48 18:#B46C48 19:#B46C48 20:#D86C48 21:#D86C48 22:#FC6C48 23:#FC6C48
*   24:#FC906C 25:#FC906C 26:#FCB490 27:#FCB490
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
* Taille totale : 1578 oct (nb_segments 2 + LUT 16 + segments 1040 + cache 520).
* ======================================================================

Circuit_00_training_nb_segments
        fdb   122

Circuit_00_training_sprite_lut
        fcb   $00,$82,$83,$86,$81,$8A,$89,$94,$8B,$80,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_00_training_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg   8                      flags=[PIT]
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg   9                      flags=[PIT]   #0:$86@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  10                      flags=[PIT]   #0:$86@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  11                      flags=[PIT]   #0:$86@-20
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  12                      flags=[PIT]
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  13                      flags=[PIT]   #0:$86@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  14                      flags=[PIT]   #0:$86@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  15                      flags=[PIT]   #0:$86@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  16                                    #0:$86@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  17                                    #0:$86@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  18                                    #0:$86@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  19                                    #0:$86@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  21
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  22                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  23                                    #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$04,$00,$EE,$00,$00,$00  ; seg  24  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$04,$00,$EE,$00,$00,$00  ; seg  25  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$04,$00,$EE,$00,$00,$00  ; seg  26  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$04,$00,$EE,$00,$00,$00  ; seg  27  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$04,$05,$EE,$00,$20,$00  ; seg  28  curve=-5                          #0:$81@-18 #2:$8A@+32
        fcb   $7B,$00,$04,$00,$EE,$00,$00,$00  ; seg  29  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$00,$60,$00,$00,$00,$18  ; seg  30  curve=-5                          #3:$89@+24
        fcb   $7B,$00,$00,$00,$00,$00,$00,$00  ; seg  31  curve=-5
        fcb   $00,$00,$07,$60,$14,$00,$00,$28  ; seg  32                                    #0:$94@+20 #3:$89@+40
        fcb   $00,$00,$07,$06,$EC,$00,$20,$00  ; seg  33                                    #0:$94@-20 #2:$89@+32
        fcb   $00,$00,$07,$00,$14,$00,$00,$00  ; seg  34                                    #0:$94@+20
        fcb   $00,$00,$07,$50,$EC,$00,$00,$1C  ; seg  35                                    #0:$94@-20 #3:$8A@+28
        fcb   $00,$00,$57,$00,$14,$D8,$00,$00  ; seg  36                                    #0:$94@+20 #1:$8A@-40
        fcb   $00,$00,$07,$00,$EC,$00,$00,$00  ; seg  37                                    #0:$94@-20
        fcb   $00,$00,$07,$06,$14,$00,$E8,$00  ; seg  38                                    #0:$94@+20 #2:$89@-24
        fcb   $00,$00,$07,$50,$EC,$00,$00,$30  ; seg  39                                    #0:$94@-20 #3:$8A@+48
        fcb   $00,$00,$07,$00,$14,$00,$00,$00  ; seg  40                                    #0:$94@+20
        fcb   $00,$00,$07,$80,$EC,$00,$00,$28  ; seg  41                                    #0:$94@-20 #3:$8B@+40
        fcb   $00,$00,$07,$06,$14,$00,$E0,$00  ; seg  42                                    #0:$94@+20 #2:$89@-32
        fcb   $00,$00,$07,$00,$EC,$00,$00,$00  ; seg  43                                    #0:$94@-20
        fcb   $00,$00,$50,$05,$00,$30,$DC,$00  ; seg  44                                    #1:$8A@+48 #2:$8A@-36
        fcb   $00,$00,$00,$80,$00,$00,$00,$D4  ; seg  45                                    #3:$8B@-44
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  46                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  47                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  48  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$54,$04,$EE,$1C,$EE,$00  ; seg  49  curve=-6                          #0:$81@-18 #1:$8A@+28 #2:$81@-18
        fcb   $7A,$00,$04,$64,$EE,$00,$EE,$24  ; seg  50  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$89@+36
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  51  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$54,$EE,$00,$EE,$D0  ; seg  52  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8A@-48
        fcb   $7A,$00,$64,$04,$EE,$30,$EE,$00  ; seg  53  curve=-6                          #0:$81@-18 #1:$89@+48 #2:$81@-18
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg  54  curve=-6
        fcb   $7A,$00,$00,$06,$00,$00,$E8,$00  ; seg  55  curve=-6                          #2:$89@-24
        fcb   $00,$00,$80,$00,$00,$28,$00,$00  ; seg  56                                    #1:$8B@+40
        fcb   $00,$00,$00,$60,$00,$00,$00,$D4  ; seg  57                                    #3:$89@-44
        fcb   $00,$00,$00,$06,$00,$00,$E0,$00  ; seg  58                                    #2:$89@-32
        fcb   $00,$00,$00,$05,$00,$00,$D8,$00  ; seg  59                                    #2:$8A@-40
        fcb   $00,$00,$06,$00,$E0,$00,$00,$00  ; seg  60                                    #0:$89@-32
        fcb   $00,$00,$00,$50,$00,$00,$00,$E8  ; seg  61                                    #3:$8A@-24
        fcb   $00,$00,$09,$09,$12,$00,$12,$00  ; seg  62                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$09,$09,$12,$00,$12,$00  ; seg  63                                    #0:$80@+18 #2:$80@+18
        fcb   $05,$00,$89,$00,$12,$D4,$00,$00  ; seg  64  curve=+5                          #0:$80@+18 #1:$8B@-44
        fcb   $05,$00,$09,$08,$12,$00,$D8,$00  ; seg  65  curve=+5                          #0:$80@+18 #2:$8B@-40
        fcb   $05,$00,$09,$00,$12,$00,$00,$00  ; seg  66  curve=+5                          #0:$80@+18
        fcb   $05,$00,$09,$50,$12,$00,$00,$EC  ; seg  67  curve=+5                          #0:$80@+18 #3:$8A@-20
        fcb   $05,$00,$09,$06,$12,$00,$C8,$00  ; seg  68  curve=+5                          #0:$80@+18 #2:$89@-56
        fcb   $05,$00,$09,$50,$12,$00,$00,$E4  ; seg  69  curve=+5                          #0:$80@+18 #3:$8A@-28
        fcb   $05,$00,$60,$00,$00,$38,$00,$00  ; seg  70  curve=+5                          #1:$89@+56
        fcb   $05,$00,$00,$08,$00,$00,$E0,$00  ; seg  71  curve=+5                          #2:$8B@-32
        fcb   $00,$00,$07,$60,$EC,$00,$00,$D0  ; seg  72                                    #0:$94@-20 #3:$89@-48
        fcb   $00,$00,$07,$05,$EC,$00,$38,$00  ; seg  73                                    #0:$94@-20 #2:$8A@+56
        fcb   $00,$00,$67,$00,$EC,$24,$00,$00  ; seg  74                                    #0:$94@-20 #1:$89@+36
        fcb   $00,$00,$07,$00,$EC,$00,$00,$00  ; seg  75                                    #0:$94@-20
        fcb   $00,$00,$00,$05,$00,$00,$1C,$00  ; seg  76                                    #2:$8A@+28
        fcb   $00,$00,$80,$50,$00,$20,$00,$28  ; seg  77                                    #1:$8B@+32 #3:$8A@+40
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  78                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  79                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  80  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$84,$00,$EE,$24,$00,$00  ; seg  81  curve=-4                          #0:$81@-18 #1:$8B@+36
        fcb   $7C,$00,$00,$60,$00,$00,$00,$20  ; seg  82  curve=-4                          #3:$89@+32
        fcb   $7C,$00,$00,$05,$00,$00,$38,$00  ; seg  83  curve=-4                          #2:$8A@+56
        fcb   $00,$00,$08,$00,$D4,$00,$00,$00  ; seg  84                                    #0:$8B@-44
        fcb   $00,$00,$50,$00,$00,$C8,$00,$00  ; seg  85                                    #1:$8A@-56
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  86                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  87                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  88  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$34  ; seg  89  curve=-4                          #0:$81@-18 #3:$8A@+52
        fcb   $7C,$00,$00,$08,$00,$00,$1C,$00  ; seg  90  curve=-4                          #2:$8B@+28
        fcb   $7C,$00,$00,$50,$00,$00,$00,$2C  ; seg  91  curve=-4                          #3:$8A@+44
        fcb   $00,$00,$07,$00,$14,$00,$00,$00  ; seg  92                                    #0:$94@+20
        fcb   $00,$00,$07,$05,$14,$00,$28,$00  ; seg  93                                    #0:$94@+20 #2:$8A@+40
        fcb   $00,$00,$07,$60,$14,$00,$00,$34  ; seg  94                                    #0:$94@+20 #3:$89@+52
        fcb   $00,$00,$07,$80,$14,$00,$00,$2C  ; seg  95                                    #0:$94@+20 #3:$8B@+44
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  96
        fcb   $00,$00,$00,$50,$00,$00,$00,$30  ; seg  97                                    #3:$8A@+48
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  98                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  99                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$28  ; seg 100  curve=-4                          #0:$81@-18 #3:$89@+40
        fcb   $7C,$00,$54,$00,$EE,$14,$00,$00  ; seg 101  curve=-4                          #0:$81@-18 #1:$8A@+20
        fcb   $7C,$00,$04,$05,$EE,$00,$18,$00  ; seg 102  curve=-4                          #0:$81@-18 #2:$8A@+24
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 103  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 104  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$54,$00,$EE,$20,$00,$00  ; seg 105  curve=-4                          #0:$81@-18 #1:$8A@+32
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 106  curve=-4
        fcb   $7C,$00,$00,$08,$00,$00,$1C,$00  ; seg 107  curve=-4                          #2:$8B@+28
        fcb   $00,$00,$00,$50,$00,$00,$00,$30  ; seg 108                                    #3:$8A@+48
        fcb   $00,$00,$00,$80,$00,$00,$00,$3C  ; seg 109                                    #3:$8B@+60
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 110                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 111                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$05,$EE,$00,$20,$00  ; seg 112  curve=-4                          #0:$81@-18 #2:$8A@+32
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$30  ; seg 113  curve=-4                          #0:$81@-18 #3:$89@+48
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 114  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 115  curve=-4
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 116
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 117
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 118
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 119
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 120
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 121
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 122                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 123
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 124
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 125
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 126                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 127                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 128                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 129                                    #0:$83@+18 #2:$83@+18

Circuit_00_training_segment_cache
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
        fcb   $FB,$00,$F6,$0A  ; seg  25  yaw=  -5 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F6,$00,$F6,$0A  ; seg  26  yaw= -10 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F1,$00,$F6,$0A  ; seg  27  yaw= -15 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  28  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E7,$00,$F6,$0A  ; seg  29  yaw= -25 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  30  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DD,$00,$F6,$0A  ; seg  31  yaw= -35 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  32  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  33  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  34  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  35  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  36  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  37  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  38  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  39  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  40  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  41  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  42  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  43  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  44  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  45  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  46  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  47  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  48  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D2,$00,$F6,$0A  ; seg  49  yaw= -46 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  50  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C6,$00,$F6,$0A  ; seg  51  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  52  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg  53  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  54  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$0A  ; seg  55  yaw= -82 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  56  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  57  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  58  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  59  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  60  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  61  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  62  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  63  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  64  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AD,$00,$F6,$0A  ; seg  65  yaw= -83 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B2,$00,$F6,$0A  ; seg  66  yaw= -78 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B7,$00,$F6,$0A  ; seg  67  yaw= -73 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  68  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C1,$00,$F6,$0A  ; seg  69  yaw= -63 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C6,$00,$F6,$0A  ; seg  70  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CB,$00,$F6,$0A  ; seg  71  yaw= -53 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  72  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  73  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  74  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  75  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  76  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  77  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  78  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  79  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  80  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  81  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  82  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  83  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  84  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  85  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  86  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  87  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  88  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  89  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  90  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  91  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  92  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  93  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  94  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  95  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  96  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  97  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  98  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  99  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 100  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg 101  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 102  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 103  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 104  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg 105  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 106  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 107  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 108  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 109  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 110  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 111  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 112  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 113  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 114  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg 115  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 116  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 117  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 118  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 119  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 120  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 121  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 122 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 123 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 124 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 125 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 126 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 127 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 128 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 129 (wraparound de seg 7)
