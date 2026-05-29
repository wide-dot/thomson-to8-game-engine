* ======================================================================
* Circuit_28_hard_11 — N=184 segments (format compact 8 oct/seg)
* Source       : 28_hard_11.bin (extrait de FILE30)
*
* Pays         : RUSSIA
* Lieu         : obozerskiy
* Description  : lane closures, diversions and
* Hazards      : pools of water on bumpy road
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
* Taille totale : 2322 oct (nb_segments 2 + LUT 16 + segments 1536 + cache 768).
* ======================================================================

Circuit_28_hard_11_nb_segments
        fdb   184

Circuit_28_hard_11_sprite_lut
        fcb   $00,$82,$83,$98,$A1,$A0,$81,$9F,$80,$A3,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_28_hard_11_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg   8                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg   9                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  10                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  11                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  12                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  13                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  14                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  15                      flags=[PIT]
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  16                                    #0:$98@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  17                                    #0:$98@-20
        fcb   $00,$00,$44,$44,$EE,$F0,$F2,$F4  ; seg  18                                    #0:$A1@-18 #1:$A1@-16 #2:$A1@-14 #3:$A1@-12
        fcb   $00,$00,$44,$44,$F6,$F8,$FA,$FC  ; seg  19                                    #0:$A1@-10 #1:$A1@-8 #2:$A1@-6 #3:$A1@-4
        fcb   $00,$7F,$03,$00,$EC,$00,$00,$00  ; seg  20            pitch=-1                #0:$98@-20
        fcb   $00,$7F,$55,$55,$12,$10,$0E,$0C  ; seg  21            pitch=-1                #0:$A0@+18 #1:$A0@+16 #2:$A0@+14 #3:$A0@+12
        fcb   $00,$7F,$55,$55,$0A,$08,$06,$04  ; seg  22            pitch=-1                #0:$A0@+10 #1:$A0@+8 #2:$A0@+6 #3:$A0@+4
        fcb   $00,$7F,$03,$00,$EC,$00,$00,$00  ; seg  23            pitch=-1                #0:$98@-20
        fcb   $00,$01,$44,$44,$EE,$F0,$F2,$F4  ; seg  24            pitch=+1                #0:$A1@-18 #1:$A1@-16 #2:$A1@-14 #3:$A1@-12
        fcb   $00,$01,$44,$44,$F6,$F8,$FA,$FC  ; seg  25            pitch=+1                #0:$A1@-10 #1:$A1@-8 #2:$A1@-6 #3:$A1@-4
        fcb   $00,$01,$03,$00,$14,$00,$00,$00  ; seg  26            pitch=+1                #0:$98@+20
        fcb   $00,$01,$03,$00,$14,$00,$00,$00  ; seg  27            pitch=+1                #0:$98@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  28                                    #0:$98@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  29                                    #0:$98@+20
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  30                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  31                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  32  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  33  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  34  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$56,$55,$EE,$0C,$0A,$08  ; seg  35  curve=-4                          #0:$81@-18 #1:$A0@+12 #2:$A0@+10 #3:$A0@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  36  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  37  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  38  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  39  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  40  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  41  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  42  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  43  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  44  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$76,$70,$EE,$08,$00,$08  ; seg  45  curve=-4                          #0:$81@-18 #1:$9F@+8 #3:$9F@+8
        fcb   $7C,$00,$03,$00,$14,$00,$00,$00  ; seg  46  curve=-4                          #0:$98@+20
        fcb   $7C,$00,$03,$00,$14,$00,$00,$00  ; seg  47  curve=-4                          #0:$98@+20
        fcb   $00,$00,$44,$44,$EE,$F0,$F2,$F4  ; seg  48                                    #0:$A1@-18 #1:$A1@-16 #2:$A1@-14 #3:$A1@-12
        fcb   $00,$00,$44,$44,$F6,$F8,$FA,$FC  ; seg  49                                    #0:$A1@-10 #1:$A1@-8 #2:$A1@-6 #3:$A1@-4
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  50                                    #0:$98@+20
        fcb   $00,$00,$55,$55,$12,$10,$0E,$0C  ; seg  51                                    #0:$A0@+18 #1:$A0@+16 #2:$A0@+14 #3:$A0@+12
        fcb   $00,$01,$55,$55,$0A,$08,$06,$04  ; seg  52            pitch=+1                #0:$A0@+10 #1:$A0@+8 #2:$A0@+6 #3:$A0@+4
        fcb   $00,$01,$03,$00,$14,$00,$00,$00  ; seg  53            pitch=+1                #0:$98@+20
        fcb   $00,$01,$88,$88,$12,$12,$12,$12  ; seg  54            pitch=+1                #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$01,$88,$88,$12,$12,$12,$12  ; seg  55            pitch=+1                #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  56  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  57  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  58  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  59  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  60  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  61  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$03,$00,$EC,$00,$00,$00  ; seg  62  curve=+6                          #0:$98@-20
        fcb   $06,$00,$03,$00,$EC,$00,$00,$00  ; seg  63  curve=+6                          #0:$98@-20
        fcb   $00,$7F,$99,$99,$F6,$F4,$FC,$FA  ; seg  64            pitch=-1                #0:$A3@-10 #1:$A3@-12 #2:$A3@-4 #3:$A3@-6
        fcb   $00,$7F,$99,$99,$FA,$F8,$F4,$FC  ; seg  65            pitch=-1                #0:$A3@-6 #1:$A3@-8 #2:$A3@-12 #3:$A3@-4
        fcb   $00,$7F,$99,$99,$FC,$FA,$F4,$F8  ; seg  66            pitch=-1                #0:$A3@-4 #1:$A3@-6 #2:$A3@-12 #3:$A3@-8
        fcb   $00,$7F,$99,$99,$F4,$F6,$FA,$F4  ; seg  67            pitch=-1                #0:$A3@-12 #1:$A3@-10 #2:$A3@-6 #3:$A3@-12
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  68                                    #0:$98@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  69                                    #0:$98@-20
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  70                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg  71                                    #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg  72  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg  73  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$99,$99,$04,$06,$0C,$04  ; seg  74  curve=-5                          #0:$A3@+4 #1:$A3@+6 #2:$A3@+12 #3:$A3@+4
        fcb   $7B,$00,$99,$99,$08,$0A,$04,$0C  ; seg  75  curve=-5                          #0:$A3@+8 #1:$A3@+10 #2:$A3@+4 #3:$A3@+12
        fcb   $00,$01,$03,$00,$EC,$00,$00,$00  ; seg  76            pitch=+1                #0:$98@-20
        fcb   $00,$01,$03,$00,$EC,$00,$00,$00  ; seg  77            pitch=+1                #0:$98@-20
        fcb   $00,$01,$06,$06,$EE,$00,$EE,$00  ; seg  78            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $00,$01,$06,$06,$EE,$00,$EE,$00  ; seg  79            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg  80  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg  81  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$99,$99,$0C,$06,$0C,$04  ; seg  82  curve=-5                          #0:$A3@+12 #1:$A3@+6 #2:$A3@+12 #3:$A3@+4
        fcb   $7B,$00,$99,$99,$0A,$04,$06,$08  ; seg  83  curve=-5                          #0:$A3@+10 #1:$A3@+4 #2:$A3@+6 #3:$A3@+8
        fcb   $00,$7F,$03,$00,$EC,$00,$00,$00  ; seg  84            pitch=-1                #0:$98@-20
        fcb   $00,$7F,$03,$00,$EC,$00,$00,$00  ; seg  85            pitch=-1                #0:$98@-20
        fcb   $00,$7F,$06,$06,$EE,$00,$EE,$00  ; seg  86            pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $00,$7F,$06,$06,$EE,$00,$EE,$00  ; seg  87            pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  88  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  89  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$99,$99,$0A,$04,$0C,$08  ; seg  90  curve=-4                          #0:$A3@+10 #1:$A3@+4 #2:$A3@+12 #3:$A3@+8
        fcb   $7C,$00,$99,$99,$0A,$04,$0A,$04  ; seg  91  curve=-4                          #0:$A3@+10 #1:$A3@+4 #2:$A3@+10 #3:$A3@+4
        fcb   $7C,$00,$99,$99,$0A,$04,$06,$08  ; seg  92  curve=-4                          #0:$A3@+10 #1:$A3@+4 #2:$A3@+6 #3:$A3@+8
        fcb   $7C,$00,$99,$99,$06,$0C,$0C,$04  ; seg  93  curve=-4                          #0:$A3@+6 #1:$A3@+12 #2:$A3@+12 #3:$A3@+4
        fcb   $7C,$00,$03,$00,$14,$00,$00,$00  ; seg  94  curve=-4                          #0:$98@+20
        fcb   $7C,$00,$03,$00,$14,$00,$00,$00  ; seg  95  curve=-4                          #0:$98@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  96                                    #0:$98@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  97                                    #0:$98@+20
        fcb   $00,$00,$44,$44,$EE,$F0,$F2,$F4  ; seg  98                                    #0:$A1@-18 #1:$A1@-16 #2:$A1@-14 #3:$A1@-12
        fcb   $00,$00,$44,$44,$F6,$F8,$FA,$FC  ; seg  99                                    #0:$A1@-10 #1:$A1@-8 #2:$A1@-6 #3:$A1@-4
        fcb   $00,$7F,$03,$00,$14,$00,$00,$00  ; seg 100            pitch=-1                #0:$98@+20
        fcb   $00,$7F,$55,$55,$12,$10,$0E,$0C  ; seg 101            pitch=-1                #0:$A0@+18 #1:$A0@+16 #2:$A0@+14 #3:$A0@+12
        fcb   $00,$7F,$55,$55,$0A,$08,$06,$04  ; seg 102            pitch=-1                #0:$A0@+10 #1:$A0@+8 #2:$A0@+6 #3:$A0@+4
        fcb   $00,$7F,$03,$00,$14,$00,$00,$00  ; seg 103            pitch=-1                #0:$98@+20
        fcb   $00,$01,$03,$00,$14,$00,$00,$00  ; seg 104            pitch=+1                #0:$98@+20
        fcb   $00,$01,$44,$44,$EE,$F0,$F2,$F4  ; seg 105            pitch=+1                #0:$A1@-18 #1:$A1@-16 #2:$A1@-14 #3:$A1@-12
        fcb   $00,$01,$44,$44,$F6,$F8,$FA,$FC  ; seg 106            pitch=+1                #0:$A1@-10 #1:$A1@-8 #2:$A1@-6 #3:$A1@-4
        fcb   $00,$01,$03,$00,$14,$00,$00,$00  ; seg 107            pitch=+1                #0:$98@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 108                                    #0:$98@+20
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 109                                    #0:$98@+20
        fcb   $00,$00,$88,$88,$12,$12,$12,$12  ; seg 110                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$88,$88,$12,$12,$12,$12  ; seg 111                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg 112  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg 113  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg 114  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg 115  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg 116  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg 117  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$03,$00,$EC,$00,$00,$00  ; seg 118  curve=+6                          #0:$98@-20
        fcb   $06,$00,$03,$00,$EC,$00,$00,$00  ; seg 119  curve=+6                          #0:$98@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 120                                    #0:$98@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 121                                    #0:$98@-20
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 122                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 123                                    #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg 124  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg 125  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg 126  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg 127  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg 128  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$06,$00,$EE,$00,$00,$00  ; seg 129  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$03,$00,$EC,$00,$00,$00  ; seg 130  curve=-5                          #0:$98@-20
        fcb   $7B,$00,$03,$00,$EC,$00,$00,$00  ; seg 131  curve=-5                          #0:$98@-20
        fcb   $00,$01,$03,$00,$EC,$00,$00,$00  ; seg 132            pitch=+1                #0:$98@-20
        fcb   $00,$01,$03,$00,$EC,$00,$00,$00  ; seg 133            pitch=+1                #0:$98@-20
        fcb   $00,$01,$55,$55,$12,$10,$0E,$0C  ; seg 134            pitch=+1                #0:$A0@+18 #1:$A0@+16 #2:$A0@+14 #3:$A0@+12
        fcb   $00,$01,$55,$55,$0A,$08,$06,$04  ; seg 135            pitch=+1                #0:$A0@+10 #1:$A0@+8 #2:$A0@+6 #3:$A0@+4
        fcb   $00,$7F,$03,$00,$14,$00,$00,$00  ; seg 136            pitch=-1                #0:$98@+20
        fcb   $00,$7F,$44,$44,$EE,$F0,$F2,$F4  ; seg 137            pitch=-1                #0:$A1@-18 #1:$A1@-16 #2:$A1@-14 #3:$A1@-12
        fcb   $00,$7F,$44,$44,$F6,$F8,$FA,$FC  ; seg 138            pitch=-1                #0:$A1@-10 #1:$A1@-8 #2:$A1@-6 #3:$A1@-4
        fcb   $00,$7F,$03,$00,$14,$00,$00,$00  ; seg 139            pitch=-1                #0:$98@+20
        fcb   $00,$00,$55,$55,$12,$10,$0E,$0C  ; seg 140                                    #0:$A0@+18 #1:$A0@+16 #2:$A0@+14 #3:$A0@+12
        fcb   $00,$00,$55,$55,$0A,$08,$06,$04  ; seg 141                                    #0:$A0@+10 #1:$A0@+8 #2:$A0@+6 #3:$A0@+4
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 142                                    #0:$98@+20
        fcb   $00,$00,$44,$44,$EE,$F0,$F2,$F4  ; seg 143                                    #0:$A1@-18 #1:$A1@-16 #2:$A1@-14 #3:$A1@-12
        fcb   $00,$00,$44,$44,$F6,$F8,$FA,$FC  ; seg 144                                    #0:$A1@-10 #1:$A1@-8 #2:$A1@-6 #3:$A1@-4
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 145                                    #0:$98@-20
        fcb   $00,$00,$55,$55,$12,$10,$0E,$0C  ; seg 146                                    #0:$A0@+18 #1:$A0@+16 #2:$A0@+14 #3:$A0@+12
        fcb   $00,$00,$55,$55,$0A,$08,$06,$04  ; seg 147                                    #0:$A0@+10 #1:$A0@+8 #2:$A0@+6 #3:$A0@+4
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 148                                    #0:$98@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 149                                    #0:$98@-20
        fcb   $00,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg 150                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg 151                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg 152  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg 153  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg 154  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg 155  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg 156  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg 157  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$00,$EC,$00,$00,$00  ; seg 158  curve=-6                          #0:$98@-20
        fcb   $7A,$00,$03,$00,$EC,$00,$00,$00  ; seg 159  curve=-6                          #0:$98@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 160                                    #0:$98@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 161                                    #0:$98@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 162                                    #0:$98@-20
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 163                                    #0:$98@-20
        fcb   $00,$00,$03,$07,$14,$00,$F8,$00  ; seg 164                                    #0:$98@+20 #2:$9F@-8
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 165                                    #0:$98@+20
        fcb   $00,$00,$03,$07,$14,$00,$08,$00  ; seg 166                                    #0:$98@+20 #2:$9F@+8
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg 167                                    #0:$98@+20
        fcb   $00,$02,$03,$07,$14,$00,$FE,$00  ; seg 168            pitch=+2                #0:$98@+20 #2:$9F@-2
        fcb   $00,$02,$03,$00,$14,$00,$00,$00  ; seg 169            pitch=+2                #0:$98@+20
        fcb   $00,$02,$03,$07,$EC,$00,$02,$00  ; seg 170            pitch=+2                #0:$98@-20 #2:$9F@+2
        fcb   $00,$02,$03,$00,$EC,$00,$00,$00  ; seg 171            pitch=+2                #0:$98@-20
        fcb   $00,$7E,$03,$07,$EC,$00,$08,$00  ; seg 172            pitch=-2                #0:$98@-20 #2:$9F@+8
        fcb   $00,$7E,$03,$00,$EC,$00,$00,$00  ; seg 173            pitch=-2                #0:$98@-20
        fcb   $00,$7E,$03,$07,$EC,$00,$F8,$00  ; seg 174            pitch=-2                #0:$98@-20 #2:$9F@-8
        fcb   $00,$7E,$03,$00,$EC,$00,$00,$00  ; seg 175            pitch=-2                #0:$98@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 176
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 177
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 178
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 179
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 180
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 181
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 182
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 183
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 184                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 185
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 186
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 187
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 188                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 189                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 190                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 191                                    #0:$83@+18 #2:$83@+18

