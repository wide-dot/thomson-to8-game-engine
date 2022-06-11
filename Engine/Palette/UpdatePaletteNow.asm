* ---------------------------------------------------------------------------
* UpdatePaletteNow
* ----------------
* Subroutine to update palette
* should be called just after WaitVBL
*
* input REG : none
* reset REG : [d] [x] [y]
* ---------------------------------------------------------------------------

Refresh_palette fcb   $FF            
Cur_palette     fdb   Dyn_palette    
Dyn_palette     fill  0,$20          

UpdatePaletteNow 
        tst   Refresh_palette
        beq   @a
	rts
@a      pshs  dp        
        ldb   #$E7
        tfr   b,dp        
        ldx   Cur_palette
        clr   <$DB                     * indice couleur a 0
        ldy   #$0010                   * init cpt
UPP_SetColor
        ldd   ,x++                     * chargement de la couleur et increment du poiteur x
        sta   <$DA                     * set de la couleur Vert et Rouge
        stb   <$DA                     * set de la couleur Bleu
        leay  -1,y
        bne   UPP_SetColor             * on reboucle si fin de liste pas atteinte
        com   Refresh_palette          * update flag, next run this routine will be ignored if no pal update is requested
UPP_return
        puls dp,pc

        
        
