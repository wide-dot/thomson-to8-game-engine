	opt   c,ct
	INCLUDE "./generated-code/LostWoods/T2/MainEngine.glb"
	org   $38C6
	setdp $FF

; ---------------------------------------------------------------------------
; Object - PaletteFade
;
; input REG : [u] pointeur sur l'objet (SST)
;
; --------------------------------------
;
; Colors
; ------
; Genesis/Megadrive: 8 values for each component (BGR) 0, 2, 4, 6, 8, A, C, E
; RGB space values: 0, 0x24, 0x49, 0x6D, 0x92, 0xB6, 0xDB, 0xFF
; ---------------------------------------------------------------------------

;*******************************************************************************
; Animation de la palette: fondu vers une couleur cible PAL_TO
;*******************************************************************************
; Ecriture en $E7DB de l'adresse ou sera stockee la couleur.
;
; les adresses vont de deux en deux car il y a deux octets a stocker par couleur.
; couleur: 0, adresse: 00
; couleur: 1, adresse: 02
; couleur: 2, adresse: 04
; ...
;
; Deux ecritures en $E7DA (auto-increment a partir de l'adresse couleur
;                          positionnee en $E7DB) pour la valeur de couleur.
;
;                             V V V V                 R R R R
; Premiere adresse        fondamentale V          fondamentale R
;
; Deuxieme adresse            X X X M                 B B B B
; auto-incrementee        bit de marquage         fondamentale B
;                       (incrustation video)
;
; Attention: les instructions suivantes effectuent une lecture avant l'ecriture
; ASL, ASR, CLR, COM, DEL, INC, LSL, LSR, NEG, ROL, RDR
; un seul appel sur $E7DA va lire $E7DA puis ecrire sur la seconde adresse $E7DA 
; Sur $E7DA il faut donc utiliser l'instruction ST pour ecrire
;*******************************************************************************   

        INCLUDE "./engine/macros.asm"   
        INCLUDE "./objects/SFX/PaletteFade/PaletteFade.idx"           

PaletteFade
        lda   routine,u
        asla
        ldx   #PaletteFade_Routines
        jmp   [a,x]
 
PaletteFade_Routines
        fdb   PaletteFade_Init
        fdb   PaletteFade_Main
        fdb   PaletteFade_Wait	
 
PaletteFade_Init
        inc   routine,u
        ldd   #$100F    
        sta   pal_cycles,u
        stb   pal_mask,u
        
        ldy   pal_src,u
        cmpy  #Dyn_palette             * Source pal is already current pal, no copy
        beq   PaletteFade_Main
        ldx   #Dyn_palette
        ldd   ,y
        std   ,x
        ldd   2,y
        std   2,x
        ldd   4,y
        std   4,x
        ldd   6,y
        std   6,x   
        ldd   8,y
        std   8,x
        ldd   10,y
        std   10,x
        ldd   12,y
        std   12,x
        ldd   14,y
        std   14,x
        ldd   16,y
        std   16,x
        ldd   18,y
        std   18,x
        ldd   20,y
        std   20,x
        ldd   22,y
        std   22,x
        ldd   24,y
        std   24,x
        ldd   26,y
        std   26,x
        ldd   28,y
        std   28,x
        ldd   30,y
        std   30,x                                                                                                                     
                                                 
PaletteFade_Main
        lda   subtype,u
	sta   pal_wait_frame,u
        ldx   pal_dst,u
        ldy   #Dyn_palette
        lda   #$10
        sta   pal_idx,u   
        dec   pal_cycles,u             * decremente le compteur du nombre de frame
        bne   PFA_Loop                 * on reboucle si nombre de frame n'est pas realise
        jmp   ClearObj                 * auto-destruction de l'objet
        
PFA_Loop
        lda   ,y                       * chargement de la composante verte et rouge
        anda  pal_mask,u               * on efface la valeur vert ou rouge par masque
        ldb   ,x                       * composante verte et rouge couleur cible
        andb  pal_mask,u               * on efface la valeur vert ou rouge par masque
        stb   pal_buffer,u             * on stocke la valeur cible pour comparaison
        ldb   #$11                     * preparation de la valeur d'increment de couleur
        andb  pal_mask,u               * on efface la valeur non utile par masque
        stb   pal_buffer+1,u           * on stocke la valeur pour ADD ou SUB ulterieur
        cmpa  pal_buffer,u             * comparaison de la composante courante et cible
        beq   PFA_VRSuivante           * si composante est egale a la cible on passe
        bhi   PFA_VRDec                * si la composante est superieure on branche
        lda   ,y                       * on recharge la valeur avec vert et rouge
        adda  pal_buffer+1,u           * on incremente la composante verte ou rouge
        bra   PFA_VRSave               * on branche pour sauvegarder
PFA_VRDec
        lda   ,y                       * on recharge la valeur avec vert et rouge
        suba  pal_buffer+1,u           * on decremente la composante verte ou rouge
PFA_VRSave                             
        sta   ,y                       * sauvegarde de la nouvelle valeur vert ou rouge
PFA_VRSuivante                         
        com   pal_mask,u               * inversion du masque pour traiter l'autre semioctet
        bmi   PFA_Loop                 * si on traite $F0 on branche sinon on continue
	    
PFA_SetPalBleu
        ldb   1,y                      * chargement composante bleue courante
        cmpb  1,x                      * comparaison composante courante et cible
        beq   PFA_SetPalNext           * si composante est egale a la cible on passe
        bhi   PFA_SetPalBleudec        * si la composante est superieure on branche
        incb                           * on incremente la composante bleue
        bra   PFA_SetPalSaveBleu       * on branche pour sauvegarder
PFA_SetPalBleudec                       
        decb                           * on decremente la composante bleue
PFA_SetPalSaveBleu                         
        stb   1,y                      * sauvegarde de la nouvelle valeur bleue
								       
PFA_SetPalNext                             
        leay  2,y                      * on avance le pointeur vers la nouvelle couleur source
        leax  2,x                      * on avance le pointeur vers la nouvelle couleur dest
        dec   pal_idx,u 
        bne   PFA_Loop                 * on reboucle si fin de liste pas atteinte
        ldd   #Dyn_palette
        std   Cur_palette
        clr   Refresh_palette          * will call refresh palette after next VBL
        inc   routine,u	
        rts               

PaletteFade_Wait
        lda   pal_wait_frame,u
        bne   @a
	dec   routine,u
	bra   PaletteFade_Main
@a      dec   pal_wait_frame,u
        rts