Circuit_28_hard_11_segment_cache
        fcb   $00,$00,$F6,$0A  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   1  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   2  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   3  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   4  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   5  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F7,$0A  ; seg   6  yaw=  +0 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $00,$00,$F8,$0A  ; seg   7  yaw=  +0 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $00,$00,$F9,$0A  ; seg   8  yaw=  +0 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $00,$00,$FA,$09  ; seg   9  yaw=  +0 pitch=  +0 min_lat=  -6 max_lat=  +9
        fcb   $00,$00,$FB,$08  ; seg  10  yaw=  +0 pitch=  +0 min_lat=  -5 max_lat=  +8
        fcb   $00,$00,$FC,$07  ; seg  11  yaw=  +0 pitch=  +0 min_lat=  -4 max_lat=  +7
        fcb   $00,$00,$FD,$06  ; seg  12  yaw=  +0 pitch=  +0 min_lat=  -3 max_lat=  +6
        fcb   $00,$00,$FE,$05  ; seg  13  yaw=  +0 pitch=  +0 min_lat=  -2 max_lat=  +5
        fcb   $00,$00,$FF,$04  ; seg  14  yaw=  +0 pitch=  +0 min_lat=  -1 max_lat=  +4
        fcb   $00,$00,$00,$03  ; seg  15  yaw=  +0 pitch=  +0 min_lat=  +0 max_lat=  +3
        fcb   $00,$00,$01,$02  ; seg  16  yaw=  +0 pitch=  +0 min_lat=  +1 max_lat=  +2
        fcb   $00,$00,$02,$01  ; seg  17  yaw=  +0 pitch=  +0 min_lat=  +2 max_lat=  +1
        fcb   $00,$00,$03,$00  ; seg  18  yaw=  +0 pitch=  +0 min_lat=  +3 max_lat=  +0
        fcb   $00,$00,$04,$FF  ; seg  19  yaw=  +0 pitch=  +0 min_lat=  +4 max_lat=  -1
        fcb   $00,$00,$FF,$FE  ; seg  20  yaw=  +0 pitch=  +0 min_lat=  -1 max_lat=  -2
        fcb   $00,$FF,$00,$FD  ; seg  21  yaw=  +0 pitch=  -1 min_lat=  +0 max_lat=  -3
        fcb   $00,$FE,$01,$FC  ; seg  22  yaw=  +0 pitch=  -2 min_lat=  +1 max_lat=  -4
        fcb   $00,$FD,$02,$0A  ; seg  23  yaw=  +0 pitch=  -3 min_lat=  +2 max_lat= +10
        fcb   $00,$FC,$03,$0A  ; seg  24  yaw=  +0 pitch=  -4 min_lat=  +3 max_lat= +10
        fcb   $00,$FD,$04,$0A  ; seg  25  yaw=  +0 pitch=  -3 min_lat=  +4 max_lat= +10
        fcb   $00,$FE,$F6,$09  ; seg  26  yaw=  +0 pitch=  -2 min_lat= -10 max_lat=  +9
        fcb   $00,$FF,$F6,$08  ; seg  27  yaw=  +0 pitch=  -1 min_lat= -10 max_lat=  +8
        fcb   $00,$00,$F6,$07  ; seg  28  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $00,$00,$F6,$06  ; seg  29  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $00,$00,$F6,$05  ; seg  30  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $00,$00,$F6,$04  ; seg  31  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $00,$00,$F6,$03  ; seg  32  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $FC,$00,$F6,$02  ; seg  33  yaw=  -4 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $F8,$00,$F6,$01  ; seg  34  yaw=  -8 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $F4,$00,$F6,$00  ; seg  35  yaw= -12 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $F0,$00,$F7,$00  ; seg  36  yaw= -16 pitch=  +0 min_lat=  -9 max_lat=  +0
        fcb   $EC,$00,$F8,$00  ; seg  37  yaw= -20 pitch=  +0 min_lat=  -8 max_lat=  +0
        fcb   $E8,$00,$F9,$00  ; seg  38  yaw= -24 pitch=  +0 min_lat=  -7 max_lat=  +0
        fcb   $E4,$00,$FA,$00  ; seg  39  yaw= -28 pitch=  +0 min_lat=  -6 max_lat=  +0
        fcb   $E0,$00,$FB,$00  ; seg  40  yaw= -32 pitch=  +0 min_lat=  -5 max_lat=  +0
        fcb   $DC,$00,$FC,$00  ; seg  41  yaw= -36 pitch=  +0 min_lat=  -4 max_lat=  +0
        fcb   $D8,$00,$FD,$00  ; seg  42  yaw= -40 pitch=  +0 min_lat=  -3 max_lat=  +0
        fcb   $D4,$00,$FE,$00  ; seg  43  yaw= -44 pitch=  +0 min_lat=  -2 max_lat=  +0
        fcb   $D0,$00,$FF,$00  ; seg  44  yaw= -48 pitch=  +0 min_lat=  -1 max_lat=  +0
        fcb   $CC,$00,$00,$00  ; seg  45  yaw= -52 pitch=  +0 min_lat=  +0 max_lat=  +0
        fcb   $C8,$00,$01,$02  ; seg  46  yaw= -56 pitch=  +0 min_lat=  +1 max_lat=  +2
        fcb   $C4,$00,$02,$01  ; seg  47  yaw= -60 pitch=  +0 min_lat=  +2 max_lat=  +1
        fcb   $C0,$00,$03,$00  ; seg  48  yaw= -64 pitch=  +0 min_lat=  +3 max_lat=  +0
        fcb   $C0,$00,$04,$FF  ; seg  49  yaw= -64 pitch=  +0 min_lat=  +4 max_lat=  -1
        fcb   $C0,$00,$F6,$FE  ; seg  50  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $C0,$00,$F7,$FD  ; seg  51  yaw= -64 pitch=  +0 min_lat=  -9 max_lat=  -3
        fcb   $C0,$00,$F8,$FC  ; seg  52  yaw= -64 pitch=  +0 min_lat=  -8 max_lat=  -4
        fcb   $C0,$01,$F9,$0A  ; seg  53  yaw= -64 pitch=  +1 min_lat=  -7 max_lat= +10
        fcb   $C0,$02,$FA,$0A  ; seg  54  yaw= -64 pitch=  +2 min_lat=  -6 max_lat= +10
        fcb   $C0,$03,$FB,$0A  ; seg  55  yaw= -64 pitch=  +3 min_lat=  -5 max_lat= +10
        fcb   $C0,$04,$FC,$0A  ; seg  56  yaw= -64 pitch=  +4 min_lat=  -4 max_lat= +10
        fcb   $C6,$04,$FD,$0A  ; seg  57  yaw= -58 pitch=  +4 min_lat=  -3 max_lat= +10
        fcb   $CC,$04,$FE,$0A  ; seg  58  yaw= -52 pitch=  +4 min_lat=  -2 max_lat= +10
        fcb   $D2,$04,$FF,$0A  ; seg  59  yaw= -46 pitch=  +4 min_lat=  -1 max_lat= +10
        fcb   $D8,$04,$00,$0A  ; seg  60  yaw= -40 pitch=  +4 min_lat=  +0 max_lat= +10
        fcb   $DE,$04,$01,$09  ; seg  61  yaw= -34 pitch=  +4 min_lat=  +1 max_lat=  +9
        fcb   $E4,$04,$02,$08  ; seg  62  yaw= -28 pitch=  +4 min_lat=  +2 max_lat=  +8
        fcb   $EA,$04,$03,$07  ; seg  63  yaw= -22 pitch=  +4 min_lat=  +3 max_lat=  +7
        fcb   $F0,$04,$04,$06  ; seg  64  yaw= -16 pitch=  +4 min_lat=  +4 max_lat=  +6
        fcb   $F0,$03,$04,$05  ; seg  65  yaw= -16 pitch=  +3 min_lat=  +4 max_lat=  +5
        fcb   $F0,$02,$04,$04  ; seg  66  yaw= -16 pitch=  +2 min_lat=  +4 max_lat=  +4
        fcb   $F0,$01,$02,$03  ; seg  67  yaw= -16 pitch=  +1 min_lat=  +2 max_lat=  +3
        fcb   $F0,$00,$F6,$02  ; seg  68  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $F0,$00,$F6,$01  ; seg  69  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $F0,$00,$F6,$00  ; seg  70  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $F0,$00,$F6,$FF  ; seg  71  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $F0,$00,$F6,$FE  ; seg  72  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $EB,$00,$F6,$FD  ; seg  73  yaw= -21 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $E6,$00,$F6,$FC  ; seg  74  yaw= -26 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $E1,$00,$F6,$FC  ; seg  75  yaw= -31 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $DC,$00,$F6,$02  ; seg  76  yaw= -36 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $DC,$01,$F6,$01  ; seg  77  yaw= -36 pitch=  +1 min_lat= -10 max_lat=  +1
        fcb   $DC,$02,$F6,$00  ; seg  78  yaw= -36 pitch=  +2 min_lat= -10 max_lat=  +0
        fcb   $DC,$03,$F6,$FF  ; seg  79  yaw= -36 pitch=  +3 min_lat= -10 max_lat=  -1
        fcb   $DC,$04,$F6,$FE  ; seg  80  yaw= -36 pitch=  +4 min_lat= -10 max_lat=  -2
        fcb   $D7,$04,$F6,$FD  ; seg  81  yaw= -41 pitch=  +4 min_lat= -10 max_lat=  -3
        fcb   $D2,$04,$F6,$FC  ; seg  82  yaw= -46 pitch=  +4 min_lat= -10 max_lat=  -4
        fcb   $CD,$04,$F6,$FC  ; seg  83  yaw= -51 pitch=  +4 min_lat= -10 max_lat=  -4
        fcb   $C8,$04,$F6,$02  ; seg  84  yaw= -56 pitch=  +4 min_lat= -10 max_lat=  +2
        fcb   $C8,$03,$F6,$01  ; seg  85  yaw= -56 pitch=  +3 min_lat= -10 max_lat=  +1
        fcb   $C8,$02,$F7,$00  ; seg  86  yaw= -56 pitch=  +2 min_lat=  -9 max_lat=  +0
        fcb   $C8,$01,$F8,$FF  ; seg  87  yaw= -56 pitch=  +1 min_lat=  -8 max_lat=  -1
        fcb   $C8,$00,$F9,$FE  ; seg  88  yaw= -56 pitch=  +0 min_lat=  -7 max_lat=  -2
        fcb   $C4,$00,$FA,$FD  ; seg  89  yaw= -60 pitch=  +0 min_lat=  -6 max_lat=  -3
        fcb   $C0,$00,$FB,$FC  ; seg  90  yaw= -64 pitch=  +0 min_lat=  -5 max_lat=  -4
        fcb   $BC,$00,$FC,$FC  ; seg  91  yaw= -68 pitch=  +0 min_lat=  -4 max_lat=  -4
        fcb   $B8,$00,$FD,$FC  ; seg  92  yaw= -72 pitch=  +0 min_lat=  -3 max_lat=  -4
        fcb   $B4,$00,$FE,$FC  ; seg  93  yaw= -76 pitch=  +0 min_lat=  -2 max_lat=  -4
        fcb   $B0,$00,$FF,$04  ; seg  94  yaw= -80 pitch=  +0 min_lat=  -1 max_lat=  +4
        fcb   $AC,$00,$00,$03  ; seg  95  yaw= -84 pitch=  +0 min_lat=  +0 max_lat=  +3
        fcb   $A8,$00,$01,$02  ; seg  96  yaw= -88 pitch=  +0 min_lat=  +1 max_lat=  +2
        fcb   $A8,$00,$02,$01  ; seg  97  yaw= -88 pitch=  +0 min_lat=  +2 max_lat=  +1
        fcb   $A8,$00,$03,$00  ; seg  98  yaw= -88 pitch=  +0 min_lat=  +3 max_lat=  +0
        fcb   $A8,$00,$04,$FF  ; seg  99  yaw= -88 pitch=  +0 min_lat=  +4 max_lat=  -1
        fcb   $A8,$00,$FE,$FE  ; seg 100  yaw= -88 pitch=  +0 min_lat=  -2 max_lat=  -2
        fcb   $A8,$FF,$FF,$FD  ; seg 101  yaw= -88 pitch=  -1 min_lat=  -1 max_lat=  -3
        fcb   $A8,$FE,$00,$FC  ; seg 102  yaw= -88 pitch=  -2 min_lat=  +0 max_lat=  -4
        fcb   $A8,$FD,$01,$0A  ; seg 103  yaw= -88 pitch=  -3 min_lat=  +1 max_lat= +10
        fcb   $A8,$FC,$02,$0A  ; seg 104  yaw= -88 pitch=  -4 min_lat=  +2 max_lat= +10
        fcb   $A8,$FD,$03,$0A  ; seg 105  yaw= -88 pitch=  -3 min_lat=  +3 max_lat= +10
        fcb   $A8,$FE,$04,$0A  ; seg 106  yaw= -88 pitch=  -2 min_lat=  +4 max_lat= +10
        fcb   $A8,$FF,$F6,$0A  ; seg 107  yaw= -88 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 108  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 109  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 110  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 111  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 112  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$0A  ; seg 113  yaw= -82 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 114  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg 115  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 116  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C6,$00,$F6,$0A  ; seg 117  yaw= -58 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg 118  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D2,$00,$F6,$0A  ; seg 119  yaw= -46 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg 120  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg 121  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$09  ; seg 122  yaw= -40 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $D8,$00,$F6,$08  ; seg 123  yaw= -40 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $D8,$00,$F6,$07  ; seg 124  yaw= -40 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $D3,$00,$F7,$06  ; seg 125  yaw= -45 pitch=  +0 min_lat=  -9 max_lat=  +6
        fcb   $CE,$00,$F8,$05  ; seg 126  yaw= -50 pitch=  +0 min_lat=  -8 max_lat=  +5
        fcb   $C9,$00,$F9,$04  ; seg 127  yaw= -55 pitch=  +0 min_lat=  -7 max_lat=  +4
        fcb   $C4,$00,$FA,$03  ; seg 128  yaw= -60 pitch=  +0 min_lat=  -6 max_lat=  +3
        fcb   $BF,$00,$FB,$02  ; seg 129  yaw= -65 pitch=  +0 min_lat=  -5 max_lat=  +2
        fcb   $BA,$00,$FC,$01  ; seg 130  yaw= -70 pitch=  +0 min_lat=  -4 max_lat=  +1
        fcb   $B5,$00,$FD,$00  ; seg 131  yaw= -75 pitch=  +0 min_lat=  -3 max_lat=  +0
        fcb   $B0,$00,$FE,$FF  ; seg 132  yaw= -80 pitch=  +0 min_lat=  -2 max_lat=  -1
        fcb   $B0,$01,$FF,$FE  ; seg 133  yaw= -80 pitch=  +1 min_lat=  -1 max_lat=  -2
        fcb   $B0,$02,$00,$FD  ; seg 134  yaw= -80 pitch=  +2 min_lat=  +0 max_lat=  -3
        fcb   $B0,$03,$01,$FC  ; seg 135  yaw= -80 pitch=  +3 min_lat=  +1 max_lat=  -4
        fcb   $B0,$04,$02,$01  ; seg 136  yaw= -80 pitch=  +4 min_lat=  +2 max_lat=  +1
        fcb   $B0,$03,$03,$00  ; seg 137  yaw= -80 pitch=  +3 min_lat=  +3 max_lat=  +0
        fcb   $B0,$02,$04,$FF  ; seg 138  yaw= -80 pitch=  +2 min_lat=  +4 max_lat=  -1
        fcb   $B0,$01,$FF,$FE  ; seg 139  yaw= -80 pitch=  +1 min_lat=  -1 max_lat=  -2
        fcb   $B0,$00,$00,$FD  ; seg 140  yaw= -80 pitch=  +0 min_lat=  +0 max_lat=  -3
        fcb   $B0,$00,$01,$FC  ; seg 141  yaw= -80 pitch=  +0 min_lat=  +1 max_lat=  -4
        fcb   $B0,$00,$02,$01  ; seg 142  yaw= -80 pitch=  +0 min_lat=  +2 max_lat=  +1
        fcb   $B0,$00,$03,$00  ; seg 143  yaw= -80 pitch=  +0 min_lat=  +3 max_lat=  +0
        fcb   $B0,$00,$04,$FF  ; seg 144  yaw= -80 pitch=  +0 min_lat=  +4 max_lat=  -1
        fcb   $B0,$00,$F6,$FE  ; seg 145  yaw= -80 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $B0,$00,$F6,$FD  ; seg 146  yaw= -80 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $B0,$00,$F6,$FC  ; seg 147  yaw= -80 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $B0,$00,$F6,$0A  ; seg 148  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 149  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 150  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 151  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 152  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AA,$00,$F7,$0A  ; seg 153  yaw= -86 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $A4,$00,$F8,$0A  ; seg 154  yaw= -92 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $9E,$00,$F9,$09  ; seg 155  yaw= -98 pitch=  +0 min_lat=  -7 max_lat=  +9
        fcb   $98,$00,$FA,$08  ; seg 156  yaw=-104 pitch=  +0 min_lat=  -6 max_lat=  +8
        fcb   $92,$00,$FB,$07  ; seg 157  yaw=-110 pitch=  +0 min_lat=  -5 max_lat=  +7
        fcb   $8C,$00,$FC,$06  ; seg 158  yaw=-116 pitch=  +0 min_lat=  -4 max_lat=  +6
        fcb   $86,$00,$FD,$05  ; seg 159  yaw=-122 pitch=  +0 min_lat=  -3 max_lat=  +5
        fcb   $80,$00,$FE,$04  ; seg 160  yaw=-128 pitch=  +0 min_lat=  -2 max_lat=  +4
        fcb   $80,$00,$FF,$03  ; seg 161  yaw=-128 pitch=  +0 min_lat=  -1 max_lat=  +3
        fcb   $80,$00,$00,$02  ; seg 162  yaw=-128 pitch=  +0 min_lat=  +0 max_lat=  +2
        fcb   $80,$00,$01,$01  ; seg 163  yaw=-128 pitch=  +0 min_lat=  +1 max_lat=  +1
        fcb   $80,$00,$02,$00  ; seg 164  yaw=-128 pitch=  +0 min_lat=  +2 max_lat=  +0
        fcb   $80,$00,$03,$FF  ; seg 165  yaw=-128 pitch=  +0 min_lat=  +3 max_lat=  -1
        fcb   $80,$00,$04,$FE  ; seg 166  yaw=-128 pitch=  +0 min_lat=  +4 max_lat=  -2
        fcb   $80,$00,$05,$FD  ; seg 167  yaw=-128 pitch=  +0 min_lat=  +5 max_lat=  -3
        fcb   $80,$00,$06,$FC  ; seg 168  yaw=-128 pitch=  +0 min_lat=  +6 max_lat=  -4
        fcb   $80,$02,$FB,$FB  ; seg 169  yaw=-128 pitch=  +2 min_lat=  -5 max_lat=  -5
        fcb   $80,$04,$FC,$FA  ; seg 170  yaw=-128 pitch=  +4 min_lat=  -4 max_lat=  -6
        fcb   $80,$06,$FD,$01  ; seg 171  yaw=-128 pitch=  +6 min_lat=  -3 max_lat=  +1
        fcb   $80,$08,$FE,$00  ; seg 172  yaw=-128 pitch=  +8 min_lat=  -2 max_lat=  +0
        fcb   $80,$06,$FF,$0A  ; seg 173  yaw=-128 pitch=  +6 min_lat=  -1 max_lat= +10
        fcb   $80,$04,$00,$0A  ; seg 174  yaw=-128 pitch=  +4 min_lat=  +0 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 175  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 176  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 177  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 178  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 179  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 180  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 181  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 182  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 183  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 184 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 185 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 186 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 187 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 188 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 189 (wraparound de seg 5)
        fcb   $00,$00,$F7,$0A  ; seg 190 (wraparound de seg 6)
        fcb   $00,$00,$F8,$0A  ; seg 191 (wraparound de seg 7)
