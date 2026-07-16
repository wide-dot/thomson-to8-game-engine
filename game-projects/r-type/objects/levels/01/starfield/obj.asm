; ===========================================================================
; Starfield - 22 etoiles sur le ciel ouvert du niveau 1 : 8 sur le plan 0,
; 7 sur les plans 1 et 2.
;
; Les etoiles n'ont AUCUN etat mutable, et depuis stardata.asm elles n'ont plus
; non plus de calcul d'adresse : l'adresse VRAM d'une etoile ne depend que de
; (plan, offset, etoile), trois valeurs connues a la COMPILATION (x_base et y
; sont des constantes, l'offset ne prend que 144 valeurs entieres). Tracer, c'est
; donc `ldx ,u++`. La table (6048 o) vit dans la page cartouche : gratuite en RAM
; residente, et valable pour les DEUX buffers (le pager permute les pages
; physiques, l'adresse logique ne bouge pas).
;
; Toutes les etoiles d'un plan partagent un offset de defilement, et tous les
; x_base sont PAIRS. Comme le wrap ajoute 144 (pair), parite(x) == parite(off) :
; le nibble est connu une fois par PLAN et par passe, pas par etoile. D'ou deux
; boucles specialisees (nibble haut / nibble bas) et 2 o par entree de table.
;
; Couleurs = nibbles palette (cf. generated-code/level01/BuilderMainGenCode.asm ;
; la palette est decalee de 1 vs le PNG) : 1 = blanc, 2 = gris, 5 = bleu fonce.
; 0 comme $F sont NOIRS a l'ecran, donc indiscernables sur une capture.
;
; Invariant central (MESURE, pas suppose) : le ciel jamais dessine est
; uniformement $FF (nibble 15), le decor peint son noir en nibble 0.
;   tracer  : si notre nibble == $F -> ecrire la couleur
;   effacer : si notre nibble == notre couleur -> reecrire $F
; -> on ne touche QUE du ciel ; le decor (nibble 0) est ignore, ce qui est aussi
;    le rendu voulu (pas d'etoile dans la silhouette de la ville).
;
; Les deux operations sont le MEME XOR, dans l'ordre inverse :
;   tracer  = tester $F puis XOR   ($F ^ masque = couleur)
;   effacer = XOR puis tester $F   (couleur ^ masque = $F)
; avec masque = $F0 ^ couleur_haut (resp. $0F ^ couleur_bas). Et pour le nibble
; haut le test se reduit a `cmpa #$F0` : (octet AND $F0) == $F0 <=> octet >= $F0.
;
; Deux passes par trame (cf. main.asm et le commentaire de StarfieldErase) :
;   ERASE entre DrawTiles et DrawSprites (le fond vient d'etre restaure),
;   DRAW apres DrawSprites (les fonds sauvegardes ne contiennent JAMAIS
;   d'etoile -> un sprite immobile puis remis en mouvement ne peut pas
;   reinjecter d'etoiles perimees). Le test "ciel vierge" garde les etoiles
;   derriere les sprites.
; ===========================================================================
        INCLUDE "./engine/macros.asm"

; ---------------------------------------------------------------------------
; Corps deroules. Les etoiles d'un plan sont adressees a OFFSET CONSTANT depuis
; U : `ldx \1,u` (6 cycles, offset 5 bits) au lieu de `ldx ,u++` (8), et surtout
; plus de `dec starCnt` + `bne` (10) -- soit ~12 des ~47 cycles par etoile. Le
; deroulage ne coute que de la page cartouche.
;
;   \1 = offset de CETTE etoile dans la table (0,2,..,12, et 14 pour la 8e)
;   \2 = offset de la SUIVANTE, qui sert de cible au saut (99 = fin de passe)
;
; COULEUR PAR ETOILE, a cout nul : chaque bloc lit SON masque XOR dans le
; descripteur, en offset NEGATIF depuis Y (les 16 masques sont ranges DEVANT le
; point d'entree du descripteur) : masque haut de l'etoile i en i-16,y, masque
; bas en i-8,y. i = \1/2 (ecrit \1/2-16 : sur si lwasm evalue gauche->droite). Offsets -16..-1 = 5 bits -> meme taille (2 o) et
; meme cout (5 cycles) que l'ancien `eora 4,y` a couleur unique par plan.
;
; Les plans n'ont pas tous le meme nombre d'etoiles (8 pour le plan 0, 7 pour
; les autres). Plutot que deux chaines completes, le bloc de la 8e etoile
; (offset 14) est place EN TETE et enchaine sur le bloc de la 1re : un plan a 8
; etoiles entre par le bloc de tete, un plan a 7 entre juste apres, et les deux
; sortent au meme rts. La 8e etoile coute donc du code une seule fois, et rien
; du tout aux plans qui ne l'ont pas.
;
; Le label est en tete de bloc et porte une instruction : lwasm ne definit un
; label depuis un parametre QUE dans ce cas. Une ligne ne portant que `\1` ou
; `sfdh\1` seul ne definit rien (erreur "Undefined symbol"), et les labels
; anonymes `>` / `!` ne se re-resolvent pas par expansion de macro.
; ---------------------------------------------------------------------------
STAR_DH MACRO                           ; tracer, nibble haut
sfdh\1  ldx   \1,u
        lda   ,x
        cmpa  #$F0                      ; ciel vierge ? (octet AND $F0)==$F0
        blo   sfdh\2                    ;   <=> octet >= $F0
        eora  \1/2-16,y                 ; $F -> couleur de CETTE etoile
        sta   ,x
 ENDM

STAR_DL MACRO                           ; tracer, nibble bas
sfdl\1  ldx   \1,u
        lda   ,x
        coma                            ; ciel vierge <=> les 4 bits bas de
        bita  #$0F                      ;   ~octet sont tous a 0
        bne   sfdl\2
        coma                            ; retour a l'octet
        eora  \1/2-8,y  
        sta   ,x
 ENDM

STAR_EH MACRO                           ; effacer, nibble haut
sfeh\1  ldx   \1,u
        lda   ,x
        eora  \1/2-16,y                 ; notre couleur -> $F
        cmpa  #$F0
        blo   sfeh\2                    ; ce n'etait pas notre couleur
        sta   ,x
 ENDM

STAR_EL MACRO                           ; effacer, nibble bas
sfel\1  ldx   \1,u
        lda   ,x
        eora  \1/2-8,y  
        coma
        bita  #$0F
        bne   sfel\2
        coma
        sta   ,x
 ENDM

Object                                  ; B = commande (starfield.INIT / .ERASE / .DRAW)
        leax  sf_rtn,pcr
        jmp   [b,x]                     ; meme idiome que main.asm:180 (jmp [a,x])
sf_rtn  fdb   StarfieldInit
        fdb   StarfieldErase
        fdb   StarfieldDraw

; ---------------------------------------------------------------------------
; Descripteurs de plan - 25 octets : 16 masques DEVANT le point d'entree Y,
; puis 9 octets de parametres.
;   -16..-9,y  masques XOR nibble haut, un par etoile ($F0 ^ couleur<<4)
;    -8..-1,y  masques XOR nibble bas,  un par etoile ($0F ^ couleur)
;    0,y  table (2)          adresse de starTab_pN
;    2,y  vitesse 8.8 (2)
;    4,y  pas (1)            nb_etoiles*2 (14 ou 16)
;    5,y  8e etoile (1)      1 = ce plan a une 8e etoile (entree du corps deroule)
;    6,y  nb de tours (1)    1 ou 2 (cf. gen_stardata.py)
;    7,y  lapStride (2)      pas*144, deplacement d'un tour dans la table
; Les etoiles vont vers la GAUCHE : x = x_base - offset, offset croissant.
;
; Les masques sont PAR ETOILE (le corps deroule lit -16+i,y / -8+i,y, cf. les
; macros) : la couleur de chaque etoile est un octet ici, cout zero en cycles.
; Couleurs (nibble palette, cf. pal.png decale de 1) : 2 = gris #616161,
; 4 = beige #CCC2AB, 5 = bleu fonce #00618F. L'etoile 8 (offset 14) = slot 7.
; ---------------------------------------------------------------------------
        fcb   $B0,$D0,$B0,$B0,$D0,$B0,$D0,$B0   ; p0 : beige,gris,beige,beige,gris,beige,gris,beige
        fcb   $0B,$0D,$0B,$0B,$0D,$0B,$0D,$0B
planeTable
        fdb   starTab_p0
        fdb   $0100                     ; 1.0 px/trame (plan rapide)
        fcb   16,1                      ; 8 etoiles (2 amas de 4) -> pas 16
        fcb   2                         ; 2 tours : hauteurs differentes a chaque passage
        fdb   16*144                    ; lapStride = 2304
        fcb   $D0,$A0,$D0,$D0,$A0,$D0,$A0,$00   ; p1 : gris,bleu,gris,gris,bleu,gris,bleu (7 etoiles)
        fcb   $0D,$0A,$0D,$0D,$0A,$0D,$0A,$00
        fdb   starTab_p1
        fdb   $0080                     ; 0.5 px/trame
        fcb   14,0                      ; 7 etoiles -> pas 14
        fcb   1                         ; 1 tour (plan lent, ne repasse pas dans l'intro)
        fdb   14*144                    ; lapStride (inutilise a 1 tour)
        fcb   $A0,$A0,$D0,$A0,$A0,$D0,$A0,$00   ; p2 : bleu fonce dominant, 2 grises (7 etoiles)
        fcb   $0A,$0A,$0D,$0A,$0A,$0D,$0A,$00
        fdb   starTab_p2
        fdb   $0040                     ; 0.25 px/trame (plan lointain, le plus sombre)
        fcb   14,0                      ; 7 etoiles -> pas 14
        fcb   1                         ; 1 tour
        fdb   14*144                    ; lapStride (inutilise)

; ---------------------------------------------------------------------------
; StarfieldInit - remet les offsets a zero. Les positions etant precalculees,
; il n'y a rien a semer.
; ---------------------------------------------------------------------------
StarfieldInit
        ldx   #starCurOff
        ldb   #27                       ; 6 (starCurOff) + 12 (starPrevOff)
                                        ; + 3 (starCurLap) + 6 (starPrevLap)
sf_ini  clr   ,x+
        decb
        bne   sf_ini
        rts

; ---------------------------------------------------------------------------
; La trame est en DEUX passes, encadrant DrawSprites (cf. main.asm) :
;   EraseSprites -> DrawTiles -> starfield.ERASE -> DrawSprites -> starfield.DRAW
;
; POURQUOI : le moteur SAUTE l'effacement/redraw d'un sprite immobile
; (CheckSpritesRefresh compare buf_prev_xy_pixel). Si les etoiles etaient
; tracees AVANT DrawSprites, elles etaient cuites dans la cellule de fond
; sauvegardee du sprite ; un sprite reste immobile N trames (vaisseau pose,
; pod dormant), puis bouge -> le moteur restaure un fond VIEUX de N trames,
; avec des etoiles a des offsets que le starfield ne vise plus -> residus
; permanents. En tracant APRES la sauvegarde des fonds, aucune cellule ne
; contient jamais d'etoile : la restauration ne peut plus rien reinjecter.
; L'effacement, lui, reste AVANT DrawSprites (le fond vient d'etre restaure
; par EraseSprites, nos etoiles de l'avant-derniere trame y sont visibles).
; ---------------------------------------------------------------------------

; StarPlaneIdx - index du plan courant, partages par les deux passes.
StarPlaneIdx
        ldb   starPlaneIdx
        aslb                            ; B = plan*2
        stb   starCurIdx
        aslb                            ; B = plan*4
        addb  starBufOff                ; + buffer*2
        stb   starPrevIdx
        lsrb                            ; B = plan*2 + buffer : index dans starPrevLap
        stb   starPrevLapIdx
        rts

; ---------------------------------------------------------------------------
; StarfieldErase - passe 1 : effacer chaque plan a l'offset et au tour du
; dernier trace DANS CE BUFFER. Porte aussi l'extinction au mur : passe
; star_cam_max on cesse de tracer mais on continue d'effacer 4 rendus (les
; 2 buffers nettoyes 2x), puis starDead coupe tout definitivement.
; ---------------------------------------------------------------------------
StarfieldErase
        ldd   glb_camera_x_pos
        cmpd  #star_cam_max
        bhs   sfe_dying
; camera en-deca du mur : VIVANT. Les clr reaniment aussi le starfield apres un
; respawn post-extinction (mort apres le mur -> reload au checkpoint 432, encore
; dans le ciel) : la camera revenue en arriere est le SEUL signal du respawn ici,
; et main.asm ne doit pas etre touche (toute insertion dans le module resident a
; corrompu le rendu, cause non identifiee). En regime normal ces clr sont des
; no-op idempotents. Seule sequelle : au 1er ERASE post-reanimation, prevOff/
; prevLap sont perimes -> l'effacement vise ~22 adresses arbitraires du ciel
; frais ($FF, cf. checkpoint.asm) ou du decor ; le XOR conditionnel n'ecrit que
; si le pixel vaut exactement une couleur d'etoile (rare, 1 seule fois, borne).
        clr   starDead
        clr   starNoDraw
        clr   starOffCnt
        bra   sfe_alive
sfe_dying
        lda   starDead
        lbne  sfe_done                  ; extinction finie : cout nul jusqu'au respawn
        lda   #1
        sta   starNoDraw
        inc   starOffCnt
        lda   starOffCnt
        cmpa  #4                        ; 4 rendus = les 2 buffers nettoyes 2x
        blo   sfe_alive
        sta   starDead                  ; A != 0
sfe_alive
        lda   gfxlock.backBuffer.id
        beq   >
        lda   #2
!       sta   starBufOff                ; sert aussi a la passe DRAW (meme trame)
        clr   starPlaneIdx
        ldy   #planeTable
sfe_plane
        jsr   StarPlaneIdx
; Deplacement de tour de l'effacement = le tour trace dans CE buffer. On efface
; exactement la ou on avait trace, sinon les etoiles de l'autre tour resteraient.
        jsr   StarLapDispPrev
        ldx   #starPrevOff
        ldb   starPrevIdx
        abx
        lda   ,x                        ; octet haut = partie entiere
        jsr   StarErasePass
        leay  25,y                      ; descripteur suivant (25 octets)
        inc   starPlaneIdx
        lda   starPlaneIdx
        cmpa  #3
        blo   sfe_plane
sfe_done
        rts

; ---------------------------------------------------------------------------
; StarfieldDraw - passe 2 : avancer chaque plan puis tracer au nouvel offset,
; et memoriser (offset, tour) pour l'effacement de CE buffer a la trame
; suivante. starBufOff et starNoDraw viennent de la passe ERASE (meme trame).
; ---------------------------------------------------------------------------
StarfieldDraw
        lda   starDead
        lbne  sfd_done
        lda   starNoDraw
        lbne  sfd_done                  ; extinction : on efface encore, on ne trace plus
        clr   starPlaneIdx
        ldy   #planeTable
sfd_plane
        jsr   StarPlaneIdx

; --- 1) AVANCER l'offset courant (compense frame-drop) -----------------------
        lda   gfxlock.frameDrop.count
        bne   >
        inca                            ; 0 -> compter 1 trame
!       sta   starFrameCnt
        ldx   #starCurOff
        ldb   starCurIdx
        abx                             ; X = &starCurOff[plan]
        ldd   ,x
sfd_mv  addd  2,y                       ; + vitesse 8.8 du plan
        dec   starFrameCnt
        bne   sfd_mv
sfd_wrap
        cmpd  #star_x_span*256          ; garder l'offset dans [0, 144.0)
        blo   sfd_wrapEnd
        subd  #star_x_span*256
; chaque wrap de 144 = un tour complet -> avancer le tour courant (mod nb_tours).
; U sert de scratch ici (X garde &starCurOff, D garde l'offset) ; pshs/puls d
; parce que le cmpa du modulo ecrase A, l'octet haut de D.
        pshs  d
        ldu   #starCurLap
        ldb   starPlaneIdx
        lda   b,u                       ; A = tour courant
        inca
        cmpa  6,y                       ; nb de tours du plan
        blo   >
        clra                            ; retour au tour 0
!       sta   b,u
        puls  d
        bra   sfd_wrap
sfd_wrapEnd
        std   ,x

; --- 2) TRACER au nouvel offset ----------------------------------------------
; Deplacement de tour du trace = le tour courant du plan.
        ldb   starPlaneIdx
        jsr   StarLapDispCur            ; B = plan ; met a jour starLapDisp
        lda   ,x                        ; partie entiere du nouvel offset
        jsr   StarDrawPass

; --- 3) memoriser l'offset ET le tour traces pour CE buffer ------------------
; Les DEUX pointeurs sont calcules AVANT le ldd : un "ldb starPrevIdx" apres
; le ldd ecraserait B, c'est-a-dire l'octet BAS de D (piege ldd = A:B).
        ldx   #starPrevOff
        ldb   starPrevIdx
        abx                             ; X = &starPrevOff[plan][buffer]
        ldu   #starCurOff
        ldb   starCurIdx
        leau  b,u                       ; U = &starCurOff[plan]
        ldd   ,u
        std   ,x
; tour trace -> starPrevLap[plan][buffer], pour que l'effacement de la trame
; suivante vise le meme tour.
        ldu   #starCurLap
        ldb   starPlaneIdx
        lda   b,u                       ; A = tour courant du plan
        ldu   #starPrevLap
        ldb   starPrevLapIdx
        sta   b,u

        leay  25,y                      ; descripteur suivant (25 octets)
        inc   starPlaneIdx
        lda   starPlaneIdx
        cmpa  #3
        lblo  sfd_plane                 ; branche longue : le corps d'un plan
sfd_done                                ; depasse la portee +/-127
        rts

; ---------------------------------------------------------------------------
; StarLapDispPrev / StarLapDispCur - calculent starLapDisp, le deplacement de
; tour (en octets) que StarSetup ajoutera a U : 0 au tour 0, lapStride au tour 1.
;   Prev : tour = starPrevLap[starPrevLapIdx]  (pour l'effacement)
;   Cur  : tour = starCurLap[B]                 (pour le trace ; B = plan)
; Y = descripteur (lapStride en 7,y). Preservent X. Clobber : A, B, D, U.
; ---------------------------------------------------------------------------
StarLapDispPrev
        ldu   #starPrevLap
        ldb   starPrevLapIdx
        lda   b,u                       ; A = tour trace dans ce buffer
        bra   StarLapDisp
StarLapDispCur
        ldu   #starCurLap
        lda   b,u                       ; A = tour courant (B = plan en entree)
StarLapDisp
        tsta                            ; tour 0 ? (tester A AVANT de charger D)
        beq   >
        ldd   7,y                       ; tour != 0 : disp = lapStride
        std   starLapDisp
        rts
!       clr   starLapDisp               ; tour 0 : disp = 0
        clr   starLapDisp+1
        rts

; ---------------------------------------------------------------------------
; StarSetup - prepare une passe : U = &starTab[plan][tour][offset].
;   entree  : A = offset entier, Y = descripteur, starLapDisp deja calcule
;   sortie  : Z = 1 si offset PAIR (nibble haut), Z = 0 si impair (nibble bas)
;             -- ni JSR ni RTS ne touchent CC, le flag survit au retour.
;   clobber : A, B, D, U
; ---------------------------------------------------------------------------
StarSetup
        sta   starOffInt
        ldb   4,y                       ; pas du plan : nb_etoiles*2 (14 ou 16)
        mul                             ; D = offset*pas (max 143*16 = 2288)
        addd  starLapDisp               ; + tour*lapStride (0 ou 2304)
        ldu   ,y                        ; U = table du plan
        leau  d,u                       ; U = &table[tour][offset][0]
        lda   starOffInt
        bita  #1                        ; parite(x) == parite(offset)
        rts

; ---------------------------------------------------------------------------
; StarDrawPass - trace les etoiles du plan a l'offset A. Le `lda 5,y` du choix
; d'entree vient APRES le `bne` : StarSetup rend son verdict de parite dans Z,
; et lda l'ecraserait.
; ---------------------------------------------------------------------------
StarDrawPass
        jsr   StarSetup
        bne   sf_dr_low
        lda   5,y                       ; ce plan a-t-il une 8e etoile ?
        bne   sfdh14
        bra   sfdh0
; --- nibble haut, deroule
        STAR_DH 14,0                    ; 8e etoile : en tete, enchaine sur la 1re
        STAR_DH 0,2
        STAR_DH 2,4
        STAR_DH 4,6
        STAR_DH 6,8
        STAR_DH 8,10
        STAR_DH 10,12
        STAR_DH 12,99
sfdh99 rts
sf_dr_low
        lda   5,y
        bne   sfdl14
        bra   sfdl0
; --- nibble bas, deroule
        STAR_DL 14,0
        STAR_DL 0,2
        STAR_DL 2,4
        STAR_DL 4,6
        STAR_DL 6,8
        STAR_DL 8,10
        STAR_DL 10,12
        STAR_DL 12,99
sfdl99 rts

; ---------------------------------------------------------------------------
; StarErasePass - efface les etoiles du plan a l'offset A. Meme XOR que le
; tracage, applique AVANT le test : si c'etait notre couleur, le nibble devient
; $F et on ecrit ; sinon (decor, sprite, autre plan) on ne touche a rien.
; ---------------------------------------------------------------------------
StarErasePass
        jsr   StarSetup
        bne   sf_er_low
        lda   5,y
        bne   sfeh14
        bra   sfeh0
; --- nibble haut, deroule
        STAR_EH 14,0
        STAR_EH 0,2
        STAR_EH 2,4
        STAR_EH 4,6
        STAR_EH 6,8
        STAR_EH 8,10
        STAR_EH 10,12
        STAR_EH 12,99
sfeh99 rts
sf_er_low
        lda   5,y
        bne   sfel14
        bra   sfel0
; --- nibble bas, deroule
        STAR_EL 14,0
        STAR_EL 0,2
        STAR_EL 2,4
        STAR_EL 4,6
        STAR_EL 6,8
        STAR_EL 8,10
        STAR_EL 10,12
        STAR_EL 12,99
sfel99 rts

; ---------------------------------------------------------------------------
; Adresses VRAM precalculees (6048 o, page cartouche). GENERE : ne pas editer,
; cf. gen_stardata.py.
; ---------------------------------------------------------------------------
        INCLUDE "./objects/levels/01/starfield/stardata.asm"
