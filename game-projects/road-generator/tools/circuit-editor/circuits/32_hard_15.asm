* ======================================================================
* Circuit_32_hard_15 — N=192 segments (format compact 8 oct/seg)
* Source       : 32_hard_15.bin (extrait de FILE30)
*
* Pays         : 
* Lieu         : 
* Description  : 
* Hazards      : 
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#00006C 01:#9090B4 02:#6C6C90 03:#48486C 04:#484848 05:#B40000 06:#242424 07:#242424
*   08:#48486C 09:#D8D8D8 10:#242424 11:#FCFCFC 12:#FC00FC 13:#FC00FC 14:#FC24FC 15:#FC24FC
*   16:#FC48FC 17:#FC48FC 18:#FC6CFC 19:#FC6CFC 20:#FC90FC 21:#FC90FC 22:#FCB4FC 23:#FCB4FC
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
* Taille totale : 2418 oct (nb_segments 2 + LUT 16 + segments 1600 + cache 800).
* ======================================================================

Circuit_32_hard_15_nb_segments
        fdb   192

Circuit_32_hard_15_sprite_lut
        fcb   $00,$82,$83,$87,$90,$80,$89,$8C,$81,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_32_hard_15_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg   8                      flags=[PIT]
        fcb   $80,$00,$00,$03,$00,$00,$E0,$00  ; seg   9                      flags=[PIT]   #2:$87@-32
        fcb   $80,$00,$30,$00,$00,$E8,$00,$00  ; seg  10                      flags=[PIT]   #1:$87@-24
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  11                      flags=[PIT]
        fcb   $80,$00,$00,$04,$00,$00,$D4,$00  ; seg  12                      flags=[PIT]   #2:$90@-44
        fcb   $80,$00,$03,$30,$C8,$00,$00,$E4  ; seg  13                      flags=[PIT]   #0:$87@-56 #3:$87@-28
        fcb   $80,$00,$40,$00,$00,$E8,$00,$00  ; seg  14                      flags=[PIT]   #1:$90@-24
        fcb   $80,$00,$00,$04,$00,$00,$E0,$00  ; seg  15                      flags=[PIT]   #2:$90@-32
        fcb   $80,$00,$03,$00,$D8,$00,$00,$00  ; seg  16                      flags=[PIT]   #0:$87@-40
        fcb   $80,$00,$00,$03,$00,$00,$D4,$00  ; seg  17                      flags=[PIT]   #2:$87@-44
        fcb   $80,$00,$04,$00,$DC,$00,$00,$00  ; seg  18                      flags=[PIT]   #0:$90@-36
        fcb   $80,$00,$00,$30,$00,$00,$00,$E0  ; seg  19                      flags=[PIT]   #3:$87@-32
        fcb   $00,$00,$30,$00,$00,$DC,$00,$00  ; seg  20                                    #1:$87@-36
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  21
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  22                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  23                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg  24  curve=+4                          #0:$80@+18
        fcb   $04,$00,$05,$06,$12,$00,$D4,$00  ; seg  25  curve=+4                          #0:$80@+18 #2:$89@-44
        fcb   $04,$00,$00,$30,$00,$00,$00,$14  ; seg  26  curve=+4                          #3:$87@+20
        fcb   $04,$00,$30,$00,$00,$20,$00,$00  ; seg  27  curve=+4                          #1:$87@+32
        fcb   $00,$00,$00,$60,$00,$00,$00,$E0  ; seg  28                                    #3:$89@-32
        fcb   $00,$00,$00,$30,$00,$00,$00,$EC  ; seg  29                                    #3:$87@-20
        fcb   $00,$00,$03,$00,$D8,$00,$00,$00  ; seg  30                                    #0:$87@-40
        fcb   $00,$00,$00,$04,$00,$00,$E4,$00  ; seg  31                                    #2:$90@-28
        fcb   $00,$00,$00,$03,$00,$00,$E8,$00  ; seg  32                                    #2:$87@-24
        fcb   $00,$00,$60,$00,$00,$E0,$00,$00  ; seg  33                                    #1:$89@-32
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  34                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  35                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$40,$12,$00,$00,$E0  ; seg  36  curve=+4                          #0:$80@+18 #3:$90@-32
        fcb   $04,$00,$05,$03,$12,$00,$DC,$00  ; seg  37  curve=+4                          #0:$80@+18 #2:$87@-36
        fcb   $04,$00,$65,$00,$12,$30,$00,$00  ; seg  38  curve=+4                          #0:$80@+18 #1:$89@+48
        fcb   $04,$00,$05,$30,$12,$00,$00,$EC  ; seg  39  curve=+4                          #0:$80@+18 #3:$87@-20
        fcb   $04,$00,$05,$30,$12,$00,$00,$D4  ; seg  40  curve=+4                          #0:$80@+18 #3:$87@-44
        fcb   $04,$00,$05,$07,$12,$00,$C8,$00  ; seg  41  curve=+4                          #0:$80@+18 #2:$8C@-56
        fcb   $04,$00,$35,$00,$12,$D4,$00,$00  ; seg  42  curve=+4                          #0:$80@+18 #1:$87@-44
        fcb   $04,$00,$05,$03,$12,$00,$E4,$00  ; seg  43  curve=+4                          #0:$80@+18 #2:$87@-28
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg  44  curve=+4                          #0:$80@+18
        fcb   $04,$00,$05,$04,$12,$00,$DC,$00  ; seg  45  curve=+4                          #0:$80@+18 #2:$90@-36
        fcb   $04,$00,$30,$00,$00,$30,$00,$00  ; seg  46  curve=+4                          #1:$87@+48
        fcb   $04,$00,$03,$00,$2C,$00,$00,$00  ; seg  47  curve=+4                          #0:$87@+44
        fcb   $00,$00,$36,$00,$E0,$DC,$00,$00  ; seg  48                                    #0:$89@-32 #1:$87@-36
        fcb   $00,$00,$30,$40,$00,$D4,$00,$24  ; seg  49                                    #1:$87@-44 #3:$90@+36
        fcb   $00,$00,$08,$08,$EE,$00,$EE,$00  ; seg  50                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$08,$08,$EE,$00,$EE,$00  ; seg  51                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$38,$30,$EE,$14,$00,$20  ; seg  52  curve=-4                          #0:$81@-18 #1:$87@+20 #3:$87@+32
        fcb   $7C,$00,$08,$06,$EE,$00,$28,$00  ; seg  53  curve=-4                          #0:$81@-18 #2:$89@+40
        fcb   $7C,$00,$35,$05,$12,$E0,$12,$00  ; seg  54  curve=-4                          #0:$80@+18 #1:$87@-32 #2:$80@+18
        fcb   $7C,$00,$05,$05,$12,$00,$12,$00  ; seg  55  curve=-4                          #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$30,$12,$00,$00,$20  ; seg  56  curve=+4                          #0:$80@+18 #3:$87@+32
        fcb   $04,$00,$45,$00,$12,$D4,$00,$00  ; seg  57  curve=+4                          #0:$80@+18 #1:$90@-44
        fcb   $04,$00,$00,$30,$00,$00,$00,$E4  ; seg  58  curve=+4                          #3:$87@-28
        fcb   $04,$00,$03,$00,$E8,$00,$00,$00  ; seg  59  curve=+4                          #0:$87@-24
        fcb   $00,$00,$60,$00,$00,$EC,$00,$00  ; seg  60                                    #1:$89@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  61
        fcb   $00,$00,$30,$30,$00,$20,$00,$14  ; seg  62                                    #1:$87@+32 #3:$87@+20
        fcb   $00,$00,$04,$00,$28,$00,$00,$00  ; seg  63                                    #0:$90@+40
        fcb   $00,$00,$70,$00,$00,$20,$00,$00  ; seg  64                                    #1:$8C@+32
        fcb   $00,$00,$33,$40,$30,$2C,$00,$E4  ; seg  65                                    #0:$87@+48 #1:$87@+44 #3:$90@-28
        fcb   $00,$00,$00,$03,$00,$00,$EC,$00  ; seg  66                                    #2:$87@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  67
        fcb   $00,$00,$00,$30,$00,$00,$00,$E0  ; seg  68                                    #3:$87@-32
        fcb   $00,$00,$00,$04,$00,$00,$20,$00  ; seg  69                                    #2:$90@+32
        fcb   $00,$00,$03,$00,$14,$00,$00,$00  ; seg  70                                    #0:$87@+20
        fcb   $00,$00,$30,$00,$00,$18,$00,$00  ; seg  71                                    #1:$87@+24
        fcb   $00,$00,$60,$00,$00,$20,$00,$00  ; seg  72                                    #1:$89@+32
        fcb   $00,$00,$03,$43,$30,$00,$1C,$E4  ; seg  73                                    #0:$87@+48 #2:$87@+28 #3:$90@-28
        fcb   $00,$00,$33,$03,$D0,$DC,$E0,$00  ; seg  74                                    #0:$87@-48 #1:$87@-36 #2:$87@-32
        fcb   $00,$00,$36,$00,$C8,$C4,$00,$00  ; seg  75                                    #0:$89@-56 #1:$87@-60
        fcb   $00,$00,$03,$43,$E0,$00,$E4,$14  ; seg  76                                    #0:$87@-32 #2:$87@-28 #3:$90@+20
        fcb   $00,$00,$30,$03,$00,$20,$30,$00  ; seg  77                                    #1:$87@+32 #2:$87@+48
        fcb   $00,$00,$03,$34,$1C,$00,$E4,$E8  ; seg  78                                    #0:$87@+28 #2:$90@-28 #3:$87@-24
        fcb   $00,$00,$30,$03,$00,$2C,$30,$00  ; seg  79                                    #1:$87@+44 #2:$87@+48
        fcb   $00,$00,$06,$00,$30,$00,$00,$00  ; seg  80                                    #0:$89@+48
        fcb   $00,$00,$03,$33,$1C,$00,$20,$E0  ; seg  81                                    #0:$87@+28 #2:$87@+32 #3:$87@-32
        fcb   $00,$00,$40,$30,$00,$E4,$00,$DC  ; seg  82                                    #1:$90@-28 #3:$87@-36
        fcb   $00,$00,$03,$03,$30,$00,$D0,$00  ; seg  83                                    #0:$87@+48 #2:$87@-48
        fcb   $00,$00,$36,$33,$CC,$14,$DC,$D4  ; seg  84                                    #0:$89@-52 #1:$87@+20 #2:$87@-36 #3:$87@-44
        fcb   $00,$00,$07,$00,$C4,$00,$00,$00  ; seg  85                                    #0:$8C@-60
        fcb   $00,$00,$30,$30,$00,$14,$00,$D8  ; seg  86                                    #1:$87@+20 #3:$87@-40
        fcb   $00,$00,$30,$04,$00,$30,$EC,$00  ; seg  87                                    #1:$87@+48 #2:$90@-20
        fcb   $00,$00,$03,$03,$14,$00,$20,$00  ; seg  88                                    #0:$87@+20 #2:$87@+32
        fcb   $00,$00,$40,$00,$00,$1C,$00,$00  ; seg  89                                    #1:$90@+28
        fcb   $00,$00,$08,$38,$EE,$00,$EE,$20  ; seg  90                                    #0:$81@-18 #2:$81@-18 #3:$87@+32
        fcb   $00,$00,$08,$78,$EE,$00,$EE,$24  ; seg  91                                    #0:$81@-18 #2:$81@-18 #3:$8C@+36
        fcb   $7C,$00,$08,$03,$EE,$00,$28,$00  ; seg  92  curve=-4                          #0:$81@-18 #2:$87@+40
        fcb   $7C,$00,$08,$40,$EE,$00,$00,$24  ; seg  93  curve=-4                          #0:$81@-18 #3:$90@+36
        fcb   $7C,$00,$05,$05,$12,$00,$12,$00  ; seg  94  curve=-4                          #0:$80@+18 #2:$80@+18
        fcb   $7C,$00,$05,$05,$12,$00,$12,$00  ; seg  95  curve=-4                          #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$30,$12,$00,$00,$EC  ; seg  96  curve=+4                          #0:$80@+18 #3:$87@-20
        fcb   $04,$00,$05,$06,$12,$00,$DC,$00  ; seg  97  curve=+4                          #0:$80@+18 #2:$89@-36
        fcb   $04,$00,$35,$30,$12,$34,$00,$DC  ; seg  98  curve=+4                          #0:$80@+18 #1:$87@+52 #3:$87@-36
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg  99  curve=+4                          #0:$80@+18
        fcb   $04,$00,$05,$04,$12,$00,$C0,$00  ; seg 100  curve=+4                          #0:$80@+18 #2:$90@-64
        fcb   $04,$00,$65,$00,$12,$E0,$00,$00  ; seg 101  curve=+4                          #0:$80@+18 #1:$89@-32
        fcb   $04,$00,$04,$40,$14,$00,$00,$20  ; seg 102  curve=+4                          #0:$90@+20 #3:$90@+32
        fcb   $04,$00,$03,$06,$1C,$00,$24,$00  ; seg 103  curve=+4                          #0:$87@+28 #2:$89@+36
        fcb   $00,$00,$04,$00,$28,$00,$00,$00  ; seg 104                                    #0:$90@+40
        fcb   $00,$00,$00,$03,$00,$00,$20,$00  ; seg 105                                    #2:$87@+32
        fcb   $00,$00,$40,$40,$00,$1C,$00,$20  ; seg 106                                    #1:$90@+28 #3:$90@+32
        fcb   $00,$00,$07,$00,$E0,$00,$00,$00  ; seg 107                                    #0:$8C@-32
        fcb   $00,$00,$40,$03,$00,$30,$EC,$00  ; seg 108                                    #1:$90@+48 #2:$87@-20
        fcb   $00,$00,$00,$60,$00,$00,$00,$30  ; seg 109                                    #3:$89@+48
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg 110                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg 111                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$60,$12,$00,$00,$E4  ; seg 112  curve=+4                          #0:$80@+18 #3:$89@-28
        fcb   $04,$00,$05,$03,$12,$00,$EC,$00  ; seg 113  curve=+4                          #0:$80@+18 #2:$87@-20
        fcb   $04,$00,$00,$40,$00,$00,$00,$20  ; seg 114  curve=+4                          #3:$90@+32
        fcb   $04,$00,$00,$40,$00,$00,$00,$30  ; seg 115  curve=+4                          #3:$90@+48
        fcb   $00,$00,$30,$00,$00,$20,$00,$00  ; seg 116                                    #1:$87@+32
        fcb   $00,$00,$03,$07,$20,$00,$14,$00  ; seg 117                                    #0:$87@+32 #2:$8C@+20
        fcb   $00,$00,$04,$30,$E0,$00,$00,$DC  ; seg 118                                    #0:$90@-32 #3:$87@-36
        fcb   $00,$00,$30,$00,$00,$20,$00,$00  ; seg 119                                    #1:$87@+32
        fcb   $00,$00,$04,$00,$E0,$00,$00,$00  ; seg 120                                    #0:$90@-32
        fcb   $00,$00,$30,$03,$00,$14,$1C,$00  ; seg 121                                    #1:$87@+20 #2:$87@+28
        fcb   $00,$00,$40,$60,$00,$24,$00,$30  ; seg 122                                    #1:$90@+36 #3:$89@+48
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 123
        fcb   $00,$00,$03,$03,$18,$00,$20,$00  ; seg 124                                    #0:$87@+24 #2:$87@+32
        fcb   $00,$00,$30,$00,$00,$30,$00,$00  ; seg 125                                    #1:$87@+48
        fcb   $00,$00,$40,$30,$00,$34,$00,$28  ; seg 126                                    #1:$90@+52 #3:$87@+40
        fcb   $00,$00,$33,$00,$14,$1C,$00,$00  ; seg 127                                    #0:$87@+20 #1:$87@+28
        fcb   $00,$00,$40,$30,$00,$18,$00,$20  ; seg 128                                    #1:$90@+24 #3:$87@+32
        fcb   $00,$00,$30,$00,$00,$E0,$00,$00  ; seg 129                                    #1:$87@-32
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg 130                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg 131                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$05,$03,$12,$00,$20,$00  ; seg 132  curve=+4                          #0:$80@+18 #2:$87@+32
        fcb   $04,$00,$65,$40,$12,$DC,$00,$D4  ; seg 133  curve=+4                          #0:$80@+18 #1:$89@-36 #3:$90@-44
        fcb   $04,$00,$35,$03,$12,$CC,$E8,$00  ; seg 134  curve=+4                          #0:$80@+18 #1:$87@-52 #2:$87@-24
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg 135  curve=+4                          #0:$80@+18
        fcb   $04,$00,$05,$00,$12,$00,$00,$00  ; seg 136  curve=+4                          #0:$80@+18
        fcb   $04,$00,$45,$60,$12,$E0,$00,$DC  ; seg 137  curve=+4                          #0:$80@+18 #1:$90@-32 #3:$89@-36
        fcb   $04,$00,$03,$03,$40,$00,$D4,$00  ; seg 138  curve=+4                          #0:$87@+64 #2:$87@-44
        fcb   $04,$00,$00,$30,$00,$00,$00,$D8  ; seg 139  curve=+4                          #3:$87@-40
        fcb   $00,$00,$34,$30,$E4,$E4,$00,$E4  ; seg 140                                    #0:$90@-28 #1:$87@-28 #3:$87@-28
        fcb   $00,$00,$40,$03,$00,$E8,$EC,$00  ; seg 141                                    #1:$90@-24 #2:$87@-20
        fcb   $00,$00,$35,$05,$12,$E0,$12,$00  ; seg 142                                    #0:$80@+18 #1:$87@-32 #2:$80@+18
        fcb   $00,$00,$05,$35,$12,$00,$12,$E0  ; seg 143                                    #0:$80@+18 #2:$80@+18 #3:$87@-32
        fcb   $04,$00,$45,$00,$12,$24,$00,$00  ; seg 144  curve=+4                          #0:$80@+18 #1:$90@+36
        fcb   $04,$00,$05,$30,$12,$00,$00,$30  ; seg 145  curve=+4                          #0:$80@+18 #3:$87@+48
        fcb   $04,$00,$08,$08,$EE,$00,$EE,$00  ; seg 146  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $04,$00,$38,$08,$EE,$D0,$EE,$00  ; seg 147  curve=+4                          #0:$81@-18 #1:$87@-48 #2:$81@-18
        fcb   $7C,$00,$48,$30,$EE,$C0,$00,$C8  ; seg 148  curve=-4                          #0:$81@-18 #1:$90@-64 #3:$87@-56
        fcb   $7C,$00,$38,$04,$EE,$E4,$24,$00  ; seg 149  curve=-4                          #0:$81@-18 #1:$87@-28 #2:$90@+36
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 150  curve=-4
        fcb   $7C,$00,$70,$30,$00,$E0,$00,$E4  ; seg 151  curve=-4                          #1:$8C@-32 #3:$87@-28
        fcb   $00,$00,$30,$00,$00,$20,$00,$00  ; seg 152                                    #1:$87@+32
        fcb   $00,$00,$00,$03,$00,$00,$DC,$00  ; seg 153                                    #2:$87@-36
        fcb   $00,$00,$40,$30,$00,$E0,$00,$E4  ; seg 154                                    #1:$90@-32 #3:$87@-28
        fcb   $00,$00,$30,$00,$00,$40,$00,$00  ; seg 155                                    #1:$87@+64
        fcb   $00,$00,$60,$03,$00,$14,$20,$00  ; seg 156                                    #1:$89@+20 #2:$87@+32
        fcb   $00,$00,$06,$03,$14,$00,$E0,$00  ; seg 157                                    #0:$89@+20 #2:$87@-32
        fcb   $00,$00,$06,$40,$20,$00,$00,$DC  ; seg 158                                    #0:$89@+32 #3:$90@-36
        fcb   $00,$00,$33,$03,$28,$24,$EC,$00  ; seg 159                                    #0:$87@+40 #1:$87@+36 #2:$87@-20
        fcb   $00,$00,$00,$40,$00,$00,$00,$EC  ; seg 160                                    #3:$90@-20
        fcb   $00,$00,$33,$03,$20,$E0,$D0,$00  ; seg 161                                    #0:$87@+32 #1:$87@-32 #2:$87@-48
        fcb   $00,$00,$00,$40,$00,$00,$00,$CC  ; seg 162                                    #3:$90@-52
        fcb   $00,$00,$33,$00,$C8,$14,$00,$00  ; seg 163                                    #0:$87@-56 #1:$87@+20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 164
        fcb   $00,$00,$00,$36,$00,$00,$E0,$20  ; seg 165                                    #2:$89@-32 #3:$87@+32
        fcb   $00,$00,$33,$00,$18,$1C,$00,$00  ; seg 166                                    #0:$87@+24 #1:$87@+28
        fcb   $00,$00,$00,$34,$00,$00,$14,$20  ; seg 167                                    #2:$90@+20 #3:$87@+32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 168
        fcb   $00,$00,$03,$04,$E0,$00,$30,$00  ; seg 169                                    #0:$87@-32 #2:$90@+48
        fcb   $00,$00,$30,$70,$00,$20,$00,$1C  ; seg 170                                    #1:$87@+32 #3:$8C@+28
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 171
        fcb   $00,$00,$04,$03,$18,$00,$20,$00  ; seg 172                                    #0:$90@+24 #2:$87@+32
        fcb   $00,$00,$40,$00,$00,$14,$00,$00  ; seg 173                                    #1:$90@+20
        fcb   $00,$00,$00,$60,$00,$00,$00,$EC  ; seg 174                                    #3:$89@-20
        fcb   $00,$00,$00,$03,$00,$00,$18,$00  ; seg 175                                    #2:$87@+24
        fcb   $00,$00,$40,$00,$00,$20,$00,$00  ; seg 176                                    #1:$90@+32
        fcb   $00,$00,$04,$30,$30,$00,$00,$EC  ; seg 177                                    #0:$90@+48 #3:$87@-20
        fcb   $00,$00,$00,$03,$00,$00,$14,$00  ; seg 178                                    #2:$87@+20
        fcb   $00,$00,$30,$00,$00,$E8,$00,$00  ; seg 179                                    #1:$87@-24
        fcb   $00,$00,$00,$04,$00,$00,$20,$00  ; seg 180                                    #2:$90@+32
        fcb   $00,$00,$03,$30,$CC,$00,$00,$E0  ; seg 181                                    #0:$87@-52 #3:$87@-32
        fcb   $00,$00,$00,$70,$00,$00,$00,$EC  ; seg 182                                    #3:$8C@-20
        fcb   $00,$00,$03,$00,$DC,$00,$00,$00  ; seg 183                                    #0:$87@-36
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 184
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 185
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 186
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 187
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 188
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 189
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 190
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 191
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 192                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 193
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 194
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 195
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 196                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 197                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 198                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 199                                    #0:$83@+18 #2:$83@+18

