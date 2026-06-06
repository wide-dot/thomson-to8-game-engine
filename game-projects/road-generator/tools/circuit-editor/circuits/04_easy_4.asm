* ======================================================================
* Circuit_04_easy_4 — N=178 segments (format compact 8 oct/seg)
* Source       : 04_easy_4.bin (extrait de FILE30)
*
* Pays         : ENGLAND
* Lieu         : hethel, nr norwich
* Description  : flat with few sharp bends
* Hazards      : oil on road, lane closures
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
* Taille totale : 2250 oct (nb_segments 2 + LUT 16 + segments 1488 + cache 744).
* ======================================================================

Circuit_04_easy_4_nb_segments
        fdb   178

Circuit_04_easy_4_sprite_lut
        fcb   $00,$82,$83,$87,$90,$A7,$81,$9A,$A2,$80,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_04_easy_4_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg   8                      flags=[PIT]   #0:$87@-18
        fcb   $80,$00,$03,$03,$EE,$00,$EE,$00  ; seg   9                      flags=[PIT]   #0:$87@-18 #2:$87@-18
        fcb   $80,$00,$03,$03,$EE,$00,$EE,$00  ; seg  10                      flags=[PIT]   #0:$87@-18 #2:$87@-18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg  11                      flags=[PIT]   #0:$87@-18
        fcb   $80,$00,$03,$03,$EE,$00,$EE,$00  ; seg  12                      flags=[PIT]   #0:$87@-18 #2:$87@-18
        fcb   $80,$00,$03,$03,$EE,$00,$EE,$00  ; seg  13                      flags=[PIT]   #0:$87@-18 #2:$87@-18
        fcb   $80,$00,$03,$00,$EE,$00,$00,$00  ; seg  14                      flags=[PIT]   #0:$87@-18
        fcb   $80,$00,$03,$03,$EE,$00,$EE,$00  ; seg  15                      flags=[PIT]   #0:$87@-18 #2:$87@-18
        fcb   $00,$00,$04,$03,$EC,$00,$24,$00  ; seg  16                                    #0:$90@-20 #2:$87@+36
        fcb   $00,$00,$05,$00,$14,$00,$00,$00  ; seg  17                                    #0:$A7@+20
        fcb   $00,$00,$04,$45,$E0,$00,$EC,$14  ; seg  18                                    #0:$90@-32 #2:$A7@-20 #3:$90@+20
        fcb   $00,$00,$43,$00,$20,$EC,$00,$00  ; seg  19                                    #0:$87@+32 #1:$90@-20
        fcb   $00,$00,$04,$05,$E4,$00,$14,$00  ; seg  20                                    #0:$90@-28 #2:$A7@+20
        fcb   $00,$00,$05,$00,$18,$00,$00,$00  ; seg  21                                    #0:$A7@+24
        fcb   $00,$00,$03,$54,$E0,$00,$24,$14  ; seg  22                                    #0:$87@-32 #2:$90@+36 #3:$A7@+20
        fcb   $00,$00,$05,$00,$24,$00,$00,$00  ; seg  23                                    #0:$A7@+36
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg  24                                    #0:$87@-20
        fcb   $00,$00,$04,$03,$14,$00,$14,$00  ; seg  25                                    #0:$90@+20 #2:$87@+20
        fcb   $00,$00,$05,$04,$20,$00,$DC,$00  ; seg  26                                    #0:$A7@+32 #2:$90@-36
        fcb   $00,$00,$05,$00,$E0,$00,$00,$00  ; seg  27                                    #0:$A7@-32
        fcb   $00,$00,$04,$30,$18,$00,$00,$14  ; seg  28                                    #0:$90@+24 #3:$87@+20
        fcb   $00,$00,$05,$00,$E8,$00,$00,$00  ; seg  29                                    #0:$A7@-24
        fcb   $00,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg  30                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$66,$66,$EE,$EE,$EE,$EE  ; seg  31                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$36,$06,$EE,$EC,$EE,$00  ; seg  32  curve=-6                          #0:$81@-18 #1:$87@-20 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg  33  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$50,$EE,$00,$00,$24  ; seg  34  curve=-6                          #0:$81@-18 #3:$A7@+36
        fcb   $7A,$00,$06,$33,$EE,$00,$EC,$DC  ; seg  35  curve=-6                          #0:$81@-18 #2:$87@-20 #3:$87@-36
        fcb   $7C,$00,$56,$00,$EE,$EC,$00,$00  ; seg  36  curve=-4                          #0:$81@-18 #1:$A7@-20
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  37  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$06,$EE,$00,$EE,$00  ; seg  38  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$06,$EE,$00,$EE,$00  ; seg  39  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg  40  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$56,$EE,$00,$EE,$EC  ; seg  41  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A7@-20
        fcb   $7A,$00,$03,$40,$14,$00,$00,$14  ; seg  42  curve=-6                          #0:$87@+20 #3:$90@+20
        fcb   $7A,$00,$05,$00,$28,$00,$00,$00  ; seg  43  curve=-6                          #0:$A7@+40
        fcb   $00,$00,$03,$00,$20,$00,$00,$00  ; seg  44                                    #0:$87@+32
        fcb   $00,$00,$04,$30,$1C,$00,$00,$24  ; seg  45                                    #0:$90@+28 #3:$87@+36
        fcb   $00,$00,$04,$50,$18,$00,$00,$14  ; seg  46                                    #0:$90@+24 #3:$A7@+20
        fcb   $00,$00,$04,$00,$30,$00,$00,$00  ; seg  47                                    #0:$90@+48
        fcb   $00,$00,$00,$04,$00,$00,$DC,$00  ; seg  48                                    #2:$90@-36
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  49
        fcb   $00,$00,$07,$47,$EE,$00,$EE,$24  ; seg  50                                    #0:$9A@-18 #2:$9A@-18 #3:$90@+36
        fcb   $00,$00,$07,$07,$EE,$00,$EE,$00  ; seg  51                                    #0:$9A@-18 #2:$9A@-18
        fcb   $00,$00,$07,$57,$EE,$00,$EE,$EC  ; seg  52                                    #0:$9A@-18 #2:$9A@-18 #3:$A7@-20
        fcb   $00,$00,$07,$37,$EE,$00,$EE,$24  ; seg  53                                    #0:$9A@-18 #2:$9A@-18 #3:$87@+36
        fcb   $00,$00,$88,$88,$FA,$F4,$F8,$FE  ; seg  54                                    #0:$A2@-6 #1:$A2@-12 #2:$A2@-8 #3:$A2@-2
        fcb   $00,$00,$88,$88,$F6,$FC,$F4,$F8  ; seg  55                                    #0:$A2@-10 #1:$A2@-4 #2:$A2@-12 #3:$A2@-8
        fcb   $00,$00,$88,$88,$F4,$FA,$F6,$FE  ; seg  56                                    #0:$A2@-12 #1:$A2@-6 #2:$A2@-10 #3:$A2@-2
        fcb   $00,$00,$43,$03,$18,$DC,$EC,$00  ; seg  57                                    #0:$87@+24 #1:$90@-36 #2:$87@-20
        fcb   $00,$00,$59,$09,$12,$14,$12,$00  ; seg  58                                    #0:$80@+18 #1:$A7@+20 #2:$80@+18
        fcb   $00,$00,$09,$09,$12,$00,$12,$00  ; seg  59                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$09,$00,$12,$00,$00,$00  ; seg  60  curve=+4                          #0:$80@+18
        fcb   $04,$00,$09,$43,$12,$00,$24,$14  ; seg  61  curve=+4                          #0:$80@+18 #2:$87@+36 #3:$90@+20
        fcb   $04,$00,$05,$00,$E0,$00,$00,$00  ; seg  62  curve=+4                          #0:$A7@-32
        fcb   $04,$00,$43,$00,$D8,$EC,$00,$00  ; seg  63  curve=+4                          #0:$87@-40 #1:$90@-20
        fcb   $00,$00,$40,$00,$00,$24,$00,$00  ; seg  64                                    #1:$90@+36
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  65
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  66                                    #0:$9A@+18 #2:$9A@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  67                                    #0:$9A@+18 #2:$9A@+18
        fcb   $00,$00,$07,$57,$12,$00,$12,$EC  ; seg  68                                    #0:$9A@+18 #2:$9A@+18 #3:$A7@-20
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  69                                    #0:$9A@+18 #2:$9A@+18
        fcb   $00,$00,$88,$88,$08,$02,$06,$0C  ; seg  70                                    #0:$A2@+8 #1:$A2@+2 #2:$A2@+6 #3:$A2@+12
        fcb   $00,$00,$88,$88,$06,$0C,$0A,$04  ; seg  71                                    #0:$A2@+6 #1:$A2@+12 #2:$A2@+10 #3:$A2@+4
        fcb   $00,$00,$88,$88,$0C,$02,$06,$0A  ; seg  72                                    #0:$A2@+12 #1:$A2@+2 #2:$A2@+6 #3:$A2@+10
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  73                                    #0:$A7@-20
        fcb   $00,$00,$03,$05,$E4,$00,$DC,$00  ; seg  74                                    #0:$87@-28 #2:$A7@-36
        fcb   $00,$00,$54,$00,$C0,$24,$00,$00  ; seg  75                                    #0:$90@-64 #1:$A7@+36
        fcb   $00,$00,$03,$00,$D0,$00,$00,$00  ; seg  76                                    #0:$87@-48
        fcb   $00,$00,$03,$00,$CC,$00,$00,$00  ; seg  77                                    #0:$87@-52
        fcb   $00,$00,$09,$59,$12,$00,$12,$14  ; seg  78                                    #0:$80@+18 #2:$80@+18 #3:$A7@+20
        fcb   $00,$00,$09,$09,$12,$00,$12,$00  ; seg  79                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$09,$00,$12,$00,$00,$00  ; seg  80  curve=+4                          #0:$80@+18
        fcb   $04,$00,$09,$03,$12,$00,$24,$00  ; seg  81  curve=+4                          #0:$80@+18 #2:$87@+36
        fcb   $04,$00,$06,$06,$EE,$00,$EE,$00  ; seg  82  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $04,$00,$06,$06,$EE,$00,$EE,$00  ; seg  83  curve=+4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$36,$00,$EE,$14,$00,$00  ; seg  84  curve=-4                          #0:$81@-18 #1:$87@+20
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg  85  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$00,$14,$00,$00,$00  ; seg  86  curve=-4                          #0:$A7@+20
        fcb   $7C,$00,$04,$05,$E0,$00,$EC,$00  ; seg  87  curve=-4                          #0:$90@-32 #2:$A7@-20
        fcb   $00,$00,$03,$05,$DC,$00,$24,$00  ; seg  88                                    #0:$87@-36 #2:$A7@+36
        fcb   $00,$00,$04,$00,$2C,$00,$00,$00  ; seg  89                                    #0:$90@+44
        fcb   $00,$00,$00,$03,$00,$00,$EC,$00  ; seg  90                                    #2:$87@-20
        fcb   $00,$00,$05,$05,$D0,$00,$14,$00  ; seg  91                                    #0:$A7@-48 #2:$A7@+20
        fcb   $00,$00,$03,$40,$E0,$00,$00,$24  ; seg  92                                    #0:$87@-32 #3:$90@+36
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  93
        fcb   $00,$00,$05,$40,$EC,$00,$00,$14  ; seg  94                                    #0:$A7@-20 #3:$90@+20
        fcb   $00,$00,$03,$04,$D0,$00,$DC,$00  ; seg  95                                    #0:$87@-48 #2:$90@-36
        fcb   $00,$00,$07,$07,$EE,$00,$EE,$00  ; seg  96                                    #0:$9A@-18 #2:$9A@-18
        fcb   $00,$00,$07,$07,$EE,$00,$EE,$00  ; seg  97                                    #0:$9A@-18 #2:$9A@-18
        fcb   $00,$00,$37,$07,$EE,$14,$EE,$00  ; seg  98                                    #0:$9A@-18 #1:$87@+20 #2:$9A@-18
        fcb   $00,$00,$07,$07,$EE,$00,$EE,$00  ; seg  99                                    #0:$9A@-18 #2:$9A@-18
        fcb   $00,$00,$88,$88,$FE,$F4,$F0,$F6  ; seg 100                                    #0:$A2@-2 #1:$A2@-12 #2:$A2@-16 #3:$A2@-10
        fcb   $00,$00,$88,$88,$F4,$F8,$F2,$FC  ; seg 101                                    #0:$A2@-12 #1:$A2@-8 #2:$A2@-14 #3:$A2@-4
        fcb   $00,$00,$88,$88,$FA,$FC,$F8,$FE  ; seg 102                                    #0:$A2@-6 #1:$A2@-4 #2:$A2@-8 #3:$A2@-2
        fcb   $00,$00,$03,$00,$30,$00,$00,$00  ; seg 103                                    #0:$87@+48
        fcb   $00,$00,$50,$00,$00,$24,$00,$00  ; seg 104                                    #1:$A7@+36
        fcb   $00,$00,$03,$05,$24,$00,$EC,$00  ; seg 105                                    #0:$87@+36 #2:$A7@-20
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 106                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 107                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$46,$00,$EE,$EC,$00,$00  ; seg 108  curve=-4                          #0:$81@-18 #1:$90@-20
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 109  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$06,$56,$EE,$00,$EE,$DC  ; seg 110  curve=-4                          #0:$81@-18 #2:$81@-18 #3:$A7@-36
        fcb   $7C,$00,$56,$06,$EE,$14,$EE,$00  ; seg 111  curve=-4                          #0:$81@-18 #1:$A7@+20 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg 112  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$06,$06,$EE,$00,$EE,$00  ; seg 113  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$46,$00,$EE,$EC,$00,$00  ; seg 114  curve=-6                          #0:$81@-18 #1:$90@-20
        fcb   $7A,$00,$06,$05,$EE,$00,$24,$00  ; seg 115  curve=-6                          #0:$81@-18 #2:$A7@+36
        fcb   $7C,$00,$06,$30,$EE,$00,$00,$DC  ; seg 116  curve=-4                          #0:$81@-18 #3:$87@-36
        fcb   $7C,$00,$46,$00,$EE,$14,$00,$00  ; seg 117  curve=-4                          #0:$81@-18 #1:$90@+20
        fcb   $7C,$00,$05,$00,$CC,$00,$00,$00  ; seg 118  curve=-4                          #0:$A7@-52
        fcb   $7C,$00,$54,$00,$E0,$24,$00,$00  ; seg 119  curve=-4                          #0:$90@-32 #1:$A7@+36
        fcb   $00,$00,$03,$05,$14,$00,$14,$00  ; seg 120                                    #0:$87@+20 #2:$A7@+20
        fcb   $00,$00,$03,$50,$20,$00,$00,$24  ; seg 121                                    #0:$87@+32 #3:$A7@+36
        fcb   $00,$00,$03,$50,$24,$00,$00,$14  ; seg 122                                    #0:$87@+36 #3:$A7@+20
        fcb   $00,$00,$55,$00,$30,$24,$00,$00  ; seg 123                                    #0:$A7@+48 #1:$A7@+36
        fcb   $00,$00,$04,$05,$2C,$00,$14,$00  ; seg 124                                    #0:$90@+44 #2:$A7@+20
        fcb   $00,$00,$05,$30,$D0,$00,$00,$DC  ; seg 125                                    #0:$A7@-48 #3:$87@-36
        fcb   $00,$00,$03,$00,$EC,$00,$00,$00  ; seg 126                                    #0:$87@-20
        fcb   $00,$00,$04,$05,$E0,$00,$DC,$00  ; seg 127                                    #0:$90@-32 #2:$A7@-36
        fcb   $00,$00,$07,$37,$12,$00,$0E,$24  ; seg 128                                    #0:$9A@+18 #2:$9A@+14 #3:$87@+36
        fcb   $00,$00,$57,$07,$0A,$14,$06,$00  ; seg 129                                    #0:$9A@+10 #1:$A7@+20 #2:$9A@+6
        fcb   $00,$00,$07,$07,$02,$00,$02,$00  ; seg 130                                    #0:$9A@+2 #2:$9A@+2
        fcb   $00,$00,$07,$07,$02,$00,$02,$00  ; seg 131                                    #0:$9A@+2 #2:$9A@+2
        fcb   $00,$00,$04,$00,$3C,$00,$00,$00  ; seg 132                                    #0:$90@+60
        fcb   $00,$00,$04,$05,$28,$00,$DC,$00  ; seg 133                                    #0:$90@+40 #2:$A7@-36
        fcb   $00,$00,$53,$30,$E4,$24,$00,$DC  ; seg 134                                    #0:$87@-28 #1:$A7@+36 #3:$87@-36
        fcb   $00,$00,$04,$00,$3C,$00,$00,$00  ; seg 135                                    #0:$90@+60
        fcb   $00,$00,$07,$07,$EE,$00,$F2,$00  ; seg 136                                    #0:$9A@-18 #2:$9A@-14
        fcb   $00,$00,$07,$07,$F6,$00,$FA,$00  ; seg 137                                    #0:$9A@-10 #2:$9A@-6
        fcb   $00,$00,$57,$07,$FE,$EC,$FE,$00  ; seg 138                                    #0:$9A@-2 #1:$A7@-20 #2:$9A@-2
        fcb   $00,$00,$07,$07,$FE,$00,$FE,$00  ; seg 139                                    #0:$9A@-2 #2:$9A@-2
        fcb   $00,$00,$07,$07,$FE,$00,$FE,$00  ; seg 140                                    #0:$9A@-2 #2:$9A@-2
        fcb   $00,$00,$07,$37,$FE,$00,$FE,$EC  ; seg 141                                    #0:$9A@-2 #2:$9A@-2 #3:$87@-20
        fcb   $00,$00,$50,$00,$00,$DC,$00,$00  ; seg 142                                    #1:$A7@-36
        fcb   $00,$00,$30,$00,$00,$14,$00,$00  ; seg 143                                    #1:$87@+20
        fcb   $00,$00,$07,$07,$12,$00,$0E,$00  ; seg 144                                    #0:$9A@+18 #2:$9A@+14
        fcb   $00,$00,$07,$07,$0A,$00,$06,$00  ; seg 145                                    #0:$9A@+10 #2:$9A@+6
        fcb   $00,$00,$07,$07,$02,$00,$02,$00  ; seg 146                                    #0:$9A@+2 #2:$9A@+2
        fcb   $00,$00,$07,$07,$02,$00,$02,$00  ; seg 147                                    #0:$9A@+2 #2:$9A@+2
        fcb   $00,$00,$07,$47,$02,$00,$02,$14  ; seg 148                                    #0:$9A@+2 #2:$9A@+2 #3:$90@+20
        fcb   $00,$00,$47,$07,$02,$EC,$02,$00  ; seg 149                                    #0:$9A@+2 #1:$90@-20 #2:$9A@+2
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 150                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$06,$06,$EE,$00,$EE,$00  ; seg 151                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 152  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$36,$00,$EE,$24,$00,$00  ; seg 153  curve=-4                          #0:$81@-18 #1:$87@+36
        fcb   $7C,$00,$06,$50,$EE,$00,$00,$EC  ; seg 154  curve=-4                          #0:$81@-18 #3:$A7@-20
        fcb   $7C,$00,$06,$00,$EE,$00,$00,$00  ; seg 155  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$05,$1C,$00,$14,$00  ; seg 156  curve=-4                          #0:$90@+28 #2:$A7@+20
        fcb   $7C,$00,$45,$00,$20,$24,$00,$00  ; seg 157  curve=-4                          #0:$A7@+32 #1:$90@+36
        fcb   $00,$00,$03,$40,$E0,$00,$00,$EC  ; seg 158                                    #0:$87@-32 #3:$90@-20
        fcb   $00,$00,$40,$00,$00,$24,$00,$00  ; seg 159                                    #1:$90@+36
        fcb   $00,$00,$03,$00,$DC,$00,$00,$00  ; seg 160                                    #0:$87@-36
        fcb   $00,$00,$00,$50,$00,$00,$00,$EC  ; seg 161                                    #3:$A7@-20
        fcb   $00,$00,$04,$03,$30,$00,$24,$00  ; seg 162                                    #0:$90@+48 #2:$87@+36
        fcb   $00,$00,$45,$40,$E0,$14,$00,$EC  ; seg 163                                    #0:$A7@-32 #1:$90@+20 #3:$90@-20
        fcb   $00,$00,$05,$03,$E8,$00,$14,$00  ; seg 164                                    #0:$A7@-24 #2:$87@+20
        fcb   $00,$00,$03,$00,$E0,$00,$00,$00  ; seg 165                                    #0:$87@-32
        fcb   $00,$00,$04,$04,$2C,$00,$DC,$00  ; seg 166                                    #0:$90@+44 #2:$90@-36
        fcb   $00,$00,$04,$40,$30,$00,$00,$24  ; seg 167                                    #0:$90@+48 #3:$90@+36
        fcb   $00,$00,$04,$03,$30,$00,$24,$00  ; seg 168                                    #0:$90@+48 #2:$87@+36
        fcb   $00,$00,$03,$00,$E0,$00,$00,$00  ; seg 169                                    #0:$87@-32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 170
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 171
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 172
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 173
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 174
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 175
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 176
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 177
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 178                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 179
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 180
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 181
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 182                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 183                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 184                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 185                                    #0:$83@+18 #2:$83@+18

