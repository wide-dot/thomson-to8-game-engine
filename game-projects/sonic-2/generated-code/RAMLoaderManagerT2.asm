	org   $010E

********************************************************************************
* Gestionnaire de chargement du RAM Loader (TO8 Thomson) - Benoit Rousseau 26/04/2021
* ------------------------------------------------------------------------------
* 
* Copie en page 0 le programme de chargement de RAM, ainsi que les index
* des donnees du niveau de jeu a charger
*
* input REG : [a] Game Mode to load
*             [b] Current Game Mode
*
********************************************************************************
        
        INCLUDE "RAMLoaderT2.glb"
        
RAMLoaderManager

* Copie en page 0a des donnees du mode a charger
* les groupes de 6 octets sont recopiees a l'envers
* la fin des donnees est marquee par un octet negatif ($FF par exemple)
************************************************************            
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
        leas  -6,s                     ; adjust destination address
        leau  6,u                      ; adjust new Game Mode source address
        leax  6,x                      ; adjust current Game Mode source address
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
        pulu  d,x,y                    ; on lit 6 octets
        pshs  d,x,y                    ; on ecrit 6 octets
        tsta                           ; balise de fin dans REG A
        bpl   RLM_CopyData             ; non => boucle
        leas  6,s                      ; on remote de 6 car le dernier bloc est une balise de fin

* Copie en page 0a du code Game Mode Engine
* les groupes de 7 octets sont recopiees a l'envers, le builder va inverser
* les donnees a l'avance on gagne un leas dans la boucle.
************************************************************    
        ldu   #RAMLoaderBin            ; source
RLM_CopyCode
        pulu  d,x,y,dp                 ; on lit 7 octets
        pshs  d,x,y,dp                 ; on ecrit 7 octets
        cmps  #$4000                   ; fin ?
        bne   RLM_CopyCode             ; non => boucle
        
* Execution du Game Mode Engine en page 0a
************************************************************
        lds   #glb_system_stack         ; positionnement pile systeme
        lda   glb_direct_page         ; set direct page to access globals
		tfr   a,dp         
        jmp   RAMLoader     

* ==============================================================================
* RAMLoader
* ==============================================================================
RAMLoaderBin
        INCLUDEBIN "RAMLoaderT2.bin"
        INCLUDE "BuilderFileIndexT2.asm"
