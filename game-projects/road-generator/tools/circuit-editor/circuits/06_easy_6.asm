* ======================================================================
* Circuit_06_easy_6 — N=120 segments (format compact 8 oct/seg)
* Source       : 06_easy_6.bin (extrait de FILE30)
*
* Pays         : CHINA
* Lieu         : nan chong
* Description  : many sharp bends
* Hazards      : water on road
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
* Taille totale : 1554 oct (nb_segments 2 + LUT 16 + segments 1024 + cache 512).
* ======================================================================

Circuit_06_easy_6_nb_segments
        fdb   120

Circuit_06_easy_6_sprite_lut
        fcb   $00,$82,$83,$80,$81,$96,$8C,$8B,$8A,$A3,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_06_easy_6_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $84,$00,$03,$00,$16,$00,$00,$00  ; seg   8  curve=+4            flags=[PIT]   #0:$80@+22
        fcb   $84,$00,$03,$00,$16,$00,$00,$00  ; seg   9  curve=+4            flags=[PIT]   #0:$80@+22
        fcb   $84,$00,$04,$04,$EE,$00,$EE,$00  ; seg  10  curve=+4            flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $84,$00,$04,$04,$EE,$00,$EE,$00  ; seg  11  curve=+4            flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $FC,$00,$04,$00,$EE,$00,$00,$00  ; seg  12  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$04,$00,$EE,$00,$00,$00  ; seg  13  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$00,$00,$00,$00,$00,$00  ; seg  14  curve=-4            flags=[PIT]
        fcb   $FC,$00,$00,$00,$00,$00,$00,$00  ; seg  15  curve=-4            flags=[PIT]
        fcb   $00,$00,$05,$60,$EC,$00,$00,$14  ; seg  16                                    #0:$96@-20 #3:$8C@+20
        fcb   $00,$00,$75,$00,$EC,$18,$00,$00  ; seg  17                                    #0:$96@-20 #1:$8B@+24
        fcb   $00,$7F,$05,$00,$EC,$00,$00,$00  ; seg  18            pitch=-1                #0:$96@-20
        fcb   $00,$7F,$05,$80,$EC,$00,$00,$EC  ; seg  19            pitch=-1                #0:$96@-20 #3:$8A@-20
        fcb   $00,$7F,$75,$70,$EC,$14,$00,$18  ; seg  20            pitch=-1                #0:$96@-20 #1:$8B@+20 #3:$8B@+24
        fcb   $00,$7F,$05,$08,$EC,$00,$14,$00  ; seg  21            pitch=-1                #0:$96@-20 #2:$8A@+20
        fcb   $00,$00,$33,$33,$12,$12,$12,$12  ; seg  22                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$33,$33,$12,$12,$12,$12  ; seg  23                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$03,$03,$12,$00,$12,$00  ; seg  24  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$03,$03,$12,$00,$12,$00  ; seg  25  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$93,$99,$12,$F0,$F6,$FE  ; seg  26  curve=+6                          #0:$80@+18 #1:$A3@-16 #2:$A3@-10 #3:$A3@-2
        fcb   $06,$00,$93,$99,$12,$FC,$FE,$F8  ; seg  27  curve=+6                          #0:$80@+18 #1:$A3@-4 #2:$A3@-2 #3:$A3@-8
        fcb   $06,$00,$93,$99,$12,$F0,$F2,$FE  ; seg  28  curve=+6                          #0:$80@+18 #1:$A3@-16 #2:$A3@-14 #3:$A3@-2
        fcb   $06,$00,$93,$99,$12,$FC,$F6,$FA  ; seg  29  curve=+6                          #0:$80@+18 #1:$A3@-4 #2:$A3@-10 #3:$A3@-6
        fcb   $06,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  30  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $06,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  31  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$84,$EE,$00,$EE,$20  ; seg  32  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8A@+32
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  33  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$33,$33,$12,$12,$12,$12  ; seg  34  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$33,$33,$12,$12,$12,$12  ; seg  35  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$83,$03,$12,$EC,$12,$00  ; seg  36  curve=+6                          #0:$80@+18 #1:$8A@-20 #2:$80@+18
        fcb   $06,$00,$73,$03,$12,$18,$12,$00  ; seg  37  curve=+6                          #0:$80@+18 #1:$8B@+24 #2:$80@+18
        fcb   $06,$00,$05,$70,$EE,$00,$00,$30  ; seg  38  curve=+6                          #0:$96@-18 #3:$8B@+48
        fcb   $06,$00,$05,$60,$EE,$00,$00,$E4  ; seg  39  curve=+6                          #0:$96@-18 #3:$8C@-28
        fcb   $00,$01,$05,$80,$EE,$00,$00,$18  ; seg  40            pitch=+1                #0:$96@-18 #3:$8A@+24
        fcb   $00,$01,$05,$00,$EE,$00,$00,$00  ; seg  41            pitch=+1                #0:$96@-18
        fcb   $00,$01,$73,$83,$12,$18,$12,$DC  ; seg  42            pitch=+1                #0:$80@+18 #1:$8B@+24 #2:$80@+18 #3:$8A@-36
        fcb   $00,$01,$03,$73,$12,$00,$12,$14  ; seg  43            pitch=+1                #0:$80@+18 #2:$80@+18 #3:$8B@+20
        fcb   $04,$00,$03,$87,$12,$00,$E8,$CC  ; seg  44  curve=+4                          #0:$80@+18 #2:$8B@-24 #3:$8A@-52
        fcb   $04,$00,$03,$00,$12,$00,$00,$00  ; seg  45  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$08,$18,$00,$14,$00  ; seg  46  curve=+4                          #0:$8B@+24 #2:$8A@+20
        fcb   $04,$00,$07,$07,$18,$00,$D0,$00  ; seg  47  curve=+4                          #0:$8B@+24 #2:$8B@-48
        fcb   $00,$01,$70,$70,$00,$18,$00,$18  ; seg  48            pitch=+1                #1:$8B@+24 #3:$8B@+24
        fcb   $00,$01,$80,$00,$00,$EC,$00,$00  ; seg  49            pitch=+1                #1:$8A@-20
        fcb   $00,$01,$95,$99,$EC,$04,$0C,$02  ; seg  50            pitch=+1                #0:$96@-20 #1:$A3@+4 #2:$A3@+12 #3:$A3@+2
        fcb   $00,$01,$95,$99,$EC,$0A,$06,$0C  ; seg  51            pitch=+1                #0:$96@-20 #1:$A3@+10 #2:$A3@+6 #3:$A3@+12
        fcb   $00,$00,$95,$99,$EC,$02,$0E,$06  ; seg  52                                    #0:$96@-20 #1:$A3@+2 #2:$A3@+14 #3:$A3@+6
        fcb   $00,$00,$95,$99,$EC,$04,$0A,$02  ; seg  53                                    #0:$96@-20 #1:$A3@+4 #2:$A3@+10 #3:$A3@+2
        fcb   $00,$00,$03,$73,$12,$00,$12,$1C  ; seg  54                                    #0:$80@+18 #2:$80@+18 #3:$8B@+28
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg  55                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$83,$00,$12,$EC,$00,$00  ; seg  56  curve=+4                          #0:$80@+18 #1:$8A@-20
        fcb   $04,$00,$03,$08,$12,$00,$24,$00  ; seg  57  curve=+4                          #0:$80@+18 #2:$8A@+36
        fcb   $04,$00,$04,$74,$EE,$00,$EE,$18  ; seg  58  curve=+4                          #0:$81@-18 #2:$81@-18 #3:$8B@+24
        fcb   $04,$00,$04,$04,$EE,$00,$EE,$00  ; seg  59  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$7F,$04,$00,$EE,$00,$00,$00  ; seg  60  curve=-4  pitch=-1                #0:$81@-18
        fcb   $7C,$7F,$04,$08,$EE,$00,$EC,$00  ; seg  61  curve=-4  pitch=-1                #0:$81@-18 #2:$8A@-20
        fcb   $7C,$7F,$60,$70,$00,$30,$00,$18  ; seg  62  curve=-4  pitch=-1                #1:$8C@+48 #3:$8B@+24
        fcb   $7C,$7F,$07,$00,$24,$00,$00,$00  ; seg  63  curve=-4  pitch=-1                #0:$8B@+36
        fcb   $00,$00,$75,$08,$EE,$D8,$20,$00  ; seg  64                                    #0:$96@-18 #1:$8B@-40 #2:$8A@+32
        fcb   $00,$00,$05,$07,$EE,$00,$10,$00  ; seg  65                                    #0:$96@-18 #2:$8B@+16
        fcb   $00,$7F,$05,$70,$EE,$00,$00,$18  ; seg  66            pitch=-1                #0:$96@-18 #3:$8B@+24
        fcb   $00,$7F,$05,$08,$EE,$00,$30,$00  ; seg  67            pitch=-1                #0:$96@-18 #2:$8A@+48
        fcb   $00,$00,$06,$70,$24,$00,$00,$18  ; seg  68                                    #0:$8C@+36 #3:$8B@+24
        fcb   $00,$00,$00,$08,$00,$00,$14,$00  ; seg  69                                    #2:$8A@+20
        fcb   $00,$7F,$03,$73,$12,$00,$12,$18  ; seg  70            pitch=-1                #0:$80@+18 #2:$80@+18 #3:$8B@+24
        fcb   $00,$7F,$03,$03,$12,$00,$12,$00  ; seg  71            pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$03,$08,$12,$00,$24,$00  ; seg  72  curve=+4                          #0:$80@+18 #2:$8A@+36
        fcb   $04,$00,$03,$06,$12,$00,$D8,$00  ; seg  73  curve=+4                          #0:$80@+18 #2:$8C@-40
        fcb   $04,$01,$03,$70,$12,$00,$00,$30  ; seg  74  curve=+4  pitch=+1                #0:$80@+18 #3:$8B@+48
        fcb   $04,$01,$73,$00,$12,$18,$00,$00  ; seg  75  curve=+4  pitch=+1                #0:$80@+18 #1:$8B@+24
        fcb   $04,$00,$03,$00,$12,$00,$00,$00  ; seg  76  curve=+4                          #0:$80@+18
        fcb   $04,$00,$83,$00,$12,$1C,$00,$00  ; seg  77  curve=+4                          #0:$80@+18 #1:$8A@+28
        fcb   $04,$01,$44,$44,$EE,$EE,$EE,$EE  ; seg  78  curve=+4  pitch=+1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $04,$01,$44,$44,$EE,$EE,$EE,$EE  ; seg  79  curve=+4  pitch=+1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  80  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$64,$04,$EE,$EC,$EE,$00  ; seg  81  curve=-6                          #0:$81@-18 #1:$8C@-20 #2:$81@-18
        fcb   $7A,$00,$04,$74,$EE,$00,$EE,$14  ; seg  82  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8B@+20
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  83  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$84,$EE,$00,$EE,$28  ; seg  84  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8A@+40
        fcb   $7A,$00,$74,$04,$EE,$E8,$EE,$00  ; seg  85  curve=-6                          #0:$81@-18 #1:$8B@-24 #2:$81@-18
        fcb   $7A,$00,$03,$03,$12,$00,$12,$00  ; seg  86  curve=-6                          #0:$80@+18 #2:$80@+18
        fcb   $7A,$00,$03,$63,$12,$00,$12,$24  ; seg  87  curve=-6                          #0:$80@+18 #2:$80@+18 #3:$8C@+36
        fcb   $04,$00,$93,$95,$12,$F8,$EC,$FC  ; seg  88  curve=+4                          #0:$80@+18 #1:$A3@-8 #2:$96@-20 #3:$A3@-4
        fcb   $04,$00,$93,$05,$12,$F4,$EC,$00  ; seg  89  curve=+4                          #0:$80@+18 #1:$A3@-12 #2:$96@-20
        fcb   $04,$00,$93,$90,$12,$F6,$00,$F8  ; seg  90  curve=+4                          #0:$80@+18 #1:$A3@-10 #3:$A3@-8
        fcb   $04,$00,$03,$05,$12,$00,$EC,$00  ; seg  91  curve=+4                          #0:$80@+18 #2:$96@-20
        fcb   $04,$00,$83,$95,$12,$EC,$EC,$FE  ; seg  92  curve=+4                          #0:$80@+18 #1:$8A@-20 #2:$96@-20 #3:$A3@-2
        fcb   $04,$00,$03,$90,$12,$00,$00,$FC  ; seg  93  curve=+4                          #0:$80@+18 #3:$A3@-4
        fcb   $04,$02,$93,$00,$12,$F4,$00,$00  ; seg  94  curve=+4  pitch=+2                #0:$80@+18 #1:$A3@-12
        fcb   $04,$02,$73,$75,$12,$D8,$EC,$E8  ; seg  95  curve=+4  pitch=+2                #0:$80@+18 #1:$8B@-40 #2:$96@-20 #3:$8B@-24
        fcb   $04,$02,$93,$05,$12,$F8,$EC,$00  ; seg  96  curve=+4  pitch=+2                #0:$80@+18 #1:$A3@-8 #2:$96@-20
        fcb   $04,$02,$93,$75,$12,$FC,$EC,$18  ; seg  97  curve=+4  pitch=+2                #0:$80@+18 #1:$A3@-4 #2:$96@-20 #3:$8B@+24
        fcb   $04,$00,$83,$00,$12,$CC,$00,$00  ; seg  98  curve=+4                          #0:$80@+18 #1:$8A@-52
        fcb   $04,$00,$93,$05,$12,$F2,$EC,$00  ; seg  99  curve=+4                          #0:$80@+18 #1:$A3@-14 #2:$96@-20
        fcb   $04,$02,$73,$90,$12,$E8,$00,$F8  ; seg 100  curve=+4  pitch=+2                #0:$80@+18 #1:$8B@-24 #3:$A3@-8
        fcb   $04,$02,$03,$00,$12,$00,$00,$00  ; seg 101  curve=+4  pitch=+2                #0:$80@+18
        fcb   $04,$00,$93,$08,$12,$FA,$D4,$00  ; seg 102  curve=+4                          #0:$80@+18 #1:$A3@-6 #2:$8A@-44
        fcb   $04,$00,$03,$98,$12,$00,$24,$F6  ; seg 103  curve=+4                          #0:$80@+18 #2:$8A@+36 #3:$A3@-10
        fcb   $04,$00,$03,$70,$12,$00,$00,$14  ; seg 104  curve=+4                          #0:$80@+18 #3:$8B@+20
        fcb   $04,$00,$73,$80,$12,$E8,$00,$EC  ; seg 105  curve=+4                          #0:$80@+18 #1:$8B@-24 #3:$8A@-20
        fcb   $04,$7E,$00,$07,$00,$00,$18,$00  ; seg 106  curve=+4  pitch=-2                #2:$8B@+24
        fcb   $04,$7E,$70,$00,$00,$E8,$00,$00  ; seg 107  curve=+4  pitch=-2                #1:$8B@-24
        fcb   $00,$7E,$05,$80,$14,$00,$00,$18  ; seg 108            pitch=-2                #0:$96@+20 #3:$8A@+24
        fcb   $00,$7E,$05,$06,$14,$00,$D8,$00  ; seg 109            pitch=-2                #0:$96@+20 #2:$8C@-40
        fcb   $00,$7E,$85,$70,$14,$EC,$00,$E8  ; seg 110            pitch=-2                #0:$96@+20 #1:$8A@-20 #3:$8B@-24
        fcb   $00,$7E,$05,$08,$14,$00,$D8,$00  ; seg 111            pitch=-2                #0:$96@+20 #2:$8A@-40
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 112
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 113
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 114
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 115
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 116
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 117
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 118
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 119
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 120                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 121
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 122
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 123
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 124                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 125                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 126                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 127                                    #0:$83@+18 #2:$83@+18

