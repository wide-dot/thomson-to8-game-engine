* ======================================================================
* Circuit_05_easy_5 — N=154 segments (format compact 8 oct/seg)
* Source       : 05_easy_5.bin (extrait de FILE30)
*
* Pays         : SWEDEN
* Lieu         : falkenburg
* Description  : long up and downhill sections
* Hazards      : barriers in road
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000000 01:#6C906C 02:#486C48 03:#B4B4B4 04:#244824 05:#B40000 06:#242424 07:#242424
*   08:#004800 09:#D8D8D8 10:#002424 11:#FCFCFC 12:#4890FC 13:#4890FC 14:#6C90FC 15:#6C90FC
*   16:#9090FC 17:#9090FC 18:#B490FC 19:#B490FC 20:#D890FC 21:#D890FC 22:#FC90FC 23:#FC90FC
*   24:#FC90FC 25:#FCB4FC 26:#FCB4FC 27:#FCD8FC
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
* Taille totale : 1962 oct (nb_segments 2 + LUT 16 + segments 1296 + cache 648).
* ======================================================================

Circuit_05_easy_5_nb_segments
        fdb   154

Circuit_05_easy_5_sprite_lut
        fcb   $00,$82,$83,$90,$A7,$98,$81,$80,$9F,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_05_easy_5_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$03,$04,$E0,$00,$30,$00  ; seg   8                      flags=[PIT]   #0:$90@-32 #2:$A7@+48
        fcb   $80,$00,$04,$00,$D0,$00,$00,$00  ; seg   9                      flags=[PIT]   #0:$A7@-48
        fcb   $80,$00,$00,$04,$00,$00,$3C,$00  ; seg  10                      flags=[PIT]   #2:$A7@+60
        fcb   $80,$00,$03,$00,$CC,$00,$00,$00  ; seg  11                      flags=[PIT]   #0:$90@-52
        fcb   $80,$00,$04,$00,$D0,$00,$00,$00  ; seg  12                      flags=[PIT]   #0:$A7@-48
        fcb   $80,$00,$03,$00,$E4,$00,$00,$00  ; seg  13                      flags=[PIT]   #0:$90@-28
        fcb   $80,$00,$04,$04,$E8,$00,$28,$00  ; seg  14                      flags=[PIT]   #0:$A7@-24 #2:$A7@+40
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  15                      flags=[PIT]   #0:$90@-20
        fcb   $00,$00,$05,$04,$EE,$00,$E0,$00  ; seg  16                                    #0:$98@-18 #2:$A7@-32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  17
        fcb   $00,$7E,$05,$03,$EE,$00,$EC,$00  ; seg  18            pitch=-2                #0:$98@-18 #2:$90@-20
        fcb   $00,$7E,$05,$00,$EE,$00,$00,$00  ; seg  19            pitch=-2                #0:$98@-18
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg  20            pitch=+2
        fcb   $00,$02,$05,$00,$EE,$00,$00,$00  ; seg  21            pitch=+2                #0:$98@-18
        fcb   $00,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg  22                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg  23                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg  24  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg  25  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$77,$77,$12,$12,$12,$12  ; seg  26  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$77,$77,$12,$12,$12,$12  ; seg  27  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  28  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  29  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$00,$00,$00,$00,$00,$00  ; seg  30  curve=+6
        fcb   $06,$00,$00,$00,$00,$00,$00,$00  ; seg  31  curve=+6
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  33
        fcb   $00,$03,$00,$00,$00,$00,$00,$00  ; seg  34            pitch=+3
        fcb   $00,$03,$00,$00,$00,$00,$00,$00  ; seg  35            pitch=+3
        fcb   $00,$00,$80,$80,$00,$FE,$00,$F8  ; seg  36                                    #1:$9F@-2 #3:$9F@-8
        fcb   $00,$00,$80,$80,$00,$FE,$00,$F8  ; seg  37                                    #1:$9F@-2 #3:$9F@-8
        fcb   $00,$01,$85,$80,$12,$FE,$00,$F8  ; seg  38            pitch=+1                #0:$98@+18 #1:$9F@-2 #3:$9F@-8
        fcb   $00,$01,$80,$80,$00,$FE,$00,$F8  ; seg  39            pitch=+1                #1:$9F@-2 #3:$9F@-8
        fcb   $00,$7E,$85,$80,$12,$FE,$00,$F8  ; seg  40            pitch=-2                #0:$98@+18 #1:$9F@-2 #3:$9F@-8
        fcb   $00,$7E,$80,$80,$00,$FE,$00,$F8  ; seg  41            pitch=-2                #1:$9F@-2 #3:$9F@-8
        fcb   $00,$7E,$05,$00,$12,$00,$00,$00  ; seg  42            pitch=-2                #0:$98@+18
        fcb   $00,$7E,$05,$00,$12,$00,$00,$00  ; seg  43            pitch=-2                #0:$98@+18
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg  44            pitch=-2
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg  45            pitch=-2
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  46                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  47                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  48  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  49  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$46,$40,$EE,$12,$00,$16  ; seg  50  curve=-4                          #0:$81@-18 #1:$A7@+18 #3:$A7@+22
        fcb   $7C,$00,$36,$00,$EE,$16,$00,$00  ; seg  51  curve=-4                          #0:$81@-18 #1:$90@+22
        fcb   $7C,$00,$36,$00,$EE,$14,$00,$00  ; seg  52  curve=-4                          #0:$81@-18 #1:$90@+20
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$12  ; seg  53  curve=-4                          #0:$81@-18 #3:$90@+18
        fcb   $7C,$00,$46,$40,$EE,$14,$00,$14  ; seg  54  curve=-4                          #0:$81@-18 #1:$A7@+20 #3:$A7@+20
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  55  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  56  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  57  curve=-4                          #0:$81@-18
        fcb   $7C,$01,$06,$00,$EE,$00,$00,$00  ; seg  58  curve=-4  pitch=+1                #0:$81@-18
        fcb   $7C,$01,$06,$00,$EE,$00,$00,$00  ; seg  59  curve=-4  pitch=+1                #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  60  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  61  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  62  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  63  curve=-4
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  64
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  65
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg  66            pitch=+1
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg  67            pitch=+1
        fcb   $00,$00,$80,$80,$00,$02,$00,$08  ; seg  68                                    #1:$9F@+2 #3:$9F@+8
        fcb   $00,$00,$80,$80,$00,$02,$00,$08  ; seg  69                                    #1:$9F@+2 #3:$9F@+8
        fcb   $00,$7E,$85,$80,$EE,$02,$00,$08  ; seg  70            pitch=-2                #0:$98@-18 #1:$9F@+2 #3:$9F@+8
        fcb   $00,$7E,$80,$80,$00,$02,$00,$08  ; seg  71            pitch=-2                #1:$9F@+2 #3:$9F@+8
        fcb   $00,$00,$85,$80,$EE,$02,$00,$08  ; seg  72                                    #0:$98@-18 #1:$9F@+2 #3:$9F@+8
        fcb   $00,$00,$85,$80,$EE,$02,$00,$08  ; seg  73                                    #0:$98@-18 #1:$9F@+2 #3:$9F@+8
        fcb   $00,$03,$00,$00,$00,$00,$00,$00  ; seg  74            pitch=+3
        fcb   $00,$03,$05,$00,$EE,$00,$00,$00  ; seg  75            pitch=+3                #0:$98@-18
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  76            pitch=-1
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  77            pitch=-1
        fcb   $00,$00,$77,$77,$12,$12,$12,$12  ; seg  78                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$77,$77,$12,$12,$12,$12  ; seg  79                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  80  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  81  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg  82  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $06,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg  83  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg  84  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg  85  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg  86  curve=-6
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg  87  curve=-6
        fcb   $00,$00,$05,$00,$EE,$00,$00,$00  ; seg  88                                    #0:$98@-18
        fcb   $00,$00,$05,$00,$EE,$00,$00,$00  ; seg  89                                    #0:$98@-18
        fcb   $00,$00,$05,$00,$EE,$00,$00,$00  ; seg  90                                    #0:$98@-18
        fcb   $00,$00,$05,$00,$EE,$00,$00,$00  ; seg  91                                    #0:$98@-18
        fcb   $00,$03,$00,$00,$00,$00,$00,$00  ; seg  92            pitch=+3
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg  93            pitch=-3
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg  94            pitch=-3
        fcb   $00,$03,$00,$00,$00,$00,$00,$00  ; seg  95            pitch=+3
        fcb   $00,$03,$05,$00,$EE,$00,$00,$00  ; seg  96            pitch=+3                #0:$98@-18
        fcb   $00,$03,$05,$00,$EE,$00,$00,$00  ; seg  97            pitch=+3                #0:$98@-18
        fcb   $00,$00,$05,$00,$EE,$00,$00,$00  ; seg  98                                    #0:$98@-18
        fcb   $00,$00,$05,$00,$EE,$00,$00,$00  ; seg  99                                    #0:$98@-18
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 100            pitch=-3
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 101            pitch=-3
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 102            pitch=-3
        fcb   $00,$03,$00,$00,$00,$00,$00,$00  ; seg 103            pitch=+3
        fcb   $00,$03,$05,$00,$12,$00,$00,$00  ; seg 104            pitch=+3                #0:$98@+18
        fcb   $00,$03,$05,$00,$12,$00,$00,$00  ; seg 105            pitch=+3                #0:$98@+18
        fcb   $00,$00,$05,$00,$12,$00,$00,$00  ; seg 106                                    #0:$98@+18
        fcb   $00,$00,$05,$00,$12,$00,$00,$00  ; seg 107                                    #0:$98@+18
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 108            pitch=-3
        fcb   $00,$7D,$05,$00,$12,$00,$00,$00  ; seg 109            pitch=-3                #0:$98@+18
        fcb   $00,$7D,$05,$00,$12,$00,$00,$00  ; seg 110            pitch=-3                #0:$98@+18
        fcb   $00,$03,$05,$00,$12,$00,$00,$00  ; seg 111            pitch=+3                #0:$98@+18
        fcb   $00,$03,$05,$00,$12,$00,$00,$00  ; seg 112            pitch=+3                #0:$98@+18
        fcb   $00,$03,$00,$00,$00,$00,$00,$00  ; seg 113            pitch=+3
        fcb   $00,$00,$05,$00,$12,$00,$00,$00  ; seg 114                                    #0:$98@+18
        fcb   $00,$00,$05,$00,$12,$00,$00,$00  ; seg 115                                    #0:$98@+18
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 116            pitch=-3
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 117            pitch=-3
        fcb   $00,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg 118                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg 119                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$06,$00,$EE,$00,$00,$00  ; seg 120  curve=-6                          #0:$81@-18
        fcb   $7A,$00,$06,$00,$EE,$00,$00,$00  ; seg 121  curve=-6                          #0:$81@-18
        fcb   $7C,$00,$06,$06,$EE,$00,$EE,$00  ; seg 122  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$06,$EE,$00,$EE,$00  ; seg 123  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$40,$00,$00,$EE,$00,$00  ; seg 124  curve=-6                          #1:$A7@-18
        fcb   $7A,$00,$00,$30,$00,$00,$00,$2C  ; seg 125  curve=-6                          #3:$90@+44
        fcb   $00,$00,$40,$40,$00,$E8,$00,$24  ; seg 126                                    #1:$A7@-24 #3:$A7@+36
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 127
        fcb   $00,$7E,$45,$40,$EE,$24,$00,$20  ; seg 128            pitch=-2                #0:$98@-18 #1:$A7@+36 #3:$A7@+32
        fcb   $00,$7E,$05,$30,$EE,$00,$00,$24  ; seg 129            pitch=-2                #0:$98@-18 #3:$90@+36
        fcb   $00,$02,$40,$00,$00,$28,$00,$00  ; seg 130            pitch=+2                #1:$A7@+40
        fcb   $00,$02,$35,$40,$EE,$18,$00,$20  ; seg 131            pitch=+2                #0:$98@-18 #1:$90@+24 #3:$A7@+32
        fcb   $00,$7E,$00,$30,$00,$00,$00,$28  ; seg 132            pitch=-2                #3:$90@+40
        fcb   $00,$7E,$30,$40,$00,$D8,$00,$1C  ; seg 133            pitch=-2                #1:$90@-40 #3:$A7@+28
        fcb   $00,$02,$40,$00,$00,$EC,$00,$00  ; seg 134            pitch=+2                #1:$A7@-20
        fcb   $00,$02,$00,$40,$00,$00,$00,$18  ; seg 135            pitch=+2                #3:$A7@+24
        fcb   $00,$7E,$66,$66,$EE,$EE,$EE,$EE  ; seg 136            pitch=-2                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$7E,$66,$66,$EE,$EE,$EE,$EE  ; seg 137            pitch=-2                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$46,$00,$EE,$14,$00,$00  ; seg 138  curve=-6                          #0:$81@-18 #1:$A7@+20
        fcb   $7A,$00,$06,$30,$EE,$00,$00,$14  ; seg 139  curve=-6                          #0:$81@-18 #3:$90@+20
        fcb   $7C,$00,$46,$06,$EE,$18,$EE,$00  ; seg 140  curve=-4                          #0:$81@-18 #1:$A7@+24 #2:$81@-18
        fcb   $7C,$00,$46,$46,$EE,$28,$EE,$20  ; seg 141  curve=-4                          #0:$81@-18 #1:$A7@+40 #2:$81@-18 #3:$A7@+32
        fcb   $7A,$00,$00,$30,$00,$00,$00,$18  ; seg 142  curve=-6                          #3:$90@+24
        fcb   $7A,$00,$40,$00,$00,$28,$00,$00  ; seg 143  curve=-6                          #1:$A7@+40
        fcb   $00,$01,$05,$05,$12,$00,$12,$00  ; seg 144            pitch=+1                #0:$98@+18 #2:$98@+18
        fcb   $00,$01,$05,$05,$12,$00,$12,$00  ; seg 145            pitch=+1                #0:$98@+18 #2:$98@+18
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg 146            pitch=+1
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg 147            pitch=+1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 148
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 149
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 150
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 151
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 152
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 153
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 154                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 155
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 156
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 157
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 158                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 159                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 160                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 161                                    #0:$83@+18 #2:$83@+18

