; ---------------------------------------------------------------------------
; Object - RasterFade
;
; input REG : [u] pointeur sur l'objet (SST)
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"   
        INCLUDE "./objects/engine/sfx/raster-fade/raster-fade.idx"        

RasterFade
        lda   routine,u
        asla
        ldx   #RasterFade_Routines
        jmp   [a,x]
 
RasterFade_Routines
        fdb  RasterFade_SubtypeInit
        fdb  RasterFade_InInit
        fdb  RasterFade_OutInit
        fdb  RasterFade_Main
        fdb  RasterCycle_Main

RasterFade_SubtypeInit
        lda   subtype,u
        sta   routine,u
        bra   RasterFade 

RasterFade_InInit
        lda   #Sub_RasterMain
        sta   routine,u 
        
        clr   raster_cycle_idx,u
        
        lda   raster_frames,u
        sta   raster_cur_frame,u
        
        lda   $E7E6
        sta   Irq_Raster_Page
        
        ldx   #pal_RasterCurrent                      ; calcul des adresses de debut et de fin
        stx   Irq_Raster_Start                        ; pour les donnees de palette
        stx   RFA_InitColor_endloop1+1
        
        lda   #$03                                    ; affectation aux variables globales de
        ldb   raster_nb_colors,u                      ; la routine Irq Raster
        mul
        leax  d,x
        stx   Irq_Raster_End        
        stx   RFA_end+2
        stx   RFA_InitColor_endloop3+1
        
        ldx   #pal_RasterCurrent        
        lda   #$03
        ldb   raster_nb_fade_colors,u
        mul
        leax  d,x        
        stx   RFA_InitColor_endloop2+1
        
        lda   raster_inc,u                            ; precalcul de l'increment
        asla                                          ; 1 devient 11, A devient AA ...
        asla
        asla
        asla
        adda  raster_inc,u
        sta   raster_inc_,u
                
        ldd   raster_color,u                          ; positionne la couleur de depart sur un tableau raster
RFA_InitColor_loop1
        leax  -3,x
        std   1,x
RFA_InitColor_endloop1        
        cmpx  #$0000
        bne   RFA_InitColor_loop1

        lda   raster_pal_dst,u                        ; recopie les index de couleur cible dans le tableau raster
        ldy   #Pal_Index
        ldy   a,y
RFA_InitColor_loop2
        lda   ,y
        leay  3,y
        sta   ,x
        leax  3,x
RFA_InitColor_endloop2        
        cmpx  #$0000
        bne   RFA_InitColor_loop2
        bra   RFA_InitColor_endloop3
        
RFA_InitColor_loop3                                   
        lda   ,y+                                     ; copie des index et couleurs non traite par le fade
        sta   ,x+
        ldd   ,y++
        std   ,x++        
RFA_InitColor_endloop3        
        cmpx  #$0000          
        bne   RFA_InitColor_loop3
        rts                                                                                                                

*******************************************************************************

RasterFade_OutInit
        lda   #Sub_RasterMain
        sta   routine,u 
        
        clr   raster_cycle_idx,u
        
        lda   raster_frames,u
        sta   raster_cur_frame,u
        
        lda   $E7E6
        sta   Irq_Raster_Page
        
        ldx   #pal_RasterCurrent                      ; calcul des adresses de debut et de fin
        stx   Irq_Raster_Start                        ; pour les donnees de palette
        
        lda   #$03                                    ; affectation aux variables globales de
        ldb   raster_nb_colors,u                      ; la routine Irq Raster
        mul
        leax  d,x
        stx   Irq_Raster_End        
        stx   RFA_end+2
        stx   RFA_OutInitColor_endloop3+1
        
        ldx   #pal_RasterCurrent       
        lda   #$03
        ldb   raster_nb_fade_colors,u
        mul
        leax  d,x        
        stx   RFA_OutInitColor_endloop2+1
        
        lda   raster_inc,u                            ; precalcul de l'increment
        asla                                          ; 1 devient 11, A devient AA ...
        asla
        asla
        asla
        adda  raster_inc,u
        sta   raster_inc_,u
                
        ldx   Irq_Raster_Start
        lda   raster_pal_dst,u                        ; recopie les index de couleur cible dans le tableau raster
        ldy   #Pal_Index
        ldy   a,y
RFA_OutInitColor_loop2
        lda   ,y
        leay  3,y
        sta   ,x
        leax  3,x
RFA_OutInitColor_endloop2        
        cmpx  #$0000
        bne   RFA_OutInitColor_loop2
        bra   RFA_OutInitColor_endloop3
        
RFA_OutInitColor_loop3                                   
        lda   ,y+                                     ; copie des index et couleurs non traite par le fade
        sta   ,x+
        ldd   ,y++
        std   ,x++        
