* ======================================================================
* Circuit_30_hard_13 — N=168 segments (format compact 8 oct/seg)
* Source       : 30_hard_13.bin (extrait de FILE30)
*
* Pays         : GREECE
* Lieu         : zakinthos island
* Description  : oil spills onto track
* Hazards      : many hills and bends
*
* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après
* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :
*   00:#000000 01:#904824 02:#6C4824 03:#482400 04:#484824 05:#B40000 06:#242424 07:#242424
*   08:#244824 09:#D8D8D8 10:#242400 11:#FCFCFC 12:#FC0000 13:#FC0000 14:#FC2400 15:#FC2400
*   16:#FC4800 17:#FC4800 18:#FC6C00 19:#FC6C00 20:#FC9000 21:#FC9000 22:#FCB400 23:#FCB400
*   24:#FCD800 25:#FCD800 26:#FCFC00 27:#FCFC00
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
* Taille totale : 2130 oct (nb_segments 2 + LUT 16 + segments 1408 + cache 704).
* ======================================================================

Circuit_30_hard_13_nb_segments
        fdb   168

Circuit_30_hard_13_sprite_lut
        fcb   $00,$82,$81,$83,$A2,$9B,$8B,$80,$99,$00,$00,$00,$00,$00,$00,$00  ; LUT sprite_id (idx 0..15)

