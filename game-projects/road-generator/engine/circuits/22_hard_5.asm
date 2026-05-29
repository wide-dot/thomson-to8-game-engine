* ======================================================================
* Circuit_22_hard_5 — N=176 segments (format compact 8 oct/seg)
* Source       : 22_hard_5.bin (extrait de FILE30)
*
* Pays         : CANADA
* Lieu         : wabush city, labrador
* Description  : long sweeping bends
* Hazards      : and long hills
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
* Taille totale : 2226 oct (nb_segments 2 + LUT 16 + segments 1472 + cache 736).
* ======================================================================

Circuit_22_hard_5_nb_segments
        fdb   176

Circuit_22_hard_5_sprite_lut
        fcb   $00,$82,$83,$87,$81,$8F,$90,$80,$00,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_22_hard_5_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$03,$03,$EE,$00,$16,$00  ; seg   8                      flags=[PIT]   #0:$87@-18 #2:$87@+22
        fcb   $80,$00,$03,$03,$EE,$00,$16,$00  ; seg   9                      flags=[PIT]   #0:$87@-18 #2:$87@+22
        fcb   $80,$00,$03,$03,$EE,$00,$16,$00  ; seg  10                      flags=[PIT]   #0:$87@-18 #2:$87@+22
        fcb   $80,$00,$03,$03,$EE,$00,$16,$00  ; seg  11                      flags=[PIT]   #0:$87@-18 #2:$87@+22
        fcb   $80,$00,$03,$03,$EE,$00,$16,$00  ; seg  12                      flags=[PIT]   #0:$87@-18 #2:$87@+22
        fcb   $80,$00,$03,$03,$EE,$00,$16,$00  ; seg  13                      flags=[PIT]   #0:$87@-18 #2:$87@+22
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  14                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  15                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$03,$EE,$00,$16,$00  ; seg  16  curve=-4                          #0:$81@-18 #2:$87@+22
        fcb   $7C,$00,$04,$03,$EE,$00,$16,$00  ; seg  17  curve=-4                          #0:$81@-18 #2:$87@+22
        fcb   $7C,$00,$04,$03,$EE,$00,$16,$00  ; seg  18  curve=-4                          #0:$81@-18 #2:$87@+22
        fcb   $7C,$00,$04,$03,$EE,$00,$16,$00  ; seg  19  curve=-4                          #0:$81@-18 #2:$87@+22
        fcb   $7C,$00,$04,$03,$EE,$00,$16,$00  ; seg  20  curve=-4                          #0:$81@-18 #2:$87@+22
        fcb   $7C,$00,$04,$03,$EE,$00,$16,$00  ; seg  21  curve=-4                          #0:$81@-18 #2:$87@+22
        fcb   $7C,$00,$03,$03,$EE,$00,$16,$00  ; seg  22  curve=-4                          #0:$87@-18 #2:$87@+22
        fcb   $7C,$00,$03,$03,$EE,$00,$16,$00  ; seg  23  curve=-4                          #0:$87@-18 #2:$87@+22
        fcb   $00,$00,$03,$05,$EE,$00,$14,$00  ; seg  24                                    #0:$87@-18 #2:$8F@+20
        fcb   $00,$00,$03,$06,$EE,$00,$18,$00  ; seg  25                                    #0:$87@-18 #2:$90@+24
        fcb   $00,$7E,$03,$06,$EE,$00,$1C,$00  ; seg  26            pitch=-2                #0:$87@-18 #2:$90@+28
        fcb   $00,$7E,$03,$05,$EE,$00,$18,$00  ; seg  27            pitch=-2                #0:$87@-18 #2:$8F@+24
        fcb   $00,$02,$03,$06,$EE,$00,$1C,$00  ; seg  28            pitch=+2                #0:$87@-18 #2:$90@+28
        fcb   $00,$02,$03,$05,$EE,$00,$14,$00  ; seg  29            pitch=+2                #0:$87@-18 #2:$8F@+20
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  30                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  31                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$54,$EE,$00,$EE,$14  ; seg  32  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8F@+20
        fcb   $7A,$00,$04,$04,$EC,$00,$EE,$00  ; seg  33  curve=-6                          #0:$81@-20 #2:$81@-18
        fcb   $7A,$7F,$04,$04,$EE,$00,$EE,$00  ; seg  34  curve=-6  pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7A,$7F,$04,$54,$EE,$00,$EE,$20  ; seg  35  curve=-6  pitch=-1                #0:$81@-18 #2:$81@-18 #3:$8F@+32
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  36  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  37  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$64,$EE,$00,$EE,$1C  ; seg  38  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$90@+28
        fcb   $7A,$00,$04,$04,$EA,$00,$EA,$00  ; seg  39  curve=-6                          #0:$81@-22 #2:$81@-22
        fcb   $7A,$01,$04,$04,$EE,$00,$EE,$00  ; seg  40  curve=-6  pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $7A,$01,$04,$04,$EC,$00,$EE,$00  ; seg  41  curve=-6  pitch=+1                #0:$81@-20 #2:$81@-18
        fcb   $7A,$00,$04,$64,$EE,$00,$EE,$20  ; seg  42  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$90@+32
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  43  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  44  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  45  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$77,$77,$12,$12,$12,$12  ; seg  46  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$77,$77,$12,$12,$12,$12  ; seg  47  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  48  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$67,$12,$00,$12,$EE  ; seg  49  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$90@-18
        fcb   $06,$7F,$07,$07,$12,$00,$12,$00  ; seg  50  curve=+6  pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $06,$7F,$07,$07,$12,$00,$12,$00  ; seg  51  curve=+6  pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  52  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$57,$12,$00,$12,$E4  ; seg  53  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8F@-28
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  54  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  55  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$7F,$07,$67,$12,$00,$12,$E0  ; seg  56  curve=+6  pitch=-1                #0:$80@+18 #2:$80@+18 #3:$90@-32
        fcb   $06,$7F,$07,$07,$12,$00,$12,$00  ; seg  57  curve=+6  pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  58  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  59  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$01,$07,$57,$12,$00,$12,$EC  ; seg  60  curve=+6  pitch=+1                #0:$80@+18 #2:$80@+18 #3:$8F@-20
        fcb   $06,$01,$07,$67,$12,$00,$12,$EC  ; seg  61  curve=+6  pitch=+1                #0:$80@+18 #2:$80@+18 #3:$90@-20
        fcb   $06,$01,$03,$55,$12,$00,$EC,$EC  ; seg  62  curve=+6  pitch=+1                #0:$87@+18 #2:$8F@-20 #3:$8F@-20
        fcb   $06,$01,$03,$06,$12,$00,$E4,$00  ; seg  63  curve=+6  pitch=+1                #0:$87@+18 #2:$90@-28
        fcb   $00,$00,$03,$06,$12,$00,$E4,$00  ; seg  64                                    #0:$87@+18 #2:$90@-28
        fcb   $00,$00,$03,$05,$12,$00,$EC,$00  ; seg  65                                    #0:$87@+18 #2:$8F@-20
        fcb   $00,$00,$03,$06,$12,$00,$E8,$00  ; seg  66                                    #0:$87@+18 #2:$90@-24
        fcb   $00,$00,$03,$06,$12,$00,$EC,$00  ; seg  67                                    #0:$87@+18 #2:$90@-20
        fcb   $00,$7E,$03,$05,$12,$00,$E4,$00  ; seg  68            pitch=-2                #0:$87@+18 #2:$8F@-28
        fcb   $00,$7E,$03,$06,$12,$00,$E8,$00  ; seg  69            pitch=-2                #0:$87@+18 #2:$90@-24
        fcb   $00,$7E,$03,$06,$12,$00,$EC,$00  ; seg  70            pitch=-2                #0:$87@+18 #2:$90@-20
        fcb   $00,$7E,$03,$05,$12,$00,$E4,$00  ; seg  71            pitch=-2                #0:$87@+18 #2:$8F@-28
        fcb   $00,$7E,$03,$05,$12,$00,$EC,$00  ; seg  72            pitch=-2                #0:$87@+18 #2:$8F@-20
        fcb   $00,$7E,$03,$06,$12,$00,$E4,$00  ; seg  73            pitch=-2                #0:$87@+18 #2:$90@-28
        fcb   $00,$7E,$07,$07,$12,$00,$12,$00  ; seg  74            pitch=-2                #0:$80@+18 #2:$80@+18
        fcb   $00,$7E,$07,$07,$12,$00,$12,$00  ; seg  75            pitch=-2                #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$07,$05,$12,$00,$EC,$00  ; seg  76  curve=+4                          #0:$80@+18 #2:$8F@-20
        fcb   $04,$00,$07,$06,$12,$00,$E4,$00  ; seg  77  curve=+4                          #0:$80@+18 #2:$90@-28
        fcb   $04,$00,$00,$05,$00,$00,$E8,$00  ; seg  78  curve=+4                          #2:$8F@-24
        fcb   $04,$00,$00,$06,$00,$00,$EC,$00  ; seg  79  curve=+4                          #2:$90@-20
        fcb   $00,$02,$03,$50,$EE,$00,$00,$12  ; seg  80            pitch=+2                #0:$87@-18 #3:$8F@+18
        fcb   $00,$02,$03,$00,$EE,$00,$00,$00  ; seg  81            pitch=+2                #0:$87@-18
        fcb   $00,$02,$03,$00,$EE,$00,$00,$00  ; seg  82            pitch=+2                #0:$87@-18
        fcb   $00,$02,$03,$00,$EE,$00,$00,$00  ; seg  83            pitch=+2                #0:$87@-18
        fcb   $00,$02,$00,$60,$00,$00,$00,$16  ; seg  84            pitch=+2                #3:$90@+22
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg  85            pitch=+2
        fcb   $00,$02,$44,$44,$EE,$EE,$EE,$EE  ; seg  86            pitch=+2                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$02,$44,$44,$EE,$EE,$EE,$EE  ; seg  87            pitch=+2                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  88  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  89  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$50,$EE,$00,$00,$12  ; seg  90  curve=-6                          #0:$81@-18 #3:$8F@+18
        fcb   $7A,$00,$04,$00,$EE,$00,$00,$00  ; seg  91  curve=-6                          #0:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  92  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$16  ; seg  93  curve=-4                          #0:$81@-18 #3:$90@+22
        fcb   $7C,$00,$04,$04,$EE,$00,$EE,$00  ; seg  94  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$04,$EE,$00,$EE,$00  ; seg  95  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$54,$EE,$00,$EE,$12  ; seg  96  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8F@+18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  97  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg  98  curve=-6
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg  99  curve=-6
        fcb   $00,$00,$03,$03,$EA,$00,$12,$00  ; seg 100                                    #0:$87@-22 #2:$87@+18
        fcb   $00,$00,$03,$05,$E8,$00,$16,$00  ; seg 101                                    #0:$87@-24 #2:$8F@+22
        fcb   $00,$00,$05,$03,$E2,$00,$14,$00  ; seg 102                                    #0:$8F@-30 #2:$87@+20
        fcb   $00,$00,$03,$03,$E6,$00,$12,$00  ; seg 103                                    #0:$87@-26 #2:$87@+18
        fcb   $00,$02,$03,$03,$EA,$00,$18,$00  ; seg 104            pitch=+2                #0:$87@-22 #2:$87@+24
        fcb   $00,$02,$05,$05,$EC,$00,$1C,$00  ; seg 105            pitch=+2                #0:$8F@-20 #2:$8F@+28
        fcb   $00,$00,$05,$03,$E8,$00,$1E,$00  ; seg 106                                    #0:$8F@-24 #2:$87@+30
        fcb   $00,$00,$03,$03,$E6,$00,$1A,$00  ; seg 107                                    #0:$87@-26 #2:$87@+26
        fcb   $00,$00,$05,$05,$E2,$00,$1C,$00  ; seg 108                                    #0:$8F@-30 #2:$8F@+28
        fcb   $00,$00,$03,$03,$E4,$00,$12,$00  ; seg 109                                    #0:$87@-28 #2:$87@+18
        fcb   $00,$02,$03,$03,$EE,$00,$1C,$00  ; seg 110            pitch=+2                #0:$87@-18 #2:$87@+28
        fcb   $00,$02,$05,$05,$EC,$00,$1A,$00  ; seg 111            pitch=+2                #0:$8F@-20 #2:$8F@+26
        fcb   $00,$00,$03,$03,$E2,$00,$18,$00  ; seg 112                                    #0:$87@-30 #2:$87@+24
        fcb   $00,$00,$05,$05,$E6,$00,$16,$00  ; seg 113                                    #0:$8F@-26 #2:$8F@+22
        fcb   $00,$00,$03,$05,$EA,$00,$14,$00  ; seg 114                                    #0:$87@-22 #2:$8F@+20
        fcb   $00,$00,$05,$03,$EC,$00,$12,$00  ; seg 115                                    #0:$8F@-20 #2:$87@+18
        fcb   $00,$02,$03,$05,$E2,$00,$1C,$00  ; seg 116            pitch=+2                #0:$87@-30 #2:$8F@+28
        fcb   $00,$02,$03,$03,$E6,$00,$1A,$00  ; seg 117            pitch=+2                #0:$87@-26 #2:$87@+26
        fcb   $00,$00,$05,$03,$E4,$00,$14,$00  ; seg 118                                    #0:$8F@-28 #2:$87@+20
        fcb   $00,$00,$05,$05,$EE,$00,$12,$00  ; seg 119                                    #0:$8F@-18 #2:$8F@+18
        fcb   $00,$7E,$03,$03,$EC,$00,$18,$00  ; seg 120            pitch=-2                #0:$87@-20 #2:$87@+24
        fcb   $00,$7E,$05,$03,$EA,$00,$16,$00  ; seg 121            pitch=-2                #0:$8F@-22 #2:$87@+22
        fcb   $00,$00,$05,$05,$E2,$00,$14,$00  ; seg 122                                    #0:$8F@-30 #2:$8F@+20
        fcb   $00,$00,$03,$03,$EE,$00,$1C,$00  ; seg 123                                    #0:$87@-18 #2:$87@+28
        fcb   $00,$7E,$05,$03,$EA,$00,$12,$00  ; seg 124            pitch=-2                #0:$8F@-22 #2:$87@+18
        fcb   $00,$7E,$03,$03,$EC,$00,$1E,$00  ; seg 125            pitch=-2                #0:$87@-20 #2:$87@+30
        fcb   $00,$00,$05,$05,$EE,$00,$1A,$00  ; seg 126                                    #0:$8F@-18 #2:$8F@+26
        fcb   $00,$00,$03,$03,$E6,$00,$1E,$00  ; seg 127                                    #0:$87@-26 #2:$87@+30
        fcb   $00,$02,$03,$03,$E2,$00,$1C,$00  ; seg 128            pitch=+2                #0:$87@-30 #2:$87@+28
        fcb   $00,$02,$05,$03,$EC,$00,$16,$00  ; seg 129            pitch=+2                #0:$8F@-20 #2:$87@+22
        fcb   $00,$00,$03,$05,$E2,$00,$14,$00  ; seg 130                                    #0:$87@-30 #2:$8F@+20
        fcb   $00,$00,$05,$03,$EA,$00,$12,$00  ; seg 131                                    #0:$8F@-22 #2:$87@+18
        fcb   $00,$00,$03,$05,$EC,$00,$1C,$00  ; seg 132                                    #0:$87@-20 #2:$8F@+28
        fcb   $00,$00,$03,$03,$E6,$00,$12,$00  ; seg 133                                    #0:$87@-26 #2:$87@+18
        fcb   $00,$00,$05,$03,$EE,$00,$1A,$00  ; seg 134                                    #0:$8F@-18 #2:$87@+26
        fcb   $00,$00,$05,$05,$EA,$00,$1C,$00  ; seg 135                                    #0:$8F@-22 #2:$8F@+28
        fcb   $00,$7E,$03,$03,$EA,$00,$12,$00  ; seg 136            pitch=-2                #0:$87@-22 #2:$87@+18
        fcb   $00,$7E,$05,$03,$EC,$00,$1A,$00  ; seg 137            pitch=-2                #0:$8F@-20 #2:$87@+26
        fcb   $00,$7E,$03,$05,$EE,$00,$16,$00  ; seg 138            pitch=-2                #0:$87@-18 #2:$8F@+22
        fcb   $00,$7E,$05,$03,$E8,$00,$18,$00  ; seg 139            pitch=-2                #0:$8F@-24 #2:$87@+24
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 140
        fcb   $00,$00,$00,$50,$00,$00,$00,$20  ; seg 141                                    #3:$8F@+32
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 142                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 143                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 144  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 145  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$50,$00,$00,$00,$20  ; seg 146  curve=-4                          #3:$8F@+32
        fcb   $7C,$00,$00,$60,$00,$00,$00,$20  ; seg 147  curve=-4                          #3:$90@+32
        fcb   $00,$00,$00,$50,$00,$00,$00,$E0  ; seg 148                                    #3:$8F@-32
        fcb   $00,$00,$00,$50,$00,$00,$00,$E0  ; seg 149                                    #3:$8F@-32
        fcb   $00,$01,$04,$64,$EE,$00,$EE,$E0  ; seg 150            pitch=+1                #0:$81@-18 #2:$81@-18 #3:$90@-32
        fcb   $00,$01,$04,$54,$EE,$00,$EE,$20  ; seg 151            pitch=+1                #0:$81@-18 #2:$81@-18 #3:$8F@+32
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$20  ; seg 152  curve=-4                          #0:$81@-18 #3:$90@+32
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 153  curve=-4                          #0:$81@-18
        fcb   $7C,$7F,$00,$60,$00,$00,$00,$E0  ; seg 154  curve=-4  pitch=-1                #3:$90@-32
        fcb   $7C,$7F,$00,$50,$00,$00,$00,$20  ; seg 155  curve=-4  pitch=-1                #3:$8F@+32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 156
        fcb   $00,$00,$00,$50,$00,$00,$00,$E0  ; seg 157                                    #3:$8F@-32
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 158                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg 159                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$03,$EE,$00,$12,$00  ; seg 160  curve=-4                          #0:$81@-18 #2:$87@+18
        fcb   $7C,$00,$04,$03,$EE,$00,$12,$00  ; seg 161  curve=-4                          #0:$81@-18 #2:$87@+18
        fcb   $7C,$01,$00,$03,$00,$00,$12,$00  ; seg 162  curve=-4  pitch=+1                #2:$87@+18
        fcb   $7C,$01,$00,$03,$00,$00,$12,$00  ; seg 163  curve=-4  pitch=+1                #2:$87@+18
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg 164                                    #0:$87@-18 #2:$87@-18
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg 165                                    #0:$87@-18 #2:$87@-18
        fcb   $00,$7F,$03,$03,$EE,$00,$EE,$00  ; seg 166            pitch=-1                #0:$87@-18 #2:$87@-18
        fcb   $00,$7F,$03,$03,$EE,$00,$EE,$00  ; seg 167            pitch=-1                #0:$87@-18 #2:$87@-18
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 168
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 169
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 170
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 171
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 172
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 173
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 174
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 175
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 176                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 177
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 178
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 179
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 180                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 181                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 182                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 183                                    #0:$83@+18 #2:$83@+18

