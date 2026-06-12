# `terrainCollision` — collision avec un terrain statique

Pour les jeux à scrolling avec un terrain solide (murs, sols, plateformes), l'engine fournit `terrainCollision` : un système qui consulte des **lookup tables** décrivant la structure du terrain. Utilisé exclusivement par r-type dans les game-projects observés.

## Concept

Le terrain est représenté par un **objet** (`ObjID_collision`) qui exporte **4 entry points** consécutifs en mémoire (espacés de 3 octets) :

```asm
ObjID_collision entry points :
  offset 0  : terrainCollision.main          (check vertical)
  offset 3  : terrainCollision.xAxis.doRight (check à droite)
  offset 6  : terrainCollision.xAxis.doLeft  (check à gauche)
  offset 9  : terrainCollision.update        (update tables)
```

L'engine fournit des **routines wrapper** (avec sauvegarde/restauration de page) qui appellent ces entry points via leurs adresses auto-modifiées.

## Initialisation — `_terrainCollision.init`

```asm
        _terrainCollision.init ObjID_collision
```

Macro :
```asm
_terrainCollision.init MACRO
        lda   Obj_Index_Page+\1
        sta   terrainCollision.main.page
        sta   terrainCollision.main.xAxis.doRight.page
        sta   terrainCollision.main.xAxis.doLeft.page
        sta   terrainCollision.main.update.page
        ldd   Obj_Index_Address+2*\1
        std   terrainCollision.main.address
        addd  #3
        std   terrainCollision.main.xAxis.doRight.address
        addd  #3
        std   terrainCollision.main.xAxis.doLeft.address
        addd  #3
        std   terrainCollision.main.update.address
 ENDM
```

À appeler **une fois au boot** du game-mode (après les `_MountObject` initiaux).

## Variables d'état

```asm
terrainCollision.sensor.x   fdb 0       ; coordonnée X du sensor (entrée)
terrainCollision.sensor.y   fdb 0       ; coordonnée Y du sensor (entrée)
terrainCollision.impact.x   fdb 0       ; coordonnée X impact (sortie)
```

`sensor.x/y` = point à tester. `impact.x` = position de collision retournée (0 = pas de collision).

## Routines wrapper

```asm
terrainCollision.do                     ; check terrain (vertical typiquement)
        _GetCartPageA
        sta   @page                     ; sauve page courante
        lda   #0                        ; (modif par init)
terrainCollision.main.page equ *-1
        _SetCartPageA                   ; mount page du terrain
        jsr   >0                        ; appel routine du terrain
terrainCollision.main.address equ *-2
        lda   #0                        ; restore page
@page   equ *-1
        _SetCartPageA
        rts

terrainCollision.xAxis.doRight          ; check à droite
        ; (même structure)

terrainCollision.xAxis.doLeft           ; check à gauche
        ; (même structure)

terrainCollision.update                 ; update tables
        sta   @a                        ; sauvegarde le paramètre A
        ; ... mount page ...
        lda   @a                        ; restore param
        jsr   ...
```

## Implémentation côté objet `collision`

L'objet `collision` doit exporter 4 entry points dans cet ordre, espacés de 3 octets :

```asm
        org   $A100                     ; (selon placement)
Collision                               ; entry point 0 : main
        jmp   Collision_Main
        ; (occupe 3 octets : jmp + adresse 2 octets)

Collision_doRight                       ; entry point +3
        jmp   Collision_DoRight
        ; (3 octets)

Collision_doLeft                        ; entry point +6
        jmp   Collision_DoLeft
        ; (3 octets)

Collision_update                        ; entry point +9
        jmp   Collision_Update
        ; (3 octets)

; Implémentations ailleurs
Collision_Main
        ; Lit terrainCollision.sensor.x et sensor.y
        ; Cherche dans la lookup table si la position est dans un mur
        ; Si oui, écrit terrainCollision.impact.x
        rts
; ...
```

Chaque `jmp` fait 3 octets, ce qui matche l'espacement attendu par le wrapper.

