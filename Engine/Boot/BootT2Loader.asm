********************************************************************************
* Boot loader T2Loader - Benoit Rousseau 29/04/2021
* ------------------------------------------------------------------------------
* 
* Description
* -----------
* Permet de programmer une MEGAROM T.2 depuis SDDRIVE avec un seul fichier SD
*
********************************************************************************
        INCLUDE "./Engine/Macros.asm"          
        
        org   $6200

PalInit
        setdp $62
        lda   #$62
        tfr   a,dp                     * positionne la direct page a 62
        
PalFade        
        clr   <pal_idx
        ldx   #pal_len                 * index limite de chargement pour couleur courante 
        ldu   #pal_from                * chargement pointeur valeur des couleurs actuelles
        
Vsync_1                                
        tst   $E7E7                    * le faisceau n'est pas dans l'ecran utile
        bpl   Vsync_1                  * tant que le bit est a 0 on boucle
Vsync_2                                 
        tst   $E7E7                    * le faisceau est dans l'ecran utile
        bmi   Vsync_2                  * tant que le bit est a 1 on boucle
        
        ldy   #0320                    * 40 lignes * 8 cycles
Tempo        
        leay  -1,y
        bne   Tempo                    * tempo pour etre dans la bordure invisible   
                                                                        
        dec   <pal_cycles              * decremente le compteur du nombre de frame
        beq   InitVideo                * si termine
        
PalRun
        lda   ,u                                   * chargement de la composante verte et rouge
        anda  <pal_mask                * on efface la valeur vert ou rouge par masque
        ldb   #$FF                     * composante verte et rouge couleur cible
        andb  <pal_mask                * on efface la valeur vert ou rouge par masque
        stb   <pal_buffer              * on stocke la valeur cible pour comparaison
        ldb   #$11                     * preparation de la valeur d'increment de couleur
        andb  <pal_mask                * on efface la valeur non utile par masque
        stb   <pal_buffer+1            * on stocke la valeur pour ADD ou SUB ulterieur
        cmpa  <pal_buffer              * comparaison de la composante courante et cible
        beq   PalVRSuivante            * si composante est egale a la cible on passe
        bhi   PalVRDec                 * si la composante est superieure on branche
        lda   ,u                       * on recharge la valeur avec vert et rouge
        adda  <pal_buffer+1            * on incremente la composante verte ou rouge
        bra   PalVRSave                * on branche pour sauvegarder
PalVRDec
        lda   ,u                       * on recharge la valeur avec vert et rouge
        suba  <pal_buffer+1            * on decremente la composante verte ou rouge
PalVRSave                             
        sta   ,u                       * sauvegarde de la nouvelle valeur vert ou rouge
PalVRSuivante                         
        com   <pal_mask                * inversion du masque pour traiter l'autre semioctet
        bmi   PalRun                   * si on traite $F0 on branche sinon on continue
            
SetPalBleu
        ldb   1,u                                   * chargement composante bleue courante
        cmpb  #$0F                     * comparaison composante courante et cible
        beq   SetPalNext               * si composante est egale a la cible on passe
        bhi   SetPalBleudec            * si la composante est superieure on branche
        incb                           * on incremente la composante bleue
        bra   SetPalSaveBleu           * on branche pour sauvegarder
SetPalBleudec                       
        decb                           * on decremente la composante bleue
SetPalSaveBleu                         
        stb   1,u                      * sauvegarde de la nouvelle valeur bleue
                                                                       
SetPalNext                             
        lda   <pal_idx                 * Lecture index couleur
        sta   $E7DB                    * selectionne l'indice de couleur a ecrire
        adda  #$02                     * increment de l'indice de couleur (x2)
        sta   <pal_idx                 * stockage du nouvel index
        lda   ,u                       * chargement de la nouvelle couleur courante
        sta   $E7DA                    * positionne la nouvelle couleur (Vert et Rouge)
        stb   $E7DA                    * positionne la nouvelle couleur (Bleu)
        lda   <pal_idx                 * rechargement de l'index couleur
        cmpa  ,x                       * comparaison avec l'index limite pour cette couleur
        bne   SetPalNext               * si inferieur on continue avec la meme couleur
        leau  2,u                      * on avance le pointeur vers la nouvelle couleur
        leax  1,x                      * on avance le pointeur vers la nouvelle limite
        cmpx  #end_pal_len             * test de fin de liste
        bne   PalRun                   * on reboucle si fin de liste pas atteinte
        bra   PalFade
        
pal_buffer                             
        fcb   $42                      * B et buffer de comparaison
        fcb   $41                      * A et buffer de comparaison
        fcb   $53                      * S
        fcb   $49                      * I
        fcb   $43                      * C
        fcb   $32                      * 2
                                                                       
