* ======================================================================
* Circuit_29_hard_12 — N=158 segments (format compact 8 oct/seg)
* Source       : 29_hard_12.bin (extrait de FILE30)
*
* Pays         : AUSTRALIA
* Lieu         : barrow creek
* Description  : desert sand track, no road
* Hazards      : markings and few signs
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000024 01:#B4906C 02:#906C48 03:#6C4824 04:#B4906C 05:#B4906C 06:#B46C6C 07:#B46C6C
*   08:#B49048 09:#B49048 10:#B46C48 11:#B46C48 12:#246CD8 13:#486CB4 14:#486CB4 15:#6C6C90
*   16:#6C6C90 17:#906C6C 18:#906C6C 19:#B46C48 20:#B46C48 21:#D86C24 22:#D86C24 23:#FC6C00
*   24:#FC6C00 25:#FC9000 26:#FC9000 27:#FCB400
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
* Taille totale : 2010 oct (nb_segments 2 + LUT 16 + segments 1328 + cache 664).
* ======================================================================

Circuit_29_hard_12_nb_segments
        fdb   158

Circuit_29_hard_12_sprite_lut
        fcb   $00,$82,$84,$9D,$9E,$A3,$80,$81,$00,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_29_hard_12_segments
        fcb   $7C,$80,$01,$00,$00,$00,$00,$00  ; seg   0  curve=-4            flags=[START] #0:$82@+0
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg   1  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg   2  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg   3  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg   4  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg   5  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg   6  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg   7  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$03,$04,$EC,$00,$12,$00  ; seg   8  curve=-4                          #0:$9D@-20 #2:$9E@+18
        fcb   $7C,$00,$03,$04,$EE,$00,$14,$00  ; seg   9  curve=-4                          #0:$9D@-18 #2:$9E@+20
        fcb   $7C,$00,$00,$53,$00,$00,$18,$D0  ; seg  10  curve=-4                          #2:$9D@+24 #3:$A3@-48
        fcb   $7C,$00,$03,$03,$EC,$00,$12,$00  ; seg  11  curve=-4                          #0:$9D@-20 #2:$9D@+18
        fcb   $7C,$00,$03,$04,$E8,$00,$16,$00  ; seg  12  curve=-4                          #0:$9D@-24 #2:$9E@+22
        fcb   $7C,$00,$03,$03,$EA,$00,$12,$00  ; seg  13  curve=-4                          #0:$9D@-22 #2:$9D@+18
        fcb   $7C,$00,$00,$56,$00,$00,$12,$20  ; seg  14  curve=-4                          #2:$80@+18 #3:$A3@+32
        fcb   $7C,$00,$04,$06,$EC,$00,$12,$00  ; seg  15  curve=-4                          #0:$9E@-20 #2:$80@+18
        fcb   $06,$00,$04,$03,$EC,$00,$18,$00  ; seg  16  curve=+6                          #0:$9E@-20 #2:$9D@+24
        fcb   $06,$00,$04,$03,$EE,$00,$12,$00  ; seg  17  curve=+6                          #0:$9E@-18 #2:$9D@+18
        fcb   $06,$00,$00,$53,$00,$00,$14,$30  ; seg  18  curve=+6                          #2:$9D@+20 #3:$A3@+48
        fcb   $06,$00,$04,$03,$EA,$00,$12,$00  ; seg  19  curve=+6                          #0:$9E@-22 #2:$9D@+18
        fcb   $06,$00,$04,$50,$EC,$00,$00,$E0  ; seg  20  curve=+6                          #0:$9E@-20 #3:$A3@-32
        fcb   $06,$00,$04,$03,$E8,$00,$18,$00  ; seg  21  curve=+6                          #0:$9E@-24 #2:$9D@+24
        fcb   $06,$00,$04,$03,$E8,$00,$16,$00  ; seg  22  curve=+6                          #0:$9E@-24 #2:$9D@+22
        fcb   $06,$00,$00,$53,$00,$00,$12,$D0  ; seg  23  curve=+6                          #2:$9D@+18 #3:$A3@-48
        fcb   $06,$00,$04,$03,$EC,$00,$14,$00  ; seg  24  curve=+6                          #0:$9E@-20 #2:$9D@+20
        fcb   $06,$00,$04,$50,$EA,$00,$00,$E0  ; seg  25  curve=+6                          #0:$9E@-22 #3:$A3@-32
        fcb   $06,$00,$04,$04,$EC,$00,$12,$00  ; seg  26  curve=+6                          #0:$9E@-20 #2:$9E@+18
        fcb   $06,$00,$03,$04,$E8,$00,$16,$00  ; seg  27  curve=+6                          #0:$9D@-24 #2:$9E@+22
        fcb   $06,$00,$00,$54,$00,$00,$18,$20  ; seg  28  curve=+6                          #2:$9E@+24 #3:$A3@+32
        fcb   $06,$00,$03,$04,$EC,$00,$12,$00  ; seg  29  curve=+6                          #0:$9D@-20 #2:$9E@+18
        fcb   $06,$00,$07,$03,$EE,$00,$18,$00  ; seg  30  curve=+6                          #0:$81@-18 #2:$9D@+24
        fcb   $06,$00,$07,$03,$EE,$00,$14,$00  ; seg  31  curve=+6                          #0:$81@-18 #2:$9D@+20
        fcb   $7A,$00,$04,$03,$E8,$00,$14,$00  ; seg  32  curve=-6                          #0:$9E@-24 #2:$9D@+20
        fcb   $7A,$00,$00,$53,$00,$00,$12,$D0  ; seg  33  curve=-6                          #2:$9D@+18 #3:$A3@-48
        fcb   $7A,$00,$04,$03,$EC,$00,$18,$00  ; seg  34  curve=-6                          #0:$9E@-20 #2:$9D@+24
        fcb   $7A,$00,$03,$50,$EA,$00,$00,$30  ; seg  35  curve=-6                          #0:$9D@-22 #3:$A3@+48
        fcb   $7A,$00,$04,$04,$EC,$00,$16,$00  ; seg  36  curve=-6                          #0:$9E@-20 #2:$9E@+22
        fcb   $7A,$00,$04,$04,$E8,$00,$12,$00  ; seg  37  curve=-6                          #0:$9E@-24 #2:$9E@+18
        fcb   $7A,$00,$00,$53,$00,$00,$16,$20  ; seg  38  curve=-6                          #2:$9D@+22 #3:$A3@+32
        fcb   $7A,$00,$04,$03,$EC,$00,$18,$00  ; seg  39  curve=-6                          #0:$9E@-20 #2:$9D@+24
        fcb   $00,$01,$04,$03,$EC,$00,$18,$00  ; seg  40            pitch=+1                #0:$9E@-20 #2:$9D@+24
        fcb   $00,$01,$03,$50,$EA,$00,$00,$E0  ; seg  41            pitch=+1                #0:$9D@-22 #3:$A3@-32
        fcb   $00,$7F,$03,$04,$EE,$00,$12,$00  ; seg  42            pitch=-1                #0:$9D@-18 #2:$9E@+18
        fcb   $00,$7F,$00,$53,$00,$00,$12,$D0  ; seg  43            pitch=-1                #2:$9D@+18 #3:$A3@-48
        fcb   $00,$00,$04,$03,$EC,$00,$18,$00  ; seg  44                                    #0:$9E@-20 #2:$9D@+24
        fcb   $00,$00,$03,$04,$EA,$00,$12,$00  ; seg  45                                    #0:$9D@-22 #2:$9E@+18
        fcb   $00,$00,$07,$04,$EE,$00,$16,$00  ; seg  46                                    #0:$81@-18 #2:$9E@+22
        fcb   $00,$00,$07,$03,$EE,$00,$12,$00  ; seg  47                                    #0:$81@-18 #2:$9D@+18
        fcb   $7C,$00,$04,$50,$EC,$00,$00,$20  ; seg  48  curve=-4                          #0:$9E@-20 #3:$A3@+32
        fcb   $7C,$00,$04,$03,$E8,$00,$12,$00  ; seg  49  curve=-4                          #0:$9E@-24 #2:$9D@+18
        fcb   $7C,$00,$00,$53,$00,$00,$12,$D0  ; seg  50  curve=-4                          #2:$9D@+18 #3:$A3@-48
        fcb   $7C,$00,$04,$03,$EC,$00,$14,$00  ; seg  51  curve=-4                          #0:$9E@-20 #2:$9D@+20
        fcb   $7C,$00,$04,$04,$EA,$00,$12,$00  ; seg  52  curve=-4                          #0:$9E@-22 #2:$9E@+18
        fcb   $7C,$00,$03,$04,$EE,$00,$18,$00  ; seg  53  curve=-4                          #0:$9D@-18 #2:$9E@+24
        fcb   $7C,$00,$03,$03,$E8,$00,$16,$00  ; seg  54  curve=-4                          #0:$9D@-24 #2:$9D@+22
        fcb   $7C,$00,$04,$04,$EC,$00,$12,$00  ; seg  55  curve=-4                          #0:$9E@-20 #2:$9E@+18
        fcb   $7C,$00,$03,$03,$EC,$00,$18,$00  ; seg  56  curve=-4                          #0:$9D@-20 #2:$9D@+24
        fcb   $7C,$00,$00,$53,$00,$00,$12,$D0  ; seg  57  curve=-4                          #2:$9D@+18 #3:$A3@-48
        fcb   $7C,$00,$04,$03,$E8,$00,$14,$00  ; seg  58  curve=-4                          #0:$9E@-24 #2:$9D@+20
        fcb   $7C,$00,$04,$03,$EE,$00,$14,$00  ; seg  59  curve=-4                          #0:$9E@-18 #2:$9D@+20
        fcb   $7C,$00,$00,$54,$00,$00,$12,$E0  ; seg  60  curve=-4                          #2:$9E@+18 #3:$A3@-32
        fcb   $7C,$00,$04,$03,$EA,$00,$18,$00  ; seg  61  curve=-4                          #0:$9E@-22 #2:$9D@+24
        fcb   $7C,$00,$03,$06,$EC,$00,$12,$00  ; seg  62  curve=-4                          #0:$9D@-20 #2:$80@+18
        fcb   $7C,$00,$04,$56,$E8,$00,$12,$20  ; seg  63  curve=-4                          #0:$9E@-24 #2:$80@+18 #3:$A3@+32
        fcb   $04,$00,$04,$03,$EC,$00,$12,$00  ; seg  64  curve=+4                          #0:$9E@-20 #2:$9D@+18
        fcb   $04,$00,$04,$03,$EA,$00,$14,$00  ; seg  65  curve=+4                          #0:$9E@-22 #2:$9D@+20
        fcb   $04,$00,$00,$53,$00,$00,$16,$30  ; seg  66  curve=+4                          #2:$9D@+22 #3:$A3@+48
        fcb   $04,$00,$03,$03,$EC,$00,$18,$00  ; seg  67  curve=+4                          #0:$9D@-20 #2:$9D@+24
        fcb   $04,$00,$04,$04,$EE,$00,$12,$00  ; seg  68  curve=+4                          #0:$9E@-18 #2:$9E@+18
        fcb   $04,$00,$03,$50,$EA,$00,$00,$D0  ; seg  69  curve=+4                          #0:$9D@-22 #3:$A3@-48
        fcb   $04,$00,$03,$04,$EC,$00,$18,$00  ; seg  70  curve=+4                          #0:$9D@-20 #2:$9E@+24
        fcb   $04,$00,$03,$04,$E8,$00,$12,$00  ; seg  71  curve=+4                          #0:$9D@-24 #2:$9E@+18
        fcb   $00,$7F,$03,$04,$EC,$00,$12,$00  ; seg  72            pitch=-1                #0:$9D@-20 #2:$9E@+18
        fcb   $00,$7F,$00,$53,$00,$00,$14,$E0  ; seg  73            pitch=-1                #2:$9D@+20 #3:$A3@-32
        fcb   $00,$01,$04,$04,$EC,$00,$12,$00  ; seg  74            pitch=+1                #0:$9E@-20 #2:$9E@+18
        fcb   $00,$01,$04,$04,$E8,$00,$14,$00  ; seg  75            pitch=+1                #0:$9E@-24 #2:$9E@+20
        fcb   $00,$00,$03,$50,$EE,$00,$00,$20  ; seg  76                                    #0:$9D@-18 #3:$A3@+32
        fcb   $00,$00,$04,$03,$EC,$00,$18,$00  ; seg  77                                    #0:$9E@-20 #2:$9D@+24
        fcb   $00,$00,$07,$03,$EE,$00,$12,$00  ; seg  78                                    #0:$81@-18 #2:$9D@+18
        fcb   $00,$00,$07,$04,$EE,$00,$16,$00  ; seg  79                                    #0:$81@-18 #2:$9E@+22
        fcb   $7A,$00,$03,$50,$EC,$00,$00,$30  ; seg  80  curve=-6                          #0:$9D@-20 #3:$A3@+48
        fcb   $7A,$00,$03,$04,$EA,$00,$18,$00  ; seg  81  curve=-6                          #0:$9D@-22 #2:$9E@+24
        fcb   $7A,$00,$00,$54,$00,$00,$12,$E0  ; seg  82  curve=-6                          #2:$9E@+18 #3:$A3@-32
        fcb   $7A,$00,$04,$03,$EC,$00,$12,$00  ; seg  83  curve=-6                          #0:$9E@-20 #2:$9D@+18
        fcb   $7A,$00,$03,$03,$E8,$00,$14,$00  ; seg  84  curve=-6                          #0:$9D@-24 #2:$9D@+20
        fcb   $7A,$00,$03,$04,$EE,$00,$16,$00  ; seg  85  curve=-6                          #0:$9D@-18 #2:$9E@+22
        fcb   $7A,$00,$04,$06,$EC,$00,$12,$00  ; seg  86  curve=-6                          #0:$9E@-20 #2:$80@+18
        fcb   $7A,$00,$03,$06,$EA,$00,$12,$00  ; seg  87  curve=-6                          #0:$9D@-22 #2:$80@+18
        fcb   $06,$00,$03,$04,$EC,$00,$18,$00  ; seg  88  curve=+6                          #0:$9D@-20 #2:$9E@+24
        fcb   $06,$00,$03,$50,$E8,$00,$00,$20  ; seg  89  curve=+6                          #0:$9D@-24 #3:$A3@+32
        fcb   $06,$00,$03,$03,$EE,$00,$12,$00  ; seg  90  curve=+6                          #0:$9D@-18 #2:$9D@+18
        fcb   $06,$00,$00,$53,$00,$00,$16,$D0  ; seg  91  curve=+6                          #2:$9D@+22 #3:$A3@-48
        fcb   $06,$00,$03,$04,$EA,$00,$16,$00  ; seg  92  curve=+6                          #0:$9D@-22 #2:$9E@+22
        fcb   $06,$00,$04,$03,$EE,$00,$14,$00  ; seg  93  curve=+6                          #0:$9E@-18 #2:$9D@+20
        fcb   $06,$00,$07,$50,$EE,$00,$00,$E0  ; seg  94  curve=+6                          #0:$81@-18 #3:$A3@-32
        fcb   $06,$00,$07,$03,$EE,$00,$12,$00  ; seg  95  curve=+6                          #0:$81@-18 #2:$9D@+18
        fcb   $7B,$00,$04,$50,$EC,$00,$00,$D0  ; seg  96  curve=-5                          #0:$9E@-20 #3:$A3@-48
        fcb   $7B,$00,$00,$53,$00,$00,$12,$20  ; seg  97  curve=-5                          #2:$9D@+18 #3:$A3@+32
        fcb   $7B,$00,$04,$04,$EE,$00,$18,$00  ; seg  98  curve=-5                          #0:$9E@-18 #2:$9E@+24
        fcb   $7B,$00,$03,$04,$E8,$00,$16,$00  ; seg  99  curve=-5                          #0:$9D@-24 #2:$9E@+22
        fcb   $7B,$00,$00,$53,$00,$00,$12,$E0  ; seg 100  curve=-5                          #2:$9D@+18 #3:$A3@-32
        fcb   $7B,$00,$03,$04,$EA,$00,$18,$00  ; seg 101  curve=-5                          #0:$9D@-22 #2:$9E@+24
        fcb   $7B,$00,$04,$00,$EC,$00,$00,$00  ; seg 102  curve=-5                          #0:$9E@-20
        fcb   $7B,$00,$03,$03,$E8,$00,$12,$00  ; seg 103  curve=-5                          #0:$9D@-24 #2:$9D@+18
        fcb   $00,$7F,$03,$04,$EC,$00,$14,$00  ; seg 104            pitch=-1                #0:$9D@-20 #2:$9E@+20
        fcb   $00,$7F,$00,$54,$00,$00,$18,$D0  ; seg 105            pitch=-1                #2:$9E@+24 #3:$A3@-48
        fcb   $00,$01,$04,$03,$EC,$00,$12,$00  ; seg 106            pitch=+1                #0:$9E@-20 #2:$9D@+18
        fcb   $00,$01,$03,$50,$EC,$00,$00,$D0  ; seg 107            pitch=+1                #0:$9D@-20 #3:$A3@-48
        fcb   $00,$00,$03,$03,$E8,$00,$18,$00  ; seg 108                                    #0:$9D@-24 #2:$9D@+24
        fcb   $00,$00,$03,$04,$EE,$00,$14,$00  ; seg 109                                    #0:$9D@-18 #2:$9E@+20
        fcb   $00,$00,$07,$03,$EE,$00,$18,$00  ; seg 110                                    #0:$81@-18 #2:$9D@+24
        fcb   $00,$00,$07,$03,$EE,$00,$12,$00  ; seg 111                                    #0:$81@-18 #2:$9D@+18
        fcb   $7B,$00,$03,$03,$EC,$00,$16,$00  ; seg 112  curve=-5                          #0:$9D@-20 #2:$9D@+22
        fcb   $7B,$00,$04,$03,$E8,$00,$18,$00  ; seg 113  curve=-5                          #0:$9E@-24 #2:$9D@+24
        fcb   $7B,$00,$00,$50,$00,$00,$00,$20  ; seg 114  curve=-5                          #3:$A3@+32
        fcb   $7B,$00,$03,$04,$EA,$00,$14,$00  ; seg 115  curve=-5                          #0:$9D@-22 #2:$9E@+20
        fcb   $7B,$00,$04,$03,$EC,$00,$12,$00  ; seg 116  curve=-5                          #0:$9E@-20 #2:$9D@+18
        fcb   $7B,$00,$03,$04,$EC,$00,$18,$00  ; seg 117  curve=-5                          #0:$9D@-20 #2:$9E@+24
        fcb   $7B,$00,$03,$04,$EA,$00,$18,$00  ; seg 118  curve=-5                          #0:$9D@-22 #2:$9E@+24
        fcb   $7B,$00,$03,$04,$EC,$00,$16,$00  ; seg 119  curve=-5                          #0:$9D@-20 #2:$9E@+22
        fcb   $00,$01,$03,$04,$E8,$00,$14,$00  ; seg 120            pitch=+1                #0:$9D@-24 #2:$9E@+20
        fcb   $00,$01,$04,$03,$EE,$00,$12,$00  ; seg 121            pitch=+1                #0:$9E@-18 #2:$9D@+18
        fcb   $00,$7F,$04,$04,$EC,$00,$18,$00  ; seg 122            pitch=-1                #0:$9E@-20 #2:$9E@+24
        fcb   $00,$7F,$04,$04,$EA,$00,$12,$00  ; seg 123            pitch=-1                #0:$9E@-22 #2:$9E@+18
        fcb   $00,$00,$03,$50,$EC,$00,$00,$E0  ; seg 124                                    #0:$9D@-20 #3:$A3@-32
        fcb   $00,$00,$03,$03,$E8,$00,$18,$00  ; seg 125                                    #0:$9D@-24 #2:$9D@+24
        fcb   $00,$00,$00,$56,$00,$00,$12,$20  ; seg 126                                    #2:$80@+18 #3:$A3@+32
        fcb   $00,$00,$03,$06,$EA,$00,$12,$00  ; seg 127                                    #0:$9D@-22 #2:$80@+18
        fcb   $06,$00,$03,$03,$EC,$00,$16,$00  ; seg 128  curve=+6                          #0:$9D@-20 #2:$9D@+22
        fcb   $06,$00,$04,$04,$E8,$00,$12,$00  ; seg 129  curve=+6                          #0:$9E@-24 #2:$9E@+18
        fcb   $06,$00,$00,$53,$00,$00,$18,$D0  ; seg 130  curve=+6                          #2:$9D@+24 #3:$A3@-48
        fcb   $06,$00,$04,$03,$EC,$00,$16,$00  ; seg 131  curve=+6                          #0:$9E@-20 #2:$9D@+22
        fcb   $06,$00,$04,$03,$EC,$00,$12,$00  ; seg 132  curve=+6                          #0:$9E@-20 #2:$9D@+18
        fcb   $06,$00,$04,$50,$EA,$00,$00,$E0  ; seg 133  curve=+6                          #0:$9E@-22 #3:$A3@-32
        fcb   $06,$00,$07,$04,$EE,$00,$14,$00  ; seg 134  curve=+6                          #0:$81@-18 #2:$9E@+20
        fcb   $06,$00,$07,$03,$EE,$00,$12,$00  ; seg 135  curve=+6                          #0:$81@-18 #2:$9D@+18
        fcb   $7A,$00,$03,$03,$EC,$00,$12,$00  ; seg 136  curve=-6                          #0:$9D@-20 #2:$9D@+18
        fcb   $7A,$00,$03,$03,$EA,$00,$16,$00  ; seg 137  curve=-6                          #0:$9D@-22 #2:$9D@+22
        fcb   $7A,$00,$00,$53,$00,$00,$14,$20  ; seg 138  curve=-6                          #2:$9D@+20 #3:$A3@+32
        fcb   $7A,$00,$04,$50,$EC,$00,$00,$D0  ; seg 139  curve=-6                          #0:$9E@-20 #3:$A3@-48
        fcb   $7A,$00,$04,$04,$E8,$00,$12,$00  ; seg 140  curve=-6                          #0:$9E@-24 #2:$9E@+18
        fcb   $7A,$00,$03,$03,$EC,$00,$14,$00  ; seg 141  curve=-6                          #0:$9D@-20 #2:$9D@+20
        fcb   $7A,$00,$00,$04,$00,$00,$16,$00  ; seg 142  curve=-6                          #2:$9E@+22
        fcb   $7A,$00,$03,$50,$E8,$00,$00,$D0  ; seg 143  curve=-6                          #0:$9D@-24 #3:$A3@-48
        fcb   $00,$00,$04,$03,$EE,$00,$12,$00  ; seg 144                                    #0:$9E@-18 #2:$9D@+18
        fcb   $00,$00,$03,$04,$EC,$00,$14,$00  ; seg 145                                    #0:$9D@-20 #2:$9E@+20
        fcb   $00,$7F,$04,$03,$EC,$00,$12,$00  ; seg 146            pitch=-1                #0:$9E@-20 #2:$9D@+18
        fcb   $00,$7F,$00,$53,$00,$00,$18,$20  ; seg 147            pitch=-1                #2:$9D@+24 #3:$A3@+32
        fcb   $00,$01,$03,$50,$EE,$00,$00,$E0  ; seg 148            pitch=+1                #0:$9D@-18 #3:$A3@-32
        fcb   $00,$01,$03,$03,$EA,$00,$12,$00  ; seg 149            pitch=+1                #0:$9D@-22 #2:$9D@+18
        fcb   $00,$01,$02,$02,$EC,$00,$14,$00  ; seg 150            pitch=+1                #0:$84@-20 #2:$84@+20
        fcb   $00,$01,$02,$02,$EC,$00,$14,$00  ; seg 151            pitch=+1                #0:$84@-20 #2:$84@+20
        fcb   $00,$7F,$02,$02,$EC,$00,$14,$00  ; seg 152            pitch=-1                #0:$84@-20 #2:$84@+20
        fcb   $00,$7F,$02,$02,$EC,$00,$14,$00  ; seg 153            pitch=-1                #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$02,$02,$EC,$00,$14,$00  ; seg 154                                    #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$02,$02,$EC,$00,$14,$00  ; seg 155                                    #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$07,$02,$EE,$00,$14,$00  ; seg 156                                    #0:$81@-18 #2:$84@+20
        fcb   $00,$00,$07,$02,$EE,$00,$14,$00  ; seg 157                                    #0:$81@-18 #2:$84@+20
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $7C,$00,$01,$00,$00,$00,$00,$00  ; seg 158  curve=-4                          #0:$82@+0
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg 159  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg 160  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg 161  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg 162  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg 163  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg 164  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$02,$02,$EC,$00,$14,$00  ; seg 165  curve=-4                          #0:$84@-20 #2:$84@+20

