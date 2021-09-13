********************************************************************************
* Chargement de donnees en RAM (TO8 Thomson) - Benoit Rousseau 26/04/2021
* ------------------------------------------------------------------------------
*
* Charge les donnees d'un mode de jeu depuis la Megarom T.2
* decompresse les donnees avec exomizer et copie ces donnees en RAM
*
* Les index de donnees sont stockees par groupe de 6 octets:
* ----------------------------------------------------------
* b: page T.2
* b: page RAM
* w: adresse T.2
* w: adresse RAM
*
* la derniere ligne contient comme premier octet une valeur negative (exemple $FF)
* en lieu et place de la page T.2
********************************************************************************

        INCLUDE "./Engine/Constants.asm"
        
        org   $4000
        opt   c,ct
        setdp $40                      ; dp for exomizer
        INCLUDE "./Engine/Compression/Exomizer.asm"  

RAMLoader
        ldx   #RL_RAM_index          
        
RL_While
        ldd   ,x++                     ; A: T2 src page, B: Dest RAM page
        bpl   RL_LoadData              ; valeur negative de secteur signifie fin du tableau de donnee
        jmp   $6100                    ; on lance le mode de jeu en page 1
        
RL_LoadData
        stb   $E7E5                    ; selection de la page en RAM Donnees (A000-DFFF)
      
        ldb   #$AA                     ; sequence pour commutation de page T.2
        stb   $0555
        ldb   #$55
        stb   $02AA
        ldb   #$C0
        stb   $0555
        sta   $0555                    ; selection de la page T.2

        ldu   ,x++                     ; source ROM (fin des donnees)
        ldy   ,x++                     ; destination RAM (fin des donnees)
        jsr   >exo2                    ; decompresse les donnees        
        bra   RL_While
fill        
        fill  0,7-((fill-exo2)%7)      ; le code est un multilpe de 7 octets (pour la copie)
        
RL_RAM_index 