pal_idx                                
        fcb   $00                      * index de la couleur courante dans le traitement
        fcb   $00                      * espace reserve pour somme de controle
   
*-------------------------------------------------------------------------------
* A partir de ce point le code doit commencer a l'adresse $6280
*-------------------------------------------------------------------------------

********************************************************************************  
* Initialisation du mode video
********************************************************************************
InitVideo
        orcc  #$50                     * desactive les interruptions
        lda   #$7B                     * passage en mode 160x200x16c
        sta   $E7DC
  
********************************************************************************
* Initialisation de la commutation de page pour l espace Donnees (Mode registre)
********************************************************************************
        ldb   $6081                    * $6081 est l'image "lisible" de $E7E7
        orb   #$10                     * positionne le bit d4 a 1
        stb   $6081                    * maintient une image coherente de $E7E7
        stb   $E7E7                    * bit d4 a 1 pour pages donnees en mode registre
 
********************************************************************************
* Lecture des donnees depuis la disquette et decompression par exomizer
********************************************************************************
DKLecture
        setdp $60
        lda   #$60
        tfr   a,dp                     * positionne la direct page a 60
        
        ldd   #$6300
        std   <$604F                   * DK.BUF Destination des donnees lues
        lda   #$00
        sta   <$6049                   * DK.DRV Lecteur        
        std   <$604A                   * DK.TRK Piste
        lda   #$02
        sta   <$604C                   * DK.SEC $02 Secteur
        sta   <$6048                   * DK.OPC $02 Operation - lecture d'un secteur
DKCO
        jsr   $E82A                    * DKCO Appel Moniteur - lecture d'un secteur
        inc   <$604C                   * increment du registre Moniteur DK.SEC
        lda   <$604C                   * chargement de DK.SEC
        cmpa  #$10                     * si DK.SEC est inferieur ou egal a 16
        bls   DKContinue               * on continue le traitement
        lda   #$01                     * sinon on a depasse le secteur 16
        sta   <$604C                   * positionnement du secteur a 1
        inc   <$604B                   * increment du registre Moniteur DK.TRK
        lda   <$604B
        cmpa  #$4F                     * si DK.SEC est inferieur ou egal a 79
        bls   DKContinue               * on continue le traitement
        clr   <$604B                   * positionnement de la piste a 0
        inc   <$6049                   * increment du registre Moniteur DK.DRV
DKContinue                            
        inc   <$604F                   * increment de 256 octets de la zone a ecrire DK.BUF
        ldd   <$604F                   * chargement de la zone a ecrire DK.BUF
dk_dernier_bloc                        
        cmpd  #$9E00                   * test debut du dernier bloc de 256 octets a ecrire
        bls   DKCO                     * si DK.BUF inferieur ou egal a la limite alors DKCO

BOO_WaitVBL
        tst   $E7E7                    ; le faisceau n'est pas dans l'ecran
        bpl   BOO_WaitVBL              ; tant que le bit est a 0 on boucle
BOO_WaitVBL1
        tst   $E7E7                    ; le faisceau est dans l'ecran
        bmi   BOO_WaitVBL1             ; tant que le bit est a 1 on boucle

* Positionnement de la page 3 a l'ecran
***************************************
        lda   #$C0
        sta   $E7DD                    ; affiche la page a l'ecran
        
        jmp   $6300

* donnees pour le fondu de palette
********************************************************************************

pal_from
        fdb   $0000                    * couleur $00 Noir (Thomson) => 06 change bordure
        fdb   $F00F                    * couleur $0C Turquoise (Bordure ecran)
        fdb   $FF0F                    * couleur $0E Blanc (TO8)
        fdb   $7707                    * couleur $10 Gris (Fond Bas)
        fdb   $AA03                    * couleur $16 Jaune (Interieur case)
        fdb   $330A                    * couleur $18 Mauve (Fond TO8)
                                                                       
pal_len                                
        fcb   $0C                      * pour chaque couleur on defini un index limite
        fcb   $0E                      * (exclu) de chargement. ex: 0C, 0E, ... 
        fcb   $10                      * la premiere couleur de PAL_FROM est chargee
        fcb   $16                      * pour les couleurs 0(00) a 5(0A)
        fcb   $18                      * la seconde couleur de PAL_FORM  est chargee
        fcb   $20                      * pour la couleur 6(0C)
end_pal_len
   
pal_cycles
        fcb   $10                      * nombre de frames de la transition (VSYNC)
                                                                       
pal_mask                               
        fcb   $0F                      * masque pour l'aternance du traitemet vert/rouge