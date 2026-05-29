********************************************************************************
* CopyPageATo0 — copie 16 Ko depuis une page RAM vers page 0 demi-pages
* ------------------------------------------------------------------------------
*
* Source : page <src_page> mountée à $0000-$3FFF (cart zone, RAM-over-cart)
* Destination : page 0 demi-pages à $4000-$5FFF, sélectionnées par bit PRC
*
* Layout cible (= où les bytes finissent dans page 0) :
*   bytes 0..$1FFF   → page 0 RAMA (= visible à $4000 quand PRC=0)
*   bytes $2000..$3FFF → page 0 RAMB (= visible à $4000 quand PRC=1)
*
* Au runtime, l'asm bascule PRC pour choisir quelle moitié est lue à $4000-$5FFF
* (= patterns_dark vs patterns_light pour le dithering Lotus, par exemple).
*
* === USAGE ===
*   lda   #3                      ; numéro de page source (chargée par RAMLoader)
*   jsr   CopyPageATo0
*
* === CONVENTION ===
*   input :  A = numéro de page source (typiquement page 3 = video page libre
*                au chargement, dont les bytes peuvent être réécrits par
*                gfxlock.init plus tard sans dommage)
*   trashes : A, B, X, Y, flags
*           $E7E6 (cart zone) modifié à src_page | $60
*           $E7C3 (PRC bit) bascule 2 fois
*
* === COÛT ===
*   ~4096 itérations × (ldd/std/cmpx/blo) ≈ 50 cycles/iter = ~200 000 cycles
*   ≈ 4 frames @ 50 Hz. Acceptable pour init.
*   Optimisable plus tard avec PSHS/PULU 7 octets (~3× plus rapide).
*
* === GOTCHAS ===
*   • Pages 2 et 3 = back-buffers gfxlock. Si appelée APRÈS gfxlock.init,
*     les bytes en page 2/3 sont des back-buffers vidéo en cours d'usage →
*     conflit. À appeler AVANT gfxlock.init dans le game-mode init.
*   • PRC est laissé à $01 (= RAMB visible). Restaurer si nécessaire.
*   • $E7E6 n'est pas restauré. Le prochain _SetCartPageA le remettra.
*
********************************************************************************

CopyPageATo0
        * Mount source page in cart zone $0000-$3FFF
        ora   #$60                       ; bit5 = RAM-over-cart, bit6 = write-enable
        sta   $E7E6                      ; cart zone = src page

        * --- Première moitié : src $0000-$1FFF → page 0 RAMA $4000-$5FFF ---
        ldb   $E7C3
        andb  #$FE                       ; PRC=0 → RAMA visible à $4000-$5FFF
        stb   $E7C3

        ldx   #$0000                     ; src ptr (cart zone)
        ldy   #$4000                     ; dst ptr (page 0 RAMA via demi-page)
CpyP0_loopA
        ldd   ,x++
        std   ,y++
        cmpx  #$2000
        blo   CpyP0_loopA

        * --- Deuxième moitié : src $2000-$3FFF → page 0 RAMB $4000-$5FFF ---
        ldb   $E7C3
        orb   #$01                       ; PRC=1 → RAMB visible à $4000-$5FFF
        stb   $E7C3

        ldx   #$2000                     ; src ptr (suite cart zone)
        ldy   #$4000                     ; dst ptr (page 0 RAMB)
CpyP0_loopB
        ldd   ,x++
        std   ,y++
        cmpx  #$4000
        blo   CpyP0_loopB

        rts
