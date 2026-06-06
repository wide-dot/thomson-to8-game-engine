* ======================================================================
* Circuit_15_medium_8 — N=152 segments (format compact 8 oct/seg)
* Source       : 15_medium_8.bin (extrait de FILE30)
*
* Pays         : USA
* Lieu         : houston, texas
* Description  : winding course
* Hazards      : rocks and water on road
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000090 01:#6C246C 02:#484848 03:#909090 04:#482448 05:#B40000 06:#240000 07:#240000
*   08:#482448 09:#D8D8D8 10:#240000 11:#FCFCFC 12:#FC006C 13:#FC006C 14:#FC2490 15:#FC2490
*   16:#FC48B4 17:#FC48B4 18:#FC6CD8 19:#FC6CD8 20:#FC90FC 21:#FC90FC 22:#FCB4FC 23:#FCB4FC
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
* Taille totale : 1938 oct (nb_segments 2 + LUT 16 + segments 1280 + cache 640).
* ======================================================================

Circuit_15_medium_8_nb_segments
        fdb   152

Circuit_15_medium_8_sprite_lut
        fcb   $00,$82,$83,$A9,$96,$A3,$8A,$8B,$80,$81,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_15_medium_8_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg   8                      flags=[PIT]   #0:$A9@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg   9                      flags=[PIT]   #0:$A9@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  10                      flags=[PIT]   #0:$A9@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  11                      flags=[PIT]   #0:$A9@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  12                      flags=[PIT]   #0:$A9@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  13                      flags=[PIT]   #0:$A9@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  14                      flags=[PIT]   #0:$A9@-20
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg  15                      flags=[PIT]   #0:$A9@-20
        fcb   $00,$00,$04,$65,$14,$00,$1C,$E0  ; seg  16                                    #0:$96@+20 #2:$A3@+28 #3:$8A@-32
        fcb   $00,$00,$04,$75,$14,$00,$20,$D8  ; seg  17                                    #0:$96@+20 #2:$A3@+32 #3:$8B@-40
        fcb   $00,$02,$04,$60,$14,$00,$00,$30  ; seg  18            pitch=+2                #0:$96@+20 #3:$8A@+48
        fcb   $00,$02,$04,$05,$14,$00,$E0,$00  ; seg  19            pitch=+2                #0:$96@+20 #2:$A3@-32
        fcb   $00,$02,$04,$60,$EC,$00,$00,$D4  ; seg  20            pitch=+2                #0:$96@-20 #3:$8A@-44
        fcb   $00,$02,$04,$70,$EC,$00,$00,$20  ; seg  21            pitch=+2                #0:$96@-20 #3:$8B@+32
        fcb   $00,$7F,$04,$65,$EC,$00,$30,$14  ; seg  22            pitch=-1                #0:$96@-20 #2:$A3@+48 #3:$8A@+20
        fcb   $00,$7F,$04,$05,$EC,$00,$1C,$00  ; seg  23            pitch=-1                #0:$96@-20 #2:$A3@+28
        fcb   $00,$00,$63,$70,$14,$0A,$00,$EC  ; seg  24                                    #0:$A9@+20 #1:$8A@+10 #3:$8B@-20
        fcb   $00,$00,$03,$60,$14,$00,$00,$E8  ; seg  25                                    #0:$A9@+20 #3:$8A@-24
        fcb   $00,$01,$03,$05,$14,$00,$28,$00  ; seg  26            pitch=+1                #0:$A9@+20 #2:$A3@+40
        fcb   $00,$01,$03,$60,$14,$00,$00,$E0  ; seg  27            pitch=+1                #0:$A9@+20 #3:$8A@-32
        fcb   $00,$00,$53,$60,$14,$FA,$00,$D8  ; seg  28                                    #0:$A9@+20 #1:$A3@-6 #3:$8A@-40
        fcb   $00,$00,$03,$70,$14,$00,$00,$CC  ; seg  29                                    #0:$A9@+20 #3:$8B@-52
        fcb   $00,$7E,$03,$60,$14,$00,$00,$E0  ; seg  30            pitch=-2                #0:$A9@+20 #3:$8A@-32
        fcb   $00,$7E,$03,$05,$14,$00,$D8,$00  ; seg  31            pitch=-2                #0:$A9@+20 #2:$A3@-40
        fcb   $00,$01,$63,$70,$EC,$0A,$00,$20  ; seg  32            pitch=+1                #0:$A9@-20 #1:$8A@+10 #3:$8B@+32
        fcb   $00,$01,$03,$70,$EC,$00,$00,$14  ; seg  33            pitch=+1                #0:$A9@-20 #3:$8B@+20
        fcb   $00,$01,$03,$05,$EC,$00,$20,$00  ; seg  34            pitch=+1                #0:$A9@-20 #2:$A3@+32
        fcb   $00,$01,$03,$60,$EC,$00,$00,$20  ; seg  35            pitch=+1                #0:$A9@-20 #3:$8A@+32
        fcb   $00,$00,$03,$60,$14,$00,$00,$E0  ; seg  36                                    #0:$A9@+20 #3:$8A@-32
        fcb   $00,$00,$03,$05,$14,$00,$1C,$00  ; seg  37                                    #0:$A9@+20 #2:$A3@+28
        fcb   $00,$7F,$03,$70,$14,$00,$00,$D8  ; seg  38            pitch=-1                #0:$A9@+20 #3:$8B@-40
        fcb   $00,$7F,$03,$60,$14,$00,$00,$30  ; seg  39            pitch=-1                #0:$A9@+20 #3:$8A@+48
        fcb   $00,$00,$54,$05,$EC,$F6,$30,$00  ; seg  40                                    #0:$96@-20 #1:$A3@-10 #2:$A3@+48
        fcb   $00,$00,$04,$60,$EC,$00,$00,$18  ; seg  41                                    #0:$96@-20 #3:$8A@+24
        fcb   $00,$00,$04,$60,$EC,$00,$00,$20  ; seg  42                                    #0:$96@-20 #3:$8A@+32
        fcb   $00,$00,$04,$05,$EC,$00,$38,$00  ; seg  43                                    #0:$96@-20 #2:$A3@+56
        fcb   $00,$00,$74,$75,$14,$0A,$D8,$E0  ; seg  44                                    #0:$96@+20 #1:$8B@+10 #2:$A3@-40 #3:$8B@-32
        fcb   $00,$00,$04,$70,$14,$00,$00,$EC  ; seg  45                                    #0:$96@+20 #3:$8B@-20
        fcb   $00,$01,$04,$05,$14,$00,$C8,$00  ; seg  46            pitch=+1                #0:$96@+20 #2:$A3@-56
        fcb   $00,$01,$04,$60,$14,$00,$00,$EC  ; seg  47            pitch=+1                #0:$96@+20 #3:$8A@-20
        fcb   $00,$7F,$64,$70,$EC,$0A,$00,$20  ; seg  48            pitch=-1                #0:$96@-20 #1:$8A@+10 #3:$8B@+32
        fcb   $00,$7F,$04,$60,$EC,$00,$00,$14  ; seg  49            pitch=-1                #0:$96@-20 #3:$8A@+20
        fcb   $00,$7F,$04,$05,$EC,$00,$20,$00  ; seg  50            pitch=-1                #0:$96@-20 #2:$A3@+32
        fcb   $00,$7F,$04,$60,$EC,$00,$00,$30  ; seg  51            pitch=-1                #0:$96@-20 #3:$8A@+48
        fcb   $00,$00,$04,$70,$14,$00,$00,$E0  ; seg  52                                    #0:$96@+20 #3:$8B@-32
        fcb   $00,$00,$04,$05,$14,$00,$28,$00  ; seg  53                                    #0:$96@+20 #2:$A3@+40
        fcb   $00,$00,$04,$60,$14,$00,$00,$E8  ; seg  54                                    #0:$96@+20 #3:$8A@-24
        fcb   $00,$00,$04,$60,$14,$00,$00,$EC  ; seg  55                                    #0:$96@+20 #3:$8A@-20
        fcb   $00,$7F,$53,$70,$EC,$F6,$00,$14  ; seg  56            pitch=-1                #0:$A9@-20 #1:$A3@-10 #3:$8B@+20
        fcb   $00,$7F,$03,$60,$EC,$00,$00,$20  ; seg  57            pitch=-1                #0:$A9@-20 #3:$8A@+32
        fcb   $00,$7F,$03,$05,$EC,$00,$30,$00  ; seg  58            pitch=-1                #0:$A9@-20 #2:$A3@+48
        fcb   $00,$7F,$03,$60,$EC,$00,$00,$18  ; seg  59            pitch=-1                #0:$A9@-20 #3:$8A@+24
        fcb   $00,$00,$00,$70,$00,$00,$00,$E0  ; seg  60                                    #3:$8B@-32
        fcb   $00,$00,$00,$05,$00,$00,$1C,$00  ; seg  61                                    #2:$A3@+28
        fcb   $00,$00,$88,$88,$12,$12,$12,$12  ; seg  62                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$88,$88,$12,$12,$12,$12  ; seg  63                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  64  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$68,$12,$00,$12,$E0  ; seg  65  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8A@-32
        fcb   $06,$00,$08,$68,$12,$00,$12,$EC  ; seg  66  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8A@-20
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  67  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$68,$78,$12,$FA,$12,$D0  ; seg  68  curve=+6                          #0:$80@+18 #1:$8A@-6 #2:$80@+18 #3:$8B@-48
        fcb   $06,$00,$08,$68,$12,$00,$12,$20  ; seg  69  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8A@+32
        fcb   $06,$00,$00,$05,$00,$00,$30,$00  ; seg  70  curve=+6                          #2:$A3@+48
        fcb   $06,$00,$00,$65,$00,$00,$20,$14  ; seg  71  curve=+6                          #2:$A3@+32 #3:$8A@+20
        fcb   $00,$00,$70,$65,$00,$06,$D8,$18  ; seg  72                                    #1:$8B@+6 #2:$A3@-40 #3:$8A@+24
        fcb   $00,$00,$00,$60,$00,$00,$00,$1C  ; seg  73                                    #3:$8A@+28
        fcb   $00,$00,$99,$99,$EE,$EE,$EE,$EE  ; seg  74                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$99,$99,$EE,$EE,$EE,$EE  ; seg  75                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$09,$09,$EE,$00,$EE,$00  ; seg  76  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$09,$79,$EE,$00,$EE,$20  ; seg  77  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8B@+32
        fcb   $7A,$00,$00,$70,$00,$00,$00,$18  ; seg  78  curve=-6                          #3:$8B@+24
        fcb   $7A,$00,$00,$65,$00,$00,$C8,$14  ; seg  79  curve=-6                          #2:$A3@-56 #3:$8A@+20
        fcb   $00,$00,$50,$05,$00,$06,$20,$00  ; seg  80                                    #1:$A3@+6 #2:$A3@+32
        fcb   $00,$00,$00,$60,$00,$00,$00,$E0  ; seg  81                                    #3:$8A@-32
        fcb   $00,$00,$08,$08,$12,$00,$12,$00  ; seg  82                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$08,$78,$12,$00,$12,$EC  ; seg  83                                    #0:$80@+18 #2:$80@+18 #3:$8B@-20
        fcb   $04,$7F,$58,$60,$12,$F6,$00,$E8  ; seg  84  curve=+4  pitch=-1                #0:$80@+18 #1:$A3@-10 #3:$8A@-24
        fcb   $04,$7F,$08,$05,$12,$00,$30,$00  ; seg  85  curve=+4  pitch=-1                #0:$80@+18 #2:$A3@+48
        fcb   $04,$7F,$08,$60,$12,$00,$00,$E0  ; seg  86  curve=+4  pitch=-1                #0:$80@+18 #3:$8A@-32
        fcb   $04,$7F,$08,$75,$12,$00,$D0,$D8  ; seg  87  curve=+4  pitch=-1                #0:$80@+18 #2:$A3@-48 #3:$8B@-40
        fcb   $04,$01,$08,$60,$12,$00,$00,$EC  ; seg  88  curve=+4  pitch=+1                #0:$80@+18 #3:$8A@-20
        fcb   $04,$01,$08,$05,$12,$00,$C8,$00  ; seg  89  curve=+4  pitch=+1                #0:$80@+18 #2:$A3@-56
        fcb   $04,$00,$00,$60,$00,$00,$00,$D0  ; seg  90  curve=+4                          #3:$8A@-48
        fcb   $04,$00,$00,$75,$00,$00,$20,$20  ; seg  91  curve=+4                          #2:$A3@+32 #3:$8B@+32
        fcb   $00,$01,$50,$60,$00,$0A,$00,$E0  ; seg  92            pitch=+1                #1:$A3@+10 #3:$8A@-32
        fcb   $00,$01,$00,$05,$00,$00,$38,$00  ; seg  93            pitch=+1                #2:$A3@+56
        fcb   $00,$00,$88,$88,$12,$12,$12,$12  ; seg  94                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$88,$88,$12,$12,$12,$12  ; seg  95                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $05,$00,$58,$60,$12,$06,$00,$E0  ; seg  96  curve=+5                          #0:$80@+18 #1:$A3@+6 #3:$8A@-32
        fcb   $05,$00,$08,$70,$12,$00,$00,$EC  ; seg  97  curve=+5                          #0:$80@+18 #3:$8B@-20
        fcb   $05,$00,$08,$75,$12,$00,$20,$D8  ; seg  98  curve=+5                          #0:$80@+18 #2:$A3@+32 #3:$8B@-40
        fcb   $05,$00,$08,$60,$12,$00,$00,$E4  ; seg  99  curve=+5                          #0:$80@+18 #3:$8A@-28
        fcb   $05,$00,$08,$05,$12,$00,$C8,$00  ; seg 100  curve=+5                          #0:$80@+18 #2:$A3@-56
        fcb   $05,$00,$08,$65,$12,$00,$20,$E0  ; seg 101  curve=+5                          #0:$80@+18 #2:$A3@+32 #3:$8A@-32
        fcb   $05,$00,$00,$60,$00,$00,$00,$20  ; seg 102  curve=+5                          #3:$8A@+32
        fcb   $05,$00,$00,$75,$00,$00,$18,$D0  ; seg 103  curve=+5                          #2:$A3@+24 #3:$8B@-48
        fcb   $00,$00,$00,$60,$00,$00,$00,$14  ; seg 104                                    #3:$8A@+20
        fcb   $00,$00,$00,$05,$00,$00,$30,$00  ; seg 105                                    #2:$A3@+48
        fcb   $00,$00,$99,$99,$EE,$EE,$EE,$EE  ; seg 106                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$99,$99,$EE,$EE,$EE,$EE  ; seg 107                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$09,$09,$EE,$00,$EE,$00  ; seg 108  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$09,$69,$EE,$00,$EE,$14  ; seg 109  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8A@+20
        fcb   $7A,$00,$00,$70,$00,$00,$00,$20  ; seg 110  curve=-6                          #3:$8B@+32
        fcb   $7A,$00,$00,$65,$00,$00,$E0,$18  ; seg 111  curve=-6                          #2:$A3@-32 #3:$8A@+24
        fcb   $00,$7F,$50,$65,$00,$0A,$EC,$20  ; seg 112            pitch=-1                #1:$A3@+10 #2:$A3@-20 #3:$8A@+32
        fcb   $00,$7F,$00,$70,$00,$00,$00,$1C  ; seg 113            pitch=-1                #3:$8B@+28
        fcb   $00,$00,$09,$09,$EE,$00,$EE,$00  ; seg 114                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$09,$09,$EE,$00,$EE,$00  ; seg 115                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$69,$60,$EE,$F6,$00,$20  ; seg 116  curve=-4                          #0:$81@-18 #1:$8A@-10 #3:$8A@+32
        fcb   $7C,$00,$09,$70,$EE,$00,$00,$14  ; seg 117  curve=-4                          #0:$81@-18 #3:$8B@+20
        fcb   $7C,$00,$00,$75,$00,$00,$20,$E0  ; seg 118  curve=-4                          #2:$A3@+32 #3:$8B@-32
        fcb   $7C,$00,$00,$65,$00,$00,$1C,$D0  ; seg 119  curve=-4                          #2:$A3@+28 #3:$8A@-48
        fcb   $00,$01,$63,$65,$14,$F6,$30,$C8  ; seg 120            pitch=+1                #0:$A9@+20 #1:$8A@-10 #2:$A3@+48 #3:$8A@-56
        fcb   $00,$01,$03,$70,$14,$00,$00,$20  ; seg 121            pitch=+1                #0:$A9@+20 #3:$8B@+32
        fcb   $00,$00,$03,$60,$14,$00,$00,$E0  ; seg 122                                    #0:$A9@+20 #3:$8A@-32
        fcb   $00,$00,$03,$05,$14,$00,$D0,$00  ; seg 123                                    #0:$A9@+20 #2:$A3@-48
        fcb   $00,$7E,$54,$60,$EC,$06,$00,$14  ; seg 124            pitch=-2                #0:$96@-20 #1:$A3@+6 #3:$8A@+20
        fcb   $00,$7E,$04,$60,$EC,$00,$00,$20  ; seg 125            pitch=-2                #0:$96@-20 #3:$8A@+32
        fcb   $00,$00,$04,$75,$EC,$00,$20,$18  ; seg 126                                    #0:$96@-20 #2:$A3@+32 #3:$8B@+24
        fcb   $00,$00,$04,$05,$EC,$00,$E0,$00  ; seg 127                                    #0:$96@-20 #2:$A3@-32
        fcb   $00,$01,$63,$60,$14,$0A,$00,$EC  ; seg 128            pitch=+1                #0:$A9@+20 #1:$8A@+10 #3:$8A@-20
        fcb   $00,$01,$03,$65,$14,$00,$18,$EC  ; seg 129            pitch=+1                #0:$A9@+20 #2:$A3@+24 #3:$8A@-20
        fcb   $00,$01,$03,$70,$14,$00,$00,$E8  ; seg 130            pitch=+1                #0:$A9@+20 #3:$8B@-24
        fcb   $00,$01,$03,$60,$14,$00,$00,$E0  ; seg 131            pitch=+1                #0:$A9@+20 #3:$8A@-32
        fcb   $00,$00,$50,$05,$00,$FA,$30,$00  ; seg 132                                    #1:$A3@-6 #2:$A3@+48
        fcb   $00,$00,$00,$60,$00,$00,$00,$20  ; seg 133                                    #3:$8A@+32
        fcb   $00,$00,$08,$78,$12,$00,$12,$D8  ; seg 134                                    #0:$80@+18 #2:$80@+18 #3:$8B@-40
        fcb   $00,$00,$08,$68,$12,$00,$12,$EC  ; seg 135                                    #0:$80@+18 #2:$80@+18 #3:$8A@-20
        fcb   $04,$00,$68,$60,$12,$0A,$00,$20  ; seg 136  curve=+4                          #0:$80@+18 #1:$8A@+10 #3:$8A@+32
        fcb   $04,$00,$08,$75,$12,$00,$C0,$EC  ; seg 137  curve=+4                          #0:$80@+18 #2:$A3@-64 #3:$8B@-20
        fcb   $04,$00,$08,$75,$12,$00,$20,$E0  ; seg 138  curve=+4                          #0:$80@+18 #2:$A3@+32 #3:$8B@-32
        fcb   $04,$00,$08,$00,$12,$00,$00,$00  ; seg 139  curve=+4                          #0:$80@+18
        fcb   $04,$7F,$58,$65,$12,$06,$D0,$EC  ; seg 140  curve=+4  pitch=-1                #0:$80@+18 #1:$A3@+6 #2:$A3@-48 #3:$8A@-20
        fcb   $04,$7F,$08,$60,$12,$00,$00,$EC  ; seg 141  curve=+4  pitch=-1                #0:$80@+18 #3:$8A@-20
        fcb   $04,$7F,$08,$70,$12,$00,$00,$E8  ; seg 142  curve=+4  pitch=-1                #0:$80@+18 #3:$8B@-24
        fcb   $04,$7F,$08,$75,$12,$00,$20,$EC  ; seg 143  curve=+4  pitch=-1                #0:$80@+18 #2:$A3@+32 #3:$8B@-20
        fcb   $04,$00,$08,$00,$12,$00,$00,$00  ; seg 144  curve=+4                          #0:$80@+18
        fcb   $04,$00,$08,$00,$12,$00,$00,$00  ; seg 145  curve=+4                          #0:$80@+18
        fcb   $04,$00,$08,$08,$12,$00,$12,$00  ; seg 146  curve=+4                          #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$08,$08,$12,$00,$12,$00  ; seg 147  curve=+4                          #0:$80@+18 #2:$80@+18
        fcb   $06,$01,$08,$08,$12,$00,$12,$00  ; seg 148  curve=+6  pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $06,$01,$08,$08,$12,$00,$12,$00  ; seg 149  curve=+6  pitch=+1                #0:$80@+18 #2:$80@+18
        fcb   $06,$01,$00,$00,$00,$00,$00,$00  ; seg 150  curve=+6  pitch=+1
        fcb   $06,$01,$00,$00,$00,$00,$00,$00  ; seg 151  curve=+6  pitch=+1
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 152                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 153
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 154
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 155
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 156                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 157                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 158                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 159                                    #0:$83@+18 #2:$83@+18

