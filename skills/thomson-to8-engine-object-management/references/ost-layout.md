# OST (Object Status Table) — layout complet

L'OST est la structure de données associée à chaque objet vivant. Elle occupe **`object_size`** octets en RAM dans le pool `Dynamic_Object_RAM`. Tous les champs sont déclarés dans `engine/constants.asm`.

## Calcul de `object_size`

```asm
object_base_size              equ 38                                   ; champs standards
object_rsvd                   equ object_base_size+ext_variables_size  ; début des rsv_*
object_size                   equ object_base_size+ext_variables_size+object_rsvd_size
```

Le `object_rsvd_size` est calculé selon le mode (overlay vs background-erase) :
- En mode background-erase (par défaut), `object_rsvd_size` ≈ 12-15 octets selon les flags
- En mode overlay (`OverlayMode equ 1`), généralement plus compact

En pratique pour la plupart des jeux : `object_size ≈ 50-58` octets.

`ext_variables_size` est **défini par le projet** dans `ram-data.asm` du game-mode. Valeurs observées :

| `ext_variables_size` | Cas d'usage |
|----------------------|-------------|
| 0 | Objets simples sans variables locales (test, 2026 TitleScreen) |
| 9 | 1 AABB par objet (bubble-bobble) |
| 20 | Plusieurs AABB ou structs complexes (r-type) |

## Layout complet (offsets fixes)

```
Offset  | Symbole              | Taille | Type        | Lecture/Écriture |
--------|----------------------|--------|-------------|------------------|
0       | id                   | 1      | ObjID_      | RW utilisateur   | (0 = slot libre)
1       | subtype              | 1      | Sub_        | RW utilisateur   |
1       | subtype_w            | 2      | Sub_ étendu | RW (overlap render_flags) |
2       | render_flags         | 1      | bitfield    | RW utilisateur+engine |
3-4     | run_object_prev      | 2      | ptr OST     | engine only      | (run-list)
5-6     | run_object_next      | 2      | ptr OST     | engine only      | (run-list)
7       | priority             | 1      | 0..8        | RW utilisateur   | (0=cache, 1=front, 8=back)
8-9     | anim                 | 2      | Ani_        | RW utilisateur   |
10-11   | prev_anim            | 2      | Ani_        | engine           |
10-11   | sub_anim             | 2      | Ani_        | RW (overlap prev_anim) |
12      | anim_frame           | 1      | index       | engine           |
13      | anim_frame_duration  | 1      | 0..127      | engine           |
13      | wave_frame_drop      | 1      | (overlap)   | objectWave only  |
14      | anim_flags           | 1      | flags v02   | RW (anim système) |
14      | status_flags         | 1      | bitfield    | RW utilisateur   | (xflip/yflip)
16-17   | image_set            | 2      | Img_        | engine (mis à jour par AnimateSprite) |
18-19   | x_pos                | 2      | s16.8 high  | RW utilisateur   |
20      | x_sub                | 1      | s16.8 low   | RW (lié à x_pos) |
21-22   | y_pos                | 2      | s16.8 high  | RW utilisateur   |
23      | y_sub                | 1      | s16.8 low   | RW (lié à y_pos) |
24      | x_pixel (= xy_pixel) | 1      | 0..159      | RW (mode screen) |
25      | y_pixel              | 1      | 0..199      | RW (mode screen) |
26-27   | x_vel                | 2      | s8.8        | RW utilisateur   |
28-29   | y_vel                | 2      | s8.8        | RW utilisateur   |
30-31   | x_acl                | 2      | s8.8        | RW utilisateur   |
32-33   | y_acl                | 2      | s8.8        | RW utilisateur   |
34      | routine              | 1      | index       | RW utilisateur   |
35      | routine_secondary    | 1      | index       | RW utilisateur   |
36      | routine_tertiary     | 1      | index       | RW utilisateur   |
37      | routine_quaternary   | 1      | index       | RW utilisateur   |
38..N   | ext_variables (espace utilisateur) | ext_variables_size | RW utilisateur |
N+1..   | rsv_render_flags     | 1      | engine      | engine only      |
        | rsv_prev_anim        | 2      | (...)       | engine only      |
        | rsv_image_center_offset | 1   |             | engine only      |
        | rsv_image_subset     | 2      |             | engine only      |
        | rsv_mapping_frame    | 2      |             | engine only      |
        | rsv_erase_nb_cell    | 1      |             | engine only      |
        | rsv_page_draw_routine| 1      |             | engine only      |
        | rsv_draw_routine     | 2      |             | engine only      |
```

