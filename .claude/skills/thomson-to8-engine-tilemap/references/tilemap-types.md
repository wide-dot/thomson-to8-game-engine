# `Tilemap` et `Tilemap16bits` — détails

## `Tilemap` — multi-layers avec parallax

### Structure submap (`submap.equ`)

```asm
submap_x_pos        equ   0    ; w - position dans la map globale (incl. caméra border)
submap_y_pos        equ   2
submap_camera_x_min equ   4    ; bornes scroll
submap_camera_y_min equ   6
submap_camera_x_max equ   8
submap_camera_y_max equ   10
submap_layers       equ   12   ; table d'adresses de layers
```

Un submap = une « zone » de la map globale (typiquement plus grande que l'écran), avec ses propres bornes de scroll. Le `submap_layers` pointe vers une suite d'adresses de layers (chaque layer indépendant).

### Structure layer (`layer.equ`)

```asm
layer_parallax_X          equ   0     ; 8-bit decimal (n/256) vitesse parallax X
layer_parallax_Y          equ   1
layer_vp_offset           equ   2     ; offset viewport (col*4 + row*40 octets)
layer_vp_tiles_x          equ   4     ; nb tiles visible en X
layer_vp_tiles_y          equ   5
layer_vp_x_size           equ   6     ; viewport X en pixels
layer_vp_y_size           equ   8
layer_mem_step_x          equ   10    ; octets entre 2 tiles d'une colonne
layer_mem_step_y          equ   11    ; octets entre lignes
layer_tile_size_bitmask_x equ   13    ; mask sous-tile X (4px=2, 8=3, 16=4)
layer_tile_size_bitmask_y equ   14
layer_tile_size_divider_x equ   15    ; nb bytes à brancher pour div rapide
layer_tile_size_divider_y equ   16
layer_tiles_location      equ   17    ; index tiles (page + adresse)
layer_width               equ   19    ; tiles en rows
layer_height              equ   20    ; tiles en cols
```

### Parallax — 8-bit decimal

```
parallax_X = $FF (255)  → 0.996 px / px caméra  ≈ 1:1 (sol/foreground)
parallax_X = $C0 (192)  → 0.75 px / px caméra   (couche intermédiaire)
parallax_X = $80 (128)  → 0.5 px / px caméra    (montagnes lointaines)
parallax_X = $40 (64)   → 0.25 px / px caméra   (ciel lointain)
parallax_X = $20 (32)   → 0.125 px / px caméra  (étoiles très lointaines)
parallax_X = $00        → fixed                 (HUD, ne bouge pas)
```

Combine plusieurs layers (3-5 typiquement) pour un effet de profondeur convaincant.

### `tile_size_bitmask` et `_divider`

Pour calculer rapidement `position / tile_size` (division pour trouver l'index de tile), au lieu d'une vraie division, l'engine utilise un **bitmask** et un **branch** :

```asm
        ldd   <glb_camera_x_pos
        subd  submap_x_pos,x
@dynb1  bra   *+2                       ; (modifié à init avec layer_tile_size_divider_x)
        _lsrd                           ; lsrd répété N fois
        _lsrd
        ; ...
```

Le `bra` est patché à init pour brancher en sautant N `_lsrd` selon la taille de tile :
- 4 px tile → 14 octets (brancher tous les `_lsrd`)
- 8 px → 12 octets
- 16 px → 10 octets
- 32 px → 8 octets
- 256 px → 2 octets (ne saute rien)

Économie : pas de boucle, pas de division, juste un branch + un nombre fixe de shifts.

### `DrawTilemap` algorithme

```asm
DrawTilemap
        lda   glb_submap_page
        ldx   glb_submap
        _SetCartPageA                   ; mount page du submap
        
        ldu   submap_layers,x           ; premier layer
        
        leay  layer_tilemap,u
        sty   @dyn2+1                   ; modif l'adresse dans la routine
        ldb   layer_tile_size_divider_x,u
        stb   @dynb1+1                  ; modif le branch divider
        ldd   <glb_camera_x_pos
        subd  submap_x_pos,x            ; relatif à submap
@dynb1  bra   *+2                       ; (patched)
        _lsrd                           ; divide par tile_size
        _lsrd
        ; ...
```

`glb_submap_index` retourné, indexe dans la map.

Pour le double-buffer :
- `glb_submap_index_buf0` = ce qui est affiché sur buffer 0
- `glb_submap_index_buf1` = idem buffer 1

Si `glb_submap_index_buf0 != glb_submap_index`, redessine.

### Setup du game-mode

```asm
        ; Charger le submap
        ldd   #my_submap_addr
        std   glb_submap
        lda   #my_submap_page
        sta   glb_submap_page
        
        ; Force refresh des deux buffers
        ldd   #glb_submap_index_inactive
        std   glb_submap_index_buf0
        std   glb_submap_index_buf1
        
        ; Caméra
        ldd   #initial_camera_x
        std   <glb_camera_x_pos
        ; ...

; Dans MainLoop
MainLoop
        ; ... 
        jsr   DrawTilemap               ; affiche le submap
        ; ...
```

---

## `Tilemap16bits` — maps avec chunks 8×8

Pour les maps **très grandes** (64×128 tiles = 8192 entrées), une représentation directe (1 octet/tile) coûte 8 Ko en RAM. Pas viable.

`Tilemap16bits` introduit un **niveau intermédiaire** : la map référence des **chunks** (groupes de 8×8 tiles), et chaque chunk référence des **tiles** réelles.

### Hiérarchie

```
Map (64×128 entrées)
   │
   │  chaque entrée = 1 octet = chunk_id (0-255)
   ↓
Chunks (128-256 chunks, chacun 8×8 tiles)
   │
   │  chaque tile dans le chunk = 2 octets = tile_id
   ↓
Tile bitmaps
```

### Économie

Pour une map 64×128 :
- Directe : 64×128 × 1 = 8 Ko
- Avec chunks : 64×128/64 = 128 chunks de pointeur (~1 Ko) + chunks données (~4 Ko) = ~5 Ko

Avantage : possibilité de **réutiliser** des chunks (zones similaires de la map).

### Structure (`map-16bits.equ`)

```asm
submap_camera_x_min equ   0
submap_camera_y_min equ   2
submap_camera_x_max equ   4
submap_camera_y_max equ   6
layer_map_width     equ   8    ; b
layer_map_height    equ   9    ; b
layer_map           equ   10   ; w → [b] : map de chunk IDs
layer_chunk0        equ   12   ; w → [w] : chunks 0-127 (2 octets/tile)
layer_chunk1        equ   14   ; w → [w] : chunks 128-255
layer_tiles         equ   16   ; w → [bw] : tile index (3 octets/tile)
layer_mul_ref       equ   18   ; w : table pré-calculée Y position
```

Le `layer_mul_ref` est une LUT pour multiplier rapidement `y * width` (évite mul à runtime).

### Pourquoi `chunk0` et `chunk1` séparés ?

Pour permettre l'usage de **direct page** sur les chunks fréquents (chunk0 = ceux les plus utilisés en DP, chunk1 = secondaires en mémoire normale).

### Différence vs `Tilemap`

- `Tilemap` : 1 octet/tile direct dans la map → max 256 tiles, map jusqu'à ~256×256
- `Tilemap16bits` : 1 octet (chunk_id) → chunks → tile (2 octets dans le chunk) → 65536 tiles possibles, map jusqu'à 64×128 (limitations actuelles)

---

## Choix entre les deux

| Scénario | Système |
|----------|---------|
| Petite map < 256 tiles uniques | `Tilemap` |
| Map avec parallax (couches multiples) | `Tilemap` |
| Grande map avec patterns répétés | `Tilemap16bits` (économise via chunks) |
| Map avec > 256 tiles uniques | `Tilemap16bits` |
| Sonic-2 (EHZ) | `Tilemap16bits` + `TileAnimScript` |

---

## Pitfalls

- **`glb_submap` à 0** : crash de `DrawTilemap`
- **`tile_size_divider` mal initialisé** : maths cassées, mauvaise tile à mauvaise position
- **`parallax_X` = 0** mais on attend du mouvement : layer fixe (intentionnel ou bug)
- **Plusieurs layers avec parallax identique** : pas une erreur mais doublon visuel
- **`layer_tiles_location` pointant vers une page non-mountable** : crash
- **Map > 64×128 en `Tilemap16bits`** : `layer_map_width` overflow (8 bits)
- **Chunk_id pointant vers chunk1 mais chunk1 = 0** : crash
- **Modifier la map en runtime sans force refresh** : `glb_submap_index_buf0/1` ne détectent pas le change
