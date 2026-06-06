* ======================================================================
* Circuit_12_medium_5 — N=180 segments (format compact 8 oct/seg)
* Source       : 12_medium_5.bin (extrait de FILE30)
*
* Pays         : GERMANY
* Lieu         : bitburg, rhineland
* Description  : lanes closed
* Hazards      : random barriers and water
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#00006C 01:#9090B4 02:#6C6C90 03:#48486C 04:#484848 05:#B40000 06:#242424 07:#242424
*   08:#48486C 09:#D8D8D8 10:#242424 11:#FCFCFC 12:#FC00FC 13:#FC00FC 14:#FC24FC 15:#FC24FC
*   16:#FC48FC 17:#FC48FC 18:#FC6CFC 19:#FC6CFC 20:#FC90FC 21:#FC90FC 22:#FCB4FC 23:#FCB4FC
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
* Taille totale : 2274 oct (nb_segments 2 + LUT 16 + segments 1504 + cache 752).
* ======================================================================

Circuit_12_medium_5_nb_segments
        fdb   180

Circuit_12_medium_5_sprite_lut
        fcb   $00,$82,$83,$A3,$98,$80,$81,$A0,$9F,$A1,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_12_medium_5_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$30,$00,$00,$00,$02  ; seg   8                      flags=[PIT]   #3:$A3@+2
        fcb   $80,$00,$00,$30,$00,$00,$00,$E0  ; seg   9                      flags=[PIT]   #3:$A3@-32
        fcb   $80,$00,$00,$30,$00,$00,$00,$DC  ; seg  10                      flags=[PIT]   #3:$A3@-36
        fcb   $80,$00,$00,$30,$00,$00,$00,$C8  ; seg  11                      flags=[PIT]   #3:$A3@-56
        fcb   $80,$00,$00,$30,$00,$00,$00,$D4  ; seg  12                      flags=[PIT]   #3:$A3@-44
        fcb   $80,$00,$00,$30,$00,$00,$00,$24  ; seg  13                      flags=[PIT]   #3:$A3@+36
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  14                      flags=[PIT]
        fcb   $80,$00,$00,$30,$00,$00,$00,$F8  ; seg  15                      flags=[PIT]   #3:$A3@-8
        fcb   $00,$00,$04,$30,$EE,$00,$00,$30  ; seg  16                                    #0:$98@-18 #3:$A3@+48
        fcb   $00,$00,$04,$30,$EE,$00,$00,$28  ; seg  17                                    #0:$98@-18 #3:$A3@+40
        fcb   $00,$00,$04,$00,$EE,$00,$00,$00  ; seg  18                                    #0:$98@-18
        fcb   $00,$00,$04,$30,$EE,$00,$00,$1C  ; seg  19                                    #0:$98@-18 #3:$A3@+28
        fcb   $00,$01,$04,$00,$12,$00,$00,$00  ; seg  20            pitch=+1                #0:$98@+18
        fcb   $00,$01,$04,$00,$12,$00,$00,$00  ; seg  21            pitch=+1                #0:$98@+18
        fcb   $00,$01,$04,$00,$12,$00,$00,$00  ; seg  22            pitch=+1                #0:$98@+18
        fcb   $00,$01,$04,$00,$12,$00,$00,$00  ; seg  23            pitch=+1                #0:$98@+18
        fcb   $00,$7F,$04,$00,$EE,$00,$00,$00  ; seg  24            pitch=-1                #0:$98@-18
        fcb   $00,$7F,$04,$30,$EE,$00,$00,$24  ; seg  25            pitch=-1                #0:$98@-18 #3:$A3@+36
        fcb   $00,$7F,$04,$00,$EE,$00,$00,$00  ; seg  26            pitch=-1                #0:$98@-18
        fcb   $00,$7F,$04,$30,$EE,$00,$00,$08  ; seg  27            pitch=-1                #0:$98@-18 #3:$A3@+8
        fcb   $00,$03,$04,$00,$EE,$00,$00,$00  ; seg  28            pitch=+3                #0:$98@-18
        fcb   $00,$03,$04,$00,$EE,$00,$00,$00  ; seg  29            pitch=+3                #0:$98@-18
        fcb   $00,$03,$04,$00,$EE,$00,$00,$00  ; seg  30            pitch=+3                #0:$98@-18
        fcb   $00,$03,$04,$00,$EE,$00,$00,$00  ; seg  31            pitch=+3                #0:$98@-18
        fcb   $00,$7D,$04,$00,$EE,$00,$00,$00  ; seg  32            pitch=-3                #0:$98@-18
        fcb   $00,$7D,$04,$00,$EE,$00,$00,$00  ; seg  33            pitch=-3                #0:$98@-18
        fcb   $00,$7D,$04,$00,$EE,$00,$00,$00  ; seg  34            pitch=-3                #0:$98@-18
        fcb   $00,$7D,$04,$00,$EE,$00,$00,$00  ; seg  35            pitch=-3                #0:$98@-18
        fcb   $00,$00,$00,$30,$00,$00,$00,$20  ; seg  36                                    #3:$A3@+32
        fcb   $00,$00,$00,$30,$00,$00,$00,$1C  ; seg  37                                    #3:$A3@+28
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  38                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$35,$12,$00,$12,$E0  ; seg  39                                    #0:$80@+18 #2:$80@+18 #3:$A3@-32
        fcb   $04,$00,$35,$30,$12,$0C,$00,$0C  ; seg  40  curve=+4                          #0:$80@+18 #1:$A3@+12 #3:$A3@+12
        fcb   $04,$00,$35,$30,$12,$0A,$00,$0E  ; seg  41  curve=+4                          #0:$80@+18 #1:$A3@+10 #3:$A3@+14
        fcb   $04,$00,$05,$30,$12,$00,$00,$04  ; seg  42  curve=+4                          #0:$80@+18 #3:$A3@+4
        fcb   $04,$00,$35,$30,$12,$0E,$00,$06  ; seg  43  curve=+4                          #0:$80@+18 #1:$A3@+14 #3:$A3@+6
        fcb   $04,$00,$35,$30,$12,$06,$00,$0E  ; seg  44  curve=+4                          #0:$80@+18 #1:$A3@+6 #3:$A3@+14
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg  45  curve=+4                          #0:$80@+18
        fcb   $04,$00,$30,$30,$00,$04,$00,$0A  ; seg  46  curve=+4                          #1:$A3@+4 #3:$A3@+10
        fcb   $04,$00,$00,$30,$00,$00,$00,$0C  ; seg  47  curve=+4                          #3:$A3@+12
        fcb   $00,$00,$00,$30,$00,$00,$00,$E0  ; seg  48                                    #3:$A3@-32
        fcb   $00,$00,$00,$30,$00,$00,$00,$24  ; seg  49                                    #3:$A3@+36
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  50                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$36,$EE,$00,$EE,$20  ; seg  51                                    #0:$81@-18 #2:$81@-18 #3:$A3@+32
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$28  ; seg  52  curve=-4                          #0:$81@-18 #3:$A3@+40
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  53  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$35,$12,$00,$12,$08  ; seg  54  curve=-4                          #0:$80@+18 #2:$80@+18 #3:$A3@+8
        fcb   $7C,$00,$05,$35,$12,$00,$12,$DC  ; seg  55  curve=-4                          #0:$80@+18 #2:$80@+18 #3:$A3@-36
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg  56  curve=+4                          #0:$80@+18
        fcb   $04,$00,$05,$30,$12,$00,$00,$E0  ; seg  57  curve=+4                          #0:$80@+18 #3:$A3@-32
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  58  curve=+4
        fcb   $04,$00,$00,$30,$00,$00,$00,$24  ; seg  59  curve=+4                          #3:$A3@+36
        fcb   $00,$7E,$04,$00,$12,$00,$00,$00  ; seg  60            pitch=-2                #0:$98@+18
        fcb   $00,$7E,$04,$00,$12,$00,$00,$00  ; seg  61            pitch=-2                #0:$98@+18
        fcb   $00,$02,$04,$00,$12,$00,$00,$00  ; seg  62            pitch=+2                #0:$98@+18
        fcb   $00,$02,$04,$00,$12,$00,$00,$00  ; seg  63            pitch=+2                #0:$98@+18
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg  64            pitch=+2
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg  65            pitch=+2
        fcb   $00,$7E,$55,$55,$12,$12,$12,$12  ; seg  66            pitch=-2                #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$7E,$55,$55,$12,$12,$12,$12  ; seg  67            pitch=-2                #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$05,$35,$12,$00,$12,$E0  ; seg  68  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$A3@-32
        fcb   $06,$00,$05,$35,$12,$00,$12,$0C  ; seg  69  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$A3@+12
        fcb   $06,$00,$05,$35,$12,$00,$12,$CC  ; seg  70  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$A3@-52
        fcb   $06,$00,$05,$35,$12,$00,$12,$30  ; seg  71  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$A3@+48
        fcb   $06,$00,$05,$05,$12,$00,$12,$00  ; seg  72  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$05,$05,$12,$00,$12,$00  ; seg  73  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$00,$30,$00,$00,$00,$20  ; seg  74  curve=+6                          #3:$A3@+32
        fcb   $06,$00,$00,$30,$00,$00,$00,$F8  ; seg  75  curve=+6                          #3:$A3@-8
        fcb   $00,$02,$04,$00,$EE,$00,$00,$00  ; seg  76            pitch=+2                #0:$98@-18
        fcb   $00,$02,$04,$00,$EE,$00,$00,$00  ; seg  77            pitch=+2                #0:$98@-18
        fcb   $00,$7E,$04,$00,$EE,$00,$00,$00  ; seg  78            pitch=-2                #0:$98@-18
        fcb   $00,$7E,$04,$00,$EE,$00,$00,$00  ; seg  79            pitch=-2                #0:$98@-18
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg  80            pitch=-2
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg  81            pitch=-2
        fcb   $00,$02,$06,$06,$EE,$00,$EE,$00  ; seg  82            pitch=+2                #0:$81@-18 #2:$81@-18
        fcb   $00,$02,$06,$06,$EE,$00,$EE,$00  ; seg  83            pitch=+2                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$36,$30,$EE,$FA,$00,$F8  ; seg  84  curve=-4                          #0:$81@-18 #1:$A3@-6 #3:$A3@-8
        fcb   $7C,$00,$36,$30,$EE,$F6,$00,$FC  ; seg  85  curve=-4                          #0:$81@-18 #1:$A3@-10 #3:$A3@-4
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$F4  ; seg  86  curve=-4                          #0:$81@-18 #3:$A3@-12
        fcb   $7C,$00,$36,$30,$EE,$F8,$00,$FE  ; seg  87  curve=-4                          #0:$81@-18 #1:$A3@-8 #3:$A3@-2
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$F6  ; seg  88  curve=-4                          #0:$81@-18 #3:$A3@-10
        fcb   $7C,$00,$36,$00,$EE,$FC,$00,$00  ; seg  89  curve=-4                          #0:$81@-18 #1:$A3@-4
        fcb   $7C,$00,$35,$35,$12,$F4,$12,$F8  ; seg  90  curve=-4                          #0:$80@+18 #1:$A3@-12 #2:$80@+18 #3:$A3@-8
        fcb   $7C,$00,$05,$35,$12,$00,$12,$F4  ; seg  91  curve=-4                          #0:$80@+18 #2:$80@+18 #3:$A3@-12
        fcb   $04,$00,$05,$30,$12,$00,$00,$00  ; seg  92  curve=+4                          #0:$80@+18 #3:$A3@+0
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg  93  curve=+4                          #0:$80@+18
        fcb   $04,$00,$06,$36,$EE,$00,$EE,$20  ; seg  94  curve=+4                          #0:$81@-18 #2:$81@-18 #3:$A3@+32
        fcb   $04,$00,$06,$06,$EE,$00,$EE,$00  ; seg  95  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$24  ; seg  96  curve=-4                          #0:$81@-18 #3:$A3@+36
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$20  ; seg  97  curve=-4                          #0:$81@-18 #3:$A3@+32
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  98  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$1C  ; seg  99  curve=-4                          #0:$81@-18 #3:$A3@+28
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$20  ; seg 100  curve=-4                          #0:$81@-18 #3:$A3@+32
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$14  ; seg 101  curve=-4                          #0:$81@-18 #3:$A3@+20
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 102  curve=-4
        fcb   $7C,$00,$00,$30,$00,$00,$00,$30  ; seg 103  curve=-4                          #3:$A3@+48
        fcb   $00,$00,$00,$30,$00,$00,$00,$E0  ; seg 104                                    #3:$A3@-32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 105
        fcb   $00,$00,$00,$30,$00,$00,$00,$DC  ; seg 106                                    #3:$A3@-36
        fcb   $00,$00,$00,$30,$00,$00,$00,$20  ; seg 107                                    #3:$A3@+32
        fcb   $04,$7E,$05,$00,$12,$00,$00,$00  ; seg 108  curve=+4  pitch=-2                #0:$80@+18
        fcb   $04,$7E,$05,$00,$12,$00,$00,$00  ; seg 109  curve=+4  pitch=-2                #0:$80@+18
        fcb   $04,$7E,$05,$00,$12,$00,$00,$00  ; seg 110  curve=+4  pitch=-2                #0:$80@+18
        fcb   $04,$7E,$05,$00,$12,$00,$00,$00  ; seg 111  curve=+4  pitch=-2                #0:$80@+18
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg 112  curve=+4                          #0:$80@+18
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg 113  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 114  curve=+4
        fcb   $04,$00,$00,$30,$00,$00,$00,$E0  ; seg 115  curve=+4                          #3:$A3@-32
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg 116                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg 117                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$00,$12,$00,$00,$00  ; seg 118                                    #0:$80@+18
        fcb   $00,$00,$05,$30,$12,$00,$00,$DC  ; seg 119                                    #0:$80@+18 #3:$A3@-36
        fcb   $04,$02,$05,$00,$12,$00,$00,$00  ; seg 120  curve=+4  pitch=+2                #0:$80@+18
        fcb   $04,$02,$05,$00,$12,$00,$00,$00  ; seg 121  curve=+4  pitch=+2                #0:$80@+18
        fcb   $04,$02,$00,$00,$00,$00,$00,$00  ; seg 122  curve=+4  pitch=+2
        fcb   $04,$02,$00,$00,$00,$00,$00,$00  ; seg 123  curve=+4  pitch=+2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 124
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 125
        fcb   $00,$00,$74,$70,$EE,$08,$00,$06  ; seg 126                                    #0:$98@-18 #1:$A0@+8 #3:$A0@+6
        fcb   $00,$00,$74,$70,$EE,$04,$00,$02  ; seg 127                                    #0:$98@-18 #1:$A0@+4 #3:$A0@+2
        fcb   $00,$7F,$84,$80,$EE,$08,$00,$02  ; seg 128            pitch=-1                #0:$98@-18 #1:$9F@+8 #3:$9F@+2
        fcb   $00,$7F,$84,$80,$EE,$08,$00,$02  ; seg 129            pitch=-1                #0:$98@-18 #1:$9F@+8 #3:$9F@+2
        fcb   $00,$7F,$84,$80,$EE,$08,$00,$02  ; seg 130            pitch=-1                #0:$98@-18 #1:$9F@+8 #3:$9F@+2
        fcb   $00,$7F,$84,$80,$EE,$08,$00,$02  ; seg 131            pitch=-1                #0:$98@-18 #1:$9F@+8 #3:$9F@+2
        fcb   $00,$00,$04,$00,$EE,$00,$00,$00  ; seg 132                                    #0:$98@-18
        fcb   $00,$00,$04,$00,$EE,$00,$00,$00  ; seg 133                                    #0:$98@-18
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 134
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 135
        fcb   $00,$02,$94,$90,$12,$F8,$00,$FA  ; seg 136            pitch=+2                #0:$98@+18 #1:$A1@-8 #3:$A1@-6
        fcb   $00,$02,$94,$90,$12,$FC,$00,$FE  ; seg 137            pitch=+2                #0:$98@+18 #1:$A1@-4 #3:$A1@-2
        fcb   $00,$02,$84,$80,$12,$F8,$00,$FE  ; seg 138            pitch=+2                #0:$98@+18 #1:$9F@-8 #3:$9F@-2
        fcb   $00,$02,$84,$80,$12,$F8,$00,$FE  ; seg 139            pitch=+2                #0:$98@+18 #1:$9F@-8 #3:$9F@-2
        fcb   $00,$7F,$84,$80,$12,$F8,$00,$FE  ; seg 140            pitch=-1                #0:$98@+18 #1:$9F@-8 #3:$9F@-2
        fcb   $00,$7F,$84,$80,$12,$F8,$00,$FE  ; seg 141            pitch=-1                #0:$98@+18 #1:$9F@-8 #3:$9F@-2
        fcb   $00,$7F,$04,$00,$12,$00,$00,$00  ; seg 142            pitch=-1                #0:$98@+18
        fcb   $00,$7F,$04,$00,$12,$00,$00,$00  ; seg 143            pitch=-1                #0:$98@+18
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 144
        fcb   $00,$00,$00,$30,$00,$00,$00,$20  ; seg 145                                    #3:$A3@+32
        fcb   $00,$00,$05,$35,$12,$00,$12,$1C  ; seg 146                                    #0:$80@+18 #2:$80@+18 #3:$A3@+28
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg 147                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$30,$12,$00,$00,$E0  ; seg 148  curve=+4                          #0:$80@+18 #3:$A3@-32
        fcb   $04,$00,$05,$30,$12,$00,$00,$D4  ; seg 149  curve=+4                          #0:$80@+18 #3:$A3@-44
        fcb   $04,$00,$06,$06,$EE,$00,$EE,$00  ; seg 150  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $04,$00,$06,$06,$EE,$00,$EE,$00  ; seg 151  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$20  ; seg 152  curve=-4                          #0:$81@-18 #3:$A3@+32
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$18  ; seg 153  curve=-4                          #0:$81@-18 #3:$A3@+24
        fcb   $7C,$00,$55,$55,$12,$12,$12,$12  ; seg 154  curve=-4                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7C,$00,$55,$55,$12,$12,$12,$12  ; seg 155  curve=-4                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$05,$05,$12,$00,$12,$00  ; seg 156  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$05,$35,$12,$00,$12,$30  ; seg 157  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$A3@+48
        fcb   $06,$00,$05,$05,$12,$00,$12,$00  ; seg 158  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$05,$35,$12,$00,$12,$E0  ; seg 159  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$A3@-32
        fcb   $06,$00,$05,$05,$12,$00,$12,$00  ; seg 160  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$05,$35,$12,$00,$12,$E0  ; seg 161  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$A3@-32
        fcb   $06,$00,$00,$30,$00,$00,$00,$C8  ; seg 162  curve=+6                          #3:$A3@-56
        fcb   $06,$00,$00,$00,$00,$00,$00,$00  ; seg 163  curve=+6
        fcb   $00,$7F,$04,$08,$EE,$00,$02,$00  ; seg 164            pitch=-1                #0:$98@-18 #2:$9F@+2
        fcb   $00,$7F,$04,$00,$EE,$00,$00,$00  ; seg 165            pitch=-1                #0:$98@-18
        fcb   $00,$7F,$04,$08,$EE,$00,$F8,$00  ; seg 166            pitch=-1                #0:$98@-18 #2:$9F@-8
        fcb   $00,$7F,$04,$00,$EE,$00,$00,$00  ; seg 167            pitch=-1                #0:$98@-18
        fcb   $00,$01,$04,$08,$EE,$00,$08,$00  ; seg 168            pitch=+1                #0:$98@-18 #2:$9F@+8
        fcb   $00,$01,$04,$00,$EE,$00,$00,$00  ; seg 169            pitch=+1                #0:$98@-18
        fcb   $00,$01,$04,$08,$EE,$00,$FE,$00  ; seg 170            pitch=+1                #0:$98@-18 #2:$9F@-2
        fcb   $00,$01,$04,$00,$EE,$00,$00,$00  ; seg 171            pitch=+1                #0:$98@-18
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 172
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 173
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 174
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 175
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 176
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 177
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 178
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 179
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 180                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 181
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 182
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 183
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 184                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 185                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 186                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 187                                    #0:$83@+18 #2:$83@+18

