glb_Page                      fcb   $00

SetCartPageA
        sta   glb_Page
        bpl   @RAMPg
        lda   $E7E6
        anda  #$DF                     ; passe le bit5 a 0 pour cartouche au lieu de 1 pour RAM
        sta   $E7E6
        lda   #$F0                     ; sortie du mode commande T.2
        sta   $0555                    ; dans le cas ou l'irq intervient en cours de changement de page
        lda   #$AA                     ; sequence pour commutation de page T.2
        sta   $0555
        lsra                           ; lda   #$55
        sta   $02AA
        lda   #$C0
        sta   $0555
        lda   glb_Page
        anda  #$7F                     ; le bit 7 doit etre a 0        
        sta   $0555                    ; selection de la page T.2 en zone cartouche
        bra   @rts
@RAMPg  sta   $E7E6                    ; selection de la page RAM en zone cartouche (bit 5 integre au numero de page)
@rts    rts

SetCartPageB
        stb   glb_Page
        bpl   @RAMPg
        ldb   $E7E6
        andb  #$DF                     ; passe le bit5 a 0 pour cartouche au lieu de 1 pour RAM
        stb   $E7E6
        ldb   #$F0                     ; sortie du mode commande T.2
        stb   $0555                    ; dans le cas ou l'irq intervient en cours de changement de page
        ldb   #$AA                     ; sequence pour commutation de page T.2
        stb   $0555
        lsrb                           ; lda   #$55
        stb   $02AA
        ldb   #$C0
        stb   $0555
        ldb   glb_Page
        andb  #$7F                     ; le bit 7 doit etre a 0        
        stb   $0555                    ; selection de la page T.2 en zone cartouche
        bra   @rts
@RAMPg  stb   $E7E6                    ; selection de la page RAM en zone cartouche (bit 5 integre au numero de page)
@rts    rts

GetCartPageA
        lda   glb_Page                 ; glb_page at 0 means that glb_page variable is not in use
	bne   @rts                     ; usefull when we dont work with T2 (ex: optimized tilemap that use only RAM)
	lda   $E7E6
@rts    rts

GetCartPageB
        ldb   glb_Page                 ; glb_page at 0 means that glb_page variable is not in use
	bne   @rts                     ; usefull when we dont work with T2 (ex: optimized tilemap that use only RAM)
	ldb   $E7E6
@rts   rts

