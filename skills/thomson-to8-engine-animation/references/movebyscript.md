# `moveByScript` — scripts de trajectoire

`moveByScript` est un système d'animation **dirigé par script** où chaque pas du script définit :
- une frame à afficher
- une vélocité X
- une vélocité Y
- une vitesse d'animation (anim_frame_duration)

Permet de programmer des trajectoires complexes (waves, courbes, patterns d'attaque) en mode déclaratif.

## Vue d'ensemble

```
Script (en mémoire) = suite de SEGMENTS
Chaque segment = "anim_frame_duration" + suite de STEPS
Chaque step = bitfield + (optionnellement) frame, x_vel, y_vel, ...

OST de l'objet pendant l'exécution :
  anim,u           → pointeur vers le script global (ou LUT)
  sub_anim,u       → pointeur vers le segment courant
  anim_frame_duration,u → durée restante avant le pas suivant
```

## Format du script

### Step

Chaque step commence par un **bitfield** (1 octet) qui indique quels champs sont présents :

```
Bit | Champ      | Bytes
----|------------|------
7   | new frame  | 1
6   | new x_vel  | 2
5   | new y_vel  | 2
4   | new ...    | ...
0   | end-of-step (?)
```

Implémentation observée :
```asm
AnimateMove
        ldy   sub_anim,u
        beq   @rts
        ldd   #0
        std   x_vel,u
        std   y_vel,u
        ldb   ,y+                       ; read bitfield
@frame  lslb
        bcc   @xvel
        lda   ,y+
        sta   anim_frame,u
@xvel   lslb
        bcc   @yvel
        ldx   ,y++
        stx   x_vel,u
@yvel   lslb
        ; ...
```

Le bitfield est shifté (`lslb`) bit par bit ; chaque bit positif déclenche la lecture du champ correspondant.

### Segment

Un segment regroupe plusieurs steps avec une vitesse d'animation commune.

```
adresse_segment :
  fcb   speed       ; anim_frame_duration pour ce segment (1 octet)
  ; suite de steps...
  fcb   $00         ; marqueur fin de segment
adresse_segment_suivant : ...
```

Le moteur lit `speed` au début, puis joue chaque step en attendant `speed` frames entre.

## Macros et équates

```asm
; Équates à définir dans le code utilisateur
moveByScript.NEGXSTEP equ scale.XN1PX     ; valeur du déplacement X négatif
moveByScript.POSXSTEP equ scale.XP1PX
moveByScript.NEGYSTEP equ scale.YN1PX
moveByScript.POSYSTEP equ scale.YP1PX

; Variables internes
moveByScript.callback       equ glb_a0
moveByScript.anim.speed     equ glb_d0
moveByScript.anim.end       equ glb_d0_b
moveByScript.anim.loops     equ glb_d0_b+1
```

## Routines

### `moveByScript.register`

Enregistre l'objet contenant les données d'animation (typiquement l'objet `ObjID_animation` du game-mode) :

```asm
        ldb   #ObjID_animation
        jsr   moveByScript.register
```

Sauvegarde la page+adresse pour usage ultérieur. À appeler une fois au boot du game-mode.

### `moveByScript.initialize`

Charge un script dans l'OST courant :

```asm
        ldx   #script_index             ; index dans la LUT
        jsr   moveByScript.initialize
```

Effet :
- `anim,u` = adresse du script
- `sub_anim,u` = adresse du premier segment

### `moveByScript.runByFrameDrop`

Exécute le script en utilisant `gfxlock.frameDrop.count` pour compenser le drop :

```asm
        jsr   moveByScript.runByFrameDrop
```

Si `frameDrop.count = 2`, le script avance de 2 steps d'un coup.

### `moveByScript.runByB`

Exécute B fois (passé en registre B) :

```asm
        ldb   #1
        jsr   moveByScript.runByB       ; 1 step
```

Permet un contrôle fin si on ne veut pas dépendre de frameDrop.

## Algorithme `runByFrameDrop`

```asm
moveByScript.runByFrameDrop
        ldb   gfxlock.frameDrop.count
moveByScript.runByB
        tstb
        bne   >
        ldb   #1                        ; cap à 1 minimum
!       stb   moveByScript.anim.loops
        _GetCartPageA
        sta   @page
@loop   lda   #0
moveByScript.anim.page.2 equ *-1
        _SetCartPageA
        lda   anim_frame_duration,u
        sta   moveByScript.anim.speed
LAB_0000_f9c6
        ldx   sub_anim,u
        ldb   ,x+                       ; lit bitfield du step
        ; ... applique chaque champ selon les bits ...
```

## Format complet d'un script

```
Script ($0000) :
  fdb segment_1                         ; adresse premier segment
  
Segment 1 ($0002) :
  fcb 4                                 ; speed = 4 frames par step
  fcb %11000000                         ; bitfield : new_frame + new_x_vel
    fcb 5                               ; new frame = 5
    fdb $0100                           ; new x_vel = $0100 (= +1.0)
  fcb %01000000                         ; new_x_vel seul
    fdb $0080                           ; +0.5
  fcb %10000000                         ; new_frame seul
    fcb 6
  ; ... autres steps
  fcb 0                                 ; fin de segment
  fdb segment_2                         ; adresse segment suivant

Segment 2 ($XXXX) :
  fcb 2                                 ; speed plus rapide
  ; ...
```

## Usage typique

```asm
; Au boot du game-mode
        ldb   #ObjID_animation
        jsr   moveByScript.register

; Init d'un objet ennemi
Init
        ldx   #5                        ; index du script "pattern_5"
        jsr   moveByScript.initialize
        inc   routine,u
        rts

; Main de l'objet
Main
        jsr   moveByScript.runByFrameDrop
        jsr   ObjectMoveSync            ; applique x_vel/y_vel (modifiés par le script)
        jsr   AnimateSprite             ; affiche la frame (anim_frame,u modifié par le script)
        jmp   DisplaySprite
```

## Cas d'usage

- **Patterns d'ennemis** : un ennemi qui suit une trajectoire en zig-zag, en cercle, en S
- **Cinématiques** : objet qui traverse l'écran selon un parcours scénarisé
- **Animations complexes** : changement de frame ET de position simultané (e.g. un personnage qui saute)
- **Réutilisation** : un script peut être réutilisé par plusieurs objets (chaque objet ouvre le même script avec son propre `sub_anim`)

## Différence avec animation v02

| Aspect | Animation v02 | moveByScript |
|--------|---------------|--------------|
| Pilote | Frame + flags | Frame + x_vel + y_vel + ... |
| Mouvement | Géré par l'objet (logique) | **Inclus dans le script** |
| Callbacks | Via `anim_flags` LUT | Via `moveByScript.callback` |
| Format | 5 octets/frame fixe | Bitfield variable (1-7 octets/step) |

`moveByScript` est plus **puissant** mais aussi plus **complexe**. Pour de simples animations cycliques, préférer v00/v02. Pour des trajectoires complexes (boss patterns), `moveByScript` est plus adapté.

## Pitfalls

- **`moveByScript.register` non appelé** : `anim.page.2` non init, page random mountée → crash
- **`moveByScript.initialize` avec un index invalide** : pointe hors LUT, `anim,u` invalide
- **Script sans fin de segment ($00)** : le moteur continue de lire la mémoire → comportement erratique
- **`anim_frame_duration` modifié par autre chose** : la vitesse d'animation change
- **Bitfield mal compris** : si on inverse l'ordre des champs dans le script, le moteur lit la mauvaise séquence
- **Mélanger `moveByScript` avec `ObjectMove`** : OK ; `moveByScript` modifie `x_vel`/`y_vel`, `ObjectMove` applique
- **Sans `ObjectMoveSync` après `moveByScript.runByFrameDrop`** : `x_vel`/`y_vel` mis à jour mais position pas changée → l'objet est figé visuellement
- **`moveByScript` consulté depuis l'IRQ** : pas re-entrant, ne pas appeler depuis UserIRQ
