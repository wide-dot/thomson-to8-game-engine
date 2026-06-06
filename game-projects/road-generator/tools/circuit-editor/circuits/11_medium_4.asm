* ======================================================================
* Circuit_11_medium_4 — N=136 segments (format compact 8 oct/seg)
* Source       : 11_medium_4.bin (extrait de FILE30)
*
* Pays         : MOROCCO
* Lieu         : tazenahkt
* Description  : bumpy winding road
* Hazards      : no hazards
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
* Taille totale : 1746 oct (nb_segments 2 + LUT 16 + segments 1152 + cache 576).
* ======================================================================

Circuit_11_medium_4_nb_segments
        fdb   136

Circuit_11_medium_4_sprite_lut
        fcb   $00,$82,$9C,$83,$81,$99,$8C,$8B,$A3,$80,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_11_medium_4_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$20,$00,$00,$EE,$00,$00  ; seg   2                                    #1:$9C@-18
        fcb   $00,$00,$20,$00,$00,$EE,$00,$00  ; seg   3                                    #1:$9C@-18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$23,$03,$12,$EE,$12,$00  ; seg   5                                    #0:$83@+18 #1:$9C@-18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$23,$03,$12,$EE,$12,$00  ; seg   7                                    #0:$83@+18 #1:$9C@-18 #2:$83@+18
        fcb   $80,$00,$20,$00,$00,$EE,$00,$00  ; seg   8                      flags=[PIT]   #1:$9C@-18
        fcb   $80,$00,$20,$00,$00,$EE,$00,$00  ; seg   9                      flags=[PIT]   #1:$9C@-18
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  10                      flags=[PIT]
        fcb   $80,$00,$20,$00,$00,$EE,$00,$00  ; seg  11                      flags=[PIT]   #1:$9C@-18
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  12                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  13                      flags=[PIT]
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  14                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  15                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  16  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  17  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$05,$00,$00,$20,$00  ; seg  18  curve=-4                          #2:$99@+32
        fcb   $7C,$00,$00,$05,$00,$00,$14,$00  ; seg  19  curve=-4                          #2:$99@+20
        fcb   $00,$01,$00,$65,$00,$00,$E0,$20  ; seg  20            pitch=+1                #2:$99@-32 #3:$8C@+32
        fcb   $00,$01,$00,$70,$00,$00,$00,$1C  ; seg  21            pitch=+1                #3:$8B@+28
        fcb   $00,$7F,$04,$74,$EE,$00,$EE,$30  ; seg  22            pitch=-1                #0:$81@-18 #2:$81@-18 #3:$8B@+48
        fcb   $00,$7F,$04,$04,$EE,$00,$EE,$00  ; seg  23            pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$65,$EE,$00,$18,$D8  ; seg  24  curve=-4                          #0:$81@-18 #2:$99@+24 #3:$8C@-40
        fcb   $7C,$00,$04,$05,$EE,$00,$1E,$00  ; seg  25  curve=-4                          #0:$81@-18 #2:$99@+30
        fcb   $7C,$00,$00,$60,$00,$00,$00,$E0  ; seg  26  curve=-4                          #3:$8C@-32
        fcb   $7C,$00,$00,$70,$00,$00,$00,$EC  ; seg  27  curve=-4                          #3:$8B@-20
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  28            pitch=-1
        fcb   $00,$7F,$00,$60,$00,$00,$00,$20  ; seg  29            pitch=-1                #3:$8C@+32
        fcb   $00,$01,$44,$44,$EE,$EE,$EE,$EE  ; seg  30            pitch=+1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$01,$44,$44,$EE,$EE,$EE,$EE  ; seg  31            pitch=+1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$64,$EE,$00,$EE,$20  ; seg  32  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8C@+32
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  33  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$84,$84,$EE,$20,$EE,$20  ; seg  34  curve=-6                          #0:$81@-18 #1:$A3@+32 #2:$81@-18 #3:$A3@+32
        fcb   $7A,$00,$84,$84,$EE,$14,$EE,$14  ; seg  35  curve=-6                          #0:$81@-18 #1:$A3@+20 #2:$81@-18 #3:$A3@+20
        fcb   $7A,$00,$84,$84,$EE,$E0,$EE,$24  ; seg  36  curve=-6                          #0:$81@-18 #1:$A3@-32 #2:$81@-18 #3:$A3@+36
        fcb   $7A,$00,$84,$84,$EE,$D8,$EE,$D0  ; seg  37  curve=-6                          #0:$81@-18 #1:$A3@-40 #2:$81@-18 #3:$A3@-48
        fcb   $7A,$00,$99,$99,$12,$12,$12,$12  ; seg  38  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$99,$99,$12,$12,$12,$12  ; seg  39  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$89,$09,$12,$DC,$12,$00  ; seg  40  curve=+6                          #0:$80@+18 #1:$A3@-36 #2:$80@+18
        fcb   $06,$00,$89,$89,$12,$24,$12,$20  ; seg  41  curve=+6                          #0:$80@+18 #1:$A3@+36 #2:$80@+18 #3:$A3@+32
        fcb   $06,$00,$79,$89,$12,$D8,$12,$DC  ; seg  42  curve=+6                          #0:$80@+18 #1:$8B@-40 #2:$80@+18 #3:$A3@-36
        fcb   $06,$00,$89,$89,$12,$E0,$12,$24  ; seg  43  curve=+6                          #0:$80@+18 #1:$A3@-32 #2:$80@+18 #3:$A3@+36
        fcb   $06,$00,$89,$69,$12,$28,$12,$E0  ; seg  44  curve=+6                          #0:$80@+18 #1:$A3@+40 #2:$80@+18 #3:$8C@-32
        fcb   $06,$00,$89,$89,$12,$C8,$12,$D4  ; seg  45  curve=+6                          #0:$80@+18 #1:$A3@-56 #2:$80@+18 #3:$A3@-44
        fcb   $06,$00,$80,$80,$00,$24,$00,$EC  ; seg  46  curve=+6                          #1:$A3@+36 #3:$A3@-20
        fcb   $06,$00,$80,$80,$00,$EC,$00,$30  ; seg  47  curve=+6                          #1:$A3@-20 #3:$A3@+48
        fcb   $00,$00,$60,$70,$00,$18,$00,$18  ; seg  48                                    #1:$8C@+24 #3:$8B@+24
        fcb   $00,$00,$80,$80,$00,$24,$00,$20  ; seg  49                                    #1:$A3@+36 #3:$A3@+32
        fcb   $00,$00,$80,$60,$00,$C8,$00,$1C  ; seg  50                                    #1:$A3@-56 #3:$8C@+28
        fcb   $00,$00,$80,$80,$00,$DC,$00,$E0  ; seg  51                                    #1:$A3@-36 #3:$A3@-32
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  52            pitch=-1
        fcb   $00,$7F,$00,$60,$00,$00,$00,$14  ; seg  53            pitch=-1                #3:$8C@+20
        fcb   $00,$7F,$04,$74,$EE,$00,$EE,$1C  ; seg  54            pitch=-1                #0:$81@-18 #2:$81@-18 #3:$8B@+28
        fcb   $00,$7F,$04,$04,$EE,$00,$EE,$00  ; seg  55            pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$20  ; seg  56  curve=-4                          #0:$81@-18 #3:$8C@+32
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  57  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$14  ; seg  58  curve=-4                          #0:$81@-18 #3:$8C@+20
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  59  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$75,$EE,$00,$1C,$18  ; seg  60  curve=-4                          #0:$81@-18 #2:$99@+28 #3:$8B@+24
        fcb   $7C,$00,$04,$65,$EE,$00,$28,$20  ; seg  61  curve=-4                          #0:$81@-18 #2:$99@+40 #3:$8C@+32
        fcb   $7C,$00,$04,$05,$EE,$00,$14,$00  ; seg  62  curve=-4                          #0:$81@-18 #2:$99@+20
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$DC  ; seg  63  curve=-4                          #0:$81@-18 #3:$8C@-36
        fcb   $7C,$01,$04,$05,$EE,$00,$28,$00  ; seg  64  curve=-4  pitch=+1                #0:$81@-18 #2:$99@+40
        fcb   $7C,$01,$04,$75,$EE,$00,$3C,$20  ; seg  65  curve=-4  pitch=+1                #0:$81@-18 #2:$99@+60 #3:$8B@+32
        fcb   $7C,$01,$00,$60,$00,$00,$00,$C8  ; seg  66  curve=-4  pitch=+1                #3:$8C@-56
        fcb   $7C,$01,$00,$05,$00,$00,$20,$00  ; seg  67  curve=-4  pitch=+1                #2:$99@+32
        fcb   $00,$00,$05,$65,$EC,$00,$14,$20  ; seg  68                                    #0:$99@-20 #2:$99@+20 #3:$8C@+32
        fcb   $00,$00,$05,$75,$EC,$00,$1C,$14  ; seg  69                                    #0:$99@-20 #2:$99@+28 #3:$8B@+20
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  70            pitch=-1
        fcb   $00,$7F,$05,$65,$EC,$00,$20,$30  ; seg  71            pitch=-1                #0:$99@-20 #2:$99@+32 #3:$8C@+48
        fcb   $00,$7F,$05,$60,$EC,$00,$00,$D0  ; seg  72            pitch=-1                #0:$99@-20 #3:$8C@-48
        fcb   $00,$7F,$05,$05,$EC,$00,$E4,$00  ; seg  73            pitch=-1                #0:$99@-20 #2:$99@-28
        fcb   $00,$01,$05,$75,$EC,$00,$1C,$20  ; seg  74            pitch=+1                #0:$99@-20 #2:$99@+28 #3:$8B@+32
        fcb   $00,$01,$05,$60,$EC,$00,$00,$14  ; seg  75            pitch=+1                #0:$99@-20 #3:$8C@+20
        fcb   $00,$01,$00,$05,$00,$00,$20,$00  ; seg  76            pitch=+1                #2:$99@+32
        fcb   $00,$01,$00,$60,$00,$00,$00,$E0  ; seg  77            pitch=+1                #3:$8C@-32
        fcb   $00,$00,$99,$99,$12,$12,$12,$12  ; seg  78                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$99,$99,$12,$12,$12,$12  ; seg  79                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$09,$09,$12,$00,$12,$00  ; seg  80  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$09,$79,$12,$00,$12,$20  ; seg  81  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8B@+32
        fcb   $06,$00,$09,$69,$12,$00,$12,$E4  ; seg  82  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8C@-28
        fcb   $06,$00,$09,$69,$12,$00,$12,$30  ; seg  83  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8C@+48
        fcb   $06,$00,$09,$79,$12,$00,$12,$E0  ; seg  84  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8B@-32
        fcb   $06,$00,$09,$09,$12,$00,$12,$00  ; seg  85  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  86  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $06,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  87  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  88  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$64,$EE,$00,$EE,$14  ; seg  89  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8C@+20
        fcb   $7A,$00,$04,$64,$EE,$00,$EE,$18  ; seg  90  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8C@+24
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  91  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$74,$EE,$00,$EE,$20  ; seg  92  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8B@+32
        fcb   $7A,$00,$04,$64,$EE,$00,$EE,$1C  ; seg  93  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8C@+28
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg  94  curve=-6
        fcb   $7A,$00,$00,$05,$00,$00,$EC,$00  ; seg  95  curve=-6                          #2:$99@-20
        fcb   $00,$00,$00,$05,$00,$00,$E4,$00  ; seg  96                                    #2:$99@-28
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  97
        fcb   $00,$01,$04,$04,$EE,$00,$EE,$00  ; seg  98            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $00,$01,$04,$04,$EE,$00,$EE,$00  ; seg  99            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 100  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$05,$EE,$00,$20,$00  ; seg 101  curve=-4                          #0:$81@-18 #2:$99@+32
        fcb   $7C,$00,$00,$05,$00,$00,$14,$00  ; seg 102  curve=-4                          #2:$99@+20
        fcb   $7C,$00,$00,$05,$00,$00,$28,$00  ; seg 103  curve=-4                          #2:$99@+40
        fcb   $00,$7F,$02,$00,$EC,$00,$00,$00  ; seg 104            pitch=-1                #0:$9C@-20
        fcb   $00,$7F,$02,$05,$EC,$00,$E0,$00  ; seg 105            pitch=-1                #0:$9C@-20 #2:$99@-32
        fcb   $00,$00,$02,$05,$EC,$00,$D8,$00  ; seg 106                                    #0:$9C@-20 #2:$99@-40
        fcb   $00,$00,$02,$00,$EC,$00,$00,$00  ; seg 107                                    #0:$9C@-20
        fcb   $00,$00,$00,$05,$00,$00,$CC,$00  ; seg 108                                    #2:$99@-52
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 109
        fcb   $00,$01,$04,$04,$EE,$00,$EE,$00  ; seg 110            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $00,$01,$04,$04,$EE,$00,$EE,$00  ; seg 111            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 112  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$05,$EE,$00,$20,$00  ; seg 113  curve=-4                          #0:$81@-18 #2:$99@+32
        fcb   $7C,$00,$04,$05,$EE,$00,$14,$00  ; seg 114  curve=-4                          #0:$81@-18 #2:$99@+20
        fcb   $7C,$00,$04,$05,$EE,$00,$30,$00  ; seg 115  curve=-4                          #0:$81@-18 #2:$99@+48
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg 116  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$05,$EE,$00,$D8,$00  ; seg 117  curve=-4                          #0:$81@-18 #2:$99@-40
        fcb   $7C,$00,$00,$05,$00,$00,$CC,$00  ; seg 118  curve=-4                          #2:$99@-52
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 119  curve=-4
        fcb   $00,$7F,$02,$05,$14,$00,$D8,$00  ; seg 120            pitch=-1                #0:$9C@+20 #2:$99@-40
        fcb   $00,$7F,$02,$05,$14,$00,$E0,$00  ; seg 121            pitch=-1                #0:$9C@+20 #2:$99@-32
        fcb   $00,$00,$02,$05,$14,$00,$D8,$00  ; seg 122                                    #0:$9C@+20 #2:$99@-40
        fcb   $00,$00,$02,$05,$14,$00,$CC,$00  ; seg 123                                    #0:$9C@+20 #2:$99@-52
        fcb   $00,$7F,$02,$05,$14,$00,$D4,$00  ; seg 124            pitch=-1                #0:$9C@+20 #2:$99@-44
        fcb   $00,$7F,$02,$00,$14,$00,$00,$00  ; seg 125            pitch=-1                #0:$9C@+20
        fcb   $00,$01,$00,$05,$00,$00,$20,$00  ; seg 126            pitch=+1                #2:$99@+32
        fcb   $00,$01,$00,$05,$00,$00,$14,$00  ; seg 127            pitch=+1                #2:$99@+20
        fcb   $00,$00,$02,$00,$EC,$00,$00,$00  ; seg 128                                    #0:$9C@-20
        fcb   $00,$00,$02,$00,$EC,$00,$00,$00  ; seg 129                                    #0:$9C@-20
        fcb   $00,$00,$02,$00,$EC,$00,$00,$00  ; seg 130                                    #0:$9C@-20
        fcb   $00,$00,$02,$00,$EC,$00,$00,$00  ; seg 131                                    #0:$9C@-20
        fcb   $00,$00,$02,$00,$EC,$00,$00,$00  ; seg 132                                    #0:$9C@-20
        fcb   $00,$00,$02,$00,$EC,$00,$00,$00  ; seg 133                                    #0:$9C@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 134
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 135
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 136                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 137
        fcb   $00,$00,$20,$00,$00,$EE,$00,$00  ; seg 138                                    #1:$9C@-18
        fcb   $00,$00,$20,$00,$00,$EE,$00,$00  ; seg 139                                    #1:$9C@-18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg 140                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$23,$03,$12,$EE,$12,$00  ; seg 141                                    #0:$83@+18 #1:$9C@-18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg 142                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$23,$03,$12,$EE,$12,$00  ; seg 143                                    #0:$83@+18 #1:$9C@-18 #2:$83@+18

