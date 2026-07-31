* ---------------------------------------------------------------------------
* PixelFade - fondu au noir par tramage, en place dans la page video courante
* ---------------------------------------------------------------------------
* Extrait de R-Type (objects/levels/endstage/obj_endstage.asm) pour etre
* reutilisable. Origine : routine de fondu "Accolade presents".
*
* Principe : le motif FadeOutPattern est une permutation des 8x10 = 80 cellules
* d'un pave de 8 px x 10 lignes. Une cellule = (colonne, ligne) ou la colonne
* encode, sur 3 bits, {quel demi-octet, quel plan RAMA/RAMB, quel octet pair ou
* impair} - soit 8 positions horizontales - et la ligne l'une des 10 lignes du
* pave. Chaque appel a FadeOut traite UNE cellule sur TOUT l'ecran (20 lignes
* x 20 octets = 400 px) en masquant un demi-octet a zero.
*
* 80 cellules x 400 px = 32000 px = exactement une page. Le compteur est arme a
* 2 x FadeLen car FadeOut fait "decb PUIS lsrb" : chaque cellule est donc
* indexee deux fois de suite, ce qui couvre les DEUX pages video en double
* buffering (le buffer alterne a chaque appel).
*
* API :
*   InitFadeOut : arme le compteur. A appeler une fois avant la sequence.
*   FadeOut     : traite une cellule sur la page montee. A appeler une fois par
*                 trame, DANS le verrou graphique. Retourne immediatement quand
*                 le fondu est termine.
*   FadeCnt     : compteur restant (octet). 0 = fondu termine.
*   FadeLen     : nombre de cellules du motif (80). Constante d'assemblage.
*
* Le motif est choisi par PATTERN (ACCOLAD, DIAG ou BAYER8).
* Clobbe : a, b, x, u. Ecrit dans son propre code (auto-modifiant).
* ---------------------------------------------------------------------------

ACCOLAD equ     1
DIAG    equ     2
BAYER8  equ     3
PATTERN equ     ACCOLAD

InitFadeOut
        ; FadeLen*2 pas, ni plus ni moins. MESURE (game-mode fadetest, banc isole) :
        ; les deux pages remplies a $FF, 30980 octets non nuls avant, puis
        ;     160 pas -> 0 octet non nul restant
        ;     161 pas -> 0 octet non nul restant
        ; Une cellule manquee en laisserait ~800, la resolution est donc large.
        ; Le 161e pas n'apporte rien : il indexe FadeOutPattern[FadeLen], hors des
        ; 80 cellules, donc il ne peut que repeter une cellule deja traitee.
        ;
        ; Rappel du compte : FadeOut fait "decb PUIS lsrb", le compteur parcourt
        ; 2*FadeLen-1..0 et indexe chaque cellule DEUX fois de suite ; le buffer
        ; alternant a chaque appel, chaque cellule est traitee une fois par page.
        ldb     #FadeLen*2
        stb     FadeCnt
        rts

FadeOut ldb     #0
FadeCnt set     *-1
        bne     >
        rts
!       decb
        stb     FadeCnt
        ldx     #FadeOutPattern
        lsrb
        abx
        ldd     #$0FE0  ; A=mask
        andb    ,x      ; keep b7b6b5
        bitb    #32     ; b5=1 ?
        beq     >
        subd    #$1F20  ; invert mask and clear b5
!       ldu     #@mask2+1
        sta     ,u
        sta     1,u
; plan rama/ramb
        lda     #$A0    ; rama
        lslb            ; carry = b7
        bpl     >       ; old b6=0 ?
        lda     #$C0    ; no=> ramb
!       rolb            ; put old b7 in b0, hence b=0/1
        std     @plan+1
        addd    #8000
        std     @tstend+1
        ldd     #40*256+31
        andb    ,x      ; extract line offset
        mul             ; convert to screen offset
; calcule adresse buffer video 
@plan   addd    #$CAFE  ; add screen-plane start
        tfr     d,x     ; result in X
        ldd     ,u
        std     <@mask0-@mask2,u
        std     <@mask1-@mask2,u
