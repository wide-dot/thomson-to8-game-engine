 ifndef PerspectiveTables_included
PerspectiveTables_included equ 1
* ======================================================================
* PerspectiveTables.asm — TABLES PERSPECTIVE PRÉCALCULÉES
* 
* Extraites de FILE59.bin (= FILE59.SCR décompressé) par
* tools/extract_perspective_tables.py.
* 
* Layout source ST :
*   FILE59 chargé à $2FD40
*   1/n × k tables : $2FD80 (8 groupes × 128 longs)
*   Y horizon      : $30D40 (128 mots signés)
*   Scaling factor : $30E40 (128 mots signés)
* 
* Conversion TO8 : aucune (= ratios + coord Y, dimensions verticales
* identiques 200 lignes ST/TO8 ; pas d'axe horizontal X à halver ici).
* 
* Référence 68000 : CARS.REL.asm.txt FUN_78a98 (= ram:$78a98, off $8698)
* ======================================================================

* ──────────────────────────────────────────────────────────────────────
* Persp_Horizon
*   Y horizon par ligne — courbe 1/Z descendant de 95 (= horizon lointai
*   n) à 39 (= sol près). Utilisé par FUN_78a98 :  Y_ecran = horizon[lin
*   e] + (altitude * scaling[line]) >> 16.
* ──────────────────────────────────────────────────────────────────────
Persp_Horizon
        fdb   $005F,$0055,$004E,$0049,$0045,$0042,$003F,$003D    ; [  0..  7]    95    85    78    73    69    66    63    61
        fdb   $003B,$0039,$0038,$0037,$0036,$0035,$0034,$0033    ; [  8.. 15]    59    57    56    55    54    53    52    51
        fdb   $0032,$0032,$0031,$0031,$0030,$0030,$002F,$002F    ; [ 16.. 23]    50    50    49    49    48    48    47    47
        fdb   $002E,$002E,$002E,$002E,$002D,$002D,$002D,$002C    ; [ 24.. 31]    46    46    46    46    45    45    45    44
        fdb   $002C,$002C,$002C,$002C,$002C,$002B,$002B,$002B    ; [ 32.. 39]    44    44    44    44    44    43    43    43
        fdb   $002B,$002B,$002B,$002A,$002A,$002A,$002A,$002A    ; [ 40.. 47]    43    43    43    42    42    42    42    42
        fdb   $002A,$002A,$0029,$0029,$0029,$0029,$0029,$0029    ; [ 48.. 55]    42    42    41    41    41    41    41    41
        fdb   $0029,$0029,$0029,$0029,$0029,$0029,$0029,$0029    ; [ 56.. 63]    41    41    41    41    41    41    41    41
        fdb   $0029,$0028,$0028,$0028,$0028,$0028,$0028,$0028    ; [ 64.. 71]    41    40    40    40    40    40    40    40
        fdb   $0028,$0028,$0028,$0028,$0028,$0028,$0028,$0028    ; [ 72.. 79]    40    40    40    40    40    40    40    40
        fdb   $0028,$0028,$0028,$0027,$0027,$0027,$0027,$0027    ; [ 80.. 87]    40    40    40    39    39    39    39    39
        fdb   $0027,$0027,$0027,$0027,$0027,$0027,$0027,$0027    ; [ 88.. 95]    39    39    39    39    39    39    39    39
        fdb   $0027,$0027,$0027,$0027,$0027,$0027,$0027,$0027    ; [ 96..103]    39    39    39    39    39    39    39    39
        fdb   $0027,$0027,$0027,$0027,$0027,$0027,$0027,$0027    ; [104..111]    39    39    39    39    39    39    39    39
        fdb   $0027,$0027,$0027,$0027,$0027,$0027,$0027,$0027    ; [112..119]    39    39    39    39    39    39    39    39
        fdb   $0027,$0027,$0027,$0027,$0027,$0027,$0027,$0027    ; [120..127]    39    39    39    39    39    39    39    39

* ──────────────────────────────────────────────────────────────────────
* Persp_Scaling
*   Facteur scaling par ligne — décroît de 4095 (proche) à ~160 (loin). 
*   Utilisé en MULS.W avec altitude cumulée pour produire la correction 
*   verticale due au pitch caméra.
* ──────────────────────────────────────────────────────────────────────
Persp_Scaling
        fdb   $0FFF,$0D5C,$0B80,$0A18,$08FE,$081C,$0763,$06C7    ; [  0..  7]  4095  3420  2944  2584  2302  2076  1891  1735
        fdb   $0644,$05D3,$0570,$051A,$04CE,$048B,$044E,$0417    ; [  8.. 15]  1604  1491  1392  1306  1230  1163  1102  1047
        fdb   $03E6,$03B9,$0390,$036A,$0347,$0327,$030A,$02EE    ; [ 16.. 23]   998   953   912   874   839   807   778   750
        fdb   $02D4,$02BC,$02A6,$0291,$027D,$026A,$0259,$0248    ; [ 24.. 31]   724   700   678   657   637   618   601   584
        fdb   $0238,$0229,$021B,$020E,$0201,$01F5,$01E9,$01DE    ; [ 32.. 39]   568   553   539   526   513   501   489   478
        fdb   $01D4,$01C9,$01C0,$01B6,$01AE,$01A5,$019D,$0195    ; [ 40.. 47]   468   457   448   438   430   421   413   405
        fdb   $018D,$0186,$017F,$0178,$0171,$016B,$0165,$015F    ; [ 48.. 55]   397   390   383   376   369   363   357   351
        fdb   $0159,$0154,$014E,$0149,$0144,$013F,$013A,$0136    ; [ 56.. 63]   345   340   334   329   324   319   314   310
        fdb   $0131,$012D,$0129,$0124,$0120,$011D,$0119,$0115    ; [ 64.. 71]   305   301   297   292   288   285   281   277
        fdb   $0112,$010E,$010B,$0107,$0104,$0101,$00FE,$00FB    ; [ 72.. 79]   274   270   267   263   260   257   254   251
        fdb   $00F8,$00F5,$00F2,$00EF,$00ED,$00EA,$00E7,$00E5    ; [ 80.. 87]   248   245   242   239   237   234   231   229
        fdb   $00E2,$00E0,$00DE,$00DB,$00D9,$00D7,$00D5,$00D3    ; [ 88.. 95]   226   224   222   219   217   215   213   211
        fdb   $00D1,$00CE,$00CC,$00CB,$00C9,$00C7,$00C5,$00C3    ; [ 96..103]   209   206   204   203   201   199   197   195
        fdb   $00C1,$00BF,$00BE,$00BC,$00BA,$00B9,$00B7,$00B6    ; [104..111]   193   191   190   188   186   185   183   182
        fdb   $00B4,$00B2,$00B1,$00AF,$00AE,$00AD,$00AB,$00AA    ; [112..119]   180   178   177   175   174   173   171   170
        fdb   $00A8,$00A7,$00A6,$00A4,$00A3,$00A2,$00A1,$00A0    ; [120..127]   168   167   166   164   163   162   161   160


* ──────────────────────────────────────────────────────────────────────
* Persp_Recip_* — TABLES 1/n × k × 2^20 (PAGÉES via FixedData mechanism)
*
* Chargées par le RAMLoader en page 3 ($1000 = RAMA pour k01..k49 partie,
* $3000 = RAMB pour k49..k57). Le game-mode init recopie page 3 → page 0
* demi-pages via CopyPageToDemiPage0 :
*   page 0 RAMA = patterns_dark + Persp_Recip_A (k01..k? partiel)
*   page 0 RAMB = patterns_light + Persp_Recip_B (k? partiel..k57)
*
* Au runtime, l'interpolateur lit Persp_Recip via $5xxx (= page 0 demi-page).
* Le bit PRC sélectionne RAMA ou RAMB selon la frame (dark/light dithering).
*
* Le fichier Persp_Recip_paged.asm (assemblé séparément en .bin) contient
* TOUTES les tables k01..k57 contiguës à partir de $5000. Voir ce fichier
* pour le layout exact.
*
* Économie : 4 Ko sur le game-mode résident (PerspectiveTables passe de
* 4.5 Ko à 512 oct).
* ──────────────────────────────────────────────────────────────────────

Persp_Recip_zero_header         equ $5000           ; 64 oct header zéros
FILE59_BASE_FOR_INTERP          equ Persp_Recip_zero_header
Persp_Recip_k01                 equ $5040           ; 512 oct (FILE59 +$40)
Persp_Recip_k09                 equ $5240           ; 512 oct (FILE59 +$240)
Persp_Recip_k17                 equ $5440           ; 512 oct (FILE59 +$440)
Persp_Recip_k25                 equ $5640           ; 512 oct (FILE59 +$640)
Persp_Recip_k33                 equ $5840           ; 512 oct (FILE59 +$840)
Persp_Recip_k41                 equ $5A40           ; 512 oct (FILE59 +$A40)
Persp_Recip_k49                 equ $5C40           ; 512 oct (FILE59 +$C40)
Persp_Recip_k57                 equ $5E40           ; 448 oct (FILE59 +$E40, tronqué)

 endc                                               ; PerspectiveTables_included
