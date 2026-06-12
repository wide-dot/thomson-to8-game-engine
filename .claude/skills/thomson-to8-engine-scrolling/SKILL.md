---
name: thomson-to8-engine-scrolling
description: "Décrit les systèmes de scrolling du Thomson TO8/TO9 game engine (Bento8/wide-dot) : scrolling vertical (vscroll) avec macros _vscroll.setMap / _vscroll.setMapHeight / _vscroll.setTileset256 / _vscroll.setTileset512 / _vscroll.setTileNb / _vscroll.setBuffer / _vscroll.setCameraPos / _vscroll.setCameraSpeed / _vscroll.setViewport, scrolling horizontal (horizontal-scroll) avec scroll-map-buffered / scroll-map-buffered-even / scroll-map-buffered-odd / scroll-map-buffered-16x16, système caméra (AutoScroll, AutoScroll.equ, CheckCameraMove) avec glb_camera_x_pos / glb_camera_y_pos / glb_camera_x_pos_coarse / glb_camera_width / glb_camera_height / glb_camera_x_min_pos / glb_camera_y_max_pos / glb_camera_x_offset / glb_camera_y_offset / glb_camera_move / glb_camera_x_min / glb_camera_y_min / glb_camera_x_max / glb_camera_y_max / glb_vp_x_min / glb_vp_y_min / glb_auto_scroll_state / glb_auto_scroll_frames / glb_auto_scroll_step / glb_auto_scroll_step_remainder, scroll_state_stop, vscroll.camera.y / vscroll.obj.map.page / vscroll.obj.map.address / vscroll.map.height / vscroll.obj.tile.pages / vscroll.tiles.dyncall / vscroll.tiles.updateTilesForNLines.address / vscroll.tiles.nbLinesByPage, TilemapBuffer pour buffer cyclique 2 Ko 32x16 tiles, scroll.doOneLoop / scroll.goUntil pour scroll programmé, conversion stm vers bin via stm2bin -obd 12 -mul 2, png2bin -lb 4 -pb 8 -p 2 -pd 4 -vs -slc pour buffers de départ, format binaire tileset 512 tiles 8192 pixels hauteur, intégration avec gfxlock pour le double buffer, choix du mode tileset 256 vs 512 selon taille. Utiliser pour implémenter un scrolling vertical (shoot ou plateformer), horizontal (shoot type r-type), gérer la caméra auto-scroll (cinématiques, traveling), définir les limites de scroll, générer les assets de scroll depuis Pro Motion, calibrer la vitesse du scroll (8.8 sub-pixel), gérer le rebouclage en fin de map. Mots-clés : vscroll, _vscroll.setMap, _vscroll.setMapHeight, _vscroll.setTileset256, _vscroll.setTileset512, _vscroll.setTileNb, _vscroll.setBuffer, _vscroll.setCameraPos, _vscroll.setCameraSpeed, _vscroll.setViewport, _vscroll.buffer.line, vscroll.do, vscroll.move, vscroll.camera.y, vscroll.obj.map.page, vscroll.obj.map.address, vscroll.map.height, vscroll.obj.tile.pages, scroll.doOneLoop, scroll.goUntil, scroll.goUntil.pos, scroll-map-buffered, scroll-map-buffered-even, scroll-map-buffered-odd, scroll-map-buffered-16x16, horizontal-scroll, AutoScroll, CheckCameraMove, glb_camera_x_pos, glb_camera_y_pos, glb_camera_x_pos_coarse, glb_camera_width, glb_camera_height, glb_camera_x_min_pos, glb_camera_y_min_pos, glb_camera_x_max_pos, glb_camera_y_max_pos, glb_camera_x_offset, glb_camera_y_offset, glb_camera_move, glb_camera_x_min, glb_camera_y_min, glb_camera_x_max, glb_camera_y_max, glb_vp_x_min, glb_vp_y_min, glb_vp_x_max, glb_vp_y_max, glb_auto_scroll_state, glb_auto_scroll_frames, glb_auto_scroll_step, glb_auto_scroll_step_remainder, scroll_state_stop, TilemapBuffer, tileset 256 tiles, tileset 512 tiles, stm2bin, png2bin, pro motion, viewport, scroll vertical BM16, sub-pixel scroll 8.8."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Scrolling — Thomson TO8/TO9 Game Engine

