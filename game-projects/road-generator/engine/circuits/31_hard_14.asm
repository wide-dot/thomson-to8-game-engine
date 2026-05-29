* ======================================================================
* Circuit_31_hard_14 — N=152 segments (format compact 8 oct/seg)
* Source       : 31_hard_14.bin (extrait de FILE30)
*
* Pays         : ANTARCTICA
* Lieu         : halley bay
* Description  : many chicanes and sharp bends
* Hazards      : good luck
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
* Taille totale : 1938 oct (nb_segments 2 + LUT 16 + segments 1280 + cache 640).
* ======================================================================

Circuit_31_hard_14_nb_segments
        fdb   152

Circuit_31_hard_14_sprite_lut
        fcb   $00,$82,$83,$88,$93,$81,$80,$84,$00,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_31_hard_14_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg   8                      flags=[PIT]   #0:$88@-18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg   9                      flags=[PIT]   #0:$88@-18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg  10                      flags=[PIT]   #0:$88@-18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg  11                      flags=[PIT]   #0:$88@-18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg  12                      flags=[PIT]   #0:$88@-18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg  13                      flags=[PIT]   #0:$88@-18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg  14                      flags=[PIT]   #0:$88@-18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg  15                      flags=[PIT]   #0:$88@-18
        fcb   $00,$00,$03,$40,$EE,$00,$00,$20  ; seg  16                                    #0:$88@-18 #3:$93@+32
        fcb   $00,$00,$03,$40,$EE,$00,$00,$30  ; seg  17                                    #0:$88@-18 #3:$93@+48
        fcb   $00,$03,$03,$00,$EE,$00,$00,$00  ; seg  18            pitch=+3                #0:$88@-18
        fcb   $00,$7D,$03,$40,$EE,$00,$00,$20  ; seg  19            pitch=-3                #0:$88@-18 #3:$93@+32
        fcb   $00,$7D,$03,$40,$EE,$00,$00,$30  ; seg  20            pitch=-3                #0:$88@-18 #3:$93@+48
        fcb   $00,$03,$03,$00,$EE,$00,$00,$00  ; seg  21            pitch=+3                #0:$88@-18
        fcb   $00,$03,$03,$40,$12,$00,$00,$E0  ; seg  22            pitch=+3                #0:$88@+18 #3:$93@-32
        fcb   $00,$03,$03,$00,$12,$00,$00,$00  ; seg  23            pitch=+3                #0:$88@+18
        fcb   $00,$00,$03,$40,$12,$00,$00,$D0  ; seg  24                                    #0:$88@+18 #3:$93@-48
        fcb   $00,$00,$03,$00,$12,$00,$00,$00  ; seg  25                                    #0:$88@+18
        fcb   $00,$00,$03,$40,$EE,$00,$00,$20  ; seg  26                                    #0:$88@-18 #3:$93@+32
        fcb   $00,$00,$03,$00,$EE,$00,$00,$00  ; seg  27                                    #0:$88@-18
        fcb   $00,$7E,$03,$40,$EE,$00,$00,$30  ; seg  28            pitch=-2                #0:$88@-18 #3:$93@+48
        fcb   $00,$7E,$03,$00,$EE,$00,$00,$00  ; seg  29            pitch=-2                #0:$88@-18
        fcb   $00,$7F,$03,$40,$12,$00,$00,$E0  ; seg  30            pitch=-1                #0:$88@+18 #3:$93@-32
        fcb   $00,$7F,$03,$00,$12,$00,$00,$00  ; seg  31            pitch=-1                #0:$88@+18
        fcb   $00,$00,$03,$00,$12,$00,$00,$00  ; seg  32                                    #0:$88@+18
        fcb   $00,$00,$03,$40,$12,$00,$00,$20  ; seg  33                                    #0:$88@+18 #3:$93@+32
        fcb   $00,$02,$03,$00,$EE,$00,$00,$00  ; seg  34            pitch=+2                #0:$88@-18
        fcb   $00,$02,$03,$40,$EE,$00,$00,$30  ; seg  35            pitch=+2                #0:$88@-18 #3:$93@+48
        fcb   $00,$02,$03,$00,$EE,$00,$00,$00  ; seg  36            pitch=+2                #0:$88@-18
        fcb   $00,$02,$03,$00,$EE,$00,$00,$00  ; seg  37            pitch=+2                #0:$88@-18
        fcb   $00,$7E,$03,$40,$12,$00,$00,$D0  ; seg  38            pitch=-2                #0:$88@+18 #3:$93@-48
        fcb   $00,$7E,$03,$40,$12,$00,$00,$E0  ; seg  39            pitch=-2                #0:$88@+18 #3:$93@-32
        fcb   $00,$7E,$03,$00,$12,$00,$00,$00  ; seg  40            pitch=-2                #0:$88@+18
        fcb   $00,$7E,$03,$40,$12,$00,$00,$E0  ; seg  41            pitch=-2                #0:$88@+18 #3:$93@-32
        fcb   $00,$7E,$03,$00,$EE,$00,$00,$00  ; seg  42            pitch=-2                #0:$88@-18
        fcb   $00,$7E,$03,$00,$EE,$00,$00,$00  ; seg  43            pitch=-2                #0:$88@-18
        fcb   $00,$02,$03,$40,$EE,$00,$00,$20  ; seg  44            pitch=+2                #0:$88@-18 #3:$93@+32
        fcb   $00,$02,$03,$00,$EE,$00,$00,$00  ; seg  45            pitch=+2                #0:$88@-18
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  46                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  47                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  48  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  49  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$45,$EE,$00,$EE,$E0  ; seg  50  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$93@-32
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  51  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$45,$EE,$00,$EE,$D0  ; seg  52  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$93@-48
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  53  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$66,$66,$12,$12,$12,$12  ; seg  54  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$66,$66,$12,$12,$12,$12  ; seg  55  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$06,$06,$12,$00,$12,$00  ; seg  56  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$06,$46,$12,$00,$12,$D0  ; seg  57  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$93@-48
        fcb   $06,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  58  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $06,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  59  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  60  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  61  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$45,$EE,$00,$EE,$20  ; seg  62  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$93@+32
        fcb   $7A,$00,$05,$45,$EE,$00,$EE,$30  ; seg  63  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$93@+48
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  64  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  65  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$40,$12,$00,$00,$E0  ; seg  66  curve=-6                          #0:$88@+18 #3:$93@-32
        fcb   $7A,$00,$03,$40,$12,$00,$00,$D0  ; seg  67  curve=-6                          #0:$88@+18 #3:$93@-48
        fcb   $00,$00,$03,$40,$12,$00,$00,$E0  ; seg  68                                    #0:$88@+18 #3:$93@-32
        fcb   $00,$00,$03,$00,$12,$00,$00,$00  ; seg  69                                    #0:$88@+18
        fcb   $00,$00,$06,$46,$12,$00,$12,$E0  ; seg  70                                    #0:$80@+18 #2:$80@+18 #3:$93@-32
        fcb   $00,$00,$06,$06,$12,$00,$12,$00  ; seg  71                                    #0:$80@+18 #2:$80@+18
        fcb   $05,$7F,$06,$00,$12,$00,$00,$00  ; seg  72  curve=+5  pitch=-1                #0:$80@+18
        fcb   $05,$7F,$06,$40,$12,$00,$00,$D0  ; seg  73  curve=+5  pitch=-1                #0:$80@+18 #3:$93@-48
        fcb   $05,$00,$03,$00,$12,$00,$00,$00  ; seg  74  curve=+5                          #0:$88@+18
        fcb   $05,$00,$03,$00,$12,$00,$00,$00  ; seg  75  curve=+5                          #0:$88@+18
        fcb   $00,$00,$03,$40,$12,$00,$00,$E0  ; seg  76                                    #0:$88@+18 #3:$93@-32
        fcb   $00,$00,$03,$40,$12,$00,$00,$30  ; seg  77                                    #0:$88@+18 #3:$93@+48
        fcb   $00,$00,$06,$46,$12,$00,$12,$E0  ; seg  78                                    #0:$80@+18 #2:$80@+18 #3:$93@-32
        fcb   $00,$00,$06,$06,$12,$00,$12,$00  ; seg  79                                    #0:$80@+18 #2:$80@+18
        fcb   $05,$00,$06,$00,$12,$00,$00,$00  ; seg  80  curve=+5                          #0:$80@+18
        fcb   $05,$00,$06,$40,$12,$00,$00,$D0  ; seg  81  curve=+5                          #0:$80@+18 #3:$93@-48
        fcb   $05,$01,$55,$55,$EE,$EE,$EE,$EE  ; seg  82  curve=+5  pitch=+1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $05,$01,$55,$55,$EE,$EE,$EE,$EE  ; seg  83  curve=+5  pitch=+1                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  84  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$45,$EE,$00,$EE,$20  ; seg  85  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$93@+32
        fcb   $7A,$00,$66,$66,$12,$12,$12,$12  ; seg  86  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$66,$66,$12,$12,$12,$12  ; seg  87  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$06,$06,$12,$00,$12,$00  ; seg  88  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$06,$46,$12,$00,$12,$E0  ; seg  89  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$93@-32
        fcb   $06,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  90  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $06,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  91  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  92  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  93  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$45,$EE,$00,$EE,$D0  ; seg  94  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$93@-48
        fcb   $7A,$00,$05,$45,$EE,$00,$EE,$20  ; seg  95  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$93@+32
        fcb   $7A,$00,$05,$45,$EE,$00,$EE,$E0  ; seg  96  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$93@-32
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  97  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$66,$66,$12,$12,$12,$12  ; seg  98  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$66,$66,$12,$12,$12,$12  ; seg  99  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$06,$06,$12,$00,$12,$00  ; seg 100  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$06,$46,$12,$00,$12,$E0  ; seg 101  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$93@-32
        fcb   $06,$00,$03,$40,$EE,$00,$00,$D0  ; seg 102  curve=+6                          #0:$88@-18 #3:$93@-48
        fcb   $06,$00,$03,$40,$EE,$00,$00,$20  ; seg 103  curve=+6                          #0:$88@-18 #3:$93@+32
        fcb   $00,$00,$03,$00,$EE,$00,$00,$00  ; seg 104                                    #0:$88@-18
        fcb   $00,$00,$03,$40,$EE,$00,$00,$30  ; seg 105                                    #0:$88@-18 #3:$93@+48
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg 106                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg 107                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg 108  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$45,$EE,$00,$EE,$20  ; seg 109  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$93@+32
        fcb   $7A,$00,$66,$66,$12,$12,$12,$12  ; seg 110  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$66,$66,$12,$12,$12,$12  ; seg 111  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$7E,$06,$46,$12,$00,$12,$E0  ; seg 112  curve=+6  pitch=-2                #0:$80@+18 #2:$80@+18 #3:$93@-32
        fcb   $06,$7E,$06,$06,$12,$00,$12,$00  ; seg 113  curve=+6  pitch=-2                #0:$80@+18 #2:$80@+18
        fcb   $06,$7E,$55,$55,$EE,$EE,$EE,$EE  ; seg 114  curve=+6  pitch=-2                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $06,$7E,$55,$55,$EE,$EE,$EE,$EE  ; seg 115  curve=+6  pitch=-2                #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg 116  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg 117  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$40,$EE,$00,$00,$D0  ; seg 118  curve=-6                          #0:$88@-18 #3:$93@-48
        fcb   $7A,$00,$03,$40,$EE,$00,$00,$20  ; seg 119  curve=-6                          #0:$88@-18 #3:$93@+32
        fcb   $00,$02,$03,$00,$EE,$00,$00,$00  ; seg 120            pitch=+2                #0:$88@-18
        fcb   $00,$02,$03,$40,$EE,$00,$00,$E0  ; seg 121            pitch=+2                #0:$88@-18 #3:$93@-32
        fcb   $00,$02,$05,$05,$EE,$00,$EE,$00  ; seg 122            pitch=+2                #0:$81@-18 #2:$81@-18
        fcb   $00,$02,$05,$05,$EE,$00,$EE,$00  ; seg 123            pitch=+2                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg 124  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$40,$EE,$00,$00,$30  ; seg 125  curve=-4                          #0:$81@-18 #3:$93@+48
        fcb   $7C,$00,$03,$40,$EE,$00,$00,$D0  ; seg 126  curve=-4                          #0:$88@-18 #3:$93@-48
        fcb   $7C,$00,$03,$00,$EE,$00,$00,$00  ; seg 127  curve=-4                          #0:$88@-18
        fcb   $00,$7E,$03,$00,$EE,$00,$00,$00  ; seg 128            pitch=-2                #0:$88@-18
        fcb   $00,$7E,$03,$40,$EE,$00,$00,$D0  ; seg 129            pitch=-2                #0:$88@-18 #3:$93@-48
        fcb   $00,$02,$03,$40,$EE,$00,$00,$20  ; seg 130            pitch=+2                #0:$88@-18 #3:$93@+32
        fcb   $00,$02,$03,$40,$EE,$00,$00,$E0  ; seg 131            pitch=+2                #0:$88@-18 #3:$93@-32
        fcb   $00,$02,$03,$40,$EE,$00,$00,$30  ; seg 132            pitch=+2                #0:$88@-18 #3:$93@+48
        fcb   $00,$02,$03,$00,$EE,$00,$00,$00  ; seg 133            pitch=+2                #0:$88@-18
        fcb   $00,$7E,$05,$45,$EE,$00,$EE,$D0  ; seg 134            pitch=-2                #0:$81@-18 #2:$81@-18 #3:$93@-48
        fcb   $00,$7E,$05,$05,$EE,$00,$EE,$00  ; seg 135            pitch=-2                #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg 136  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$40,$EE,$00,$00,$20  ; seg 137  curve=-4                          #0:$81@-18 #3:$93@+32
        fcb   $7C,$00,$05,$40,$EE,$00,$00,$E0  ; seg 138  curve=-4                          #0:$81@-18 #3:$93@-32
        fcb   $7C,$00,$05,$40,$EE,$00,$00,$D0  ; seg 139  curve=-4                          #0:$81@-18 #3:$93@-48
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg 140  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$40,$EE,$00,$00,$E0  ; seg 141  curve=-4                          #0:$81@-18 #3:$93@-32
        fcb   $7C,$00,$07,$07,$EC,$00,$14,$00  ; seg 142  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $7C,$00,$07,$07,$EC,$00,$14,$00  ; seg 143  curve=-4                          #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$07,$07,$EC,$00,$14,$00  ; seg 144                                    #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$07,$07,$EC,$00,$14,$00  ; seg 145                                    #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$07,$07,$EC,$00,$14,$00  ; seg 146                                    #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$07,$07,$EC,$00,$14,$00  ; seg 147                                    #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$07,$07,$EC,$00,$14,$00  ; seg 148                                    #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$07,$07,$EC,$00,$14,$00  ; seg 149                                    #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$07,$07,$EC,$00,$14,$00  ; seg 150                                    #0:$84@-20 #2:$84@+20
        fcb   $00,$00,$07,$07,$EC,$00,$14,$00  ; seg 151                                    #0:$84@-20 #2:$84@+20
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 152                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 153
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 154
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 155
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 156                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 157                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 158                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 159                                    #0:$83@+18 #2:$83@+18

