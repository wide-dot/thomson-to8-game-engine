# `TileAnimScript` — animation de tiles

Permet d'animer des tiles dans une tilemap (eau qui bouge, feu, plantes oscillantes) via un **script déclaratif**. Jusqu'à 16 animations simultanées.

## Variables

```asm
ZACurIndex equ   0       ; offset 0 : index courant dans le script
ZACurFrame equ   1       ; offset 1 : frame courante de l'animation
ZADuration equ   2       ; offset 2 : durée restante (frames 20ms)
ZAMaxFrame equ   3       ; offset 3 : nb frames max
ZASize     equ   4       ; taille struct = 4 octets

TileAnimScriptData
        fill  0,16*ZASize ; jusqu'à 16 animations
```

## Initialisation — `TileAnimScriptInit`

```asm
        ldx   #my_animation_list
        jsr   TileAnimScriptInit
```

`my_animation_list` est une suite de pointeurs vers les scripts d'animation (chacun pointant vers un format de données spécifique), terminée par 0 :

```asm
my_animation_list
        fdb   anim_water
        fdb   anim_fire
        fdb   anim_plant
        fdb   0                         ; fin
```

`TileAnimScriptInit` :
```asm
TileAnimScriptInit
        stx   TileAnimScriptList        ; sauve la liste pour TileAnimScript
        ldu   #TileAnimScriptData
@loop   ldy   ,x++                      ; lit pointeur vers script
        beq   @rts
        ldd   ,y                        ; lit 1er octet (duration globale ?)
        bpl   @globalduration
        ; ... global duration ou per-frame duration ...
        stb   ZAMaxFrame,u
        ldd   2,y
        incb
        std   ZACurFrame,u
        bra   @common
@globalduration
        inca
        std   ZADuration,u
        lda   2,y
        sta   ZACurFrame,u
@common
        clr   ZACurIndex,u
        leau  ZASize,u                  ; passe à l'entrée suivante dans Data
        bra   @loop
@rts    rts
```

Chaque script peut avoir :
- Une **duration globale** (toutes les frames même duration) — flag négatif au début
- Des durations **par frame** — flag positif

## Format binaire d'un script

### Avec duration globale (legacy)

```
@anim_water
        fcb   $05                      ; positive = duration globale = 5 frames
        fcb   4                        ; nb frames = 4
        ; ... (peut-être données complémentaires)
```

### Avec duration par frame

```
@anim_fire
        fcb   $80, 4                   ; négative = per-frame mode, nb frames = 4
        fdb   tile_fire_001            ; frame 0
        fdb   tile_fire_002            ; frame 1
        ; ...
```

(format à vérifier dans le code engine pour le détail exact)

## Tick — `TileAnimScript`

```asm
TileAnimScript
        ldx   #0                        ; (dynamic = TileAnimScriptList)
TileAnimScriptList equ *-2
        beq   @rts                      ; pas de liste init → rien
        ldu   #TileAnimScriptData
@loop   ldy   ,x++
        beq   @rts                      ; fin de liste
        
        lda   ZADuration,u
        suba  gfxlock.frameDrop.count   ; sync framerate
        bcs   @loadScript
        sta   ZADuration,u
        leau  ZASize,u
        bra   @loop
        
@loadScript
        sta   @delta                    ; report frames sautées
        lda   ZACurIndex,u
        inca
        cmpa  ZAMaxFrame,u
        bne   @a
        lda   #0                        ; reset
@a      sta   ZACurIndex,u
        ; ... mettre à jour le tile bitmap ...
        leau  ZASize,u
        bra   @loop
```

Boucle sur les 16 slots possibles. Pour chacun :
1. Décrémente `ZADuration` selon `frameDrop.count` (sync)
2. Si écoulé, avance `ZACurIndex` (frame suivante)
3. Met à jour le bitmap du tile correspondant

## Quand appeler

```asm
MainLoop
        jsr   RunObjects
        jsr   TileAnimScript            ; tick animations de tiles
        jsr   CheckSpritesRefresh
        ; ...
```

Appelée chaque frame. Sync via `gfxlock.frameDrop.count` (donc adaptive).

## Cas d'usage

### Eau qui bouge (4 frames)

```asm
anim_water
        fcb   $05, 4                    ; 5 frames per image, 4 images
        fdb   tile_water_001            ; ondulation 1
        fdb   tile_water_002
        fdb   tile_water_003
        fdb   tile_water_004
```

### Feu (looping)

```asm
anim_fire
        fcb   $03, 4                    ; 3 frames per image, 4 images
        fdb   tile_fire_001
        fdb   tile_fire_002
        fdb   tile_fire_003
        fdb   tile_fire_002             ; ping-pong via duplicate
```

### Plante oscillante (slow)

```asm
anim_plant
        fcb   $10, 2                    ; 16 frames per image, 2 images
        fdb   tile_plant_norm
        fdb   tile_plant_tilted
```

## Intégration avec `Tilemap`

Le tile animé est référencé par la map normalement. Quand `TileAnimScript` change le bitmap pointé par le tile_id, **toutes les occurrences** du tile sont automatiquement mises à jour visuellement à la prochaine `DrawTilemap`.

Pratique : pas besoin de modifier la map elle-même, juste le pointeur de bitmap.

## Limites

- **16 animations** simultanées max (taille du buffer `TileAnimScriptData`)
- **1 octet pour ZADuration** : max 127 frames (~2.5s) entre changements
- **1 octet pour ZAMaxFrame** : max 256 frames par animation
- Synchro framerate via `gfxlock.frameDrop.count` (donc nécessite gfxlock)

## Pitfalls

- **Liste non terminée par 0** : `TileAnimScript` lit après la fin → boucle infinie / crash
- **Plus de 16 animations** : seules les 16 premières sont prises (silencieux)
- **`TileAnimScriptInit` non appelé** : `TileAnimScriptList = 0`, routine skipée silencieusement
- **Modifier `TileAnimScriptData` à la main** : risque de corruption (préférer réinitialiser via Init)
- **`gfxlock.frameDrop.count = 0`** (pas de gfxlock) : animation figée
- **Sync avec changement de game-mode** : `TileAnimScriptData` partagé, à reset au boot
- **Anim sans pointeurs valides** : tiles affichés au pointeur 0 (image noire ou random)
