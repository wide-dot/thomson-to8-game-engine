* ======================================================================
* Circuit_10_medium_3 — N=188 segments (format compact 8 oct/seg)
* Source       : 10_medium_3.bin (extrait de FILE30)
*
* Pays         : URUGUAY
* Lieu         : mercedes
* Description  : some sharp bends
* Hazards      : rocks on downhill section
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000090 01:#6C9048 02:#246C24 03:#48486C 04:#484848 05:#B40000 06:#242424 07:#242424
*   08:#244824 09:#D8D8D8 10:#242424 11:#FCFCFC 12:#900048 13:#900048 14:#90006C 15:#90006C
*   16:#900090 17:#902490 18:#9024B4 19:#9048B4 20:#9048D8 21:#906CD8 22:#906CFC 23:#9090FC
*   24:#9090FC 25:#90B4FC 26:#90B4FC 27:#90D8FC
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
* Taille totale : 2370 oct (nb_segments 2 + LUT 16 + segments 1568 + cache 784).
* ======================================================================

Circuit_10_medium_3_nb_segments
        fdb   188

Circuit_10_medium_3_sprite_lut
        fcb   $00,$82,$83,$8C,$8A,$81,$A3,$80,$95,$90,$9A,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_10_medium_3_segments
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
        fcb   $00,$00,$33,$44,$EC,$E8,$E0,$D0  ; seg  16                                    #0:$8C@-20 #1:$8C@-24 #2:$8A@-32 #3:$8A@-48
        fcb   $00,$00,$43,$43,$D0,$EC,$D8,$E8  ; seg  17                                    #0:$8C@-48 #1:$8A@-20 #2:$8C@-40 #3:$8A@-24
        fcb   $00,$00,$43,$43,$E0,$24,$1C,$CC  ; seg  18                                    #0:$8C@-32 #1:$8A@+36 #2:$8C@+28 #3:$8A@-52
        fcb   $00,$00,$33,$44,$D8,$E0,$E0,$E4  ; seg  19                                    #0:$8C@-40 #1:$8C@-32 #2:$8A@-32 #3:$8A@-28
        fcb   $00,$00,$30,$00,$00,$D0,$00,$00  ; seg  20                                    #1:$8C@-48
        fcb   $00,$00,$30,$00,$00,$20,$00,$00  ; seg  21                                    #1:$8C@+32
        fcb   $00,$00,$05,$65,$EE,$00,$EE,$20  ; seg  22                                    #0:$81@-18 #2:$81@-18 #3:$A3@+32
        fcb   $00,$00,$05,$05,$EE,$00,$EE,$00  ; seg  23                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$45,$00,$EE,$14,$00,$00  ; seg  24  curve=-4                          #0:$81@-18 #1:$8A@+20
        fcb   $7C,$00,$35,$60,$EE,$1C,$00,$30  ; seg  25  curve=-4                          #0:$81@-18 #1:$8C@+28 #3:$A3@+48
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg  26  curve=-4
        fcb   $7C,$00,$00,$60,$00,$00,$00,$E4  ; seg  27  curve=-4                          #3:$A3@-28
        fcb   $00,$00,$40,$00,$00,$18,$00,$00  ; seg  28                                    #1:$8A@+24
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  29
        fcb   $00,$00,$77,$77,$12,$12,$12,$12  ; seg  30                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $00,$00,$77,$77,$12,$12,$12,$12  ; seg  31                                    #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  32  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$67,$12,$00,$12,$D0  ; seg  33  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$A3@-48
        fcb   $06,$00,$00,$00,$00,$00,$00,$00  ; seg  34  curve=+6
        fcb   $06,$00,$40,$00,$00,$E4,$00,$00  ; seg  35  curve=+6                          #1:$8A@-28
        fcb   $00,$00,$40,$60,$00,$EC,$00,$20  ; seg  36                                    #1:$8A@-20 #3:$A3@+32
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  37
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  38                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  39                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  40  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$65,$EE,$00,$EE,$24  ; seg  41  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A3@+36
        fcb   $7A,$00,$30,$00,$00,$E0,$00,$00  ; seg  42  curve=-6                          #1:$8C@-32
        fcb   $7A,$00,$30,$00,$00,$D8,$00,$00  ; seg  43  curve=-6                          #1:$8C@-40
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  44
        fcb   $00,$00,$40,$00,$00,$20,$00,$00  ; seg  45                                    #1:$8A@+32
        fcb   $00,$00,$05,$65,$EE,$00,$EE,$20  ; seg  46                                    #0:$81@-18 #2:$81@-18 #3:$A3@+32
        fcb   $00,$00,$05,$05,$EE,$00,$EE,$00  ; seg  47                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg  48  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg  49  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$35,$60,$EE,$14,$00,$E0  ; seg  50  curve=-4                          #0:$81@-18 #1:$8C@+20 #3:$A3@-32
        fcb   $7C,$00,$45,$60,$EE,$18,$00,$24  ; seg  51  curve=-4                          #0:$81@-18 #1:$8A@+24 #3:$A3@+36
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg  52  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg  53  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$60,$EE,$00,$00,$28  ; seg  54  curve=-4                          #0:$81@-18 #3:$A3@+40
        fcb   $7C,$00,$35,$00,$EE,$20,$00,$00  ; seg  55  curve=-4                          #0:$81@-18 #1:$8C@+32
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg  56  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$05,$00,$EE,$00,$00,$00  ; seg  57  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$40,$60,$00,$1C,$00,$30  ; seg  58  curve=-4                          #1:$8A@+28 #3:$A3@+48
        fcb   $7C,$00,$30,$60,$00,$20,$00,$D0  ; seg  59  curve=-4                          #1:$8C@+32 #3:$A3@-48
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  60
        fcb   $00,$00,$40,$00,$00,$14,$00,$00  ; seg  61                                    #1:$8A@+20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  62
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  63
        fcb   $00,$00,$30,$00,$00,$20,$00,$00  ; seg  64                                    #1:$8C@+32
        fcb   $00,$00,$40,$00,$00,$E0,$00,$00  ; seg  65                                    #1:$8A@-32
        fcb   $00,$00,$00,$60,$00,$00,$00,$D8  ; seg  66                                    #3:$A3@-40
        fcb   $00,$00,$30,$00,$00,$18,$00,$00  ; seg  67                                    #1:$8C@+24
        fcb   $00,$00,$40,$00,$00,$14,$00,$00  ; seg  68                                    #1:$8A@+20
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg  69
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  70                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg  71                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  72  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$35,$05,$EE,$1C,$EE,$00  ; seg  73  curve=-6                          #0:$81@-18 #1:$8C@+28 #2:$81@-18
        fcb   $7A,$00,$05,$65,$EE,$00,$EE,$DC  ; seg  74  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A3@-36
        fcb   $7A,$00,$45,$65,$EE,$1C,$EE,$24  ; seg  75  curve=-6                          #0:$81@-18 #1:$8A@+28 #2:$81@-18 #3:$A3@+36
        fcb   $7A,$00,$05,$65,$EE,$00,$EE,$18  ; seg  76  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$A3@+24
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg  77  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$77,$77,$12,$12,$12,$12  ; seg  78  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7A,$00,$77,$77,$12,$12,$12,$12  ; seg  79  curve=-6                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  80  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  81  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  82  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  83  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  84  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  85  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$00,$00,$00,$00,$00,$00  ; seg  86  curve=+6
        fcb   $06,$00,$00,$00,$00,$00,$00,$00  ; seg  87  curve=+6
        fcb   $00,$00,$08,$08,$EE,$00,$24,$00  ; seg  88                                    #0:$95@-18 #2:$95@+36
        fcb   $00,$00,$08,$00,$12,$00,$00,$00  ; seg  89                                    #0:$95@+18
        fcb   $00,$00,$08,$00,$12,$00,$00,$00  ; seg  90                                    #0:$95@+18
        fcb   $00,$00,$08,$08,$12,$00,$DC,$00  ; seg  91                                    #0:$95@+18 #2:$95@-36
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg  92            pitch=+1
        fcb   $00,$01,$08,$00,$EE,$00,$00,$00  ; seg  93            pitch=+1                #0:$95@-18
        fcb   $00,$01,$08,$08,$EE,$00,$1C,$00  ; seg  94            pitch=+1                #0:$95@-18 #2:$95@+28
        fcb   $00,$01,$08,$00,$EE,$00,$00,$00  ; seg  95            pitch=+1                #0:$95@-18
        fcb   $00,$7E,$08,$00,$12,$00,$00,$00  ; seg  96            pitch=-2                #0:$95@+18
        fcb   $00,$7E,$08,$00,$12,$00,$00,$00  ; seg  97            pitch=-2                #0:$95@+18
        fcb   $00,$02,$00,$08,$00,$00,$E0,$00  ; seg  98            pitch=+2                #2:$95@-32
        fcb   $00,$02,$08,$00,$12,$00,$00,$00  ; seg  99            pitch=+2                #0:$95@+18
        fcb   $00,$7D,$08,$00,$EE,$00,$00,$00  ; seg 100            pitch=-3                #0:$95@-18
        fcb   $00,$7D,$08,$08,$EE,$00,$20,$00  ; seg 101            pitch=-3                #0:$95@-18 #2:$95@+32
        fcb   $00,$03,$08,$00,$EE,$00,$00,$00  ; seg 102            pitch=+3                #0:$95@-18
        fcb   $00,$03,$08,$00,$12,$00,$00,$00  ; seg 103            pitch=+3                #0:$95@+18
        fcb   $00,$7F,$08,$00,$12,$00,$00,$00  ; seg 104            pitch=-1                #0:$95@+18
        fcb   $00,$7F,$00,$08,$00,$00,$D0,$00  ; seg 105            pitch=-1                #2:$95@-48
        fcb   $00,$01,$08,$00,$12,$00,$00,$00  ; seg 106            pitch=+1                #0:$95@+18
        fcb   $00,$01,$00,$00,$00,$00,$00,$00  ; seg 107            pitch=+1
        fcb   $00,$00,$08,$00,$12,$00,$00,$00  ; seg 108                                    #0:$95@+18
        fcb   $00,$00,$08,$08,$EE,$00,$20,$00  ; seg 109                                    #0:$95@-18 #2:$95@+32
        fcb   $00,$02,$08,$00,$EE,$00,$00,$00  ; seg 110            pitch=+2                #0:$95@-18
        fcb   $00,$02,$08,$00,$12,$00,$00,$00  ; seg 111            pitch=+2                #0:$95@+18
        fcb   $00,$7E,$08,$00,$12,$00,$00,$00  ; seg 112            pitch=-2                #0:$95@+18
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg 113            pitch=-2
        fcb   $00,$00,$08,$08,$EE,$00,$28,$00  ; seg 114                                    #0:$95@-18 #2:$95@+40
        fcb   $00,$00,$08,$00,$EE,$00,$00,$00  ; seg 115                                    #0:$95@-18
        fcb   $00,$7F,$08,$00,$12,$00,$00,$00  ; seg 116            pitch=-1                #0:$95@+18
        fcb   $00,$7F,$00,$00,$00,$00,$00,$00  ; seg 117            pitch=-1
        fcb   $00,$7F,$08,$08,$EE,$00,$30,$00  ; seg 118            pitch=-1                #0:$95@-18 #2:$95@+48
        fcb   $00,$7F,$08,$00,$12,$00,$00,$00  ; seg 119            pitch=-1                #0:$95@+18
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 120
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 121
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg 122                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $00,$00,$55,$55,$EE,$EE,$EE,$EE  ; seg 123                                    #0:$81@-18 #1:$81@-18 #2:$81@-18 #3:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg 124  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$05,$EE,$00,$EE,$00  ; seg 125  curve=-6                          #0:$81@-18 #2:$81@-18
        fcb   $7A,$00,$05,$00,$EE,$00,$00,$00  ; seg 126  curve=-6                          #0:$81@-18
        fcb   $7A,$00,$05,$00,$EE,$00,$00,$00  ; seg 127  curve=-6                          #0:$81@-18
        fcb   $7C,$00,$35,$90,$EE,$E0,$00,$20  ; seg 128  curve=-4                          #0:$81@-18 #1:$8C@-32 #3:$90@+32
        fcb   $7C,$00,$05,$90,$EE,$00,$00,$E0  ; seg 129  curve=-4                          #0:$81@-18 #3:$90@-32
        fcb   $7C,$00,$05,$95,$EE,$00,$EE,$DC  ; seg 130  curve=-4                          #0:$81@-18 #2:$81@-18 #3:$90@-36
        fcb   $7C,$00,$35,$95,$EE,$CC,$EE,$30  ; seg 131  curve=-4                          #0:$81@-18 #1:$8C@-52 #2:$81@-18 #3:$90@+48
        fcb   $7A,$00,$05,$95,$EE,$00,$EE,$14  ; seg 132  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$90@+20
        fcb   $7A,$00,$05,$95,$EE,$00,$EE,$28  ; seg 133  curve=-6                          #0:$81@-18 #2:$81@-18 #3:$90@+40
        fcb   $7A,$00,$40,$90,$00,$20,$00,$1C  ; seg 134  curve=-6                          #1:$8A@+32 #3:$90@+28
        fcb   $7A,$00,$00,$90,$00,$00,$00,$20  ; seg 135  curve=-6                          #3:$90@+32
        fcb   $00,$00,$40,$90,$00,$14,$00,$E0  ; seg 136                                    #1:$8A@+20 #3:$90@-32
        fcb   $00,$00,$30,$90,$00,$30,$00,$D0  ; seg 137                                    #1:$8C@+48 #3:$90@-48
        fcb   $00,$00,$00,$90,$00,$00,$00,$EC  ; seg 138                                    #3:$90@-20
        fcb   $00,$00,$00,$90,$00,$00,$00,$28  ; seg 139                                    #3:$90@+40
        fcb   $00,$7E,$30,$90,$00,$2C,$00,$14  ; seg 140            pitch=-2                #1:$8C@+44 #3:$90@+20
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg 141            pitch=-2
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 142
        fcb   $00,$00,$AA,$AA,$EE,$12,$EE,$12  ; seg 143                                    #0:$9A@-18 #1:$9A@+18 #2:$9A@-18 #3:$9A@+18
        fcb   $00,$02,$AA,$AA,$EE,$12,$EE,$12  ; seg 144            pitch=+2                #0:$9A@-18 #1:$9A@+18 #2:$9A@-18 #3:$9A@+18
        fcb   $00,$02,$00,$00,$00,$00,$00,$00  ; seg 145            pitch=+2
        fcb   $00,$7E,$44,$43,$F2,$0A,$F4,$0E  ; seg 146            pitch=-2                #0:$8A@-14 #1:$8A@+10 #2:$8C@-12 #3:$8A@+14
        fcb   $00,$7E,$33,$44,$F6,$0C,$F0,$0A  ; seg 147            pitch=-2                #0:$8C@-10 #1:$8C@+12 #2:$8A@-16 #3:$8A@+10
        fcb   $00,$00,$00,$90,$00,$00,$00,$38  ; seg 148                                    #3:$90@+56
        fcb   $00,$00,$30,$90,$00,$1C,$00,$24  ; seg 149                                    #1:$8C@+28 #3:$90@+36
        fcb   $00,$7D,$00,$90,$00,$00,$00,$DC  ; seg 150            pitch=-3                #3:$90@-36
        fcb   $00,$7D,$0A,$0A,$12,$00,$12,$00  ; seg 151            pitch=-3                #0:$9A@+18 #2:$9A@+18
        fcb   $00,$02,$0A,$0A,$12,$00,$12,$00  ; seg 152            pitch=+2                #0:$9A@+18 #2:$9A@+18
        fcb   $00,$02,$00,$90,$00,$00,$00,$20  ; seg 153            pitch=+2                #3:$90@+32
        fcb   $00,$02,$34,$43,$0A,$06,$02,$0A  ; seg 154            pitch=+2                #0:$8A@+10 #1:$8C@+6 #2:$8C@+2 #3:$8A@+10
        fcb   $00,$02,$44,$43,$08,$04,$02,$06  ; seg 155            pitch=+2                #0:$8A@+8 #1:$8A@+4 #2:$8C@+2 #3:$8A@+6
        fcb   $00,$7D,$00,$90,$00,$00,$00,$1C  ; seg 156            pitch=-3                #3:$90@+28
        fcb   $00,$7D,$00,$00,$00,$00,$00,$00  ; seg 157            pitch=-3
        fcb   $00,$03,$30,$00,$00,$1C,$00,$00  ; seg 158            pitch=+3                #1:$8C@+28
        fcb   $00,$03,$4A,$9A,$EE,$24,$EE,$30  ; seg 159            pitch=+3                #0:$9A@-18 #1:$8A@+36 #2:$9A@-18 #3:$90@+48
        fcb   $00,$02,$0A,$0A,$EE,$00,$EE,$00  ; seg 160            pitch=+2                #0:$9A@-18 #2:$9A@-18
        fcb   $00,$02,$40,$90,$00,$DC,$00,$20  ; seg 161            pitch=+2                #1:$8A@-36 #3:$90@+32
        fcb   $00,$7E,$34,$44,$F4,$F6,$F2,$FE  ; seg 162            pitch=-2                #0:$8A@-12 #1:$8C@-10 #2:$8A@-14 #3:$8A@-2
        fcb   $00,$7E,$44,$43,$FC,$F8,$F6,$FA  ; seg 163            pitch=-2                #0:$8A@-4 #1:$8A@-8 #2:$8C@-10 #3:$8A@-6
        fcb   $00,$00,$30,$90,$00,$E0,$00,$E4  ; seg 164                                    #1:$8C@-32 #3:$90@-28
        fcb   $00,$00,$40,$90,$00,$1C,$00,$20  ; seg 165                                    #1:$8A@+28 #3:$90@+32
        fcb   $00,$7E,$00,$00,$00,$00,$00,$00  ; seg 166            pitch=-2
        fcb   $00,$7E,$0A,$9A,$12,$00,$12,$DC  ; seg 167            pitch=-2                #0:$9A@+18 #2:$9A@+18 #3:$90@-36
        fcb   $00,$01,$0A,$9A,$12,$00,$12,$C8  ; seg 168            pitch=+1                #0:$9A@+18 #2:$9A@+18 #3:$90@-56
        fcb   $00,$01,$90,$00,$00,$E0,$00,$00  ; seg 169            pitch=+1                #1:$90@-32
        fcb   $00,$02,$44,$43,$08,$04,$02,$06  ; seg 170            pitch=+2                #0:$8A@+8 #1:$8A@+4 #2:$8C@+2 #3:$8A@+6
        fcb   $00,$02,$34,$43,$0A,$06,$02,$0A  ; seg 171            pitch=+2                #0:$8A@+10 #1:$8C@+6 #2:$8C@+2 #3:$8A@+10
        fcb   $00,$00,$90,$90,$00,$14,$00,$CC  ; seg 172                                    #1:$90@+20 #3:$90@-52
        fcb   $00,$00,$90,$90,$00,$DC,$00,$D0  ; seg 173                                    #1:$90@-36 #3:$90@-48
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 174
        fcb   $00,$00,$AA,$AA,$12,$EE,$12,$EE  ; seg 175                                    #0:$9A@+18 #1:$9A@-18 #2:$9A@+18 #3:$9A@-18
        fcb   $00,$00,$AA,$AA,$12,$EE,$12,$EE  ; seg 176                                    #0:$9A@+18 #1:$9A@-18 #2:$9A@+18 #3:$9A@-18
        fcb   $00,$00,$99,$99,$18,$14,$1C,$20  ; seg 177                                    #0:$90@+24 #1:$90@+20 #2:$90@+28 #3:$90@+32
        fcb   $00,$00,$44,$44,$F8,$0A,$F6,$08  ; seg 178                                    #0:$8A@-8 #1:$8A@+10 #2:$8A@-10 #3:$8A@+8
        fcb   $00,$00,$34,$33,$F4,$0E,$F2,$0C  ; seg 179                                    #0:$8A@-12 #1:$8C@+14 #2:$8C@-14 #3:$8C@+12
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 180
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 181
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 182
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 183
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 184
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 185
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 186
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 187
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $00,$00,$01,$00,$00,$00,$00,$00  ; seg 188                                    #0:$82@+0
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 189
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 190
        fcb   $00,$00,$00,$00,$00,$00,$00,$00  ; seg 191
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 192                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 193                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 194                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$02,$02,$12,$00,$12,$00  ; seg 195                                    #0:$83@+18 #2:$83@+18

