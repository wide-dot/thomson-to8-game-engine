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
        bne   @rts
        ldx   Cur_palette
        clr   $E7DB                    * indice couleur a 0
        ldy   #$0010                   * init cpt
@loop   ldd   ,x++                     * chargement de la couleur et increment du poiteur x
        sta   $E7DA                    * set de la couleur Vert et Rouge
        stb   $E7DA                    * set de la couleur Bleu
        leay  -1,y
        bne   @loop                    * on reboucle si fin de liste pas atteinte
        com   Refresh_palette          * update flag, next run this routine will be ignored if no pal update is requested
@rts    rts

        
        
