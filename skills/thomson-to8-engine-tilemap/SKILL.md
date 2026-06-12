---
name: thomson-to8-engine-tilemap
description: "Décrit le système de tilemap statique (non-scrolling) du Thomson TO8/TO9 game engine (Bento8/wide-dot) : routine DrawTilemap pour afficher un layer de tiles à partir d'un submap (structure submap_x_pos / submap_y_pos / submap_camera_x_min/x_max/y_min/y_max / submap_layers), structure de layer (layer_parallax_X / parallax_Y / vp_offset / vp_tiles_x / vp_tiles_y / vp_x_size / vp_y_size / mem_step_x / mem_step_y / tile_size_bitmask_x / tile_size_divider_x / tiles_location / width / height) pour layers parallaxés, Tilemap16bits pour maps avec 64x128 tiles et chunks 8x8 (layer_map / layer_chunk0 / layer_chunk1 / layer_tiles / layer_mul_ref), TilemapBuffer pour buffer cyclique 2 Ko 32x16 tiles, Spritemap pour allocation dynamique de sprites depuis une map (spmap_x_pos / spmap_y_pos / spmap_vp_tiles_x / spmap_tile_size_bitmask_x / spmap_tile_size_divider_x / spmap_nb_tiles_x / spmap_map, variables glb_spritemap_obj / glb_spritemap_addr / glb_spritemap_page / glb_spritemap_index / spritemap_cur_index / spritemap_cur_index_end), TileAnimScript pour animer des tiles à partir d'un script déclaratif (ZACurIndex / ZACurFrame / ZADuration / ZAMaxFrame / ZASize, TileAnimScriptInit, TileAnimScriptList, integration avec gfxlock.frameDrop.count), bm4.drawChunbks pour rendu chunks BM4, types de data (layer.equ, submap.equ, map-16bits.equ, spritemap.equ), tilesets via tileset.X property dans object .properties (CENTER, TOP_LEFT, TILE8x16, TILE16x16, mapFile, mapBitDepth). Utiliser pour afficher un fond statique tilé (non-scrolling), gérer des layers avec parallax (8-bit decimal pour la vitesse de parallax), animer des tiles (eau, feu, plantes), allouer dynamiquement des sprites depuis une map (avec scroll), créer des chunks 8x8 tiles pour économiser la RAM map. Mots-clés : DrawTilemap, Tilemap, Tilemaps, Tilemap16bits, Spritemap, TileAnimScript, TileAnimScriptInit, TileAnimScriptList, TileAnimScriptData, TilemapBuffer, glb_submap, glb_submap_page, glb_submap_index, glb_submap_index_buf0, glb_submap_index_buf1, glb_submap_index_inactive, glb_spritemap_obj, glb_spritemap_addr, glb_spritemap_page, glb_spritemap_index, glb_spritemap_index_old, spritemap_cur_index, spritemap_cur_index_end, spritemap_cur_index_old, glb_map_pge, glb_map_adr, glb_map_chunk_pge, glb_map_chunk_adr, glb_map_defchunk0_pge, glb_map_defchunk0_adr, glb_map_tiles_pge, glb_map_tiles_adr, glb_map_width, layer_parallax_X, layer_parallax_Y, layer_vp_offset, layer_vp_tiles_x, layer_vp_tiles_y, layer_vp_x_size, layer_vp_y_size, layer_mem_step_x, layer_mem_step_y, layer_tile_size_bitmask_x, layer_tile_size_bitmask_y, layer_tile_size_divider_x, layer_tile_size_divider_y, layer_tiles_location, layer_width, layer_height, layer.equ, submap.equ, map-16bits.equ, spritemap.equ, submap_x_pos, submap_y_pos, submap_camera_x_min, submap_layers, layer_map, layer_chunk0, layer_chunk1, layer_tiles, layer_mul_ref, layer_map_width, layer_map_height, spmap_x_pos, spmap_vp_tiles_x, spmap_tile_size_bitmask_x, spmap_tile_size_divider_x, spmap_map, ZACurIndex, ZACurFrame, ZADuration, ZAMaxFrame, ZASize, tileset.X, CENTER, TOP_LEFT, TILE8x16, TILE16x16, mapFile, mapBitDepth, bm4.drawChunbks, chunk 8x8, chunks de tiles, parallax."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Tilemap statique — Thomson TO8/TO9 Game Engine