## Dépendances inter-champs (CRITIQUE)

Plusieurs champs sont contraints à être contigus en mémoire :

| Contrainte | Raison |
|------------|--------|
| `subtype` (1) doit suivre `id` (0) | `ldd id,u` permet de lire les deux d'un coup |
| `x_sub` (20) doit suivre `x_pos` (18-19) | `addd x_pos+1,u` met à jour `x_pos+x_sub` ensemble |
| `y_sub` (23) doit suivre `y_pos` (21-22) | Idem |
| `y_pixel` (25) doit suivre `x_pixel` (24) | `ldd xy_pixel,u` = x+y ensemble |
| `render_flags` bits 0/1 sont xmirror/ymirror (DEPENDENCY explicit dans le code) | `AnimateSprite` applique `status_flags & 3` xor `render_flags & 3` |

## Bits de `render_flags`

### Mode background-erase (par défaut)

```
Bit | Mask  | Symbole                       | Effet
----|-------|-------------------------------|-----
0   | $01   | render_xmirror_mask           | Sprite miroir horizontal
1   | $02   | render_ymirror_mask           | Sprite miroir vertical
2   | $04   | render_overlay_mask           | Sprite compilé sans backup de fond
3   | $08   | render_playfieldcoord_mask    | Coord playfield (x_pos/y_pos) vs écran (x_pixel/y_pixel)
4   | $10   | render_xloop_mask             | Loop X hors écran (en coord écran)
5   | $20   | render_todelete_mask          | Marquer pour suppression engine
6   | $40   | render_subobjects_mask        | Rendre les sous-objets
7   | $80   | render_hide_mask              | Cacher (préserve priority/mapping)
```

### Mode overlay (`OverlayMode equ 1`)

Mêmes bits 0/1/3/4/6/7. Différences :
- Bit 2 (`render_overlay_mask`) : **absent**
- Bit 5 : `render_no_range_ctrl_mask` (skip vérif out-of-range — DANGEREUX, peut corrompre la mémoire)

## Bits de `status_flags`

```
Bit | Mask  | Symbole                  | Effet
----|-------|--------------------------|-----
0   | $01   | status_xflip_mask        | Flip horizontal (appliqué pendant AnimateSprite)
1   | $02   | status_yflip_mask        | Flip vertical
```

## Bits de `anim_flags` (mode v02 ou link)

```
Bit | Mask  | Symbole              | Effet
----|-------|----------------------|-----
2   | $04   | anim_link_mask       | Charger une nouvelle animation sans reset anim_frame
```

En mode v02 (advanced), `anim_flags` est utilisé comme offset dans une LUT applicative pour déclencher des callbacks à des frames spécifiques.

## Bits de `rsv_render_flags` (zone réservée engine)

```
Bit | Mask  | Symbole                       | Effet
----|-------|-------------------------------|-----
0   | $01   | rsv_render_checkrefresh_mask  | EraseSprite + DisplaySprite traités cette frame
1   | $02   | rsv_render_erasesprite_mask   | Sprite à effacer
2   | $04   | rsv_render_displaysprite_mask | Sprite à dessiner
3   | $08   | rsv_render_outofrange_mask    | Sprite out-of-range full-rendering
7   | $80   | rsv_render_onscreen_mask      | A été rendu sur le dernier buffer
```

