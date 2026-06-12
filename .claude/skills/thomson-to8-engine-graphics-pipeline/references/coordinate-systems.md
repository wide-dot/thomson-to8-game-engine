# Systèmes de coordonnées — playfield vs écran

L'engine gère **deux systèmes de coordonnées** pour les sprites :

| Système | Champs OST | Taille | Usage |
|---------|------------|--------|-------|
| Playfield | `x_pos` (16.8) + `y_pos` (16.8) | 3 octets chacun | Monde scrollé (jeu), positions absolues |
| Écran | `x_pixel` + `y_pixel` (= `xy_pixel`) | 1 octet chacun | HUD, UI, sprites fixes |

Le choix est fait via `render_flags` :

```asm
        lda   render_flags,u
        ora   #render_playfieldcoord_mask   ; bit 3 = playfield
        sta   render_flags,u
```

Si le bit 3 (`render_playfieldcoord_mask`) est :
- **1** : le moteur utilise `x_pos`/`y_pos` et applique la conversion via caméra
- **0** : le moteur utilise `x_pixel`/`y_pixel` directement

## Coord playfield — fixed-point 16.8

```
x_pos = 2 octets (partie entière signée -32768..+32767)
x_sub = 1 octet (partie fractionnaire 0..255 = 0..0.996)
```

Permet :
- Une **map** allant de -32768 à +32767 pixels
- Une précision **sub-pixel** (0.0039 pixel par incrément de x_sub)
- Des **vitesses précises** : `x_vel = $0080` = 0.5 pixel/frame en moyenne

`x_pos` et `x_sub` **doivent être contigus** en mémoire (offset 18-20) pour que `addd x_pos+1,u` mette à jour `x_sub+x_pos.low` ensemble.

## Coord écran — 8 bits

```
x_pixel = 1 octet (position X à l'écran, 0..255 mais 0..159 visible en mode 160 colonnes)
y_pixel = 1 octet (position Y à l'écran, 0..199 visible)
```

Plus simple, plus rapide, mais limité à 256×256 pixels. Pas de sub-pixel.

### ⚠️ Règle de positionnement du centre d'un sprite (mode CENTER)

Le `x_pixel`/`y_pixel` pointe le **centre interne du sprite**, mais ce centre n'est PAS `taille/2` — c'est `ceil(taille/2)-1` :

```
center_internal_offset = ceil(sprite_size / 2) - 1
```

Pour les tailles paires, c'est un pixel **avant** le milieu mathématique :

| Taille sprite | center_internal_offset | Pour `x_pixel` du centre à 80 → top-left du sprite à |
|---------------|------------------------|------------------------------------------------------|
| 8 px | 3 | 80 - 3 = 77 |
| 16 px | 7 | 80 - 7 = 73 |
| 32 px | 15 | 80 - 15 = 65 |
| 100 px | 49 | 80 - 49 = 31 |
| 160 px | 79 | 80 - 79 = 1 |

**Pour qu'un sprite 160 px occupe exactement les 160 colonnes (X=0..159)** : le top-left doit être à x=0, donc `x_pixel = 79` (et **pas 80**).

**Risque si on se trompe d'un pixel** : le sprite peut déborder de la zone visible. Et si `render_xloop_mask` n'est PAS activé, l'engine peut **ne pas dessiner le sprite du tout** (clipping out total) → le sprite disparaît silencieusement, sans message d'erreur. Bug très piégeux.

**Sécurité** : pour les sprites qui doivent pouvoir déborder (typique des fonds en perspective), poser explicitement `render_xloop_mask` à l'init pour permettre le wrap horizontal.

## Caméra — conversion automatique

Quand `render_playfieldcoord_mask` est mis, le moteur calcule à l'affichage :

```
x_pixel_effective = x_pos - glb_camera_x_pos + glb_camera_x_offset
y_pixel_effective = y_pos - glb_camera_y_pos + glb_camera_y_offset
```

Variables globales caméra :
```asm
glb_camera_x_pos               ; position X caméra dans le playfield (s16.8)
glb_camera_y_pos               ; position Y caméra (s16.8)
glb_camera_x_pos_coarse        ; ((x_pos - 64) / 64) * 64 — pour alignement scroll
glb_camera_x_offset            ; offset à appliquer (init = screen_left)
glb_camera_y_offset            ; offset Y (init = screen_top)
glb_camera_width               ; largeur du viewport visible
glb_camera_height              ; hauteur
glb_camera_x_min_pos           ; borne min de scroll caméra
glb_camera_x_max_pos           ; borne max
glb_camera_y_min_pos           ; idem Y
glb_camera_y_max_pos
```

