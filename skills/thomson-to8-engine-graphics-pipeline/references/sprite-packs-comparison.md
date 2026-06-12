# Sprite-packs — comparaison et choix

L'engine fournit **trois packs de routines de rendu sprite**, à choisir selon les besoins du projet. Chaque pack est un fichier `.asm` qui regroupe (via `INCLUDE`) les sous-routines nécessaires.

## Vue d'ensemble

| Pack | Modes | Performances | Variants sprite | Cas d'usage |
|------|-------|--------------|-----------------|-------------|
| `sprite-background-erase-pack.asm` | Backup/Draw/Erase | ★★★ Optimal pour sprites mobiles | `NB0,NB1,XB0,XB1` (etc.) | **Recommandé** par défaut |
| `sprite-background-erase-ext-pack.asm` | Backup/Draw/Erase + RLE/ZX0 | ★★★ Idem + sprites encodés | + `DMAP`, `DZX0` | Grands sprites, scrolling de fond |
| `sprite-overlay-pack.asm` | Overlay | ★★ Plus simple, moins efficient | `ND0,ND1` (etc.) | Legacy, démos minimales |

## `sprite-background-erase-pack.asm` (recommandé)

```asm
INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"
```

### Contenu

```asm
        INCLUDE "./engine/graphics/sprite/background-erase-mode/DisplaySprite.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/CheckSpritesRefresh.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/EraseSprites.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/UnsetDisplayPriority.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/DrawSprites.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/BgBufferAlloc.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/DeleteObject.asm"
```

### Mécanique

1. **Avant** de dessiner un sprite, on **sauvegarde le fond** (la zone d'écran qui sera couverte) dans une cellule de 64 octets allouée via `BgBufferAlloc`.
2. **À l'effacement** (frame suivante, si l'objet a bougé), on restaure le fond depuis cette cellule.
3. Le fond peut donc être **dessiné une seule fois** (au boot ou via `DrawFullscreenImage`) puis rester intact — les sprites mobiles s'en chargent eux-mêmes.

### Variants sprite requis

Pour qu'un sprite soit utilisable en mode backup, il faut le compiler avec le suffixe `B` :

```properties
sprite.Img_Player_001=./images/p001.png;NB0,NB1
```

- `NB0` = Normal Backup, position 0
- `NB1` = Normal Backup, position 1 (shift 1px)

Si le sprite doit pouvoir flipper :
```properties
sprite.Img_Player_001=./images/p001.png;NB0,NB1,XB0,XB1
```

### ⚠️ Variants `D` (Draw seul) — `render_overlay_mask` obligatoire dans `Init`

Quand le sprite est compilé avec un variant `ND*` (Normal Draw), `XD*`, `YD*`, ou `XYD*` (= sans sauvegarde du fond, utilisé pour les décors statiques ou les sprites "additifs"), le **code asm de l'objet** doit poser `render_overlay_mask` dans `render_flags,u` :

```asm
Init
        ; ... config animation, priority, position ...
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        inc   routine,u
```