Circuit_11_medium_4_segment_cache
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
        fcb   $F0,$01,$F6,$0A  ; seg  23  yaw= -16 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  24  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  25  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  26  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  27  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  28  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  29  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  30  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  31  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  32  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  33  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  34  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$00,$F6,$0A  ; seg  35  yaw= -50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  36  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg  37  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  38  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg  39  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  40  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg  41  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  42  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg  43  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  44  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$00,$F6,$0A  ; seg  45  yaw= -50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  46  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  47  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  48  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  49  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  50  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  51  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  52  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  53  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  54  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FD,$F6,$0A  ; seg  55  yaw= -32 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  56  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $DC,$FC,$F6,$0A  ; seg  57  yaw= -36 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $D8,$FC,$F6,$0A  ; seg  58  yaw= -40 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $D4,$FC,$F6,$0A  ; seg  59  yaw= -44 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $D0,$FC,$F6,$0A  ; seg  60  yaw= -48 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $CC,$FC,$F6,$0A  ; seg  61  yaw= -52 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C8,$FC,$F6,$0A  ; seg  62  yaw= -56 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C4,$FC,$F6,$0A  ; seg  63  yaw= -60 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C0,$FC,$F6,$0A  ; seg  64  yaw= -64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $BC,$FD,$F6,$0A  ; seg  65  yaw= -68 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $B8,$FE,$F6,$0A  ; seg  66  yaw= -72 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B4,$FF,$F6,$0A  ; seg  67  yaw= -76 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  68  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  69  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  70  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$FF,$F6,$0A  ; seg  71  yaw= -80 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg  72  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$FD,$F6,$0A  ; seg  73  yaw= -80 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $B0,$FC,$F6,$0A  ; seg  74  yaw= -80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $B0,$FD,$F6,$0A  ; seg  75  yaw= -80 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg  76  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$FF,$F6,$0A  ; seg  77  yaw= -80 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  78  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  79  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  80  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg  81  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  82  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg  83  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  84  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$00,$F6,$0A  ; seg  85  yaw= -50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  86  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  87  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  88  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  89  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  90  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$00,$F6,$0A  ; seg  91  yaw= -50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  92  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg  93  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  94  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg  95  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  96  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  97  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  98  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$01,$F6,$0A  ; seg  99  yaw= -80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg 100  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $AC,$02,$F6,$0A  ; seg 101  yaw= -84 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg 102  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A4,$02,$F6,$0A  ; seg 103  yaw= -92 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A0,$02,$F6,$0A  ; seg 104  yaw= -96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A0,$01,$F6,$0A  ; seg 105  yaw= -96 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 106  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 107  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 108  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 109  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 110  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$01,$F6,$0A  ; seg 111  yaw= -96 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A0,$02,$F6,$0A  ; seg 112  yaw= -96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $9C,$02,$F6,$0A  ; seg 113  yaw=-100 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $98,$02,$F6,$0A  ; seg 114  yaw=-104 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $94,$02,$F6,$0A  ; seg 115  yaw=-108 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $90,$02,$F6,$0A  ; seg 116  yaw=-112 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $8C,$02,$F6,$0A  ; seg 117  yaw=-116 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $88,$02,$F6,$0A  ; seg 118  yaw=-120 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $84,$02,$F6,$0A  ; seg 119  yaw=-124 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 120  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 121  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 122  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 123  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 124  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 125  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 126  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 127  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 128  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 129  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 130  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 131  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 132  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 133  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 134  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 135  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 136 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 137 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 138 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 139 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 140 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 141 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 142 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 143 (wraparound de seg 7)
