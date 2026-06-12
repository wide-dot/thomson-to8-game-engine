# Système caméra — variables et `AutoScroll`

Le système caméra gère la position du **viewport visible** dans la map. Les sprites en coord playfield sont automatiquement convertis vers coord écran via la caméra.

## Variables globales

Définies dans `engine/constants.asm` (zone `glb_*`) :

```asm
glb_camera_x_pos                  ; position X caméra (s16.8)
glb_camera_x_sub                  ; sub-pixel X
glb_camera_y_pos                  ; position Y caméra
glb_camera_y_sub                  ; sub-pixel Y
glb_camera_x_pos_coarse           ; ((x_pos - 64) / 64) * 64
glb_camera_width                  ; largeur viewport
glb_camera_height                 ; hauteur viewport
glb_camera_x_min_pos              ; borne min X (scroll-left limite)
glb_camera_y_min_pos              ; borne min Y
glb_camera_x_max_pos              ; borne max X
glb_camera_y_max_pos              ; borne max Y
glb_camera_x_offset               ; offset coord écran (= screen_left init)
glb_camera_y_offset               ; offset Y
glb_camera_move                   ; flag : caméra a bougé cette frame ?
```

## Conversion playfield → écran

Pour un sprite avec `render_playfieldcoord_mask` :
```
x_pixel_effective = x_pos - glb_camera_x_pos + glb_camera_x_offset
y_pixel_effective = y_pos - glb_camera_y_pos + glb_camera_y_offset
```

Calculé par `DrawSprites` (avant de dessiner).

`glb_camera_x/y_offset` est typiquement `screen_left`/`screen_top` (~48 / ~28 selon mode). Initialisé par `InitDrawSprites`.

## `AutoScroll`

Permet de **programmer un déplacement caméra automatique** sur N frames à une vitesse donnée.

### Variables

```asm
glb_auto_scroll_state               fcb   scroll_state_stop
glb_auto_scroll_frames              fdb   0     ; nb de frames restantes
glb_auto_scroll_step                fdb   0     ; msb: px/frame, lsb: sub-pixel
glb_auto_scroll_step_remainder16bit fcb   $00
glb_auto_scroll_step_remainder      fdb   0     ; accumulator pour sub-pixel
```

### États (`AutoScroll.equ`)

```asm
scroll_state_stop                 equ   0
scroll_state_up                   equ   1
scroll_state_down                 equ   2
; (variantes horizontales possibles)
```

### Algorithme

```asm
AutoScroll
        lda   glb_auto_scroll_state
        beq   ATS_Return                ; stop → rien
        ldd   glb_auto_scroll_frames
        subd  #1
        bmi   ATS_Stop                  ; plus de frames → arrêt
        
ATS_Up
        std   glb_auto_scroll_frames
        lda   glb_auto_scroll_state
        deca
        bne   ATS_Down                  ; pas Up → Down
        
        ldd   glb_auto_scroll_step_remainder
        addd  glb_auto_scroll_step      ; ajoute la step au remainder
        std   glb_auto_scroll_step_remainder
        ldd   <glb_camera_y_pos
        subd  glb_auto_scroll_step_remainder16bit
        clr   glb_auto_scroll_step_remainder
        cmpd  glb_camera_y_min
        blt   ATS_Stop
        std   <glb_camera_y_pos
        rts
        
ATS_Down
        ; ... symétrique pour Down ...
```

### Sub-pixel accumulator

La step est 8.8 (msb = px entiers, lsb = sub-pixel). À chaque frame, on accumule dans `step_remainder`. Quand le total dépasse 1 pixel entier, on bouge la caméra.

Exemple : step = `$0080` (0.5 px/frame). Après 2 frames, remainder = `$0100` (1 px). On bouge la caméra de 1 px et reset remainder.

### Usage

```asm
        ; Programmer un scroll vers le bas sur 100 frames à 1.5 px/frame
        lda   #scroll_state_down
        sta   glb_auto_scroll_state
        ldd   #100
        std   glb_auto_scroll_frames
        ldd   #$0180                    ; 1.5 px/frame
        std   glb_auto_scroll_step
        clr   glb_auto_scroll_step_remainder      ; reset remainder
        clr   glb_auto_scroll_step_remainder+1

        ; Dans MainLoop :
        jsr   AutoScroll
```

À la fin des 100 frames (ou si la caméra atteint la borne), `AutoScroll` met `state = stop` automatiquement.

## `CheckCameraMove`

```asm
CheckCameraMove
        ldd   glb_camera_x_pos
        cmpd  prev_glb_camera_x_pos
        bne   @moved
        ldd   glb_camera_y_pos
        cmpd  prev_glb_camera_y_pos
        beq   @same
@moved
        lda   #1
        sta   <glb_camera_move
        ; ... update prev values ...
        rts
@same
        clr   <glb_camera_move
        rts
```

Met `glb_camera_move = 1` si la caméra a bougé depuis la dernière frame, 0 sinon.

Usage : trigger un refresh des sprites en coord playfield :
```asm
        jsr   CheckCameraMove
        lda   <glb_camera_move
        beq   @no_refresh
        lda   #1
        sta   <glb_force_sprite_refresh
@no_refresh
```

Sans ça, les sprites peuvent rester à l'ancienne position visuellement.

## Bornes de scroll

```asm
glb_camera_x_min_pos              ; (et y_min)
glb_camera_x_max_pos              ; (et y_max)
```

À initialiser au début du game-mode :
```asm
        ldd   #0
        std   glb_camera_x_min_pos
        ldd   #map_width-160            ; scroll jusqu'à voir la dernière colonne
        std   glb_camera_x_max_pos
```

`AutoScroll` consulte ces bornes pour arrêter le scroll automatiquement.

`vscroll.move` consulte aussi (logique applicative).

## Pattern goldorak — macros caméra

goldorak factorise dans `global/global-macros.asm` :
```asm
_camera.set #pos                       ; macro pour positionner la caméra
_camera.move #speed                    ; macro pour démarrer un AutoScroll
```

(macros locales au projet)

## Pitfalls

- **`glb_camera_x_offset` / `y_offset` non init** : sprites mal placés (sortie de `InitDrawSprites` cf. graphics-pipeline)
- **`AutoScroll` sans `clr glb_auto_scroll_step_remainder`** : valeurs résiduelles du précédent scroll → comportement erratique
- **`glb_camera_x_pos > glb_camera_x_max_pos`** : selon le contexte, peut continuer à scroller (illégalement) ou être bloqué
- **Modifier `glb_camera_x_pos` manuellement pendant un AutoScroll** : conflit, valeurs override
- **`CheckCameraMove` mais pas de `glb_force_sprite_refresh`** : sprites en coord playfield ne se redessinent pas
- **Sub-pixel remainder pas reset entre scrolls** : précision de plus en plus mauvaise
- **Mode 320×200 vs 160×200** : `glb_camera_width` et `glb_camera_x_offset` doivent matcher le mode
