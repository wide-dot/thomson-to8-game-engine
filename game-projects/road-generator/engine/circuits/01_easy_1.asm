* ======================================================================
* Circuit_01_easy_1 — N=116 segments (format compact 8 oct/seg)
* Source       : 01_easy_1.bin (extrait de FILE30)
*
* Pays         : MEXICO
* Lieu         : monterrey
* Description  : shallow hills
* Hazards      : some roadworks - lane closed
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
* par circuit ; ce circuit : 12 entries utilisées).
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
* Taille totale : 1506 oct (nb_segments 2 + LUT 16 + segments 992 + cache 496).
* ======================================================================

Circuit_01_easy_1_nb_segments
        fdb   116

Circuit_01_easy_1_sprite_lut
        fcb   $00,$82,$83,$8F,$81,$9E,$9D,$80,$8B,$8A,$A1,$9F,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_01_easy_1_segments
        fcb   $00,$80,$01,$00,$00,$00,$00,$00  ; seg   0                      flags=[START] #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   1
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg   3
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg   8                      flags=[PIT]
        fcb   $80,$00,$03,$00,$EC,$00,$00,$00  ; seg   9                      flags=[PIT]   #0:$8F@-20
        fcb   $80,$00,$03,$30,$28,$00,$00,$EC  ; seg  10                      flags=[PIT]   #0:$8F@+40 #3:$8F@-20
        fcb   $80,$00,$30,$00,$00,$EC,$00,$00  ; seg  11                      flags=[PIT]   #1:$8F@-20
        fcb   $80,$00,$03,$03,$E8,$00,$D8,$00  ; seg  12                      flags=[PIT]   #0:$8F@-24 #2:$8F@-40
        fcb   $80,$00,$00,$03,$00,$00,$DC,$00  ; seg  13                      flags=[PIT]   #2:$8F@-36
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  14                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $80,$00,$04,$04,$EE,$00,$EE,$00  ; seg  15                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$04,$30,$EE,$00,$00,$2C  ; seg  16  curve=-4                          #0:$81@-18 #3:$8F@+44
        fcb   $7C,$00,$04,$03,$EE,$00,$20,$00  ; seg  17  curve=-4                          #0:$81@-18 #2:$8F@+32
        fcb   $7C,$00,$54,$00,$EE,$E0,$00,$00  ; seg  18  curve=-4                          #0:$81@-18 #1:$9E@-32
        fcb   $7C,$00,$04,$60,$EE,$00,$00,$E0  ; seg  19  curve=-4                          #0:$81@-18 #3:$9D@-32
        fcb   $7C,$00,$04,$06,$EE,$00,$E4,$00  ; seg  20  curve=-4                          #0:$81@-18 #2:$9D@-28
        fcb   $7C,$00,$54,$00,$EE,$24,$00,$00  ; seg  21  curve=-4                          #0:$81@-18 #1:$9E@+36
        fcb   $7C,$00,$00,$50,$00,$00,$00,$24  ; seg  22  curve=-4                          #3:$9E@+36
        fcb   $7C,$00,$30,$00,$00,$18,$00,$00  ; seg  23  curve=-4                          #1:$8F@+24
        fcb   $00,$00,$05,$06,$30,$00,$1C,$00  ; seg  24                                    #0:$9E@+48 #2:$9D@+28
        fcb   $00,$00,$60,$00,$00,$20,$00,$00  ; seg  25                                    #1:$9D@+32
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  26                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$04,$04,$EE,$00,$EE,$00  ; seg  27                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$34,$60,$EE,$20,$00,$E0  ; seg  28  curve=-4                          #0:$81@-18 #1:$8F@+32 #3:$9D@-32
        fcb   $7C,$00,$04,$00,$EE,$00,$00,$00  ; seg  29  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$04,$03,$EE,$00,$14,$00  ; seg  30  curve=-4                          #0:$81@-18 #2:$8F@+20
        fcb   $7C,$00,$04,$03,$EE,$00,$16,$00  ; seg  31  curve=-4                          #0:$81@-18 #2:$8F@+22
        fcb   $7C,$00,$04,$03,$EE,$00,$14,$00  ; seg  32  curve=-4                          #0:$81@-18 #2:$8F@+20
        fcb   $7C,$00,$04,$53,$EE,$00,$18,$14  ; seg  33  curve=-4                          #0:$81@-18 #2:$8F@+24 #3:$9E@+20
        fcb   $7C,$00,$34,$03,$EE,$20,$14,$00  ; seg  34  curve=-4                          #0:$81@-18 #1:$8F@+32 #2:$8F@+20
        fcb   $7C,$00,$04,$03,$EE,$00,$16,$00  ; seg  35  curve=-4                          #0:$81@-18 #2:$8F@+22
        fcb   $7C,$00,$64,$03,$EE,$D8,$18,$00  ; seg  36  curve=-4                          #0:$81@-18 #1:$9D@-40 #2:$8F@+24
        fcb   $7C,$00,$04,$03,$EE,$00,$18,$00  ; seg  37  curve=-4                          #0:$81@-18 #2:$8F@+24
        fcb   $7C,$00,$03,$03,$EA,$00,$14,$00  ; seg  38  curve=-4                          #0:$8F@-22 #2:$8F@+20
        fcb   $7C,$00,$03,$03,$E8,$00,$16,$00  ; seg  39  curve=-4                          #0:$8F@-24 #2:$8F@+22
        fcb   $00,$00,$63,$00,$EC,$E8,$00,$00  ; seg  40                                    #0:$8F@-20 #1:$9D@-24
        fcb   $00,$00,$03,$30,$E8,$00,$00,$14  ; seg  41                                    #0:$8F@-24 #3:$8F@+20
        fcb   $00,$00,$33,$00,$EA,$D0,$00,$00  ; seg  42                                    #0:$8F@-22 #1:$8F@-48
        fcb   $00,$00,$03,$50,$EA,$00,$00,$20  ; seg  43                                    #0:$8F@-22 #3:$9E@+32
        fcb   $00,$7E,$60,$00,$00,$E0,$00,$00  ; seg  44            pitch=-2                #1:$9D@-32
        fcb   $00,$7E,$00,$60,$00,$00,$00,$28  ; seg  45            pitch=-2                #3:$9D@+40
        fcb   $00,$7E,$07,$07,$12,$00,$12,$00  ; seg  46            pitch=-2                #0:$80@+18 #2:$80@+18
        fcb   $00,$7E,$67,$07,$12,$20,$12,$00  ; seg  47            pitch=-2                #0:$80@+18 #1:$9D@+32 #2:$80@+18
        fcb   $05,$00,$57,$60,$12,$14,$00,$20  ; seg  48  curve=+5                          #0:$80@+18 #1:$9E@+20 #3:$9D@+32
        fcb   $05,$00,$07,$00,$12,$00,$00,$00  ; seg  49  curve=+5                          #0:$80@+18
        fcb   $05,$00,$30,$00,$00,$D8,$00,$00  ; seg  50  curve=+5                          #1:$8F@-40
        fcb   $05,$00,$00,$60,$00,$00,$00,$D8  ; seg  51  curve=+5                          #3:$9D@-40
        fcb   $00,$02,$03,$00,$EC,$00,$00,$00  ; seg  52            pitch=+2                #0:$8F@-20
        fcb   $00,$02,$53,$00,$EA,$20,$00,$00  ; seg  53            pitch=+2                #0:$8F@-22 #1:$9E@+32
        fcb   $00,$02,$03,$60,$E8,$00,$00,$14  ; seg  54            pitch=+2                #0:$8F@-24 #3:$9D@+20
        fcb   $00,$02,$63,$00,$EA,$20,$00,$00  ; seg  55            pitch=+2                #0:$8F@-22 #1:$9D@+32
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg  56            pitch=+2
        fcb   $00,$02,$00,$30,$00,$00,$00,$30  ; seg  57            pitch=+2                #3:$8F@+48
        fcb   $00,$02,$04,$04,$EE,$00,$EE,$00  ; seg  58            pitch=+2                #0:$81@-18 #2:$81@-18
        fcb   $00,$02,$04,$04,$EE,$00,$EE,$00  ; seg  59            pitch=+2                #0:$81@-18 #2:$81@-18
        fcb   $7B,$00,$04,$03,$EE,$00,$14,$00  ; seg  60  curve=-5                          #0:$81@-18 #2:$8F@+20
        fcb   $7B,$00,$04,$03,$EE,$00,$16,$00  ; seg  61  curve=-5                          #0:$81@-18 #2:$8F@+22
        fcb   $7B,$00,$00,$03,$00,$00,$18,$00  ; seg  62  curve=-5                          #2:$8F@+24
        fcb   $7B,$00,$00,$03,$00,$00,$14,$00  ; seg  63  curve=-5                          #2:$8F@+20
        fcb   $00,$7E,$03,$00,$E8,$00,$00,$00  ; seg  64            pitch=-2                #0:$8F@-24
        fcb   $00,$7E,$03,$00,$EA,$00,$00,$00  ; seg  65            pitch=-2                #0:$8F@-22
        fcb   $00,$7E,$03,$00,$EC,$00,$00,$00  ; seg  66            pitch=-2                #0:$8F@-20
        fcb   $00,$7E,$03,$00,$E8,$00,$00,$00  ; seg  67            pitch=-2                #0:$8F@-24
        fcb   $00,$00,$06,$00,$C8,$00,$00,$00  ; seg  68                                    #0:$9D@-56
        fcb   $00,$00,$80,$00,$00,$28,$00,$00  ; seg  69                                    #1:$8B@+40
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  70                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$44,$44,$EE,$EE,$EE,$EE  ; seg  71                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$84,$04,$EE,$1C,$EE,$00  ; seg  72  curve=-6                          #0:$81@-18 #1:$8B@+28 #2:$81@-18
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  73  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$84,$EE,$00,$EE,$D0  ; seg  74  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8B@-48
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  75  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$04,$84,$EE,$00,$EE,$20  ; seg  76  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$8B@+32
        fcb   $7A,$00,$04,$04,$EE,$00,$EE,$00  ; seg  77  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$90,$00,$00,$D0,$00,$00  ; seg  78  curve=-6                          #1:$8A@-48
        fcb   $7A,$00,$00,$80,$00,$00,$00,$EC  ; seg  79  curve=-6                          #3:$8B@-20
        fcb   $00,$00,$00,$09,$00,$00,$14,$00  ; seg  80                                    #2:$8A@+20
        fcb   $00,$00,$09,$00,$20,$00,$00,$00  ; seg  81                                    #0:$8A@+32
        fcb   $00,$02,$00,$08,$00,$00,$28,$00  ; seg  82            pitch=+2                #2:$8B@+40
        fcb   $00,$02,$09,$00,$18,$00,$00,$00  ; seg  83            pitch=+2                #0:$8A@+24
        fcb   $00,$00,$90,$00,$00,$EC,$00,$00  ; seg  84                                    #1:$8A@-20
        fcb   $00,$00,$08,$09,$D8,$00,$14,$00  ; seg  85                                    #0:$8B@-40 #2:$8A@+20
        fcb   $00,$7E,$00,$90,$00,$00,$00,$24  ; seg  86            pitch=-2                #3:$8A@+36
        fcb   $00,$7E,$08,$00,$EC,$00,$00,$00  ; seg  87            pitch=-2                #0:$8B@-20
        fcb   $00,$00,$8A,$0A,$EE,$D8,$EE,$00  ; seg  88                                    #0:$A1@-18 #1:$8B@-40 #2:$A1@-18
        fcb   $00,$00,$0A,$9A,$EE,$00,$EE,$EC  ; seg  89                                    #0:$A1@-18 #2:$A1@-18 #3:$8A@-20
        fcb   $00,$00,$0A,$0A,$EE,$00,$EE,$00  ; seg  90                                    #0:$A1@-18 #2:$A1@-18
        fcb   $00,$00,$9A,$0A,$F0,$1C,$F2,$00  ; seg  91                                    #0:$A1@-16 #1:$8A@+28 #2:$A1@-14
        fcb   $00,$00,$0A,$0A,$F4,$00,$F6,$00  ; seg  92                                    #0:$A1@-12 #2:$A1@-10
        fcb   $00,$00,$0A,$9A,$F8,$00,$F8,$CC  ; seg  93                                    #0:$A1@-8 #2:$A1@-8 #3:$8A@-52
        fcb   $00,$00,$0A,$8A,$F8,$00,$F8,$D0  ; seg  94                                    #0:$A1@-8 #2:$A1@-8 #3:$8B@-48
        fcb   $00,$00,$9A,$0A,$F8,$E0,$F8,$00  ; seg  95                                    #0:$A1@-8 #1:$8A@-32 #2:$A1@-8
        fcb   $00,$00,$9B,$80,$F8,$EC,$00,$E0  ; seg  96                                    #0:$9F@-8 #1:$8A@-20 #3:$8B@-32
        fcb   $00,$00,$0B,$09,$F8,$00,$F6,$00  ; seg  97                                    #0:$9F@-8 #2:$8A@-10
        fcb   $00,$00,$0B,$89,$F8,$00,$E4,$F4  ; seg  98                                    #0:$9F@-8 #2:$8A@-28 #3:$8B@-12
        fcb   $00,$00,$8B,$08,$F8,$30,$F1,$00  ; seg  99                                    #0:$9F@-8 #1:$8B@+48 #2:$8B@-15
        fcb   $00,$7E,$8B,$80,$F8,$F9,$00,$F8  ; seg 100            pitch=-2                #0:$9F@-8 #1:$8B@-7 #3:$8B@-8
        fcb   $00,$7E,$9B,$09,$F8,$F2,$F3,$00  ; seg 101            pitch=-2                #0:$9F@-8 #1:$8A@-14 #2:$8A@-13
        fcb   $00,$7E,$0B,$00,$F8,$00,$00,$00  ; seg 102            pitch=-2                #0:$9F@-8
        fcb   $00,$7E,$9B,$00,$F8,$1C,$00,$00  ; seg 103            pitch=-2                #0:$9F@-8 #1:$8A@+28
        fcb   $00,$00,$90,$09,$00,$30,$18,$00  ; seg 104                                    #1:$8A@+48 #2:$8A@+24
        fcb   $00,$00,$80,$80,$00,$D8,$00,$C0  ; seg 105                                    #1:$8B@-40 #3:$8B@-64
        fcb   $00,$00,$90,$09,$00,$20,$24,$00  ; seg 106                                    #1:$8A@+32 #2:$8A@+36
        fcb   $00,$00,$00,$99,$00,$00,$30,$E0  ; seg 107                                    #2:$8A@+48 #3:$8A@-32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 108
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 109
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 110
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 111
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg 112            pitch=+2
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg 113            pitch=+2
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg 114            pitch=+2
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg 115            pitch=+2
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 116                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 117
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 118
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 119
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 120                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 121                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 122                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 123                                    #0:$83@+18 #2:$83@+18

