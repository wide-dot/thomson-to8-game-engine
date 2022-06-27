********************************************************************************
* Chargement de donnees en RAM (TO8 Thomson) - Benoit Rousseau 10/11/2020
* ------------------------------------------------------------------------------
*
* Charge les donnees d'un mode de jeu depuis la disquette
* decompresse les donnees avec exomizer et copie ces donnees en RAM
* Les donnees sont stockees par groupe de 7 octets
* Donnees b: SEC, b: DRV/TRK, b: nb SEC, b: offset de fin, b: dest Page, w: dest Adresse
* la derniere ligne contient comme premier octet une valeur negative (exemple $FF)
* Remarque:
* ---------
* Les donnees sur la disquette sont continues. Lorsque des donnees se terminent a moitie
* sur un secteur, les donnees de fin sont ignorees par l'offset. Si les donnees commencent
* en milieu de secteur, c'est l'exomizer qui s'arretera. On optimise ainsi l'espace disquette
* il n'y a pas de separateur ni de blanc entre les donnees.
*
********************************************************************************

        INCLUDE "./Engine/Constants.asm"
        
        org   $4000
        opt   c,ct
        setdp $40                      ; dp for exomizer
start        
        INCLUDE "./Engine/Compression/Exomizer.asm"  

RAMLoader 
        ldb   $E7E5
        orb   #$60                     ; charge la page video de travail et la positionne
        stb   $E7E6                    ; dans l'espace cartouche comme buffer pour exomizer
        
        ldu   #RL_RAM_index
        pshs  u
        
RAMLoader_continue
        setdp $60
        lda   #$60
        tfr   a,dp                     ; positionne la direct page a 60

        ldd   ,u++
        bpl   RL_Continue              ; valeur negative de secteur signifie fin du tableau de donnee
        lds   #glb_system_stack         ; reinit de la pile systeme
		
	lda   #dp/256             ; set direct page to access globals
	tfr   a,dp
		        
        jmp   $6100                    ; on lance le mode de jeu en page 1
RL_Continue        
        sta   <dk_sector              ; secteur (1-16)
        stb   RL_DKDernierBloc+2       ; nombre de secteurs a lire
        
        ldb   ,u+                      ; lecture du lecteur et du secteur
        sex                            ; encodes dans un octet :
        anda  #$01                     ; d7: lecteur (0-1)
        andb  #$7F                     ; d6-d0: piste (0-79)
        sta   <dk_drive
        lda   #$00
        std   <dk_track
        
        ldb   #$00                     ; le buffer DKCO est toujours positionne a $0000
        std   <dk_write_location
        
        pulu  d,y                      ; y adresse de fin des donnees de destination
        sta   RL_NegOffset+3           ; nombre d'octets inutilises dans le dernier secteur disquette
        stb   RL_Page+1
        
        pshs  u        

        lda   #$02
        sta   <$6048                   ; DK.OPC $02 Operation - lecture d'un secteur
RL_DKCO
        jsr   $E82A                    ; DKCO Appel Moniteur - lecture d'un secteur
        inc   <dk_sector              ; increment du registre Moniteur DK.SEC
        lda   <dk_sector              ; chargement de DK.SEC
        cmpa  #$10                     ; si DK.SEC est inferieur ou egal a 16
        bls   RL_DKContinue            ; on continue le traitement
        lda   #$01                     ; sinon on a depasse le secteur 16
        sta   <dk_sector              ; positionnement du secteur a 1
        inc   <dk_track_lsb               ; increment du registre Moniteur DK.TRK
        lda   <dk_track_lsb
        cmpa  #$4F                     ; si DK.SEC est inferieur ou egal a 79
        bls   RL_DKContinue            ; on continue le traitement
        clr   <dk_track_lsb               ; positionnement de la piste a 0
        inc   <dk_drive              ; increment du registre Moniteur DK.DRV
RL_DKContinue                            
        inc   <$604F                   ; increment de 256 octets de la zone a ecrire DK.BUF
        ldu   <$604F                   ; chargement de la zone a ecrire DK.BUF
RL_DKDernierBloc                        
        cmpu  #0                       ; test debut du dernier bloc de 256 octets a ecrire
        bls   RL_DKCO                  ; si DK.BUF inferieur ou egal a la limite alors DKCO
        lda   RL_NegOffset+3           ; charge l'offset
        beq   RL_Page                     ; on ne traite que si offset > 0
        leau  $0100,u                  ; astuce pour conserver un code de meme taille sur l'instruction ci dessous peu importe la taille du leau
RL_NegOffset        
        leau  $FE00,u                  ; adresse de fin des donnees compressees - offset - 256 (astuce ci dessus)
RL_Page
        lda   #0                       ; page memoire
        sta   $E7E5                    ; selection de la page en RAM Donnees (A000-DFFF)
        jsr   exo2                     ; decompresse les donnees
        puls  u
        bra   RAMLoader_continue
fill        
        fill  0,7-((fill-start)%7)      ; le code est un multilpe de 7 octets (pour la copie)
        
RL_RAM_index 