;       std     <@mask2-@mask2,u
        std     <@mask3-@mask2,u
        std     <@mask4-@mask2,u
        std     <@mask5-@mask2,u
        std     <@mask6-@mask2,u
        std     <@mask7-@mask2,u
        std     <@mask8-@mask2,u
        std     <@mask9-@mask2,u
@mask0  ldd   #0
        anda  ,x
        sta   ,x
        andb  2,x
        stb   2,x
@mask1  ldd   #0
        anda  4,x
        sta   4,x
        andb  6,x
        stb   6,x
@mask2  ldd   #0
        anda  8,x
        sta   8,x
        andb  10,x
        stb   10,x
@mask3  ldd   #0
        anda  12,x
        sta   12,x
        andb  14,x
        stb   14,x
@mask4  ldd   #0
        anda  16,x
        sta   16,x
        andb  18,x
        stb   18,x
@mask5  ldd   #0
        anda  20,x
        sta   20,x
        andb  22,x
        stb   22,x
@mask6  ldd   #0
        anda  24,x
        sta   24,x
        andb  26,x
        stb   26,x
@mask7  ldd   #0
        anda  28,x
        sta   28,x
        andb  30,x
        stb   30,x
@mask8  ldd   #0
        anda  32,x
        sta   32,x
        andb  34,x
        stb   34,x
@mask9  ldd   #0
        anda  36,x
        sta   36,x
        andb  38,x
        stb   38,x
        leax    40*(FadeLen/8),x ; ligne suivante
@tstend cmpx    #$DEAD  ; screen done ?
        lbcs    @mask0  ; no => process a nes line
        rts

; Accolade presents fading-out
; ----------------------------

; matrice de tramage (codée en dur)
;     0  1  2  3  4  5  6  7
; 0:  1 51 11 21 61 31 71 41        0
; 1: 18 58 28 68 38 78 48  8 
; 2: 65 35 75 45  5 55 15 25 
; 3: 42  2 52 12 22 62 32 72        1
; 4:  9 19 59 29 69 39 79 49 
; 5: 26 66 36 76 46  6 56 16 
; 6: 73 43  3 53 13 23 63 33        2
; 7: 50 10 20 60 30 70 40 80 
; 8: 17 27 67 37 77 47  7 57 
; 9: 34 74 44  4 54 14 24 64        3

; coord colonne,ligne avec 0 <= colonne <= 7 
; le framework gère des motifs de 8 pix horiz,
; et jusqu'à 32 vertical

coord   macro
        fcb     32*(\1)+(\2)
        endm

FadeOutPattern
        ifeq    PATTERN-ACCOLAD
