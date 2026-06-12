# Scrolling horizontal — `scroll-map-buffered*`

Le scrolling horizontal de l'engine est utilisé exclusivement par r-type. Quatre variantes existent :

| Fichier | Usage |
|---------|-------|
| `scroll-map-buffered.asm` | Version générique 8×16 tiles |
| `scroll-map-buffered-even.asm` | Optimisée pour positions paires |
| `scroll-map-buffered-odd.asm` | Optimisée pour positions impaires |
| `scroll-map-buffered-16x16.asm` | Tiles 16×16 (au lieu de 8×16) |

## Concept

Comme `vscroll`, le scrolling horizontal fait :
1. Une **map** de tile IDs
2. Un **tileset** de bitmaps
3. Des **buffers** double-buffer
4. Une **caméra** qui glisse horizontalement

Différence majeure : le scroll horizontal sur TO8/BM16 est **plus complexe** car les pixels sont organisés en plans (RAMA/RAMB) et l'écran fait 160 colonnes (= 40 octets en mode 4-pixel/octet).

## Pattern r-type — usage

Dans `r-type/game-mode/01/main.asm` :
```asm
        INCLUDE "./engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered-even.asm"
```

L'inclusion expose les routines et variables nécessaires.

## Choix even/odd/buffered

Le choix entre `even`/`odd`/`buffered` (générique) dépend de la **position X du buffer** par rapport au pixel-shift courant :

- **even** : optimisée quand la caméra est à une position paire (alignement pixel)
- **odd** : optimisée pour positions impaires (décalage 1 pixel)
- **buffered** : générique (gère les deux cas mais plus lent)

L'engine peut switch automatiquement entre even et odd selon la parité de `glb_camera_x_pos`.

## Variantes 8x16 vs 16x16

- **8×16 tiles** : tiles plus petites, plus de variété par écran, mais map plus longue à stocker (plus de tiles à scroller)
- **16×16 tiles** : tiles plus grandes, moins de variété, mais scroll plus efficient (moins de calculs par frame)

## Pipeline d'assets

Similaire à `vscroll`, mais avec une orientation horizontale :
- Map : stockage en colonnes
- Tileset : tiles 8×16 ou 16×16
- Buffers : adapter aux dimensions et au mode pixel

Outils (`6809-game-builder`) à utiliser avec les bons paramètres `-hs` (horizontal scroll) au lieu de `-vs`.

## Setup typique (r-type level01)

```asm
        ; Setup objects
        _MountObject ObjID_LevelInit
        jsr   ,x                        ; init du niveau (charge map, tileset)

        _MountObject ObjID_LevelWave
        jsr   ,x                        ; init des vagues d'ennemis

        ; Init scroll
        jsr   InitScroll                ; routine custom du game-mode
```

`InitScroll` configure les variables internes du scroll horizontal (adresses map/tileset, buffers, position initiale).

## MainLoop

```asm
MainLoop
        jsr   ReadJoypads
        jsr   RunObjects
        ; ... collisions ...
        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        ; (scroll horizontal s'intègre ici, mais via routines spécifiques r-type)
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _gfxlock.off
        _gfxlock.loop
        bra   MainLoop
```

## Intégration avec terrainCollision

Le scrolling horizontal va souvent de pair avec `terrainCollision` (collisions avec les murs/sols qui défilent). Cf. skill `engine-collision/references/terrain-collision.md`.

## Différences avec vscroll

| Aspect | vscroll | horizontal-scroll |
|--------|---------|-------------------|
| Direction | Y | X |
| Mode pixel | BM16 16x16 tiles | BM16 8x16 ou 16x16 |
| Variantes | 256 vs 512 tiles | even/odd/buffered/16x16 |
| Bénéfice maj | Speed-up vertical | Alignement pixel-shift |
| Usage repo | bubble-bobble, goldorak | r-type |

## Pitfalls

- **Confondre even/odd selon la parité de la position** : impacte les performances mais pas la justesse fonctionnelle
- **Mélanger 8×16 et 16×16** : crash de format
- **Map mal alignée** : décalage visuel
- **Tileset partiel** : tiles manquantes affichées en noir ou random
- **Pas d'usage observé dans d'autres game-projects** : la documentation est moins complète. Pour les autres genres, préférer `vscroll` ou tilemap statique

## Notes

Le scrolling horizontal est moins documenté que `vscroll` dans le repo. Pour des détails sur les variantes, lire les fichiers `.asm` correspondants et consulter le code de r-type pour les patterns d'intégration.

Pour des features comme :
- Parallax (plusieurs couches de scroll)
- Looping scroll (cyclique)
- Scroll bidirectionnel

— elles ne sont **pas standard** dans l'engine. À implémenter applicativement ou ajouter à l'engine.
