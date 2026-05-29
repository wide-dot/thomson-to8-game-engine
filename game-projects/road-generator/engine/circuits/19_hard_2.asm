* ======================================================================
* Circuit_19_hard_2 — N=124 segments (format compact 8 oct/seg)
* Source       : 19_hard_2.bin (extrait de FILE30)
*
* Pays         : KENYA
* Lieu         : konza, nr nairobi
* Description  : twisting desert road
* Hazards      : little room to manoeuvre
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
* par circuit ; ce circuit : 7 entries utilisées).
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
* Taille totale : 1602 oct (nb_segments 2 + LUT 16 + segments 1056 + cache 528).
* ======================================================================

Circuit_19_hard_2_nb_segments
        fdb   124

Circuit_19_hard_2_sprite_lut
        fcb   $00,$82,$83,$81,$80,$99,$AB,$00,$00,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_19_hard_2_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$20,$20,$00,$12,$00,$12  ; seg   4                                    #1:$83@+18 #3:$83@+18
        fcb   $00,$00,$20,$20,$00,$12,$00,$12  ; seg   5                                    #1:$83@+18 #3:$83@+18
        fcb   $00,$00,$23,$23,$EE,$12,$EE,$12  ; seg   6                                    #0:$81@-18 #1:$83@+18 #2:$81@-18 #3:$83@+18
        fcb   $00,$00,$23,$23,$EE,$12,$EE,$12  ; seg   7                                    #0:$81@-18 #1:$83@+18 #2:$81@-18 #3:$83@+18
        fcb   $FC,$00,$03,$00,$EE,$00,$00,$00  ; seg   8  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$03,$00,$EE,$00,$00,$00  ; seg   9  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$04,$04,$16,$00,$16,$00  ; seg  10  curve=-4            flags=[PIT]   #0:$80@+22 #2:$80@+22
        fcb   $FC,$00,$04,$04,$16,$00,$16,$00  ; seg  11  curve=-4            flags=[PIT]   #0:$80@+22 #2:$80@+22
        fcb   $84,$00,$04,$05,$16,$00,$EE,$00  ; seg  12  curve=+4            flags=[PIT]   #0:$80@+22 #2:$99@-18
        fcb   $84,$00,$04,$05,$16,$00,$EE,$00  ; seg  13  curve=+4            flags=[PIT]   #0:$80@+22 #2:$99@-18
        fcb   $84,$00,$03,$03,$EE,$00,$EE,$00  ; seg  14  curve=+4            flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $84,$00,$03,$03,$EE,$00,$EE,$00  ; seg  15  curve=+4            flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg  16  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg  17  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$06,$05,$EE,$00,$12,$00  ; seg  18  curve=-4                          #0:$AB@-18 #2:$99@+18
        fcb   $7C,$00,$06,$05,$EE,$00,$12,$00  ; seg  19  curve=-4                          #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$06,$05,$EE,$00,$12,$00  ; seg  20                                    #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$06,$05,$EE,$00,$12,$00  ; seg  21                                    #0:$AB@-18 #2:$99@+18
        fcb   $00,$02,$06,$05,$EE,$00,$12,$00  ; seg  22            pitch=+2                #0:$AB@-18 #2:$99@+18
        fcb   $00,$02,$06,$05,$EE,$00,$12,$00  ; seg  23            pitch=+2                #0:$AB@-18 #2:$99@+18
        fcb   $00,$7E,$06,$05,$EE,$00,$12,$00  ; seg  24            pitch=-2                #0:$AB@-18 #2:$99@+18
        fcb   $00,$7E,$06,$05,$EE,$00,$12,$00  ; seg  25            pitch=-2                #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  26                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  27                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  28  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  29  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$44,$44,$12,$12,$12,$12  ; seg  30  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$44,$44,$12,$12,$12,$12  ; seg  31  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$04,$04,$12,$00,$12,$00  ; seg  32  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$04,$04,$12,$00,$12,$00  ; seg  33  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$06,$05,$12,$00,$EE,$00  ; seg  34  curve=+6                          #0:$AB@+18 #2:$99@-18
        fcb   $06,$00,$06,$05,$12,$00,$EE,$00  ; seg  35  curve=+6                          #0:$AB@+18 #2:$99@-18
        fcb   $00,$7F,$06,$05,$12,$00,$EE,$00  ; seg  36            pitch=-1                #0:$AB@+18 #2:$99@-18
        fcb   $00,$7F,$06,$05,$12,$00,$EE,$00  ; seg  37            pitch=-1                #0:$AB@+18 #2:$99@-18
        fcb   $00,$01,$33,$33,$EE,$EE,$EE,$EE  ; seg  38            pitch=+1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$01,$33,$33,$EE,$EE,$EE,$EE  ; seg  39            pitch=+1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  40  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  41  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$05,$EE,$00,$12,$00  ; seg  42  curve=-6                          #0:$81@-18 #2:$99@+18
        fcb   $7A,$00,$03,$05,$EE,$00,$12,$00  ; seg  43  curve=-6                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg  44  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg  45  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$03,$EE,$00,$EE,$00  ; seg  46  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$03,$03,$EE,$00,$EE,$00  ; seg  47  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  48  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  49  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$04,$12,$00,$12,$00  ; seg  50  curve=-6                          #0:$80@+18 #2:$80@+18
        fcb   $7A,$00,$04,$04,$12,$00,$12,$00  ; seg  51  curve=-6                          #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$04,$05,$12,$00,$EE,$00  ; seg  52  curve=+4                          #0:$80@+18 #2:$99@-18
        fcb   $04,$00,$04,$05,$12,$00,$EE,$00  ; seg  53  curve=+4                          #0:$80@+18 #2:$99@-18
        fcb   $04,$7E,$06,$05,$12,$00,$EE,$00  ; seg  54  curve=+4  pitch=-2                #0:$AB@+18 #2:$99@-18
        fcb   $04,$7E,$06,$05,$12,$00,$EE,$00  ; seg  55  curve=+4  pitch=-2                #0:$AB@+18 #2:$99@-18
        fcb   $00,$02,$06,$05,$12,$00,$EE,$00  ; seg  56            pitch=+2                #0:$AB@+18 #2:$99@-18
        fcb   $00,$02,$06,$05,$12,$00,$EE,$00  ; seg  57            pitch=+2                #0:$AB@+18 #2:$99@-18
        fcb   $00,$00,$04,$04,$12,$00,$12,$00  ; seg  58                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$04,$04,$12,$00,$12,$00  ; seg  59                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$7F,$04,$05,$12,$00,$EE,$00  ; seg  60  curve=+4  pitch=-1                #0:$80@+18 #2:$99@-18
        fcb   $04,$7F,$04,$05,$12,$00,$EE,$00  ; seg  61  curve=+4  pitch=-1                #0:$80@+18 #2:$99@-18
        fcb   $04,$01,$04,$04,$12,$00,$12,$00  ; seg  62  curve=+4  pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $04,$01,$04,$04,$12,$00,$12,$00  ; seg  63  curve=+4  pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$04,$04,$12,$00,$12,$00  ; seg  64  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$04,$04,$12,$00,$12,$00  ; seg  65  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  66  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $06,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  67  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  68  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  69  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$05,$EE,$00,$12,$00  ; seg  70  curve=-6                          #0:$81@-18 #2:$99@+18
        fcb   $7A,$00,$03,$05,$EE,$00,$12,$00  ; seg  71  curve=-6                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg  72  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg  73  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$06,$05,$EE,$00,$12,$00  ; seg  74  curve=-4                          #0:$AB@-18 #2:$99@+18
        fcb   $7C,$00,$06,$05,$EE,$00,$12,$00  ; seg  75  curve=-4                          #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$06,$05,$EE,$00,$12,$00  ; seg  76                                    #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$06,$05,$EE,$00,$12,$00  ; seg  77                                    #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg  78                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg  79                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$02,$03,$05,$EE,$00,$12,$00  ; seg  80  curve=-4  pitch=+2                #0:$81@-18 #2:$99@+18
        fcb   $7C,$02,$03,$05,$EE,$00,$12,$00  ; seg  81  curve=-4  pitch=+2                #0:$81@-18 #2:$99@+18
        fcb   $7C,$7E,$06,$05,$EE,$00,$12,$00  ; seg  82  curve=-4  pitch=-2                #0:$AB@-18 #2:$99@+18
        fcb   $7C,$7E,$06,$05,$EE,$00,$12,$00  ; seg  83  curve=-4  pitch=-2                #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$06,$05,$EE,$00,$12,$00  ; seg  84                                    #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$06,$05,$EE,$00,$12,$00  ; seg  85                                    #0:$AB@-18 #2:$99@+18
        fcb   $00,$01,$03,$03,$EE,$00,$EE,$00  ; seg  86            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $00,$01,$03,$03,$EE,$00,$EE,$00  ; seg  87            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg  88  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg  89  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$7F,$06,$05,$EE,$00,$12,$00  ; seg  90  curve=-4  pitch=-1                #0:$AB@-18 #2:$99@+18
        fcb   $7C,$7F,$06,$05,$EE,$00,$12,$00  ; seg  91  curve=-4  pitch=-1                #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$06,$05,$12,$00,$EE,$00  ; seg  92                                    #0:$AB@+18 #2:$99@-18
        fcb   $00,$00,$06,$05,$12,$00,$EE,$00  ; seg  93                                    #0:$AB@+18 #2:$99@-18
        fcb   $00,$03,$06,$05,$12,$00,$EE,$00  ; seg  94            pitch=+3                #0:$AB@+18 #2:$99@-18
        fcb   $00,$03,$06,$05,$12,$00,$EE,$00  ; seg  95            pitch=+3                #0:$AB@+18 #2:$99@-18
        fcb   $00,$00,$06,$05,$12,$00,$EE,$00  ; seg  96                                    #0:$AB@+18 #2:$99@-18
        fcb   $00,$00,$06,$05,$12,$00,$EE,$00  ; seg  97                                    #0:$AB@+18 #2:$99@-18
        fcb   $00,$00,$06,$05,$EE,$00,$12,$00  ; seg  98                                    #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$06,$05,$EE,$00,$12,$00  ; seg  99                                    #0:$AB@-18 #2:$99@+18
        fcb   $00,$7D,$06,$05,$EE,$00,$12,$00  ; seg 100            pitch=-3                #0:$AB@-18 #2:$99@+18
        fcb   $00,$7D,$06,$05,$EE,$00,$12,$00  ; seg 101            pitch=-3                #0:$AB@-18 #2:$99@+18
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg 102                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg 103                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg 104  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg 105  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$01,$03,$05,$EE,$00,$12,$00  ; seg 106  curve=-4  pitch=+1                #0:$81@-18 #2:$99@+18
        fcb   $7C,$01,$03,$05,$EE,$00,$12,$00  ; seg 107  curve=-4  pitch=+1                #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg 108  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$03,$05,$EE,$00,$12,$00  ; seg 109  curve=-4                          #0:$81@-18 #2:$99@+18
        fcb   $7C,$00,$04,$04,$12,$00,$12,$00  ; seg 110  curve=-4                          #0:$80@+18 #2:$80@+18
        fcb   $7C,$00,$04,$04,$12,$00,$12,$00  ; seg 111  curve=-4                          #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$04,$05,$12,$00,$EE,$00  ; seg 112  curve=+4                          #0:$80@+18 #2:$99@-18
        fcb   $04,$00,$04,$05,$12,$00,$EE,$00  ; seg 113  curve=+4                          #0:$80@+18 #2:$99@-18
        fcb   $04,$7F,$03,$03,$EE,$00,$EE,$00  ; seg 114  curve=+4  pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $04,$7F,$03,$03,$EE,$00,$EE,$00  ; seg 115  curve=+4  pitch=-1                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$03,$00,$EE,$00,$00,$00  ; seg 116  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$03,$00,$EE,$00,$00,$00  ; seg 117  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 118  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 119  curve=-4
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 120
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 121
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 122
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 123
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 124                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 125
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 126
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 127
        fcb   $00,$00,$20,$20,$00,$12,$00,$12  ; seg 128                                    #1:$83@+18 #3:$83@+18
        fcb   $00,$00,$20,$20,$00,$12,$00,$12  ; seg 129                                    #1:$83@+18 #3:$83@+18
        fcb   $00,$00,$23,$23,$EE,$12,$EE,$12  ; seg 130                                    #0:$81@-18 #1:$83@+18 #2:$81@-18 #3:$83@+18
        fcb   $00,$00,$23,$23,$EE,$12,$EE,$12  ; seg 131                                    #0:$81@-18 #1:$83@+18 #2:$81@-18 #3:$83@+18