L'engine fournit plusieurs systèmes de **tilemap** (affichage de fonds basés sur tiles) :

1. **`Tilemap`** — tilemap statique multi-layers avec parallax
2. **`Tilemap16bits`** — variante avec maps 64×128 tiles, chunks 8×8
3. **`TilemapBuffer`** — buffer cyclique 2 Ko pour streaming (wide-dot)
4. **`Spritemap`** — allocation dynamique de sprites depuis une map
5. **`TileAnimScript`** — animation déclarative de tiles

Ce skill couvre les structures de données, les routines de rendu, et les patterns d'usage.

Pour le **scrolling** vertical/horizontal, voir le skill `engine-scrolling`.

---

## `Tilemap` — fond statique multi-layers

### Variables globales

```asm
glb_submap                fdb   0       ; adresse du submap data structure
glb_submap_page           fcb   0       ; page mémoire du submap
glb_submap_index          fdb   0       ; index dans la map qui matche la caméra
glb_submap_index_buf0     fdb   $FFFF   ; index actuel pour buffer 0
glb_submap_index_buf1     fdb   $FFFF   ; index actuel pour buffer 1
glb_submap_index_inactive equ   $FFFF   ; force background refresh
```

`buf0`/`buf1` séparés pour gérer le double-buffer (chaque buffer a son propre snapshot).

### Routine `DrawTilemap`

```asm
DrawTilemap
        lda   glb_submap_page
        ldx   glb_submap
        _SetCartPageA
        
        ; Parcours des layers du submap
        ldu   submap_layers,x
        
        ; Conversion caméra → index map (avec tile_size_divider pour vitesse)
        leay  layer_tilemap,u
        ; ... arithmétique avec parallax ...
        
        ; Affichage des tiles
```

Le rendu dépend des champs du **layer** (parallax, mem_step, tile_size_divider).

### Structure du submap (`submap.equ`)

```asm
submap_x_pos        equ   0     ; position dans la map globale (px)
submap_y_pos        equ   2
submap_camera_x_min equ   4     ; bornes de scroll
submap_camera_y_min equ   6
submap_camera_x_max equ   8
submap_camera_y_max equ   10
submap_layers       equ   12    ; table d'adresses de layers
```

Un submap peut contenir **plusieurs layers** (par exemple : sol + objets + ciel). Chaque layer a sa propre parallax.

### Structure d'un layer (`layer.equ`)

```asm
layer_parallax_X          equ   0     ; vitesse parallax X en 8 bits décimal (n/256)
layer_parallax_Y          equ   1     ; $FF = 1px/cam-px, $00 = fixed, $80 = 0.5
layer_vp_offset           equ   2     ; offset viewport (col*4 + row*40 octets)
layer_vp_tiles_x          equ   4     ; nb tiles en viewport rows
layer_vp_tiles_y          equ   5
layer_vp_x_size           equ   6     ; viewport X en pixels
layer_vp_y_size           equ   8
layer_mem_step_x          equ   10    ; octets entre 2 tiles d'une colonne
layer_mem_step_y          equ   11    ; octets entre 2 lignes
layer_tile_size_bitmask_x equ   13    ; mask pour sous-tile X (4px=2, 8px=3, 16px=4, 32px=5)
layer_tile_size_bitmask_y equ   14
layer_tile_size_divider_x equ   15    ; pour div rapide (4px=14, 8px=12, 16px=10)
layer_tile_size_divider_y equ   16
layer_tiles_location      equ   17    ; index tiles (page + adresse)
layer_width               equ   19    ; tiles en rows
layer_height              equ   20    ; tiles en cols
```

### Parallax

```
layer_parallax_X = $FF → 1 px de scroll par px caméra (au plus proche)
layer_parallax_X = $80 → 0.5 px par px caméra (couche intermédiaire)
layer_parallax_X = $20 → 0.125 px par px caméra (couche lointaine, ciel)
layer_parallax_X = $00 → fixed (HUD-like)
```

Plusieurs layers avec des parallax différentes donnent l'illusion de profondeur (couches).

Voir [references/tilemap-types.md](references/tilemap-types.md).

