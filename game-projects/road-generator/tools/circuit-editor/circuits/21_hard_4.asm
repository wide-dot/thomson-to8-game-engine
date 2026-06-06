* ======================================================================
* Circuit_21_hard_4 — N=112 segments (format compact 8 oct/seg)
* Source       : 21_hard_4.bin (extrait de FILE30)
*
* Pays         : MALAYSIA
* Lieu         : bandar seri begawan
* Description  : many hazards in road
* Hazards      : slow - you have been warned
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
* Taille totale : 1458 oct (nb_segments 2 + LUT 16 + segments 960 + cache 480).
* ======================================================================

Circuit_21_hard_4_nb_segments
        fdb   112

Circuit_21_hard_4_sprite_lut
        fcb   $00,$82,$80,$83,$A7,$8F,$9A,$81,$98,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_21_hard_4_segments
        fcb   $04,$80,$01,$00,$00,$00,$00,$00  ; seg   0  curve=+4            flags=[START] #0:$82@+0
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg   1  curve=+4                          #0:$80@+18
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg   2  curve=+4                          #0:$80@+18
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg   3  curve=+4                          #0:$80@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg   4  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg   5  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg   6  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg   7  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $84,$00,$02,$04,$16,$00,$EE,$00  ; seg   8  curve=+4            flags=[PIT]   #0:$80@+22 #2:$A7@-18
        fcb   $84,$00,$02,$54,$16,$00,$EE,$30  ; seg   9  curve=+4            flags=[PIT]   #0:$80@+22 #2:$A7@-18 #3:$8F@+48
        fcb   $84,$00,$02,$04,$16,$00,$EE,$00  ; seg  10  curve=+4            flags=[PIT]   #0:$80@+22 #2:$A7@-18
        fcb   $84,$00,$02,$04,$16,$00,$EE,$00  ; seg  11  curve=+4            flags=[PIT]   #0:$80@+22 #2:$A7@-18
        fcb   $84,$00,$02,$54,$16,$00,$EE,$14  ; seg  12  curve=+4            flags=[PIT]   #0:$80@+22 #2:$A7@-18 #3:$8F@+20
        fcb   $84,$00,$02,$04,$16,$00,$EE,$00  ; seg  13  curve=+4            flags=[PIT]   #0:$80@+22 #2:$A7@-18
        fcb   $84,$00,$00,$04,$00,$00,$EE,$00  ; seg  14  curve=+4            flags=[PIT]   #2:$A7@-18
        fcb   $84,$00,$00,$04,$00,$00,$EE,$00  ; seg  15  curve=+4            flags=[PIT]   #2:$A7@-18
        fcb   $00,$00,$00,$64,$00,$00,$D4,$0C  ; seg  16                                    #2:$A7@-44 #3:$9A@+12
        fcb   $00,$00,$00,$04,$00,$00,$20,$00  ; seg  17                                    #2:$A7@+32
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  18                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  19                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  20  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  21  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$57,$EE,$00,$EE,$20  ; seg  22  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8F@+32
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  23  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  24  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  25  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$54,$00,$00,$18,$E0  ; seg  26  curve=-6                          #2:$A7@+24 #3:$8F@-32
        fcb   $7A,$00,$00,$04,$00,$00,$20,$00  ; seg  27  curve=-6                          #2:$A7@+32
        fcb   $00,$00,$00,$64,$00,$00,$E0,$F4  ; seg  28                                    #2:$A7@-32 #3:$9A@-12
        fcb   $00,$00,$00,$04,$00,$00,$D8,$00  ; seg  29                                    #2:$A7@-40
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  30                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  31                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  32  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  33  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$54,$00,$00,$CC,$20  ; seg  34  curve=-6                          #2:$A7@-52 #3:$8F@+32
        fcb   $7A,$00,$00,$04,$00,$00,$E4,$00  ; seg  35  curve=-6                          #2:$A7@-28
        fcb   $00,$00,$08,$64,$14,$00,$20,$F8  ; seg  36                                    #0:$98@+20 #2:$A7@+32 #3:$9A@-8
        fcb   $00,$00,$08,$04,$14,$00,$18,$00  ; seg  37                                    #0:$98@+20 #2:$A7@+24
        fcb   $00,$00,$08,$64,$14,$00,$30,$08  ; seg  38                                    #0:$98@+20 #2:$A7@+48 #3:$9A@+8
        fcb   $00,$00,$08,$04,$14,$00,$1C,$00  ; seg  39                                    #0:$98@+20 #2:$A7@+28
        fcb   $00,$01,$08,$04,$EC,$00,$E0,$00  ; seg  40            pitch=+1                #0:$98@-20 #2:$A7@-32
        fcb   $00,$01,$08,$04,$EC,$00,$D0,$00  ; seg  41            pitch=+1                #0:$98@-20 #2:$A7@-48
        fcb   $00,$7F,$08,$64,$EC,$00,$2C,$0C  ; seg  42            pitch=-1                #0:$98@-20 #2:$A7@+44 #3:$9A@+12
        fcb   $00,$7F,$08,$04,$EC,$00,$18,$00  ; seg  43            pitch=-1                #0:$98@-20 #2:$A7@+24
        fcb   $00,$7F,$08,$64,$14,$00,$28,$08  ; seg  44            pitch=-1                #0:$98@+20 #2:$A7@+40 #3:$9A@+8
        fcb   $00,$7F,$08,$04,$14,$00,$E4,$00  ; seg  45            pitch=-1                #0:$98@+20 #2:$A7@-28
        fcb   $00,$01,$08,$04,$14,$00,$DC,$00  ; seg  46            pitch=+1                #0:$98@+20 #2:$A7@-36
        fcb   $00,$01,$08,$04,$14,$00,$30,$00  ; seg  47            pitch=+1                #0:$98@+20 #2:$A7@+48
        fcb   $00,$00,$00,$64,$00,$00,$30,$0C  ; seg  48                                    #2:$A7@+48 #3:$9A@+12
        fcb   $00,$00,$00,$04,$00,$00,$20,$00  ; seg  49                                    #2:$A7@+32
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  50                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  51                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  52  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg  53  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$04,$00,$00,$20,$00  ; seg  54  curve=-6                          #2:$A7@+32
        fcb   $7A,$00,$00,$54,$00,$00,$14,$2C  ; seg  55  curve=-6                          #2:$A7@+20 #3:$8F@+44
        fcb   $00,$00,$00,$64,$00,$00,$E0,$08  ; seg  56                                    #2:$A7@-32 #3:$9A@+8
        fcb   $00,$00,$00,$04,$00,$00,$DC,$00  ; seg  57                                    #2:$A7@-36
        fcb   $00,$00,$07,$67,$EE,$00,$EE,$F8  ; seg  58                                    #0:$81@-18 #2:$81@-18 #3:$9A@-8
        fcb   $00,$00,$07,$07,$EE,$00,$EE,$00  ; seg  59                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$07,$04,$EE,$00,$20,$00  ; seg  60  curve=-4                          #0:$81@-18 #2:$A7@+32
        fcb   $7C,$00,$07,$54,$EE,$00,$38,$20  ; seg  61  curve=-4                          #0:$81@-18 #2:$A7@+56 #3:$8F@+32
        fcb   $7C,$00,$02,$02,$12,$00,$12,$00  ; seg  62  curve=-4                          #0:$80@+18 #2:$80@+18
        fcb   $7C,$00,$02,$52,$12,$00,$12,$E0  ; seg  63  curve=-4                          #0:$80@+18 #2:$80@+18 #3:$8F@-32
        fcb   $04,$00,$02,$64,$12,$00,$E0,$FC  ; seg  64  curve=+4                          #0:$80@+18 #2:$A7@-32 #3:$9A@-4
        fcb   $04,$00,$02,$04,$12,$00,$D0,$00  ; seg  65  curve=+4                          #0:$80@+18 #2:$A7@-48
        fcb   $04,$00,$02,$04,$12,$00,$C8,$00  ; seg  66  curve=+4                          #0:$80@+18 #2:$A7@-56
        fcb   $04,$00,$02,$04,$12,$00,$E4,$00  ; seg  67  curve=+4                          #0:$80@+18 #2:$A7@-28
        fcb   $04,$00,$02,$64,$12,$00,$24,$F4  ; seg  68  curve=+4                          #0:$80@+18 #2:$A7@+36 #3:$9A@-12
        fcb   $04,$00,$02,$04,$12,$00,$2C,$00  ; seg  69  curve=+4                          #0:$80@+18 #2:$A7@+44
        fcb   $04,$00,$07,$57,$EE,$00,$EE,$14  ; seg  70  curve=+4                          #0:$81@-18 #2:$81@-18 #3:$8F@+20
        fcb   $04,$00,$07,$57,$EE,$00,$EE,$1C  ; seg  71  curve=+4                          #0:$81@-18 #2:$81@-18 #3:$8F@+28
        fcb   $7C,$00,$07,$64,$EE,$00,$20,$F8  ; seg  72  curve=-4                          #0:$81@-18 #2:$A7@+32 #3:$9A@-8
        fcb   $7C,$00,$07,$04,$EE,$00,$14,$00  ; seg  73  curve=-4                          #0:$81@-18 #2:$A7@+20
        fcb   $7C,$00,$07,$04,$EE,$00,$D0,$00  ; seg  74  curve=-4                          #0:$81@-18 #2:$A7@-48
        fcb   $7C,$00,$07,$04,$EE,$00,$2C,$00  ; seg  75  curve=-4                          #0:$81@-18 #2:$A7@+44
        fcb   $7C,$00,$07,$64,$EE,$00,$30,$0C  ; seg  76  curve=-4                          #0:$81@-18 #2:$A7@+48 #3:$9A@+12
        fcb   $7C,$00,$07,$04,$EE,$00,$D8,$00  ; seg  77  curve=-4                          #0:$81@-18 #2:$A7@-40
        fcb   $7C,$00,$07,$04,$EE,$00,$24,$00  ; seg  78  curve=-4                          #0:$81@-18 #2:$A7@+36
        fcb   $7C,$00,$07,$54,$EE,$00,$1C,$30  ; seg  79  curve=-4                          #0:$81@-18 #2:$A7@+28 #3:$8F@+48
        fcb   $7C,$00,$07,$64,$EE,$00,$20,$08  ; seg  80  curve=-4                          #0:$81@-18 #2:$A7@+32 #3:$9A@+8
        fcb   $7C,$00,$07,$04,$EE,$00,$28,$00  ; seg  81  curve=-4                          #0:$81@-18 #2:$A7@+40
        fcb   $7C,$00,$00,$04,$00,$00,$30,$00  ; seg  82  curve=-4                          #2:$A7@+48
        fcb   $7C,$00,$00,$54,$00,$00,$1C,$EC  ; seg  83  curve=-4                          #2:$A7@+28 #3:$8F@-20
        fcb   $00,$00,$08,$64,$14,$00,$E0,$04  ; seg  84                                    #0:$98@+20 #2:$A7@-32 #3:$9A@+4
        fcb   $00,$00,$08,$04,$14,$00,$20,$00  ; seg  85                                    #0:$98@+20 #2:$A7@+32
        fcb   $00,$7E,$08,$04,$14,$00,$D0,$00  ; seg  86            pitch=-2                #0:$98@+20 #2:$A7@-48
        fcb   $00,$7E,$08,$04,$14,$00,$C8,$00  ; seg  87            pitch=-2                #0:$98@+20 #2:$A7@-56
        fcb   $00,$7E,$08,$64,$EC,$00,$20,$F8  ; seg  88            pitch=-2                #0:$98@-20 #2:$A7@+32 #3:$9A@-8
        fcb   $00,$02,$08,$04,$EC,$00,$18,$00  ; seg  89            pitch=+2                #0:$98@-20 #2:$A7@+24
        fcb   $00,$02,$08,$64,$EC,$00,$20,$F4  ; seg  90            pitch=+2                #0:$98@-20 #2:$A7@+32 #3:$9A@-12
        fcb   $00,$02,$08,$04,$EC,$00,$1C,$00  ; seg  91            pitch=+2                #0:$98@-20 #2:$A7@+28
        fcb   $00,$02,$08,$64,$14,$00,$30,$FC  ; seg  92            pitch=+2                #0:$98@+20 #2:$A7@+48 #3:$9A@-4
        fcb   $00,$02,$08,$04,$14,$00,$28,$00  ; seg  93            pitch=+2                #0:$98@+20 #2:$A7@+40
        fcb   $00,$02,$08,$64,$14,$00,$E0,$F8  ; seg  94            pitch=+2                #0:$98@+20 #2:$A7@-32 #3:$9A@-8
        fcb   $00,$7E,$08,$04,$14,$00,$D4,$00  ; seg  95            pitch=-2                #0:$98@+20 #2:$A7@-44
        fcb   $00,$7E,$00,$64,$00,$00,$CC,$08  ; seg  96            pitch=-2                #2:$A7@-52 #3:$9A@+8
        fcb   $00,$7E,$00,$04,$00,$00,$20,$00  ; seg  97            pitch=-2                #2:$A7@+32
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  98                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$77,$77,$EE,$EE,$EE,$EE  ; seg  99                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg 100  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg 101  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$54,$EE,$00,$20,$14  ; seg 102  curve=-6                          #0:$81@-18 #2:$A7@+32 #3:$8F@+20
        fcb   $7A,$00,$07,$54,$EE,$00,$14,$28  ; seg 103  curve=-6                          #0:$81@-18 #2:$A7@+20 #3:$8F@+40
        fcb   $7C,$00,$07,$00,$EE,$00,$00,$00  ; seg 104  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$07,$00,$EE,$00,$00,$00  ; seg 105  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$07,$07,$EE,$00,$EE,$00  ; seg 106  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$07,$07,$EE,$00,$EE,$00  ; seg 107  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg 108  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$07,$07,$EE,$00,$EE,$00  ; seg 109  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$02,$02,$12,$00,$12,$00  ; seg 110  curve=-6                          #0:$80@+18 #2:$80@+18
        fcb   $7A,$00,$02,$02,$12,$00,$12,$00  ; seg 111  curve=-6                          #0:$80@+18 #2:$80@+18
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $04,$00,$01,$00,$00,$00,$00,$00  ; seg 112  curve=+4                          #0:$82@+0
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg 113  curve=+4                          #0:$80@+18
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg 114  curve=+4                          #0:$80@+18
        fcb   $04,$00,$02,$00,$12,$00,$00,$00  ; seg 115  curve=+4                          #0:$80@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg 116  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg 117  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg 118  curve=+4                          #0:$83@+18 #2:$83@+18
        fcb   $04,$00,$03,$03,$12,$00,$12,$00  ; seg 119  curve=+4                          #0:$83@+18 #2:$83@+18

