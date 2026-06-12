---
name: thomson-to8-engine-graphics-pipeline
description: "Décrit le pipeline graphique du Thomson TO8/TO9 game engine (Bento8/wide-dot) : double buffering avec gfxlock (gfxlock.status, gfxlock.bufferSwap.do/check/wait, _gfxlock.init/on/off/loop, backBuffer.id, frame.count, frameDrop.count_w), commutation des pages physiques 2/3 via map.CF74021.SYS2 et map.CF74021.DATA, swap demi-page écran via map.MC6846.PRC, sprite-packs (background-erase-pack, background-erase-ext-pack, overlay-pack) et leurs sous-modules (DrawSprites, EraseSprites, CheckSpritesRefresh, UnsetDisplayPriority, DisplaySprite, BgBufferAlloc, DeleteObject, BuildSprites), Display Priority Structure (DPS) avec priorités 1-8 (1=front, 8=back), file Lst_Priority_Unset_0/1, listes Tbl_Sub_Object_Erase/Draw, allocation des cellules d'effacement BBC (Background Backup Cells) à 64 octets de $4000 à $5FFF, Lst_FreeCell_0/1, rsv_render_flags bitfield (checkrefresh, erasesprite, displaysprite, outofrange, onscreen), glb_camera_x/y_offset, screen_left/top, InitDrawSprites, glb_force_sprite_refresh, choix entre coord playfield (render_playfieldcoord_mask) et coord écran, modes BM4 vs BM16 et leurs implications de rendu, intégration avec PalUpdateNow et l'IRQ raster. Utiliser pour comprendre la boucle de rendu, choisir entre les sprite-packs, débugger les artefacts de tearing/clipping, gérer les priorités d'affichage, optimiser le rendu en réduisant le nombre de sprites à redessiner, ajuster les paramètres de double buffering, ou comprendre la gestion des cellules de fond. Mots-clés : gfxlock, _gfxlock.init, _gfxlock.on, _gfxlock.off, _gfxlock.loop, gfxlock.bufferSwap.do, gfxlock.bufferSwap.check, gfxlock.bufferSwap.wait, gfxlock.bufferSwap.count, gfxlock.bufferSwap.status, gfxlock.backBuffer.id, gfxlock.backBuffer.status, gfxlock.frame.count, gfxlock.frame.lastCount, gfxlock.frameDrop.count, gfxlock.frameDrop.count_w, gfxlock.status, gfxlock.screenBorder.color, gfxlock.screenBorder.update, gfxlock.backProcess.on, gfxlock.backProcess.routine, gfxlock.backProcess.status, gfxlock.irq, map.CF74021.SYS2, map.CF74021.DATA, map.MC6846.PRC, $E7DD, page 2, page 3, InitDrawSprites, DrawSprites, EraseSprites, CheckSpritesRefresh, UnsetDisplayPriority, DisplaySprite, DisplaySprite2, DisplaySprite3, DisplaySprite_x, DisplaySprite_priority, BuildSprites, DeleteObject, BgBufferAlloc, Lst_FreeCellFirstEntry_0, Lst_FreeCell_0, nb_free_cells, cell_size, cell_start, cell_end, next_entry, entry_size, Background Backup Cells, BBC, Tbl_Sub_Object_Erase, Tbl_Sub_Object_Draw, Lst_Priority_Unset_0, DPS, Display Priority Structure, DPS_buffer_0, DPS_buffer_1, buf_Tbl_Priority_First_Entry, priority 1-8, render_flags, render_xmirror_mask, render_ymirror_mask, render_overlay_mask, render_playfieldcoord_mask, render_xloop_mask, render_todelete_mask, render_subobjects_mask, render_hide_mask, rsv_render_flags, rsv_render_checkrefresh_mask, rsv_render_erasesprite_mask, rsv_render_displaysprite_mask, rsv_render_outofrange_mask, rsv_render_onscreen_mask, glb_camera_x_offset, glb_camera_y_offset, glb_camera_x_pos, glb_camera_y_pos, glb_camera_x_pos_coarse, glb_camera_width, glb_camera_height, glb_camera_x_min_pos, glb_camera_y_max_pos, glb_force_sprite_refresh, glb_screen_location_1, glb_screen_location_2, glb_register_s, screen_left, screen_top, sprite-background-erase-pack, sprite-background-erase-ext-pack, sprite-overlay-pack, BM4, BM16, overlay mode, OverlayMode, double-buffer, dirty rendering, sprite priority, z-order."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Pipeline graphique — Thomson TO8/TO9 Game Engine

