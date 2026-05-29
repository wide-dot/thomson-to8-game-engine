* ======================================================================
* Circuit_16_medium_9 — N=170 segments (format compact 8 oct/seg)
* Source       : 16_medium_9.bin (extrait de FILE30)
*
* Pays         : JAPAN
* Lieu         : sagamihara
* Description  : deceptively sharp bends
* Hazards      : oil patches on straights
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
* par circuit ; ce circuit : 11 entries utilisées).
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
* Taille totale : 2154 oct (nb_segments 2 + LUT 16 + segments 1424 + cache 712).
* ======================================================================

Circuit_16_medium_9_nb_segments
        fdb   170

Circuit_16_medium_9_sprite_lut
        fcb   $00,$82,$80,$83,$81,$8A,$89,$8F,$84,$A2,$86,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_16_medium_9_segments
        fcb   $04,$80,$01,$00,$00,$00,$00,$00  ; seg   0  curve=+4            flags=[START] #0:$82@+0
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg   1  curve=+4                          #0:$80@+18
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg   2  curve=+4                          #0:$80@+18
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg   3  curve=+4                          #0:$80@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg   4  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg   5  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg   6  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg   7  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $84,$00,$02,$00,$16,$00,$00,$00  ; seg   8  curve=+4            flags=[PIT]   #0:$80@+22
        fcb   $84,$00,$02,$00,$16,$00,$00,$00  ; seg   9  curve=+4            flags=[PIT]   #0:$80@+22
        fcb   $84,$00,$02,$00,$16,$00,$00,$00  ; seg  10  curve=+4            flags=[PIT]   #0:$80@+22
        fcb   $84,$00,$02,$00,$16,$00,$00,$00  ; seg  11  curve=+4            flags=[PIT]   #0:$80@+22
        fcb   $84,$00,$02,$00,$16,$00,$00,$00  ; seg  12  curve=+4            flags=[PIT]   #0:$80@+22
        fcb   $84,$00,$02,$00,$16,$00,$00,$00  ; seg  13  curve=+4            flags=[PIT]   #0:$80@+22
        fcb   $84,$00,$04,$04,$EE,$00,$EE,$00  ; seg  14  curve=+4            flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $84,$00,$04,$04,$EE,$00,$EE,$00  ; seg  15  curve=+4            flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$D8  ; seg  16  curve=-4                          #0:$81@-18 #3:$8A@-40
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$20  ; seg  17  curve=-4                          #0:$81@-18 #3:$89@+32
        fcb   $7C,$00,$74,$60,$EE,$14,$00,$E0  ; seg  18  curve=-4                          #0:$81@-18 #1:$8F@+20 #3:$89@-32
        fcb   $7C,$00,$74,$00,$EE,$14,$00,$00  ; seg  19  curve=-4                          #0:$81@-18 #1:$8F@+20
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$38  ; seg  20  curve=-4                          #0:$81@-18 #3:$8A@+56
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$D0  ; seg  21  curve=-4                          #0:$81@-18 #3:$89@-48
        fcb   $7C,$00,$74,$00,$EE,$14,$00,$00  ; seg  22  curve=-4                          #0:$81@-18 #1:$8F@+20
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$E8  ; seg  23  curve=-4                          #0:$81@-18 #3:$89@-24
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$20  ; seg  24  curve=-4                          #0:$81@-18 #3:$8A@+32
        fcb   $7C,$00,$74,$00,$EE,$14,$00,$00  ; seg  25  curve=-4                          #0:$81@-18 #1:$8F@+20
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$38  ; seg  26  curve=-4                          #0:$81@-18 #3:$89@+56
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$D0  ; seg  27  curve=-4                          #0:$81@-18 #3:$89@-48
        fcb   $7C,$00,$74,$00,$EE,$14,$00,$00  ; seg  28  curve=-4                          #0:$81@-18 #1:$8F@+20
        fcb   $7C,$00,$74,$50,$EE,$14,$00,$E8  ; seg  29  curve=-4                          #0:$81@-18 #1:$8F@+20 #3:$8A@-24
        fcb   $7C,$00,$00,$60,$00,$00,$00,$28  ; seg  30  curve=-4                          #3:$89@+40
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  31  curve=-4
        fcb   $00,$00,$08,$68,$12,$00,$12,$30  ; seg  32                                    #0:$84@+18 #2:$84@+18 #3:$89@+48
        fcb   $00,$00,$08,$58,$12,$00,$12,$D8  ; seg  33                                    #0:$84@+18 #2:$84@+18 #3:$8A@-40
        fcb   $00,$01,$78,$08,$12,$EC,$12,$00  ; seg  34            pitch=+1                #0:$84@+18 #1:$8F@-20 #2:$84@+18
        fcb   $00,$01,$08,$58,$12,$00,$12,$E8  ; seg  35            pitch=+1                #0:$84@+18 #2:$84@+18 #3:$8A@-24
        fcb   $00,$7F,$08,$08,$EE,$00,$EE,$00  ; seg  36            pitch=-1                #0:$84@-18 #2:$84@-18
        fcb   $00,$7F,$08,$68,$EE,$00,$EE,$28  ; seg  37            pitch=-1                #0:$84@-18 #2:$84@-18 #3:$89@+40
        fcb   $00,$7F,$78,$08,$EE,$14,$EE,$00  ; seg  38            pitch=-1                #0:$84@-18 #1:$8F@+20 #2:$84@-18
        fcb   $00,$7F,$08,$68,$EE,$00,$EE,$E0  ; seg  39            pitch=-1                #0:$84@-18 #2:$84@-18 #3:$89@-32
        fcb   $00,$01,$08,$68,$12,$00,$12,$38  ; seg  40            pitch=+1                #0:$84@+18 #2:$84@+18 #3:$89@+56
        fcb   $00,$01,$78,$08,$12,$EC,$12,$00  ; seg  41            pitch=+1                #0:$84@+18 #1:$8F@-20 #2:$84@+18
        fcb   $00,$01,$08,$58,$12,$00,$12,$28  ; seg  42            pitch=+1                #0:$84@+18 #2:$84@+18 #3:$8A@+40
        fcb   $00,$01,$08,$68,$12,$00,$12,$E0  ; seg  43            pitch=+1                #0:$84@+18 #2:$84@+18 #3:$89@-32
        fcb   $00,$7F,$00,$60,$00,$00,$00,$D8  ; seg  44            pitch=-1                #3:$89@-40
        fcb   $00,$7F,$70,$00,$00,$14,$00,$00  ; seg  45            pitch=-1                #1:$8F@+20
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  46                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  47                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  48  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$54,$EE,$00,$EE,$20  ; seg  49  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8A@+32
        fcb   $7A,$00,$04,$64,$EE,$00,$EE,$E0  ; seg  50  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$89@-32
        fcb   $7A,$00,$74,$04,$EE,$14,$EE,$00  ; seg  51  curve=-6                          #0:$81@-18 #1:$8F@+20 #2:$81@-18
        fcb   $7A,$00,$74,$64,$EE,$14,$EE,$D8  ; seg  52  curve=-6                          #0:$81@-18 #1:$8F@+20 #2:$81@-18 #3:$89@-40
        fcb   $7A,$00,$04,$54,$EE,$00,$EE,$20  ; seg  53  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8A@+32
        fcb   $7A,$00,$22,$22,$12,$12,$12,$12  ; seg  54  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$22,$22,$12,$12,$12,$12  ; seg  55  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$02,$02,$12,$00,$12,$00  ; seg  56  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$02,$62,$12,$00,$12,$38  ; seg  57  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$89@+56
        fcb   $06,$00,$72,$02,$12,$EC,$12,$00  ; seg  58  curve=+6                          #0:$80@+18 #1:$8F@-20 #2:$80@+18
        fcb   $06,$00,$02,$62,$12,$00,$12,$E0  ; seg  59  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$89@-32
        fcb   $06,$00,$02,$52,$12,$00,$12,$38  ; seg  60  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8A@+56
        fcb   $06,$00,$02,$02,$12,$00,$12,$00  ; seg  61  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$70,$00,$00,$EC,$00,$00  ; seg  62  curve=+6                          #1:$8F@-20
        fcb   $06,$00,$70,$60,$00,$14,$00,$20  ; seg  63  curve=+6                          #1:$8F@+20 #3:$89@+32
        fcb   $00,$00,$08,$68,$EE,$00,$EE,$D8  ; seg  64                                    #0:$84@-18 #2:$84@-18 #3:$89@-40
        fcb   $00,$00,$08,$58,$EE,$00,$EE,$28  ; seg  65                                    #0:$84@-18 #2:$84@-18 #3:$8A@+40
        fcb   $00,$00,$78,$08,$EE,$14,$EE,$00  ; seg  66                                    #0:$84@-18 #1:$8F@+20 #2:$84@-18
        fcb   $00,$00,$08,$68,$EE,$00,$EE,$30  ; seg  67                                    #0:$84@-18 #2:$84@-18 #3:$89@+48
        fcb   $00,$00,$00,$60,$00,$00,$00,$E0  ; seg  68                                    #3:$89@-32
        fcb   $00,$00,$00,$50,$00,$00,$00,$D8  ; seg  69                                    #3:$8A@-40
        fcb   $00,$00,$72,$02,$12,$EC,$12,$00  ; seg  70                                    #0:$80@+18 #1:$8F@-20 #2:$80@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg  71                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$02,$60,$12,$00,$00,$E0  ; seg  72  curve=+4                          #0:$80@+18 #3:$89@-32
        fcb   $04,$00,$02,$60,$12,$00,$00,$D8  ; seg  73  curve=+4                          #0:$80@+18 #3:$89@-40
        fcb   $04,$7F,$02,$50,$12,$00,$00,$20  ; seg  74  curve=+4  pitch=-1                #0:$80@+18 #3:$8A@+32
        fcb   $04,$7F,$72,$50,$12,$EC,$00,$E0  ; seg  75  curve=+4  pitch=-1                #0:$80@+18 #1:$8F@-20 #3:$8A@-32
        fcb   $04,$01,$72,$00,$12,$EC,$00,$00  ; seg  76  curve=+4  pitch=+1                #0:$80@+18 #1:$8F@-20
        fcb   $04,$01,$02,$60,$12,$00,$00,$38  ; seg  77  curve=+4  pitch=+1                #0:$80@+18 #3:$89@+56
        fcb   $04,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  78  curve=+4                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $04,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  79  curve=+4                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  80  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$64,$EE,$00,$EE,$28  ; seg  81  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$89@+40
        fcb   $7A,$01,$04,$64,$EE,$00,$EE,$38  ; seg  82  curve=-6  pitch=+1                #0:$81@-18 #2:$81@-18 #3:$89@+56
        fcb   $7A,$01,$04,$54,$EE,$00,$EE,$E0  ; seg  83  curve=-6  pitch=+1                #0:$81@-18 #2:$81@-18 #3:$8A@-32
        fcb   $7A,$7F,$04,$04,$EE,$00,$EE,$00  ; seg  84  curve=-6  pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7A,$7F,$04,$64,$EE,$00,$EE,$D8  ; seg  85  curve=-6  pitch=-1                #0:$81@-18 #2:$81@-18 #3:$89@-40
        fcb   $7A,$00,$70,$60,$00,$14,$00,$20  ; seg  86  curve=-6                          #1:$8F@+20 #3:$89@+32
        fcb   $7A,$00,$70,$50,$00,$14,$00,$E0  ; seg  87  curve=-6                          #1:$8F@+20 #3:$8A@-32
        fcb   $00,$00,$00,$60,$00,$00,$00,$38  ; seg  88                                    #3:$89@+56
        fcb   $00,$00,$00,$60,$00,$00,$00,$20  ; seg  89                                    #3:$89@+32
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  90                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  91                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$74,$50,$EE,$14,$00,$D8  ; seg  92  curve=-4                          #0:$81@-18 #1:$8F@+20 #3:$8A@-40
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$20  ; seg  93  curve=-4                          #0:$81@-18 #3:$89@+32
        fcb   $7C,$00,$70,$00,$00,$14,$00,$00  ; seg  94  curve=-4                          #1:$8F@+20
        fcb   $7C,$00,$00,$60,$00,$00,$00,$38  ; seg  95  curve=-4                          #3:$89@+56
        fcb   $00,$00,$70,$60,$00,$14,$00,$E0  ; seg  96                                    #1:$8F@+20 #3:$89@-32
        fcb   $00,$00,$70,$50,$00,$14,$00,$38  ; seg  97                                    #1:$8F@+20 #3:$8A@+56
        fcb   $00,$00,$04,$64,$EE,$00,$EE,$E8  ; seg  98                                    #0:$81@-18 #2:$81@-18 #3:$89@-24
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  99                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$74,$50,$EE,$14,$00,$20  ; seg 100  curve=-4                          #0:$81@-18 #1:$8F@+20 #3:$8A@+32
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$D0  ; seg 101  curve=-4                          #0:$81@-18 #3:$89@-48
        fcb   $7C,$00,$74,$00,$EE,$14,$00,$00  ; seg 102  curve=-4                          #0:$81@-18 #1:$8F@+20
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$38  ; seg 103  curve=-4                          #0:$81@-18 #3:$8A@+56
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 104  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$74,$00,$EE,$14,$00,$00  ; seg 105  curve=-4                          #0:$81@-18 #1:$8F@+20
        fcb   $7C,$00,$70,$60,$00,$14,$00,$30  ; seg 106  curve=-4                          #1:$8F@+20 #3:$89@+48
        fcb   $7C,$00,$00,$60,$00,$00,$00,$E0  ; seg 107  curve=-4                          #3:$89@-32
        fcb   $00,$00,$78,$08,$12,$EC,$12,$00  ; seg 108                                    #0:$84@+18 #1:$8F@-20 #2:$84@+18
        fcb   $00,$00,$08,$68,$12,$00,$12,$28  ; seg 109                                    #0:$84@+18 #2:$84@+18 #3:$89@+40
        fcb   $00,$00,$78,$08,$12,$EC,$12,$00  ; seg 110                                    #0:$84@+18 #1:$8F@-20 #2:$84@+18
        fcb   $00,$00,$08,$58,$12,$00,$12,$D0  ; seg 111                                    #0:$84@+18 #2:$84@+18 #3:$8A@-48
        fcb   $00,$01,$00,$60,$00,$00,$00,$E0  ; seg 112            pitch=+1                #3:$89@-32
        fcb   $00,$01,$00,$60,$00,$00,$00,$28  ; seg 113            pitch=+1                #3:$89@+40
        fcb   $00,$7F,$79,$00,$06,$EC,$00,$00  ; seg 114            pitch=-1                #0:$A2@+6 #1:$8F@-20
        fcb   $00,$7F,$00,$60,$00,$00,$00,$D8  ; seg 115            pitch=-1                #3:$89@-40
        fcb   $00,$7F,$09,$50,$0A,$00,$00,$E0  ; seg 116            pitch=-1                #0:$A2@+10 #3:$8A@-32
        fcb   $00,$7F,$70,$00,$00,$EC,$00,$00  ; seg 117            pitch=-1                #1:$8F@-20
        fcb   $00,$01,$79,$60,$08,$EC,$00,$E0  ; seg 118            pitch=+1                #0:$A2@+8 #1:$8F@-20 #3:$89@-32
        fcb   $00,$01,$00,$60,$00,$00,$00,$28  ; seg 119            pitch=+1                #3:$89@+40
        fcb   $00,$01,$09,$50,$FA,$00,$00,$30  ; seg 120            pitch=+1                #0:$A2@-6 #3:$8A@+48
        fcb   $00,$01,$70,$00,$00,$14,$00,$00  ; seg 121            pitch=+1                #1:$8F@+20
        fcb   $00,$00,$09,$60,$F8,$00,$00,$D8  ; seg 122                                    #0:$A2@-8 #3:$89@-40
        fcb   $00,$00,$70,$00,$00,$14,$00,$00  ; seg 123                                    #1:$8F@+20
        fcb   $00,$00,$09,$50,$F6,$00,$00,$E0  ; seg 124                                    #0:$A2@-10 #3:$8A@-32
        fcb   $00,$00,$70,$60,$00,$14,$00,$30  ; seg 125                                    #1:$8F@+20 #3:$89@+48
        fcb   $00,$7F,$09,$00,$FA,$00,$00,$00  ; seg 126            pitch=-1                #0:$A2@-6
        fcb   $00,$7F,$00,$60,$00,$00,$00,$E8  ; seg 127            pitch=-1                #3:$89@-24
        fcb   $00,$7F,$09,$60,$0A,$00,$00,$E0  ; seg 128            pitch=-1                #0:$A2@+10 #3:$89@-32
        fcb   $00,$7F,$00,$50,$00,$00,$00,$28  ; seg 129            pitch=-1                #3:$8A@+40
        fcb   $00,$00,$79,$00,$08,$14,$00,$00  ; seg 130                                    #0:$A2@+8 #1:$8F@+20
        fcb   $00,$00,$70,$60,$00,$EC,$00,$D0  ; seg 131                                    #1:$8F@-20 #3:$89@-48
        fcb   $00,$00,$79,$00,$06,$EC,$00,$00  ; seg 132                                    #0:$A2@+6 #1:$8F@-20
        fcb   $00,$00,$00,$60,$00,$00,$00,$E8  ; seg 133                                    #3:$89@-24
        fcb   $00,$01,$02,$02,$12,$00,$12,$00  ; seg 134            pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $00,$01,$02,$02,$12,$00,$12,$00  ; seg 135            pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$02,$50,$12,$00,$00,$20  ; seg 136  curve=+4                          #0:$80@+18 #3:$8A@+32
        fcb   $04,$00,$02,$60,$12,$00,$00,$E8  ; seg 137  curve=+4                          #0:$80@+18 #3:$89@-24
        fcb   $04,$00,$70,$00,$00,$14,$00,$00  ; seg 138  curve=+4                          #1:$8F@+20
        fcb   $04,$00,$70,$60,$00,$EC,$00,$D0  ; seg 139  curve=+4                          #1:$8F@-20 #3:$89@-48
        fcb   $00,$00,$00,$60,$00,$00,$00,$28  ; seg 140                                    #3:$89@+40
        fcb   $00,$00,$00,$50,$00,$00,$00,$30  ; seg 141                                    #3:$8A@+48
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 142                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 143                                    #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$04,$60,$EE,$00,$00,$E8  ; seg 144  curve=-5                          #0:$81@-18 #3:$89@-24
        fcb   $7B,$00,$04,$60,$EE,$00,$00,$20  ; seg 145  curve=-5                          #0:$81@-18 #3:$89@+32
        fcb   $7B,$00,$74,$00,$EE,$14,$00,$00  ; seg 146  curve=-5                          #0:$81@-18 #1:$8F@+20
        fcb   $7B,$00,$74,$50,$EE,$14,$00,$D8  ; seg 147  curve=-5                          #0:$81@-18 #1:$8F@+20 #3:$8A@-40
        fcb   $7B,$01,$04,$60,$EE,$00,$00,$E0  ; seg 148  curve=-5  pitch=+1                #0:$81@-18 #3:$89@-32
        fcb   $7B,$01,$74,$00,$EE,$18,$00,$00  ; seg 149  curve=-5  pitch=+1                #0:$81@-18 #1:$8F@+24
        fcb   $7B,$7F,$04,$50,$EE,$00,$00,$E8  ; seg 150  curve=-5  pitch=-1                #0:$81@-18 #3:$8A@-24
        fcb   $7B,$7F,$74,$00,$EE,$18,$00,$00  ; seg 151  curve=-5  pitch=-1                #0:$81@-18 #1:$8F@+24
        fcb   $7B,$7F,$04,$70,$EE,$00,$00,$28  ; seg 152  curve=-5  pitch=-1                #0:$81@-18 #3:$8F@+40
        fcb   $7B,$7F,$04,$70,$EE,$00,$00,$E0  ; seg 153  curve=-5  pitch=-1                #0:$81@-18 #3:$8F@-32
        fcb   $7B,$00,$74,$00,$EE,$1C,$00,$00  ; seg 154  curve=-5                          #0:$81@-18 #1:$8F@+28
        fcb   $7B,$00,$74,$70,$EE,$14,$00,$E8  ; seg 155  curve=-5                          #0:$81@-18 #1:$8F@+20 #3:$8F@-24
        fcb   $7B,$01,$04,$70,$EE,$00,$00,$20  ; seg 156  curve=-5  pitch=+1                #0:$81@-18 #3:$8F@+32
        fcb   $7B,$01,$04,$70,$EE,$00,$00,$D0  ; seg 157  curve=-5  pitch=+1                #0:$81@-18 #3:$8F@-48
        fcb   $7B,$00,$70,$70,$00,$18,$00,$38  ; seg 158  curve=-5                          #1:$8F@+24 #3:$8F@+56
        fcb   $7B,$00,$70,$00,$00,$14,$00,$00  ; seg 159  curve=-5                          #1:$8F@+20
        fcb   $00,$00,$0A,$0A,$12,$00,$EE,$00  ; seg 160                                    #0:$86@+18 #2:$86@-18
        fcb   $00,$00,$0A,$7A,$12,$00,$EE,$30  ; seg 161                                    #0:$86@+18 #2:$86@-18 #3:$8F@+48
        fcb   $00,$00,$0A,$0A,$12,$00,$EE,$00  ; seg 162                                    #0:$86@+18 #2:$86@-18
        fcb   $00,$00,$0A,$0A,$12,$00,$EE,$00  ; seg 163                                    #0:$86@+18 #2:$86@-18
        fcb   $00,$00,$0A,$0A,$12,$00,$EE,$00  ; seg 164                                    #0:$86@+18 #2:$86@-18
        fcb   $00,$00,$0A,$0A,$12,$00,$EE,$00  ; seg 165                                    #0:$86@+18 #2:$86@-18
        fcb   $00,$00,$0A,$0A,$12,$00,$EE,$00  ; seg 166                                    #0:$86@+18 #2:$86@-18
        fcb   $00,$00,$0A,$0A,$12,$00,$EE,$00  ; seg 167                                    #0:$86@+18 #2:$86@-18
        fcb   $00,$00,$0A,$0A,$12,$00,$EE,$00  ; seg 168                                    #0:$86@+18 #2:$86@-18
        fcb   $00,$00,$0A,$0A,$12,$00,$EE,$00  ; seg 169                                    #0:$86@+18 #2:$86@-18
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $04,$00,$01,$00,$00,$00,$00,$00  ; seg 170  curve=+4                          #0:$82@+0
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg 171  curve=+4                          #0:$80@+18
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg 172  curve=+4                          #0:$80@+18
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg 173  curve=+4                          #0:$80@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg 174  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg 175  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg 176  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg 177  curve=+4                          #0:$83@+18 #2:$83@+18

