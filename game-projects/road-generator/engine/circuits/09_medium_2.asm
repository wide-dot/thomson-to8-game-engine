* ======================================================================
* Circuit_09_medium_2 — N=146 segments (format compact 8 oct/seg)
* Source       : 09_medium_2.bin (extrait de FILE30)
*
* Pays         : GREENLAND
* Lieu         : sondrestromfjord
* Description  : flat course, but oil slicks
* Hazards      : covering part of a long bend
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
* par circuit ; ce circuit : 11 entries utilisées).
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
* Taille totale : 1866 oct (nb_segments 2 + LUT 16 + segments 1232 + cache 616).
* ======================================================================

Circuit_09_medium_2_nb_segments
        fdb   146

Circuit_09_medium_2_sprite_lut
        fcb   $00,$82,$83,$81,$92,$A8,$8A,$80,$97,$A0,$A2,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_09_medium_2_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$20,$20,$00,$12,$00,$12  ; seg   4                                    #1:$83@+18 #3:$83@+18
        fcb   $00,$00,$20,$20,$00,$12,$00,$12  ; seg   5                                    #1:$83@+18 #3:$83@+18
        fcb   $00,$00,$23,$23,$EE,$12,$EE,$12  ; seg   6                                    #0:$81@-18 #1:$83@+18 #2:$81@-18 #3:$83@+18
        fcb   $00,$00,$23,$23,$EE,$12,$EE,$12  ; seg   7                                    #0:$81@-18 #1:$83@+18 #2:$81@-18 #3:$83@+18
        fcb   $FC,$00,$03,$40,$EE,$00,$00,$1C  ; seg   8  curve=-4            flags=[PIT]   #0:$81@-18 #3:$92@+28
        fcb   $FC,$00,$03,$40,$EE,$00,$00,$28  ; seg   9  curve=-4            flags=[PIT]   #0:$81@-18 #3:$92@+40
        fcb   $FC,$00,$03,$00,$EE,$00,$00,$00  ; seg  10  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$03,$40,$EE,$00,$00,$30  ; seg  11  curve=-4            flags=[PIT]   #0:$81@-18 #3:$92@+48
        fcb   $FC,$00,$03,$40,$EE,$00,$00,$D0  ; seg  12  curve=-4            flags=[PIT]   #0:$81@-18 #3:$92@-48
        fcb   $FC,$00,$03,$00,$EE,$00,$00,$00  ; seg  13  curve=-4            flags=[PIT]   #0:$81@-18
        fcb   $FC,$00,$00,$00,$00,$00,$00,$00  ; seg  14  curve=-4            flags=[PIT]
        fcb   $FC,$00,$00,$40,$00,$00,$00,$20  ; seg  15  curve=-4            flags=[PIT]   #3:$92@+32
        fcb   $00,$00,$65,$40,$12,$E0,$00,$14  ; seg  16                                    #0:$A8@+18 #1:$8A@-32 #3:$92@+20
        fcb   $00,$00,$05,$40,$12,$00,$00,$E0  ; seg  17                                    #0:$A8@+18 #3:$92@-32
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  18                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  19                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$03,$40,$EE,$00,$00,$14  ; seg  20  curve=-6                          #0:$81@-18 #3:$92@+20
        fcb   $7A,$00,$03,$40,$EE,$00,$00,$2C  ; seg  21  curve=-6                          #0:$81@-18 #3:$92@+44
        fcb   $7A,$00,$77,$77,$12,$12,$12,$12  ; seg  22  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$77,$77,$12,$12,$12,$12  ; seg  23  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$07,$47,$12,$00,$12,$E0  ; seg  24  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$92@-32
        fcb   $06,$00,$07,$47,$12,$00,$12,$D0  ; seg  25  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$92@-48
        fcb   $06,$00,$67,$07,$12,$C0,$12,$00  ; seg  26  curve=+6                          #0:$80@+18 #1:$8A@-64 #2:$80@+18
        fcb   $06,$00,$07,$47,$12,$00,$12,$E0  ; seg  27  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$92@-32
        fcb   $06,$00,$67,$07,$12,$20,$12,$00  ; seg  28  curve=+6                          #0:$80@+18 #1:$8A@+32 #2:$80@+18
        fcb   $06,$00,$07,$47,$12,$00,$12,$E4  ; seg  29  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$92@-28
        fcb   $06,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  30  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $06,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  31  curve=+6                          #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$03,$43,$EE,$00,$EE,$24  ; seg  32  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$92@+36
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  33  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$40,$EE,$00,$00,$1C  ; seg  34  curve=-6                          #0:$81@-18 #3:$92@+28
        fcb   $7A,$00,$03,$40,$EE,$00,$00,$14  ; seg  35  curve=-6                          #0:$81@-18 #3:$92@+20
        fcb   $7C,$00,$63,$00,$EE,$D0,$00,$00  ; seg  36  curve=-4                          #0:$81@-18 #1:$8A@-48
        fcb   $7C,$00,$03,$40,$EE,$00,$00,$20  ; seg  37  curve=-4                          #0:$81@-18 #3:$92@+32
        fcb   $7C,$00,$05,$40,$12,$00,$00,$EC  ; seg  38  curve=-4                          #0:$A8@+18 #3:$92@-20
        fcb   $7C,$00,$05,$00,$12,$00,$00,$00  ; seg  39  curve=-4                          #0:$A8@+18
        fcb   $00,$00,$05,$40,$12,$00,$00,$D8  ; seg  40                                    #0:$A8@+18 #3:$92@-40
        fcb   $00,$00,$05,$40,$12,$00,$00,$E0  ; seg  41                                    #0:$A8@+18 #3:$92@-32
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg  42                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg  43                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$03,$40,$EE,$00,$00,$14  ; seg  44  curve=-4                          #0:$81@-18 #3:$92@+20
        fcb   $7C,$00,$63,$00,$EE,$18,$00,$00  ; seg  45  curve=-4                          #0:$81@-18 #1:$8A@+24
        fcb   $7C,$00,$05,$00,$12,$00,$00,$00  ; seg  46  curve=-4                          #0:$A8@+18
        fcb   $7C,$00,$05,$40,$12,$00,$00,$EC  ; seg  47  curve=-4                          #0:$A8@+18 #3:$92@-20
        fcb   $00,$00,$05,$40,$12,$00,$00,$20  ; seg  48                                    #0:$A8@+18 #3:$92@+32
        fcb   $00,$00,$05,$40,$12,$00,$00,$E0  ; seg  49                                    #0:$A8@+18 #3:$92@-32
        fcb   $00,$00,$65,$00,$12,$2C,$00,$00  ; seg  50                                    #0:$A8@+18 #1:$8A@+44
        fcb   $00,$00,$05,$40,$12,$00,$00,$E4  ; seg  51                                    #0:$A8@+18 #3:$92@-28
        fcb   $00,$00,$05,$40,$12,$00,$00,$EC  ; seg  52                                    #0:$A8@+18 #3:$92@-20
        fcb   $00,$00,$05,$00,$12,$00,$00,$00  ; seg  53                                    #0:$A8@+18
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  54                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  55                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  56  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  57  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$40,$EE,$00,$00,$14  ; seg  58  curve=-6                          #0:$81@-18 #3:$92@+20
        fcb   $7A,$00,$03,$40,$EE,$00,$00,$18  ; seg  59  curve=-6                          #0:$81@-18 #3:$92@+24
        fcb   $7C,$00,$63,$00,$EE,$18,$00,$00  ; seg  60  curve=-4                          #0:$81@-18 #1:$8A@+24
        fcb   $7C,$00,$03,$40,$EE,$00,$00,$14  ; seg  61  curve=-4                          #0:$81@-18 #3:$92@+20
        fcb   $7C,$00,$03,$03,$EE,$00,$EE,$00  ; seg  62  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$03,$03,$EE,$00,$EE,$00  ; seg  63  curve=-4                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$43,$EE,$00,$EE,$14  ; seg  64  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$92@+20
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  65  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$65,$40,$EE,$1C,$00,$2C  ; seg  66  curve=-6                          #0:$A8@-18 #1:$8A@+28 #3:$92@+44
        fcb   $7A,$00,$05,$40,$EE,$00,$00,$20  ; seg  67  curve=-6                          #0:$A8@-18 #3:$92@+32
        fcb   $00,$00,$65,$00,$EE,$D0,$00,$00  ; seg  68                                    #0:$A8@-18 #1:$8A@-48
        fcb   $00,$00,$05,$40,$EE,$00,$00,$1C  ; seg  69                                    #0:$A8@-18 #3:$92@+28
        fcb   $00,$00,$05,$40,$EE,$00,$00,$18  ; seg  70                                    #0:$A8@-18 #3:$92@+24
        fcb   $00,$00,$65,$00,$EE,$1C,$00,$00  ; seg  71                                    #0:$A8@-18 #1:$8A@+28
        fcb   $00,$00,$05,$40,$EE,$00,$00,$14  ; seg  72                                    #0:$A8@-18 #3:$92@+20
        fcb   $00,$00,$65,$00,$EE,$E0,$00,$00  ; seg  73                                    #0:$A8@-18 #1:$8A@-32
        fcb   $00,$00,$77,$77,$12,$12,$12,$12  ; seg  74                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$77,$77,$12,$12,$12,$12  ; seg  75                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  76  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$47,$12,$00,$12,$EC  ; seg  77  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$92@-20
        fcb   $06,$00,$67,$00,$12,$E0,$00,$00  ; seg  78  curve=+6                          #0:$80@+18 #1:$8A@-32
        fcb   $06,$00,$07,$00,$12,$00,$00,$00  ; seg  79  curve=+6                          #0:$80@+18
        fcb   $04,$00,$67,$00,$12,$D8,$00,$00  ; seg  80  curve=+4                          #0:$80@+18 #1:$8A@-40
        fcb   $04,$00,$67,$00,$12,$C8,$00,$00  ; seg  81  curve=+4                          #0:$80@+18 #1:$8A@-56
        fcb   $04,$00,$07,$07,$12,$00,$12,$00  ; seg  82  curve=+4                          #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$67,$07,$12,$E0,$12,$00  ; seg  83  curve=+4                          #0:$80@+18 #1:$8A@-32 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  84  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  85  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$60,$00,$00,$D8,$00,$00  ; seg  86  curve=+6                          #1:$8A@-40
        fcb   $06,$00,$60,$00,$00,$C0,$00,$00  ; seg  87  curve=+6                          #1:$8A@-64
        fcb   $00,$00,$08,$08,$EE,$00,$EE,$00  ; seg  88                                    #0:$97@-18 #2:$97@-18
        fcb   $00,$00,$68,$08,$EE,$20,$EE,$00  ; seg  89                                    #0:$97@-18 #1:$8A@+32 #2:$97@-18
        fcb   $00,$00,$68,$68,$12,$1C,$12,$14  ; seg  90                                    #0:$97@+18 #1:$8A@+28 #2:$97@+18 #3:$8A@+20
        fcb   $00,$00,$08,$08,$12,$00,$12,$00  ; seg  91                                    #0:$97@+18 #2:$97@+18
        fcb   $00,$00,$68,$08,$EE,$30,$EE,$00  ; seg  92                                    #0:$97@-18 #1:$8A@+48 #2:$97@-18
        fcb   $00,$00,$68,$08,$EE,$1C,$EE,$00  ; seg  93                                    #0:$97@-18 #1:$8A@+28 #2:$97@-18
        fcb   $00,$00,$68,$08,$12,$14,$12,$00  ; seg  94                                    #0:$97@+18 #1:$8A@+20 #2:$97@+18
        fcb   $00,$00,$08,$08,$12,$00,$12,$00  ; seg  95                                    #0:$97@+18 #2:$97@+18
        fcb   $00,$00,$60,$00,$00,$20,$00,$00  ; seg  96                                    #1:$8A@+32
        fcb   $00,$00,$60,$60,$00,$EC,$00,$14  ; seg  97                                    #1:$8A@-20 #3:$8A@+20
        fcb   $00,$00,$67,$07,$12,$D8,$12,$00  ; seg  98                                    #0:$80@+18 #1:$8A@-40 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg  99                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$67,$00,$12,$E4,$00,$00  ; seg 100  curve=+4                          #0:$80@+18 #1:$8A@-28
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 101  curve=+4                          #0:$80@+18
        fcb   $04,$00,$60,$00,$00,$20,$00,$00  ; seg 102  curve=+4                          #1:$8A@+32
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 103  curve=+4
        fcb   $00,$00,$99,$99,$12,$12,$11,$11  ; seg 104                                    #0:$A0@+18 #1:$A0@+18 #2:$A0@+17 #3:$A0@+17
        fcb   $00,$00,$99,$99,$10,$10,$0F,$0F  ; seg 105                                    #0:$A0@+16 #1:$A0@+16 #2:$A0@+15 #3:$A0@+15
        fcb   $00,$00,$99,$99,$0E,$0E,$0D,$0D  ; seg 106                                    #0:$A0@+14 #1:$A0@+14 #2:$A0@+13 #3:$A0@+13
        fcb   $00,$00,$99,$99,$0C,$0C,$0B,$0B  ; seg 107                                    #0:$A0@+12 #1:$A0@+12 #2:$A0@+11 #3:$A0@+11
        fcb   $00,$00,$99,$99,$0A,$0A,$09,$09  ; seg 108                                    #0:$A0@+10 #1:$A0@+10 #2:$A0@+9 #3:$A0@+9
        fcb   $00,$00,$99,$99,$08,$08,$07,$07  ; seg 109                                    #0:$A0@+8 #1:$A0@+8 #2:$A0@+7 #3:$A0@+7
        fcb   $00,$00,$93,$93,$EE,$06,$EE,$06  ; seg 110                                    #0:$81@-18 #1:$A0@+6 #2:$81@-18 #3:$A0@+6
        fcb   $00,$00,$93,$93,$EE,$06,$EE,$06  ; seg 111                                    #0:$81@-18 #1:$A0@+6 #2:$81@-18 #3:$A0@+6
        fcb   $7B,$00,$A3,$AA,$EE,$04,$0C,$09  ; seg 112  curve=-5                          #0:$81@-18 #1:$A2@+4 #2:$A2@+12 #3:$A2@+9
        fcb   $7B,$00,$A3,$A0,$EE,$0A,$00,$07  ; seg 113  curve=-5                          #0:$81@-18 #1:$A2@+10 #3:$A2@+7
        fcb   $7B,$00,$A3,$0A,$EE,$0C,$0A,$00  ; seg 114  curve=-5                          #0:$81@-18 #1:$A2@+12 #2:$A2@+10
        fcb   $7B,$00,$03,$AA,$EE,$00,$04,$0B  ; seg 115  curve=-5                          #0:$81@-18 #2:$A2@+4 #3:$A2@+11
        fcb   $7B,$00,$A3,$AA,$EE,$0A,$08,$0D  ; seg 116  curve=-5                          #0:$81@-18 #1:$A2@+10 #2:$A2@+8 #3:$A2@+13
        fcb   $7B,$00,$A3,$AA,$EE,$02,$06,$09  ; seg 117  curve=-5                          #0:$81@-18 #1:$A2@+2 #2:$A2@+6 #3:$A2@+9
        fcb   $7B,$00,$03,$A0,$EE,$00,$00,$0D  ; seg 118  curve=-5                          #0:$81@-18 #3:$A2@+13
        fcb   $7B,$00,$A3,$AA,$EE,$0C,$04,$09  ; seg 119  curve=-5                          #0:$81@-18 #1:$A2@+12 #2:$A2@+4 #3:$A2@+9
        fcb   $7B,$00,$A3,$A0,$EE,$04,$00,$0B  ; seg 120  curve=-5                          #0:$81@-18 #1:$A2@+4 #3:$A2@+11
        fcb   $7B,$00,$A3,$0A,$EE,$0C,$06,$00  ; seg 121  curve=-5                          #0:$81@-18 #1:$A2@+12 #2:$A2@+6
        fcb   $7B,$00,$03,$AA,$EE,$00,$04,$0D  ; seg 122  curve=-5                          #0:$81@-18 #2:$A2@+4 #3:$A2@+13
        fcb   $7B,$00,$A3,$A0,$EE,$0E,$00,$0B  ; seg 123  curve=-5                          #0:$81@-18 #1:$A2@+14 #3:$A2@+11
        fcb   $7B,$00,$A3,$0A,$EE,$0C,$04,$00  ; seg 124  curve=-5                          #0:$81@-18 #1:$A2@+12 #2:$A2@+4
        fcb   $7B,$00,$03,$00,$EE,$00,$00,$00  ; seg 125  curve=-5                          #0:$81@-18
        fcb   $7B,$00,$08,$08,$12,$00,$12,$00  ; seg 126  curve=-5                          #0:$97@+18 #2:$97@+18
        fcb   $7B,$00,$08,$08,$12,$00,$12,$00  ; seg 127  curve=-5                          #0:$97@+18 #2:$97@+18
        fcb   $00,$00,$68,$08,$EE,$E0,$EE,$00  ; seg 128                                    #0:$97@-18 #1:$8A@-32 #2:$97@-18
        fcb   $00,$00,$68,$08,$EE,$20,$EE,$00  ; seg 129                                    #0:$97@-18 #1:$8A@+32 #2:$97@-18
        fcb   $00,$00,$08,$08,$12,$00,$12,$00  ; seg 130                                    #0:$97@+18 #2:$97@+18
        fcb   $00,$00,$68,$08,$12,$E0,$12,$00  ; seg 131                                    #0:$97@+18 #1:$8A@-32 #2:$97@+18
        fcb   $00,$00,$68,$08,$EE,$14,$EE,$00  ; seg 132                                    #0:$97@-18 #1:$8A@+20 #2:$97@-18
        fcb   $00,$00,$08,$08,$EE,$00,$EE,$00  ; seg 133                                    #0:$97@-18 #2:$97@-18
        fcb   $00,$00,$68,$08,$12,$E0,$12,$00  ; seg 134                                    #0:$97@+18 #1:$8A@-32 #2:$97@+18
        fcb   $00,$00,$68,$08,$12,$D8,$12,$00  ; seg 135                                    #0:$97@+18 #1:$8A@-40 #2:$97@+18
        fcb   $00,$00,$08,$08,$EE,$00,$EE,$00  ; seg 136                                    #0:$97@-18 #2:$97@-18
        fcb   $00,$00,$08,$08,$EE,$00,$EE,$00  ; seg 137                                    #0:$97@-18 #2:$97@-18
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 138
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 139
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 140
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 141
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 142
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 143
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 144
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 145
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 146                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 147
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 148
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 149
        fcb   $00,$00,$20,$20,$00,$12,$00,$12  ; seg 150                                    #1:$83@+18 #3:$83@+18
        fcb   $00,$00,$20,$20,$00,$12,$00,$12  ; seg 151                                    #1:$83@+18 #3:$83@+18
        fcb   $00,$00,$23,$23,$EE,$12,$EE,$12  ; seg 152                                    #0:$81@-18 #1:$83@+18 #2:$81@-18 #3:$83@+18
        fcb   $00,$00,$23,$23,$EE,$12,$EE,$12  ; seg 153                                    #0:$81@-18 #1:$83@+18 #2:$81@-18 #3:$83@+18

