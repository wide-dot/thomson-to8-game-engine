* ======================================================================
* Circuit_02_easy_2 — N=192 segments (format compact 8 oct/seg)
* Source       : 02_easy_2.bin (extrait de FILE30)
*
* Pays         : ICELAND
* Lieu         : fiskivotn
* Description  : steeper hills and sharper bends
* Hazards      : extra fuel needed
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000048 01:#90B4FC 02:#4890D8 03:#244890 04:#4890D8 05:#B40000 06:#242424 07:#242424
*   08:#486CB4 09:#D8D8D8 10:#242448 11:#FCFCFC 12:#24486C 13:#244890 14:#244890 15:#2448B4
*   16:#2448B4 17:#2448D8 18:#2448D8 19:#2448FC 20:#2448FC 21:#0048FC 22:#006CFC 23:#006CFC
*   24:#0090FC 25:#0090FC 26:#00B4FC 27:#00B4FC
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
* Taille totale : 2418 oct (nb_segments 2 + LUT 16 + segments 1600 + cache 800).
* ======================================================================

Circuit_02_easy_2_nb_segments
        fdb   192

Circuit_02_easy_2_sprite_lut
        fcb   $00,$82,$83,$92,$88,$84,$8B,$8A,$80,$81,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_02_easy_2_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$03,$00,$1C,$00,$00,$00  ; seg   8                      flags=[PIT]   #0:$92@+28
        fcb   $80,$00,$40,$00,$00,$E0,$00,$00  ; seg   9                      flags=[PIT]   #1:$88@-32
        fcb   $80,$00,$45,$00,$EC,$C0,$00,$00  ; seg  10                      flags=[PIT]   #0:$84@-20 #1:$88@-64
        fcb   $80,$00,$05,$04,$EC,$00,$E4,$00  ; seg  11                      flags=[PIT]   #0:$84@-20 #2:$88@-28
        fcb   $80,$00,$05,$00,$EC,$00,$00,$00  ; seg  12                      flags=[PIT]   #0:$84@-20
        fcb   $80,$00,$35,$00,$EC,$24,$00,$00  ; seg  13                      flags=[PIT]   #0:$84@-20 #1:$92@+36
        fcb   $80,$00,$45,$00,$EC,$20,$00,$00  ; seg  14                      flags=[PIT]   #0:$84@-20 #1:$88@+32
        fcb   $80,$00,$05,$40,$EC,$00,$00,$CC  ; seg  15                      flags=[PIT]   #0:$84@-20 #3:$88@-52
        fcb   $00,$00,$05,$00,$14,$00,$00,$00  ; seg  16                                    #0:$84@+20
        fcb   $00,$00,$65,$00,$14,$28,$00,$00  ; seg  17                                    #0:$84@+20 #1:$8B@+40
        fcb   $00,$00,$05,$40,$14,$00,$00,$14  ; seg  18                                    #0:$84@+20 #3:$88@+20
        fcb   $00,$00,$05,$00,$14,$00,$00,$00  ; seg  19                                    #0:$84@+20
        fcb   $00,$00,$35,$00,$14,$30,$00,$00  ; seg  20                                    #0:$84@+20 #1:$92@+48
        fcb   $00,$00,$45,$00,$14,$EC,$00,$00  ; seg  21                                    #0:$84@+20 #1:$88@-20
        fcb   $00,$00,$45,$00,$EC,$E4,$00,$00  ; seg  22                                    #0:$84@-20 #1:$88@-28
        fcb   $00,$00,$05,$06,$EC,$00,$1C,$00  ; seg  23                                    #0:$84@-20 #2:$8B@+28
        fcb   $00,$00,$05,$40,$EC,$00,$00,$20  ; seg  24                                    #0:$84@-20 #3:$88@+32
        fcb   $00,$00,$05,$04,$EC,$00,$24,$00  ; seg  25                                    #0:$84@-20 #2:$88@+36
        fcb   $00,$00,$05,$03,$EC,$00,$EC,$00  ; seg  26                                    #0:$84@-20 #2:$92@-20
        fcb   $00,$00,$45,$00,$EC,$18,$00,$00  ; seg  27                                    #0:$84@-20 #1:$88@+24
        fcb   $00,$00,$00,$40,$00,$00,$00,$D0  ; seg  28                                    #3:$88@-48
        fcb   $00,$00,$00,$07,$00,$00,$D8,$00  ; seg  29                                    #2:$8A@-40
        fcb   $00,$00,$08,$08,$12,$00,$12,$00  ; seg  30                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$48,$08,$12,$2C,$12,$00  ; seg  31                                    #0:$80@+18 #1:$88@+44 #2:$80@+18
        fcb   $04,$00,$08,$06,$12,$00,$C8,$00  ; seg  32  curve=+4                          #0:$80@+18 #2:$8B@-56
        fcb   $04,$00,$08,$03,$12,$00,$E4,$00  ; seg  33  curve=+4                          #0:$80@+18 #2:$92@-28
        fcb   $04,$00,$40,$00,$00,$24,$00,$00  ; seg  34  curve=+4                          #1:$88@+36
        fcb   $04,$00,$47,$00,$24,$1C,$00,$00  ; seg  35  curve=+4                          #0:$8A@+36 #1:$88@+28
        fcb   $00,$00,$07,$30,$28,$00,$00,$E8  ; seg  36                                    #0:$8A@+40 #3:$92@-24
        fcb   $00,$00,$40,$00,$00,$E4,$00,$00  ; seg  37                                    #1:$88@-28
        fcb   $00,$00,$88,$88,$12,$12,$12,$12  ; seg  38                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$88,$88,$12,$12,$12,$12  ; seg  39                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  40  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$08,$08,$12,$00,$12,$00  ; seg  41  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$03,$00,$18,$00,$00,$00  ; seg  42  curve=+6                          #0:$92@+24
        fcb   $06,$00,$00,$04,$00,$00,$18,$00  ; seg  43  curve=+6                          #2:$88@+24
        fcb   $00,$00,$00,$47,$00,$00,$20,$EC  ; seg  44                                    #2:$8A@+32 #3:$88@-20
        fcb   $00,$00,$00,$06,$00,$00,$24,$00  ; seg  45                                    #2:$8B@+36
        fcb   $00,$00,$09,$09,$EE,$00,$EE,$00  ; seg  46                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$49,$09,$EE,$28,$EE,$00  ; seg  47                                    #0:$81@-18 #1:$88@+40 #2:$81@-18
        fcb   $7C,$00,$09,$09,$EE,$00,$EE,$00  ; seg  48  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$09,$79,$EE,$00,$EE,$14  ; seg  49  curve=-4                          #0:$81@-18 #2:$81@-18 #3:$8A@+20
        fcb   $7C,$00,$09,$09,$EE,$00,$EE,$00  ; seg  50  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$09,$49,$EE,$00,$EE,$E0  ; seg  51  curve=-4                          #0:$81@-18 #2:$81@-18 #3:$88@-32
        fcb   $7C,$00,$09,$09,$EE,$00,$EE,$00  ; seg  52  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$09,$09,$EE,$00,$EE,$00  ; seg  53  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$70,$00,$00,$CC,$00,$00  ; seg  54  curve=-4                          #1:$8A@-52
        fcb   $7C,$00,$00,$60,$00,$00,$00,$E4  ; seg  55  curve=-4                          #3:$8B@-28
        fcb   $00,$00,$00,$04,$00,$00,$16,$00  ; seg  56                                    #2:$88@+22
        fcb   $00,$00,$00,$03,$00,$00,$EA,$00  ; seg  57                                    #2:$92@-22
        fcb   $00,$00,$09,$09,$EE,$00,$EE,$00  ; seg  58                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$79,$09,$EE,$E0,$EE,$00  ; seg  59                                    #0:$81@-18 #1:$8A@-32 #2:$81@-18
        fcb   $7B,$00,$09,$00,$EE,$00,$00,$00  ; seg  60  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$49,$00,$EE,$D8,$00,$00  ; seg  61  curve=-5                          #0:$81@-18 #1:$88@-40
        fcb   $7B,$00,$09,$00,$EE,$00,$00,$00  ; seg  62  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$79,$00,$EE,$CC,$00,$00  ; seg  63  curve=-5                          #0:$81@-18 #1:$8A@-52
        fcb   $7B,$00,$09,$03,$EE,$00,$DC,$00  ; seg  64  curve=-5                          #0:$81@-18 #2:$92@-36
        fcb   $7B,$00,$09,$00,$EE,$00,$00,$00  ; seg  65  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$00,$04,$00,$00,$E0,$00  ; seg  66  curve=-5                          #2:$88@-32
        fcb   $7B,$00,$00,$70,$00,$00,$00,$E0  ; seg  67  curve=-5                          #3:$8A@-32
        fcb   $00,$7E,$05,$00,$14,$00,$00,$00  ; seg  68            pitch=-2                #0:$84@+20
        fcb   $00,$7E,$05,$00,$14,$00,$00,$00  ; seg  69            pitch=-2                #0:$84@+20
        fcb   $00,$7E,$35,$00,$14,$1C,$00,$00  ; seg  70            pitch=-2                #0:$84@+20 #1:$92@+28
        fcb   $00,$7E,$45,$00,$14,$28,$00,$00  ; seg  71            pitch=-2                #0:$84@+20 #1:$88@+40
        fcb   $00,$7E,$05,$40,$14,$00,$00,$18  ; seg  72            pitch=-2                #0:$84@+20 #3:$88@+24
        fcb   $00,$7E,$05,$04,$14,$00,$24,$00  ; seg  73            pitch=-2                #0:$84@+20 #2:$88@+36
        fcb   $00,$7E,$05,$00,$14,$00,$00,$00  ; seg  74            pitch=-2                #0:$84@+20
        fcb   $00,$7E,$05,$00,$14,$00,$00,$00  ; seg  75            pitch=-2                #0:$84@+20
        fcb   $00,$03,$30,$00,$00,$CC,$00,$00  ; seg  76            pitch=+3                #1:$92@-52
        fcb   $00,$03,$00,$07,$00,$00,$1C,$00  ; seg  77            pitch=+3                #2:$8A@+28
        fcb   $00,$03,$00,$70,$00,$00,$00,$14  ; seg  78            pitch=+3                #3:$8A@+20
        fcb   $00,$03,$40,$00,$00,$E0,$00,$00  ; seg  79            pitch=+3                #1:$88@-32
        fcb   $00,$03,$05,$00,$EC,$00,$00,$00  ; seg  80            pitch=+3                #0:$84@-20
        fcb   $00,$03,$05,$00,$EC,$00,$00,$00  ; seg  81            pitch=+3                #0:$84@-20
        fcb   $00,$03,$05,$60,$EC,$00,$00,$24  ; seg  82            pitch=+3                #0:$84@-20 #3:$8B@+36
        fcb   $00,$03,$05,$04,$EC,$00,$E4,$00  ; seg  83            pitch=+3                #0:$84@-20 #2:$88@-28
        fcb   $00,$7E,$05,$04,$EC,$00,$DC,$00  ; seg  84            pitch=-2                #0:$84@-20 #2:$88@-36
        fcb   $00,$7E,$05,$70,$EC,$00,$00,$14  ; seg  85            pitch=-2                #0:$84@-20 #3:$8A@+20
        fcb   $00,$7E,$05,$70,$EC,$00,$00,$18  ; seg  86            pitch=-2                #0:$84@-20 #3:$8A@+24
        fcb   $00,$7E,$05,$30,$EC,$00,$00,$D8  ; seg  87            pitch=-2                #0:$84@-20 #3:$92@-40
        fcb   $00,$00,$40,$00,$00,$D0,$00,$00  ; seg  88                                    #1:$88@-48
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  89
        fcb   $00,$00,$09,$09,$EE,$00,$EE,$00  ; seg  90                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$09,$09,$EE,$00,$EE,$00  ; seg  91                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$09,$00,$EE,$00,$00,$00  ; seg  92  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$09,$40,$EE,$00,$00,$E0  ; seg  93  curve=-4                          #0:$81@-18 #3:$88@-32
        fcb   $7C,$00,$00,$30,$00,$00,$00,$DC  ; seg  94  curve=-4                          #3:$92@-36
        fcb   $7C,$00,$00,$60,$00,$00,$00,$C8  ; seg  95  curve=-4                          #3:$8B@-56
        fcb   $00,$01,$07,$00,$20,$00,$00,$00  ; seg  96            pitch=+1                #0:$8A@+32
        fcb   $00,$01,$04,$07,$C8,$00,$D4,$00  ; seg  97            pitch=+1                #0:$88@-56 #2:$8A@-44
        fcb   $00,$01,$46,$00,$E4,$1C,$00,$00  ; seg  98            pitch=+1                #0:$8B@-28 #1:$88@+28
        fcb   $00,$01,$00,$03,$00,$00,$18,$00  ; seg  99            pitch=+1                #2:$92@+24
        fcb   $00,$7F,$05,$00,$14,$00,$00,$00  ; seg 100            pitch=-1                #0:$84@+20
        fcb   $00,$7F,$05,$30,$14,$00,$00,$28  ; seg 101            pitch=-1                #0:$84@+20 #3:$92@+40
        fcb   $00,$7F,$05,$03,$14,$00,$24,$00  ; seg 102            pitch=-1                #0:$84@+20 #2:$92@+36
        fcb   $00,$7F,$45,$00,$14,$30,$00,$00  ; seg 103            pitch=-1                #0:$84@+20 #1:$88@+48
        fcb   $00,$00,$00,$07,$00,$00,$30,$00  ; seg 104                                    #2:$8A@+48
        fcb   $00,$00,$46,$00,$D8,$24,$00,$00  ; seg 105                                    #0:$8B@-40 #1:$88@+36
        fcb   $00,$00,$09,$09,$EE,$00,$EE,$00  ; seg 106                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$09,$30,$EE,$00,$00,$DC  ; seg 107                                    #0:$81@-18 #3:$92@-36
        fcb   $7C,$00,$09,$00,$EE,$00,$00,$00  ; seg 108  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$79,$00,$EE,$E0,$00,$00  ; seg 109  curve=-4                          #0:$81@-18 #1:$8A@-32
        fcb   $7C,$00,$07,$40,$E0,$00,$00,$E0  ; seg 110  curve=-4                          #0:$8A@-32 #3:$88@-32
        fcb   $7C,$00,$00,$03,$00,$00,$20,$00  ; seg 111  curve=-4                          #2:$92@+32
        fcb   $00,$01,$70,$00,$00,$D8,$00,$00  ; seg 112            pitch=+1                #1:$8A@-40
        fcb   $00,$01,$04,$00,$D4,$00,$00,$00  ; seg 113            pitch=+1                #0:$88@-44
        fcb   $00,$01,$00,$04,$00,$00,$18,$00  ; seg 114            pitch=+1                #2:$88@+24
        fcb   $00,$01,$07,$00,$EC,$00,$00,$00  ; seg 115            pitch=+1                #0:$8A@-20
        fcb   $00,$7F,$30,$40,$00,$E4,$00,$20  ; seg 116            pitch=-1                #1:$92@-28 #3:$88@+32
        fcb   $00,$7F,$00,$06,$00,$00,$1C,$00  ; seg 117            pitch=-1                #2:$8B@+28
        fcb   $00,$7F,$00,$60,$00,$00,$00,$24  ; seg 118            pitch=-1                #3:$8B@+36
        fcb   $00,$7F,$00,$03,$00,$00,$E4,$00  ; seg 119            pitch=-1                #2:$92@-28
        fcb   $00,$00,$04,$04,$EE,$00,$E0,$00  ; seg 120                                    #0:$88@-18 #2:$88@-32
        fcb   $00,$00,$04,$03,$EE,$00,$EC,$00  ; seg 121                                    #0:$88@-18 #2:$92@-20
        fcb   $00,$00,$04,$40,$EE,$00,$00,$E0  ; seg 122                                    #0:$88@-18 #3:$88@-32
        fcb   $00,$00,$04,$60,$EE,$00,$00,$20  ; seg 123                                    #0:$88@-18 #3:$8B@+32
        fcb   $00,$00,$04,$40,$EE,$00,$00,$1C  ; seg 124                                    #0:$88@-18 #3:$88@+28
        fcb   $00,$00,$04,$00,$EE,$00,$00,$00  ; seg 125                                    #0:$88@-18
        fcb   $00,$00,$44,$00,$EE,$EC,$00,$00  ; seg 126                                    #0:$88@-18 #1:$88@-20
        fcb   $00,$00,$64,$00,$EE,$DC,$00,$00  ; seg 127                                    #0:$88@-18 #1:$8B@-36
        fcb   $00,$02,$70,$00,$00,$20,$00,$00  ; seg 128            pitch=+2                #1:$8A@+32
        fcb   $00,$02,$04,$00,$D8,$00,$00,$00  ; seg 129            pitch=+2                #0:$88@-40
        fcb   $00,$02,$30,$00,$00,$24,$00,$00  ; seg 130            pitch=+2                #1:$92@+36
        fcb   $00,$02,$00,$60,$00,$00,$00,$20  ; seg 131            pitch=+2                #3:$8B@+32
        fcb   $00,$7E,$07,$00,$E4,$00,$00,$00  ; seg 132            pitch=-2                #0:$8A@-28
        fcb   $00,$7E,$00,$30,$00,$00,$00,$E8  ; seg 133            pitch=-2                #3:$92@-24
        fcb   $00,$7E,$07,$00,$2C,$00,$00,$00  ; seg 134            pitch=-2                #0:$8A@+44
        fcb   $00,$7E,$00,$04,$00,$00,$E8,$00  ; seg 135            pitch=-2                #2:$88@-24
        fcb   $00,$00,$00,$03,$00,$00,$20,$00  ; seg 136                                    #2:$92@+32
        fcb   $00,$00,$04,$00,$24,$00,$00,$00  ; seg 137                                    #0:$88@+36
        fcb   $00,$00,$09,$09,$EE,$00,$EE,$00  ; seg 138                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$09,$09,$EE,$00,$EE,$00  ; seg 139                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$09,$03,$EE,$00,$24,$00  ; seg 140  curve=-4                          #0:$81@-18 #2:$92@+36
        fcb   $7C,$00,$09,$04,$EE,$00,$1C,$00  ; seg 141  curve=-4                          #0:$81@-18 #2:$88@+28
        fcb   $7C,$00,$70,$00,$00,$E8,$00,$00  ; seg 142  curve=-4                          #1:$8A@-24
        fcb   $7C,$00,$00,$30,$00,$00,$00,$1C  ; seg 143  curve=-4                          #3:$92@+28
        fcb   $00,$00,$04,$03,$12,$00,$EE,$00  ; seg 144                                    #0:$88@+18 #2:$92@-18
        fcb   $00,$00,$04,$43,$12,$00,$EE,$14  ; seg 145                                    #0:$88@+18 #2:$92@-18 #3:$88@+20
        fcb   $00,$00,$00,$03,$00,$00,$EE,$00  ; seg 146                                    #2:$92@-18
        fcb   $00,$00,$44,$03,$12,$18,$EE,$00  ; seg 147                                    #0:$88@+18 #1:$88@+24 #2:$92@-18
        fcb   $00,$02,$04,$43,$12,$00,$EE,$30  ; seg 148            pitch=+2                #0:$88@+18 #2:$92@-18 #3:$88@+48
        fcb   $00,$02,$04,$00,$12,$00,$00,$00  ; seg 149            pitch=+2                #0:$88@+18
        fcb   $00,$02,$04,$03,$12,$00,$EE,$00  ; seg 150            pitch=+2                #0:$88@+18 #2:$92@-18
        fcb   $00,$02,$34,$03,$12,$1C,$EE,$00  ; seg 151            pitch=+2                #0:$88@+18 #1:$92@+28 #2:$92@-18
        fcb   $00,$7E,$04,$06,$12,$00,$14,$00  ; seg 152            pitch=-2                #0:$88@+18 #2:$8B@+20
        fcb   $00,$7E,$40,$00,$00,$E4,$00,$00  ; seg 153            pitch=-2                #1:$88@-28
        fcb   $00,$7E,$04,$70,$12,$00,$00,$DC  ; seg 154            pitch=-2                #0:$88@+18 #3:$8A@-36
        fcb   $00,$7E,$04,$30,$12,$00,$00,$CC  ; seg 155            pitch=-2                #0:$88@+18 #3:$92@-52
        fcb   $00,$00,$40,$00,$00,$E8,$00,$00  ; seg 156                                    #1:$88@-24
        fcb   $00,$00,$04,$40,$14,$00,$00,$20  ; seg 157                                    #0:$88@+20 #3:$88@+32
        fcb   $00,$00,$99,$99,$EE,$EE,$EE,$EE  ; seg 158                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$99,$99,$EE,$EE,$EE,$EE  ; seg 159                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$69,$09,$EE,$CC,$EE,$00  ; seg 160  curve=-6                          #0:$81@-18 #1:$8B@-52 #2:$81@-18
        fcb   $7A,$00,$09,$39,$EE,$00,$EE,$D0  ; seg 161  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$92@-48
        fcb   $7A,$00,$09,$79,$EE,$00,$EE,$30  ; seg 162  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8A@+48
        fcb   $7A,$00,$49,$09,$EE,$E4,$EE,$00  ; seg 163  curve=-6                          #0:$81@-18 #1:$88@-28 #2:$81@-18
        fcb   $7A,$00,$09,$09,$EE,$00,$EE,$00  ; seg 164  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$09,$09,$EE,$00,$EE,$00  ; seg 165  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$03,$20,$00,$20,$00  ; seg 166  curve=-6                          #0:$88@+32 #2:$92@+32
        fcb   $7A,$00,$40,$00,$00,$EC,$00,$00  ; seg 167  curve=-6                          #1:$88@-20
        fcb   $00,$00,$05,$70,$14,$00,$00,$38  ; seg 168                                    #0:$84@+20 #3:$8A@+56
        fcb   $00,$00,$35,$00,$14,$EC,$00,$00  ; seg 169                                    #0:$84@+20 #1:$92@-20
        fcb   $00,$00,$45,$00,$14,$DC,$00,$00  ; seg 170                                    #0:$84@+20 #1:$88@-36
        fcb   $00,$00,$05,$07,$14,$00,$1C,$00  ; seg 171                                    #0:$84@+20 #2:$8A@+28
        fcb   $00,$7E,$65,$00,$EC,$E4,$00,$00  ; seg 172            pitch=-2                #0:$84@-20 #1:$8B@-28
        fcb   $00,$7E,$05,$44,$EC,$00,$E4,$20  ; seg 173            pitch=-2                #0:$84@-20 #2:$88@-28 #3:$88@+32
        fcb   $00,$02,$05,$00,$EC,$00,$00,$00  ; seg 174            pitch=+2                #0:$84@-20
        fcb   $00,$02,$65,$00,$EC,$30,$00,$00  ; seg 175            pitch=+2                #0:$84@-20 #1:$8B@+48
        fcb   $00,$00,$05,$04,$14,$00,$E0,$00  ; seg 176                                    #0:$84@+20 #2:$88@-32
        fcb   $00,$00,$35,$00,$14,$E8,$00,$00  ; seg 177                                    #0:$84@+20 #1:$92@-24
        fcb   $00,$00,$05,$40,$14,$00,$00,$D8  ; seg 178                                    #0:$84@+20 #3:$88@-40
        fcb   $00,$00,$05,$04,$14,$00,$30,$00  ; seg 179                                    #0:$84@+20 #2:$88@+48
        fcb   $00,$7E,$65,$00,$EC,$14,$00,$00  ; seg 180            pitch=-2                #0:$84@-20 #1:$8B@+20
        fcb   $00,$7E,$35,$00,$EC,$1C,$00,$00  ; seg 181            pitch=-2                #0:$84@-20 #1:$92@+28
        fcb   $00,$02,$05,$40,$EC,$00,$00,$24  ; seg 182            pitch=+2                #0:$84@-20 #3:$88@+36
        fcb   $00,$02,$05,$07,$EC,$00,$24,$00  ; seg 183            pitch=+2                #0:$84@-20 #2:$8A@+36
        fcb   $00,$00,$05,$00,$14,$00,$00,$00  ; seg 184                                    #0:$84@+20
        fcb   $00,$00,$05,$00,$14,$00,$00,$00  ; seg 185                                    #0:$84@+20
        fcb   $00,$00,$05,$00,$14,$00,$00,$00  ; seg 186                                    #0:$84@+20
        fcb   $00,$00,$05,$00,$14,$00,$00,$00  ; seg 187                                    #0:$84@+20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg 188                                    #0:$84@-20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg 189                                    #0:$84@-20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg 190                                    #0:$84@-20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg 191                                    #0:$84@-20
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 192                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 193
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 194
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 195
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 196                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 197                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 198                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 199                                    #0:$83@+18 #2:$83@+18