---

## `Tilemap16bits` — chunks pour économiser

Variante pour maps **64×128 tiles** (= 8192 tiles, trop pour 1 octet/tile). Utilise des **chunks 8×8** comme niveau intermédiaire :

```
Map (64×128 tiles) ──[chunk id 1 octet]──→ Chunk (8×8 tiles) ──[tile id 1 octet]──→ Tile bitmap
```

Total : 64 × 128 = 8192 entrées dans la map, mais une carte de 1 octet/entrée fait 8 Ko. Avec chunks :
- 64 × 128 / (8 × 8) = 128 chunks dans la map
- Chaque chunk = 8 × 8 = 64 octets de tile IDs
- Tile bitmaps : 256 max

Économie : 1 Ko de map + 8 Ko de chunks + tiles vs 8 Ko de map directe + tiles.

Structure (`map-16bits.equ`) :
```asm
submap_camera_x_min equ   0
submap_camera_y_min equ   2
submap_camera_x_max equ   4
submap_camera_y_max equ   6
layer_map_width     equ   8
layer_map_height    equ   9
layer_map           equ   10    ; w → [b] : map des chunk IDs (1 byte each)
layer_chunk0        equ   12    ; w → [w] : chunks 0-127
layer_chunk1        equ   14    ; w → [w] : chunks 128-255
layer_tiles         equ   16    ; w → [bw] : tile index (3 bytes : page + addr)
layer_mul_ref       equ   18    ; w : table pré-calculée pour Y dans map
```

Utilisé par sonic-2.

---

## `TilemapBuffer` — buffer cyclique

Buffer 2 Ko (32×16 tiles de 16×16 px) pour streaming. Permet d'afficher une zone plus grande que l'écran en cyclant le buffer.

Variables :
```asm
glb_map_pge             fcb   0
glb_map_adr             fdb   0
glb_map_chunk_pge       fcb   0     ; chunks
glb_map_chunk_adr       fdb   0
glb_map_defchunk0_pge   fcb   0     ; tile bitmaps
glb_map_defchunk0_adr   fdb   0
glb_map_defchunk1_pge   fcb   0
glb_map_defchunk1_adr   fdb   0
glb_map_tiles_pge       fcb   0
glb_map_tiles_adr       fdb   0
glb_map_width           fcb   0
```

Utilisé par wide-dot-engine (cf. skill `thomson-to8-to9-video/references/wide-dot-engine.md` dans gen-ai).

---

## `Spritemap` — sprites dynamiques depuis une map

Permet de spawner des objets depuis une map (chaque entrée map = ObjID à spawn à cette position).

Variables :
```asm
glb_spritemap_obj             fdb   0
glb_spritemap_addr            fdb   0
glb_spritemap_page            fcb   0
glb_spritemap_index           fdb   0
glb_spritemap_index_old       fdb   0
spritemap_cur_index_end       fdb   0
spritemap_cur_index           fdb   0
```

Structure (`spritemap.equ`) :
```asm
spmap_x_pos               equ   0
spmap_y_pos               equ   2
spmap_vp_tiles_x          equ   4
spmap_tile_size_bitmask_x equ   6
spmap_tile_size_divider_x equ   7
smpap_tile_x_size         equ   8
spmap_nb_tiles_x          equ   9
spmap_map                 equ   10    ; map de ObjID + position
```

Algorithme : à chaque frame, calcule la zone visible (basée caméra) et alloue les objets dont la position tombe dans la zone.

---

## `TileAnimScript` — animation de tiles

Anime des tiles via un script déclaratif (eau, feu, plantes mouvantes).

Variables par animation script :
```asm
ZACurIndex equ   0       ; index courant dans le script
ZACurFrame equ   1       ; frame courante de l'animation
ZADuration equ   2       ; durée restante (frames 20ms)
ZAMaxFrame equ   3       ; nb frames max
ZASize     equ   4

TileAnimScriptData       fill 0, 16*ZASize   ; jusqu'à 16 animations simultanées
```

### Init

```asm
        ldx   #my_anim_list
        jsr   TileAnimScriptInit
```

`my_anim_list` est une suite de pointeurs vers les scripts d'animation, terminée par 0.

### Tick

