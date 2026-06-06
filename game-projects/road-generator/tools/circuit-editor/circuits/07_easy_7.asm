* ======================================================================
* Circuit_07_easy_7 — N=136 segments (format compact 8 oct/seg)
* Source       : 07_easy_7.bin (extrait de FILE30)
*
* Pays         : FINLAND
* Lieu         : merikania
* Description  : mainly gentle slopes
* Hazards      : rocks lying on edges of road
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

Circuit_07_easy_7_nb_segments
        fdb   136

Circuit_07_easy_7_sprite_lut
        fcb   $00,$82,$83,$A5,$81,$8C,$87,$8B,$9A,$80,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_07_easy_7_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$03,$00,$00,$28,$00  ; seg   8                      flags=[PIT]   #2:$A5@+40
        fcb   $80,$00,$00,$03,$00,$00,$30,$00  ; seg   9                      flags=[PIT]   #2:$A5@+48
        fcb   $80,$00,$00,$03,$00,$00,$D4,$00  ; seg  10                      flags=[PIT]   #2:$A5@-44
        fcb   $80,$00,$00,$03,$00,$00,$EC,$00  ; seg  11                      flags=[PIT]   #2:$A5@-20
        fcb   $80,$00,$00,$03,$00,$00,$E0,$00  ; seg  12                      flags=[PIT]   #2:$A5@-32
        fcb   $80,$00,$00,$03,$00,$00,$24,$00  ; seg  13                      flags=[PIT]   #2:$A5@+36
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  14                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  15                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$E0  ; seg  16  curve=-4                          #0:$81@-18 #3:$8C@-32
        fcb   $7C,$00,$04,$06,$EE,$00,$14,$00  ; seg  17  curve=-4                          #0:$81@-18 #2:$87@+20
        fcb   $7C,$00,$04,$73,$EE,$00,$1C,$20  ; seg  18  curve=-4                          #0:$81@-18 #2:$A5@+28 #3:$8B@+32
        fcb   $7C,$00,$04,$70,$EE,$00,$00,$CC  ; seg  19  curve=-4                          #0:$81@-18 #3:$8B@-52
        fcb   $7C,$00,$04,$03,$EE,$00,$28,$00  ; seg  20  curve=-4                          #0:$81@-18 #2:$A5@+40
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  21  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$73,$EE,$00,$20,$28  ; seg  22  curve=-4                          #0:$81@-18 #2:$A5@+32 #3:$8B@+40
        fcb   $7C,$00,$04,$06,$EE,$00,$14,$00  ; seg  23  curve=-4                          #0:$81@-18 #2:$87@+20
        fcb   $7C,$7F,$04,$00,$EE,$00,$00,$00  ; seg  24  curve=-4  pitch=-1                #0:$81@-18
        fcb   $7C,$7F,$04,$73,$EE,$00,$18,$30  ; seg  25  curve=-4  pitch=-1                #0:$81@-18 #2:$A5@+24 #3:$8B@+48
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  26  curve=-4
        fcb   $7C,$00,$00,$03,$00,$00,$24,$00  ; seg  27  curve=-4                          #2:$A5@+36
        fcb   $00,$00,$08,$58,$EE,$00,$EE,$14  ; seg  28                                    #0:$9A@-18 #2:$9A@-18 #3:$8C@+20
        fcb   $00,$00,$08,$08,$EE,$00,$EE,$00  ; seg  29                                    #0:$9A@-18 #2:$9A@-18
        fcb   $00,$7F,$00,$70,$00,$00,$00,$20  ; seg  30            pitch=-1                #3:$8B@+32
        fcb   $00,$7F,$06,$00,$EA,$00,$00,$00  ; seg  31            pitch=-1                #0:$87@-22
        fcb   $00,$00,$53,$73,$E2,$F4,$1C,$F4  ; seg  32                                    #0:$A5@-30 #1:$8C@-12 #2:$A5@+28 #3:$8B@-12
        fcb   $00,$00,$76,$00,$EC,$FC,$00,$00  ; seg  33                                    #0:$87@-20 #1:$8B@-4
        fcb   $00,$01,$06,$50,$E8,$00,$00,$F2  ; seg  34            pitch=+1                #0:$87@-24 #3:$8C@-14
        fcb   $00,$01,$56,$73,$EA,$FE,$20,$FC  ; seg  35            pitch=+1                #0:$87@-22 #1:$8C@-2 #2:$A5@+32 #3:$8B@-4
        fcb   $00,$01,$70,$70,$00,$F2,$00,$F8  ; seg  36            pitch=+1                #1:$8B@-14 #3:$8B@-8
        fcb   $00,$01,$70,$00,$00,$F8,$00,$00  ; seg  37            pitch=+1                #1:$8B@-8
        fcb   $00,$00,$04,$74,$EE,$00,$EE,$F4  ; seg  38                                    #0:$81@-18 #2:$81@-18 #3:$8B@-12
        fcb   $00,$00,$54,$74,$EE,$F6,$EE,$F2  ; seg  39                                    #0:$81@-18 #1:$8C@-10 #2:$81@-18 #3:$8B@-14
        fcb   $7C,$01,$04,$70,$EE,$00,$00,$20  ; seg  40  curve=-4  pitch=+1                #0:$81@-18 #3:$8B@+32
        fcb   $7C,$01,$04,$03,$EE,$00,$30,$00  ; seg  41  curve=-4  pitch=+1                #0:$81@-18 #2:$A5@+48
        fcb   $7C,$00,$00,$03,$00,$00,$E4,$00  ; seg  42  curve=-4                          #2:$A5@-28
        fcb   $7C,$00,$00,$73,$00,$00,$EC,$EC  ; seg  43  curve=-4                          #2:$A5@-20 #3:$8B@-20
        fcb   $00,$00,$06,$76,$12,$00,$E8,$D8  ; seg  44                                    #0:$87@+18 #2:$87@-24 #3:$8B@-40
        fcb   $00,$00,$06,$00,$12,$00,$00,$00  ; seg  45                                    #0:$87@+18
        fcb   $00,$7F,$03,$53,$12,$00,$C4,$20  ; seg  46            pitch=-1                #0:$A5@+18 #2:$A5@-60 #3:$8C@+32
        fcb   $00,$7F,$06,$00,$12,$00,$00,$00  ; seg  47            pitch=-1                #0:$87@+18
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  48
        fcb   $00,$00,$00,$70,$00,$00,$00,$18  ; seg  49                                    #3:$8B@+24
        fcb   $00,$00,$04,$74,$EE,$00,$EE,$28  ; seg  50                                    #0:$81@-18 #2:$81@-18 #3:$8B@+40
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  51                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  52  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$50,$EE,$00,$00,$30  ; seg  53  curve=-4                          #0:$81@-18 #3:$8C@+48
        fcb   $7C,$00,$00,$53,$00,$00,$14,$D0  ; seg  54  curve=-4                          #2:$A5@+20 #3:$8C@-48
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  55  curve=-4
        fcb   $00,$00,$08,$08,$12,$00,$12,$00  ; seg  56                                    #0:$9A@+18 #2:$9A@+18
        fcb   $00,$00,$08,$08,$12,$00,$12,$00  ; seg  57                                    #0:$9A@+18 #2:$9A@+18
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  58            pitch=-1
        fcb   $00,$7F,$03,$70,$18,$00,$00,$E4  ; seg  59            pitch=-1                #0:$A5@+24 #3:$8B@-28
        fcb   $00,$7F,$76,$53,$16,$04,$30,$04  ; seg  60            pitch=-1                #0:$87@+22 #1:$8B@+4 #2:$A5@+48 #3:$8C@+4
        fcb   $00,$7F,$76,$00,$18,$0E,$00,$00  ; seg  61            pitch=-1                #0:$87@+24 #1:$8B@+14
        fcb   $00,$00,$00,$76,$00,$00,$EC,$0A  ; seg  62                                    #2:$87@-20 #3:$8B@+10
        fcb   $00,$00,$73,$70,$12,$0A,$00,$0E  ; seg  63                                    #0:$A5@+18 #1:$8B@+10 #3:$8B@+14
        fcb   $00,$00,$76,$70,$EA,$02,$00,$06  ; seg  64                                    #0:$87@-22 #1:$8B@+2 #3:$8B@+6
        fcb   $00,$00,$70,$03,$00,$0E,$28,$00  ; seg  65                                    #1:$8B@+14 #2:$A5@+40
        fcb   $00,$01,$56,$50,$E8,$0C,$00,$06  ; seg  66            pitch=+1                #0:$87@-24 #1:$8C@+12 #3:$8C@+6
        fcb   $00,$01,$06,$73,$E4,$00,$18,$08  ; seg  67            pitch=+1                #0:$87@-28 #2:$A5@+24 #3:$8B@+8
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg  68            pitch=+1
        fcb   $00,$01,$06,$70,$EC,$00,$00,$20  ; seg  69            pitch=+1                #0:$87@-20 #3:$8B@+32
        fcb   $00,$01,$00,$03,$00,$00,$20,$00  ; seg  70            pitch=+1                #2:$A5@+32
        fcb   $00,$01,$03,$50,$EA,$00,$00,$1C  ; seg  71            pitch=+1                #0:$A5@-22 #3:$8C@+28
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg  72            pitch=-1
        fcb   $00,$7F,$00,$70,$00,$00,$00,$30  ; seg  73            pitch=-1                #3:$8B@+48
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  74                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  75                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$01,$04,$70,$EE,$00,$00,$28  ; seg  76  curve=-4  pitch=+1                #0:$81@-18 #3:$8B@+40
        fcb   $7C,$01,$04,$00,$EE,$00,$00,$00  ; seg  77  curve=-4  pitch=+1                #0:$81@-18
        fcb   $7C,$00,$04,$76,$EE,$00,$38,$1C  ; seg  78  curve=-4                          #0:$81@-18 #2:$87@+56 #3:$8B@+28
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  79  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$03,$EE,$00,$14,$00  ; seg  80  curve=-4                          #0:$81@-18 #2:$A5@+20
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  81  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$53,$00,$00,$28,$20  ; seg  82  curve=-4                          #2:$A5@+40 #3:$8C@+32
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  83  curve=-4
        fcb   $00,$00,$06,$00,$18,$00,$00,$00  ; seg  84                                    #0:$87@+24
        fcb   $00,$00,$06,$03,$1C,$00,$30,$00  ; seg  85                                    #0:$87@+28 #2:$A5@+48
        fcb   $00,$7F,$06,$03,$1A,$00,$24,$00  ; seg  86            pitch=-1                #0:$87@+26 #2:$A5@+36
        fcb   $00,$7F,$03,$00,$12,$00,$00,$00  ; seg  87            pitch=-1                #0:$A5@+18
        fcb   $00,$00,$00,$06,$00,$00,$18,$00  ; seg  88                                    #2:$87@+24
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  89
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  90                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  91                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$70,$EE,$00,$00,$E8  ; seg  92  curve=-4                          #0:$81@-18 #3:$8B@-24
        fcb   $7C,$00,$04,$03,$EE,$00,$1C,$00  ; seg  93  curve=-4                          #0:$81@-18 #2:$A5@+28
        fcb   $7C,$00,$00,$03,$00,$00,$20,$00  ; seg  94  curve=-4                          #2:$A5@+32
        fcb   $7C,$00,$00,$50,$00,$00,$00,$28  ; seg  95  curve=-4                          #3:$8C@+40
        fcb   $00,$7E,$06,$03,$18,$00,$30,$00  ; seg  96            pitch=-2                #0:$87@+24 #2:$A5@+48
        fcb   $00,$7E,$06,$06,$12,$00,$EC,$00  ; seg  97            pitch=-2                #0:$87@+18 #2:$87@-20
        fcb   $00,$02,$03,$70,$16,$00,$00,$30  ; seg  98            pitch=+2                #0:$A5@+22 #3:$8B@+48
        fcb   $00,$02,$06,$03,$14,$00,$D8,$00  ; seg  99            pitch=+2                #0:$87@+20 #2:$A5@-40
        fcb   $00,$02,$00,$70,$00,$00,$00,$18  ; seg 100            pitch=+2                #3:$8B@+24
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg 101            pitch=+2
        fcb   $00,$7E,$44,$44,$EE,$EE,$EE,$EE  ; seg 102            pitch=-2                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$7E,$44,$44,$EE,$EE,$EE,$EE  ; seg 103            pitch=-2                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg 104  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg 105  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$50,$00,$00,$00,$20  ; seg 106  curve=-6                          #3:$8C@+32
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg 107  curve=-6
        fcb   $00,$00,$88,$88,$12,$EE,$12,$EE  ; seg 108                                    #0:$9A@+18 #1:$9A@-18 #2:$9A@+18 #3:$9A@-18
        fcb   $00,$00,$88,$88,$12,$EE,$12,$EE  ; seg 109                                    #0:$9A@+18 #1:$9A@-18 #2:$9A@+18 #3:$9A@-18
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg 110            pitch=+2
        fcb   $00,$02,$03,$00,$14,$00,$00,$00  ; seg 111            pitch=+2                #0:$A5@+20
        fcb   $00,$00,$77,$77,$08,$0E,$F4,$F8  ; seg 112                                    #0:$8B@+8 #1:$8B@+14 #2:$8B@-12 #3:$8B@-8
        fcb   $00,$00,$77,$75,$F0,$12,$F2,$12  ; seg 113                                    #0:$8B@-16 #1:$8B@+18 #2:$8C@-14 #3:$8B@+18
        fcb   $00,$00,$57,$77,$F4,$0C,$EE,$10  ; seg 114                                    #0:$8B@-12 #1:$8C@+12 #2:$8B@-18 #3:$8B@+16
        fcb   $00,$00,$77,$57,$0A,$0C,$EE,$F2  ; seg 115                                    #0:$8B@+10 #1:$8B@+12 #2:$8B@-18 #3:$8C@-14
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg 116            pitch=-2
        fcb   $00,$7E,$00,$70,$00,$00,$00,$20  ; seg 117            pitch=-2                #3:$8B@+32
        fcb   $00,$00,$99,$99,$12,$12,$12,$12  ; seg 118                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$99,$99,$12,$12,$12,$12  ; seg 119                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$09,$09,$12,$00,$12,$00  ; seg 120  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$09,$09,$12,$00,$12,$00  ; seg 121  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$00,$70,$00,$00,$00,$30  ; seg 122  curve=+6                          #3:$8B@+48
        fcb   $06,$00,$00,$00,$00,$00,$00,$00  ; seg 123  curve=+6
        fcb   $00,$7E,$06,$03,$EE,$00,$24,$00  ; seg 124            pitch=-2                #0:$87@-18 #2:$A5@+36
        fcb   $00,$7E,$06,$03,$E8,$00,$18,$00  ; seg 125            pitch=-2                #0:$87@-24 #2:$A5@+24
        fcb   $00,$02,$03,$76,$EE,$00,$1C,$1C  ; seg 126            pitch=+2                #0:$A5@-18 #2:$87@+28 #3:$8B@+28
        fcb   $00,$02,$06,$03,$EC,$00,$30,$00  ; seg 127            pitch=+2                #0:$87@-20 #2:$A5@+48
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 128
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 129
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 130
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 131
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 132
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 133
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 134
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 135
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 136                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 137
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 138
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 139
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 140                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 141                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 142                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 143                                    #0:$83@+18 #2:$83@+18