Circuit_16_medium_9_segment_cache
        fcb   $00,$00,$F6,$0A  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $04,$00,$F6,$0A  ; seg   1  yaw=  +4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg   2  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$00,$F6,$0A  ; seg   3  yaw= +12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg   4  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg   5  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $18,$00,$F6,$0A  ; seg   6  yaw= +24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1C,$00,$F6,$0A  ; seg   7  yaw= +28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg   8  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $24,$00,$F6,$0A  ; seg   9  yaw= +36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  10  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$00,$F6,$0A  ; seg  11  yaw= +44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  12  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  13  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  14  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  15  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  16  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  17  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  18  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  19  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  20  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$00,$F6,$0A  ; seg  21  yaw= +44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  22  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $24,$00,$F6,$0A  ; seg  23  yaw= +36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  24  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1C,$00,$F6,$0A  ; seg  25  yaw= +28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $18,$00,$F6,$0A  ; seg  26  yaw= +24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg  27  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  28  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$00,$F6,$0A  ; seg  29  yaw= +12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  30  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $04,$00,$F6,$0A  ; seg  31  yaw=  +4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  32  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  33  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  34  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$01,$F6,$0A  ; seg  35  yaw=  +0 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  36  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $00,$01,$F6,$0A  ; seg  37  yaw=  +0 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  38  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg  39  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  40  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$FF,$F6,$0A  ; seg  41  yaw=  +0 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  42  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$01,$F6,$0A  ; seg  43  yaw=  +0 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  44  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $00,$01,$F6,$0A  ; seg  45  yaw=  +0 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  46  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  47  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  48  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FA,$00,$F6,$0A  ; seg  49  yaw=  -6 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  50  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EE,$00,$F6,$0A  ; seg  51  yaw= -18 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  52  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  53  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  54  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D6,$00,$F6,$0A  ; seg  55  yaw= -42 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  56  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D6,$00,$F6,$0A  ; seg  57  yaw= -42 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  58  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  59  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  60  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EE,$00,$F6,$0A  ; seg  61  yaw= -18 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  62  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FA,$00,$F6,$0A  ; seg  63  yaw=  -6 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  64  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  65  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  66  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  67  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  68  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  69  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  70  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  71  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  72  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $04,$00,$F6,$0A  ; seg  73  yaw=  +4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  74  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$FF,$F6,$0A  ; seg  75  yaw= +12 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $10,$FE,$F6,$0A  ; seg  76  yaw= +16 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $14,$FF,$F6,$0A  ; seg  77  yaw= +20 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $18,$00,$F6,$0A  ; seg  78  yaw= +24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1C,$00,$F6,$0A  ; seg  79  yaw= +28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  80  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1A,$00,$F6,$0A  ; seg  81  yaw= +26 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg  82  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0E,$01,$F6,$0A  ; seg  83  yaw= +14 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $08,$02,$F6,$0A  ; seg  84  yaw=  +8 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $02,$01,$F6,$0A  ; seg  85  yaw=  +2 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  86  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F6,$00,$F6,$0A  ; seg  87  yaw= -10 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  88  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  89  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  90  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  91  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  92  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  93  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  94  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  95  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  96  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  97  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  98  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  99  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg 100  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg 101  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg 102  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$09  ; seg 103  yaw= -44 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $D0,$00,$F6,$08  ; seg 104  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $CC,$00,$F6,$07  ; seg 105  yaw= -52 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $C8,$00,$F6,$06  ; seg 106  yaw= -56 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $C4,$00,$F6,$05  ; seg 107  yaw= -60 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $C0,$00,$F6,$04  ; seg 108  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $C0,$00,$F7,$03  ; seg 109  yaw= -64 pitch=  +0 min_lat=  -9 max_lat=  +3
        fcb   $C0,$00,$F8,$02  ; seg 110  yaw= -64 pitch=  +0 min_lat=  -8 max_lat=  +2
        fcb   $C0,$00,$F9,$01  ; seg 111  yaw= -64 pitch=  +0 min_lat=  -7 max_lat=  +1
        fcb   $C0,$00,$FA,$00  ; seg 112  yaw= -64 pitch=  +0 min_lat=  -6 max_lat=  +0
        fcb   $C0,$01,$FB,$FF  ; seg 113  yaw= -64 pitch=  +1 min_lat=  -5 max_lat=  -1
        fcb   $C0,$02,$FC,$FE  ; seg 114  yaw= -64 pitch=  +2 min_lat=  -4 max_lat=  -2
        fcb   $C0,$01,$FD,$03  ; seg 115  yaw= -64 pitch=  +1 min_lat=  -3 max_lat=  +3
        fcb   $C0,$00,$FE,$02  ; seg 116  yaw= -64 pitch=  +0 min_lat=  -2 max_lat=  +2
        fcb   $C0,$FF,$FF,$01  ; seg 117  yaw= -64 pitch=  -1 min_lat=  -1 max_lat=  +1
        fcb   $C0,$FE,$00,$00  ; seg 118  yaw= -64 pitch=  -2 min_lat=  +0 max_lat=  +0
        fcb   $C0,$FF,$01,$0A  ; seg 119  yaw= -64 pitch=  -1 min_lat=  +1 max_lat= +10
        fcb   $C0,$00,$02,$0A  ; seg 120  yaw= -64 pitch=  +0 min_lat=  +2 max_lat= +10
        fcb   $C0,$01,$FF,$09  ; seg 121  yaw= -64 pitch=  +1 min_lat=  -1 max_lat=  +9
        fcb   $C0,$02,$00,$08  ; seg 122  yaw= -64 pitch=  +2 min_lat=  +0 max_lat=  +8
        fcb   $C0,$02,$FF,$07  ; seg 123  yaw= -64 pitch=  +2 min_lat=  -1 max_lat=  +7
        fcb   $C0,$02,$00,$06  ; seg 124  yaw= -64 pitch=  +2 min_lat=  +0 max_lat=  +6
        fcb   $C0,$02,$01,$05  ; seg 125  yaw= -64 pitch=  +2 min_lat=  +1 max_lat=  +5
        fcb   $C0,$02,$02,$04  ; seg 126  yaw= -64 pitch=  +2 min_lat=  +2 max_lat=  +4
        fcb   $C0,$01,$F6,$03  ; seg 127  yaw= -64 pitch=  +1 min_lat= -10 max_lat=  +3
        fcb   $C0,$00,$F6,$02  ; seg 128  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $C0,$FF,$F6,$01  ; seg 129  yaw= -64 pitch=  -1 min_lat= -10 max_lat=  +1
        fcb   $C0,$FE,$F6,$00  ; seg 130  yaw= -64 pitch=  -2 min_lat= -10 max_lat=  +0
        fcb   $C0,$FE,$F6,$FF  ; seg 131  yaw= -64 pitch=  -2 min_lat= -10 max_lat=  -1
        fcb   $C0,$FE,$F6,$FE  ; seg 132  yaw= -64 pitch=  -2 min_lat= -10 max_lat=  -2
        fcb   $C0,$FE,$F6,$0A  ; seg 133  yaw= -64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C0,$FE,$F6,$0A  ; seg 134  yaw= -64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C0,$FF,$F6,$0A  ; seg 135  yaw= -64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 136  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg 137  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 138  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg 139  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 140  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 141  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 142  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 143  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 144  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CB,$00,$F6,$0A  ; seg 145  yaw= -53 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C6,$00,$F6,$0A  ; seg 146  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C1,$00,$F6,$0A  ; seg 147  yaw= -63 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 148  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B7,$01,$F6,$0A  ; seg 149  yaw= -73 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B2,$02,$F6,$0A  ; seg 150  yaw= -78 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $AD,$01,$F6,$0A  ; seg 151  yaw= -83 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 152  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A3,$FF,$F6,$0A  ; seg 153  yaw= -93 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $9E,$FE,$F6,$0A  ; seg 154  yaw= -98 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $99,$FE,$F6,$0A  ; seg 155  yaw=-103 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $94,$FE,$F6,$0A  ; seg 156  yaw=-108 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $8F,$FF,$F6,$0A  ; seg 157  yaw=-113 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $8A,$00,$F6,$0A  ; seg 158  yaw=-118 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $85,$00,$F6,$0A  ; seg 159  yaw=-123 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 160  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 161  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 162  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 163  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 164  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 165  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 166  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 167  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 168  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 169  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 170 (wraparound de seg 0)
        fcb   $04,$00,$F6,$0A  ; seg 171 (wraparound de seg 1)
        fcb   $08,$00,$F6,$0A  ; seg 172 (wraparound de seg 2)
        fcb   $0C,$00,$F6,$0A  ; seg 173 (wraparound de seg 3)
        fcb   $10,$00,$F6,$0A  ; seg 174 (wraparound de seg 4)
        fcb   $14,$00,$F6,$0A  ; seg 175 (wraparound de seg 5)
        fcb   $18,$00,$F6,$0A  ; seg 176 (wraparound de seg 6)
        fcb   $1C,$00,$F6,$0A  ; seg 177 (wraparound de seg 7)