Circuit_09_medium_2_segment_cache
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
        fcb   $EC,$00,$F6,$0A  ; seg  13  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  14  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  15  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  16  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  17  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  18  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  19  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  20  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  21  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  22  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$00,$F6,$0A  ; seg  23  yaw= -50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  24  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CE,$00,$F6,$0A  ; seg  25  yaw= -50 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  26  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DA,$00,$F6,$0A  ; seg  27  yaw= -38 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  28  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E6,$00,$F6,$0A  ; seg  29  yaw= -26 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  30  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F2,$00,$F6,$0A  ; seg  31  yaw= -14 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  32  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F2,$00,$F6,$0A  ; seg  33  yaw= -14 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  34  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E6,$00,$F6,$0A  ; seg  35  yaw= -26 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  36  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  37  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  38  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  39  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  40  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  41  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  42  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  43  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  44  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  45  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  46  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  47  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  48  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  49  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  50  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  51  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  52  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  53  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  54  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  55  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  56  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg  57  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  58  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$0A  ; seg  59  yaw= -82 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  60  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg  61  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg  62  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg  63  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  64  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg  65  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg  66  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg  67  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  68  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  69  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  70  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  71  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  72  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  73  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  74  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  75  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  76  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg  77  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg  78  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg  79  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  80  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg  81  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg  82  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg  83  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  84  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$0A  ; seg  85  yaw= -82 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  86  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg  87  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  88  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  89  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  90  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  91  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  92  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  93  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  94  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  95  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  96  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  97  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  98  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$09  ; seg  99  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $C0,$00,$F6,$08  ; seg 100  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $C4,$00,$F6,$07  ; seg 101  yaw= -60 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $C8,$00,$F6,$06  ; seg 102  yaw= -56 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $CC,$00,$F6,$05  ; seg 103  yaw= -52 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $D0,$00,$F6,$04  ; seg 104  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $D0,$00,$F6,$03  ; seg 105  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $D0,$00,$F6,$02  ; seg 106  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $D0,$00,$F6,$01  ; seg 107  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $D0,$00,$F6,$00  ; seg 108  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $D0,$00,$F6,$FF  ; seg 109  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $D0,$00,$F6,$FE  ; seg 110  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $D0,$00,$F6,$FD  ; seg 111  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $D0,$00,$F6,$FC  ; seg 112  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $CB,$00,$F6,$FE  ; seg 113  yaw= -53 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $C6,$00,$F6,$FD  ; seg 114  yaw= -58 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $C1,$00,$F6,$FC  ; seg 115  yaw= -63 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $BC,$00,$F6,$FB  ; seg 116  yaw= -68 pitch=  +0 min_lat= -10 max_lat=  -5
        fcb   $B7,$00,$F6,$FA  ; seg 117  yaw= -73 pitch=  +0 min_lat= -10 max_lat=  -6
        fcb   $B2,$00,$F6,$FD  ; seg 118  yaw= -78 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $AD,$00,$F6,$FC  ; seg 119  yaw= -83 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $A8,$00,$F6,$FC  ; seg 120  yaw= -88 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $A3,$00,$F6,$FD  ; seg 121  yaw= -93 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $9E,$00,$F6,$FC  ; seg 122  yaw= -98 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $99,$00,$F6,$FD  ; seg 123  yaw=-103 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $94,$00,$F6,$FC  ; seg 124  yaw=-108 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $8F,$00,$F6,$0A  ; seg 125  yaw=-113 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8A,$00,$F6,$0A  ; seg 126  yaw=-118 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $85,$00,$F6,$0A  ; seg 127  yaw=-123 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 128  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 129  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 130  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 131  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 132  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 133  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 134  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 135  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 136  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 137  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 138  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 139  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 140  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 141  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 142  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 143  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 144  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 145  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 146 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 147 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 148 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 149 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 150 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 151 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 152 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 153 (wraparound de seg 7)