Ces flags sont gérés par le moteur (`CheckSpritesRefresh`, `DrawSprites`, `EraseSprites`). Ne pas modifier depuis le code utilisateur sauf cas spécifique (`glb_force_sprite_refresh`).

## Variables locales dans `ext_variables`

Si `ext_variables_size > 0`, on peut réserver des slots :

```asm
; Dans le code de l'objet
my_health       equ ext_variables       ; 1 octet à l'offset 38
my_target_addr  equ ext_variables+1     ; 2 octets à l'offset 39-40
AABB_0          equ ext_variables       ; 9 octets pour 1 AABB de collision
```

Conventions observées :
- `AABB_0`, `AABB_1`, ... pour les zones de collision
- `player_pos_ring_buffer_ptr` (r-type) pour des historiques de position
- Variables métier libres au choix du développeur

## ⚠️ Règles critiques à connaître pour `render_flags` et `xy_pixel`

### `render_overlay_mask` OBLIGATOIRE pour sprites variant `D*` (Draw seul)

Si le sprite associé à l'objet est compilé avec un variant `ND0`/`ND1`/`XD*`/`YD*`/`XYD*` (= mode Draw seul, sans backup du fond), il faut **impérativement** poser `render_overlay_mask` dans `render_flags,u` à l'init :

```asm
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
```

Sans ce flag, l'engine cherche un code d'erase compilé qui n'existe pas pour les variants D → **sprite invisible** sans message d'erreur.

Pour les variants `NB*`/`XB*`/`YB*`/`XYB*` (mode Backup), `render_overlay_mask` doit rester à 0.

### Position du centre : `ceil(taille/2)-1` (pas `taille/2`)

Quand on positionne un sprite via `xy_pixel` (= `x_pixel` + `y_pixel`), la convention CENTER de l'engine considère le centre interne du sprite à l'offset `ceil(sprite_size/2)-1`. Pour les tailles paires, ce centre est **un pixel avant** le milieu mathématique :

| Taille | Centre interne | `x_pixel` pour top-left à x=0 |
|--------|----------------|-------------------------------|
| 16 px | 7 | 7 |
| 32 px | 15 | 15 |
| 100 px | 49 | 49 |
| 160 px | 79 | 79 |

Si on se trompe d'un pixel et que le sprite déborde, et que `render_xloop_mask` n'est PAS posé, le sprite **n'est pas dessiné** (clipping out total, silencieux).

---

## Initialisation d'un slot fraîchement alloué

Après `LoadObject_u`, le slot est **garanti à zéro** (sauf `id` que tu vas mettre toi-même). C'est `UnloadObject_*` qui efface tous les octets via une boucle `pshu d,x,y` optimisée. Donc tous les champs `render_flags`, `priority`, `x_vel`, etc. valent 0 par défaut.

Init typique :
```asm
        jsr   LoadObject_u
        beq   @noslot
        lda   #ObjID_X
        sta   id,u
        ldd   #Ani_X_default
        std   anim,u
        ldb   #4
        stb   priority,u
        ldd   #$80AF                    ; xy_pixel = $80 (x), $AF (y)
        std   xy_pixel,u
        ; le reste (render_flags, x_vel, etc.) reste à 0
@noslot
```

## Diagramme mémoire d'un slot

```
   u → ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
       │id│st│RF│prev │next │pr│anim │panim│af│ad│sf│  │
       ├──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┤
       │image_set│ x_pos  │xs│ y_pos  │ys│xp│yp│ x_vel│
       ├──────────────────────────────────────────────┤
       │ y_vel│ x_acl│ y_acl│r1│r2│r3│r4│              │
       ├──────────────────────────────────────────────┤
       │     ext_variables (taille variable)          │
       │ ... (AABB, vars locales, etc.)               │
       ├──────────────────────────────────────────────┤
       │     rsv_* (zone réservée engine)             │
u+os → └──────────────────────────────────────────────┘
```