L'engine propose deux systèmes de scrolling :

1. **`vscroll`** — scrolling vertical avec tileset 256 ou 512 tiles, utilisé par bubble-bobble (BM16, 160×200) et goldorak (BM16)
2. **`horizontal-scroll`** — scrolling horizontal pour shoot'em up, utilisé par r-type (variantes buffered, even, odd, 16x16)

Plus un **système caméra** (`AutoScroll`) pour piloter le scroll automatiquement (cinématiques, traveling).

Ce skill couvre les deux systèmes, leurs macros, leurs variables globales et le pipeline de génération d'assets.

---

## `vscroll` — scrolling vertical

### Composants

```
Map  : tableau 2D de tile IDs (e.g. 38x16 tiles = 760 entrées)
Tileset : 256 ou 512 tiles graphiques (tile id → bitmap 16x16 ou 8x8)
Buffer A/B : objets buffer de tiles (double-buffer cyclique)
Camera : pointe la position courante dans la map
```

### Setup au boot du game-mode

```asm
        _vscroll.setMap #ObjID_levelMap
        _vscroll.setMapHeight #38*16
        _vscroll.setTileset256 ObjID_levelTileA0,ObjID_levelTileB0
        _vscroll.setTileNb #61
        _vscroll.setBuffer #ObjID_scrollA,#ObjID_scrollB
        _vscroll.setCameraPos #0
        _vscroll.setCameraSpeed #$0100
        _vscroll.setViewport #0,#200
```