Circuit_15_medium_8_segment_cache
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
        fcb   $00,$00,$F7,$09  ; seg  17  yaw=  +0 pitch=  +0 min_lat=  -9 max_lat=  +9
        fcb   $00,$00,$F8,$08  ; seg  18  yaw=  +0 pitch=  +0 min_lat=  -8 max_lat=  +8
        fcb   $00,$02,$F9,$07  ; seg  19  yaw=  +0 pitch=  +2 min_lat=  -7 max_lat=  +7
        fcb   $00,$04,$FA,$06  ; seg  20  yaw=  +0 pitch=  +4 min_lat=  -6 max_lat=  +6
        fcb   $00,$06,$FB,$05  ; seg  21  yaw=  +0 pitch=  +6 min_lat=  -5 max_lat=  +5
        fcb   $00,$08,$FC,$04  ; seg  22  yaw=  +0 pitch=  +8 min_lat=  -4 max_lat=  +4
        fcb   $00,$07,$FD,$03  ; seg  23  yaw=  +0 pitch=  +7 min_lat=  -3 max_lat=  +3
        fcb   $00,$06,$FE,$02  ; seg  24  yaw=  +0 pitch=  +6 min_lat=  -2 max_lat=  +2
        fcb   $00,$06,$FF,$09  ; seg  25  yaw=  +0 pitch=  +6 min_lat=  -1 max_lat=  +9
        fcb   $00,$06,$00,$08  ; seg  26  yaw=  +0 pitch=  +6 min_lat=  +0 max_lat=  +8
        fcb   $00,$07,$01,$07  ; seg  27  yaw=  +0 pitch=  +7 min_lat=  +1 max_lat=  +7
        fcb   $00,$08,$02,$06  ; seg  28  yaw=  +0 pitch=  +8 min_lat=  +2 max_lat=  +6
        fcb   $00,$08,$F6,$05  ; seg  29  yaw=  +0 pitch=  +8 min_lat= -10 max_lat=  +5
        fcb   $00,$08,$F6,$04  ; seg  30  yaw=  +0 pitch=  +8 min_lat= -10 max_lat=  +4
        fcb   $00,$06,$F6,$03  ; seg  31  yaw=  +0 pitch=  +6 min_lat= -10 max_lat=  +3
        fcb   $00,$04,$F6,$02  ; seg  32  yaw=  +0 pitch=  +4 min_lat= -10 max_lat=  +2
        fcb   $00,$05,$F7,$0A  ; seg  33  yaw=  +0 pitch=  +5 min_lat=  -9 max_lat= +10
        fcb   $00,$06,$F8,$0A  ; seg  34  yaw=  +0 pitch=  +6 min_lat=  -8 max_lat= +10
        fcb   $00,$07,$F9,$0A  ; seg  35  yaw=  +0 pitch=  +7 min_lat=  -7 max_lat= +10
        fcb   $00,$08,$FA,$0A  ; seg  36  yaw=  +0 pitch=  +8 min_lat=  -6 max_lat= +10
        fcb   $00,$08,$FB,$09  ; seg  37  yaw=  +0 pitch=  +8 min_lat=  -5 max_lat=  +9
        fcb   $00,$08,$FC,$08  ; seg  38  yaw=  +0 pitch=  +8 min_lat=  -4 max_lat=  +8
        fcb   $00,$07,$FD,$07  ; seg  39  yaw=  +0 pitch=  +7 min_lat=  -3 max_lat=  +7
        fcb   $00,$06,$FE,$06  ; seg  40  yaw=  +0 pitch=  +6 min_lat=  -2 max_lat=  +6
        fcb   $00,$06,$F6,$05  ; seg  41  yaw=  +0 pitch=  +6 min_lat= -10 max_lat=  +5
        fcb   $00,$06,$F6,$04  ; seg  42  yaw=  +0 pitch=  +6 min_lat= -10 max_lat=  +4
        fcb   $00,$06,$F6,$03  ; seg  43  yaw=  +0 pitch=  +6 min_lat= -10 max_lat=  +3
        fcb   $00,$06,$F6,$02  ; seg  44  yaw=  +0 pitch=  +6 min_lat= -10 max_lat=  +2
        fcb   $00,$06,$F6,$05  ; seg  45  yaw=  +0 pitch=  +6 min_lat= -10 max_lat=  +5
        fcb   $00,$06,$F6,$04  ; seg  46  yaw=  +0 pitch=  +6 min_lat= -10 max_lat=  +4
        fcb   $00,$07,$F6,$03  ; seg  47  yaw=  +0 pitch=  +7 min_lat= -10 max_lat=  +3
        fcb   $00,$08,$F6,$02  ; seg  48  yaw=  +0 pitch=  +8 min_lat= -10 max_lat=  +2
        fcb   $00,$07,$F7,$0A  ; seg  49  yaw=  +0 pitch=  +7 min_lat=  -9 max_lat= +10
        fcb   $00,$06,$F8,$0A  ; seg  50  yaw=  +0 pitch=  +6 min_lat=  -8 max_lat= +10
        fcb   $00,$05,$F9,$0A  ; seg  51  yaw=  +0 pitch=  +5 min_lat=  -7 max_lat= +10
        fcb   $00,$04,$FA,$0A  ; seg  52  yaw=  +0 pitch=  +4 min_lat=  -6 max_lat= +10
        fcb   $00,$04,$FB,$0A  ; seg  53  yaw=  +0 pitch=  +4 min_lat=  -5 max_lat= +10
        fcb   $00,$04,$FC,$0A  ; seg  54  yaw=  +0 pitch=  +4 min_lat=  -4 max_lat= +10
        fcb   $00,$04,$FD,$0A  ; seg  55  yaw=  +0 pitch=  +4 min_lat=  -3 max_lat= +10
        fcb   $00,$04,$FE,$0A  ; seg  56  yaw=  +0 pitch=  +4 min_lat=  -2 max_lat= +10
        fcb   $00,$03,$F7,$0A  ; seg  57  yaw=  +0 pitch=  +3 min_lat=  -9 max_lat= +10
        fcb   $00,$02,$F8,$0A  ; seg  58  yaw=  +0 pitch=  +2 min_lat=  -8 max_lat= +10
        fcb   $00,$01,$F9,$0A  ; seg  59  yaw=  +0 pitch=  +1 min_lat=  -7 max_lat= +10
        fcb   $00,$00,$FA,$0A  ; seg  60  yaw=  +0 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $00,$00,$FB,$09  ; seg  61  yaw=  +0 pitch=  +0 min_lat=  -5 max_lat=  +9
        fcb   $00,$00,$FC,$08  ; seg  62  yaw=  +0 pitch=  +0 min_lat=  -4 max_lat=  +8
        fcb   $00,$00,$FD,$07  ; seg  63  yaw=  +0 pitch=  +0 min_lat=  -3 max_lat=  +7
        fcb   $00,$00,$FE,$06  ; seg  64  yaw=  +0 pitch=  +0 min_lat=  -2 max_lat=  +6
        fcb   $06,$00,$FF,$05  ; seg  65  yaw=  +6 pitch=  +0 min_lat=  -1 max_lat=  +5
        fcb   $0C,$00,$00,$04  ; seg  66  yaw= +12 pitch=  +0 min_lat=  +0 max_lat=  +4
        fcb   $12,$00,$01,$03  ; seg  67  yaw= +18 pitch=  +0 min_lat=  +1 max_lat=  +3
        fcb   $18,$00,$02,$02  ; seg  68  yaw= +24 pitch=  +0 min_lat=  +2 max_lat=  +2
        fcb   $1E,$00,$F6,$01  ; seg  69  yaw= +30 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $24,$00,$F6,$00  ; seg  70  yaw= +36 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $2A,$00,$F6,$FF  ; seg  71  yaw= +42 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $30,$00,$F6,$FE  ; seg  72  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $30,$00,$F6,$05  ; seg  73  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $30,$00,$F6,$04  ; seg  74  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $30,$00,$F6,$03  ; seg  75  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $30,$00,$F6,$02  ; seg  76  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $2A,$00,$F7,$01  ; seg  77  yaw= +42 pitch=  +0 min_lat=  -9 max_lat=  +1
        fcb   $24,$00,$F8,$00  ; seg  78  yaw= +36 pitch=  +0 min_lat=  -8 max_lat=  +0
        fcb   $1E,$00,$F9,$FF  ; seg  79  yaw= +30 pitch=  +0 min_lat=  -7 max_lat=  -1
        fcb   $18,$00,$FA,$FE  ; seg  80  yaw= +24 pitch=  +0 min_lat=  -6 max_lat=  -2
        fcb   $18,$00,$FB,$0A  ; seg  81  yaw= +24 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $18,$00,$FC,$0A  ; seg  82  yaw= +24 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $18,$00,$FD,$0A  ; seg  83  yaw= +24 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $18,$00,$FE,$0A  ; seg  84  yaw= +24 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $1C,$FF,$F6,$09  ; seg  85  yaw= +28 pitch=  -1 min_lat= -10 max_lat=  +9
        fcb   $20,$FE,$F6,$08  ; seg  86  yaw= +32 pitch=  -2 min_lat= -10 max_lat=  +8
        fcb   $24,$FD,$F6,$07  ; seg  87  yaw= +36 pitch=  -3 min_lat= -10 max_lat=  +7
        fcb   $28,$FC,$F6,$06  ; seg  88  yaw= +40 pitch=  -4 min_lat= -10 max_lat=  +6
        fcb   $2C,$FD,$F6,$05  ; seg  89  yaw= +44 pitch=  -3 min_lat= -10 max_lat=  +5
        fcb   $30,$FE,$F6,$04  ; seg  90  yaw= +48 pitch=  -2 min_lat= -10 max_lat=  +4
        fcb   $34,$FE,$F6,$03  ; seg  91  yaw= +52 pitch=  -2 min_lat= -10 max_lat=  +3
        fcb   $38,$FE,$F6,$02  ; seg  92  yaw= +56 pitch=  -2 min_lat= -10 max_lat=  +2
        fcb   $38,$FF,$F6,$01  ; seg  93  yaw= +56 pitch=  -1 min_lat= -10 max_lat=  +1
        fcb   $38,$00,$F6,$00  ; seg  94  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $38,$00,$F6,$FF  ; seg  95  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $38,$00,$F6,$FE  ; seg  96  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $3D,$00,$F6,$0A  ; seg  97  yaw= +61 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $42,$00,$F6,$0A  ; seg  98  yaw= +66 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $47,$00,$F6,$0A  ; seg  99  yaw= +71 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $4C,$00,$F6,$0A  ; seg 100  yaw= +76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $51,$00,$F6,$0A  ; seg 101  yaw= +81 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $56,$00,$F6,$0A  ; seg 102  yaw= +86 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $5B,$00,$F6,$0A  ; seg 103  yaw= +91 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 104  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$09  ; seg 105  yaw= +96 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $60,$00,$F6,$08  ; seg 106  yaw= +96 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $60,$00,$F6,$07  ; seg 107  yaw= +96 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $60,$00,$F6,$06  ; seg 108  yaw= +96 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $5A,$00,$F7,$05  ; seg 109  yaw= +90 pitch=  +0 min_lat=  -9 max_lat=  +5
        fcb   $54,$00,$F8,$04  ; seg 110  yaw= +84 pitch=  +0 min_lat=  -8 max_lat=  +4
        fcb   $4E,$00,$F9,$03  ; seg 111  yaw= +78 pitch=  +0 min_lat=  -7 max_lat=  +3
        fcb   $48,$00,$FA,$02  ; seg 112  yaw= +72 pitch=  +0 min_lat=  -6 max_lat=  +2
        fcb   $48,$FF,$FB,$09  ; seg 113  yaw= +72 pitch=  -1 min_lat=  -5 max_lat=  +9
        fcb   $48,$FE,$FC,$08  ; seg 114  yaw= +72 pitch=  -2 min_lat=  -4 max_lat=  +8
        fcb   $48,$FE,$FD,$07  ; seg 115  yaw= +72 pitch=  -2 min_lat=  -3 max_lat=  +7
        fcb   $48,$FE,$FE,$06  ; seg 116  yaw= +72 pitch=  -2 min_lat=  -2 max_lat=  +6
        fcb   $44,$FE,$FB,$05  ; seg 117  yaw= +68 pitch=  -2 min_lat=  -5 max_lat=  +5
        fcb   $40,$FE,$FC,$04  ; seg 118  yaw= +64 pitch=  -2 min_lat=  -4 max_lat=  +4
        fcb   $3C,$FE,$FD,$03  ; seg 119  yaw= +60 pitch=  -2 min_lat=  -3 max_lat=  +3
        fcb   $38,$FE,$FE,$02  ; seg 120  yaw= +56 pitch=  -2 min_lat=  -2 max_lat=  +2
        fcb   $38,$FF,$F7,$01  ; seg 121  yaw= +56 pitch=  -1 min_lat=  -9 max_lat=  +1
        fcb   $38,$00,$F8,$00  ; seg 122  yaw= +56 pitch=  +0 min_lat=  -8 max_lat=  +0
        fcb   $38,$00,$F9,$FF  ; seg 123  yaw= +56 pitch=  +0 min_lat=  -7 max_lat=  -1
        fcb   $38,$00,$FA,$FE  ; seg 124  yaw= +56 pitch=  +0 min_lat=  -6 max_lat=  -2
        fcb   $38,$FE,$FB,$05  ; seg 125  yaw= +56 pitch=  -2 min_lat=  -5 max_lat=  +5
        fcb   $38,$FC,$FC,$04  ; seg 126  yaw= +56 pitch=  -4 min_lat=  -4 max_lat=  +4
        fcb   $38,$FC,$FD,$03  ; seg 127  yaw= +56 pitch=  -4 min_lat=  -3 max_lat=  +3
        fcb   $38,$FC,$FE,$02  ; seg 128  yaw= +56 pitch=  -4 min_lat=  -2 max_lat=  +2
        fcb   $38,$FD,$FF,$09  ; seg 129  yaw= +56 pitch=  -3 min_lat=  -1 max_lat=  +9
        fcb   $38,$FE,$00,$08  ; seg 130  yaw= +56 pitch=  -2 min_lat=  +0 max_lat=  +8
        fcb   $38,$FF,$01,$07  ; seg 131  yaw= +56 pitch=  -1 min_lat=  +1 max_lat=  +7
        fcb   $38,$00,$02,$06  ; seg 132  yaw= +56 pitch=  +0 min_lat=  +2 max_lat=  +6
        fcb   $38,$00,$F6,$05  ; seg 133  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $38,$00,$F6,$04  ; seg 134  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $38,$00,$F6,$03  ; seg 135  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $38,$00,$F6,$02  ; seg 136  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $3C,$00,$F6,$01  ; seg 137  yaw= +60 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $40,$00,$F6,$00  ; seg 138  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $44,$00,$F6,$FF  ; seg 139  yaw= +68 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $48,$00,$F6,$FE  ; seg 140  yaw= +72 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $4C,$FF,$F6,$0A  ; seg 141  yaw= +76 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $50,$FE,$F6,$0A  ; seg 142  yaw= +80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $54,$FD,$F6,$0A  ; seg 143  yaw= +84 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $58,$FC,$F6,$0A  ; seg 144  yaw= +88 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $5C,$FC,$F6,$0A  ; seg 145  yaw= +92 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $60,$FC,$F6,$0A  ; seg 146  yaw= +96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $64,$FC,$F6,$0A  ; seg 147  yaw=+100 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $68,$FC,$F6,$0A  ; seg 148  yaw=+104 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $6E,$FD,$F6,$0A  ; seg 149  yaw=+110 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $74,$FE,$F6,$0A  ; seg 150  yaw=+116 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $7A,$FF,$F6,$0A  ; seg 151  yaw=+122 pitch=  -1 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 152 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 153 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 154 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 155 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 156 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 157 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 158 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 159 (wraparound de seg 7)