Circuit_22_hard_5_segment_cache
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
        fcb   $EC,$00,$F6,$0A  ; seg  21  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  22  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  23  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  24  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  25  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  26  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  27  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  28  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  29  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  30  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  31  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  32  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  33  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  34  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$FF,$F6,$0A  ; seg  35  yaw= -50 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C8,$FE,$F6,$0A  ; seg  36  yaw= -56 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C2,$FE,$F6,$0A  ; seg  37  yaw= -62 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $BC,$FE,$F6,$0A  ; seg  38  yaw= -68 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B6,$FE,$F6,$0A  ; seg  39  yaw= -74 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg  40  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $AA,$FF,$F6,$0A  ; seg  41  yaw= -86 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg  42  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9E,$00,$F6,$0A  ; seg  43  yaw= -98 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  44  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg  45  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg  46  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg  47  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  48  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg  49  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg  50  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$FF,$F6,$0A  ; seg  51  yaw=-110 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $98,$FE,$F6,$0A  ; seg  52  yaw=-104 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $9E,$FE,$F6,$0A  ; seg  53  yaw= -98 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A4,$FE,$F6,$0A  ; seg  54  yaw= -92 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $AA,$FE,$F6,$0A  ; seg  55  yaw= -86 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg  56  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B6,$FD,$F6,$0A  ; seg  57  yaw= -74 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $BC,$FC,$F6,$0A  ; seg  58  yaw= -68 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C2,$FC,$F6,$0A  ; seg  59  yaw= -62 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C8,$FC,$F6,$0A  ; seg  60  yaw= -56 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $CE,$FD,$F6,$0A  ; seg  61  yaw= -50 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $D4,$FE,$F6,$0A  ; seg  62  yaw= -44 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $DA,$FF,$F6,$0A  ; seg  63  yaw= -38 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  64  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  65  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  66  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  67  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  68  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  69  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  70  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FA,$F6,$0A  ; seg  71  yaw= -32 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $E0,$F8,$F6,$0A  ; seg  72  yaw= -32 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $E0,$F6,$F6,$0A  ; seg  73  yaw= -32 pitch= -10 min_lat= -10 max_lat= +10
        fcb   $E0,$F4,$F6,$0A  ; seg  74  yaw= -32 pitch= -12 min_lat= -10 max_lat= +10
        fcb   $E0,$F2,$F6,$0A  ; seg  75  yaw= -32 pitch= -14 min_lat= -10 max_lat= +10
        fcb   $E0,$F0,$F6,$0A  ; seg  76  yaw= -32 pitch= -16 min_lat= -10 max_lat= +10
        fcb   $E4,$F0,$F6,$0A  ; seg  77  yaw= -28 pitch= -16 min_lat= -10 max_lat= +10
        fcb   $E8,$F0,$F6,$0A  ; seg  78  yaw= -24 pitch= -16 min_lat= -10 max_lat= +10
        fcb   $EC,$F0,$F6,$0A  ; seg  79  yaw= -20 pitch= -16 min_lat= -10 max_lat= +10
        fcb   $F0,$F0,$F6,$0A  ; seg  80  yaw= -16 pitch= -16 min_lat= -10 max_lat= +10
        fcb   $F0,$F2,$F6,$0A  ; seg  81  yaw= -16 pitch= -14 min_lat= -10 max_lat= +10
        fcb   $F0,$F4,$F6,$0A  ; seg  82  yaw= -16 pitch= -12 min_lat= -10 max_lat= +10
        fcb   $F0,$F6,$F6,$0A  ; seg  83  yaw= -16 pitch= -10 min_lat= -10 max_lat= +10
        fcb   $F0,$F8,$F6,$0A  ; seg  84  yaw= -16 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $F0,$FA,$F6,$0A  ; seg  85  yaw= -16 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $F0,$FC,$F6,$0A  ; seg  86  yaw= -16 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $F0,$FE,$F6,$0A  ; seg  87  yaw= -16 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  88  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EA,$00,$F6,$0A  ; seg  89  yaw= -22 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  90  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DE,$00,$F6,$0A  ; seg  91  yaw= -34 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  92  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  93  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  94  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  95  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  96  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg  97  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  98  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg  99  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 100  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 101  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 102  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 103  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 104  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg 105  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 106  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 107  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 108  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 109  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 110  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$06,$F6,$0A  ; seg 111  yaw= -80 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 112  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 113  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 114  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 115  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 116  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$0A,$F6,$0A  ; seg 117  yaw= -80 pitch= +10 min_lat= -10 max_lat= +10
        fcb   $B0,$0C,$F6,$0A  ; seg 118  yaw= -80 pitch= +12 min_lat= -10 max_lat= +10
        fcb   $B0,$0C,$F6,$0A  ; seg 119  yaw= -80 pitch= +12 min_lat= -10 max_lat= +10
        fcb   $B0,$0C,$F6,$0A  ; seg 120  yaw= -80 pitch= +12 min_lat= -10 max_lat= +10
        fcb   $B0,$0A,$F6,$0A  ; seg 121  yaw= -80 pitch= +10 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 122  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 123  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 124  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$06,$F6,$0A  ; seg 125  yaw= -80 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 126  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 127  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 128  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$06,$F6,$0A  ; seg 129  yaw= -80 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 130  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 131  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 132  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 133  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 134  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 135  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 136  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$06,$F6,$0A  ; seg 137  yaw= -80 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 138  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg 139  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 140  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 141  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 142  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 143  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 144  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg 145  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 146  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 147  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 148  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 149  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 150  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$01,$F6,$0A  ; seg 151  yaw= -96 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A0,$02,$F6,$0A  ; seg 152  yaw= -96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $9C,$02,$F6,$0A  ; seg 153  yaw=-100 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $98,$02,$F6,$0A  ; seg 154  yaw=-104 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $94,$01,$F6,$0A  ; seg 155  yaw=-108 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 156  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 157  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 158  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 159  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 160  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 161  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 162  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$01,$F6,$0A  ; seg 163  yaw=-124 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 164  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 165  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 166  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 167  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 168  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 169  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 170  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 171  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 172  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 173  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 174  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 175  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 176 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 177 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 178 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 179 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 180 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 181 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 182 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 183 (wraparound de seg 7)