Circuit_07_easy_7_segment_cache
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
        fcb   $F0,$00,$F7,$0A  ; seg  20  yaw= -16 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $EC,$00,$F8,$0A  ; seg  21  yaw= -20 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $E8,$00,$F9,$0A  ; seg  22  yaw= -24 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $E4,$00,$FA,$0A  ; seg  23  yaw= -28 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $E0,$00,$FB,$0A  ; seg  24  yaw= -32 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $DC,$FF,$FC,$0A  ; seg  25  yaw= -36 pitch=  -1 min_lat=  -4 max_lat= +10
        fcb   $D8,$FE,$FD,$0A  ; seg  26  yaw= -40 pitch=  -2 min_lat=  -3 max_lat= +10
        fcb   $D4,$FE,$FE,$0A  ; seg  27  yaw= -44 pitch=  -2 min_lat=  -2 max_lat= +10
        fcb   $D0,$FE,$FF,$0A  ; seg  28  yaw= -48 pitch=  -2 min_lat=  -1 max_lat= +10
        fcb   $D0,$FE,$00,$0A  ; seg  29  yaw= -48 pitch=  -2 min_lat=  +0 max_lat= +10
        fcb   $D0,$FE,$01,$0A  ; seg  30  yaw= -48 pitch=  -2 min_lat=  +1 max_lat= +10
        fcb   $D0,$FD,$02,$0A  ; seg  31  yaw= -48 pitch=  -3 min_lat=  +2 max_lat= +10
        fcb   $D0,$FC,$03,$0A  ; seg  32  yaw= -48 pitch=  -4 min_lat=  +3 max_lat= +10
        fcb   $D0,$FC,$04,$0A  ; seg  33  yaw= -48 pitch=  -4 min_lat=  +4 max_lat= +10
        fcb   $D0,$FC,$05,$0A  ; seg  34  yaw= -48 pitch=  -4 min_lat=  +5 max_lat= +10
        fcb   $D0,$FD,$06,$0A  ; seg  35  yaw= -48 pitch=  -3 min_lat=  +6 max_lat= +10
        fcb   $D0,$FE,$00,$0A  ; seg  36  yaw= -48 pitch=  -2 min_lat=  +0 max_lat= +10
        fcb   $D0,$FF,$00,$0A  ; seg  37  yaw= -48 pitch=  -1 min_lat=  +0 max_lat= +10
        fcb   $D0,$00,$FD,$0A  ; seg  38  yaw= -48 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $D0,$00,$FE,$0A  ; seg  39  yaw= -48 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  40  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$01,$F6,$0A  ; seg  41  yaw= -52 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C8,$02,$F6,$0A  ; seg  42  yaw= -56 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C4,$02,$F6,$0A  ; seg  43  yaw= -60 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  44  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  45  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  46  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$09  ; seg  47  yaw= -64 pitch=  +1 min_lat= -10 max_lat=  +9
        fcb   $C0,$00,$F6,$08  ; seg  48  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $C0,$00,$F6,$07  ; seg  49  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $C0,$00,$F6,$06  ; seg  50  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $C0,$00,$F6,$05  ; seg  51  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $C0,$00,$F6,$04  ; seg  52  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $BC,$00,$F6,$03  ; seg  53  yaw= -68 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $B8,$00,$F6,$02  ; seg  54  yaw= -72 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $B4,$00,$F6,$01  ; seg  55  yaw= -76 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $B0,$00,$F6,$00  ; seg  56  yaw= -80 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $B0,$00,$F6,$FF  ; seg  57  yaw= -80 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $B0,$00,$F6,$FE  ; seg  58  yaw= -80 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $B0,$FF,$F6,$FD  ; seg  59  yaw= -80 pitch=  -1 min_lat= -10 max_lat=  -3
        fcb   $B0,$FE,$F6,$FC  ; seg  60  yaw= -80 pitch=  -2 min_lat= -10 max_lat=  -4
        fcb   $B0,$FD,$F6,$FD  ; seg  61  yaw= -80 pitch=  -3 min_lat= -10 max_lat=  -3
        fcb   $B0,$FC,$F6,$FC  ; seg  62  yaw= -80 pitch=  -4 min_lat= -10 max_lat=  -4
        fcb   $B0,$FC,$F6,$FB  ; seg  63  yaw= -80 pitch=  -4 min_lat= -10 max_lat=  -5
        fcb   $B0,$FC,$F6,$FA  ; seg  64  yaw= -80 pitch=  -4 min_lat= -10 max_lat=  -6
        fcb   $B0,$FC,$F6,$FF  ; seg  65  yaw= -80 pitch=  -4 min_lat= -10 max_lat=  -1
        fcb   $B0,$FC,$F6,$FE  ; seg  66  yaw= -80 pitch=  -4 min_lat= -10 max_lat=  -2
        fcb   $B0,$FD,$F6,$00  ; seg  67  yaw= -80 pitch=  -3 min_lat= -10 max_lat=  +0
        fcb   $B0,$FE,$F6,$0A  ; seg  68  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$FF,$F6,$0A  ; seg  69  yaw= -80 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  70  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$01,$F6,$0A  ; seg  71  yaw= -80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg  72  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$01,$F6,$0A  ; seg  73  yaw= -80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  74  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  75  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  76  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$01,$F6,$0A  ; seg  77  yaw= -84 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg  78  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A4,$02,$F6,$0A  ; seg  79  yaw= -92 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A0,$02,$F6,$0A  ; seg  80  yaw= -96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $9C,$02,$F6,$0A  ; seg  81  yaw=-100 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $98,$02,$F6,$0A  ; seg  82  yaw=-104 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $94,$02,$F6,$0A  ; seg  83  yaw=-108 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $90,$02,$F6,$0A  ; seg  84  yaw=-112 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $90,$02,$F6,$0A  ; seg  85  yaw=-112 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $90,$02,$F6,$0A  ; seg  86  yaw=-112 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $90,$01,$F6,$0A  ; seg  87  yaw=-112 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg  88  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg  89  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg  90  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg  91  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg  92  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg  93  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg  94  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg  95  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  96  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg  97  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FC,$F6,$0A  ; seg  98  yaw=-128 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg  99  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 100  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 101  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$04,$F6,$0A  ; seg 102  yaw=-128 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F7,$09  ; seg 103  yaw=-128 pitch=  +2 min_lat=  -9 max_lat=  +9
        fcb   $80,$00,$F8,$08  ; seg 104  yaw=-128 pitch=  +0 min_lat=  -8 max_lat=  +8
        fcb   $7A,$00,$F9,$07  ; seg 105  yaw=+122 pitch=  +0 min_lat=  -7 max_lat=  +7
        fcb   $74,$00,$FA,$06  ; seg 106  yaw=+116 pitch=  +0 min_lat=  -6 max_lat=  +6
        fcb   $6E,$00,$FB,$05  ; seg 107  yaw=+110 pitch=  +0 min_lat=  -5 max_lat=  +5
        fcb   $68,$00,$FC,$04  ; seg 108  yaw=+104 pitch=  +0 min_lat=  -4 max_lat=  +4
        fcb   $68,$00,$FD,$03  ; seg 109  yaw=+104 pitch=  +0 min_lat=  -3 max_lat=  +3
        fcb   $68,$00,$FE,$02  ; seg 110  yaw=+104 pitch=  +0 min_lat=  -2 max_lat=  +2
        fcb   $68,$02,$FF,$01  ; seg 111  yaw=+104 pitch=  +2 min_lat=  -1 max_lat=  +1
        fcb   $68,$04,$00,$00  ; seg 112  yaw=+104 pitch=  +4 min_lat=  +0 max_lat=  +0
        fcb   $68,$04,$FB,$04  ; seg 113  yaw=+104 pitch=  +4 min_lat=  -5 max_lat=  +4
        fcb   $68,$04,$FC,$03  ; seg 114  yaw=+104 pitch=  +4 min_lat=  -4 max_lat=  +3
        fcb   $68,$04,$FA,$02  ; seg 115  yaw=+104 pitch=  +4 min_lat=  -6 max_lat=  +2
        fcb   $68,$04,$F6,$0A  ; seg 116  yaw=+104 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $68,$02,$F6,$0A  ; seg 117  yaw=+104 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $68,$00,$F6,$0A  ; seg 118  yaw=+104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $68,$00,$F6,$0A  ; seg 119  yaw=+104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $68,$00,$F6,$0A  ; seg 120  yaw=+104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $6E,$00,$F6,$0A  ; seg 121  yaw=+110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $74,$00,$F6,$0A  ; seg 122  yaw=+116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $7A,$00,$F6,$0A  ; seg 123  yaw=+122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 124  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 125  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FC,$F6,$0A  ; seg 126  yaw=-128 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 127  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
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
