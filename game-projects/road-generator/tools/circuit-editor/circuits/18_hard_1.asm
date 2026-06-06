* ======================================================================
* Circuit_18_hard_1 — N=148 segments (format compact 8 oct/seg)
* Source       : 18_hard_1.bin (extrait de FILE30)
*
* Pays         : NORWAY
* Lieu         : hardangerjokulen
* Description  : beware of loose rocks and
* Hazards      : water at the base of hills
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
* Taille totale : 1890 oct (nb_segments 2 + LUT 16 + segments 1248 + cache 624).
* ======================================================================

Circuit_18_hard_1_nb_segments
        fdb   148

Circuit_18_hard_1_sprite_lut
        fcb   $00,$82,$83,$81,$85,$9A,$8B,$89,$8A,$A7,$80,$A3,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_18_hard_1_segments
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
        fcb   $80,$00,$03,$03,$EE,$00,$EE,$00  ; seg  14                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $80,$00,$03,$03,$EE,$00,$EE,$00  ; seg  15                      flags=[PIT]   #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$03,$00,$EE,$00,$00,$00  ; seg  16  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$03,$00,$EE,$00,$00,$00  ; seg  17  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  18  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  19  curve=-4
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  21
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  22                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  23                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  24  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  25  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  26  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  27  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  28  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg  29  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg  30  curve=-6
        fcb   $7A,$00,$00,$00,$00,$00,$00,$00  ; seg  31  curve=-6
        fcb   $00,$00,$04,$04,$14,$00,$14,$00  ; seg  32                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$04,$04,$14,$00,$14,$00  ; seg  33                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$04,$04,$14,$00,$14,$00  ; seg  34                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$00,$04,$04,$14,$00,$14,$00  ; seg  35                                    #0:$85@+20 #2:$85@+20
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg  36            pitch=-2
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg  37            pitch=-2
        fcb   $00,$03,$05,$05,$12,$00,$12,$00  ; seg  38            pitch=+3                #0:$9A@+18 #2:$9A@+18
        fcb   $00,$03,$05,$05,$12,$00,$12,$00  ; seg  39            pitch=+3                #0:$9A@+18 #2:$9A@+18
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  40                                    #0:$9A@+18 #2:$9A@+18
        fcb   $00,$00,$05,$05,$12,$00,$12,$00  ; seg  41                                    #0:$9A@+18 #2:$9A@+18
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg  42            pitch=-3
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg  43            pitch=-3
        fcb   $00,$02,$76,$98,$FE,$F6,$F4,$EC  ; seg  44            pitch=+2                #0:$8B@-2 #1:$89@-10 #2:$8A@-12 #3:$A7@-20
        fcb   $00,$02,$88,$07,$FC,$F8,$FE,$00  ; seg  45            pitch=+2                #0:$8A@-4 #1:$8A@-8 #2:$89@-2
        fcb   $00,$7E,$87,$96,$F4,$FA,$FA,$14  ; seg  46            pitch=-2                #0:$89@-12 #1:$8A@-6 #2:$8B@-6 #3:$A7@+20
        fcb   $00,$7E,$70,$97,$00,$F4,$FC,$14  ; seg  47            pitch=-2                #1:$89@-12 #2:$89@-4 #3:$A7@+20
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg  48            pitch=+1
        fcb   $00,$01,$00,$90,$00,$00,$00,$EC  ; seg  49            pitch=+1                #3:$A7@-20
        fcb   $00,$02,$05,$05,$EE,$00,$EE,$00  ; seg  50            pitch=+2                #0:$9A@-18 #2:$9A@-18
        fcb   $00,$02,$05,$05,$EE,$00,$EE,$00  ; seg  51            pitch=+2                #0:$9A@-18 #2:$9A@-18
        fcb   $00,$7D,$05,$95,$EE,$00,$EE,$14  ; seg  52            pitch=-3                #0:$9A@-18 #2:$9A@-18 #3:$A7@+20
        fcb   $00,$7D,$05,$05,$EE,$00,$EE,$00  ; seg  53            pitch=-3                #0:$9A@-18 #2:$9A@-18
        fcb   $00,$03,$00,$00,$00,$00,$00,$00  ; seg  54            pitch=+3
        fcb   $00,$03,$00,$90,$00,$00,$00,$14  ; seg  55            pitch=+3                #3:$A7@+20
        fcb   $00,$7F,$68,$97,$02,$02,$08,$EC  ; seg  56            pitch=-1                #0:$8A@+2 #1:$8B@+2 #2:$89@+8 #3:$A7@-20
        fcb   $00,$7F,$86,$06,$0C,$06,$02,$00  ; seg  57            pitch=-1                #0:$8B@+12 #1:$8A@+6 #2:$8B@+2
        fcb   $00,$00,$76,$97,$04,$0C,$06,$14  ; seg  58                                    #0:$8B@+4 #1:$89@+12 #2:$89@+6 #3:$A7@+20
        fcb   $00,$00,$76,$08,$06,$0A,$04,$00  ; seg  59                                    #0:$8B@+6 #1:$89@+10 #2:$8A@+4
        fcb   $00,$02,$00,$90,$00,$00,$00,$14  ; seg  60            pitch=+2                #3:$A7@+20
        fcb   $00,$02,$00,$90,$00,$00,$00,$EC  ; seg  61            pitch=+2                #3:$A7@-20
        fcb   $00,$7F,$05,$05,$12,$00,$12,$00  ; seg  62            pitch=-1                #0:$9A@+18 #2:$9A@+18
        fcb   $00,$7F,$05,$05,$12,$00,$12,$00  ; seg  63            pitch=-1                #0:$9A@+18 #2:$9A@+18
        fcb   $00,$02,$05,$05,$12,$00,$12,$00  ; seg  64            pitch=+2                #0:$9A@+18 #2:$9A@+18
        fcb   $00,$02,$05,$05,$12,$00,$12,$00  ; seg  65            pitch=+2                #0:$9A@+18 #2:$9A@+18
        fcb   $00,$7D,$67,$98,$02,$02,$0E,$14  ; seg  66            pitch=-3                #0:$89@+2 #1:$8B@+2 #2:$8A@+14 #3:$A7@+20
        fcb   $00,$7D,$77,$06,$0C,$0E,$0C,$00  ; seg  67            pitch=-3                #0:$89@+12 #1:$89@+14 #2:$8B@+12
        fcb   $00,$02,$78,$06,$04,$0A,$04,$00  ; seg  68            pitch=+2                #0:$8A@+4 #1:$89@+10 #2:$8B@+4
        fcb   $00,$02,$87,$96,$06,$08,$0A,$EC  ; seg  69            pitch=+2                #0:$89@+6 #1:$8A@+8 #2:$8B@+10 #3:$A7@-20
        fcb   $00,$7F,$05,$05,$EE,$00,$EE,$00  ; seg  70            pitch=-1                #0:$9A@-18 #2:$9A@-18
        fcb   $00,$7F,$05,$05,$EE,$00,$EE,$00  ; seg  71            pitch=-1                #0:$9A@-18 #2:$9A@-18
        fcb   $00,$02,$05,$05,$EE,$00,$EE,$00  ; seg  72            pitch=+2                #0:$9A@-18 #2:$9A@-18
        fcb   $00,$02,$05,$05,$EE,$00,$EE,$00  ; seg  73            pitch=+2                #0:$9A@-18 #2:$9A@-18
        fcb   $00,$7D,$87,$97,$F2,$F8,$F2,$14  ; seg  74            pitch=-3                #0:$89@-14 #1:$8A@-8 #2:$89@-14 #3:$A7@+20
        fcb   $00,$7D,$67,$98,$F4,$F6,$F2,$EC  ; seg  75            pitch=-3                #0:$89@-12 #1:$8B@-10 #2:$8A@-14 #3:$A7@-20
        fcb   $00,$00,$76,$06,$F6,$F4,$FE,$00  ; seg  76                                    #0:$8B@-10 #1:$89@-12 #2:$8B@-2
        fcb   $00,$00,$87,$98,$F8,$FC,$FA,$14  ; seg  77                                    #0:$89@-8 #1:$8A@-4 #2:$8A@-6 #3:$A7@+20
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg  78                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg  79                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$03,$90,$EE,$00,$00,$EC  ; seg  80  curve=-4                          #0:$81@-18 #3:$A7@-20
        fcb   $7C,$00,$03,$00,$EE,$00,$00,$00  ; seg  81  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$90,$00,$00,$00,$EC  ; seg  82  curve=-4                          #3:$A7@-20
        fcb   $7C,$00,$00,$90,$00,$00,$00,$EC  ; seg  83  curve=-4                          #3:$A7@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  84
        fcb   $00,$00,$00,$90,$00,$00,$00,$14  ; seg  85                                    #3:$A7@+20
        fcb   $00,$00,$99,$90,$EC,$14,$00,$EC  ; seg  86                                    #0:$A7@-20 #1:$A7@+20 #3:$A7@-20
        fcb   $00,$00,$09,$09,$14,$00,$EC,$00  ; seg  87                                    #0:$A7@+20 #2:$A7@-20
        fcb   $00,$00,$99,$90,$EC,$14,$00,$14  ; seg  88                                    #0:$A7@-20 #1:$A7@+20 #3:$A7@+20
        fcb   $00,$00,$09,$99,$14,$00,$14,$EC  ; seg  89                                    #0:$A7@+20 #2:$A7@+20 #3:$A7@-20
        fcb   $00,$00,$90,$00,$00,$14,$00,$00  ; seg  90                                    #1:$A7@+20
        fcb   $00,$00,$09,$99,$14,$00,$EC,$14  ; seg  91                                    #0:$A7@+20 #2:$A7@-20 #3:$A7@+20
        fcb   $00,$00,$90,$90,$00,$EC,$00,$EC  ; seg  92                                    #1:$A7@-20 #3:$A7@-20
        fcb   $00,$00,$00,$09,$00,$00,$14,$00  ; seg  93                                    #2:$A7@+20
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  94                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$33,$33,$EE,$EE,$EE,$EE  ; seg  95                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$93,$03,$EE,$14,$EE,$00  ; seg  96  curve=-6                          #0:$81@-18 #1:$A7@+20 #2:$81@-18
        fcb   $7A,$00,$03,$93,$EE,$00,$EE,$14  ; seg  97  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A7@+20
        fcb   $7A,$00,$93,$03,$EE,$14,$EE,$00  ; seg  98  curve=-6                          #0:$81@-18 #1:$A7@+20 #2:$81@-18
        fcb   $7A,$00,$03,$93,$EE,$00,$EE,$14  ; seg  99  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A7@+20
        fcb   $7A,$00,$93,$03,$EE,$14,$EE,$00  ; seg 100  curve=-6                          #0:$81@-18 #1:$A7@+20 #2:$81@-18
        fcb   $7A,$00,$03,$03,$EE,$00,$EE,$00  ; seg 101  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$90,$90,$00,$14,$00,$EC  ; seg 102  curve=-6                          #1:$A7@+20 #3:$A7@-20
        fcb   $7A,$00,$09,$90,$EC,$00,$00,$EC  ; seg 103  curve=-6                          #0:$A7@-20 #3:$A7@-20
        fcb   $00,$00,$09,$90,$EC,$00,$00,$EC  ; seg 104                                    #0:$A7@-20 #3:$A7@-20
        fcb   $00,$00,$90,$90,$00,$14,$00,$14  ; seg 105                                    #1:$A7@+20 #3:$A7@+20
        fcb   $00,$00,$03,$03,$EE,$00,$EE,$00  ; seg 106                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$03,$93,$EE,$00,$EE,$14  ; seg 107                                    #0:$81@-18 #2:$81@-18 #3:$A7@+20
        fcb   $7C,$00,$03,$00,$EE,$00,$00,$00  ; seg 108  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$03,$00,$EE,$00,$00,$00  ; seg 109  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$0A,$0A,$12,$00,$12,$00  ; seg 110  curve=-4                          #0:$80@+18 #2:$80@+18
        fcb   $7C,$00,$0A,$0A,$12,$00,$12,$00  ; seg 111  curve=-4                          #0:$80@+18 #2:$80@+18
        fcb   $04,$00,$0A,$00,$12,$00,$00,$00  ; seg 112  curve=+4                          #0:$80@+18
        fcb   $04,$00,$0A,$00,$12,$00,$00,$00  ; seg 113  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 114  curve=+4
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 115  curve=+4
        fcb   $00,$00,$04,$04,$EC,$00,$EC,$00  ; seg 116                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$04,$04,$EC,$00,$EC,$00  ; seg 117                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$04,$04,$EC,$00,$EC,$00  ; seg 118                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$00,$04,$04,$EC,$00,$EC,$00  ; seg 119                                    #0:$85@-20 #2:$85@-20
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 120            pitch=-3
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 121            pitch=-3
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 122            pitch=-3
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 123            pitch=-3
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 124
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 125
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 126
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 127
        fcb   $00,$06,$0B,$BB,$0A,$00,$F4,$0A  ; seg 128            pitch=+6                #0:$A3@+10 #2:$A3@-12 #3:$A3@+10
        fcb   $00,$06,$BB,$B0,$0E,$08,$00,$F4  ; seg 129            pitch=+6                #0:$A3@+14 #1:$A3@+8 #3:$A3@-12
        fcb   $00,$04,$BB,$BB,$0C,$F4,$F8,$08  ; seg 130            pitch=+4                #0:$A3@+12 #1:$A3@-12 #2:$A3@-8 #3:$A3@+8
        fcb   $00,$04,$B0,$BB,$00,$F2,$F8,$FE  ; seg 131            pitch=+4                #1:$A3@-14 #2:$A3@-8 #3:$A3@-2
        fcb   $00,$7F,$06,$00,$14,$00,$00,$00  ; seg 132            pitch=-1                #0:$8B@+20
        fcb   $00,$7F,$77,$00,$14,$EC,$00,$00  ; seg 133            pitch=-1                #0:$89@+20 #1:$89@-20
        fcb   $00,$7F,$06,$08,$EC,$00,$EC,$00  ; seg 134            pitch=-1                #0:$8B@-20 #2:$8A@-20
        fcb   $00,$7F,$70,$60,$00,$EC,$00,$14  ; seg 135            pitch=-1                #1:$89@-20 #3:$8B@+20
        fcb   $00,$7F,$70,$80,$00,$14,$00,$EC  ; seg 136            pitch=-1                #1:$89@+20 #3:$8A@-20
        fcb   $00,$7F,$06,$07,$14,$00,$14,$00  ; seg 137            pitch=-1                #0:$8B@+20 #2:$89@+20
        fcb   $00,$7F,$80,$60,$00,$EC,$00,$EC  ; seg 138            pitch=-1                #1:$8A@-20 #3:$8B@-20
        fcb   $00,$7F,$07,$07,$14,$00,$EC,$00  ; seg 139            pitch=-1                #0:$89@+20 #2:$89@-20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 140
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 141
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 142
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 143
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 144
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 145
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 146
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 147
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 148                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 149
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 150
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 151
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 152                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 153                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 154                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 155                                    #0:$83@+18 #2:$83@+18