**Sans ça** : l'engine considère le sprite comme un sprite mode B et cherche le code d'erase compilé → qui n'existe pas pour les variants D → **rien ne s'affiche** (échec silencieux, c'est ce que ce flag est censé indiquer au moteur).

Inversement, pour les variants `NB*`/`XB*`/`YB*`/`XYB*`, **ne PAS** poser `render_overlay_mask` (sinon le mécanisme de backup n'est pas appliqué).

### Avantages
- Performance optimale pour sprites mobiles (le fond n'est dessiné qu'une fois)
- Compatible avec `DrawFullscreenImage` pour les fonds statiques
- Pattern utilisé par r-type, bubble-bobble, sonic-2, 2026 (tous les jeux récents)

### Inconvénients
- Plus de mémoire requise (cellules de 64 octets × N sprites)
- Variants `B` à compiler (cycles de build plus longs)

## `sprite-background-erase-ext-pack.asm`

```asm
INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"
```

### Contenu

Identique au précédent **sauf** `DrawSprites.asm` → `DrawSpritesExtEnc.asm` (encoding étendu).

```asm
        INCLUDE "./engine/graphics/sprite/background-erase-mode/DisplaySprite.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/CheckSpritesRefresh.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/EraseSprites.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/UnsetDisplayPriority.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/DrawSpritesExtEnc.asm"   ← différence
        INCLUDE "./engine/graphics/sprite/background-erase-mode/BgBufferAlloc.asm"
        INCLUDE "./engine/graphics/sprite/background-erase-mode/DeleteObject.asm"
```

### Quand l'utiliser

Si le projet utilise des sprites avec encodage compressé :
- `DMAP` : encodage RLE optimisé pour tiles répétitives (images de fond)
- `DZX0` : compression ZX0 (sprites volumineux)

```properties
sprite.Img_bigBackground=./images/bg.png;NDMAP   # ou NDZX0
```

Cas typiques : pattern r-type/level01 qui utilise `sprite-background-erase-ext-pack` pour permettre les backgrounds tilés et compressés.

### Compatibilité

Tous les sprites des variants standards (`NB0`, `NB1`, `ND0`, etc.) restent compatibles. `DrawSpritesExtEnc` détecte le format du sprite au runtime via le rsv_ field et appelle le bon décodeur.

## `sprite-overlay-pack.asm`

```asm
INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"
```

### Contenu

```asm
        INCLUDE "./engine/graphics/sprite/overlay-mode/DisplaySprite.asm"
        INCLUDE "./engine/graphics/sprite/overlay-mode/BuildSprites.asm"
        INCLUDE "./engine/graphics/sprite/overlay-mode/DeleteObject.asm"
```

### Mécanique

Mode **overlay** : les sprites sont fusionnés dans un buffer overlay. Le fond est redessiné à chaque frame (en mode plein écran), puis les sprites sont ajoutés par-dessus.

`BuildSprites` (équivalent de `EraseSprites + DrawSprites` en mode overlay) parcourt la DPS et redessine tout.

### Activation

Le mode overlay nécessite **`OverlayMode equ 1`** au début du `main.asm` :

```asm
OverlayMode equ 1

        INCLUDE "./engine/constants.asm"     ; lit OverlayMode pour adapter render_flags
        INCLUDE "./engine/macros.asm"
        ; ...

        INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"
```

### Variants sprite

Mode overlay : les sprites sont compilés sans backup → variant `D` (Draw seul) :
```properties
sprite.Img_Player_001=./images/p001.png;ND0,ND1
```

### Différences de `render_flags`

En mode overlay, `render_overlay_mask` (bit 2) **n'existe pas**. À la place, le bit 5 devient `render_no_range_ctrl_mask` (skip out-of-range check — **dangereux**, peut corrompre la mémoire).

### Quand l'utiliser

- Démos très simples (un seul background, peu de sprites mobiles)
- Pattern legacy (cf. game-projects/test)
- Quand le fond change à chaque frame de toute façon (pas de bénéfice à le préserver)

### Inconvénients
- Performance moindre (redessine tout chaque frame)
- Pas adapté à scrolling complexe avec sprites multiples

## Boucle MainLoop selon le pack

### Avec `background-erase-pack` (ou ext)

```asm
MainLoop
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites              ; étape distincte d'erase
        jsr   UnsetDisplayPriority
        jsr   DrawSprites               ; puis draw
        _gfxlock.off
        _gfxlock.loop
        bra   MainLoop
```

### Avec `overlay-pack`

```asm
MainLoop
        jsr   WaitVBL                   ; pas de gfxlock typiquement
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   BuildSprites              ; erase+draw en un coup
        bra   MainLoop
```

## Routines partagées (présentes dans tous les packs)

- `DisplaySprite` : enregistre l'objet dans la DPS (le sprite sera affiché). Variantes :
  - `DisplaySprite` (U = OST)
  - `DisplaySprite_x` / `DisplaySprite2` (X = OST)
  - `DisplaySprite_priority` / `DisplaySprite3` (U = OST, A = priority)
- `DeleteObject` : supprime un objet de la DPS et libère son slot

## Choix décisionnel

```
Tu fais :                                    → Pack à utiliser
──────────────────────────────────────────  ────────────────────────────
Un jeu standard avec sprites mobiles         background-erase-pack
+ scrolling de fond (grands sprites)         background-erase-ext-pack
+ images compressées (RLE/ZX0)               background-erase-ext-pack
Une démo très simple, fond redessiné         overlay-pack
Un projet legacy déjà en overlay            overlay-pack (ou migrer)
```

## Migration overlay → background-erase

Si tu veux faire évoluer un projet de overlay vers background-erase :

1. **Retirer `OverlayMode equ 1`** du `main.asm`
2. **Remplacer** l'INCLUDE `sprite-overlay-pack.asm` par `sprite-background-erase-pack.asm`
3. **Remplacer** le `jsr BuildSprites` dans MainLoop par la séquence Erase/Unset/Draw :
   ```asm
   jsr CheckSpritesRefresh
   jsr EraseSprites
   jsr UnsetDisplayPriority
   jsr DrawSprites
   ```
4. **Recompiler les sprites** avec variants `B` (typiquement passer `ND0,ND1` à `NB0,NB1`) dans les `.properties` des objets
5. **Ajouter `InitDrawSprites`** dans le code d'init
6. **Adapter `render_flags`** si des objets utilisent `render_no_range_ctrl_mask` (bit 5 en overlay)

## Pitfalls

- **Inclure deux packs simultanément** : conflits de symboles (BuildSprites vs DrawSprites), build cassé
- **Variant `B` non compilé** mais code utilisant background-erase : sprite affiché mais sans backup, donc à l'effacement, le fond reste à 0 (couleur 0 = noir)
- **Pas d'`InitDrawSprites`** : `glb_camera_x_offset` à 0 → sprites à la mauvaise position
- **`OverlayMode equ 1`** mais utilisant background-erase-pack : `render_flags` mal interprétés, comportement imprévisible
- **Mélange de `DisplaySprite` et `DisplaySprite_x`** : OK, ce sont des variantes du même mécanisme