| Macro | Effet |
|-------|-------|
| `_vscroll.setMap` | Pointe la map (ObjID de l'objet `levelMap`) |
| `_vscroll.setMapHeight` | Hauteur de la map en pixels (= rows × 16) |
| `_vscroll.setTileset256` | Mode 256 tiles (1 octet par tile id) |
| `_vscroll.setTileset512` | Mode 512 tiles (2 octets par tile id, plus de variété) |
| `_vscroll.setTileNb` | Nombre de tiles uniques dans le tileset (par exemple 61) |
| `_vscroll.setBuffer` | 2 objets buffer (double-buffer alterné) |
| `_vscroll.setCameraPos` | Position Y initiale de la caméra (playfield) |
| `_vscroll.setCameraSpeed` | Vitesse 8.8 (`$0100` = 1 px/frame, `$0080` = 0.5 px/frame) |
| `_vscroll.setViewport` | Y min et Y max du viewport (zone visible à l'écran) |

### MainLoop

```asm
MainLoop
        jsr   RunObjects
        ; ... collision ...
        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        jsr   vscroll.do                ; dessine les tiles dans le buffer
        jsr   vscroll.move              ; avance la caméra selon speed
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _gfxlock.off
        _gfxlock.loop
        bra   MainLoop
```

### Macro `_vscroll.buffer.line`

Utilisée à l'intérieur des objets buffer (cycle de lignes) — pas pour usage utilisateur direct.

### Scroll programmé — `scroll.goUntil`

Pattern bubble-bobble pour faire un scroll auto jusqu'à une position cible :

```asm
        ldd   #200                      ; position cible
        std   scroll.goUntil.pos
        jsr   scroll.goUntil            ; bloquant : scroll progressivement

; routine définie applicativement :
scroll.goUntil.pos fdb 0
scroll.goUntil
@loop
        jsr   scroll.doOneLoop
        ldd   scroll.goUntil.pos
        subd  #10
        cmpd  vscroll.camera.y
        bhi   @loop
        ; fine scroll
        _vscroll.setCameraSpeed #$0040
@loop2
        jsr   scroll.doOneLoop
        ldd   scroll.goUntil.pos
        subd  #1
        cmpd  vscroll.camera.y
        bhi   @loop2
        _vscroll.setCameraSpeed #0
        rts
```

Voir [references/vertical-scroll.md](references/vertical-scroll.md).

---

## `horizontal-scroll` — pour r-type

Variants disponibles :
- `scroll-map-buffered.asm` — version standard
- `scroll-map-buffered-even.asm` — pour positions paires
- `scroll-map-buffered-odd.asm` — pour positions impaires
- `scroll-map-buffered-16x16.asm` — tiles 16×16 au lieu de 8×16

Pattern d'usage (r-type) :
```asm
        INCLUDE "./engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered-even.asm"
```

Voir [references/horizontal-scroll.md](references/horizontal-scroll.md).

---

## Système caméra

### Variables globales

```asm
glb_camera_x_pos               ; position X caméra dans le playfield (16.8 signed)
glb_camera_y_pos               ; position Y
glb_camera_x_pos_coarse        ; ((x_pos - 64) / 64) * 64 — pour alignement scroll
glb_camera_width               ; largeur du viewport visible
glb_camera_height              ; hauteur
glb_camera_x_min_pos           ; bornes de scroll
glb_camera_x_max_pos
glb_camera_y_min_pos
glb_camera_y_max_pos
glb_camera_x_offset            ; offset coord écran (init = screen_left)
glb_camera_y_offset            ; offset Y
glb_camera_move                ; flag : la caméra a-t-elle bougé cette frame ?
```

### `AutoScroll` (engine/graphics/camera/AutoScroll.asm)

Permet de **programmer un déplacement caméra automatique** sur N frames à une vitesse donnée.

```asm
glb_auto_scroll_state               fcb   scroll_state_stop
glb_auto_scroll_frames              fdb   0
glb_auto_scroll_step                fdb   0     ; msb : px/frame, lsb : sub-pixel
glb_auto_scroll_step_remainder      fdb   0
```

États (`AutoScroll.equ`) :
- `scroll_state_stop` : pas de scroll
- `scroll_state_up` : monte
- `scroll_state_down` : descend
- (et variantes horizontales)

Usage :
```asm
        ; Programmer un scroll vers le bas sur 100 frames à 1.5 px/frame
        lda   #scroll_state_down
        sta   glb_auto_scroll_state
        ldd   #100
        std   glb_auto_scroll_frames
        ldd   #$0180                    ; 1.5 px/frame (8.8)
        std   glb_auto_scroll_step

        ; Dans MainLoop
        jsr   AutoScroll
```

### `CheckCameraMove`

Détecte si la caméra a bougé cette frame (`glb_camera_move`). Utile pour forcer un refresh des sprites en coord playfield.

```asm
        jsr   CheckCameraMove           ; met glb_camera_move = 1 si bougé
        lda   <glb_camera_move
        beq   @no_move
        lda   #1
        sta   <glb_force_sprite_refresh ; force refresh global
@no_move
```

Voir [references/camera-system.md](references/camera-system.md).

---

## Pipeline de génération d'assets — vscroll

D'après `engine/graphics/tilemap/vscroll/vscroll.md` :

### 1. Export depuis Pro Motion

- Format map : `.stm`
- Tileset : 1 fichier image, 1 colonne, tiles 16×16
- Destination : `objects/scroll/levelX/`

### 2. Conversion map STM → BIN

```bash
stm2bin -f="path/level1.stm" -obd=12 -mul=2
```

- `obd=12` : output bit depth 12 bits par tile id
- `mul=2` : multiplier le tile id par 2 (valeurs paires uniquement)

### 3. Génération des buffers de départ

```bash
png2bin -f level1.start.png -lb 4 -pb 8 -p 2 -pd 4 -vs -slc
```

- `lb=4` : 4 bits par pixel dans un plan
- `pb=8` : 8 bits par plan
- `p=2` : 2 plans mémoire
- `pd=4` : 4 bits par pixel
- `vs` : output pour vertical scroll
- `slc` : shift colors indexes left by 1

### 4. Génération du tileset

Tileset fixe 512 tiles, image 8192 pixels de haut. Outils dans `6809-game-builder`.

### Format des buffers

Dans les objets buffer :
```asm
        INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"
@loop
        INCLUDEBIN "./objects/scroll/levelX/level.start.0.0.bin.vscroll"
        _vscroll.buffer.line
        jmp   @loop
```

Le `_vscroll.buffer.line` est ajouté entre chaque INCLUDEBIN pour gérer le découpage en lignes.

---

## Variables internes vscroll

```asm
vscroll.camera.y                fdb 0       ; position Y caméra
vscroll.obj.map.page            fcb 0       ; page de la map
vscroll.obj.map.address         fdb 0       ; adresse de la map
vscroll.map.height              fdb 0       ; hauteur map en pixels
vscroll.obj.tile.pages          fill 0,8    ; pages des tiles (8 octets selon mode)
vscroll.tiles.dyncall           fill 0,...  ; routines dynamiques par tile
```

---

## `TilemapBuffer` (engine/graphics/tilemap/TilemapBuffer.asm)

Buffer cyclique 2 Ko (32×16 tiles) pour tilemap. Utilisé par wide-dot-engine. Permet d'afficher une portion de map plus grande que l'écran, en streaming les tiles au fur et à mesure du scroll.

---

## Choix : vscroll vs horizontal-scroll

| Genre | Système recommandé |
|-------|--------------------|
| Shoot vertical | `vscroll` |
| Shoot horizontal | `horizontal-scroll` |
| Plateformer 2D | `vscroll` (pour des écrans verticaux) ou tilemap statique |
| Cinématique linéaire | `AutoScroll` |
| Vue de dessus 4 directions | tilemap classique (cf. autre skill) |

---

## Pitfalls

- **`_vscroll.setMap` non appelée** avant `vscroll.do` : pointe à 0, crash
- **`_vscroll.setMapHeight` incorrecte** : scroll dépasse la fin de map, lecture aléatoire
- **`_vscroll.setTileset256` mais le tileset a 512 tiles** : moitié non utilisée
- **Speed > taille tile par frame** : tearing visuel (saut perceptible)
- **Camera position dépasse `glb_camera_x_max_pos`** : peut générer un wrap-around ou un crash selon le mode
- **Buffer A et B mal configurés** : double-buffer cassé, tearing
- **Modifier `glb_camera_x_pos` manuellement pendant un scroll auto** : conflit avec `AutoScroll`
- **Génération assets sans `stm2bin -mul=2`** : tile IDs impairs, format binaire incompatible
- **PNG d'origine pas en 160×200** : viewport plus petit, mais nécessite ajuster `glb_camera_width`/`height`

---

## Références détaillées

- [references/vertical-scroll.md](references/vertical-scroll.md) — `vscroll` complet : macros setMap/MapHeight/Tileset256/Tileset512/TileNb/Buffer/CameraPos/CameraSpeed/Viewport, `vscroll.do`/`vscroll.move`, variables internes (`vscroll.camera.y`, `obj.map.page`, etc.), pattern `scroll.goUntil`, `_vscroll.buffer.line`, pipeline d'assets stm2bin/png2bin, formats binaires des buffers
- [references/horizontal-scroll.md](references/horizontal-scroll.md) — `scroll-map-buffered` et variants (even/odd/16x16), pattern r-type, buffers, intégration avec map de niveau, conversion playfield
- [references/camera-system.md](references/camera-system.md) — Variables `glb_camera_*`, conversion playfield → écran, bornes min/max, `AutoScroll` (états, vitesse 8.8, sub-pixel remainder, `glb_auto_scroll_*`), `CheckCameraMove`, intégration avec `glb_force_sprite_refresh`, `screen_left`/`screen_top` initialisation