Circuit_31_hard_14_segment_cache
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
        fcb   $00,$03,$F6,$0A  ; seg  19  yaw=  +0 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  20  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FD,$F6,$0A  ; seg  21  yaw=  +0 pitch=  -3 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  22  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$03,$F6,$0A  ; seg  23  yaw=  +0 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $00,$06,$F6,$0A  ; seg  24  yaw=  +0 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $00,$06,$F6,$0A  ; seg  25  yaw=  +0 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $00,$06,$F6,$0A  ; seg  26  yaw=  +0 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $00,$06,$F6,$0A  ; seg  27  yaw=  +0 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $00,$06,$F6,$0A  ; seg  28  yaw=  +0 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $00,$04,$F6,$0A  ; seg  29  yaw=  +0 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  30  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $00,$01,$F6,$0A  ; seg  31  yaw=  +0 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  32  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  33  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  34  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  35  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $00,$04,$F6,$0A  ; seg  36  yaw=  +0 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $00,$06,$F6,$0A  ; seg  37  yaw=  +0 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $00,$08,$F6,$0A  ; seg  38  yaw=  +0 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $00,$06,$F6,$0A  ; seg  39  yaw=  +0 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $00,$04,$F6,$0A  ; seg  40  yaw=  +0 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $00,$02,$F6,$0A  ; seg  41  yaw=  +0 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  42  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  43  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$FC,$F6,$0A  ; seg  44  yaw=  +0 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $00,$FE,$F6,$0A  ; seg  45  yaw=  +0 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  46  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  47  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $00,$00,$F6,$0A  ; seg  48  yaw=  +0 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FA,$00,$F6,$0A  ; seg  49  yaw=  -6 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  50  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EE,$00,$F6,$0A  ; seg  51  yaw= -18 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  52  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  53  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  54  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D6,$00,$F6,$0A  ; seg  55  yaw= -42 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  56  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D6,$00,$F6,$0A  ; seg  57  yaw= -42 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  58  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  59  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  60  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E2,$00,$F6,$0A  ; seg  61  yaw= -30 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  62  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D6,$00,$F6,$0A  ; seg  63  yaw= -42 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  64  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CA,$00,$F6,$0A  ; seg  65  yaw= -54 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  66  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BE,$00,$F6,$0A  ; seg  67  yaw= -66 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  68  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  69  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  70  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  71  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  72  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BD,$FF,$F6,$0A  ; seg  73  yaw= -67 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $C2,$FE,$F6,$0A  ; seg  74  yaw= -62 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C7,$FE,$F6,$0A  ; seg  75  yaw= -57 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $CC,$FE,$F6,$0A  ; seg  76  yaw= -52 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $CC,$FE,$F6,$0A  ; seg  77  yaw= -52 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $CC,$FE,$F6,$0A  ; seg  78  yaw= -52 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $CC,$FE,$F6,$0A  ; seg  79  yaw= -52 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $CC,$FE,$F6,$0A  ; seg  80  yaw= -52 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $D1,$FE,$F6,$0A  ; seg  81  yaw= -47 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $D6,$FE,$F6,$0A  ; seg  82  yaw= -42 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $DB,$FF,$F6,$0A  ; seg  83  yaw= -37 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  84  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  85  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  86  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$00,$F6,$0A  ; seg  87  yaw= -50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  88  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$00,$F6,$0A  ; seg  89  yaw= -50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  90  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  91  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  92  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  93  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  94  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$00,$F6,$0A  ; seg  95  yaw= -50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  96  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg  97  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  98  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg  99  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 100  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg 101  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 102  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg 103  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 104  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 105  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 106  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 107  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 108  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C2,$00,$F6,$0A  ; seg 109  yaw= -62 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg 110  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$00,$F6,$0A  ; seg 111  yaw= -74 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 112  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B6,$FE,$F6,$0A  ; seg 113  yaw= -74 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $BC,$FC,$F6,$0A  ; seg 114  yaw= -68 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C2,$FA,$F6,$0A  ; seg 115  yaw= -62 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $C8,$F8,$F6,$0A  ; seg 116  yaw= -56 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $C2,$F8,$F6,$0A  ; seg 117  yaw= -62 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $BC,$F8,$F6,$0A  ; seg 118  yaw= -68 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $B6,$F8,$F6,$0A  ; seg 119  yaw= -74 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $B0,$F8,$F6,$0A  ; seg 120  yaw= -80 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $B0,$FA,$F6,$0A  ; seg 121  yaw= -80 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $B0,$FC,$F6,$0A  ; seg 122  yaw= -80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg 123  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg 124  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AC,$00,$F6,$0A  ; seg 125  yaw= -84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 126  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 127  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 128  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$FE,$F6,$0A  ; seg 129  yaw= -96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A0,$FC,$F6,$0A  ; seg 130  yaw= -96 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $A0,$FE,$F6,$0A  ; seg 131  yaw= -96 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 132  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$02,$F6,$0A  ; seg 133  yaw= -96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A0,$04,$F6,$0A  ; seg 134  yaw= -96 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $A0,$02,$F6,$0A  ; seg 135  yaw= -96 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 136  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg 137  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 138  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 139  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 140  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 141  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 142  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg 143  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 144  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 145  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 146  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 147  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 148  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 149  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 150  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 151  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 152 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 153 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 154 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 155 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 156 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 157 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 158 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 159 (wraparound de seg 7)