Circuit_05_easy_5_segment_cache
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
        fcb   $00,$FE,$F6,$0A  ; seg  19  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$FC,$F6,$0A  ; seg  20  yaw=  +0 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F7,$0A  ; seg  21  yaw=  +0 pitch=  -2 min_lat=  -9 max_lat= +10
        fcb   $00,$00,$F8,$0A  ; seg  22  yaw=  +0 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $00,$00,$F9,$0A  ; seg  23  yaw=  +0 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $00,$00,$FA,$0A  ; seg  24  yaw=  +0 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $FA,$00,$FB,$0A  ; seg  25  yaw=  -6 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $F4,$00,$FC,$0A  ; seg  26  yaw= -12 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $EE,$00,$FD,$0A  ; seg  27  yaw= -18 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $E8,$00,$FE,$0A  ; seg  28  yaw= -24 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $EE,$00,$FF,$0A  ; seg  29  yaw= -18 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $F4,$00,$00,$0A  ; seg  30  yaw= -12 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $FA,$00,$01,$0A  ; seg  31  yaw=  -6 pitch=  +0 min_lat=  +1 max_lat= +10
        fcb   $00,$00,$02,$0A  ; seg  32  yaw=  +0 pitch=  +0 min_lat=  +2 max_lat= +10
        fcb   $00,$00,$03,$0A  ; seg  33  yaw=  +0 pitch=  +0 min_lat=  +3 max_lat= +10
        fcb   $00,$00,$04,$0A  ; seg  34  yaw=  +0 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $00,$03,$05,$0A  ; seg  35  yaw=  +0 pitch=  +3 min_lat=  +5 max_lat= +10
        fcb   $00,$06,$06,$0A  ; seg  36  yaw=  +0 pitch=  +6 min_lat=  +6 max_lat= +10
        fcb   $00,$06,$06,$0A  ; seg  37  yaw=  +0 pitch=  +6 min_lat=  +6 max_lat= +10
        fcb   $00,$06,$06,$0A  ; seg  38  yaw=  +0 pitch=  +6 min_lat=  +6 max_lat= +10
        fcb   $00,$07,$06,$0A  ; seg  39  yaw=  +0 pitch=  +7 min_lat=  +6 max_lat= +10
        fcb   $00,$08,$06,$0A  ; seg  40  yaw=  +0 pitch=  +8 min_lat=  +6 max_lat= +10
        fcb   $00,$06,$06,$0A  ; seg  41  yaw=  +0 pitch=  +6 min_lat=  +6 max_lat= +10
        fcb   $00,$04,$F6,$0A  ; seg  42  yaw=  +0 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  43  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  44  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  45  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$FC,$F6,$0A  ; seg  46  yaw=  +0 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $00,$FC,$F6,$0A  ; seg  47  yaw=  +0 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $00,$FC,$F6,$0A  ; seg  48  yaw=  +0 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $FC,$FC,$F6,$0A  ; seg  49  yaw=  -4 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $F8,$FC,$F6,$0A  ; seg  50  yaw=  -8 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $F4,$FC,$F6,$0A  ; seg  51  yaw= -12 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $F0,$FC,$F6,$0A  ; seg  52  yaw= -16 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $EC,$FC,$F6,$09  ; seg  53  yaw= -20 pitch=  -4 min_lat= -10 max_lat=  +9
        fcb   $E8,$FC,$F6,$08  ; seg  54  yaw= -24 pitch=  -4 min_lat= -10 max_lat=  +8
        fcb   $E4,$FC,$F6,$07  ; seg  55  yaw= -28 pitch=  -4 min_lat= -10 max_lat=  +7
        fcb   $E0,$FC,$F6,$06  ; seg  56  yaw= -32 pitch=  -4 min_lat= -10 max_lat=  +6
        fcb   $DC,$FC,$F6,$05  ; seg  57  yaw= -36 pitch=  -4 min_lat= -10 max_lat=  +5
        fcb   $D8,$FC,$F6,$04  ; seg  58  yaw= -40 pitch=  -4 min_lat= -10 max_lat=  +4
        fcb   $D4,$FD,$F6,$03  ; seg  59  yaw= -44 pitch=  -3 min_lat= -10 max_lat=  +3
        fcb   $D0,$FE,$F6,$02  ; seg  60  yaw= -48 pitch=  -2 min_lat= -10 max_lat=  +2
        fcb   $CC,$FE,$F6,$01  ; seg  61  yaw= -52 pitch=  -2 min_lat= -10 max_lat=  +1
        fcb   $C8,$FE,$F6,$00  ; seg  62  yaw= -56 pitch=  -2 min_lat= -10 max_lat=  +0
        fcb   $C4,$FE,$F6,$FF  ; seg  63  yaw= -60 pitch=  -2 min_lat= -10 max_lat=  -1
        fcb   $C0,$FE,$F6,$FE  ; seg  64  yaw= -64 pitch=  -2 min_lat= -10 max_lat=  -2
        fcb   $C0,$FE,$F6,$FD  ; seg  65  yaw= -64 pitch=  -2 min_lat= -10 max_lat=  -3
        fcb   $C0,$FE,$F6,$FC  ; seg  66  yaw= -64 pitch=  -2 min_lat= -10 max_lat=  -4
        fcb   $C0,$FF,$F6,$FB  ; seg  67  yaw= -64 pitch=  -1 min_lat= -10 max_lat=  -5
        fcb   $C0,$00,$F6,$FA  ; seg  68  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $C0,$00,$F6,$FA  ; seg  69  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $C0,$00,$F6,$FA  ; seg  70  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $C0,$FE,$F6,$FA  ; seg  71  yaw= -64 pitch=  -2 min_lat= -10 max_lat=  -6
        fcb   $C0,$FC,$F6,$FA  ; seg  72  yaw= -64 pitch=  -4 min_lat= -10 max_lat=  -6
        fcb   $C0,$FC,$F6,$FA  ; seg  73  yaw= -64 pitch=  -4 min_lat= -10 max_lat=  -6
        fcb   $C0,$FC,$F6,$0A  ; seg  74  yaw= -64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C0,$FF,$F6,$0A  ; seg  75  yaw= -64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  76  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg  77  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  78  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  79  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  80  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C6,$00,$F6,$0A  ; seg  81  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  82  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D2,$00,$F6,$0A  ; seg  83  yaw= -46 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  84  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D2,$00,$F6,$0A  ; seg  85  yaw= -46 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  86  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C6,$00,$F6,$0A  ; seg  87  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  88  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  89  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  90  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  91  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  92  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg  93  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  94  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$FD,$F6,$0A  ; seg  95  yaw= -64 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  96  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg  97  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg  98  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg  99  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 100  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 101  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 102  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$FD,$F6,$0A  ; seg 103  yaw= -64 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 104  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 105  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 106  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 107  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 108  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 109  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 110  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$FD,$F6,$0A  ; seg 111  yaw= -64 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 112  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 113  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 114  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 115  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 116  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 117  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 118  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 119  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 120  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg 121  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 122  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 123  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg 124  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A6,$00,$F6,$0A  ; seg 125  yaw= -90 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 126  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 127  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 128  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$FE,$F6,$0A  ; seg 129  yaw= -96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A0,$FC,$F6,$0A  ; seg 130  yaw= -96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $A0,$FE,$F6,$0A  ; seg 131  yaw= -96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 132  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$FE,$F6,$0A  ; seg 133  yaw= -96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A0,$FC,$F6,$0A  ; seg 134  yaw= -96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $A0,$FE,$F6,$0A  ; seg 135  yaw= -96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 136  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$FE,$F6,$0A  ; seg 137  yaw= -96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A0,$FC,$F6,$0A  ; seg 138  yaw= -96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $9A,$FC,$F6,$0A  ; seg 139  yaw=-102 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $94,$FC,$F6,$0A  ; seg 140  yaw=-108 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $90,$FC,$F6,$0A  ; seg 141  yaw=-112 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $8C,$FC,$F6,$0A  ; seg 142  yaw=-116 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $86,$FC,$F6,$0A  ; seg 143  yaw=-122 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $80,$FC,$F6,$0A  ; seg 144  yaw=-128 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $80,$FD,$F6,$0A  ; seg 145  yaw=-128 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 146  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FF,$F6,$0A  ; seg 147  yaw=-128 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 148  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 149  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 150  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 151  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 152  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 153  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 154 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 155 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 156 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 157 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 158 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 159 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 160 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 161 (wraparound de seg 7)