Circuit_18_hard_1_segment_cache
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
        fcb   $F0,$00,$F6,$0A  ; seg  21  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  22  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  23  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  24  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EA,$00,$F6,$0A  ; seg  25  yaw= -22 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  26  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DE,$00,$F6,$0A  ; seg  27  yaw= -34 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  28  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D2,$00,$F7,$0A  ; seg  29  yaw= -46 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $CC,$00,$F8,$0A  ; seg  30  yaw= -52 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $C6,$00,$F9,$0A  ; seg  31  yaw= -58 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $C0,$00,$FA,$0A  ; seg  32  yaw= -64 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $C0,$00,$FB,$0A  ; seg  33  yaw= -64 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $C0,$00,$FC,$0A  ; seg  34  yaw= -64 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $C0,$00,$FD,$0A  ; seg  35  yaw= -64 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $C0,$00,$FE,$0A  ; seg  36  yaw= -64 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $C0,$FE,$FF,$0A  ; seg  37  yaw= -64 pitch=  -2 min_lat=  -1 max_lat= +10
        fcb   $C0,$FC,$00,$0A  ; seg  38  yaw= -64 pitch=  -4 min_lat=  +0 max_lat= +10
        fcb   $C0,$FF,$01,$0A  ; seg  39  yaw= -64 pitch=  -1 min_lat=  +1 max_lat= +10
        fcb   $C0,$02,$02,$0A  ; seg  40  yaw= -64 pitch=  +2 min_lat=  +2 max_lat= +10
        fcb   $C0,$02,$03,$09  ; seg  41  yaw= -64 pitch=  +2 min_lat=  +3 max_lat=  +9
        fcb   $C0,$02,$04,$08  ; seg  42  yaw= -64 pitch=  +2 min_lat=  +4 max_lat=  +8
        fcb   $C0,$FF,$05,$07  ; seg  43  yaw= -64 pitch=  -1 min_lat=  +5 max_lat=  +7
        fcb   $C0,$FC,$06,$06  ; seg  44  yaw= -64 pitch=  -4 min_lat=  +6 max_lat=  +6
        fcb   $C0,$FE,$06,$05  ; seg  45  yaw= -64 pitch=  -2 min_lat=  +6 max_lat=  +5
        fcb   $C0,$00,$03,$04  ; seg  46  yaw= -64 pitch=  +0 min_lat=  +3 max_lat=  +4
        fcb   $C0,$FE,$04,$03  ; seg  47  yaw= -64 pitch=  -2 min_lat=  +4 max_lat=  +3
        fcb   $C0,$FC,$F6,$02  ; seg  48  yaw= -64 pitch=  -4 min_lat= -10 max_lat=  +2
        fcb   $C0,$FD,$F6,$01  ; seg  49  yaw= -64 pitch=  -3 min_lat= -10 max_lat=  +1
        fcb   $C0,$FE,$F6,$00  ; seg  50  yaw= -64 pitch=  -2 min_lat= -10 max_lat=  +0
        fcb   $C0,$00,$F6,$FF  ; seg  51  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $C0,$02,$F6,$FE  ; seg  52  yaw= -64 pitch=  +2 min_lat= -10 max_lat=  -2
        fcb   $C0,$FF,$F6,$FD  ; seg  53  yaw= -64 pitch=  -1 min_lat= -10 max_lat=  -3
        fcb   $C0,$FC,$F6,$FC  ; seg  54  yaw= -64 pitch=  -4 min_lat= -10 max_lat=  -4
        fcb   $C0,$FF,$F6,$FB  ; seg  55  yaw= -64 pitch=  -1 min_lat= -10 max_lat=  -5
        fcb   $C0,$02,$F6,$FA  ; seg  56  yaw= -64 pitch=  +2 min_lat= -10 max_lat=  -6
        fcb   $C0,$01,$F6,$FA  ; seg  57  yaw= -64 pitch=  +1 min_lat= -10 max_lat=  -6
        fcb   $C0,$00,$F6,$FC  ; seg  58  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $C0,$00,$F6,$FC  ; seg  59  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $C0,$00,$F6,$00  ; seg  60  yaw= -64 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $C0,$02,$F7,$FF  ; seg  61  yaw= -64 pitch=  +2 min_lat=  -9 max_lat=  -1
        fcb   $C0,$04,$F8,$FE  ; seg  62  yaw= -64 pitch=  +4 min_lat=  -8 max_lat=  -2
        fcb   $C0,$03,$F9,$FD  ; seg  63  yaw= -64 pitch=  +3 min_lat=  -7 max_lat=  -3
        fcb   $C0,$02,$FA,$FC  ; seg  64  yaw= -64 pitch=  +2 min_lat=  -6 max_lat=  -4
        fcb   $C0,$04,$FB,$FB  ; seg  65  yaw= -64 pitch=  +4 min_lat=  -5 max_lat=  -5
        fcb   $C0,$06,$FC,$FA  ; seg  66  yaw= -64 pitch=  +6 min_lat=  -4 max_lat=  -6
        fcb   $C0,$03,$FD,$FD  ; seg  67  yaw= -64 pitch=  +3 min_lat=  -3 max_lat=  -3
        fcb   $C0,$00,$FE,$FC  ; seg  68  yaw= -64 pitch=  +0 min_lat=  -2 max_lat=  -4
        fcb   $C0,$02,$FF,$FE  ; seg  69  yaw= -64 pitch=  +2 min_lat=  -1 max_lat=  -2
        fcb   $C0,$04,$00,$0A  ; seg  70  yaw= -64 pitch=  +4 min_lat=  +0 max_lat= +10
        fcb   $C0,$03,$01,$0A  ; seg  71  yaw= -64 pitch=  +3 min_lat=  +1 max_lat= +10
        fcb   $C0,$02,$02,$0A  ; seg  72  yaw= -64 pitch=  +2 min_lat=  +2 max_lat= +10
        fcb   $C0,$04,$03,$0A  ; seg  73  yaw= -64 pitch=  +4 min_lat=  +3 max_lat= +10
        fcb   $C0,$06,$04,$0A  ; seg  74  yaw= -64 pitch=  +6 min_lat=  +4 max_lat= +10
        fcb   $C0,$03,$05,$0A  ; seg  75  yaw= -64 pitch=  +3 min_lat=  +5 max_lat= +10
        fcb   $C0,$00,$06,$0A  ; seg  76  yaw= -64 pitch=  +0 min_lat=  +6 max_lat= +10
        fcb   $C0,$00,$04,$0A  ; seg  77  yaw= -64 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  78  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  79  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  80  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BC,$00,$F6,$0A  ; seg  81  yaw= -68 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B8,$00,$F6,$0A  ; seg  82  yaw= -72 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  83  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  84  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  85  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  86  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  87  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  88  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  89  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  90  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  91  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  92  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  93  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  94  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  95  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B0,$00,$F6,$0A  ; seg  96  yaw= -80 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AA,$00,$F6,$0A  ; seg  97  yaw= -86 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg  98  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9E,$00,$F6,$0A  ; seg  99  yaw= -98 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 100  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg 101  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 102  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg 103  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 104  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 105  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 106  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 107  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 108  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $7C,$00,$F6,$0A  ; seg 109  yaw=+124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $78,$00,$F6,$0A  ; seg 110  yaw=+120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $74,$00,$F6,$0A  ; seg 111  yaw=+116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $70,$00,$F6,$0A  ; seg 112  yaw=+112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $74,$00,$F6,$0A  ; seg 113  yaw=+116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $78,$00,$F6,$0A  ; seg 114  yaw=+120 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $7C,$00,$F6,$0A  ; seg 115  yaw=+124 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F7,$0A  ; seg 116  yaw=-128 pitch=  +0 min_lat=  -9 max_lat= +10
        fcb   $80,$00,$F8,$0A  ; seg 117  yaw=-128 pitch=  +0 min_lat=  -8 max_lat= +10
        fcb   $80,$00,$F9,$0A  ; seg 118  yaw=-128 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $80,$00,$FA,$0A  ; seg 119  yaw=-128 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $80,$00,$FB,$09  ; seg 120  yaw=-128 pitch=  +0 min_lat=  -5 max_lat=  +9
        fcb   $80,$FD,$FC,$08  ; seg 121  yaw=-128 pitch=  -3 min_lat=  -4 max_lat=  +8
        fcb   $80,$FA,$FD,$07  ; seg 122  yaw=-128 pitch=  -6 min_lat=  -3 max_lat=  +7
        fcb   $80,$F7,$FE,$06  ; seg 123  yaw=-128 pitch=  -9 min_lat=  -2 max_lat=  +6
        fcb   $80,$F4,$FF,$05  ; seg 124  yaw=-128 pitch= -12 min_lat=  -1 max_lat=  +5
        fcb   $80,$F4,$00,$04  ; seg 125  yaw=-128 pitch= -12 min_lat=  +0 max_lat=  +4
        fcb   $80,$F4,$01,$03  ; seg 126  yaw=-128 pitch= -12 min_lat=  +1 max_lat=  +3
        fcb   $80,$F4,$02,$02  ; seg 127  yaw=-128 pitch= -12 min_lat=  +2 max_lat=  +2
        fcb   $80,$F4,$03,$01  ; seg 128  yaw=-128 pitch= -12 min_lat=  +3 max_lat=  +1
        fcb   $80,$FA,$04,$00  ; seg 129  yaw=-128 pitch=  -6 min_lat=  +4 max_lat=  +0
        fcb   $80,$00,$05,$00  ; seg 130  yaw=-128 pitch=  +0 min_lat=  +5 max_lat=  +0
        fcb   $80,$04,$06,$0A  ; seg 131  yaw=-128 pitch=  +4 min_lat=  +6 max_lat= +10
        fcb   $80,$08,$F6,$0A  ; seg 132  yaw=-128 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $80,$07,$F6,$0A  ; seg 133  yaw=-128 pitch=  +7 min_lat= -10 max_lat= +10
        fcb   $80,$06,$F6,$0A  ; seg 134  yaw=-128 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $80,$05,$F6,$0A  ; seg 135  yaw=-128 pitch=  +5 min_lat= -10 max_lat= +10
        fcb   $80,$04,$F6,$0A  ; seg 136  yaw=-128 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $80,$03,$F6,$0A  ; seg 137  yaw=-128 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 138  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 139  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 140  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 141  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 142  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 143  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 144  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 145  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 146  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 147  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 148 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 149 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 150 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 151 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 152 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 153 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 154 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 155 (wraparound de seg 7)