Circuit_10_medium_3_segment_cache
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
        fcb   $FC,$00,$F6,$0A  ; seg  25  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F8,$00,$F6,$0A  ; seg  26  yaw=  -8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F4,$00,$F6,$0A  ; seg  27  yaw= -12 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  28  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  29  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  30  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  31  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  32  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F6,$00,$F6,$0A  ; seg  33  yaw= -10 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  34  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $02,$00,$F6,$0A  ; seg  35  yaw=  +2 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  36  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  37  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  38  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  39  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $08,$00,$F6,$0A  ; seg  40  yaw=  +8 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $02,$00,$F6,$0A  ; seg  41  yaw=  +2 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $FC,$00,$F6,$0A  ; seg  42  yaw=  -4 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F6,$00,$F6,$0A  ; seg  43  yaw= -10 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  44  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  45  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  46  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  47  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $F0,$00,$F6,$0A  ; seg  48  yaw= -16 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $EC,$00,$F6,$0A  ; seg  49  yaw= -20 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E8,$00,$F6,$0A  ; seg  50  yaw= -24 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E4,$00,$F6,$0A  ; seg  51  yaw= -28 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $E0,$00,$F6,$0A  ; seg  52  yaw= -32 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $DC,$00,$F6,$0A  ; seg  53  yaw= -36 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D8,$00,$F6,$0A  ; seg  54  yaw= -40 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D4,$00,$F6,$0A  ; seg  55  yaw= -44 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $D0,$00,$F6,$0A  ; seg  56  yaw= -48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $CC,$00,$F6,$0A  ; seg  57  yaw= -52 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C8,$00,$F6,$0A  ; seg  58  yaw= -56 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C4,$00,$F6,$0A  ; seg  59  yaw= -60 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  60  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  61  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  62  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  63  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  64  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  65  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  66  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  67  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  68  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  69  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  70  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  71  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  72  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg  73  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  74  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$0A  ; seg  75  yaw= -82 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  76  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A2,$00,$F6,$0A  ; seg  77  yaw= -94 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg  78  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $96,$00,$F6,$0A  ; seg  79  yaw=-106 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $90,$00,$F6,$0A  ; seg  80  yaw=-112 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $96,$00,$F6,$0A  ; seg  81  yaw=-106 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg  82  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A2,$00,$F6,$0A  ; seg  83  yaw= -94 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg  84  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$0A  ; seg  85  yaw= -82 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg  86  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg  87  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  88  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  89  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  90  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  91  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  92  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg  93  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  94  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg  95  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg  96  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  97  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg  98  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg  99  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 100  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 101  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$FE,$F6,$0A  ; seg 102  yaw= -64 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 103  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 104  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 105  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 106  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 107  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 108  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 109  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 110  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 111  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$08,$F6,$0A  ; seg 112  yaw= -64 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $C0,$06,$F6,$0A  ; seg 113  yaw= -64 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 114  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 115  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$04,$F6,$0A  ; seg 116  yaw= -64 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $C0,$03,$F6,$0A  ; seg 117  yaw= -64 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $C0,$02,$F6,$0A  ; seg 118  yaw= -64 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $C0,$01,$F6,$0A  ; seg 119  yaw= -64 pitch=  +1 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 120  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 121  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 122  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 123  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $C0,$00,$F6,$0A  ; seg 124  yaw= -64 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $BA,$00,$F6,$0A  ; seg 125  yaw= -70 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $B4,$00,$F6,$0A  ; seg 126  yaw= -76 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $AE,$00,$F6,$0A  ; seg 127  yaw= -82 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A8,$00,$F6,$0A  ; seg 128  yaw= -88 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A4,$00,$F6,$0A  ; seg 129  yaw= -92 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $A0,$00,$F6,$0A  ; seg 130  yaw= -96 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $9C,$00,$F6,$0A  ; seg 131  yaw=-100 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $98,$00,$F6,$0A  ; seg 132  yaw=-104 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $92,$00,$F6,$0A  ; seg 133  yaw=-110 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $8C,$00,$F6,$0A  ; seg 134  yaw=-116 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $86,$00,$F6,$0A  ; seg 135  yaw=-122 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 136  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 137  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 138  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$09  ; seg 139  yaw=-128 pitch=  +0 min_lat= -10 max_lat=  +9
        fcb   $80,$00,$F7,$08  ; seg 140  yaw=-128 pitch=  +0 min_lat=  -9 max_lat=  +8
        fcb   $80,$FE,$F8,$07  ; seg 141  yaw=-128 pitch=  -2 min_lat=  -8 max_lat=  +7
        fcb   $80,$FC,$F9,$06  ; seg 142  yaw=-128 pitch=  -4 min_lat=  -7 max_lat=  +6
        fcb   $80,$FC,$FA,$05  ; seg 143  yaw=-128 pitch=  -4 min_lat=  -6 max_lat=  +5
        fcb   $80,$FC,$FB,$04  ; seg 144  yaw=-128 pitch=  -4 min_lat=  -5 max_lat=  +4
        fcb   $80,$FE,$FC,$03  ; seg 145  yaw=-128 pitch=  -2 min_lat=  -4 max_lat=  +3
        fcb   $80,$00,$FD,$02  ; seg 146  yaw=-128 pitch=  +0 min_lat=  -3 max_lat=  +2
        fcb   $80,$FE,$FE,$01  ; seg 147  yaw=-128 pitch=  -2 min_lat=  -2 max_lat=  +1
        fcb   $80,$FC,$F8,$00  ; seg 148  yaw=-128 pitch=  -4 min_lat=  -8 max_lat=  +0
        fcb   $80,$FC,$F9,$FF  ; seg 149  yaw=-128 pitch=  -4 min_lat=  -7 max_lat=  -1
        fcb   $80,$FC,$FA,$FE  ; seg 150  yaw=-128 pitch=  -4 min_lat=  -6 max_lat=  -2
        fcb   $80,$F9,$FB,$FD  ; seg 151  yaw=-128 pitch=  -7 min_lat=  -5 max_lat=  -3
        fcb   $80,$F6,$FC,$FC  ; seg 152  yaw=-128 pitch= -10 min_lat=  -4 max_lat=  -4
        fcb   $80,$F8,$FD,$FB  ; seg 153  yaw=-128 pitch=  -8 min_lat=  -3 max_lat=  -5
        fcb   $80,$FA,$FE,$FA  ; seg 154  yaw=-128 pitch=  -6 min_lat=  -2 max_lat=  -6
        fcb   $80,$FC,$FF,$FA  ; seg 155  yaw=-128 pitch=  -4 min_lat=  -1 max_lat=  -6
        fcb   $80,$FE,$00,$08  ; seg 156  yaw=-128 pitch=  -2 min_lat=  +0 max_lat=  +8
        fcb   $80,$FB,$01,$07  ; seg 157  yaw=-128 pitch=  -5 min_lat=  +1 max_lat=  +7
        fcb   $80,$F8,$02,$06  ; seg 158  yaw=-128 pitch=  -8 min_lat=  +2 max_lat=  +6
        fcb   $80,$FB,$03,$05  ; seg 159  yaw=-128 pitch=  -5 min_lat=  +3 max_lat=  +5
        fcb   $80,$FE,$04,$04  ; seg 160  yaw=-128 pitch=  -2 min_lat=  +4 max_lat=  +4
        fcb   $80,$00,$05,$03  ; seg 161  yaw=-128 pitch=  +0 min_lat=  +5 max_lat=  +3
        fcb   $80,$02,$06,$02  ; seg 162  yaw=-128 pitch=  +2 min_lat=  +6 max_lat=  +2
        fcb   $80,$00,$04,$01  ; seg 163  yaw=-128 pitch=  +0 min_lat=  +4 max_lat=  +1
        fcb   $80,$FE,$F6,$00  ; seg 164  yaw=-128 pitch=  -2 min_lat= -10 max_lat=  +0
        fcb   $80,$FE,$F6,$FF  ; seg 165  yaw=-128 pitch=  -2 min_lat= -10 max_lat=  -1
        fcb   $80,$FE,$F6,$FE  ; seg 166  yaw=-128 pitch=  -2 min_lat= -10 max_lat=  -2
        fcb   $80,$FC,$F6,$FD  ; seg 167  yaw=-128 pitch=  -4 min_lat= -10 max_lat=  -3
        fcb   $80,$FA,$F6,$FC  ; seg 168  yaw=-128 pitch=  -6 min_lat= -10 max_lat=  -4
        fcb   $80,$FB,$F7,$FB  ; seg 169  yaw=-128 pitch=  -5 min_lat=  -9 max_lat=  -5
        fcb   $80,$FC,$F8,$FA  ; seg 170  yaw=-128 pitch=  -4 min_lat=  -8 max_lat=  -6
        fcb   $80,$FE,$F9,$FA  ; seg 171  yaw=-128 pitch=  -2 min_lat=  -7 max_lat=  -6
        fcb   $80,$00,$FA,$06  ; seg 172  yaw=-128 pitch=  +0 min_lat=  -6 max_lat=  +6
        fcb   $80,$00,$FB,$05  ; seg 173  yaw=-128 pitch=  +0 min_lat=  -5 max_lat=  +5
        fcb   $80,$00,$FC,$04  ; seg 174  yaw=-128 pitch=  +0 min_lat=  -4 max_lat=  +4
        fcb   $80,$00,$FD,$03  ; seg 175  yaw=-128 pitch=  +0 min_lat=  -3 max_lat=  +3
        fcb   $80,$00,$FE,$02  ; seg 176  yaw=-128 pitch=  +0 min_lat=  -2 max_lat=  +2
        fcb   $80,$00,$FF,$01  ; seg 177  yaw=-128 pitch=  +0 min_lat=  -1 max_lat=  +1
        fcb   $80,$00,$00,$00  ; seg 178  yaw=-128 pitch=  +0 min_lat=  +0 max_lat=  +0
        fcb   $80,$00,$FC,$04  ; seg 179  yaw=-128 pitch=  +0 min_lat=  -4 max_lat=  +4
        fcb   $80,$00,$F6,$0A  ; seg 180  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 181  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 182  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 183  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 184  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 185  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 186  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $80,$00,$F6,$0A  ; seg 187  yaw=-128 pitch=  +0 min_lat= -10 max_lat= +10
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$0A  ; seg 188 (wraparound de seg 0)
        fcb   $00,$00,$F6,$0A  ; seg 189 (wraparound de seg 1)
        fcb   $00,$00,$F6,$0A  ; seg 190 (wraparound de seg 2)
        fcb   $00,$00,$F6,$0A  ; seg 191 (wraparound de seg 3)
        fcb   $00,$00,$F6,$0A  ; seg 192 (wraparound de seg 4)
        fcb   $00,$00,$F6,$0A  ; seg 193 (wraparound de seg 5)
        fcb   $00,$00,$F6,$0A  ; seg 194 (wraparound de seg 6)
        fcb   $00,$00,$F6,$0A  ; seg 195 (wraparound de seg 7)