Le pipeline graphique combine **double buffering** (deux pages vidéo qui s'échangent à chaque VBL), **gestion de priorités** (DPS), et **rendu différentiel** (« dirty rendering » — seuls les sprites modifiés sont redessinés/effacés). Le tout pour atteindre 50 Hz stables sur le matériel.

Ce skill couvre : `gfxlock` (le double buffer), les trois **sprite-packs** disponibles, la **Display Priority Structure** (DPS), les **Background Backup Cells** (BBC) pour l'effacement, et la mécanique précise de la boucle de rendu.

---

## Vue d'ensemble — boucle de rendu

```
MainLoop
   │
   ├── RunObjects               ← exécute la logique des objets, ils peuvent
   │                              modifier position/anim/priority/render_flags
   │
   ├── CheckSpritesRefresh      ← détermine quels sprites doivent être
   │                              effacés/redessinés (dirty detection)
   │
   ├── _gfxlock.on              ← verrouille la phase rendu (attend si nécessaire
   │                              que le swap précédent soit terminé)
   │
   ├── EraseSprites             ← efface les sprites du frame précédent en
   │                              restaurant le background sauvegardé
   │
   ├── UnsetDisplayPriority     ← retire les sprites avec priority=0 de la DPS
   │
   ├── DrawSprites              ← dessine les sprites visibles dans l'ordre
   │                              de priorité (back to front)
   │
   ├── _gfxlock.off             ← libère le verrou rendu
   │
   ├── _gfxlock.loop            ← gère le compteur de frames, bascule
   │                              backBuffer.id pour la prochaine frame
   │
   └── bra   MainLoop

UserIRQ (50 Hz, sur VBL)
   │
   ├── gfxlock.bufferSwap.check ← si rendu prêt, échange les pages visibles
   │                              via map.CF74021.SYS2 = page 2 ou 3
   │
   ├── PalUpdateNow             ← applique les changements de palette
   │
   └── (audio frame)
```

---

## `gfxlock` — double buffering

`gfxlock` gère **deux pages physiques** comme buffers vidéo alternés :
- Page 2 et page 3 (en zone donnée `$A000-$DFFF` via `map.CF74021.DATA = $E7E5`)
- Une **visible** (lue par le hardware vidéo), une **écrite** (back-buffer)
- À chaque VBL, si le rendu est complet, échange via `gfxlock.bufferSwap.do`

### Variables d'état

| Variable | Taille | Rôle |
|----------|--------|------|
| `gfxlock.status` | 1 | 1 = rendu en cours, 0 = inactif |
| `gfxlock.bufferSwap.status` | 1 | -1 = swap effectué, 0 = pas swap |
| `gfxlock.bufferSwap.count` | 2 | Compteur de swaps depuis init |
| `gfxlock.backBuffer.id` | 1 | 0 ou 1 = index du back-buffer courant |
| `gfxlock.backBuffer.status` | 1 | 0 ou -1 (flip/flop interne) |
| `gfxlock.frame.count` | 2 | Frames 50 Hz écoulées depuis init |
| `gfxlock.frame.lastCount` | 2 | Frame count au dernier render |
| `gfxlock.frameDrop.count` | 1 | Nb de frames sautées depuis le dernier rendu |
| `gfxlock.frameDrop.count_w` | 1 | (zero pad MSB) pour usage en 16-bit |

### Macros principales

```asm
_gfxlock.init     → init de gfxlock (au boot, après IRQ on)
_gfxlock.on       → verrou rendu (attend si swap pending)
_gfxlock.off      → libère le verrou
_gfxlock.loop     → bascule backBuffer.id, met à jour frameDrop.count
_gfxlock.backProcess.on → enregistre une routine à appeler pendant le wait
```

### Routines (appelées par les macros)

- `gfxlock.bufferSwap.do` : exécute le swap (écrit dans `map.CF74021.SYS2 = $E7E7`)
- `gfxlock.bufferSwap.check` : appelée par UserIRQ, swap si rendu prêt
- `gfxlock.bufferSwap.wait` : attente bloquante (avec back-process optionnel)
- `gfxlock.screenBorder.update` : change la couleur de bordure (passe en `$E7DD`)

Voir [references/gfxlock-internals.md](references/gfxlock-internals.md) pour le détail de chaque routine, le hardware mappé, et les patterns d'usage.

---

## Sprite-packs — choisir le bon

Trois packs sont fournis dans `engine/graphics/sprite/` :

### `sprite-background-erase-pack.asm`

Pack par défaut. Inclut :
- `DisplaySprite` (+ variantes `_x`, `_priority`)
- `CheckSpritesRefresh`
- `EraseSprites`
- `UnsetDisplayPriority`
- `DrawSprites`
- `BgBufferAlloc`
- `DeleteObject`

Mode **backup/draw/erase** : chaque sprite mobile sauvegarde le fond avant de se dessiner, et le restaure quand il disparaît. Permet d'avoir des sprites animés sur un fond non-redessiné chaque frame (économie massive de cycles).

Variants sprite requis : `NB0,NB1` + `XB0,XB1` si flip H, etc. (cf. skill `engine-new-game` references/object-properties.md).

### `sprite-background-erase-ext-pack.asm`

Identique mais remplace `DrawSprites.asm` par `DrawSpritesExtEnc.asm`. Permet les sprites avec **encodage RLE (`DMAP`) ou ZX0 (`DZX0`)** — utile pour les grands sprites ou backgrounds qui se déplacent.

### `sprite-overlay-pack.asm`

Pack legacy. Inclut :
- `DisplaySprite` (overlay)
- `BuildSprites`
- `DeleteObject`

Mode **overlay** : pas de sauvegarde de fond, les sprites sont fusionnés dans un buffer overlay. Plus simple, moins performant en cas de nombreux sprites mobiles. Nécessite `OverlayMode equ 1` en préambule, désactive certains bits de `render_flags` (`render_overlay_mask` n'existe pas).

Voir [references/sprite-packs-comparison.md](references/sprite-packs-comparison.md) pour la comparaison détaillée et les critères de choix.

---

## DPS — Display Priority Structure

Le rendu se fait dans l'ordre des **priorités** (8 niveaux). Chaque buffer (0 et 1) a sa propre DPS — c'est la liste **doublement chaînée ouverte** qui mémorise pour chaque niveau de priorité quels objets sont à afficher.

```asm
DPS_buffer_0+buf_Tbl_Priority_First_Entry+16    ; priorité 8 (back)
DPS_buffer_0+buf_Tbl_Priority_First_Entry+14    ; priorité 7
...
DPS_buffer_0+buf_Tbl_Priority_First_Entry+2     ; priorité 1 (front)
```

Sémantique :
- **priority 0** : non affiché
- **priority 1** : front (dessiné en dernier, masque les autres)
- **priority 2-7** : intermédiaires
- **priority 8** : back (dessiné en premier)

`DrawSprites` parcourt de **back vers front** (priorité 8 → 1), `EraseSprites` de **front vers back** (1 → 8) pour gérer la superposition correctement.

Voir [references/display-priority-structure.md](references/display-priority-structure.md).

---

## BBC — Background Backup Cells

Les sprites en mode `B` (backup) sauvegardent leur fond dans des **cellules** de 64 octets allouées dans la zone `$6000-...`.

```asm
nb_free_cells                 equ   128       ; nombre de cellules par buffer
cell_size                     equ   64        ; taille d'une cellule (64 octets)
cell_start_adr                equ   $6000     ; adresse de début des cellules
```

Chaque objet, lors de son affichage, demande N cellules via `BgBufferAlloc` (N = `(taille_sprite + 64 + 15) / 64`). Les cellules sont chaînées en liste libre.

`BgBufferAlloc` retourne `Y = cell_end` ou 0 si pas de place.

Voir [references/bbc-allocation.md](references/bbc-allocation.md) pour le détail de l'allocation, les listes de cellules libres, la fragmentation, et le sizing recommandé.

---

## `render_flags` et `rsv_render_flags`

### `render_flags` (offset 2, modifiable par l'utilisateur)

```
Bit | Mask  | Symbole                       | Effet
----|-------|-------------------------------|---------------------------------------------------
0   | $01   | render_xmirror_mask           | Sprite miroir horizontal (combiné avec status_xflip)
1   | $02   | render_ymirror_mask           | Sprite miroir vertical
2   | $04   | render_overlay_mask           | Sprite sans backup de fond (mode B-E-pack)
3   | $08   | render_playfieldcoord_mask    | x_pos/y_pos (1) vs x_pixel/y_pixel (0)
4   | $10   | render_xloop_mask             | Loop X hors écran (en coord écran)
5   | $20   | render_todelete_mask          | Marquer pour suppression engine
6   | $40   | render_subobjects_mask        | Rendre les sous-objets
7   | $80   | render_hide_mask              | Cacher (préserve priority/mapping)
```

### ⚠️ `render_overlay_mask` est OBLIGATOIRE pour les variants `D*` (Draw seul)

Quand le sprite est compilé avec un variant `ND0`, `ND1`, `XD*`, `YD*`, `XYD*` (= sans backup du fond), `render_overlay_mask` doit **impérativement** être posé dans `render_flags,u` à l'`Init` de l'objet :

```asm
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
```

**Sinon** : l'engine traite le sprite comme un mode `B` (backup) et cherche le code d'erase compilé qui n'existe pas pour les variants D → **rien ne s'affiche**, aucun message d'erreur. Bug très piégeux.

Pour les variants `NB*`/`XB*`/`YB*`/`XYB*` (mode Backup), `render_overlay_mask` doit **rester à 0** (sinon l'engine n'applique pas le mécanisme backup/restore et le sprite peut laisser des traces).

### `rsv_render_flags` (zone réservée engine)

```
Bit | Mask  | Symbole                       | Effet
----|-------|-------------------------------|---------------------------------------------------
0   | $01   | rsv_render_checkrefresh_mask  | EraseSprite+DisplaySprite déjà traités cette frame
1   | $02   | rsv_render_erasesprite_mask   | À effacer
2   | $04   | rsv_render_displaysprite_mask | À redessiner
3   | $08   | rsv_render_outofrange_mask    | Out of range (clipping)
7   | $80   | rsv_render_onscreen_mask      | Rendu sur le dernier buffer
```

Ces flags sont gérés par `CheckSpritesRefresh`, `EraseSprites`, `DrawSprites`. Ne pas les toucher depuis le code utilisateur sauf cas spécifique.

### Forcer le refresh global — `glb_force_sprite_refresh`

```asm
        lda   #1
        sta   <glb_force_sprite_refresh
```

Force `CheckSpritesRefresh` à considérer tous les sprites comme dirty. Utile après un scroll ou un changement de fond.

---

## Camera — coordonnées playfield → écran

```asm
glb_camera_x_pos              ; position X de la caméra (playfield)
glb_camera_y_pos              ; position Y de la caméra
glb_camera_x_pos_coarse       ; ((x_pos - 64) / 64) * 64 — pour alignement
glb_camera_x_offset           ; offset à appliquer (= screen_left initialement)
glb_camera_y_offset           ; offset Y (= screen_top initialement)
glb_camera_width              ; largeur du viewport
glb_camera_height             ; hauteur du viewport
glb_camera_x_min/max_pos      ; bornes de scroll
```

Conversion automatique faite par `DrawSprites` si le flag `render_playfieldcoord_mask` est mis :
```
x_pixel = x_pos - glb_camera_x_pos + glb_camera_x_offset
y_pixel = y_pos - glb_camera_y_pos + glb_camera_y_offset
```

`InitDrawSprites` initialise `glb_camera_x_offset = screen_left` et `glb_camera_y_offset = screen_top`. À appeler au boot.

---

## Squelette d'une frame complète

```asm
MainLoop
        jsr   RunObjects
        jsr   CheckSpritesRefresh       ; détermine ce qui doit bouger
        _gfxlock.on                     ; attend swap si nécessaire
        jsr   EraseSprites              ; restaure les fonds
        jsr   UnsetDisplayPriority      ; nettoie les sprites supprimés
        jsr   DrawSprites               ; redessine dans l'ordre priorité
        _gfxlock.off                    ; débloque pour le swap
        _gfxlock.loop                   ; flip backBuffer.id, update frame count
        bra   MainLoop

UserIRQ
        jsr   gfxlock.bufferSwap.check  ; swap si rendu prêt
        jsr   PalUpdateNow              ; applique la palette
        ; ... audio ...
        rts
```

---

## Pitfalls

- **Sprite ND* sans `render_overlay_mask`** : sprite compilé en variant `ND*` (Draw seul, sans backup) sans le flag → **invisible**, échec silencieux. Toujours poser `render_overlay_mask` à l'init pour ces variants. Cf. section dédiée.
- **Position d'un sprite calculée comme `taille/2`** : la règle est `ceil(taille/2)-1`. Sprite 160 px centré X = `x_pixel = 79`, pas 80. Si débordement et `render_xloop_mask` non posé → sprite non affiché.
- **`InitDrawSprites` manqué** au boot : `BgBufferAlloc` opère sur des listes non-init → corruption mémoire ; `glb_camera_x/y_offset` à 0 → sprites mal placés
- **`_gfxlock.init` après `IrqOn`** : status non initialisé, `gfxlock.bufferSwap.check` peut faire un swap involontaire
- **Mélange sprite-pack overlay et background-erase** : signatures incompatibles, les sprites n'auront pas les bonnes variantes
- **Trop de sprites en priorité identique** : pas de bug fonctionnel mais la DPS peut consommer beaucoup de RAM (chaque slot = 8 bytes)
- **Variant `NB0` seulement (sans `NB1`)** : le sprite ne pourra bouger qu'aux positions paires X → saccade visuelle
- **`render_playfieldcoord_mask` mis mais `x_pos`/`y_pos` non initialisés** : sprite affiché en (0,0) - camera, hors écran
- **`UnsetDisplayPriority` oublié** : les sprites supprimés restent dans la DPS → corruption (ils dépointent vers de la mémoire libérée)
- **Modifier `priority` directement sans passer par `DisplaySprite`** : la DPS n'est pas mise à jour, le sprite reste dans la mauvaise priorité

---

## Références détaillées

- [references/gfxlock-internals.md](references/gfxlock-internals.md) — Mécanique précise de gfxlock : `bufferSwap.do`/`check`/`wait`, mappage hardware (`map.CF74021.SYS2`, `map.CF74021.DATA`, `map.MC6846.PRC`, `$E7E5`/`$E7E6`/`$E7E7`), variables d'état détaillées, sync VBL via IRQ, frame drop adaptatif, back-process pendant wait, intégration palette
- [references/sprite-packs-comparison.md](references/sprite-packs-comparison.md) — `background-erase-pack` vs `-ext-pack` vs `overlay-pack` : sous-modules inclus, variants sprite requis, taille en RAM, performances comparées, conventions `OverlayMode equ 1`, conversion entre packs
- [references/display-priority-structure.md](references/display-priority-structure.md) — DPS détaillée : `DPS_buffer_0/1`, `buf_Tbl_Priority_First_Entry`, chaînage open doubly linked list, `Lst_Priority_Unset_0/1`, sémantique des priorités 1-8, `DisplaySprite`/`_x`/`_priority` (variantes), `UnsetDisplayPriority` parcours
- [references/bbc-allocation.md](references/bbc-allocation.md) — Background Backup Cells : `nb_free_cells = 128`, `cell_size = 64`, `cell_start_adr = $6000`, structure d'une cellule (`nb_cells`, `cell_start`, `cell_end`, `next_entry`), `Lst_FreeCellFirstEntry_0/1`, `Lst_FreeCell_0/1`, fragmentation, `BgBufferAlloc` algorithme, sizing
- [references/dirty-rendering.md](references/dirty-rendering.md) — `CheckSpritesRefresh` algorithme : parcours `Tbl_Sub_Object_Erase`/`Draw` back to front, détection des changements via `rsv_render_flags`, `glb_force_sprite_refresh` pattern, gestion du double buffer (chaque buffer a son propre état refresh), interaction avec `EraseSprites` (front to back) et `DrawSprites` (back to front)
- [references/coordinate-systems.md](references/coordinate-systems.md) — Coord playfield (`x_pos`/`y_pos` signed 16.8) vs coord écran (`x_pixel`/`y_pixel` 8-bit), conversion par caméra, `glb_camera_x_offset` / `glb_camera_y_offset` / `screen_left` / `screen_top`, flags `render_playfieldcoord_mask` et `render_xloop_mask`, dimensions du viewport, modes 160x200 (BM16) et 320x200 (BM4)