; Accolade presnts
        coord   7,7     ; 80
        coord   6,4     ; 79
        coord   5,1     ; 78
        coord   4,8     ; 77
        coord   3,5     ; 76
        coord   2,2     ; 75
        coord   1,9     ; 74
        coord   0,6     ; 73
        coord   7,3     ; 72
        coord   6,0     ; 71
        
        coord   5,7     ; 70
        coord   4,4     ; 69
        coord   3,1     ; 68
        coord   2,8     ; 67
        coord   1,5     ; 66
        coord   0,2     ; 65
        coord   7,9     ; 64
        coord   6,6    ; 63
        coord   5,3     ; 62
        coord   4,0     ; 61
        
        coord   3,7     ; 60
        coord   2,4     ; 59
        coord   1,1     ; 58
        coord   7,8     ; 57
        coord   6,5     ; 56
        coord   5,2     ; 55
        coord   4,9     ; 54
        coord   3,6     ; 53
        coord   2,3     ; 52
        coord   1,0     ; 51
        
        coord   0,7     ; 50
        coord   7,4     ; 49
        coord   6,1     ; 48
        coord   5,8     ; 47
        coord   4,5     ; 46
        coord   3,2     ; 45
        coord   2,9     ; 44
        coord   1,6     ; 43
        coord   0,3     ; 42
        coord   7,0     ; 41

        coord   6,7     ; 40
        coord   5,4     ; 39
        coord   4,1     ; 38
        coord   3,8     ; 37
        coord   2,5     ; 36
        coord   1,2     ; 35
        coord   0,9     ; 34
        coord   7,6     ; 33
        coord   6,3     ; 32
        coord   5,0     ; 31

        coord   4,7     ; 30
        coord   3,4     ; 29
        coord   2,1     ; 28
        coord   1,8     ; 27
        coord   0,5     ; 26
        coord   7,2     ; 25
        coord   6,9     ; 24
        coord   5,6     ; 23
        coord   4,3     ; 22
        coord   3,0     ; 21

        coord   2,7     ; 20
        coord   1,4     ; 19
        coord   0,1     ; 18 <== irrégularité
        coord   0,8     ; 17
        coord   7,5     ; 16
        coord   6,2     ; 15
        coord   5,9     ; 14
        coord   4,6     ; 13
        coord   3,3     ; 12
        coord   2,0     ; 11

        coord   1,7     ; 10
        coord   0,4     ; 9
        coord   7,1     ; 8
        coord   6,8     ; 7
        coord   5,5     ; 6
        coord   4,2     ; 5
        coord   3,9     ; 4
        coord   2,6     ; 3
        coord   1,3     ; 2
        coord   0,0     ; 1
        endc

        ifeq    PATTERN-DIAG
        coord   7,0
        coord   6,1
        coord   5,2
        coord   4,3
        coord   3,4
        coord   2,5
        coord   1,6
        coord   0,7

        coord   7,1
        coord   6,2
        coord   5,3
        coord   4,4
        coord   3,5
        coord   2,6
        coord   1,7
        coord   0,0

        coord   7,2
        coord   6,3
        coord   5,4
        coord   4,5
        coord   3,6
        coord   2,7
        coord   1,0
        coord   0,1

        coord   7,3
        coord   6,4
        coord   5,5
        coord   4,6
        coord   3,7
        coord   2,0
        coord   1,1
        coord   0,2

        coord   7,4
        coord   6,5
        coord   5,6
        coord   4,7
        coord   3,0
        coord   2,1
        coord   1,2
        coord   0,3

        coord   7,5
        coord   6,6
        coord   5,7
        coord   4,0
        coord   3,1
        coord   2,2
        coord   1,3
        coord   0,4

        coord   7,6
        coord   6,7
        coord   5,0
        coord   4,1
        coord   3,2
        coord   2,3
        coord   1,4
        coord   0,5

        coord   7,7
        coord   6,0
        coord   5,1
        coord   4,2
        coord   3,3
        coord   2,4
        coord   1,5
        coord   0,6

        endc

        ifeq    PATTERN-BAYER8
bloc1   macro
        coord   0+\1,0+\2
        coord   4+\1,4+\2
        coord   4+\1,0+\2
        coord   0+\1,4+\2
        endm
bloc2   macro
        bloc1   0+\1,0+\2
        bloc1   2+\1,2+\2
        bloc1   2+\1,0+\2
        bloc1   0+\1,2+\2
        endm

        bloc2   0,0
        bloc2   1,1
        bloc2   1,0
        bloc2   0,1
        endc

FadeLen set (*-FadeOutPattern)   ; 80 : la table des cellules s'arrete ICI

; Garde-fou. Le compteur est arme a FadeLen*2, donc l'index maximum est
; FadeLen-1 et cet octet n'est JAMAIS lu en fonctionnement nominal. Il est
; conserve pour qu'un eventuel pas surnumeraire (index FadeLen) lise une valeur
; DEFINIE au lieu de ce qui suit l'objet dans l'image - plan et ligne aleatoires,
; donc une ecriture masquee parasite a un endroit imprevisible de l'ecran.
; Doublon de la premiere cellule traitee (index FadeLen-1 = coord 0,0), donc
; strictement idempotent.
; NE PAS deplacer avant le "FadeLen set" : la table doit rester a 80 pour que
; FadeLen*2 et 40*(FadeLen/8) restent justes.
        coord   0,0
