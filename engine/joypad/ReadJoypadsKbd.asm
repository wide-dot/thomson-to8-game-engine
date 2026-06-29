********************************************************************************
* ReadJoypadsKbd - lecture joypad (V1) + "n'importe quelle touche clavier -> bouton B"
*
* Variante de ReadJoypads : memes variables et masques, tires du fichier de
* definitions partage joypad.const.asm (autonome, n'a plus besoin que ReadJoypads.asm
* soit inclus avant). N'IMPACTE PAS ReadJoypads (les autres jeux continuent a
* l'utiliser). Utilisee par R-Type pour l'instant ; a capitaliser ensuite.
*
* But : pour les manettes 1 bouton (bouton A seulement), permettre de declencher
* la fonction du second bouton (rappel du force pod) avec n'importe quelle touche
* clavier. Le flag KTEST (PIA systeme $E7C8 bit 0 = au moins une touche enfoncee)
* est injecte dans la lecture BRUTE du bouton B, AVANT la detection de front : donc
* Fire_Press (edge) et Fire_Held se comportent comme un vrai bouton B (front propre,
* pas de toggle en rafale tant que la touche reste enfoncee).
********************************************************************************

        INCLUDE "./engine/joypad/joypad.const.asm" ; masques + variables partages (garde IFNDEF)

ReadJoypadsKbd
        ldd   $E7CC                  ; A = dpad ($E7CC), B = boutons ($E7CD) (0: press)
        coma
        comb                         ; -> 1: press

        ; manette 1 bouton : KTEST clavier -> bouton B (avant la detection de front)
        pshs  a                      ; preserve le dpad
        lda   $E7C8                  ; PIA systeme, KTEST en bit 0
        lsra                         ; bit 0 -> C
        bcc   >                      ; C=0 : aucune touche -> rien
        orb   #c1_button_B_mask      ; C=1 : au moins une touche -> bouton B
!       puls  a

        std   Joypads_Read
        ldd   Joypads_Held
        eora  Dpad_Read
        eorb  Fire_Read
        anda  Dpad_Read
        andb  Fire_Read
        std   Joypads_Press
        ldd   Joypads_Read
        std   Joypads_Held
        rts
