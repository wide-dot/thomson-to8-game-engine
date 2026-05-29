* ======================================================================
* Circuit_14_medium_7 — N=112 segments (format compact 8 oct/seg)
* Source       : 14_medium_7.bin (extrait de FILE30)
*
* Pays         : ARGENTINA
* Lieu         : chacabuco, nr buenos aires
* Description  : another fast course with
* Hazards      : gentle hills
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000024 01:#B4906C 02:#906C48 03:#6C4824 04:#6C4800 05:#B40000 06:#240000 07:#240000
*   08:#484800 09:#D8D8D8 10:#240000 11:#FCFCFC 12:#246CD8 13:#486CB4 14:#486CB4 15:#6C6C90
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
* Taille totale : 1458 oct (nb_segments 2 + LUT 16 + segments 960 + cache 480).
* ======================================================================

Circuit_14_medium_7_nb_segments
        fdb   112

Circuit_14_medium_7_sprite_lut
        fcb   $00,$82,$83,$8F,$87,$80,$8B,$A2,$91,$81,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_14_medium_7_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$30,$00,$00,$00,$E0  ; seg   8                      flags=[PIT]   #3:$8F@-32
        fcb   $80,$00,$00,$30,$00,$00,$00,$DC  ; seg   9                      flags=[PIT]   #3:$8F@-36
        fcb   $80,$00,$00,$40,$00,$00,$00,$E4  ; seg  10                      flags=[PIT]   #3:$87@-28
        fcb   $80,$00,$00,$30,$00,$00,$00,$E8  ; seg  11                      flags=[PIT]   #3:$8F@-24
        fcb   $80,$00,$00,$30,$00,$00,$00,$EC  ; seg  12                      flags=[PIT]   #3:$8F@-20
        fcb   $80,$00,$00,$40,$00,$00,$00,$E4  ; seg  13                      flags=[PIT]   #3:$87@-28
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  14                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$35,$12,$00,$12,$EC  ; seg  15                                    #0:$80@+18 #2:$80@+18 #3:$8F@-20
        fcb   $04,$00,$05,$60,$12,$00,$00,$E8  ; seg  16  curve=+4                          #0:$80@+18 #3:$8B@-24
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg  17  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$40,$00,$00,$00,$EC  ; seg  18  curve=+4                          #3:$87@-20
        fcb   $04,$00,$00,$40,$00,$00,$00,$E4  ; seg  19  curve=+4                          #3:$87@-28
        fcb   $00,$00,$00,$60,$00,$00,$00,$E8  ; seg  20                                    #3:$8B@-24
        fcb   $00,$00,$00,$30,$00,$00,$00,$EC  ; seg  21                                    #3:$8F@-20
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  22                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  23                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$40,$12,$00,$00,$E8  ; seg  24  curve=+4                          #0:$80@+18 #3:$87@-24
        fcb   $04,$00,$05,$60,$12,$00,$00,$DC  ; seg  25  curve=+4                          #0:$80@+18 #3:$8B@-36
        fcb   $04,$00,$00,$60,$00,$00,$00,$E0  ; seg  26  curve=+4                          #3:$8B@-32
        fcb   $04,$00,$00,$30,$00,$00,$00,$D8  ; seg  27  curve=+4                          #3:$8F@-40
        fcb   $00,$01,$34,$43,$14,$24,$28,$1C  ; seg  28            pitch=+1                #0:$87@+20 #1:$8F@+36 #2:$8F@+40 #3:$87@+28
        fcb   $00,$01,$43,$44,$28,$1C,$20,$18  ; seg  29            pitch=+1                #0:$8F@+40 #1:$87@+28 #2:$87@+32 #3:$87@+24
        fcb   $00,$00,$43,$43,$14,$28,$14,$24  ; seg  30                                    #0:$8F@+20 #1:$87@+40 #2:$8F@+20 #3:$87@+36
        fcb   $00,$00,$33,$43,$2C,$14,$1C,$20  ; seg  31                                    #0:$8F@+44 #1:$8F@+20 #2:$8F@+28 #3:$87@+32
        fcb   $00,$00,$00,$60,$00,$00,$00,$1C  ; seg  32                                    #3:$8B@+28
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  33
        fcb   $00,$7F,$05,$35,$12,$00,$12,$2C  ; seg  34            pitch=-1                #0:$80@+18 #2:$80@+18 #3:$8F@+44
        fcb   $00,$7F,$05,$05,$12,$00,$12,$00  ; seg  35            pitch=-1                #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$60,$12,$00,$00,$28  ; seg  36  curve=+4                          #0:$80@+18 #3:$8B@+40
        fcb   $04,$00,$05,$40,$12,$00,$00,$14  ; seg  37  curve=+4                          #0:$80@+18 #3:$87@+20
        fcb   $04,$00,$00,$60,$00,$00,$00,$20  ; seg  38  curve=+4                          #3:$8B@+32
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  39  curve=+4
        fcb   $00,$00,$34,$33,$EC,$D4,$EC,$EC  ; seg  40                                    #0:$87@-20 #1:$8F@-44 #2:$8F@-20 #3:$8F@-20
        fcb   $00,$00,$34,$33,$D8,$EC,$D8,$D4  ; seg  41                                    #0:$87@-40 #1:$8F@-20 #2:$8F@-40 #3:$8F@-44
        fcb   $00,$00,$34,$44,$D4,$DC,$E4,$D8  ; seg  42                                    #0:$87@-44 #1:$8F@-36 #2:$87@-28 #3:$87@-40
        fcb   $00,$00,$33,$34,$E8,$D4,$E4,$EC  ; seg  43                                    #0:$8F@-24 #1:$8F@-44 #2:$87@-28 #3:$8F@-20
        fcb   $00,$00,$00,$70,$00,$00,$00,$E0  ; seg  44                                    #3:$A2@-32
        fcb   $00,$00,$00,$70,$00,$00,$00,$20  ; seg  45                                    #3:$A2@+32
        fcb   $00,$00,$05,$75,$12,$00,$12,$30  ; seg  46                                    #0:$80@+18 #2:$80@+18 #3:$A2@+48
        fcb   $00,$00,$05,$75,$12,$00,$12,$D8  ; seg  47                                    #0:$80@+18 #2:$80@+18 #3:$A2@-40
        fcb   $04,$00,$75,$70,$12,$24,$00,$18  ; seg  48  curve=+4                          #0:$80@+18 #1:$A2@+36 #3:$A2@+24
        fcb   $04,$00,$05,$70,$12,$00,$00,$20  ; seg  49  curve=+4                          #0:$80@+18 #3:$A2@+32
        fcb   $04,$00,$70,$70,$00,$D8,$00,$30  ; seg  50  curve=+4                          #1:$A2@-40 #3:$A2@+48
        fcb   $04,$00,$00,$70,$00,$00,$00,$28  ; seg  51  curve=+4                          #3:$A2@+40
        fcb   $00,$00,$08,$08,$12,$00,$12,$00  ; seg  52                                    #0:$91@+18 #2:$91@+18
        fcb   $00,$00,$08,$78,$12,$00,$12,$C8  ; seg  53                                    #0:$91@+18 #2:$91@+18 #3:$A2@-56
        fcb   $00,$7F,$08,$78,$EE,$00,$EE,$EC  ; seg  54            pitch=-1                #0:$91@-18 #2:$91@-18 #3:$A2@-20
        fcb   $00,$7F,$08,$08,$EE,$00,$EE,$00  ; seg  55            pitch=-1                #0:$91@-18 #2:$91@-18
        fcb   $00,$00,$08,$78,$12,$00,$12,$D8  ; seg  56                                    #0:$91@+18 #2:$91@+18 #3:$A2@-40
        fcb   $00,$00,$08,$08,$12,$00,$12,$00  ; seg  57                                    #0:$91@+18 #2:$91@+18
        fcb   $00,$7F,$08,$78,$EE,$00,$EE,$E0  ; seg  58            pitch=-1                #0:$91@-18 #2:$91@-18 #3:$A2@-32
        fcb   $00,$7F,$08,$08,$EE,$00,$EE,$00  ; seg  59            pitch=-1                #0:$91@-18 #2:$91@-18
        fcb   $00,$00,$00,$70,$00,$00,$00,$28  ; seg  60                                    #3:$A2@+40
        fcb   $00,$00,$70,$70,$00,$24,$00,$18  ; seg  61                                    #1:$A2@+36 #3:$A2@+24
        fcb   $00,$7F,$00,$70,$00,$00,$00,$E0  ; seg  62            pitch=-1                #3:$A2@-32
        fcb   $00,$7F,$70,$70,$00,$30,$00,$D8  ; seg  63            pitch=-1                #1:$A2@+48 #3:$A2@-40
        fcb   $00,$01,$00,$70,$00,$00,$00,$C8  ; seg  64            pitch=+1                #3:$A2@-56
        fcb   $00,$01,$00,$70,$00,$00,$00,$D0  ; seg  65            pitch=+1                #3:$A2@-48
        fcb   $00,$00,$70,$70,$00,$14,$00,$D8  ; seg  66                                    #1:$A2@+20 #3:$A2@-40
        fcb   $00,$00,$00,$70,$00,$00,$00,$C8  ; seg  67                                    #3:$A2@-56
        fcb   $00,$01,$43,$43,$28,$1C,$24,$28  ; seg  68            pitch=+1                #0:$8F@+40 #1:$87@+28 #2:$8F@+36 #3:$87@+40
        fcb   $00,$01,$33,$43,$1C,$18,$30,$24  ; seg  69            pitch=+1                #0:$8F@+28 #1:$8F@+24 #2:$8F@+48 #3:$87@+36
        fcb   $00,$00,$44,$33,$24,$24,$1C,$1C  ; seg  70                                    #0:$87@+36 #1:$87@+36 #2:$8F@+28 #3:$8F@+28
        fcb   $00,$00,$33,$44,$1C,$20,$28,$18  ; seg  71                                    #0:$8F@+28 #1:$8F@+32 #2:$87@+40 #3:$87@+24
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg  72            pitch=+1
        fcb   $00,$01,$00,$60,$00,$00,$00,$DC  ; seg  73            pitch=+1                #3:$8B@-36
        fcb   $00,$00,$05,$35,$12,$00,$12,$E0  ; seg  74                                    #0:$80@+18 #2:$80@+18 #3:$8F@-32
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  75                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$60,$12,$00,$00,$D8  ; seg  76  curve=+4                          #0:$80@+18 #3:$8B@-40
        fcb   $04,$00,$05,$30,$12,$00,$00,$D4  ; seg  77  curve=+4                          #0:$80@+18 #3:$8F@-44
        fcb   $04,$00,$00,$30,$00,$00,$00,$C8  ; seg  78  curve=+4                          #3:$8F@-56
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  79  curve=+4
        fcb   $00,$00,$05,$65,$12,$00,$12,$E0  ; seg  80                                    #0:$80@+18 #2:$80@+18 #3:$8B@-32
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  81                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$30,$12,$00,$00,$D4  ; seg  82  curve=+4                          #0:$80@+18 #3:$8F@-44
        fcb   $04,$00,$05,$30,$12,$00,$00,$20  ; seg  83  curve=+4                          #0:$80@+18 #3:$8F@+32
        fcb   $04,$00,$00,$60,$00,$00,$00,$38  ; seg  84  curve=+4                          #3:$8B@+56
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg  85  curve=+4
        fcb   $00,$01,$33,$34,$D8,$CC,$D4,$D4  ; seg  86            pitch=+1                #0:$8F@-40 #1:$8F@-52 #2:$87@-44 #3:$8F@-44
        fcb   $00,$01,$33,$34,$DC,$D8,$E8,$D8  ; seg  87            pitch=+1                #0:$8F@-36 #1:$8F@-40 #2:$87@-24 #3:$8F@-40
        fcb   $00,$00,$43,$44,$D8,$E4,$DC,$E4  ; seg  88                                    #0:$8F@-40 #1:$87@-28 #2:$87@-36 #3:$87@-28
        fcb   $00,$00,$33,$34,$E4,$D8,$EC,$DC  ; seg  89                                    #0:$8F@-28 #1:$8F@-40 #2:$87@-20 #3:$8F@-36
        fcb   $00,$00,$00,$30,$00,$00,$00,$20  ; seg  90                                    #3:$8F@+32
        fcb   $00,$00,$00,$60,$00,$00,$00,$18  ; seg  91                                    #3:$8B@+24
        fcb   $00,$7F,$09,$39,$EE,$00,$EE,$20  ; seg  92            pitch=-1                #0:$81@-18 #2:$81@-18 #3:$8F@+32
        fcb   $00,$7F,$09,$39,$EE,$00,$EE,$28  ; seg  93            pitch=-1                #0:$81@-18 #2:$81@-18 #3:$8F@+40
        fcb   $04,$00,$09,$00,$EE,$00,$00,$00  ; seg  94  curve=+4                          #0:$81@-18
        fcb   $04,$00,$09,$60,$EE,$00,$00,$38  ; seg  95  curve=+4                          #0:$81@-18 #3:$8B@+56
        fcb   $04,$00,$00,$30,$00,$00,$00,$D0  ; seg  96  curve=+4                          #3:$8F@-48
        fcb   $04,$00,$00,$30,$00,$00,$00,$20  ; seg  97  curve=+4                          #3:$8F@+32
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  98                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  99                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$40,$12,$00,$00,$30  ; seg 100  curve=+4                          #0:$80@+18 #3:$87@+48
        fcb   $04,$00,$05,$30,$12,$00,$00,$2C  ; seg 101  curve=+4                          #0:$80@+18 #3:$8F@+44
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 102  curve=+4
        fcb   $04,$00,$00,$60,$00,$00,$00,$20  ; seg 103  curve=+4                          #3:$8B@+32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 104
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 105
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 106
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 107
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 108
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 109
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 110
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 111
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 112                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 113
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 114
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 115
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 116                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 117                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 118                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 119                                    #0:$83@+18 #2:$83@+18

