********************************************************************************
* Attente VBL
* Alternance de la page 2 et 3 entre affichage et espace cartouche
* Alternance de la RAMA et RAM B dans l'espace ecran
* ------------------------------------------------------------------------------
*
* Page Affichee par l'automate Video
* ----------------------------------
*   $E7DD determine la page affichee a l'ecran
*   bit7=0 bit6=0 bit5=0 bit4=0 (#$0_) : page 0
*   bit7=0 bit6=1 bit5=0 bit4=0 (#$4_) : page 1
*   bit7=1 bit6=0 bit5=0 bit4=0 (#$8_) : page 2
*   bit7=1 bit6=1 bit5=0 bit4=0 (#$C_) : page 3
*   bit3 bit2 bit1 bit0  (#$_0 a #$_F) : couleur du cadre
*   Remarque : bit5 et bit4 utilisable uniquement en mode MO
*
* Page en espace cartouche
* ------------------------
*   $E7E6 determine la page visible dans l'espace cartouche (0000 a 3FFF)
*   bit7 toujours a 0
*   bit6=1 : ecriture autorisee
*   bit5=1 : espace cartouche recouvert par de la RAM
*   bit4=0 : CAS1N valide : banques 0-15 / 1 = CAS2N valide : banques 16-31
*   bit5=1 bit4=0 bit3=0 bit2=0 bit1=0 bit0=0 (#$60) : page 0
*   ...
*   bit5=1 bit4=0 bit3=1 bit2=1 bit1=1 bit0=1 (#$6F) : page 15
*   bit5=1 bit4=1 bit3=0 bit2=0 bit1=0 bit0=0 (#$70) : page 16
*   ...
*   bit5=1 bit4=1 bit3=1 bit2=1 bit1=1 bit0=1 (#$7F) : page 31
*
* Demi-Page 0 en espace ecran (4000 a 5FFF)
* -----------------------------------------
*   $E7C3 determine la demi-page de la page 0 visible dans l'espace ecran
*   bit0=0 : 8Ko RAMA
*   bit0=1 : 8ko RAMB
*
* Page en espace donnees
* ----------------------
* lda   #$04
* sta   $E7E5                    * selection de la page 04 en RAM Donnees (A000-DFFF)
*
********************************************************************************
WaitVBL
 ifdef DO_NOT_WAIT_VBL
        ldd   gfxlock.frame.count
        subd  gfxlock.frame.lastCount
	cmpb  #2
	bhs   SwapVideoPage
 endc
@a
        tst   $E7E7              * le faisceau n'est pas dans l'ecran
        bpl   @a                 * tant que le bit est a 0 on boucle
@b
        tst   $E7E7              * le faisceau est dans l'ecran
        bmi   @b                 * tant que le bit est a 1 on boucle
                        
SwapVideoPage
        ldb   am_SwapVideoPage+1 * charge la valeur du ldb suivant am_SwapVideoPage
        andb  #$40               * alterne bit6=0 et bit6=1 (suivant la valeur B $00 ou $FF)
        orb   #$80               * bit7=1, bit3 a bit0=couleur de cadre (ici 0)
gfxlock.screenBorder.color equ *-1
        stb   $E7DD              * changement page (2 ou 3) affichee a l'ecran
        com   am_SwapVideoPage+1 * alterne $00 et $FF sur le ldb suivant am_SwapVideoPage
am_SwapVideoPage
        ldb   #$00
        andb  #$01               * alterne bit0=0 et bit0=1 (suivant la valeur B $00 ou $FF)
        stb   gfxlock.backBuffer.id
        orb   #$02               * bit1=1
        stb   $E7E5              * changement page (2 ou 3) visible dans l'espace donnees
        ldb   $E7C3              * charge l'identifiant de la demi-page 0 configuree en espace ecran
        eorb  #$01               * alterne bit0 = 0 ou 1 changement demi-page de la page 0 visible dans l'espace ecran
        stb   $E7C3
        
        inc   gfxlock.bufferSwap.count+1
        bne   @a
        inc   gfxlock.bufferSwap.count  
@a

        ldd   gfxlock.frame.count     ; store in gfxlock.frameDrop.count the number of elapsed 50Hz frames
        subd  gfxlock.frame.lastCount ; used in AnimateSpriteSync
	cmpb  Vint_Main_runcount_cap      ; allow to cap Animation and Mvt Sync
	bls   @a
	ldb   Vint_Main_runcount_cap
@a      stb   gfxlock.frameDrop.count

        ldd   gfxlock.frame.count
        std   gfxlock.frame.lastCount

        rts
        
gfxlock.bufferSwap.count  fdb   0 ; page swap counter
gfxlock.frame.count       fdb   0 ; incremented in 50Hz IRQ
gfxlock.frame.lastCount   fdb   0
gfxlock.frameDrop.count_w fcb   0 ; pad to be able to load Vint_Main_runcount as a word
gfxlock.frameDrop.count   fcb   0
Vint_Main_runcount_cap    fcb   -1
gfxlock.backBuffer.id     fcb   0 ; screen buffer set to write operations (0 or 1)