```asm
TileAnimScript
        ldx   #0                        ; (dynamic = TileAnimScriptList)
        ; Pour chaque script :
        ;   Décrémenter ZADuration
        ;   Si écoulé, charger frame suivante
        ;   ...
```

Appelée chaque frame (typiquement depuis MainLoop ou IRQ).

Synchro framerate via `gfxlock.frameDrop.count`.

Voir [references/tile-anim-script.md](references/tile-anim-script.md).

---

## `tileset.X` property — pipeline

Dans le `.properties` d'un objet, on peut déclarer un tileset :

```properties
tileset.TileSet_levelA=./objects/scroll/tileset.png;61,8,8,TILE16x16
```

Format :
```
tileset.<Nom>=<fichier>;<nbTiles>,<nbCols>,<nbRows>[,<centerMode>[,<mapFile>[,<mapBitDepth>]]]
```

| Champ | Valeurs |
|-------|---------|
| `nbTiles` | nb total |
| `nbCols`/`nbRows` | grille |
| `centerMode` | `CENTER`/`TOP_LEFT`/`TILE8x16`/`TILE16x16` (par défaut `TOP_LEFT`) |
| `mapFile` | chemin map binaire (optionnel) |
| `mapBitDepth` | profondeur bit des IDs (défaut 8) |

Tilesets sont **toujours en RAM** (`tileset.inRAM = true` hardcodé pour vitesse).

---

## Choix entre les systèmes

| Genre | Système recommandé |
|-------|--------------------|
| Fond statique HUD-like | Pas besoin de tilemap, `DrawFullscreenImage` |
| Fond statique large (4-direction) | `Tilemap` ou `Tilemap16bits` |
| Fond avec layers parallax | `Tilemap` multi-layers |
| Sprites spawnés dynamiquement depuis map | `Spritemap` |
| Tiles animées (eau, feu) | `TileAnimScript` + tilemap |
| Vertical scrolling | `vscroll` (skill scrolling) |
| Horizontal scrolling | `horizontal-scroll` (skill scrolling) |
| Wide-dot avec streaming | `TilemapBuffer` |

---

## Pitfalls

- **Submap dépassant la taille déclarée** : crash ou affichage random
- **Layer parallax_X = 0** mais layer attendu fixe : OK, mais ne pas oublier `parallax_Y` aussi
- **Tile size bitmask incompatible avec divider** : maths cassées, mauvaise position des tiles
- **`Tilemap16bits` mais chunks pas définis** : crash (page 0 mountée)
- **`TileAnimScript` non initialisée** : `TileAnimScriptList = 0` → routine skipée silencieusement
- **`Spritemap` mais pool d'objets plein** : objets manqués silencieusement
- **`mapBitDepth` incorrect** : tile IDs décodés en mauvaise valeur
- **Tilesets pas en RAM** : impossibilité (toujours RAM par engine)

---

## Références détaillées

- [references/tilemap-types.md](references/tilemap-types.md) — `Tilemap` détaillé : structure submap, layers, parallax 8-bit décimal, tile_size_bitmask/divider pour div rapide, `glb_submap_index_buf0/1` pour double buffer, viewport offset, `DrawTilemap` algorithme. `Tilemap16bits` avec chunks 8×8 : pourquoi, économie mémoire, structure
- [references/tile-anim-script.md](references/tile-anim-script.md) — `TileAnimScript` complet : format binaire d'un script (frame duration / nb frames / tiles list), `TileAnimScriptInit` parcours de la liste, `TileAnimScriptData` (16 slots), sync framerate via `gfxlock.frameDrop.count`, patterns water/fire/plant
- [references/spritemap.md](references/spritemap.md) — `Spritemap` allocation dynamique : structure spmap, conversion caméra → index, `LoadObject_u` automatique pour chaque entrée visible, `spritemap_cur_index*` pour tracker la zone visible vs précédente, pattern avec scroll
- [references/tileset-pipeline.md](references/tileset-pipeline.md) — Pipeline du builder Java pour `tileset.X` : parsing des paramètres (nbTiles, cols, rows, centerMode, mapFile), génération du code asm tile par tile, modes CENTER/TOP_LEFT/TILE8x16/TILE16x16, restriction inRAM hardcoded, intégration avec `Tilemap`/`Tilemap16bits`
