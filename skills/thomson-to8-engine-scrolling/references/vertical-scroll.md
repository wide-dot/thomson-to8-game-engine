# `vscroll` — scrolling vertical

Le système `vscroll` permet un scrolling vertical fluide avec tileset (BM16, 160×200). Utilisé par bubble-bobble et goldorak.

## Composants

```
┌─────────────────────────────────────────────────────┐
│  Map (objet levelMap) : grille 2D de tile IDs       │
│  ex: 38 rows × 16 cols, chaque tile = 16x16 px      │
│  Mode 256 tiles : 1 octet/id                        │
│  Mode 512 tiles : 2 octets/id                       │
└─────────────────────────────────────────────────────┘
            │
            ↓
┌─────────────────────────────────────────────────────┐
│  Tileset (objets levelTileA/B) : 256 ou 512 tiles  │
│  Chaque tile = bitmap 16x16 (en code asm)           │
└─────────────────────────────────────────────────────┘
            │
            ↓
┌─────────────────────────────────────────────────────┐
│  Buffer A et B (objets scrollA/scrollB)             │
│  Double-buffer cyclique, contient le snapshot       │
│  du viewport en cours d'affichage                   │
└─────────────────────────────────────────────────────┘
            │
            ↓
┌─────────────────────────────────────────────────────┐
│  Écran (BM16, 160x200 visible)                      │
│  La caméra y_pos pointe dans la map ; le viewport  │
│  affiche les lignes [y_pos, y_pos + viewport_height]│
└─────────────────────────────────────────────────────┘
```

## Setup

```asm
        ; 1. Map
        _vscroll.setMap #ObjID_levelMap
        _vscroll.setMapHeight #38*16    ; 608 pixels (38 rows × 16)
        
        ; 2. Tileset
        _vscroll.setTileset256 ObjID_levelTileA0,ObjID_levelTileB0
        _vscroll.setTileNb #61          ; 61 tiles uniques dans le tileset
        
        ; 3. Buffer
        _vscroll.setBuffer #ObjID_scrollA,#ObjID_scrollB
        
        ; 4. Camera
        _vscroll.setCameraPos #0        ; commence en haut
        _vscroll.setCameraSpeed #$0100  ; 1 px/frame
        _vscroll.setViewport #0,#200    ; tout l'écran visible
```

## Macros détaillées

### `_vscroll.setMap` — pointer la map

```asm
_vscroll.setMap MACRO
        ldb   \1                        ; ObjID_ de la map
        ldx   #Obj_Index_Page
        lda   b,x
        sta   vscroll.obj.map.page      ; sauve la page
        aslb
        ldx   #Obj_Index_Address
        ldx   b,x
        stx   vscroll.obj.map.address   ; sauve l'adresse
 ENDM
```

L'objet `levelMap` doit contenir la map sous forme binaire (cf. pipeline `stm2bin`).

### `_vscroll.setMapHeight`

```asm
_vscroll.setMapHeight MACRO
        ldd   \1
        std   vscroll.map.height
 ENDM
```

Total height en pixels. La caméra ne peut pas dépasser cette valeur (sinon wrap ou crash selon le mode).

### `_vscroll.setTileset256` vs `_vscroll.setTileset512`

256 tiles : tile id sur 1 octet → 256 tiles uniques max.
512 tiles : tile id sur 2 octets → 512 tiles uniques (avec mode 12-bit, valeurs paires : 256 distincts en mémoire).

Pour 256 :
```asm
_vscroll.setTileset256 MACRO
 IFDEF vscroll.tiles.DEFINED
        lda   #16                       ; 16 lignes par page
        _vscroll.setUpdateRoutine_
 ENDC
        _vscroll.setTileset_
        fcb   \1                        ; ObjID tile A
        fcb   \2                        ; ObjID tile B
        ; ... répété 8 fois ...
 ENDM
```

Deux ObjIDs (`A` et `B`) car les tiles sont stockés sur 2 pages (par paires AB) pour économiser de la RAM.

### `_vscroll.setTileNb`

```asm
        _vscroll.setTileNb #61
```

Nombre de tiles **uniques** dans le tileset (vs. la capacité max 256/512). Permet d'optimiser le traitement.

### `_vscroll.setBuffer`

```asm
        _vscroll.setBuffer #ObjID_scrollA,#ObjID_scrollB
```

Deux objets buffer pour le double-buffer. Chaque buffer = snapshot du viewport courant.

### `_vscroll.setCameraPos` / `_vscroll.setCameraSpeed`

```asm
        _vscroll.setCameraPos #0        ; commence à y=0
        _vscroll.setCameraSpeed #$0100  ; 1.0 px/frame (8.8 fixed-point)
```

Vitesse en 8.8 :
- `$0100` = 1.0 px/frame
- `$0080` = 0.5 px/frame
- `$0040` = 0.25 px/frame
- `$0200` = 2.0 px/frame

### `_vscroll.setViewport`

```asm
        _vscroll.setViewport #0,#200    ; y_min=0, y_max=200 (full screen)
        _vscroll.setViewport #40,#160   ; viewport partiel (40-159)
```

