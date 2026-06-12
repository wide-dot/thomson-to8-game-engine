# Background Backup Cells (BBC)

Quand un sprite mobile en mode `B` (Backup) est affiché, l'engine **sauvegarde le fond** qu'il va couvrir dans une « cellule » de 64 octets. À l'effacement, ce fond est restauré, laissant l'écran intact pour les autres sprites et le fond statique.

## Constantes

```asm
nb_free_cells                 equ   128            ; nombre total de cellules
cell_size                     equ   64             ; taille d'une cellule en octets
cell_start_adr                equ   $6000          ; adresse de début des cellules
```

128 cellules × 64 octets = **8 Ko** par buffer, soit 16 Ko au total (deux buffers).

L'adresse `$6000` (page système, non commutable) contient les cellules. La zone `$6000-$7FFF` est typiquement réservée à cet usage.

## Structure d'une cellule

```asm
nb_cells                      equ   0              ; nb de cellules réservées (1 octet)
cell_start                    equ   1              ; adresse de début (2 octets)
cell_end                      equ   3              ; adresse de fin (2 octets)
next_entry                    equ   5              ; chaînage vers cellule suivante (2 octets)
entry_size                    equ   7              ; taille d'une entrée
```

Chaque cellule alloué contient :
- `nb_cells` : combien de cellules contigues sont allouées (peut être 1, 2, ...)
- `cell_start` / `cell_end` : intervalle d'adresses utilisé
- `next_entry` : prochaine cellule dans la liste libre (0 = fin)

## Liste libre

```asm
Lst_FreeCellFirstEntry_0      fdb   Lst_FreeCell_0 ; pointer vers la première cellule libre (buffer 0)
Lst_FreeCell_0                fcb   nb_free_cells  ; init avec nb_free_cells cellules libres
```

Au démarrage, toutes les cellules sont libres et chaînées. `Lst_FreeCellFirstEntry_0` pointe vers le premier nœud.

`Lst_FreeCellFirstEntry_1` / `Lst_FreeCell_1` : équivalent pour le buffer 1.

## `BgBufferAlloc` — algorithme

```asm
BgBufferAlloc
        ; input  : A = nb de cellules demandées
        ; output : Y = cell_end ou 0 si pas de place
        pshs  b,x
        ldb   gfxlock.backBuffer.id
        bne   BBA1
BBA0
        ldx   #Lst_FreeCellFirstEntry_0
        ldy   Lst_FreeCellFirstEntry_0
        bra   BBA_Next
BBA1
        ldx   #Lst_FreeCellFirstEntry_1
        ldy   Lst_FreeCellFirstEntry_1
BBA_Next
        beq   BBA_rts                    ; fin de liste, pas trouvé
        cmpa  nb_cells,y                 ; compare avec taille de la cellule libre
        beq   BBA_FitCell                ; pile la taille → on prend tout
        bls   BBA_DivideCell             ; cellule plus grande → on divise
        leax  next_entry,y               ; sauve previous pour update
        ldy   next_entry,y               ; passe à la suivante
        bra   BBA_Next

BBA_FitCell
        ldd   next_entry,y
        std   ,x                         ; relink previous → next (skip current)
        ldd   cell_end,y                 ; retourne cell_end
        ; ... efface la cellule réservée ...

BBA_DivideCell
        ; divise la cellule libre :
        ; - alloue A cellules à partir du début
        ; - reste = (taille - A) cellules au bout
```

## Comment l'objet utilise les cellules

Pour chaque sprite affiché en mode `B`, l'engine :
1. Détermine le nombre de cellules nécessaires : `nb_cell = (taille_sprite + 16 + 64 - 1) / 64` (le +16 pour IRQ + bckp registres, cf. `BuildDisk.java` lignes 506-509)
2. Appelle `BgBufferAlloc` avec ce nombre
3. Reçoit `Y = cell_end` (adresse où finir la sauvegarde du fond)
4. Sauvegarde le fond avant de dessiner le sprite
5. Au moment d'effacer (frame suivante), restaure depuis cell_start/cell_end
6. Libère la cellule via `BgBufferRelease` (équivalent inverse de Alloc)

## Sizing d'un sprite

Le nombre de cellules dépend de la taille du sprite en pixels et de l'encodage :

| Taille sprite | Octets compilés (estimés) | Nb cellules |
|---------------|---------------------------|-------------|
| 8×8 px | ~32 octets | 1 |
| 16×16 px | ~128 octets | 3 (= ceil(128+16)/64) |
| 24×24 px | ~280 octets | 5 |
| 32×32 px | ~500 octets | 9 |
| 16×32 px | ~256 octets | 5 |

À retenir : un sprite de 16×16 typique consomme **3 cellules**. Avec 128 cellules par buffer, on peut afficher ~40 sprites de cette taille simultanément.

`curSubSprite.nb_cell` est calculé par le builder Java au moment de la compilation du sprite (cf. `BuildDisk.java` ligne 506).

## Fragmentation

Les cellules sont allouées en **blocs contigus**. Si la liste libre se fragmente (alternance allocations/libérations), un grand sprite peut échouer même s'il y a assez de cellules au total.

Mitigation :
- Allouer les gros sprites en premier (au boot)
- Limiter la rotation de sprites de tailles très variables
- Augmenter `nb_free_cells` si la zone le permet

## Pattern d'utilisation

L'utilisateur **ne touche pas directement** à `BgBufferAlloc` — c'est l'engine (`DisplaySprite`) qui s'en charge. Ce qui compte :
- Compiler les sprites avec variant `B` (`NB0,NB1`)
- Dimensionner `nb_free_cells` si on a beaucoup de sprites
- Surveiller la fragmentation en cas d'échecs visuels

## Pitfalls

- **Pas assez de cellules** : un sprite n'est pas affiché (silent fail). Détectable visuellement.
- **Sprite avec variant `D` (Draw seul)** : ne consomme pas de cellule, mais ne sauvegarde pas le fond → laisse un trou à l'effacement
- **Sprite trop gros** : un sprite >128 cellules est impossible à allouer (dépasse la zone). À découper en sous-sprites.
- **Buffer 0 et 1 désynchronisés** : si un sprite est dans `Lst_FreeCell_0` mais pas `Lst_FreeCell_1`, il y a un bug d'allocation. Très rare.
- **Modifier `cell_start_adr`** sans recompiler tout l'engine : risque de collision avec d'autres zones mémoire.