Circuit_04_easy_4_segment_cache
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
        fcb   $FA,$00,$F6,$0A  ; seg  33  yaw=  -6 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  34  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EE,$00,$F6,$0A  ; seg  35  yaw= -18 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  36  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  37  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  38  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F7,$0A  ; seg  39  yaw= -36 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $D8,$00,$F8,$0A  ; seg  40  yaw= -40 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $D2,$00,$F9,$0A  ; seg  41  yaw= -46 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $CC,$00,$FA,$0A  ; seg  42  yaw= -52 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $C6,$00,$FB,$0A  ; seg  43  yaw= -58 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $C0,$00,$FC,$0A  ; seg  44  yaw= -64 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $C0,$00,$FD,$0A  ; seg  45  yaw= -64 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $C0,$00,$FE,$0A  ; seg  46  yaw= -64 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $C0,$00,$FF,$0A  ; seg  47  yaw= -64 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $C0,$00,$00,$0A  ; seg  48  yaw= -64 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $C0,$00,$01,$0A  ; seg  49  yaw= -64 pitch=  +0 min_lat=  +1 max_lat= +10
        fcb   $C0,$00,$02,$0A  ; seg  50  yaw= -64 pitch=  +0 min_lat=  +2 max_lat= +10
        fcb   $C0,$00,$03,$0A  ; seg  51  yaw= -64 pitch=  +0 min_lat=  +3 max_lat= +10
        fcb   $C0,$00,$04,$0A  ; seg  52  yaw= -64 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $C0,$00,$05,$0A  ; seg  53  yaw= -64 pitch=  +0 min_lat=  +5 max_lat= +10
        fcb   $C0,$00,$06,$0A  ; seg  54  yaw= -64 pitch=  +0 min_lat=  +6 max_lat= +10
        fcb   $C0,$00,$05,$09  ; seg  55  yaw= -64 pitch=  +0 min_lat=  +5 max_lat=  +9
        fcb   $C0,$00,$06,$08  ; seg  56  yaw= -64 pitch=  +0 min_lat=  +6 max_lat=  +8
        fcb   $C0,$00,$F6,$07  ; seg  57  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $C0,$00,$F6,$06  ; seg  58  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $C0,$00,$F6,$05  ; seg  59  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $C0,$00,$F6,$04  ; seg  60  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $C4,$00,$F6,$03  ; seg  61  yaw= -60 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $C8,$00,$F6,$02  ; seg  62  yaw= -56 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $CC,$00,$F6,$01  ; seg  63  yaw= -52 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $D0,$00,$F6,$00  ; seg  64  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $D0,$00,$F6,$FF  ; seg  65  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $D0,$00,$F6,$FE  ; seg  66  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $D0,$00,$F6,$FD  ; seg  67  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $D0,$00,$F6,$FC  ; seg  68  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $D0,$00,$F6,$FB  ; seg  69  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -5
        fcb   $D0,$00,$F6,$FA  ; seg  70  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $D0,$00,$F6,$FB  ; seg  71  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -5
        fcb   $D0,$00,$F6,$FA  ; seg  72  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $D0,$00,$F6,$0A  ; seg  73  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  74  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  75  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  76  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  77  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  78  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  79  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  80  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  81  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  82  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  83  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  84  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F7,$0A  ; seg  85  yaw= -36 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $D8,$00,$F8,$0A  ; seg  86  yaw= -40 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $D4,$00,$F9,$0A  ; seg  87  yaw= -44 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $D0,$00,$FA,$0A  ; seg  88  yaw= -48 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $D0,$00,$FB,$0A  ; seg  89  yaw= -48 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $D0,$00,$FC,$0A  ; seg  90  yaw= -48 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $D0,$00,$FD,$0A  ; seg  91  yaw= -48 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $D0,$00,$FE,$0A  ; seg  92  yaw= -48 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $D0,$00,$FF,$0A  ; seg  93  yaw= -48 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $D0,$00,$00,$0A  ; seg  94  yaw= -48 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $D0,$00,$01,$0A  ; seg  95  yaw= -48 pitch=  +0 min_lat=  +1 max_lat= +10
        fcb   $D0,$00,$02,$0A  ; seg  96  yaw= -48 pitch=  +0 min_lat=  +2 max_lat= +10
        fcb   $D0,$00,$03,$0A  ; seg  97  yaw= -48 pitch=  +0 min_lat=  +3 max_lat= +10
        fcb   $D0,$00,$04,$0A  ; seg  98  yaw= -48 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $D0,$00,$05,$0A  ; seg  99  yaw= -48 pitch=  +0 min_lat=  +5 max_lat= +10
        fcb   $D0,$00,$06,$0A  ; seg 100  yaw= -48 pitch=  +0 min_lat=  +6 max_lat= +10
        fcb   $D0,$00,$05,$0A  ; seg 101  yaw= -48 pitch=  +0 min_lat=  +5 max_lat= +10
        fcb   $D0,$00,$06,$0A  ; seg 102  yaw= -48 pitch=  +0 min_lat=  +6 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 103  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 104  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 105  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 106  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 107  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg 108  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg 109  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg 110  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg 111  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 112  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg 113  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 114  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$09  ; seg 115  yaw= -82 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $A8,$00,$F6,$08  ; seg 116  yaw= -88 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $A4,$00,$F6,$07  ; seg 117  yaw= -92 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $A0,$00,$F6,$06  ; seg 118  yaw= -96 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $9C,$00,$F6,$05  ; seg 119  yaw=-100 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $98,$00,$F6,$04  ; seg 120  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $98,$00,$F6,$03  ; seg 121  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $98,$00,$F6,$02  ; seg 122  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $98,$00,$F7,$01  ; seg 123  yaw=-104 pitch=  +0 min_lat=  -9 max_lat=  +1
        fcb   $98,$00,$F8,$00  ; seg 124  yaw=-104 pitch=  +0 min_lat=  -8 max_lat=  +0
        fcb   $98,$00,$F9,$FF  ; seg 125  yaw=-104 pitch=  +0 min_lat=  -7 max_lat=  -1
        fcb   $98,$00,$FA,$FE  ; seg 126  yaw=-104 pitch=  +0 min_lat=  -6 max_lat=  -2
        fcb   $98,$00,$FB,$FD  ; seg 127  yaw=-104 pitch=  +0 min_lat=  -5 max_lat=  -3
        fcb   $98,$00,$FC,$FC  ; seg 128  yaw=-104 pitch=  +0 min_lat=  -4 max_lat=  -4
        fcb   $98,$00,$FD,$FB  ; seg 129  yaw=-104 pitch=  +0 min_lat=  -3 max_lat=  -5
        fcb   $98,$00,$FE,$FA  ; seg 130  yaw=-104 pitch=  +0 min_lat=  -2 max_lat=  -6
        fcb   $98,$00,$FF,$FA  ; seg 131  yaw=-104 pitch=  +0 min_lat=  -1 max_lat=  -6
        fcb   $98,$00,$00,$08  ; seg 132  yaw=-104 pitch=  +0 min_lat=  +0 max_lat=  +8
        fcb   $98,$00,$01,$07  ; seg 133  yaw=-104 pitch=  +0 min_lat=  +1 max_lat=  +7
        fcb   $98,$00,$02,$06  ; seg 134  yaw=-104 pitch=  +0 min_lat=  +2 max_lat=  +6
        fcb   $98,$00,$03,$05  ; seg 135  yaw=-104 pitch=  +0 min_lat=  +3 max_lat=  +5
        fcb   $98,$00,$04,$04  ; seg 136  yaw=-104 pitch=  +0 min_lat=  +4 max_lat=  +4
        fcb   $98,$00,$05,$03  ; seg 137  yaw=-104 pitch=  +0 min_lat=  +5 max_lat=  +3
        fcb   $98,$00,$06,$02  ; seg 138  yaw=-104 pitch=  +0 min_lat=  +6 max_lat=  +2
        fcb   $98,$00,$06,$01  ; seg 139  yaw=-104 pitch=  +0 min_lat=  +6 max_lat=  +1
        fcb   $98,$00,$06,$00  ; seg 140  yaw=-104 pitch=  +0 min_lat=  +6 max_lat=  +0
        fcb   $98,$00,$06,$FF  ; seg 141  yaw=-104 pitch=  +0 min_lat=  +6 max_lat=  -1
        fcb   $98,$00,$F6,$FE  ; seg 142  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $98,$00,$F6,$FD  ; seg 143  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $98,$00,$F6,$FC  ; seg 144  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $98,$00,$F6,$FB  ; seg 145  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  -5
        fcb   $98,$00,$F6,$FA  ; seg 146  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $98,$00,$F6,$FA  ; seg 147  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $98,$00,$F6,$FA  ; seg 148  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $98,$00,$F6,$FA  ; seg 149  yaw=-104 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $98,$00,$F6,$0A  ; seg 150  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 151  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 152  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $94,$00,$F6,$0A  ; seg 153  yaw=-108 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg 154  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 155  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $88,$00,$F6,$0A  ; seg 156  yaw=-120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $84,$00,$F6,$0A  ; seg 157  yaw=-124 pitch=  +0 min_lat= -10 max_lat= +10
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
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 178 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 179 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 180 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 181 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 182 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 183 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 184 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 185 (wraparound de seg 7)