Circuit_30_hard_13_segments
        fcb   $7C,$80,$01,$00,$00,$00,$00,$00  ; seg   0  curve=-4            flags=[START] #0:$82@+0
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg   1  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg   2  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg   3  curve=-4
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg   4                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg   5                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg   6                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg   7                                    #0:$83@+18 #2:$83@+18
        fcb   $80,$00,$40,$00,$00,$08,$00,$00  ; seg   8                      flags=[PIT]   #1:$A2@+8
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg   9                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  10                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  11                      flags=[PIT]
        fcb   $80,$00,$40,$00,$00,$F8,$00,$00  ; seg  12                      flags=[PIT]   #1:$A2@-8
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  13                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  14                      flags=[PIT]
        fcb   $80,$00,$00,$00,$00,$00,$00,$00  ; seg  15                      flags=[PIT]
        fcb   $00,$00,$45,$60,$EC,$0C,$00,$14  ; seg  16                                    #0:$9B@-20 #1:$A2@+12 #3:$8B@+20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  17                                    #0:$9B@-20
        fcb   $00,$00,$05,$60,$EC,$00,$00,$20  ; seg  18                                    #0:$9B@-20 #3:$8B@+32
        fcb   $00,$00,$05,$60,$EC,$00,$00,$30  ; seg  19                                    #0:$9B@-20 #3:$8B@+48
        fcb   $00,$02,$45,$00,$14,$F4,$00,$00  ; seg  20            pitch=+2                #0:$9B@+20 #1:$A2@-12
        fcb   $00,$02,$05,$60,$14,$00,$00,$E0  ; seg  21            pitch=+2                #0:$9B@+20 #3:$8B@-32
        fcb   $00,$02,$05,$60,$14,$00,$00,$D0  ; seg  22            pitch=+2                #0:$9B@+20 #3:$8B@-48
        fcb   $00,$02,$05,$00,$14,$00,$00,$00  ; seg  23            pitch=+2                #0:$9B@+20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  24                                    #0:$9B@-20
        fcb   $00,$00,$05,$60,$EC,$00,$00,$20  ; seg  25                                    #0:$9B@-20 #3:$8B@+32
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  26                                    #0:$9B@-20
        fcb   $00,$00,$05,$60,$EC,$00,$00,$18  ; seg  27                                    #0:$9B@-20 #3:$8B@+24
        fcb   $00,$7E,$05,$00,$14,$00,$00,$00  ; seg  28            pitch=-2                #0:$9B@+20
        fcb   $00,$7E,$05,$00,$14,$00,$00,$00  ; seg  29            pitch=-2                #0:$9B@+20
        fcb   $00,$7E,$05,$60,$14,$00,$00,$EC  ; seg  30            pitch=-2                #0:$9B@+20 #3:$8B@-20
        fcb   $00,$7E,$05,$60,$14,$00,$00,$E0  ; seg  31            pitch=-2                #0:$9B@+20 #3:$8B@-32
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  32                                    #0:$9B@-20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  33                                    #0:$9B@-20
        fcb   $00,$00,$05,$60,$EC,$00,$00,$20  ; seg  34                                    #0:$9B@-20 #3:$8B@+32
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  35                                    #0:$9B@-20
        fcb   $00,$00,$40,$60,$00,$0C,$00,$14  ; seg  36                                    #1:$A2@+12 #3:$8B@+20
        fcb   $00,$00,$00,$60,$00,$00,$00,$EC  ; seg  37                                    #3:$8B@-20
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg  38                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg  39                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$00,$42,$00,$EE,$F8,$00,$00  ; seg  40  curve=-4                          #0:$81@-18 #1:$A2@-8
        fcb   $7C,$00,$02,$60,$EE,$00,$00,$20  ; seg  41  curve=-4                          #0:$81@-18 #3:$8B@+32
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  42  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  43  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$42,$60,$EE,$0C,$00,$18  ; seg  44  curve=-4                          #0:$81@-18 #1:$A2@+12 #3:$8B@+24
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg  45  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$77,$77,$12,$12,$12,$12  ; seg  46  curve=-4                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $7C,$00,$77,$77,$12,$12,$12,$12  ; seg  47  curve=-4                          #0:$80@+18 #1:$80@+18 #2:$80@+18 #3:$80@+18
        fcb   $06,$00,$47,$07,$12,$08,$12,$00  ; seg  48  curve=+6                          #0:$80@+18 #1:$A2@+8 #2:$80@+18
        fcb   $06,$00,$07,$67,$12,$00,$12,$E0  ; seg  49  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8B@-32
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  50  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  51  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$47,$07,$12,$0C,$12,$00  ; seg  52  curve=+6                          #0:$80@+18 #1:$A2@+12 #2:$80@+18
        fcb   $06,$00,$07,$67,$12,$00,$12,$D8  ; seg  53  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8B@-40
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  54  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  55  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$47,$07,$12,$F4,$12,$00  ; seg  56  curve=+6                          #0:$80@+18 #1:$A2@-12 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  57  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$07,$67,$12,$00,$12,$E0  ; seg  58  curve=+6                          #0:$80@+18 #2:$80@+18 #3:$8B@-32
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  59  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$47,$07,$12,$F8,$12,$00  ; seg  60  curve=+6                          #0:$80@+18 #1:$A2@-8 #2:$80@+18
        fcb   $06,$00,$07,$07,$12,$00,$12,$00  ; seg  61  curve=+6                          #0:$80@+18 #2:$80@+18
        fcb   $06,$00,$00,$60,$00,$00,$00,$C8  ; seg  62  curve=+6                          #3:$8B@-56
        fcb   $06,$00,$00,$60,$00,$00,$00,$20  ; seg  63  curve=+6                          #3:$8B@+32
        fcb   $00,$00,$48,$08,$EC,$0C,$14,$00  ; seg  64                                    #0:$99@-20 #1:$A2@+12 #2:$99@+20
        fcb   $00,$00,$08,$08,$EC,$00,$14,$00  ; seg  65                                    #0:$99@-20 #2:$99@+20
        fcb   $00,$00,$08,$60,$EC,$00,$00,$14  ; seg  66                                    #0:$99@-20 #3:$8B@+20
        fcb   $00,$00,$08,$08,$EC,$00,$14,$00  ; seg  67                                    #0:$99@-20 #2:$99@+20
        fcb   $00,$7F,$00,$68,$00,$00,$14,$E0  ; seg  68            pitch=-1                #2:$99@+20 #3:$8B@-32
        fcb   $00,$7F,$08,$08,$EC,$00,$14,$00  ; seg  69            pitch=-1                #0:$99@-20 #2:$99@+20
        fcb   $00,$7F,$08,$60,$EC,$00,$00,$20  ; seg  70            pitch=-1                #0:$99@-20 #3:$8B@+32
        fcb   $00,$7F,$08,$08,$EC,$00,$14,$00  ; seg  71            pitch=-1                #0:$99@-20 #2:$99@+20
        fcb   $00,$01,$08,$08,$EC,$00,$14,$00  ; seg  72            pitch=+1                #0:$99@-20 #2:$99@+20
        fcb   $00,$01,$00,$08,$00,$00,$14,$00  ; seg  73            pitch=+1                #2:$99@+20
        fcb   $00,$01,$08,$08,$EC,$00,$14,$00  ; seg  74            pitch=+1                #0:$99@-20 #2:$99@+20
        fcb   $00,$01,$08,$60,$EC,$00,$00,$28  ; seg  75            pitch=+1                #0:$99@-20 #3:$8B@+40
        fcb   $00,$03,$48,$08,$EC,$04,$14,$00  ; seg  76            pitch=+3                #0:$99@-20 #1:$A2@+4 #2:$99@+20
        fcb   $00,$03,$48,$08,$EC,$02,$14,$00  ; seg  77            pitch=+3                #0:$99@-20 #1:$A2@+2 #2:$99@+20
        fcb   $00,$03,$08,$68,$EC,$00,$14,$30  ; seg  78            pitch=+3                #0:$99@-20 #2:$99@+20 #3:$8B@+48
        fcb   $00,$03,$00,$68,$00,$00,$14,$D0  ; seg  79            pitch=+3                #2:$99@+20 #3:$8B@-48
        fcb   $00,$7D,$08,$08,$EC,$00,$14,$00  ; seg  80            pitch=-3                #0:$99@-20 #2:$99@+20
        fcb   $00,$7D,$08,$60,$EC,$00,$00,$18  ; seg  81            pitch=-3                #0:$99@-20 #3:$8B@+24
        fcb   $00,$7D,$08,$08,$EC,$00,$14,$00  ; seg  82            pitch=-3                #0:$99@-20 #2:$99@+20
        fcb   $00,$7D,$08,$08,$EC,$00,$14,$00  ; seg  83            pitch=-3                #0:$99@-20 #2:$99@+20
        fcb   $00,$00,$00,$60,$00,$00,$00,$1C  ; seg  84                                    #3:$8B@+28
        fcb   $00,$00,$00,$60,$00,$00,$00,$E0  ; seg  85                                    #3:$8B@-32
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg  86                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg  87                                    #0:$81@-18 #2:$81@-18
        fcb   $7C,$7F,$02,$00,$EE,$00,$00,$00  ; seg  88  curve=-4  pitch=-1                #0:$81@-18
        fcb   $7C,$7F,$02,$00,$EE,$00,$00,$00  ; seg  89  curve=-4  pitch=-1                #0:$81@-18
        fcb   $7C,$7F,$00,$60,$00,$00,$00,$20  ; seg  90  curve=-4  pitch=-1                #3:$8B@+32
        fcb   $7C,$7F,$00,$60,$00,$00,$00,$E4  ; seg  91  curve=-4  pitch=-1                #3:$8B@-28
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  92                                    #0:$9B@-20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  93                                    #0:$9B@-20
        fcb   $00,$00,$05,$60,$EC,$00,$00,$24  ; seg  94                                    #0:$9B@-20 #3:$8B@+36
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  95                                    #0:$9B@-20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  96                                    #0:$9B@-20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  97                                    #0:$9B@-20
        fcb   $00,$00,$05,$60,$EC,$00,$00,$14  ; seg  98                                    #0:$9B@-20 #3:$8B@+20
        fcb   $00,$00,$05,$00,$EC,$00,$00,$00  ; seg  99                                    #0:$9B@-20
        fcb   $00,$01,$00,$60,$00,$00,$00,$20  ; seg 100            pitch=+1                #3:$8B@+32
        fcb   $00,$01,$00,$60,$00,$00,$00,$EC  ; seg 101            pitch=+1                #3:$8B@-20
        fcb   $00,$01,$02,$02,$EE,$00,$EE,$00  ; seg 102            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $00,$01,$02,$02,$EE,$00,$EE,$00  ; seg 103            pitch=+1                #0:$81@-18 #2:$81@-18
        fcb   $04,$00,$42,$00,$EE,$FC,$00,$00  ; seg 104  curve=+4                          #0:$81@-18 #1:$A2@-4
        fcb   $04,$00,$02,$00,$EE,$00,$00,$00  ; seg 105  curve=+4                          #0:$81@-18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 106  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$E0  ; seg 107  curve=+4                          #0:$80@+18 #3:$8B@-32
        fcb   $04,$00,$47,$00,$12,$F8,$00,$00  ; seg 108  curve=+4                          #0:$80@+18 #1:$A2@-8
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 109  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$60,$00,$00,$00,$D4  ; seg 110  curve=+4                          #3:$8B@-44
        fcb   $04,$00,$00,$60,$00,$00,$00,$20  ; seg 111  curve=+4                          #3:$8B@+32
        fcb   $00,$00,$48,$00,$14,$0C,$00,$00  ; seg 112                                    #0:$99@+20 #1:$A2@+12
        fcb   $00,$00,$08,$00,$14,$00,$00,$00  ; seg 113                                    #0:$99@+20
        fcb   $00,$00,$08,$00,$EC,$00,$00,$00  ; seg 114                                    #0:$99@-20
        fcb   $00,$00,$08,$60,$EC,$00,$00,$24  ; seg 115                                    #0:$99@-20 #3:$8B@+36
        fcb   $00,$00,$48,$00,$EC,$08,$00,$00  ; seg 116                                    #0:$99@-20 #1:$A2@+8
        fcb   $00,$00,$08,$00,$EC,$00,$00,$00  ; seg 117                                    #0:$99@-20
        fcb   $00,$00,$08,$60,$14,$00,$00,$34  ; seg 118                                    #0:$99@+20 #3:$8B@+52
        fcb   $00,$00,$08,$00,$14,$00,$00,$00  ; seg 119                                    #0:$99@+20
        fcb   $00,$02,$48,$00,$14,$04,$00,$00  ; seg 120            pitch=+2                #0:$99@+20 #1:$A2@+4
        fcb   $00,$02,$48,$60,$EC,$02,$00,$20  ; seg 121            pitch=+2                #0:$99@-20 #1:$A2@+2 #3:$8B@+32
        fcb   $00,$7E,$08,$00,$EC,$00,$00,$00  ; seg 122            pitch=-2                #0:$99@-20
        fcb   $00,$7E,$08,$00,$EC,$00,$00,$00  ; seg 123            pitch=-2                #0:$99@-20
        fcb   $00,$00,$08,$00,$14,$00,$00,$00  ; seg 124                                    #0:$99@+20
        fcb   $00,$00,$08,$60,$14,$00,$00,$E8  ; seg 125                                    #0:$99@+20 #3:$8B@-24
        fcb   $00,$00,$08,$00,$EC,$00,$00,$00  ; seg 126                                    #0:$99@-20
        fcb   $00,$00,$08,$00,$EC,$00,$00,$00  ; seg 127                                    #0:$99@-20
        fcb   $00,$02,$48,$00,$EC,$F4,$00,$00  ; seg 128            pitch=+2                #0:$99@-20 #1:$A2@-12
        fcb   $00,$02,$48,$00,$14,$F6,$00,$00  ; seg 129            pitch=+2                #0:$99@+20 #1:$A2@-10
        fcb   $00,$7E,$08,$00,$14,$00,$00,$00  ; seg 130            pitch=-2                #0:$99@+20
        fcb   $00,$7E,$08,$60,$14,$00,$00,$E0  ; seg 131            pitch=-2                #0:$99@+20 #3:$8B@-32
        fcb   $00,$00,$00,$60,$00,$00,$00,$20  ; seg 132                                    #3:$8B@+32
        fcb   $00,$00,$00,$60,$00,$00,$00,$18  ; seg 133                                    #3:$8B@+24
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 134                                    #0:$80@+18 #2:$80@+18
        fcb   $00,$00,$07,$07,$12,$00,$12,$00  ; seg 135                                    #0:$80@+18 #2:$80@+18
        fcb   $04,$01,$47,$00,$12,$08,$00,$00  ; seg 136  curve=+4  pitch=+1                #0:$80@+18 #1:$A2@+8
        fcb   $04,$01,$47,$60,$12,$0A,$00,$E8  ; seg 137  curve=+4  pitch=+1                #0:$80@+18 #1:$A2@+10 #3:$8B@-24
        fcb   $04,$01,$07,$00,$12,$00,$00,$00  ; seg 138  curve=+4  pitch=+1                #0:$80@+18
        fcb   $04,$01,$07,$00,$12,$00,$00,$00  ; seg 139  curve=+4  pitch=+1                #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$EC  ; seg 140  curve=+4                          #0:$80@+18 #3:$8B@-20
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 141  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$20  ; seg 142  curve=+4                          #0:$80@+18 #3:$8B@+32
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 143  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 144  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$EC  ; seg 145  curve=+4                          #0:$80@+18 #3:$8B@-20
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 146  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 147  curve=+4                          #0:$80@+18
        fcb   $04,$00,$07,$60,$12,$00,$00,$E4  ; seg 148  curve=+4                          #0:$80@+18 #3:$8B@-28
        fcb   $04,$00,$07,$00,$12,$00,$00,$00  ; seg 149  curve=+4                          #0:$80@+18
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 150  curve=+4
        fcb   $04,$00,$00,$00,$00,$00,$00,$00  ; seg 151  curve=+4
        fcb   $00,$7F,$88,$00,$EC,$C8,$00,$00  ; seg 152            pitch=-1                #0:$99@-20 #1:$99@-56
        fcb   $00,$7F,$88,$88,$E8,$CC,$DC,$E0  ; seg 153            pitch=-1                #0:$99@-24 #1:$99@-52 #2:$99@-36 #3:$99@-32
        fcb   $00,$7F,$80,$88,$00,$D0,$E0,$E4  ; seg 154            pitch=-1                #1:$99@-48 #2:$99@-32 #3:$99@-28
        fcb   $00,$7F,$08,$88,$EC,$00,$E8,$D8  ; seg 155            pitch=-1                #0:$99@-20 #2:$99@-24 #3:$99@-40
        fcb   $00,$00,$88,$08,$E4,$D0,$C8,$00  ; seg 156                                    #0:$99@-28 #1:$99@-48 #2:$99@-56
        fcb   $00,$00,$88,$80,$E8,$DC,$00,$E0  ; seg 157                                    #0:$99@-24 #1:$99@-36 #3:$99@-32
        fcb   $00,$00,$08,$88,$EC,$00,$D0,$DC  ; seg 158                                    #0:$99@-20 #2:$99@-48 #3:$99@-36
        fcb   $00,$00,$88,$08,$E4,$D8,$C8,$00  ; seg 159                                    #0:$99@-28 #1:$99@-40 #2:$99@-56
        fcb   $00,$00,$40,$00,$00,$D0,$00,$00  ; seg 160                                    #1:$A2@-48
        fcb   $00,$00,$40,$00,$00,$20,$00,$00  ; seg 161                                    #1:$A2@+32
        fcb   $00,$00,$40,$00,$00,$E8,$00,$00  ; seg 162                                    #1:$A2@-24
        fcb   $00,$00,$40,$00,$00,$18,$00,$00  ; seg 163                                    #1:$A2@+24
        fcb   $00,$00,$40,$00,$00,$20,$00,$00  ; seg 164                                    #1:$A2@+32
        fcb   $00,$00,$40,$00,$00,$E0,$00,$00  ; seg 165                                    #1:$A2@-32
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 166                                    #0:$81@-18 #2:$81@-18
        fcb   $00,$00,$02,$02,$EE,$00,$EE,$00  ; seg 167                                    #0:$81@-18 #2:$81@-18
* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──
        fcb   $7C,$00,$01,$00,$00,$00,$00,$00  ; seg 168  curve=-4                          #0:$82@+0
        fcb   $7C,$00,$02,$00,$EE,$00,$00,$00  ; seg 169  curve=-4                          #0:$81@-18
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 170  curve=-4
        fcb   $7C,$00,$00,$00,$00,$00,$00,$00  ; seg 171  curve=-4
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg 172                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg 173                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg 174                                    #0:$83@+18 #2:$83@+18
        fcb   $00,$00,$03,$03,$12,$00,$12,$00  ; seg 175                                    #0:$83@+18 #2:$83@+18

Circuit_30_hard_13_segment_cache
        fcb   $00,$00,$F6,$08  ; seg   0  yaw=  +0 pitch=  +0 min_lat= -10 max_lat=  +8
        fcb   $FC,$00,$F6,$07  ; seg   1  yaw=  -4 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $F8,$00,$F6,$06  ; seg   2  yaw=  -8 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $F4,$00,$F7,$05  ; seg   3  yaw= -12 pitch=  +0 min_lat=  -9 max_lat=  +5
        fcb   $F0,$00,$F8,$04  ; seg   4  yaw= -16 pitch=  +0 min_lat=  -8 max_lat=  +4
        fcb   $F0,$00,$F9,$03  ; seg   5  yaw= -16 pitch=  +0 min_lat=  -7 max_lat=  +3
        fcb   $F0,$00,$FA,$02  ; seg   6  yaw= -16 pitch=  +0 min_lat=  -6 max_lat=  +2
        fcb   $F0,$00,$FB,$01  ; seg   7  yaw= -16 pitch=  +0 min_lat=  -5 max_lat=  +1
        fcb   $F0,$00,$FC,$00  ; seg   8  yaw= -16 pitch=  +0 min_lat=  -4 max_lat=  +0
        fcb   $F0,$00,$FD,$0A  ; seg   9  yaw= -16 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $F0,$00,$FE,$0A  ; seg  10  yaw= -16 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $F0,$00,$FF,$09  ; seg  11  yaw= -16 pitch=  +0 min_lat=  -1 max_lat=  +9
        fcb   $F0,$00,$00,$08  ; seg  12  yaw= -16 pitch=  +0 min_lat=  +0 max_lat=  +8
        fcb   $F0,$00,$F6,$07  ; seg  13  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $F0,$00,$F6,$06  ; seg  14  yaw= -16 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $F0,$00,$F7,$05  ; seg  15  yaw= -16 pitch=  +0 min_lat=  -9 max_lat=  +5
        fcb   $F0,$00,$F8,$04  ; seg  16  yaw= -16 pitch=  +0 min_lat=  -8 max_lat=  +4
        fcb   $F0,$00,$F9,$0A  ; seg  17  yaw= -16 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $F0,$00,$FA,$0A  ; seg  18  yaw= -16 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $F0,$00,$FB,$0A  ; seg  19  yaw= -16 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $F0,$00,$FC,$0A  ; seg  20  yaw= -16 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $F0,$02,$F6,$0A  ; seg  21  yaw= -16 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $F0,$04,$F6,$0A  ; seg  22  yaw= -16 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $F0,$06,$F6,$0A  ; seg  23  yaw= -16 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $F0,$08,$F6,$0A  ; seg  24  yaw= -16 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $F0,$08,$F6,$0A  ; seg  25  yaw= -16 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $F0,$08,$F6,$0A  ; seg  26  yaw= -16 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $F0,$08,$F6,$0A  ; seg  27  yaw= -16 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $F0,$08,$F6,$0A  ; seg  28  yaw= -16 pitch=  +8 min_lat= -10 max_lat= +10
        fcb   $F0,$06,$F6,$0A  ; seg  29  yaw= -16 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $F0,$04,$F6,$0A  ; seg  30  yaw= -16 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $F0,$02,$F7,$09  ; seg  31  yaw= -16 pitch=  +2 min_lat=  -9 max_lat=  +9
        fcb   $F0,$00,$F8,$08  ; seg  32  yaw= -16 pitch=  +0 min_lat=  -8 max_lat=  +8
        fcb   $F0,$00,$F9,$07  ; seg  33  yaw= -16 pitch=  +0 min_lat=  -7 max_lat=  +7
        fcb   $F0,$00,$FA,$06  ; seg  34  yaw= -16 pitch=  +0 min_lat=  -6 max_lat=  +6
        fcb   $F0,$00,$FB,$05  ; seg  35  yaw= -16 pitch=  +0 min_lat=  -5 max_lat=  +5
        fcb   $F0,$00,$FC,$04  ; seg  36  yaw= -16 pitch=  +0 min_lat=  -4 max_lat=  +4
        fcb   $F0,$00,$FD,$0A  ; seg  37  yaw= -16 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $F0,$00,$FE,$0A  ; seg  38  yaw= -16 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $F0,$00,$FF,$09  ; seg  39  yaw= -16 pitch=  +0 min_lat=  -1 max_lat=  +9
        fcb   $F0,$00,$00,$08  ; seg  40  yaw= -16 pitch=  +0 min_lat=  +0 max_lat=  +8
        fcb   $EC,$00,$F6,$07  ; seg  41  yaw= -20 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $E8,$00,$F6,$06  ; seg  42  yaw= -24 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $E4,$00,$F6,$05  ; seg  43  yaw= -28 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $E0,$00,$F6,$04  ; seg  44  yaw= -32 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $DC,$00,$F6,$03  ; seg  45  yaw= -36 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $D8,$00,$F6,$02  ; seg  46  yaw= -40 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $D4,$00,$F6,$01  ; seg  47  yaw= -44 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $D0,$00,$F6,$00  ; seg  48  yaw= -48 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $D6,$00,$F6,$07  ; seg  49  yaw= -42 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $DC,$00,$F6,$06  ; seg  50  yaw= -36 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $E2,$00,$F7,$05  ; seg  51  yaw= -30 pitch=  +0 min_lat=  -9 max_lat=  +5
        fcb   $E8,$00,$F8,$04  ; seg  52  yaw= -24 pitch=  +0 min_lat=  -8 max_lat=  +4
        fcb   $EE,$00,$F9,$0A  ; seg  53  yaw= -18 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $F4,$00,$FA,$0A  ; seg  54  yaw= -12 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $FA,$00,$FB,$0A  ; seg  55  yaw=  -6 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $00,$00,$FC,$0A  ; seg  56  yaw=  +0 pitch=  +0 min_lat=  -4 max_lat= +10
        fcb   $06,$00,$FD,$0A  ; seg  57  yaw=  +6 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $0C,$00,$FE,$0A  ; seg  58  yaw= +12 pitch=  +0 min_lat=  -2 max_lat= +10
        fcb   $12,$00,$FF,$09  ; seg  59  yaw= +18 pitch=  +0 min_lat=  -1 max_lat=  +9
        fcb   $18,$00,$00,$08  ; seg  60  yaw= +24 pitch=  +0 min_lat=  +0 max_lat=  +8
        fcb   $1E,$00,$F6,$07  ; seg  61  yaw= +30 pitch=  +0 min_lat= -10 max_lat=  +7
        fcb   $24,$00,$F6,$06  ; seg  62  yaw= +36 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $2A,$00,$F6,$05  ; seg  63  yaw= +42 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $30,$00,$F6,$04  ; seg  64  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $30,$00,$F6,$06  ; seg  65  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $30,$00,$F6,$05  ; seg  66  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $30,$00,$F6,$04  ; seg  67  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $30,$00,$F6,$03  ; seg  68  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $30,$FF,$F6,$02  ; seg  69  yaw= +48 pitch=  -1 min_lat= -10 max_lat=  +2
        fcb   $30,$FE,$F6,$01  ; seg  70  yaw= +48 pitch=  -2 min_lat= -10 max_lat=  +1
        fcb   $30,$FD,$F6,$00  ; seg  71  yaw= +48 pitch=  -3 min_lat= -10 max_lat=  +0
        fcb   $30,$FC,$F6,$FF  ; seg  72  yaw= +48 pitch=  -4 min_lat= -10 max_lat=  -1
        fcb   $30,$FD,$F6,$FE  ; seg  73  yaw= +48 pitch=  -3 min_lat= -10 max_lat=  -2
        fcb   $30,$FE,$F6,$FD  ; seg  74  yaw= +48 pitch=  -2 min_lat= -10 max_lat=  -3
        fcb   $30,$FF,$F6,$FC  ; seg  75  yaw= +48 pitch=  -1 min_lat= -10 max_lat=  -4
        fcb   $30,$00,$F6,$FB  ; seg  76  yaw= +48 pitch=  +0 min_lat= -10 max_lat=  -5
        fcb   $30,$03,$F6,$FA  ; seg  77  yaw= +48 pitch=  +3 min_lat= -10 max_lat=  -6
        fcb   $30,$06,$F6,$0A  ; seg  78  yaw= +48 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $30,$09,$F6,$0A  ; seg  79  yaw= +48 pitch=  +9 min_lat= -10 max_lat= +10
        fcb   $30,$0C,$F6,$0A  ; seg  80  yaw= +48 pitch= +12 min_lat= -10 max_lat= +10
        fcb   $30,$09,$F6,$0A  ; seg  81  yaw= +48 pitch=  +9 min_lat= -10 max_lat= +10
        fcb   $30,$06,$F6,$0A  ; seg  82  yaw= +48 pitch=  +6 min_lat= -10 max_lat= +10
        fcb   $30,$03,$F6,$0A  ; seg  83  yaw= +48 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  84  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  85  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  86  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  87  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $30,$00,$F6,$0A  ; seg  88  yaw= +48 pitch=  +0 min_lat= -10 max_lat= +10
        fcb   $2C,$FF,$F6,$0A  ; seg  89  yaw= +44 pitch=  -1 min_lat= -10 max_lat= +10
        fcb   $28,$FE,$F6,$0A  ; seg  90  yaw= +40 pitch=  -2 min_lat= -10 max_lat= +10
        fcb   $24,$FD,$F7,$0A  ; seg  91  yaw= +36 pitch=  -3 min_lat=  -9 max_lat= +10
        fcb   $20,$FC,$F8,$0A  ; seg  92  yaw= +32 pitch=  -4 min_lat=  -8 max_lat= +10
        fcb   $20,$FC,$F9,$0A  ; seg  93  yaw= +32 pitch=  -4 min_lat=  -7 max_lat= +10
        fcb   $20,$FC,$FA,$0A  ; seg  94  yaw= +32 pitch=  -4 min_lat=  -6 max_lat= +10
        fcb   $20,$FC,$FB,$0A  ; seg  95  yaw= +32 pitch=  -4 min_lat=  -5 max_lat= +10
        fcb   $20,$FC,$FC,$0A  ; seg  96  yaw= +32 pitch=  -4 min_lat=  -4 max_lat= +10
        fcb   $20,$FC,$FD,$0A  ; seg  97  yaw= +32 pitch=  -4 min_lat=  -3 max_lat= +10
        fcb   $20,$FC,$FE,$0A  ; seg  98  yaw= +32 pitch=  -4 min_lat=  -2 max_lat= +10
        fcb   $20,$FC,$FF,$0A  ; seg  99  yaw= +32 pitch=  -4 min_lat=  -1 max_lat= +10
        fcb   $20,$FC,$00,$0A  ; seg 100  yaw= +32 pitch=  -4 min_lat=  +0 max_lat= +10
        fcb   $20,$FD,$01,$0A  ; seg 101  yaw= +32 pitch=  -3 min_lat=  +1 max_lat= +10
        fcb   $20,$FE,$02,$0A  ; seg 102  yaw= +32 pitch=  -2 min_lat=  +2 max_lat= +10
        fcb   $20,$FF,$03,$0A  ; seg 103  yaw= +32 pitch=  -1 min_lat=  +3 max_lat= +10
        fcb   $20,$00,$04,$0A  ; seg 104  yaw= +32 pitch=  +0 min_lat=  +4 max_lat= +10
        fcb   $24,$00,$FD,$0A  ; seg 105  yaw= +36 pitch=  +0 min_lat=  -3 max_lat= +10
        fcb   $28,$00,$FE,$09  ; seg 106  yaw= +40 pitch=  +0 min_lat=  -2 max_lat=  +9
        fcb   $2C,$00,$FF,$08  ; seg 107  yaw= +44 pitch=  +0 min_lat=  -1 max_lat=  +8
        fcb   $30,$00,$00,$07  ; seg 108  yaw= +48 pitch=  +0 min_lat=  +0 max_lat=  +7
        fcb   $34,$00,$F6,$06  ; seg 109  yaw= +52 pitch=  +0 min_lat= -10 max_lat=  +6
        fcb   $38,$00,$F6,$05  ; seg 110  yaw= +56 pitch=  +0 min_lat= -10 max_lat=  +5
        fcb   $3C,$00,$F6,$04  ; seg 111  yaw= +60 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $40,$00,$F6,$03  ; seg 112  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $40,$00,$F6,$02  ; seg 113  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $40,$00,$F6,$01  ; seg 114  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $40,$00,$F6,$00  ; seg 115  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $40,$00,$F6,$FF  ; seg 116  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  -1
        fcb   $40,$00,$F6,$FE  ; seg 117  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  -2
        fcb   $40,$00,$F6,$FD  ; seg 118  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  -3
        fcb   $40,$00,$F6,$FC  ; seg 119  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  -4
        fcb   $40,$00,$F6,$FB  ; seg 120  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  -5
        fcb   $40,$02,$F6,$FA  ; seg 121  yaw= +64 pitch=  +2 min_lat= -10 max_lat=  -6
        fcb   $40,$04,$F7,$0A  ; seg 122  yaw= +64 pitch=  +4 min_lat=  -9 max_lat= +10
        fcb   $40,$02,$F8,$0A  ; seg 123  yaw= +64 pitch=  +2 min_lat=  -8 max_lat= +10
        fcb   $40,$00,$F9,$0A  ; seg 124  yaw= +64 pitch=  +0 min_lat=  -7 max_lat= +10
        fcb   $40,$00,$FA,$0A  ; seg 125  yaw= +64 pitch=  +0 min_lat=  -6 max_lat= +10
        fcb   $40,$00,$FB,$0A  ; seg 126  yaw= +64 pitch=  +0 min_lat=  -5 max_lat= +10
        fcb   $40,$00,$FC,$09  ; seg 127  yaw= +64 pitch=  +0 min_lat=  -4 max_lat=  +9
        fcb   $40,$00,$FD,$08  ; seg 128  yaw= +64 pitch=  +0 min_lat=  -3 max_lat=  +8
        fcb   $40,$02,$FE,$07  ; seg 129  yaw= +64 pitch=  +2 min_lat=  -2 max_lat=  +7
        fcb   $40,$04,$F6,$06  ; seg 130  yaw= +64 pitch=  +4 min_lat= -10 max_lat=  +6
        fcb   $40,$02,$F6,$05  ; seg 131  yaw= +64 pitch=  +2 min_lat= -10 max_lat=  +5
        fcb   $40,$00,$F6,$04  ; seg 132  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +4
        fcb   $40,$00,$F6,$03  ; seg 133  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +3
        fcb   $40,$00,$F6,$02  ; seg 134  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +2
        fcb   $40,$00,$F6,$01  ; seg 135  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +1
        fcb   $40,$00,$F6,$00  ; seg 136  yaw= +64 pitch=  +0 min_lat= -10 max_lat=  +0
        fcb   $44,$01,$F6,$02  ; seg 137  yaw= +68 pitch=  +1 min_lat= -10 max_lat=  +2
        fcb   $48,$02,$F6,$0A  ; seg 138  yaw= +72 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $4C,$03,$F6,$0A  ; seg 139  yaw= +76 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $50,$04,$F6,$0A  ; seg 140  yaw= +80 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $54,$04,$F6,$0A  ; seg 141  yaw= +84 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $58,$04,$F6,$0A  ; seg 142  yaw= +88 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $5C,$04,$F6,$0A  ; seg 143  yaw= +92 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $60,$04,$F6,$0A  ; seg 144  yaw= +96 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $64,$04,$F6,$0A  ; seg 145  yaw=+100 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $68,$04,$F6,$0A  ; seg 146  yaw=+104 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $6C,$04,$F6,$0A  ; seg 147  yaw=+108 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $70,$04,$F6,$0A  ; seg 148  yaw=+112 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $74,$04,$F6,$0A  ; seg 149  yaw=+116 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $78,$04,$F6,$0A  ; seg 150  yaw=+120 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $7C,$04,$F6,$0A  ; seg 151  yaw=+124 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $80,$04,$F6,$0A  ; seg 152  yaw=-128 pitch=  +4 min_lat= -10 max_lat= +10
        fcb   $80,$03,$F6,$0A  ; seg 153  yaw=-128 pitch=  +3 min_lat= -10 max_lat= +10
        fcb   $80,$02,$F6,$0A  ; seg 154  yaw=-128 pitch=  +2 min_lat= -10 max_lat= +10
        fcb   $80,$01,$F6,$0A  ; seg 155  yaw=-128 pitch=  +1 min_lat= -10 max_lat= +10
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
* ── Wraparound cache (8 premiers dupliqués) ──
        fcb   $00,$00,$F6,$08  ; seg 168 (wraparound de seg 0)
        fcb   $FC,$00,$F6,$07  ; seg 169 (wraparound de seg 1)
        fcb   $F8,$00,$F6,$06  ; seg 170 (wraparound de seg 2)
        fcb   $F4,$00,$F7,$05  ; seg 171 (wraparound de seg 3)
        fcb   $F0,$00,$F8,$04  ; seg 172 (wraparound de seg 4)
        fcb   $F0,$00,$F9,$03  ; seg 173 (wraparound de seg 5)
        fcb   $F0,$00,$FA,$02  ; seg 174 (wraparound de seg 6)
        fcb   $F0,$00,$FB,$01  ; seg 175 (wraparound de seg 7)