Circuit_12_medium_5_segment_cache
        fcb   $00,$00,$F6,$02  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $00,$00,$F6,$01  ; seg   1  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $00,$00,$F6,$00  ; seg   2  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $00,$00,$F6,$FF  ; seg   3  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $00,$00,$F6,$FE  ; seg   4  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $00,$00,$F6,$FD  ; seg   5  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $00,$00,$F7,$FC  ; seg   6  yaw=  +0 pitch=  +0 min_lat=  -9 max_lat=  -4
        fcb   $00,$00,$F8,$FB  ; seg   7  yaw=  +0 pitch=  +0 min_lat=  -8 max_lat=  -5
        fcb   $00,$00,$F9,$FA  ; seg   8  yaw=  +0 pitch=  +0 min_lat=  -7 max_lat=  -6
        fcb   $00,$00,$FA,$0A  ; seg   9  yaw=  +0 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $00,$00,$FB,$0A  ; seg  10  yaw=  +0 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $00,$00,$FC,$0A  ; seg  11  yaw=  +0 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $00,$00,$FD,$0A  ; seg  12  yaw=  +0 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $00,$00,$FE,$0A  ; seg  13  yaw=  +0 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $00,$00,$FF,$0A  ; seg  14  yaw=  +0 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $00,$00,$00,$0A  ; seg  15  yaw=  +0 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  16  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  17  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$09  ; seg  18  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $00,$00,$F6,$08  ; seg  19  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $00,$00,$F6,$07  ; seg  20  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $00,$01,$F6,$06  ; seg  21  yaw=  +0 pitch=  +1 min_lat= -10 max_lat=  +6
        fcb   $00,$02,$F6,$05  ; seg  22  yaw=  +0 pitch=  +2 min_lat= -10 max_lat=  +5
        fcb   $00,$03,$F6,$04  ; seg  23  yaw=  +0 pitch=  +3 min_lat= -10 max_lat=  +4
        fcb   $00,$04,$F6,$03  ; seg  24  yaw=  +0 pitch=  +4 min_lat= -10 max_lat=  +3
        fcb   $00,$03,$F6,$02  ; seg  25  yaw=  +0 pitch=  +3 min_lat= -10 max_lat=  +2
        fcb   $00,$02,$F6,$01  ; seg  26  yaw=  +0 pitch=  +2 min_lat= -10 max_lat=  +1
        fcb   $00,$01,$F6,$00  ; seg  27  yaw=  +0 pitch=  +1 min_lat= -10 max_lat=  +0
        fcb   $00,$00,$F6,$0A  ; seg  28  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$03,$F6,$09  ; seg  29  yaw=  +0 pitch=  +3 min_lat= -10 max_lat=  +9
        fcb   $00,$06,$F6,$08  ; seg  30  yaw=  +0 pitch=  +6 min_lat= -10 max_lat=  +8
        fcb   $00,$09,$F6,$07  ; seg  31  yaw=  +0 pitch=  +9 min_lat= -10 max_lat=  +7
        fcb   $00,$0C,$F6,$06  ; seg  32  yaw=  +0 pitch= +12 min_lat= -10 max_lat=  +6
        fcb   $00,$09,$F6,$05  ; seg  33  yaw=  +0 pitch=  +9 min_lat= -10 max_lat=  +5
        fcb   $00,$06,$F6,$04  ; seg  34  yaw=  +0 pitch=  +6 min_lat= -10 max_lat=  +4
        fcb   $00,$03,$F6,$03  ; seg  35  yaw=  +0 pitch=  +3 min_lat= -10 max_lat=  +3
        fcb   $00,$00,$F6,$02  ; seg  36  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $00,$00,$F6,$01  ; seg  37  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $00,$00,$F6,$00  ; seg  38  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $00,$00,$F6,$FF  ; seg  39  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $00,$00,$F6,$FE  ; seg  40  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $04,$00,$F6,$FD  ; seg  41  yaw=  +4 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $08,$00,$F6,$FC  ; seg  42  yaw=  +8 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $0C,$00,$F6,$FE  ; seg  43  yaw= +12 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $10,$00,$F6,$FE  ; seg  44  yaw= +16 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $14,$00,$F6,$FD  ; seg  45  yaw= +20 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $18,$00,$F6,$FC  ; seg  46  yaw= +24 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $1C,$00,$F6,$04  ; seg  47  yaw= +28 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $20,$00,$F6,$06  ; seg  48  yaw= +32 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $20,$00,$F6,$05  ; seg  49  yaw= +32 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $20,$00,$F6,$04  ; seg  50  yaw= +32 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $20,$00,$F6,$03  ; seg  51  yaw= +32 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $20,$00,$F6,$02  ; seg  52  yaw= +32 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $1C,$00,$F6,$01  ; seg  53  yaw= +28 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $18,$00,$F6,$00  ; seg  54  yaw= +24 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $14,$00,$F6,$0A  ; seg  55  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  56  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg  57  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $18,$00,$F6,$0A  ; seg  58  yaw= +24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1C,$00,$F6,$0A  ; seg  59  yaw= +28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  60  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$FE,$F6,$0A  ; seg  61  yaw= +32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $20,$FC,$F6,$0A  ; seg  62  yaw= +32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $20,$FE,$F6,$0A  ; seg  63  yaw= +32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$09  ; seg  64  yaw= +32 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $20,$02,$F6,$08  ; seg  65  yaw= +32 pitch=  +2 min_lat= -10 max_lat=  +8
        fcb   $20,$04,$F7,$07  ; seg  66  yaw= +32 pitch=  +4 min_lat=  -9 max_lat=  +7
        fcb   $20,$02,$F8,$06  ; seg  67  yaw= +32 pitch=  +2 min_lat=  -8 max_lat=  +6
        fcb   $20,$00,$F9,$05  ; seg  68  yaw= +32 pitch=  +0 min_lat=  -7 max_lat=  +5
        fcb   $26,$00,$FA,$04  ; seg  69  yaw= +38 pitch=  +0 min_lat=  -6 max_lat=  +4
        fcb   $2C,$00,$FB,$0A  ; seg  70  yaw= +44 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $32,$00,$FC,$0A  ; seg  71  yaw= +50 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $38,$00,$FD,$0A  ; seg  72  yaw= +56 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $3E,$00,$FE,$0A  ; seg  73  yaw= +62 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $44,$00,$FF,$0A  ; seg  74  yaw= +68 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $4A,$00,$00,$09  ; seg  75  yaw= +74 pitch=  +0 min_lat=  +0 max_lat=  +9
        fcb   $50,$00,$FB,$08  ; seg  76  yaw= +80 pitch=  +0 min_lat=  -5 max_lat=  +8
        fcb   $50,$02,$FC,$07  ; seg  77  yaw= +80 pitch=  +2 min_lat=  -4 max_lat=  +7
        fcb   $50,$04,$FD,$06  ; seg  78  yaw= +80 pitch=  +4 min_lat=  -3 max_lat=  +6
        fcb   $50,$02,$FE,$05  ; seg  79  yaw= +80 pitch=  +2 min_lat=  -2 max_lat=  +5
        fcb   $50,$00,$FF,$04  ; seg  80  yaw= +80 pitch=  +0 min_lat=  -1 max_lat=  +4
        fcb   $50,$FE,$00,$03  ; seg  81  yaw= +80 pitch=  -2 min_lat=  +0 max_lat=  +3
        fcb   $50,$FC,$01,$02  ; seg  82  yaw= +80 pitch=  -4 min_lat=  +1 max_lat=  +2
        fcb   $50,$FE,$02,$01  ; seg  83  yaw= +80 pitch=  -2 min_lat=  +2 max_lat=  +1
        fcb   $50,$00,$03,$00  ; seg  84  yaw= +80 pitch=  +0 min_lat=  +3 max_lat=  +0
        fcb   $4C,$00,$04,$FF  ; seg  85  yaw= +76 pitch=  +0 min_lat=  +4 max_lat=  -1
        fcb   $48,$00,$05,$FE  ; seg  86  yaw= +72 pitch=  +0 min_lat=  +5 max_lat=  -2
        fcb   $44,$00,$06,$FD  ; seg  87  yaw= +68 pitch=  +0 min_lat=  +6 max_lat=  -3
        fcb   $40,$00,$03,$FC  ; seg  88  yaw= +64 pitch=  +0 min_lat=  +3 max_lat=  -4
        fcb   $3C,$00,$04,$FB  ; seg  89  yaw= +60 pitch=  +0 min_lat=  +4 max_lat=  -5
        fcb   $38,$00,$00,$FA  ; seg  90  yaw= +56 pitch=  +0 min_lat=  +0 max_lat=  -6
        fcb   $34,$00,$FC,$F9  ; seg  91  yaw= +52 pitch=  +0 min_lat=  -4 max_lat=  -7
        fcb   $30,$00,$F6,$F8  ; seg  92  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  -8
        fcb   $34,$00,$F6,$0A  ; seg  93  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  94  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  95  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  96  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  97  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  98  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  99  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg 100  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$00,$F6,$0A  ; seg 101  yaw= +44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg 102  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $24,$00,$F6,$0A  ; seg 103  yaw= +36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 104  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 105  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 106  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 107  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg 108  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $24,$FE,$F6,$0A  ; seg 109  yaw= +36 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $28,$FC,$F6,$0A  ; seg 110  yaw= +40 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $2C,$FA,$F6,$0A  ; seg 111  yaw= +44 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $30,$F8,$F6,$09  ; seg 112  yaw= +48 pitch=  -8 min_lat= -10 max_lat=  +9
        fcb   $34,$F8,$F6,$08  ; seg 113  yaw= +52 pitch=  -8 min_lat= -10 max_lat=  +8
        fcb   $38,$F8,$F6,$07  ; seg 114  yaw= +56 pitch=  -8 min_lat= -10 max_lat=  +7
        fcb   $3C,$F8,$F6,$06  ; seg 115  yaw= +60 pitch=  -8 min_lat= -10 max_lat=  +6
        fcb   $40,$F8,$F6,$05  ; seg 116  yaw= +64 pitch=  -8 min_lat= -10 max_lat=  +5
        fcb   $40,$F8,$F6,$04  ; seg 117  yaw= +64 pitch=  -8 min_lat= -10 max_lat=  +4
        fcb   $40,$F8,$F6,$03  ; seg 118  yaw= +64 pitch=  -8 min_lat= -10 max_lat=  +3
        fcb   $40,$F8,$F6,$02  ; seg 119  yaw= +64 pitch=  -8 min_lat= -10 max_lat=  +2
        fcb   $40,$F8,$F6,$01  ; seg 120  yaw= +64 pitch=  -8 min_lat= -10 max_lat=  +1
        fcb   $44,$FA,$F6,$00  ; seg 121  yaw= +68 pitch=  -6 min_lat= -10 max_lat=  +0
        fcb   $48,$FC,$F7,$FF  ; seg 122  yaw= +72 pitch=  -4 min_lat=  -9 max_lat=  -1
        fcb   $4C,$FE,$F8,$FE  ; seg 123  yaw= +76 pitch=  -2 min_lat=  -8 max_lat=  -2
        fcb   $50,$00,$F9,$FD  ; seg 124  yaw= +80 pitch=  +0 min_lat=  -7 max_lat=  -3
        fcb   $50,$00,$FA,$FC  ; seg 125  yaw= +80 pitch=  +0 min_lat=  -6 max_lat=  -4
        fcb   $50,$00,$FB,$FB  ; seg 126  yaw= +80 pitch=  +0 min_lat=  -5 max_lat=  -5
        fcb   $50,$00,$FC,$FA  ; seg 127  yaw= +80 pitch=  +0 min_lat=  -4 max_lat=  -6
        fcb   $50,$00,$FD,$FA  ; seg 128  yaw= +80 pitch=  +0 min_lat=  -3 max_lat=  -6
        fcb   $50,$FF,$FE,$FA  ; seg 129  yaw= +80 pitch=  -1 min_lat=  -2 max_lat=  -6
        fcb   $50,$FE,$FF,$FA  ; seg 130  yaw= +80 pitch=  -2 min_lat=  -1 max_lat=  -6
        fcb   $50,$FD,$00,$FA  ; seg 131  yaw= +80 pitch=  -3 min_lat=  +0 max_lat=  -6
        fcb   $50,$FC,$01,$0A  ; seg 132  yaw= +80 pitch=  -4 min_lat=  +1 max_lat= +10
        fcb   $50,$FC,$02,$0A  ; seg 133  yaw= +80 pitch=  -4 min_lat=  +2 max_lat= +10
        fcb   $50,$FC,$03,$0A  ; seg 134  yaw= +80 pitch=  -4 min_lat=  +3 max_lat= +10
        fcb   $50,$FC,$04,$0A  ; seg 135  yaw= +80 pitch=  -4 min_lat=  +4 max_lat= +10
        fcb   $50,$FC,$05,$0A  ; seg 136  yaw= +80 pitch=  -4 min_lat=  +5 max_lat= +10
        fcb   $50,$FE,$06,$0A  ; seg 137  yaw= +80 pitch=  -2 min_lat=  +6 max_lat= +10
        fcb   $50,$00,$06,$0A  ; seg 138  yaw= +80 pitch=  +0 min_lat=  +6 max_lat= +10
        fcb   $50,$02,$06,$0A  ; seg 139  yaw= +80 pitch=  +2 min_lat=  +6 max_lat= +10
        fcb   $50,$04,$06,$0A  ; seg 140  yaw= +80 pitch=  +4 min_lat=  +6 max_lat= +10
        fcb   $50,$03,$06,$0A  ; seg 141  yaw= +80 pitch=  +3 min_lat=  +6 max_lat= +10
        fcb   $50,$02,$F6,$0A  ; seg 142  yaw= +80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $50,$01,$F6,$0A  ; seg 143  yaw= +80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 144  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 145  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 146  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 147  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 148  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $54,$00,$F6,$09  ; seg 149  yaw= +84 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $58,$00,$F6,$08  ; seg 150  yaw= +88 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $5C,$00,$F6,$07  ; seg 151  yaw= +92 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $60,$00,$F6,$06  ; seg 152  yaw= +96 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $5C,$00,$F6,$05  ; seg 153  yaw= +92 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $58,$00,$F6,$04  ; seg 154  yaw= +88 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $54,$00,$F7,$03  ; seg 155  yaw= +84 pitch=  +0 min_lat=  -9 max_lat=  +3
        fcb   $50,$00,$F8,$02  ; seg 156  yaw= +80 pitch=  +0 min_lat=  -8 max_lat=  +2
        fcb   $56,$00,$F9,$01  ; seg 157  yaw= +86 pitch=  +0 min_lat=  -7 max_lat=  +1
        fcb   $5C,$00,$FA,$00  ; seg 158  yaw= +92 pitch=  +0 min_lat=  -6 max_lat=  +0
        fcb   $62,$00,$FB,$FF  ; seg 159  yaw= +98 pitch=  +0 min_lat=  -5 max_lat=  -1
        fcb   $68,$00,$FC,$FE  ; seg 160  yaw=+104 pitch=  +0 min_lat=  -4 max_lat=  -2
        fcb   $6E,$00,$FD,$FD  ; seg 161  yaw=+110 pitch=  +0 min_lat=  -3 max_lat=  -3
        fcb   $74,$00,$FE,$FC  ; seg 162  yaw=+116 pitch=  +0 min_lat=  -2 max_lat=  -4
        fcb   $7A,$00,$FF,$FB  ; seg 163  yaw=+122 pitch=  +0 min_lat=  -1 max_lat=  -5
        fcb   $80,$00,$00,$FA  ; seg 164  yaw=-128 pitch=  +0 min_lat=  +0 max_lat=  -6
        fcb   $80,$FF,$01,$03  ; seg 165  yaw=-128 pitch=  -1 min_lat=  +1 max_lat=  +3
        fcb   $80,$FE,$02,$02  ; seg 166  yaw=-128 pitch=  -2 min_lat=  +2 max_lat=  +2
        fcb   $80,$FD,$03,$01  ; seg 167  yaw=-128 pitch=  -3 min_lat=  +3 max_lat=  +1
        fcb   $80,$FC,$04,$00  ; seg 168  yaw=-128 pitch=  -4 min_lat=  +4 max_lat=  +0
        fcb   $80,$FD,$05,$0A  ; seg 169  yaw=-128 pitch=  -3 min_lat=  +5 max_lat= +10
        fcb   $80,$FE,$06,$0A  ; seg 170  yaw=-128 pitch=  -2 min_lat=  +6 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 171  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 172  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 173  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 174  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 175  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 176  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 177  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 178  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 179  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$02  ; seg 180 (wraparound de seg 0)
        fcb   $00,$00,$F6,$01  ; seg 181 (wraparound de seg 1)
        fcb   $00,$00,$F6,$00  ; seg 182 (wraparound de seg 2)
        fcb   $00,$00,$F6,$FF  ; seg 183 (wraparound de seg 3)
        fcb   $00,$00,$F6,$FE  ; seg 184 (wraparound de seg 4)
        fcb   $00,$00,$F6,$FD  ; seg 185 (wraparound de seg 5)
        fcb   $00,$00,$F7,$FC  ; seg 186 (wraparound de seg 6)
        fcb   $00,$00,$F8,$FB  ; seg 187 (wraparound de seg 7)