Circuit_21_hard_4_segment_cache
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
        fcb   $2C,$00,$F6,$09  ; seg  11  yaw= +44 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $30,$00,$F6,$08  ; seg  12  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $34,$00,$F6,$07  ; seg  13  yaw= +52 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $38,$00,$F6,$06  ; seg  14  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $3C,$00,$F6,$05  ; seg  15  yaw= +60 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $40,$00,$F6,$04  ; seg  16  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $40,$00,$F6,$0A  ; seg  17  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  18  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  19  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  20  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3A,$00,$F6,$0A  ; seg  21  yaw= +58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  22  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2E,$00,$F7,$0A  ; seg  23  yaw= +46 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $28,$00,$F8,$0A  ; seg  24  yaw= +40 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $22,$00,$F9,$0A  ; seg  25  yaw= +34 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $1C,$00,$FA,$0A  ; seg  26  yaw= +28 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $16,$00,$FB,$0A  ; seg  27  yaw= +22 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $10,$00,$FC,$0A  ; seg  28  yaw= +16 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $10,$00,$F9,$09  ; seg  29  yaw= +16 pitch=  +0 min_lat=  -7 max_lat=  +9
        fcb   $10,$00,$FA,$08  ; seg  30  yaw= +16 pitch=  +0 min_lat=  -6 max_lat=  +8
        fcb   $10,$00,$FB,$07  ; seg  31  yaw= +16 pitch=  +0 min_lat=  -5 max_lat=  +7
        fcb   $10,$00,$FC,$06  ; seg  32  yaw= +16 pitch=  +0 min_lat=  -4 max_lat=  +6
        fcb   $0A,$00,$FD,$05  ; seg  33  yaw= +10 pitch=  +0 min_lat=  -3 max_lat=  +5
        fcb   $04,$00,$FE,$04  ; seg  34  yaw=  +4 pitch=  +0 min_lat=  -2 max_lat=  +4
        fcb   $FE,$00,$FF,$03  ; seg  35  yaw=  -2 pitch=  +0 min_lat=  -1 max_lat=  +3
        fcb   $F8,$00,$00,$02  ; seg  36  yaw=  -8 pitch=  +0 min_lat=  +0 max_lat=  +2
        fcb   $F8,$00,$F6,$01  ; seg  37  yaw=  -8 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $F8,$00,$F6,$00  ; seg  38  yaw=  -8 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $F8,$00,$F6,$05  ; seg  39  yaw=  -8 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $F8,$00,$F6,$04  ; seg  40  yaw=  -8 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $F8,$01,$F6,$03  ; seg  41  yaw=  -8 pitch=  +1 min_lat= -10 max_lat=  +3
        fcb   $F8,$02,$F6,$02  ; seg  42  yaw=  -8 pitch=  +2 min_lat= -10 max_lat=  +2
        fcb   $F8,$01,$F6,$01  ; seg  43  yaw=  -8 pitch=  +1 min_lat= -10 max_lat=  +1
        fcb   $F8,$00,$F6,$00  ; seg  44  yaw=  -8 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $F8,$FF,$F6,$07  ; seg  45  yaw=  -8 pitch=  -1 min_lat= -10 max_lat=  +7
        fcb   $F8,$FE,$F6,$06  ; seg  46  yaw=  -8 pitch=  -2 min_lat= -10 max_lat=  +6
        fcb   $F8,$FF,$F6,$05  ; seg  47  yaw=  -8 pitch=  -1 min_lat= -10 max_lat=  +5
        fcb   $F8,$00,$F6,$04  ; seg  48  yaw=  -8 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $F8,$00,$F7,$07  ; seg  49  yaw=  -8 pitch=  +0 min_lat=  -9 max_lat=  +7
        fcb   $F8,$00,$F8,$06  ; seg  50  yaw=  -8 pitch=  +0 min_lat=  -8 max_lat=  +6
        fcb   $F8,$00,$F9,$05  ; seg  51  yaw=  -8 pitch=  +0 min_lat=  -7 max_lat=  +5
        fcb   $F8,$00,$FA,$04  ; seg  52  yaw=  -8 pitch=  +0 min_lat=  -6 max_lat=  +4
        fcb   $F2,$00,$FB,$03  ; seg  53  yaw= -14 pitch=  +0 min_lat=  -5 max_lat=  +3
        fcb   $EC,$00,$FC,$02  ; seg  54  yaw= -20 pitch=  +0 min_lat=  -4 max_lat=  +2
        fcb   $E6,$00,$FD,$01  ; seg  55  yaw= -26 pitch=  +0 min_lat=  -3 max_lat=  +1
        fcb   $E0,$00,$FE,$00  ; seg  56  yaw= -32 pitch=  +0 min_lat=  -2 max_lat=  +0
        fcb   $E0,$00,$FF,$0A  ; seg  57  yaw= -32 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $E0,$00,$00,$0A  ; seg  58  yaw= -32 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $E0,$00,$FF,$0A  ; seg  59  yaw= -32 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $E0,$00,$00,$0A  ; seg  60  yaw= -32 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $DC,$00,$01,$0A  ; seg  61  yaw= -36 pitch=  +0 min_lat=  +1 max_lat= +10
        fcb   $D8,$00,$02,$0A  ; seg  62  yaw= -40 pitch=  +0 min_lat=  +2 max_lat= +10
        fcb   $D4,$00,$03,$0A  ; seg  63  yaw= -44 pitch=  +0 min_lat=  +3 max_lat= +10
        fcb   $D0,$00,$04,$0A  ; seg  64  yaw= -48 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $D4,$00,$F9,$0A  ; seg  65  yaw= -44 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $D8,$00,$FA,$0A  ; seg  66  yaw= -40 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $DC,$00,$FB,$0A  ; seg  67  yaw= -36 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $E0,$00,$FC,$0A  ; seg  68  yaw= -32 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $E4,$00,$FD,$0A  ; seg  69  yaw= -28 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $E8,$00,$FE,$0A  ; seg  70  yaw= -24 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $EC,$00,$FF,$09  ; seg  71  yaw= -20 pitch=  +0 min_lat=  -1 max_lat=  +9
        fcb   $F0,$00,$00,$08  ; seg  72  yaw= -16 pitch=  +0 min_lat=  +0 max_lat=  +8
        fcb   $EC,$00,$F6,$07  ; seg  73  yaw= -20 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $E8,$00,$F6,$06  ; seg  74  yaw= -24 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $E4,$00,$F6,$05  ; seg  75  yaw= -28 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $E0,$00,$F6,$04  ; seg  76  yaw= -32 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $DC,$00,$F6,$03  ; seg  77  yaw= -36 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $D8,$00,$F6,$02  ; seg  78  yaw= -40 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $D4,$00,$F7,$01  ; seg  79  yaw= -44 pitch=  +0 min_lat=  -9 max_lat=  +1
        fcb   $D0,$00,$F8,$00  ; seg  80  yaw= -48 pitch=  +0 min_lat=  -8 max_lat=  +0
        fcb   $CC,$00,$F9,$FF  ; seg  81  yaw= -52 pitch=  +0 min_lat=  -7 max_lat=  -1
        fcb   $C8,$00,$FA,$FE  ; seg  82  yaw= -56 pitch=  +0 min_lat=  -6 max_lat=  -2
        fcb   $C4,$00,$FB,$FD  ; seg  83  yaw= -60 pitch=  +0 min_lat=  -5 max_lat=  -3
        fcb   $C0,$00,$FC,$FC  ; seg  84  yaw= -64 pitch=  +0 min_lat=  -4 max_lat=  -4
        fcb   $C0,$00,$FD,$0A  ; seg  85  yaw= -64 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $C0,$00,$FE,$0A  ; seg  86  yaw= -64 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $C0,$FE,$FF,$09  ; seg  87  yaw= -64 pitch=  -2 min_lat=  -1 max_lat=  +9
        fcb   $C0,$FC,$00,$08  ; seg  88  yaw= -64 pitch=  -4 min_lat=  +0 max_lat=  +8
        fcb   $C0,$FA,$01,$07  ; seg  89  yaw= -64 pitch=  -6 min_lat=  +1 max_lat=  +7
        fcb   $C0,$FC,$02,$06  ; seg  90  yaw= -64 pitch=  -4 min_lat=  +2 max_lat=  +6
        fcb   $C0,$FE,$03,$05  ; seg  91  yaw= -64 pitch=  -2 min_lat=  +3 max_lat=  +5
        fcb   $C0,$00,$04,$04  ; seg  92  yaw= -64 pitch=  +0 min_lat=  +4 max_lat=  +4
        fcb   $C0,$02,$FF,$03  ; seg  93  yaw= -64 pitch=  +2 min_lat=  -1 max_lat=  +3
        fcb   $C0,$04,$00,$02  ; seg  94  yaw= -64 pitch=  +4 min_lat=  +0 max_lat=  +2
        fcb   $C0,$06,$F6,$01  ; seg  95  yaw= -64 pitch=  +6 min_lat= -10 max_lat=  +1
        fcb   $C0,$04,$F6,$00  ; seg  96  yaw= -64 pitch=  +4 min_lat= -10 max_lat=  +0
        fcb   $C0,$02,$F6,$0A  ; seg  97  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  98  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  99  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 100  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg 101  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 102  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$0A  ; seg 103  yaw= -82 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 104  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 105  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 106  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg 107  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 108  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg 109  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 110  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg 111  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 112 (wraparound de seg 0)
        fcb   $04,$00,$F6,$0A  ; seg 113 (wraparound de seg 1)
        fcb   $08,$00,$F6,$0A  ; seg 114 (wraparound de seg 2)
        fcb   $0C,$00,$F6,$0A  ; seg 115 (wraparound de seg 3)
        fcb   $10,$00,$F6,$0A  ; seg 116 (wraparound de seg 4)
        fcb   $14,$00,$F6,$0A  ; seg 117 (wraparound de seg 5)
        fcb   $18,$00,$F6,$0A  ; seg 118 (wraparound de seg 6)
        fcb   $1C,$00,$F6,$0A  ; seg 119 (wraparound de seg 7)