Circuit_19_hard_2_segment_cache
        fcb   $00,$00,$F6,$0A  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   1  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   2  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   3  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   4  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   5  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   6  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   7  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg   8  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg   9  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  10  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  11  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  12  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  13  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  14  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  15  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  16  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  17  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  18  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  19  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  20  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  21  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  22  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$02,$F6,$0A  ; seg  23  yaw= -16 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $F0,$04,$F6,$0A  ; seg  24  yaw= -16 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $F0,$02,$F6,$0A  ; seg  25  yaw= -16 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  26  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  27  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  28  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EA,$00,$F6,$0A  ; seg  29  yaw= -22 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  30  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DE,$00,$F6,$0A  ; seg  31  yaw= -34 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  32  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DE,$00,$F6,$0A  ; seg  33  yaw= -34 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  34  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EA,$00,$F6,$0A  ; seg  35  yaw= -22 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  36  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$FF,$F6,$0A  ; seg  37  yaw= -16 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $F0,$FE,$F6,$0A  ; seg  38  yaw= -16 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $F0,$FF,$F6,$0A  ; seg  39  yaw= -16 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  40  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EA,$00,$F6,$0A  ; seg  41  yaw= -22 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  42  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DE,$00,$F6,$0A  ; seg  43  yaw= -34 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  44  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  45  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  46  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  47  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  48  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg  49  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  50  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg  51  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  52  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  53  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  54  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$FE,$F6,$0A  ; seg  55  yaw= -68 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C0,$FC,$F6,$0A  ; seg  56  yaw= -64 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C0,$FE,$F6,$0A  ; seg  57  yaw= -64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  58  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  59  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  60  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$FF,$F6,$0A  ; seg  61  yaw= -60 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C8,$FE,$F6,$0A  ; seg  62  yaw= -56 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $CC,$FF,$F6,$0A  ; seg  63  yaw= -52 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  64  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D6,$00,$F6,$0A  ; seg  65  yaw= -42 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  66  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  67  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  68  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  69  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  70  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D6,$00,$F6,$0A  ; seg  71  yaw= -42 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  72  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  73  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  74  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  75  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  76  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  77  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  78  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  79  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  80  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$02,$F6,$0A  ; seg  81  yaw= -68 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B8,$04,$F6,$0A  ; seg  82  yaw= -72 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B4,$02,$F6,$0A  ; seg  83  yaw= -76 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  84  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  85  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  86  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$01,$F6,$0A  ; seg  87  yaw= -80 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg  88  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $AC,$02,$F6,$0A  ; seg  89  yaw= -84 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A8,$02,$F6,$0A  ; seg  90  yaw= -88 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A4,$01,$F6,$0A  ; seg  91  yaw= -92 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg  92  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg  93  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg  94  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$03,$F6,$0A  ; seg  95  yaw= -96 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $A0,$06,$F6,$0A  ; seg  96  yaw= -96 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $A0,$06,$F6,$0A  ; seg  97  yaw= -96 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $A0,$06,$F6,$0A  ; seg  98  yaw= -96 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $A0,$06,$F6,$0A  ; seg  99  yaw= -96 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $A0,$06,$F6,$0A  ; seg 100  yaw= -96 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $A0,$03,$F6,$0A  ; seg 101  yaw= -96 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 102  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 103  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 104  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg 105  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 106  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$01,$F6,$0A  ; seg 107  yaw=-108 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $90,$02,$F6,$0A  ; seg 108  yaw=-112 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $8C,$02,$F6,$0A  ; seg 109  yaw=-116 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $88,$02,$F6,$0A  ; seg 110  yaw=-120 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $84,$02,$F6,$0A  ; seg 111  yaw=-124 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 112  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $84,$02,$F6,$0A  ; seg 113  yaw=-124 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $88,$02,$F6,$0A  ; seg 114  yaw=-120 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $8C,$01,$F6,$0A  ; seg 115  yaw=-116 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 116  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 117  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 118  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg 119  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 120  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 121  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 122  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 123  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 124 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 125 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 126 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 127 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 128 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 129 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 130 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 131 (wraparound de seg 7)