## Lookup tables — pattern r-type

Dans r-type, le terrain est représenté par :
- Une **table de hauteurs** indexée par X (pour le sol et le plafond)
- Une **table de murs** pour les obstacles latéraux

Le `Collision_Main` lit `sensor.x`, calcule l'index dans la table, lit la hauteur, et compare à `sensor.y`. Si collision, écrit `impact.x`.

```asm
Collision_Main
        ldd   terrainCollision.sensor.x
        ; ... convert to table index ...
        ldx   #floor_height_table
        ldb   d,x                       ; hauteur du sol à cette X
        cmpb  terrainCollision.sensor.y+1
        bls   @no_collision
        ; ... compute impact ...
        std   terrainCollision.impact.x
        rts
@no_collision
        ldd   #0
        std   terrainCollision.impact.x
        rts
```

## Usage typique (pattern r-type)

```asm
; Avant de bouger le joueur, vérifier qu'on peut
Player_TryMove
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        jsr   terrainCollision.do
        ldd   terrainCollision.impact.x
        bne   @blocked                  ; impact != 0 → collision
        ; ... appliquer le mouvement ...
        rts
@blocked
        ; ... bloquer ou rebondir ...
        rts

; Check ouvert/fermé latéralement
        jsr   terrainCollision.xAxis.doRight
        bne   @wall_right
        jsr   terrainCollision.xAxis.doLeft
        bne   @wall_left
```

## `terrainCollision.update`

Permet de **modifier le terrain** à runtime (e.g. murs destructibles). Le paramètre A indique quoi modifier ; l'objet `collision` met à jour ses tables.

Usage rare. Cf. r-type pour le cas spécifique (boss qui modifie le terrain).

## Comparaison avec AABB

| Aspect | AABB | terrainCollision |
|--------|------|------------------|
| Cibles | Objets dynamiques | Terrain statique |
| Représentation | Box centre-radius | Lookup table |
| Coût | O(N×M) | O(1) par check |
| Précision | Sub-pixel | Tile-aligned |
| Modification | Add/Remove dynamique | Update via routine |

Les deux systèmes **coexistent** dans r-type : AABB pour player vs ennemis, terrainCollision pour player vs murs.

## Patterns d'usage

### Sensors multiples (plateformer)

Pour un personnage de plateformer, on a typiquement 4-8 sensors :
- Bas-gauche et bas-droit (détection sol)
- Haut-gauche et haut-droit (détection plafond)
- Gauche-haut et gauche-bas (détection mur gauche)
- Droite-haut et droite-bas (détection mur droit)

Chaque sensor positionne `sensor.x` et `sensor.y` puis appelle `terrainCollision.do`.

### Intégration avec scroll

Quand la caméra bouge, les positions sensor doivent être en **coord playfield** (cohérentes avec le terrain). L'objet `collision` doit faire la conversion playfield → table index.

### Anti-stuck

Si un objet est déjà dans le terrain (e.g. spawn en superposition), `terrainCollision.do` retourne `impact != 0` à chaque check. Pattern : tester la sortie possible (`xAxis.doRight`/`doLeft`) et pousser dans la direction libre.

## Pitfalls

- **`_terrainCollision.init` non appelé** : `terrainCollision.main.address = 0` → `jsr >0` → crash
- **Object `collision` mal défini** (entry points pas espacés de 3 octets) : le wrapper jsr à la mauvaise adresse → comportement erratique
- **Sensor.x/y non mis à jour** avant l'appel : utilise la valeur précédente
- **Lookup table mal alignée avec scroll** : impact retourné incohérent avec ce qu'on voit à l'écran
- **Update du terrain pendant que d'autres objets sont en train de check** : race condition potentiel (si test multi-frame)
- **terrainCollision.do appelée pendant que la page de `collision` est mountée** : double mount, OK car wrapper sauve/restaure
- **Confondre coord playfield et écran** dans `sensor.x/y` : le terrain est en coord playfield (le moteur ne fait pas de conversion automatique)