Circuit_29_hard_12_segment_cache
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
        fcb   $C6,$00,$F6,$0A  ; seg  17  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  18  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D2,$00,$F6,$0A  ; seg  19  yaw= -46 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  20  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DE,$00,$F6,$0A  ; seg  21  yaw= -34 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  22  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EA,$00,$F6,$0A  ; seg  23  yaw= -22 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  24  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F6,$00,$F6,$0A  ; seg  25  yaw= -10 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  26  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $02,$00,$F6,$0A  ; seg  27  yaw=  +2 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  28  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0E,$00,$F6,$0A  ; seg  29  yaw= +14 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg  30  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1A,$00,$F6,$0A  ; seg  31  yaw= +26 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  32  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1A,$00,$F6,$0A  ; seg  33  yaw= +26 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg  34  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0E,$00,$F6,$0A  ; seg  35  yaw= +14 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  36  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $02,$00,$F6,$0A  ; seg  37  yaw=  +2 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  38  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F6,$00,$F6,$0A  ; seg  39  yaw= -10 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  40  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$01,$F6,$0A  ; seg  41  yaw= -16 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $F0,$02,$F6,$0A  ; seg  42  yaw= -16 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $F0,$01,$F6,$0A  ; seg  43  yaw= -16 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  44  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  45  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  46  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  47  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  48  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  49  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  50  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  51  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  52  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  53  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  54  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  55  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  56  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  57  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  58  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  59  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  60  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  61  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  62  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  63  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  64  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  65  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  66  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  67  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  68  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  69  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  70  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  71  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  72  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$FF,$F6,$0A  ; seg  73  yaw= -48 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $D0,$FE,$F6,$0A  ; seg  74  yaw= -48 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $D0,$FF,$F6,$0A  ; seg  75  yaw= -48 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  76  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  77  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  78  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  79  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  80  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CA,$00,$F6,$0A  ; seg  81  yaw= -54 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  82  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BE,$00,$F6,$0A  ; seg  83  yaw= -66 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  84  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B2,$00,$F6,$0A  ; seg  85  yaw= -78 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg  86  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A6,$00,$F6,$0A  ; seg  87  yaw= -90 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg  88  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A6,$00,$F6,$0A  ; seg  89  yaw= -90 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg  90  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B2,$00,$F6,$0A  ; seg  91  yaw= -78 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  92  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BE,$00,$F6,$0A  ; seg  93  yaw= -66 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  94  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CA,$00,$F6,$0A  ; seg  95  yaw= -54 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  96  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CB,$00,$F6,$0A  ; seg  97  yaw= -53 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C6,$00,$F6,$0A  ; seg  98  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C1,$00,$F6,$0A  ; seg  99  yaw= -63 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 100  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B7,$00,$F6,$0A  ; seg 101  yaw= -73 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B2,$00,$F6,$0A  ; seg 102  yaw= -78 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AD,$00,$F6,$0A  ; seg 103  yaw= -83 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 104  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$FF,$F6,$0A  ; seg 105  yaw= -88 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $A8,$FE,$F6,$0A  ; seg 106  yaw= -88 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A8,$FF,$F6,$0A  ; seg 107  yaw= -88 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 108  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 109  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 110  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 111  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 112  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A3,$00,$F6,$0A  ; seg 113  yaw= -93 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9E,$00,$F6,$0A  ; seg 114  yaw= -98 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $99,$00,$F6,$0A  ; seg 115  yaw=-103 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 116  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8F,$00,$F6,$0A  ; seg 117  yaw=-113 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8A,$00,$F6,$0A  ; seg 118  yaw=-118 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $85,$00,$F6,$0A  ; seg 119  yaw=-123 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 120  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 121  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 122  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 123  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 124  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 125  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 126  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 127  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 128  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg 129  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 130  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg 131  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 132  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9E,$00,$F6,$0A  ; seg 133  yaw= -98 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 134  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AA,$00,$F6,$0A  ; seg 135  yaw= -86 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 136  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AA,$00,$F6,$0A  ; seg 137  yaw= -86 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 138  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9E,$00,$F6,$0A  ; seg 139  yaw= -98 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 140  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg 141  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 142  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg 143  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 144  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 145  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 146  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 147  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 148  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 149  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 150  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 151  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 152  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 153  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 154  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 155  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 156  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 157  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 158 (wraparound de seg 0)
        fcb   $FC,$00,$F6,$0A  ; seg 159 (wraparound de seg 1)
        fcb   $F8,$00,$F6,$0A  ; seg 160 (wraparound de seg 2)
        fcb   $F4,$00,$F6,$0A  ; seg 161 (wraparound de seg 3)
        fcb   $F0,$00,$F6,$0A  ; seg 162 (wraparound de seg 4)
        fcb   $EC,$00,$F6,$0A  ; seg 163 (wraparound de seg 5)
        fcb   $E8,$00,$F6,$0A  ; seg 164 (wraparound de seg 6)
        fcb   $E4,$00,$F6,$0A  ; seg 165 (wraparound de seg 7)