RFA_OutInitColor_endloop3        
        cmpx  #$0000          
        bne   RFA_OutInitColor_loop3
        rts                                                               
                                                 
RasterFade_Main
        dec   raster_cur_frame,u
        beq   RFA_Continue   
        bra   RasterCycle_Main
          
RFA_Continue
        lda   raster_frames,u
        sta   raster_cur_frame,u
        
        lda   raster_pal_dst,u                        ; recopie les index de couleur cible dans le tableau raster
        ldx   #Pal_Index
        ldx   a,x
        leax  1,x
        ldy   #pal_RasterCurrent+1
        dec   raster_cycles,u          * decremente le compteur du nombre de frame
        bne   RFA_Loop                 * on reboucle si nombre de frame n'est pas realise
        inc   routine,u
        lda   Vint_runcount+1
        sta   raster_cycle_frame,u        
        bra   RasterCycle_Main
        
RFA_Loop
        lda   1,y	                   * chargement de la composante verte et rouge
        anda  pal_mask                 * on efface la valeur vert ou rouge par masque
        ldb   1,x                      * composante verte et rouge couleur cible
        andb  pal_mask                 * on efface la valeur vert ou rouge par masque
        stb   pal_buffer               * on stocke la valeur cible pour comparaison
        ldb   raster_inc_,u            * preparation de la valeur d'increment de couleur
        andb  pal_mask                 * on efface la valeur non utile par masque
        stb   pal_buffer+1             * on stocke la valeur pour ADD ou SUB ulterieur
        cmpa  pal_buffer               * comparaison de la composante courante et cible
        beq   RFA_VRSuivante           * si composante est egale a la cible on passe
        bhi   RFA_VRDec                * si la composante est superieure on branche
        lda   1,y                      * on recharge la valeur avec vert et rouge
        adda  pal_buffer+1             * on incremente la composante verte ou rouge
        bra   RFA_VRSave               * on branche pour sauvegarder
RFA_VRDec
        lda   1,y                      * on recharge la valeur avec vert et rouge
        suba  pal_buffer+1             * on decremente la composante verte ou rouge
RFA_VRSave                             
        sta   1,y                      * sauvegarde de la nouvelle valeur vert ou rouge
RFA_VRSuivante                         
        com   pal_mask                 * inversion du masque pour traiter l'autre semioctet
        bmi   RFA_Loop                 * si on traite $F0 on branche sinon on continue
	    
RFA_SetPalBleu
        ldb   ,y                       * chargement composante bleue courante
        cmpb  ,x                       * comparaison composante courante et cible
        beq   RFA_SetPalNext           * si composante est egale a la cible on passe
        bhi   RFA_SetPalBleudec        * si la composante est superieure on branche
        subb  raster_inc,u             * on incremente la composante bleue
        bra   RFA_SetPalSaveBleu       * on branche pour sauvegarder
RFA_SetPalBleudec                       
        subb  raster_inc,u             * on decremente la composante bleue
RFA_SetPalSaveBleu                         
        stb   ,y                       * sauvegarde de la nouvelle valeur bleue
								       
RFA_SetPalNext                             
        leay  3,y                      * on avance le pointeur vers la nouvelle couleur source
        leax  3,x                      * on avance le pointeur vers la nouvelle couleur dest
RFA_end        
        cmpy  #$0000
        blo   RFA_Loop                 * on reboucle si fin de liste pas atteinte
        rts
        
RasterCycle_Main     
        lda   Vint_runcount+1
        suba  raster_cycle_frame,u
        cmpa  #8
        blo   RasterCycle_Main_end

        lda   Vint_runcount+1
        sta   raster_cycle_frame,u
        
        lda   raster_cycle_idx,u
        inca
        cmpa  #6
        bne   RasterCycle_Main_continue
        lda   #0
RasterCycle_Main_continue
        sta   raster_cycle_idx,u
        asla
        
        ldx   #Pal_TitleScreenCycle
        ldx   a,x
        ldy   #pal_RasterCurrent+124        
        stx   ,y
        
RasterCycle_Main_end
        rts        
        
* ---------------------------------------------------------------------------
* Local data
* ---------------------------------------------------------------------------
        
pal_mask     fcb $0F                   * masque pour l'aternance du traitemet vert/rouge
pal_buffer   fdb $00                   * buffer de comparaison
pal_RasterCurrent fill 0,600

Pal_TitleScreenCycle
		fdb   $0e00
		fdb   $0c10
		fdb   $0e00		
		fdb   $0b41
		fdb   $0e00				
		fdb   $0b74 
Pal_TitleScreenCycle_end	

Pal_Index
        fdb   Pal_TitleScreenRaster
        fdb   Pal_TitleScreenRasterBlack
                   