Circuit_02_easy_2_segment_cache
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
        fcb   $00,$00,$F6,$0A  ; seg  19  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  20  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  21  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  22  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  23  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  24  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  25  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  26  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  27  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  28  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  29  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  30  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  31  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  32  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $04,$00,$F6,$0A  ; seg  33  yaw=  +4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  34  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$00,$F6,$0A  ; seg  35  yaw= +12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  36  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  37  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  38  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  39  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  40  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $16,$00,$F6,$0A  ; seg  41  yaw= +22 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1C,$00,$F6,$0A  ; seg  42  yaw= +28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $22,$00,$F6,$0A  ; seg  43  yaw= +34 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  44  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  45  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  46  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  47  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  48  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $24,$00,$F6,$0A  ; seg  49  yaw= +36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  50  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1C,$00,$F6,$0A  ; seg  51  yaw= +28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $18,$00,$F6,$0A  ; seg  52  yaw= +24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg  53  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  54  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$00,$F6,$0A  ; seg  55  yaw= +12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  56  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  57  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  58  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  59  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  60  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $03,$00,$F6,$0A  ; seg  61  yaw=  +3 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FE,$00,$F6,$0A  ; seg  62  yaw=  -2 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F9,$00,$F6,$0A  ; seg  63  yaw=  -7 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  64  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EF,$00,$F6,$0A  ; seg  65  yaw= -17 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EA,$00,$F6,$0A  ; seg  66  yaw= -22 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E5,$00,$F6,$0A  ; seg  67  yaw= -27 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  68  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$FE,$F6,$0A  ; seg  69  yaw= -32 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  70  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FA,$F6,$0A  ; seg  71  yaw= -32 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $E0,$F8,$F6,$0A  ; seg  72  yaw= -32 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $E0,$F6,$F6,$0A  ; seg  73  yaw= -32 pitch= -10 min_lat= -10 max_lat= +10
        fcb   $E0,$F4,$F6,$0A  ; seg  74  yaw= -32 pitch= -12 min_lat= -10 max_lat= +10
        fcb   $E0,$F2,$F6,$0A  ; seg  75  yaw= -32 pitch= -14 min_lat= -10 max_lat= +10
        fcb   $E0,$F0,$F6,$0A  ; seg  76  yaw= -32 pitch= -16 min_lat= -10 max_lat= +10
        fcb   $E0,$F3,$F6,$0A  ; seg  77  yaw= -32 pitch= -13 min_lat= -10 max_lat= +10
        fcb   $E0,$F6,$F6,$0A  ; seg  78  yaw= -32 pitch= -10 min_lat= -10 max_lat= +10
        fcb   $E0,$F9,$F6,$0A  ; seg  79  yaw= -32 pitch=  -7 min_lat= -10 max_lat= +10
        fcb   $E0,$FC,$F6,$0A  ; seg  80  yaw= -32 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $E0,$FF,$F6,$0A  ; seg  81  yaw= -32 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  82  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$05,$F6,$0A  ; seg  83  yaw= -32 pitch=  +5 min_lat= -10 max_lat= +10
        fcb   $E0,$08,$F6,$0A  ; seg  84  yaw= -32 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $E0,$06,$F6,$0A  ; seg  85  yaw= -32 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $E0,$04,$F6,$0A  ; seg  86  yaw= -32 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $E0,$02,$F6,$0A  ; seg  87  yaw= -32 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  88  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  89  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  90  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  91  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  92  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  93  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  94  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  95  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  96  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$01,$F6,$0A  ; seg  97  yaw= -48 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $D0,$02,$F6,$0A  ; seg  98  yaw= -48 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $D0,$03,$F6,$0A  ; seg  99  yaw= -48 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $D0,$04,$F6,$0A  ; seg 100  yaw= -48 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $D0,$03,$F6,$0A  ; seg 101  yaw= -48 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $D0,$02,$F6,$0A  ; seg 102  yaw= -48 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $D0,$01,$F6,$0A  ; seg 103  yaw= -48 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 104  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 105  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 106  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 107  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 108  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg 109  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 110  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg 111  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 112  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 113  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 114  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 115  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 116  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 117  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 118  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 119  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 120  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 121  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 122  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 123  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 124  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 125  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 126  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 127  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 128  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 129  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 130  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 131  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$08,$F6,$0A  ; seg 132  yaw= -64 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 133  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 134  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 135  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 136  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 137  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 138  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 139  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 140  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 141  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg 142  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 143  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 144  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 145  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 146  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 147  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 148  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg 149  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 150  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$06,$F6,$0A  ; seg 151  yaw= -80 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg 152  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$06,$F6,$0A  ; seg 153  yaw= -80 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg 154  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg 155  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 156  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 157  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 158  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 159  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 160  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AA,$00,$F6,$0A  ; seg 161  yaw= -86 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 162  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9E,$00,$F6,$0A  ; seg 163  yaw= -98 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 164  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg 165  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 166  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg 167  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 168  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 169  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 170  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 171  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 172  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 173  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FC,$F6,$0A  ; seg 174  yaw=-128 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 175  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 176  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 177  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 178  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 179  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 180  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 181  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$FC,$F6,$0A  ; seg 182  yaw=-128 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 183  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 184  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 185  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 186  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 187  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 188  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 189  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 190  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 191  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 192 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 193 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 194 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 195 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 196 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 197 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 198 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 199 (wraparound de seg 7)