## `InitDrawSprites` — initialisation caméra

```asm
InitDrawSprites
        ldd   #screen_left
        std   glb_camera_x_offset
        ldd   #screen_top
        std   glb_camera_y_offset
        rts
```

Initialise `glb_camera_x/y_offset` aux constantes `screen_left` / `screen_top` (définies dans `engine/constants.asm` selon la résolution choisie).

**À appeler au boot** du game-mode, sinon les sprites en mode playfield sont mal placés.

## `screen_left` / `screen_top`

Définis dans `engine/constants.asm`. Valeurs typiques pour le mode 160×200 :
- `screen_left = 48` (32+16, alignement wide-dot)
- `screen_top = 28` ou 14 selon mode

Ces constantes représentent le **décalage de la zone visible** par rapport au coin haut-gauche du buffer vidéo (qui inclut des bordures non visibles).

## Pattern de choix

### HUD / UI (coord écran)

```asm
Init
        ; ... 
        ldd   #$10A0                    ; x_pixel = $10, y_pixel = $A0
        std   xy_pixel,u
        ; render_playfieldcoord_mask non mis → utilise xy_pixel
        inc   routine,u
```

Les éléments HUD ne bougent jamais avec la caméra. Coord écran direct.

### Sprite dans le monde (coord playfield)

```asm
Init
        ; ...
        ldd   #200                      ; x_pos = 200 dans le playfield
        std   x_pos,u
        ldd   #100
        std   y_pos,u
        clr   x_sub,u                   ; sub-pixel 0
        clr   y_sub,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u
```

Le sprite suit la caméra : si la caméra se déplace de 50 px à droite, le sprite reste « à sa place dans le monde » et apparaît 50 px plus à gauche à l'écran.

## `render_xloop_mask`

Bit 4 : **loop horizontal** quand le sprite est hors écran (en coord écran seulement).

Permet à un sprite décor (étoile, particule de fond) de réapparaître de l'autre côté de l'écran quand il en sort. Utilisé pour fonds défilants infinis (starfield).

```asm
        ora   #render_xloop_mask
```

Ne fonctionne **qu'en coord écran** (pas playfield).

## Modes graphiques et résolution

Le TO8 a plusieurs modes :

| Mode | Résolution | Couleurs | Mémoire VRAM |
|------|------------|----------|--------------|
| BM4 | 320×200 | 4 couleurs | 8 Ko + 8 Ko (couleur) = 16 Ko |
| BM16 | 160×200 | 16 couleurs | 16 Ko |
| 80 col | 80×200 texte | 8 couleurs | 16 Ko |

L'engine utilise par défaut **BM16** (160×200, 16 couleurs). Les constantes `screen_left`/`screen_top` et la conversion caméra sont calibrées pour ce mode.

Pour un autre mode, il faudrait recalibrer (pas standard dans le repo).

## Conversion manuelle (rare)

Si on veut convertir manuellement playfield → écran sans utiliser le bit `render_playfieldcoord_mask` :

```asm
        ldd   x_pos,u                   ; lire playfield
        subd  glb_camera_x_pos
        addd  glb_camera_x_offset       ; pas standard, plutôt ld + add direct
        ; D = position écran
        stb   x_pixel,u                 ; (low 8 bits)
```

Mais c'est rare ; le moteur le fait automatiquement.

## Pitfalls

- **Position calculée comme `taille/2`** au lieu de `ceil(taille/2)-1` : décalage d'un pixel, possible débordement, sprite invisible si `render_xloop_mask` absent. C'est l'erreur la plus piégeuse car silencieuse.
- **Modifier `x_pos` sans `x_sub`** : la partie haute change sans la basse → l'objet « saute »
- **`render_playfieldcoord_mask` mis mais `x_pos`/`y_pos` non initialisés** : sprite à (0,0) - camera → hors écran
- **`InitDrawSprites` oublié** : `glb_camera_x/y_offset = 0` → sprites en haut-gauche du buffer (souvent invisibles à cause de la zone non-visible)
- **Confondre `x_pixel` et `x_pos`** : `x_pixel,u` (offset 24) ≠ `x_pos,u` (offset 18). Toujours vérifier le mode (coord écran vs playfield)
- **`x_pixel` > 159 en mode 160 colonnes** : sprite hors écran (clipped). `x_pixel` peut être 160-255 si `render_xloop_mask`, sinon caché
- **`y_pixel` > 199** : sprite sous l'écran, clipped