Circuit_01_easy_1_segment_cache
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
        fcb   $F0,$00,$F6,$0A  ; seg  20  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  21  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  22  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  23  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  24  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  25  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  26  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  27  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  28  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  29  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  30  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  31  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  32  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  33  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  34  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  35  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  36  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  37  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  38  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  39  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  40  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  41  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  42  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  43  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  44  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$FE,$F6,$0A  ; seg  45  yaw= -80 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $B0,$FC,$F6,$0A  ; seg  46  yaw= -80 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $B0,$FA,$F6,$0A  ; seg  47  yaw= -80 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $B0,$F8,$F6,$0A  ; seg  48  yaw= -80 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $B5,$F8,$F6,$0A  ; seg  49  yaw= -75 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $BA,$F8,$F6,$0A  ; seg  50  yaw= -70 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $BF,$F8,$F6,$0A  ; seg  51  yaw= -65 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $C4,$F8,$F6,$0A  ; seg  52  yaw= -60 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $C4,$FA,$F6,$0A  ; seg  53  yaw= -60 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $C4,$FC,$F6,$0A  ; seg  54  yaw= -60 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $C4,$FE,$F6,$0A  ; seg  55  yaw= -60 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  56  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$02,$F6,$0A  ; seg  57  yaw= -60 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C4,$04,$F6,$0A  ; seg  58  yaw= -60 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C4,$06,$F6,$0A  ; seg  59  yaw= -60 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C4,$08,$F6,$0A  ; seg  60  yaw= -60 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $BF,$08,$F6,$0A  ; seg  61  yaw= -65 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $BA,$08,$F6,$0A  ; seg  62  yaw= -70 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B5,$08,$F6,$0A  ; seg  63  yaw= -75 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$08,$F6,$0A  ; seg  64  yaw= -80 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $B0,$06,$F6,$0A  ; seg  65  yaw= -80 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $B0,$04,$F6,$0A  ; seg  66  yaw= -80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $B0,$02,$F6,$0A  ; seg  67  yaw= -80 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  68  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  69  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  70  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  71  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  72  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AA,$00,$F6,$0A  ; seg  73  yaw= -86 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg  74  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9E,$00,$F6,$0A  ; seg  75  yaw= -98 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg  76  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg  77  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg  78  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg  79  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  80  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  81  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg  82  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg  83  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$04,$F7,$0A  ; seg  84  yaw=-128 pitch=  +4 min_lat=  -9 max_lat= +10
        fcb   $80,$04,$F8,$0A  ; seg  85  yaw=-128 pitch=  +4 min_lat=  -8 max_lat= +10
        fcb   $80,$04,$F9,$0A  ; seg  86  yaw=-128 pitch=  +4 min_lat=  -7 max_lat= +10
        fcb   $80,$02,$FA,$0A  ; seg  87  yaw=-128 pitch=  +2 min_lat=  -6 max_lat= +10
        fcb   $80,$00,$FB,$0A  ; seg  88  yaw=-128 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $80,$00,$FC,$0A  ; seg  89  yaw=-128 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $80,$00,$FD,$0A  ; seg  90  yaw=-128 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $80,$00,$FE,$0A  ; seg  91  yaw=-128 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $80,$00,$FF,$0A  ; seg  92  yaw=-128 pitch=  +0 min_lat=  -1 max_lat= +10
        fcb   $80,$00,$00,$0A  ; seg  93  yaw=-128 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $80,$00,$00,$0A  ; seg  94  yaw=-128 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $80,$00,$00,$0A  ; seg  95  yaw=-128 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $80,$00,$00,$0A  ; seg  96  yaw=-128 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $80,$00,$00,$0A  ; seg  97  yaw=-128 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $80,$00,$00,$0A  ; seg  98  yaw=-128 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $80,$00,$00,$0A  ; seg  99  yaw=-128 pitch=  +0 min_lat=  +0 max_lat= +10
        fcb   $80,$00,$01,$0A  ; seg 100  yaw=-128 pitch=  +0 min_lat=  +1 max_lat= +10
        fcb   $80,$FE,$00,$0A  ; seg 101  yaw=-128 pitch=  -2 min_lat=  +0 max_lat= +10
        fcb   $80,$FC,$00,$0A  ; seg 102  yaw=-128 pitch=  -4 min_lat=  +0 max_lat= +10
        fcb   $80,$FA,$00,$0A  ; seg 103  yaw=-128 pitch=  -6 min_lat=  +0 max_lat= +10
        fcb   $80,$F8,$F6,$0A  ; seg 104  yaw=-128 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $80,$F8,$F6,$0A  ; seg 105  yaw=-128 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $80,$F8,$F6,$0A  ; seg 106  yaw=-128 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $80,$F8,$F6,$0A  ; seg 107  yaw=-128 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $80,$F8,$F6,$0A  ; seg 108  yaw=-128 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $80,$F8,$F6,$0A  ; seg 109  yaw=-128 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $80,$F8,$F6,$0A  ; seg 110  yaw=-128 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $80,$F8,$F6,$0A  ; seg 111  yaw=-128 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $80,$F8,$F6,$0A  ; seg 112  yaw=-128 pitch=  -8 min_lat= -10 max_lat= +10
        fcb   $80,$FA,$F6,$0A  ; seg 113  yaw=-128 pitch=  -6 min_lat= -10 max_lat= +10
        fcb   $80,$FC,$F6,$0A  ; seg 114  yaw=-128 pitch=  -4 min_lat= -10 max_lat= +10
        fcb   $80,$FE,$F6,$0A  ; seg 115  yaw=-128 pitch=  -2 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 116 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 117 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 118 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 119 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 120 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 121 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 122 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 123 (wraparound de seg 7)