Pal_TitleScreenRaster
        fcb   $08
        fdb   $0020	* 148-154 island 4
        fcb   $0a
        fdb   $0040	* 148-154 island 5
        fcb   $12
        fdb   $0071	* 148-154 island 9
        fcb   $14
        fdb   $00a4	* 148-154 island 10		
        fcb   $1e
        fdb   $0b10	* 148-154
        fcb   $1e
        fdb   $0c00
        fcb   $1e
        fdb   $0b10	* 148-154 
        fcb   $1e
        fdb   $0b10	* 148-154
        fcb   $1e
        fdb   $0c00
        fcb   $1e
        fdb   $0b10	* 148-154
        fcb   $0e
        fdb   $0026	* 148-154 island 7
        fcb   $0c
        fdb   $014a	* 148-154 island 6
        fcb   $10
        fdb   $0fff	* 148-154 island 8
        fcb   $1e
        fdb   $0b10	* 148-154
        fcb   $1e
        fdb   $0c10	* 155-157
        fcb   $1e
        fdb   $0b10	* 148-154
        fcb   $1e
        fdb   $0c10	* 155-157
        fcb   $1e
        fdb   $0a21	* 158-161
        fcb   $1e
        fdb   $0c10	* 155-157
        fcb   $1e
        fdb   $0a21	* 158-161
        fcb   $1e
        fdb   $0a21	* 158-161
        fcb   $1e
        fdb   $0b41	* 162-164
        fcb   $1e
		fdb   $0a21	* 158-161
        fcb   $1e
        fdb   $0b41	* 162-164
        fcb   $1e
        fdb   $0a52	* 165-167
        fcb   $1c
        fdb   $0123	* 165-167 island 14
        fcb   $06
        fdb   $026a	* 165-167 island 3
        fcb   $1e
        fdb   $0b74	* 168-171
        fcb   $1e
		fdb   $0a52	* 165-167
        fcb   $1e
        fdb   $0b74	* 168-171
        fcb   $1e
		fdb   $0b74	* 168-171
        fcb   $1e
        fdb   $0b97	* 172-174
        fcb   $1e
		fdb   $0b74	* 168-171
        fcb   $1e
        fdb   $0b97	* 172-174
        fcb   $1e
        fdb   $0bbb	* 175-180
        fcb   $1e
		fdb   $0b97	* 172-174
        fcb   $1e
        fdb   $0bbb	* 175-180
        fcb   $18
		fdb   $0e00	* 175-180 island 12
        fcb   $04
		fdb   $0c10	* 175-180 island 2
        fcb   $00
		fdb   $0b41	* 175-180 island 0
        fcb   $1a
		fdb   $0b74	* 175-180 island 13
        fcb   $16
		fdb   $0a42	* 175-180 island 11
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131
        fcb   $1e
        fdb   $0c00	* 181-131	
        fcb   $00
        fdb   $0fff	* title screen 0		
        fcb   $04
        fdb   $0008	* title screen 2
        fcb   $06
        fdb   $0002	* title screen 3
        fcb   $08
        fdb   $035d	* title screen 4
        fcb   $0a
        fdb   $0016	* title screen 5
        fcb   $0c
        fdb   $004f	* title screen 6
        fcb   $0e
        fdb   $0027	* title screen 7
        fcb   $10
        fdb   $00ff	* title screen 8        
        fcb   $12
        fdb   $00f3	* title screen 9
        fcb   $14
        fdb   $0ff8	* title screen 10
        fcb   $16
        fdb   $0e64	* title screen 11
        fcb   $18
        fdb   $0522	* title screen 12
        fcb   $1a
        fdb   $0e00	* title screen 13
        fcb   $1c
        fdb   $0001	* title screen 14        

Pal_TitleScreenRasterBlack
        fcb   $08
        fdb   $0000
        fcb   $0a
        fdb   $0000
        fcb   $12
        fdb   $0000
        fcb   $14
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $0e
        fdb   $0000
        fcb   $0c
        fdb   $0000
        fcb   $10
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1c
        fdb   $0000
        fcb   $06
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $18
        fdb   $0000
        fcb   $04
        fdb   $0000
        fcb   $00
        fdb   $0000
        fcb   $1a
        fdb   $0000
        fcb   $16
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $1e
        fdb   $0000
        fcb   $00
        fdb   $0000
        fcb   $04
        fdb   $0000
        fcb   $06
        fdb   $0000
        fcb   $08
        fdb   $0000
        fcb   $0a
        fdb   $0000
        fcb   $0c
        fdb   $0000
        fcb   $0e
        fdb   $0000
        fcb   $10
        fdb   $0000
        fcb   $12
        fdb   $0000
        fcb   $14
        fdb   $0000
        fcb   $16
        fdb   $0000
        fcb   $18
        fdb   $0000
        fcb   $1a
        fdb   $0000
        fcb   $1c
        fdb   $0000