Circuit_06_easy_6_segment_cache
        fcb   $00,$00,$F6,$0A  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   1  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   2  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   3  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   4  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   5  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   6  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   7  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   8  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $04,$00,$F6,$0A  ; seg   9  yaw=  +4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  10  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$00,$F7,$0A  ; seg  11  yaw= +12 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $10,$00,$F8,$0A  ; seg  12  yaw= +16 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $0C,$00,$F9,$0A  ; seg  13  yaw= +12 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $08,$00,$FA,$0A  ; seg  14  yaw=  +8 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $04,$00,$FB,$0A  ; seg  15  yaw=  +4 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $00,$00,$FC,$0A  ; seg  16  yaw=  +0 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $00,$00,$FD,$0A  ; seg  17  yaw=  +0 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $00,$00,$FE,$0A  ; seg  18  yaw=  +0 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $00,$FF,$FF,$0A  ; seg  19  yaw=  +0 pitch=  -1 min_lat=  -1 max_lat= +10
        fcb   $00,$FE,$00,$0A  ; seg  20  yaw=  +0 pitch=  -2 min_lat=  +0 max_lat= +10
        fcb   $00,$FD,$01,$0A  ; seg  21  yaw=  +0 pitch=  -3 min_lat=  +1 max_lat= +10
        fcb   $00,$FC,$02,$0A  ; seg  22  yaw=  +0 pitch=  -4 min_lat=  +2 max_lat= +10
        fcb   $00,$FC,$03,$0A  ; seg  23  yaw=  +0 pitch=  -4 min_lat=  +3 max_lat= +10
        fcb   $00,$FC,$04,$0A  ; seg  24  yaw=  +0 pitch=  -4 min_lat=  +4 max_lat= +10
        fcb   $06,$FC,$05,$0A  ; seg  25  yaw=  +6 pitch=  -4 min_lat=  +5 max_lat= +10
        fcb   $0C,$FC,$06,$0A  ; seg  26  yaw= +12 pitch=  -4 min_lat=  +6 max_lat= +10
        fcb   $12,$FC,$06,$0A  ; seg  27  yaw= +18 pitch=  -4 min_lat=  +6 max_lat= +10
        fcb   $18,$FC,$06,$0A  ; seg  28  yaw= +24 pitch=  -4 min_lat=  +6 max_lat= +10
        fcb   $1E,$FC,$04,$0A  ; seg  29  yaw= +30 pitch=  -4 min_lat=  +4 max_lat= +10
        fcb   $24,$FC,$F6,$0A  ; seg  30  yaw= +36 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $2A,$FC,$F6,$0A  ; seg  31  yaw= +42 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $30,$FC,$F6,$0A  ; seg  32  yaw= +48 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $2A,$FC,$F6,$0A  ; seg  33  yaw= +42 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $24,$FC,$F6,$0A  ; seg  34  yaw= +36 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $1E,$FC,$F6,$09  ; seg  35  yaw= +30 pitch=  -4 min_lat= -10 max_lat=  +9
        fcb   $18,$FC,$F6,$08  ; seg  36  yaw= +24 pitch=  -4 min_lat= -10 max_lat=  +8
        fcb   $1E,$FC,$F6,$07  ; seg  37  yaw= +30 pitch=  -4 min_lat= -10 max_lat=  +7
        fcb   $24,$FC,$F6,$06  ; seg  38  yaw= +36 pitch=  -4 min_lat= -10 max_lat=  +6
        fcb   $2A,$FC,$F6,$05  ; seg  39  yaw= +42 pitch=  -4 min_lat= -10 max_lat=  +5
        fcb   $30,$FC,$F6,$04  ; seg  40  yaw= +48 pitch=  -4 min_lat= -10 max_lat=  +4
        fcb   $30,$FD,$F6,$03  ; seg  41  yaw= +48 pitch=  -3 min_lat= -10 max_lat=  +3
        fcb   $30,$FE,$F6,$02  ; seg  42  yaw= +48 pitch=  -2 min_lat= -10 max_lat=  +2
        fcb   $30,$FF,$F6,$01  ; seg  43  yaw= +48 pitch=  -1 min_lat= -10 max_lat=  +1
        fcb   $30,$00,$F6,$00  ; seg  44  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $34,$00,$F6,$FF  ; seg  45  yaw= +52 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $38,$00,$F6,$FE  ; seg  46  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $3C,$00,$F6,$FD  ; seg  47  yaw= +60 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $40,$00,$F6,$FC  ; seg  48  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $40,$01,$F6,$FB  ; seg  49  yaw= +64 pitch=  +1 min_lat= -10 max_lat=  -5
        fcb   $40,$02,$F6,$FA  ; seg  50  yaw= +64 pitch=  +2 min_lat= -10 max_lat=  -6
        fcb   $40,$03,$F6,$FB  ; seg  51  yaw= +64 pitch=  +3 min_lat= -10 max_lat=  -5
        fcb   $40,$04,$F6,$FA  ; seg  52  yaw= +64 pitch=  +4 min_lat= -10 max_lat=  -6
        fcb   $40,$04,$F6,$FA  ; seg  53  yaw= +64 pitch=  +4 min_lat= -10 max_lat=  -6
        fcb   $40,$04,$F6,$0A  ; seg  54  yaw= +64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $40,$04,$F6,$0A  ; seg  55  yaw= +64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $40,$04,$F6,$0A  ; seg  56  yaw= +64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $44,$04,$F6,$0A  ; seg  57  yaw= +68 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $48,$04,$F6,$0A  ; seg  58  yaw= +72 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $4C,$04,$F6,$0A  ; seg  59  yaw= +76 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $50,$04,$F6,$0A  ; seg  60  yaw= +80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $4C,$03,$F6,$0A  ; seg  61  yaw= +76 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $48,$02,$F6,$0A  ; seg  62  yaw= +72 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $44,$01,$F6,$0A  ; seg  63  yaw= +68 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$09  ; seg  64  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $40,$00,$F6,$08  ; seg  65  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $40,$00,$F6,$0A  ; seg  66  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$FF,$F6,$0A  ; seg  67  yaw= +64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $40,$FE,$F6,$0A  ; seg  68  yaw= +64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $40,$FE,$F6,$0A  ; seg  69  yaw= +64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $40,$FE,$F6,$0A  ; seg  70  yaw= +64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $40,$FD,$F6,$0A  ; seg  71  yaw= +64 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $40,$FC,$F6,$0A  ; seg  72  yaw= +64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $44,$FC,$F6,$0A  ; seg  73  yaw= +68 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $48,$FC,$F6,$0A  ; seg  74  yaw= +72 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $4C,$FD,$F7,$0A  ; seg  75  yaw= +76 pitch=  -3 min_lat=  -9 max_lat= +10
        fcb   $50,$FE,$F8,$0A  ; seg  76  yaw= +80 pitch=  -2 min_lat=  -8 max_lat= +10
        fcb   $54,$FE,$F9,$0A  ; seg  77  yaw= +84 pitch=  -2 min_lat=  -7 max_lat= +10
        fcb   $58,$FE,$FA,$0A  ; seg  78  yaw= +88 pitch=  -2 min_lat=  -6 max_lat= +10
        fcb   $5C,$FF,$FB,$0A  ; seg  79  yaw= +92 pitch=  -1 min_lat=  -5 max_lat= +10
        fcb   $60,$00,$FC,$0A  ; seg  80  yaw= +96 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $5A,$00,$FD,$0A  ; seg  81  yaw= +90 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $54,$00,$FE,$0A  ; seg  82  yaw= +84 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $4E,$00,$FF,$0A  ; seg  83  yaw= +78 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $48,$00,$00,$0A  ; seg  84  yaw= +72 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $42,$00,$01,$0A  ; seg  85  yaw= +66 pitch=  +0 min_lat=  +1 max_lat= +10
        fcb   $3C,$00,$02,$0A  ; seg  86  yaw= +60 pitch=  +0 min_lat=  +2 max_lat= +10
        fcb   $36,$00,$03,$0A  ; seg  87  yaw= +54 pitch=  +0 min_lat=  +3 max_lat= +10
        fcb   $30,$00,$04,$0A  ; seg  88  yaw= +48 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $34,$00,$03,$0A  ; seg  89  yaw= +52 pitch=  +0 min_lat=  +3 max_lat= +10
        fcb   $38,$00,$04,$0A  ; seg  90  yaw= +56 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $3C,$00,$05,$0A  ; seg  91  yaw= +60 pitch=  +0 min_lat=  +5 max_lat= +10
        fcb   $40,$00,$06,$0A  ; seg  92  yaw= +64 pitch=  +0 min_lat=  +6 max_lat= +10
        fcb   $44,$00,$04,$0A  ; seg  93  yaw= +68 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $48,$00,$01,$0A  ; seg  94  yaw= +72 pitch=  +0 min_lat=  +1 max_lat= +10
        fcb   $4C,$02,$02,$0A  ; seg  95  yaw= +76 pitch=  +2 min_lat=  +2 max_lat= +10
        fcb   $50,$04,$03,$0A  ; seg  96  yaw= +80 pitch=  +4 min_lat=  +3 max_lat= +10
        fcb   $54,$06,$04,$0A  ; seg  97  yaw= +84 pitch=  +6 min_lat=  +4 max_lat= +10
        fcb   $58,$08,$FE,$0A  ; seg  98  yaw= +88 pitch=  +8 min_lat=  -2 max_lat= +10
        fcb   $5C,$08,$FF,$0A  ; seg  99  yaw= +92 pitch=  +8 min_lat=  -1 max_lat= +10
        fcb   $60,$08,$00,$0A  ; seg 100  yaw= +96 pitch=  +8 min_lat=  +0 max_lat= +10
        fcb   $64,$0A,$01,$0A  ; seg 101  yaw=+100 pitch= +10 min_lat=  +1 max_lat= +10
        fcb   $68,$0C,$02,$0A  ; seg 102  yaw=+104 pitch= +12 min_lat=  +2 max_lat= +10
        fcb   $6C,$0C,$FE,$0A  ; seg 103  yaw=+108 pitch= +12 min_lat=  -2 max_lat= +10
        fcb   $70,$0C,$F6,$0A  ; seg 104  yaw=+112 pitch= +12 min_lat= -10 max_lat= +10
        fcb   $74,$0C,$F6,$0A  ; seg 105  yaw=+116 pitch= +12 min_lat= -10 max_lat= +10
        fcb   $78,$0C,$F6,$0A  ; seg 106  yaw=+120 pitch= +12 min_lat= -10 max_lat= +10
        fcb   $7C,$0A,$F6,$0A  ; seg 107  yaw=+124 pitch= +10 min_lat= -10 max_lat= +10
        fcb   $80,$08,$F6,$0A  ; seg 108  yaw=-128 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $80,$06,$F6,$0A  ; seg 109  yaw=-128 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $80,$04,$F6,$0A  ; seg 110  yaw=-128 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 111  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
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