Circuit_32_hard_15_segment_cache
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
        fcb   $04,$00,$F6,$0A  ; seg  25  yaw=  +4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  26  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $0C,$00,$F6,$0A  ; seg  27  yaw= +12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  28  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  29  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  30  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  31  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  32  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  33  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  34  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  35  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $10,$00,$F6,$0A  ; seg  36  yaw= +16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $14,$00,$F6,$0A  ; seg  37  yaw= +20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $18,$00,$F6,$0A  ; seg  38  yaw= +24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $1C,$00,$F6,$0A  ; seg  39  yaw= +28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $20,$00,$F6,$0A  ; seg  40  yaw= +32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $24,$00,$F6,$0A  ; seg  41  yaw= +36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $28,$00,$F6,$0A  ; seg  42  yaw= +40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$00,$F6,$0A  ; seg  43  yaw= +44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  44  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  45  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  46  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  47  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  48  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  49  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  50  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  51  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  52  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  53  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  54  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  55  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  56  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  57  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  58  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  59  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  60  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  61  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  62  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  63  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  64  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  65  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  66  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  67  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  68  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  69  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  70  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  71  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  72  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  73  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  74  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  75  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  76  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  77  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  78  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  79  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  80  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  81  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  82  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  83  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  84  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  85  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  86  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  87  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  88  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  89  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  90  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  91  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg  92  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  93  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  94  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  95  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  96  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $34,$00,$F6,$0A  ; seg  97  yaw= +52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $38,$00,$F6,$0A  ; seg  98  yaw= +56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $3C,$00,$F6,$0A  ; seg  99  yaw= +60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $40,$00,$F6,$0A  ; seg 100  yaw= +64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $44,$00,$F6,$0A  ; seg 101  yaw= +68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $48,$00,$F6,$0A  ; seg 102  yaw= +72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $4C,$00,$F6,$0A  ; seg 103  yaw= +76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 104  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 105  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 106  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 107  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 108  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 109  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 110  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 111  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $50,$00,$F6,$0A  ; seg 112  yaw= +80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $54,$00,$F6,$0A  ; seg 113  yaw= +84 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $58,$00,$F6,$0A  ; seg 114  yaw= +88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $5C,$00,$F6,$0A  ; seg 115  yaw= +92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 116  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 117  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 118  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 119  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 120  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 121  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 122  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 123  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 124  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 125  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 126  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 127  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 128  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 129  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 130  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 131  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $60,$00,$F6,$0A  ; seg 132  yaw= +96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $64,$00,$F6,$0A  ; seg 133  yaw=+100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $68,$00,$F6,$0A  ; seg 134  yaw=+104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $6C,$00,$F6,$0A  ; seg 135  yaw=+108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $70,$00,$F6,$0A  ; seg 136  yaw=+112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $74,$00,$F6,$0A  ; seg 137  yaw=+116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $78,$00,$F6,$0A  ; seg 138  yaw=+120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $7C,$00,$F6,$0A  ; seg 139  yaw=+124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 140  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 141  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 142  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 143  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 144  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg 145  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 146  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 147  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 148  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 149  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 150  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg 151  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 152  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 153  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 154  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 155  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 156  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 157  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 158  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 159  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 160  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 161  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 162  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 163  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 164  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 165  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 166  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 167  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 168  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 169  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 170  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 171  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 172  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 173  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 174  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 175  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 176  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 177  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 178  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 179  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 180  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 181  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 182  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 183  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
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
