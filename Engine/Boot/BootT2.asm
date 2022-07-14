********************************************************************************
* Boot loader T.2 - Benoit Rousseau 26/04/2021
* ------------------------------------------------------------------------------
* 
* Description
* -----------
* Animation de la palette: fondu vers une couleur cible PAL_TO
* Initialisation de la commutation de page pour l'espace Donnees (Mode registre)
* Appel du Game Mode Engine
*
********************************************************************************

        INCLUDE "./Engine/Constants.asm"
        INCLUDE "./Engine/Macros.asm"          
        
        org   $0000

********************************************************************************  
* Header Megarom T.2
********************************************************************************

        fcb   $20                      * caractere espace
        fcb   $53                      * S
        fcb   $6F                      * o        
        fcb   $6E                      * n        
        fcb   $69                      * i
        fcb   $63                      * c
        fcb   $20                      *          
        fcb   $74                      * t
        fcb   $68                      * h
        fcb   $65                      * e
        fcb   $20                      *
        fcb   $48                      * H
        fcb   $65                      * e
        fcb   $64                      * d
        fcb   $67                      * g
        fcb   $65                      * e
        fcb   $68                      * h
        fcb   $6F                      * o
        fcb   $67                      * g                               
        fcb   $20                      *
        fcb   $32                      * 2
        fcb   $20                      *
        fcb   $20                      *
        fcb   $04                      * caractere de fin
        
        fdb   $0000                    * reserve TO7/70
        fcb   $A3                      * checksum (somme des $19 premiers octets a laquelle on ajoute $55)
        fcb   $00                      * libre
        fdb   PalFadeInit              * point entree (reset a chaud) 
        fdb   PalFadeInit              * point entree (reset a froid)

* donnees pour le fondu de palette
********************************************************************************
PalFadeInit
        lda   #$61
        tfr   a,dp                     * positionne la direct page
        
pal_from equ $6100
        ldx   #pal_from
        ldd   #$0000                   * couleur $00 Noir (Thomson) => 06 change bordure
        std   ,x++ 
        ldd   #$F00F                   * couleur $0C Turquoise (Bordure ecran)
        std   ,x++        
        ldd   #$FF0F                   * couleur $0E Blanc (TO8)
        std   ,x++        
        ldd   #$7707                   * couleur $10 Gris (Fond Bas)
        std   ,x++        
        ldd   #$AA03                   * couleur $16 Jaune (Interieur case)
        std   ,x++        
        ldd   #$330A                   * couleur $18 Mauve (Fond TO8)
        std   ,x++        
                                                                       
pal_len equ pal_from+12                              
        ldd   #$0C0E                   * pour chaque couleur on defini un index limite
        std   ,x++                     * (exclu) de chargement. ex: 0C, 0E, ... 
        ldd   #$1016                   * la premiere couleur de PAL_FROM est chargee
        std   ,x++                     * pour les couleurs 0(00) a 5(0A)
        ldd   #$1820                   * la seconde couleur de PAL_FORM  est chargee
        std   ,x++                     * pour la couleur 6(0C)
end_pal_len equ pal_len+6 
   
pal_cycles equ pal_len+6
        lda   #$10                     * nombre de frames de la transition (VSYNC)
        sta   ,x+
                                                                       
pal_mask equ pal_cycles+1                              
        lda   #$0F                     * masque pour l'aternance du traitemet vert/rouge
        sta   ,x+                
        
pal_buffer equ pal_mask+1                           
        lda   #$42                     * buffer de comparaison
        sta   ,x+        
        lda   #$41                     * buffer de comparaison
        sta   ,x+        
                                                                       
pal_idx equ pal_buffer+2                                 
        lda   #$00                     * index de la couleur courante dans le traitement
        sta   ,x        
        
********************************************************************************  
* Fondu palette
********************************************************************************

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
        
********************************************************************************  
* Initialisation du mode video
********************************************************************************
InitVideo
        orcc  #$50                     * desactive les interruptions
        lds   #glb_system_stack        * positionnement pile systeme
        lda   #$7B                     * passage en mode 160x200x16c
        sta   $E7DC
  
********************************************************************************
* Initialisation de la commutation de page pour l espace Donnees (Mode registre)
********************************************************************************
        ldb   $6081                    * $6081 est l'image "lisible" de $E7E7
        orb   #$10                     * positionne le bit d4 a 1
        stb   $6081                    * maintient une image coherente de $E7E7
        stb   $E7E7                    * bit d4 a 1 pour pages donnees en mode registre
 
* Positionnement de la page 3 a l'ecran et de la page 2 en zone A000-DFFF
***********************************************************
        ldd   #$C002                   ; page 3, couleur de cadre 0 et page 2
        sta   $E7DD                    ; affiche la page a l'ecran
        stb   $E7E5                    ; visible dans l'espace donnees
        
        lda   #$AA
        sta   $0555
        lda   #$55
        sta   $02AA
        lda   #$B0
        sta   $0555
        lda   #$02                     ; mode neutre pour la T.2
        sta   $0556
        
        _ldd  gmboot,$FF               ; level to boot and flag for first level load