Circuit_14_medium_7_segment_cache
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
        fcb   $04,$00,$F6,$0A  ; seg  17  yaw=  +4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  18  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$00,$F6,$0A  ; seg  19  yaw= +12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  20  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  21  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  22  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  23  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  24  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg  25  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $18,$00,$F6,$0A  ; seg  26  yaw= +24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1C,$00,$F6,$0A  ; seg  27  yaw= +28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  28  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$01,$F6,$0A  ; seg  29  yaw= +32 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $20,$02,$F6,$0A  ; seg  30  yaw= +32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $20,$02,$F6,$0A  ; seg  31  yaw= +32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $20,$02,$F6,$0A  ; seg  32  yaw= +32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $20,$02,$F6,$0A  ; seg  33  yaw= +32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $20,$02,$F6,$0A  ; seg  34  yaw= +32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $20,$01,$F6,$0A  ; seg  35  yaw= +32 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  36  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $24,$00,$F6,$0A  ; seg  37  yaw= +36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  38  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$00,$F6,$0A  ; seg  39  yaw= +44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  40  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  41  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  42  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  43  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  44  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  45  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  46  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  47  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  48  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  49  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  50  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  51  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  52  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  53  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  54  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$FF,$F6,$0A  ; seg  55  yaw= +64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $40,$FE,$F6,$0A  ; seg  56  yaw= +64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $40,$FE,$F6,$0A  ; seg  57  yaw= +64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $40,$FE,$F6,$0A  ; seg  58  yaw= +64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $40,$FD,$F6,$0A  ; seg  59  yaw= +64 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $40,$FC,$F6,$0A  ; seg  60  yaw= +64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $40,$FC,$F6,$0A  ; seg  61  yaw= +64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $40,$FC,$F6,$0A  ; seg  62  yaw= +64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $40,$FB,$F6,$0A  ; seg  63  yaw= +64 pitch=  -5 min_lat= -10 max_lat= +10
        fcb   $40,$FA,$F6,$0A  ; seg  64  yaw= +64 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $40,$FB,$F6,$0A  ; seg  65  yaw= +64 pitch=  -5 min_lat= -10 max_lat= +10
        fcb   $40,$FC,$F6,$0A  ; seg  66  yaw= +64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $40,$FC,$F6,$0A  ; seg  67  yaw= +64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $40,$FC,$F6,$0A  ; seg  68  yaw= +64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $40,$FD,$F6,$0A  ; seg  69  yaw= +64 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $40,$FE,$F6,$0A  ; seg  70  yaw= +64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $40,$FE,$F6,$0A  ; seg  71  yaw= +64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $40,$FE,$F6,$0A  ; seg  72  yaw= +64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $40,$FF,$F6,$0A  ; seg  73  yaw= +64 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  74  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  75  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  76  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $44,$00,$F6,$0A  ; seg  77  yaw= +68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $48,$00,$F6,$0A  ; seg  78  yaw= +72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $4C,$00,$F6,$0A  ; seg  79  yaw= +76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  80  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  81  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg  82  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $54,$00,$F6,$0A  ; seg  83  yaw= +84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $58,$00,$F6,$0A  ; seg  84  yaw= +88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $5C,$00,$F6,$0A  ; seg  85  yaw= +92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg  86  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$01,$F6,$0A  ; seg  87  yaw= +96 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $60,$02,$F6,$0A  ; seg  88  yaw= +96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $60,$02,$F6,$0A  ; seg  89  yaw= +96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $60,$02,$F6,$0A  ; seg  90  yaw= +96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $60,$02,$F6,$0A  ; seg  91  yaw= +96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $60,$02,$F6,$0A  ; seg  92  yaw= +96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $60,$01,$F6,$0A  ; seg  93  yaw= +96 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg  94  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $64,$00,$F6,$0A  ; seg  95  yaw=+100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $68,$00,$F6,$0A  ; seg  96  yaw=+104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $6C,$00,$F6,$0A  ; seg  97  yaw=+108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $70,$00,$F6,$0A  ; seg  98  yaw=+112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $70,$00,$F6,$0A  ; seg  99  yaw=+112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $70,$00,$F6,$0A  ; seg 100  yaw=+112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $74,$00,$F6,$0A  ; seg 101  yaw=+116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $78,$00,$F6,$0A  ; seg 102  yaw=+120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $7C,$00,$F6,$0A  ; seg 103  yaw=+124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 104  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 105  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 106  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 107  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 108  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 109  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 110  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 111  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 112 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 113 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 114 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 115 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 116 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 117 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 118 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 119 (wraparound de seg 7)