Permet d'avoir un HUD au-dessus/en-dessous du scroll.

## Boucle MainLoop avec vscroll

```asm
MainLoop
        jsr   RunObjects                ; les ennemis bougent
        ; ... collisions ...
        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        jsr   vscroll.do                ; dessine la slice de map
        jsr   vscroll.move              ; avance la caméra
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _gfxlock.off
        _gfxlock.loop
        bra   MainLoop
```

`vscroll.do` lit la map et écrit les tiles dans le buffer courant. `vscroll.move` met à jour `vscroll.camera.y` selon la speed.

## Pattern `scroll.goUntil` (bubble-bobble)

Pour faire un scroll programmé jusqu'à une position cible, sans logique gameplay pendant :

```asm
scroll.goUntil.pos fdb 0

scroll.goUntil
@loop
        jsr   scroll.doOneLoop          ; 1 tour de scroll
        ldd   scroll.goUntil.pos
        subd  #10
        cmpd  vscroll.camera.y
        bhi   @loop                     ; tant qu'on n'est pas à 10px de la cible
        
        ; fine scroll (vitesse réduite)
        _vscroll.setCameraSpeed #$0040
@loop2
        jsr   scroll.doOneLoop
        ldd   scroll.goUntil.pos
        subd  #1
        cmpd  vscroll.camera.y
        bhi   @loop2                    ; jusqu'à 1px de la cible
        
        ; stop
        _vscroll.setCameraSpeed #0
        jsr   scroll.doOneLoop
        jsr   scroll.doOneLoop          ; 2 derniers tours pour finaliser
        rts

scroll.doOneLoop
        jsr   ReadJoypads
        jsr   RunObjects
        lda   #1
        sta   <glb_force_sprite_refresh ; force refresh tout
        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        jsr   vscroll.do
        jsr   vscroll.move
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _gfxlock.off
        _gfxlock.loop
        rts
```

Permet un scroll cinématique entre deux écrans, avec fade de vitesse à l'arrivée.

## Pipeline d'assets

### 1. Pro Motion → STM

Export "all" en .stm (Stamp Map), tiles 16×16, 1 colonne par fichier image.

### 2. STM → BIN (map)

```bash
stm2bin -f="level1.stm" -obd=12 -mul=2
```

Convertit en binaire 12-bit par tile id, valeurs paires. Header STM supprimé.

### 3. PNG → BIN (buffers de départ)

```bash
png2bin -f level1.start.png -lb 4 -pb 8 -p 2 -pd 4 -vs -slc
```

Convertit l'image initiale en buffers de code+data au format vscroll.

Paramètres :
- `lb 4` : 4 bits par pixel dans un plan
- `pb 8` : 8 bits par plan (1 octet)
- `p 2` : 2 plans mémoire (parité)
- `pd 4` : 4 bits par pixel total
- `vs` : output for Vertical Scroll
- `slc` : shift colors left by 1

### 4. Format buffer

Dans les objets `scrollA.properties` et `scrollB.properties` :
```asm
        INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"
@loop
        INCLUDEBIN "./objects/scroll/level1/level1.start.0.0.bin.vscroll"
        _vscroll.buffer.line            ; macro qui découpe par ligne
        jmp   @loop                     ; cyclique
```

### 5. Tileset (512 tiles)

L'image tileset doit faire 8192 pixels de haut (512 × 16). Outil `6809-game-builder` pour la conversion.

## Variables internes

```asm
vscroll.camera.y                fdb 0       ; position Y caméra (16 bits)
vscroll.obj.map.page            fcb 0       ; page mémoire de la map
vscroll.obj.map.address         fdb 0       ; adresse de la map
vscroll.map.height              fdb 0       ; hauteur en pixels
vscroll.obj.tile.pages          fill 0,16   ; pages des tiles (selon mode)
vscroll.tiles.dyncall           ; routines dynamiques pour update tiles
vscroll.tiles.updateTilesForNLines.address  ; adresse routine update
vscroll.tiles.nbLinesByPage     ; nb de lignes par page (16 ou 8)
```

## Pitfalls

- **Map dépassant `vscroll.map.height`** : lecture aléatoire après la fin, glitches visuels
- **Tileset mal aligné** : tiles déplacées, pas en grille
- **`_vscroll.setTileset256` mais 257+ tiles dans le tileset** : tile 256+ inaccessible
- **`_vscroll.setBuffer` sur des objets non chargés** : crash
- **Speed = 0 mais on attend du scroll** : la caméra reste fixe (à vérifier que `_vscroll.setCameraSpeed` a été appelée)
- **Speed > 8 px/frame** : sauts visibles, pas de scroll fluide
- **Modifier `vscroll.camera.y` manuellement** : possible mais override `vscroll.move`. Préférer changer `cameraSpeed` puis remettre 0
- **Génération assets avec mauvais paramètres `png2bin`** : format incompatible, plantage à l'INCLUDEBIN
- **Buffer A et B inversés** : le double-buffer ne fait plus son boulot, tearing
