********************************************************************************
* Gestionnaire de chargement du RAM Loader (TO8 Thomson) - Benoit Rousseau 07/11/2020
* ------------------------------------------------------------------------------
*
* Copie en page 0 le programme de chargement de RAM, ainsi que les index
* des donnees du niveau de jeu a charger
*
* input REG : [a] Game Mode to load
*             [b] Current Game Mode
*
********************************************************************************

        INCLUDE "./GeneratedCode/RAMLoaderFd.glb"
        
        org $0000

RAMLoaderManager

* Copie en page 0a des donnees du mode a charger
* les groupes de 7 octets sont recopiees a l'envers
* la fin des donnees est marquee par un octet negatif ($FF par exemple)
************************************************************            
        sts   RLM_CopyCode_restore_s+2 ; sauve s
        ldu   #Gm_Index
        aslb
        ldx   b,u                      ; load address of current game mode data        
        asla
        ldu   a,u                      ; load address of new game mode data
        
        lds   -2,u                     ; load destination address
        tstb
        bmi   RLM_SetPage              ; negative value means first load so nothing to compare
        
RLM_SkipCommon        
        ldd   ,u
        cmpd  ,x   
        bne   RLM_SetPage
        ldd   2,u
        cmpd  2,x   
        bne   RLM_SetPage
        ldd   4,u
        cmpd  4,x   
        bne   RLM_SetPage
        lda   6,u
        cmpa  6,x   
        bne   RLM_SetPage                        
        leas  -7,s                     ; adjust destination address
        leau  7,u                      ; adjust new Game Mode source address
        leax  7,x                      ; adjust current Game Mode source address
        bra   RLM_SkipCommon
        
* Positionnement de la page 0a en zone 4000-5FFF
***********************************************************
RLM_SetPage
        ldb   $E7C3                    ; charge l'id de la demi-Page 0 en espace ecran
        andb  #$FE                     ; positionne bit0=0 pour page 0 RAMA
        stb   $E7C3                    ; dans l'espace ecran        
        
        lda   #$FF                     ; ecriture balise de fin
        pshs  a                        ; pour GameModeEngine
RLM_CopyData
        pulu  d,x,y,dp                 ; on lit 7 octets
        pshs  d,x,y,dp                 ; on ecrit 7 octets
        tsta                           ; balise de fin dans REG A
        bpl   RLM_CopyData             ; non => boucle
        leas  7,s                      ; on remote de 7 car le dernier bloc est une balise de fin

* Copie en page 0a du code RAMLoader
* les groupes de 7 octets sont recopiees a l'envers, le builder va inverser
* les donnees a l'avance on gagne un leas dans la boucle.
************************************************************    
        ldu   #RAMLoaderBin            ; source
RLM_CopyCode
        pulu  d,x,y,dp                 ; on lit 7 octets
        pshs  d,x,y,dp                 ; on ecrit 7 octets
        cmps  #$4000                   ; fin ?
        bne   RLM_CopyCode             ; non => boucle
RLM_CopyCode_restore_s
        lds   #0                       ; restaure s
        
* Execution du RAMLoader en page 0a
************************************************************         
        jmp   RAMLoader     

* ==============================================================================
* RAMLoader
* ==============================================================================
RAMLoaderBin
        INCLUDEBIN "./GeneratedCode/RAMLoaderFd.bin"
        INCLUDE "./GeneratedCode/BuilderFileIndexFd.asm"
